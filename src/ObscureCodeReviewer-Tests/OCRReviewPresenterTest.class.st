"
I test OCRReviewPresenter without opening it: the guide is the one the review comes with, never a stored one.
"
Class {
	#name : 'OCRReviewPresenterTest',
	#superclass : 'TestCase',
	#category : 'ObscureCodeReviewer-Tests',
	#package : 'ObscureCodeReviewer-Tests'
}

{ #category : 'helpers' }
OCRReviewPresenterTest >> emptyReview [

	^ OCRReview
		  repositoryName: 'my-project'
		  base: OCRLastCommitBase new
		  baseLabel: 'abc1234 (last commit)'
		  changes: #(  )
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testApplyKeepsTheReviewerEditsOfThePullRequest [

	| review presenter next |
	review := self emptyReview
		          guide: (OCRReviewGuide fromText: 'Title: Draft');
		          yourself.
	presenter := OCRReviewPresenterStub on: review.
	review pullRequest: (OCRPullRequest title: 'Mine' body: '').
	next := self emptyReview.
	presenter nextReview: next.

	presenter applyGuide: 'Title: New draft'.

	self assert: next pullRequest title equals: 'Mine'
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testApplyShowsTheNewGuide [

	| presenter next |
	presenter := OCRReviewPresenterStub on: (self emptyReview
		              guide: (OCRReviewGuide fromText: '# Parse faster');
		              yourself).
	next := self emptyReview.
	presenter nextReview: next.

	presenter applyGuide: '# Clean up'.

	self assert: (next guide topics collect: [ :each | each title ] as: Array) equals: #( 'Clean up' )
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testRefreshKeepsTheGuide [

	| guide presenter next |
	guide := OCRReviewGuide fromText: '# Parse faster'.
	presenter := OCRReviewPresenterStub on: (self emptyReview
		              guide: guide;
		              yourself).
	next := self emptyReview.
	presenter nextReview: next.

	presenter refresh.

	self assert: next guide identicalTo: guide
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testTheGuideIsTheOneOfTheReview [

	| review guide |
	guide := OCRReviewGuide fromText: '# Parse faster'.
	review := self emptyReview
		          guide: guide;
		          yourself.

	OCRReviewPresenter on: review.

	self assert: review guide identicalTo: guide
]
