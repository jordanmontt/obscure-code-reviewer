"
I read a review guide written in Markdown and answer an OCRReviewGuide.

	Title: Add topics to the review
	The agent groups its changes by purpose.

	# Goal
	The reviewer reads the changes one purpose at a time.

	Topics:

	# Read the guide
	Why: the agent explains its changes as topics.
	- OCRGuideParser>>#parse: reads the whole text
	- OCRTopic
	- OCRTopic>>#reference <- OCRChange>>#reference

- The text before a line 'Topics:' is the pull request description (OCRPullRequest), as it is: an optional first line 'Title: ...', then the body, whose headings and lists are not topics nor changes. Without a 'Topics:' line, the text before the first topic is the pull request.
- A line starting with '# ' starts a topic; the rest of the line is its title.
- A line starting with '- ' lists a change of the current topic: 'Foo>>#bar', 'Foo class>>#bar', 'Foo' or 'Foo class' for a definition, or a file path. Write a path with spaces between backquotes. 'Foo>>bar' is read as 'Foo>>#bar'.
- After the reference, '<- Other>>#ref' says the code was moved or extracted from that change; the rest of the line is why this change was made.
- Any other line is part of the current topic's explanation.

I never fail: whatever I do not understand ends up in a text, or in the warnings of the review (see OCRTopicTreeBuilder).
"
Class {
	#name : 'OCRGuideParser',
	#superclass : 'Object',
	#category : 'ObscureCodeReviewer-Model',
	#package : 'ObscureCodeReviewer',
	#tag : 'Model'
}

{ #category : 'private' }
OCRGuideParser >> normalized: aReference [
	"'Foo>>bar' becomes 'Foo>>#bar'; backquotes are dropped."

	| reference |
	reference := (aReference copyWithout: $`) trimBoth.
	((reference includesSubstring: '>>') and: [ (reference includesSubstring: '>>#') not ]) ifTrue: [
		^ reference copyReplaceAll: '>>' with: '>>#' ].
	^ reference
]

{ #category : 'parsing' }
OCRGuideParser >> parse: aString [
	"Lines before a 'Topics:' line are the pull request as they are, its headings and lists included."

	| topics introLines lines end |
	topics := OrderedCollection new.
	introLines := OrderedCollection new.
	lines := aString lines collect: [ :each | each trimBoth ].
	end := lines indexOf: 'Topics:'.
	introLines addAll: (lines first: (end - 1 max: 0)).
	(lines allButFirst: end) do: [ :each | self readLine: each into: topics after: introLines ].
	^ OCRReviewGuide text: aString topics: topics pullRequest: (self pullRequestFrom: introLines)
]

{ #category : 'parsing' }
OCRGuideParser >> pullRequestFrom: someLines [
	"An optional first line 'Title: ...', then the body."

	| lines title |
	lines := someLines asOrderedCollection.
	[ lines isNotEmpty and: [ lines first isEmpty ] ] whileTrue: [ lines removeFirst ].
	title := ''.
	(lines isNotEmpty and: [ lines first beginsWith: 'Title:' ]) ifTrue: [ title := (lines removeFirst allButFirst: 6) trimBoth ].
	^ OCRPullRequest title: title body: (String cr join: lines) trimBoth
]

{ #category : 'parsing' }
OCRGuideParser >> readItem: aString into: aTopic [
	"A change: its reference, optionally '<-' and the reference it was moved from, then why."

	| words reference |
	words := aString substrings asOrderedCollection.
	words ifEmpty: [ ^ self ].
	reference := self takeReferenceFrom: words.
	aTopic addReference: reference.
	(words isNotEmpty and: [ words first = '<-' ]) ifTrue: [
		words removeFirst.
		words ifNotEmpty: [ aTopic origin: (self takeReferenceFrom: words) for: reference ] ].
	aTopic why: (self whyFrom: words) for: reference
]

{ #category : 'parsing' }
OCRGuideParser >> readLine: aLine into: someTopics after: someIntroLines [
	"someIntroLines collects the lines before the first topic."

	(aLine beginsWith: '# ') ifTrue: [
		someTopics add: (OCRTopic titled: (aLine allButFirst: 2) trimBoth).
		^ self ].
	someTopics ifEmpty: [
		someIntroLines add: aLine.
		^ self ].
	(aLine beginsWith: '- ') ifTrue: [ ^ self readItem: (aLine allButFirst: 2) into: someTopics last ].
	someTopics last addExplanationLine: aLine
]

{ #category : 'private' }
OCRGuideParser >> takeQuoted: aFirstWord from: someWords [
	"A reference between backquotes may have spaces: take words up to the closing backquote."

	| parts |
	parts := OrderedCollection with: aFirstWord.
	[ someWords isEmpty or: [ parts last size > 1 and: [ parts last endsWith: '`' ] ] ] whileFalse: [
		parts add: someWords removeFirst ].
	^ ' ' join: parts
]

{ #category : 'parsing' }
OCRGuideParser >> takeReferenceFrom: someWords [
	"Remove the words of one reference from the front of someWords and answer it as changes write it."

	| first |
	first := someWords removeFirst.
	(first beginsWith: '`') ifTrue: [ ^ self normalized: (self takeQuoted: first from: someWords) ].
	(someWords isNotEmpty and: [ someWords first = 'class' or: [ someWords first beginsWith: 'class>>' ] ]) ifTrue: [
		^ self normalized: (' ' join: {
			   first.
			   someWords removeFirst }) ].
	^ self normalized: first
]

{ #category : 'parsing' }
OCRGuideParser >> whyFrom: someWords [
	"The rest of the line, without a leading separator like '-' or ':'."

	(someWords isNotEmpty and: [ #( '-' '--' ':' ) includes: someWords first ]) ifTrue: [ someWords removeFirst ].
	^ ' ' join: someWords
]
