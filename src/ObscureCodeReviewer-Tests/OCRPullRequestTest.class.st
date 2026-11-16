"
I test the pull request description: the agent draft from the guide, the reviewer edits, and Copy review.
"
Class {
	#name : 'OCRPullRequestTest',
	#superclass : 'TestCase',
	#category : 'ObscureCodeReviewer-Tests',
	#package : 'ObscureCodeReviewer-Tests'
}

{ #category : 'helpers' }
OCRPullRequestTest >> fileChange: aPath [

	^ OCRFileChange modification
		  path: aPath;
		  oldSource: 'old';
		  newSource: 'new';
		  yourself
]

{ #category : 'helpers' }
OCRPullRequestTest >> methodChange: aSelector class: aClassName [

	^ OCRMethodChange modification
		  packageName: 'MyProject';
		  className: aClassName;
		  selector: aSelector;
		  oldSource: aSelector , ' ^ 1';
		  newSource: aSelector , ' ^ 2';
		  yourself
]

{ #category : 'helpers' }
OCRPullRequestTest >> reviewWith: someChanges [

	^ self reviewWith: someChanges guide: ''
]

{ #category : 'helpers' }
OCRPullRequestTest >> reviewWith: someChanges guide: aString [

	^ (OCRReview
		   repositoryName: 'my-project'
		   base: OCRLastCommitBase new
		   baseLabel: 'abc1234 (last commit)'
		   changes: someChanges)
		  guide: (OCRReviewGuide fromText: aString);
		  yourself
]

{ #category : 'tests' }
OCRPullRequestTest >> testEditedPullRequestIsCopied [

	| review feedback |
	review := self reviewWith: #(  ) guide: 'Title: Add topics
Body'.
	review pullRequest: (OCRPullRequest title: 'Add topics to reviews' body: 'Body').

	feedback := review feedback.

	self assert: review isPullRequestEdited.
	self assert: (feedback includesSubstring:
		 (String lf join: #( '## Pull request (edited by the reviewer)' 'Title: Add topics to reviews' '' 'Body' )))
]

{ #category : 'tests' }
OCRPullRequestTest >> testRefreshKeepsTheReviewerEdits [

	| old new |
	old := self reviewWith: #(  ) guide: 'Title: Draft'.
	old pullRequest: (OCRPullRequest title: 'Mine' body: '').
	new := self reviewWith: #(  ) guide: 'Title: New draft'.

	new continueFrom: old.

	self assert: new pullRequest title equals: 'Mine'
]

{ #category : 'tests' }
OCRPullRequestTest >> testRefreshTakesANewDraftWhenNotEdited [

	| old new |
	old := self reviewWith: #(  ) guide: 'Title: Draft'.
	new := self reviewWith: #(  ) guide: 'Title: New draft'.

	new continueFrom: old.

	self assert: new pullRequest title equals: 'New draft'
]

{ #category : 'tests' }
OCRPullRequestTest >> testTheReviewStartsWithTheAgentDraft [

	| review |
	review := self reviewWith: #(  ) guide: 'Title: Add topics
Body'.

	self assert: review pullRequest equals: (OCRPullRequest title: 'Add topics' body: 'Body').
	self deny: review isPullRequestEdited
]

{ #category : 'tests' }
OCRPullRequestTest >> testUneditedPullRequestIsNotCopied [

	| review |
	review := self reviewWith: #(  ) guide: 'Title: Add topics
Body'.

	self deny: (review feedback includesSubstring: 'Pull request')
]
