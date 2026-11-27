"
I test comments on topics: in the copied review and across a refresh.
"
Class {
	#name : 'OCRReviewTopicsTest',
	#superclass : 'OCRTestCase',
	#category : 'ObscureCodeReviewer-Tests',
	#package : 'ObscureCodeReviewer-Tests'
}

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
