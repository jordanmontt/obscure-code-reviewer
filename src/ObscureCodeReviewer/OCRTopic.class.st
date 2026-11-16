"
I am one topic of a review guide: a group of changes that do one thing, with an explanation of why.

My references are the changes I list, as 'Foo>>#bar', 'Foo class>>#bar' or 'Foo' for a class definition. I can be commented like a change: my reference is 'Topic: ' followed by my title.
"
Class {
	#name : 'OCRTopic',
	#superclass : 'Object',
	#instVars : [
		'title',
		'explanationLines',
		'references'
	],
	#category : 'ObscureCodeReviewer-Model',
	#package : 'ObscureCodeReviewer',
	#tag : 'Model'
}

{ #category : 'instance creation' }
OCRTopic class >> titled: aString [

	^ self new
		  setTitle: aString;
		  yourself
]

{ #category : 'building' }
OCRTopic >> addExplanationLine: aString [

	explanationLines add: aString
]

{ #category : 'building' }
OCRTopic >> addReference: aReference [
	"A change listed twice in the same topic is kept once."

	(references includes: aReference) ifTrue: [ ^ self ].
	references add: aReference
]

{ #category : 'accessing' }
OCRTopic >> explanation [

	^ (String cr join: explanationLines) trimBoth
]

{ #category : 'accessing' }
OCRTopic >> lists: aReference [

	^ references includes: aReference
]

{ #category : 'displaying' }
OCRTopic >> printOn: aStream [

	aStream nextPutAll: self reference
]

{ #category : 'displaying' }
OCRTopic >> reference [
	"How comments are attached to me, and my title in the copied review."

	^ 'Topic: ' , title
]

{ #category : 'accessing' }
OCRTopic >> references [
	"In the order of the guide."

	^ references
]

{ #category : 'initialization' }
OCRTopic >> setTitle: aString [

	title := aString.
	explanationLines := OrderedCollection new.
	references := OrderedCollection new
]

{ #category : 'accessing' }
OCRTopic >> title [

	^ title
]
