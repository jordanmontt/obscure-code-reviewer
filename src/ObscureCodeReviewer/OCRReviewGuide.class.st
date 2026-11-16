"
I am a review guide: the topics an agent wrote to explain its changes, parsed from Markdown by OCRGuideParser.

	# Optimize parsing
	Why: avoid re-scanning the stream for every token.
	- OCRParser>>#nextToken
	- OCRToken

The class side keeps the guide text of each repository while the image runs, so the agent can store it through the MCP and the review window finds it:

	OCRReviewGuide forRepositoryNamed: 'my-project' put: '# Optimize parsing
Why: avoid re-scanning the stream for every token.
- OCRParser>>#nextToken
- OCRToken'

A repository without a stored guide has an empty guide: no topics, and the review works the same.
"
Class {
	#name : 'OCRReviewGuide',
	#superclass : 'Object',
	#instVars : [
		'text',
		'topics'
	],
	#classInstVars : [
		'storedTexts'
	],
	#category : 'ObscureCodeReviewer-Model',
	#package : 'ObscureCodeReviewer',
	#tag : 'Model'
}

{ #category : 'instance creation' }
OCRReviewGuide class >> empty [

	^ self fromText: ''
]

{ #category : 'store' }
OCRReviewGuide class >> forRepositoryNamed: aRepositoryName [
	"The stored guide of the repository, or an empty guide."

	^ self fromText: (storedTexts at: aRepositoryName ifAbsent: [ '' ])
]

{ #category : 'store' }
OCRReviewGuide class >> forRepositoryNamed: aRepositoryName put: aString [
	"Keep aString as the guide of the repository, replacing the previous one."

	storedTexts at: aRepositoryName put: aString
]

{ #category : 'instance creation' }
OCRReviewGuide class >> fromText: aString [

	^ OCRGuideParser new parse: aString
]

{ #category : 'class initialization' }
OCRReviewGuide class >> initialize [

	storedTexts := Dictionary new
]

{ #category : 'store' }
OCRReviewGuide class >> removeForRepositoryNamed: aRepositoryName [

	storedTexts removeKey: aRepositoryName ifAbsent: [ ^ self ]
]

{ #category : 'instance creation' }
OCRReviewGuide class >> text: aString topics: someTopics [
	"Use #fromText: instead; this is for OCRGuideParser."

	^ self new
		  setText: aString topics: someTopics;
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

{ #category : 'initialization' }
OCRReviewGuide >> setText: aString topics: someTopics [

	text := aString.
	topics := someTopics
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
