"
I test where guides are kept: OCRReviewGuide class>>#forRepositoryNamed:put:. I use a repository name no real repository has, and remove its guide after each test.
"
Class {
	#name : 'OCRReviewGuideStoreTest',
	#superclass : 'TestCase',
	#category : 'ObscureCodeReviewer-Tests',
	#package : 'ObscureCodeReviewer-Tests'
}

{ #category : 'helpers' }
OCRReviewGuideStoreTest >> repositoryName [

	^ 'ocr-guide-store-test'
]

{ #category : 'running' }
OCRReviewGuideStoreTest >> tearDown [

	OCRReviewGuide removeForRepositoryNamed: self repositoryName.
	super tearDown
]

{ #category : 'tests' }
OCRReviewGuideStoreTest >> testStoredGuideIsFound [

	OCRReviewGuide forRepositoryNamed: self repositoryName put: '# Parse faster'.

	self assert: (OCRReviewGuide forRepositoryNamed: self repositoryName) topics first title equals: 'Parse faster'
]

{ #category : 'tests' }
OCRReviewGuideStoreTest >> testStoringAgainReplacesTheGuide [

	OCRReviewGuide forRepositoryNamed: self repositoryName put: '# Parse faster'.
	OCRReviewGuide forRepositoryNamed: self repositoryName put: '# Clean up'.

	self assert: (OCRReviewGuide forRepositoryNamed: self repositoryName) text equals: '# Clean up'
]

{ #category : 'tests' }
OCRReviewGuideStoreTest >> testWithoutStoredGuideTheGuideIsEmpty [

	self assert: (OCRReviewGuide forRepositoryNamed: self repositoryName) topics isEmpty
]
