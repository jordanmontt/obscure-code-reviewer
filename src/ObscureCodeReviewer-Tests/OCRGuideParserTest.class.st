"
I test OCRGuideParser: how a review guide in Markdown becomes topics.
"
Class {
	#name : 'OCRGuideParserTest',
	#superclass : 'TestCase',
	#category : 'ObscureCodeReviewer-Tests',
	#package : 'ObscureCodeReviewer-Tests'
}

{ #category : 'tests' }
OCRGuideParserTest >> testAChangeListedTwiceInATopicIsKeptOnce [

	| guide |
	guide := OCRReviewGuide fromText: '# Topic
- A>>#a
- A>>#a'.

	self assert: guide topics first references asArray equals: #( 'A>>#a' )
]

{ #category : 'tests' }
OCRGuideParserTest >> testEmptyTextHasNoTopics [

	self assert: OCRReviewGuide empty topics isEmpty
]

{ #category : 'tests' }
OCRGuideParserTest >> testHeadingsStartTopics [

	| guide |
	guide := OCRReviewGuide fromText: '# Parse faster
- A>>#a
# Clean up
- B'.

	self assert: (guide topics collect: [ :each | each title ]) asArray equals: #( 'Parse faster' 'Clean up' ).
	self assert: guide topics first references asArray equals: #( 'A>>#a' ).
	self assert: guide topics second references asArray equals: #( 'B' )
]

{ #category : 'tests' }
OCRGuideParserTest >> testOtherLinesAreTheExplanation [

	| guide |
	guide := OCRReviewGuide fromText: '# Parse faster
Why: avoid re-scanning.

- A>>#a
It is twice as fast.'.

	self assert: guide topics first explanation equals: 'Why: avoid re-scanning.' , String cr , String cr , 'It is twice as fast.'
]

{ #category : 'tests' }
OCRGuideParserTest >> testReferencesAreReadAsChangesWriteThem [

	| guide |
	guide := OCRReviewGuide fromText: '# Topic
- `A>>#a`
- A>>b
- A class>>c'.

	self assert: guide topics first references asArray equals: #( 'A>>#a' 'A>>#b' 'A class>>#c' )
]

{ #category : 'tests' }
OCRGuideParserTest >> testTextBeforeTheFirstTopicIsIgnored [

	| guide |
	guide := OCRReviewGuide fromText: 'Some introduction.
- A>>#a
# Topic
- B'.

	self assert: guide topics size equals: 1.
	self assert: guide topics first references asArray equals: #( 'B' )
]
