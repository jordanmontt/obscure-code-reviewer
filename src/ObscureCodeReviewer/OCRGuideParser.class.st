"
I read a review guide written in Markdown and answer an OCRReviewGuide.

- A line starting with '# ' starts a topic; the rest of the line is its title.
- A line starting with '- ' lists a change of the current topic: 'Foo>>#bar', 'Foo class>>#bar', or 'Foo' for a class definition. Backquotes are ignored, and 'Foo>>bar' is read as 'Foo>>#bar'.
- Any other line is part of the current topic's explanation.
- Text before the first topic is an introduction and is ignored.

I never fail: whatever I do not understand ends up in an explanation, or in the warnings of the review (see OCRTopicTreeBuilder).
"
Class {
	#name : 'OCRGuideParser',
	#superclass : 'Object',
	#category : 'ObscureCodeReviewer-Model',
	#package : 'ObscureCodeReviewer',
	#tag : 'Model'
}

{ #category : 'parsing' }
OCRGuideParser >> parse: aString [

	| topics |
	topics := OrderedCollection new.
	aString lines do: [ :each | self readLine: each trimBoth into: topics ].
	^ OCRReviewGuide text: aString topics: topics
]

{ #category : 'private' }
OCRGuideParser >> readLine: aLine into: someTopics [

	(aLine beginsWith: '# ') ifTrue: [ ^ someTopics add: (OCRTopic titled: (aLine allButFirst: 2) trimBoth) ].
	someTopics ifEmpty: [ ^ self ].
	(aLine beginsWith: '- ') ifTrue: [ ^ someTopics last addReference: (self referenceIn: (aLine allButFirst: 2)) ].
	someTopics last addExplanationLine: aLine
]

{ #category : 'private' }
OCRGuideParser >> referenceIn: aString [
	"Answer the reference as changes write it: 'Foo>>#bar'."

	| reference |
	reference := (aString copyWithout: $`) trimBoth.
	((reference includesSubstring: '>>') and: [ (reference includesSubstring: '>>#') not ]) ifTrue: [
		^ reference copyReplaceAll: '>>' with: '>>#' ].
	^ reference
]
