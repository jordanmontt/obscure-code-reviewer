"
I test comments on topics: in the copied review and across a refresh.
"
Class {
	#name : 'OCRReviewTopicsTest',
	#superclass : 'TestCase',
	#category : 'ObscureCodeReviewer-Tests',
	#package : 'ObscureCodeReviewer-Tests'
}

{ #category : 'helpers' }
OCRReviewTopicsTest >> methodChange: aSelector class: aClassName [

	^ OCRMethodChange modification
		  packageName: 'MyProject';
		  className: aClassName;
		  selector: aSelector;
		  yourself
]

{ #category : 'helpers' }
OCRReviewTopicsTest >> reviewWith: someChanges guide: aString [

	^ (OCRReview
		   repositoryName: 'my-project'
		   base: OCRLastCommitBase new
		   baseLabel: 'abc1234 (last commit)'
		   changes: someChanges)
		  guide: (OCRReviewGuide fromText: aString);
		  yourself
]

{ #category : 'tests' }
OCRReviewTopicsTest >> testRefreshKeepsCommentsOnTopicsStillInTheGuide [

	| old new |
	old := self reviewWith: #(  ) guide: '# Parse faster'.
	old comment: 'Split this topic' on: old guide topics first.
	new := self reviewWith: #(  ) guide: '# Parse faster'.

	new takeCommentsFrom: old.

	self assert: (new commentOn: new guide topics first) equals: 'Split this topic'.
	self assert: new generalComment equals: ''
]

{ #category : 'tests' }
OCRReviewTopicsTest >> testRefreshMovesCommentsOnRemovedTopicsToTheGeneralComment [

	| old new |
	old := self reviewWith: #(  ) guide: '# Parse faster'.
	old comment: 'Split this topic' on: old guide topics first.
	new := self reviewWith: #(  ) guide: '# Something else'.

	new takeCommentsFrom: old.

	self assert: new generalComment equals: 'Topic: Parse faster (item no longer in diff): Split this topic'
]

{ #category : 'tests' }
OCRReviewTopicsTest >> testTopicCommentIsInTheFeedbackAfterTheGeneralComment [

	| review topic feedback |
	review := self reviewWith: { (self methodChange: #a class: 'A') } guide: '# Parse faster
- A>>#a'.
	topic := review guide topics first.
	review generalComment: 'Overall fine'.
	review comment: 'Split this topic' on: topic.
	review comment: 'Rename' on: (self methodChange: #a class: 'A').

	feedback := review feedback.

	self assert: (feedback includesSubstring: (String lf join: #( '## Topic: Parse faster' 'Split this topic' ))).
	self assert: (feedback indexOfSubCollection: '## General') < (feedback indexOfSubCollection: '## Topic: Parse faster').
	self assert: (feedback indexOfSubCollection: '## Topic: Parse faster') < (feedback indexOfSubCollection: '## A>>#a')
]
