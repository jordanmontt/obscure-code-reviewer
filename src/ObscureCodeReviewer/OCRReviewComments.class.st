"
I am the reviewer's comments in a review: one per change or topic, attached by its reference (e.g. 'MyClass>>#myMethod' or 'Topic: Parse faster'), and one general comment for the whole review.

OCRReview holds me and keeps me across a refresh (see OCRReview>>#takeCommentsFrom:).

	comments := OCRReviewComments new.
	comments comment: 'Please rename this' on: aChange.
	comments commentOn: aChange ""'Please rename this'""
"
Class {
	#name : 'OCRReviewComments',
	#superclass : 'Object',
	#instVars : [
		'byReference',
		'general'
	],
	#category : 'ObscureCodeReviewer-Model',
	#package : 'ObscureCodeReviewer',
	#tag : 'Model'
}

{ #category : 'comments' }
OCRReviewComments >> addLostComment: aComment on: aReference [
	"Append aComment to the general comment, saying which item it was about."

	general := String streamContents: [ :stream |
		           general trimBoth ifNotEmpty: [ :text |
			           stream
				           nextPutAll: text;
				           cr;
				           cr ].
		           stream
			           nextPutAll: aReference;
			           nextPutAll: ' (item no longer in diff): ';
			           nextPutAll: aComment trimBoth ]
]

{ #category : 'comments' }
OCRReviewComments >> comment: aString on: anItem [
	"anItem is a change or a topic. An empty comment removes the comment."

	self comment: aString onReference: anItem reference
]

{ #category : 'comments' }
OCRReviewComments >> comment: aString onReference: aReference [

	aString trimBoth isEmpty ifTrue: [ ^ byReference removeKey: aReference ifAbsent: [ self ] ].
	byReference at: aReference put: aString
]

{ #category : 'comments' }
OCRReviewComments >> commentAtReference: aReference [

	^ byReference at: aReference
]

{ #category : 'comments' }
OCRReviewComments >> commentOn: anItem [
	"My comment on anItem (a change or a topic), or an empty string."

	^ byReference at: anItem reference ifAbsent: [ '' ]
]

{ #category : 'comments' }
OCRReviewComments >> commentedReferences [
	"The references of the items I have a comment on, sorted."

	^ byReference keys sorted
]

{ #category : 'comments' }
OCRReviewComments >> general [

	^ general
]

{ #category : 'comments' }
OCRReviewComments >> general: aString [

	general := aString
]

{ #category : 'comments' }
OCRReviewComments >> hasCommentOn: anItem [

	^ byReference includesKey: anItem reference
]

{ #category : 'initialization' }
OCRReviewComments >> initialize [

	super initialize.
	byReference := Dictionary new.
	general := ''
]
