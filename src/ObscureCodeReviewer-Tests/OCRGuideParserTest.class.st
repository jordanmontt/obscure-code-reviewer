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
OCRGuideParserTest >> testArrowSaysWhereTheCodeWasMovedFrom [

	| guide |
	guide := OCRReviewGuide fromText: '# Topic
- A>>#new <- B>>#old extracted to share it'.

	self assert: (guide originOf: 'A>>#new' ifNone: [ 'none' ]) equals: 'B>>#old'.
	self assert: (guide whyOf: 'A>>#new') equals: 'extracted to share it'.
	self assert: (guide originOf: 'B>>#old' ifNone: [ 'none' ]) equals: 'none'
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

	self assert: (guide topics collect: [ :each | each title ] as: Array) equals: #( 'Parse faster' 'Clean up' ).
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

	self assert: guide topics first explanation equals: (String cr join: #( 'Why: avoid re-scanning.' '' 'It is twice as fast.' ))
]

{ #category : 'tests' }
OCRGuideParserTest >> testPathsWithSpacesGoBetweenBackquotes [

	| guide |
	guide := OCRReviewGuide fromText: '# Docs
- `docs/User guide.md` explains topics
- README.md'.

	self assert: guide topics first references asArray equals: #( 'docs/User guide.md' 'README.md' ).
	self assert: (guide whyOf: 'docs/User guide.md') equals: 'explains topics'
]

{ #category : 'tests' }
OCRGuideParserTest >> testPullRequestWithoutTitleLineHasOnlyABody [

	| guide |
	guide := OCRReviewGuide fromText: 'Just a summary.
# Topic'.

	self assert: guide pullRequest equals: (OCRPullRequest title: '' body: 'Just a summary.')
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
OCRGuideParserTest >> testTextBeforeTheFirstTopicIsThePullRequest [

	| guide |
	guide := OCRReviewGuide fromText: '
Title: Add topics
The agent groups its changes.
- not a change here
# Topic
- B'.

	self assert: guide pullRequest title equals: 'Add topics'.
	self assert: guide pullRequest body equals: (String cr join: #( 'The agent groups its changes.' '- not a change here' )).
	self assert: guide topics first references asArray equals: #( 'B' )
]

{ #category : 'tests' }
OCRGuideParserTest >> testTheRestOfAChangeLineIsWhy [

	| guide |
	guide := OCRReviewGuide fromText: '# Topic
- A>>#a keeps the order
- A class>>#b - answers a copy
- A'.

	self assert: guide topics first references asArray equals: #( 'A>>#a' 'A class>>#b' 'A' ).
	self assert: (guide whyOf: 'A>>#a') equals: 'keeps the order'.
	self assert: (guide whyOf: 'A class>>#b') equals: 'answers a copy'.
	self assert: (guide whyOf: 'A') equals: ''
]
