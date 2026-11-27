"
I test how a refreshed OCRReview keeps the comments of the review it replaces.
"
Class {
	#name : 'OCRReviewRefreshTest',
	#superclass : 'TestCase',
	#category : 'ObscureCodeReviewer-Tests',
	#package : 'ObscureCodeReviewer-Tests'
}

{ #category : 'helpers' }
OCRReviewRefreshTest >> methodChange: aSelector [

	^ OCRMethodChange modification
		  packageName: 'MyProject';
		  className: 'MyClass';
		  selector: aSelector;
		  yourself
]

{ #category : 'helpers' }
OCRReviewRefreshTest >> reviewWith: someChanges [

	^ OCRReview
		  repositoryName: 'my-project'
		  reviewBase: (OCRReviewBase base: OCRLastCommitBase new commitId: 'abc1234')
		  changes: someChanges
]

{ #category : 'tests' }
OCRReviewRefreshTest >> testCommentOnVanishedChangeMovesToGeneralComment [

	| old new |
	old := self reviewWith: { (self methodChange: #a) }.
	old comment: 'Rename this' on: (self methodChange: #a).
	new := self reviewWith: { (self methodChange: #b) }.

	new takeCommentsFrom: old.

	self deny: (new hasCommentOn: (self methodChange: #a)).
	self assert: new generalComment equals: 'MyClass>>#a (item no longer in diff): Rename this'
]

{ #category : 'tests' }
OCRReviewRefreshTest >> testCommentsOnChangesStillThereAreKept [

	| old new |
	old := self reviewWith: { (self methodChange: #a) }.
	old comment: 'Rename this' on: (self methodChange: #a).
	new := self reviewWith: { (self methodChange: #a) }.

	new takeCommentsFrom: old.

	self assert: (new commentOn: (self methodChange: #a)) equals: 'Rename this'
]

{ #category : 'tests' }
OCRReviewRefreshTest >> testGeneralCommentIsKept [

	| old new |
	old := self reviewWith: { (self methodChange: #a) }.
	old generalComment: 'Good start.'.
	new := self reviewWith: { (self methodChange: #a) }.

	new takeCommentsFrom: old.

	self assert: new generalComment equals: 'Good start.'
]

{ #category : 'tests' }
OCRReviewRefreshTest >> testVanishedCommentsComeAfterGeneralCommentInReferenceOrder [

	| old new |
	old := self reviewWith: {
		       (self methodChange: #a).
		       (self methodChange: #b) }.
	old generalComment: 'Good start.'.
	old comment: 'Second' on: (self methodChange: #b).
	old comment: 'First' on: (self methodChange: #a).
	new := self reviewWith: #(  ).

	new takeCommentsFrom: old.

	self assert: new generalComment equals: (String cr join:
		 #( 'Good start.' '' 'MyClass>>#a (item no longer in diff): First' '' 'MyClass>>#b (item no longer in diff): Second' ))
]
