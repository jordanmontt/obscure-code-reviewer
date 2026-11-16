"
I write the comments of a review as Markdown, ready to paste to the agent:

	Review of my-project, base abc1234 (last commit)

	## General
	The general comment.

	## MyClass>>#myMethod (modified)
	The comment on that method.

Only commented items are written, in the order of the changes tree.

	OCRFeedbackWriter new feedbackFor: aReview
"
Class {
	#name : 'OCRFeedbackWriter',
	#superclass : 'Object',
	#category : 'ObscureCodeReviewer-Model',
	#package : 'ObscureCodeReviewer',
	#tag : 'Model'
}

{ #category : 'writing' }
OCRFeedbackWriter >> commentedChangesOf: aReview [

	| commented |
	commented := OrderedCollection new.
	aReview structuralTree do: [ :section |
		section withAllChildrenDo: [ :node |
			(node hasChange and: [ aReview hasCommentOn: node change ]) ifTrue: [ commented add: node change ] ] ].
	^ commented
]

{ #category : 'writing' }
OCRFeedbackWriter >> feedbackFor: aReview [

	^ String streamContents: [ :stream |
		  self writeHeaderOf: aReview on: stream.
		  self writeGeneralCommentOf: aReview on: stream.
		  (self commentedChangesOf: aReview) do: [ :each |
			  self writeSection: (self titleOf: each) text: (aReview commentOn: each) on: stream ] ]
]

{ #category : 'writing' }
OCRFeedbackWriter >> titleOf: aChange [

	^ aChange reference , ' (' , aChange kindDescription , ')'
]

{ #category : 'writing' }
OCRFeedbackWriter >> writeGeneralCommentOf: aReview on: aStream [

	aReview generalComment trimBoth isEmpty ifTrue: [ ^ self ].
	self writeSection: 'General' text: aReview generalComment on: aStream
]

{ #category : 'writing' }
OCRFeedbackWriter >> writeHeaderOf: aReview on: aStream [

	aStream
		nextPutAll: 'Review of ';
		nextPutAll: aReview repositoryName;
		nextPutAll: ', base ';
		nextPutAll: aReview baseLabel;
		lf;
		lf
]

{ #category : 'writing' }
OCRFeedbackWriter >> writeSection: aTitle text: aString on: aStream [

	aStream
		nextPutAll: '## ';
		nextPutAll: aTitle;
		lf;
		nextPutAll: aString trimBoth withUnixLineEndings;
		lf;
		lf
]
