"
I am a review guide: the pull request draft and the topics an agent wrote to explain its changes, parsed from Markdown by OCRGuideParser.

	Title: Parse tokens lazily
	The parser now reads one token at a time.

	Topics:

	# Optimize parsing
	Why: avoid re-scanning the stream for every token.
	- OCRParser>>#nextToken
	- OCRToken

I am not stored anywhere: the agent gives me to the review window when it opens it, and the window keeps me as long as it is open:

	(OCRReviewPresenter
		onRepositoryNamed: 'my-project'
		guide: (OCRReviewGuide fromText: '...')) open

A review opened without a guide has an empty guide: no topics, and the review works the same.
"
Class {
	#name : 'OCRReviewGuide',
	#superclass : 'Object',
	#instVars : [
		'text',
		'topics',
		'pullRequest'
	],
	#category : 'ObscureCodeReviewer-Model',
	#package : 'ObscureCodeReviewer',
	#tag : 'Model'
}

{ #category : 'instance creation' }
OCRReviewGuide class >> empty [

	^ self fromText: ''
]

{ #category : 'instance creation' }
OCRReviewGuide class >> fromText: aString [

	^ OCRGuideParser new parse: aString
]

{ #category : 'instance creation' }
OCRReviewGuide class >> text: aString topics: someTopics pullRequest: aPullRequest [
	"Use #fromText: instead; this is for OCRGuideParser."

	^ self new
		  setText: aString topics: someTopics pullRequest: aPullRequest;
		  yourself
]

{ #category : 'accessing' }
OCRReviewGuide >> firstTopicListing: aReference ifNone: aBlock [
	"A change belongs to the first topic that lists it."

	^ topics detect: [ :each | each lists: aReference ] ifNone: aBlock
]

{ #category : 'accessing' }
OCRReviewGuide >> includesTopicReferenced: aReference [

	^ topics anySatisfy: [ :each | each reference = aReference ]
]

{ #category : 'accessing' }
OCRReviewGuide >> originOf: aReference ifNone: aBlock [
	"The reference of the change the code of aReference was moved from."

	^ (self firstTopicListing: aReference ifNone: [ ^ aBlock value ]) originOf: aReference ifNone: aBlock
]

{ #category : 'accessing' }
OCRReviewGuide >> pullRequest [
	"The agent's draft of the pull request description: the text before the 'Topics:' line, or before the first topic."

	^ pullRequest
]

{ #category : 'initialization' }
OCRReviewGuide >> setText: aString topics: someTopics pullRequest: aPullRequest [

	text := aString.
	topics := someTopics.
	pullRequest := aPullRequest
]

{ #category : 'accessing' }
OCRReviewGuide >> text [
	"The Markdown I was parsed from."

	^ text
]

{ #category : 'accessing' }
OCRReviewGuide >> topics [

	^ topics
]

{ #category : 'accessing' }
OCRReviewGuide >> whyOf: aReference [
	"What the agent wrote after the reference of a change; empty when nothing."

	^ (self firstTopicListing: aReference ifNone: [ ^ '' ]) whyOf: aReference
]
