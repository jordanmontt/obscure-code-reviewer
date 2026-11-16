"
I test OCRBaseChoices: which bases the picker offers, and in which order.
"
Class {
	#name : 'OCRBaseChoicesTest',
	#superclass : 'TestCase',
	#category : 'ObscureCodeReviewer-Tests',
	#package : 'ObscureCodeReviewer-Tests'
}

{ #category : 'helpers' }
OCRBaseChoicesTest >> descriptionsWithDefault: aBase branchNames: someNames [

	^ (OCRBaseChoices default: aBase branchNames: someNames) bases collect: [ :each | each description ] as: Array
]

{ #category : 'tests' }
OCRBaseChoicesTest >> testDefaultComesFirstThenLastCommitThenEachBranch [

	| descriptions |
	descriptions := self descriptionsWithDefault: (OCRSplitBase fromBranchNamed: 'main') branchNames: #( 'main' 'dev' 'origin/main' ).

	self assert: descriptions equals: #( 'split from main' 'last commit' 'split from dev' 'split from origin/main' )
]

{ #category : 'tests' }
OCRBaseChoicesTest >> testLastCommitIsOfferedOnceWhenItIsTheDefault [

	| descriptions |
	descriptions := self descriptionsWithDefault: OCRLastCommitBase new branchNames: #( 'dev' ).

	self assert: descriptions equals: #( 'last commit' 'split from dev' )
]

{ #category : 'tests' }
OCRBaseChoicesTest >> testOnlyTheDefaultIsLabeledAsDefault [

	| choices |
	choices := OCRBaseChoices default: (OCRSplitBase fromBranchNamed: 'main') branchNames: #( 'dev' ).

	self
		assert: (choices bases collect: [ :each | choices labelFor: each ] as: Array)
		equals: #( 'split from main (default)' 'last commit' 'split from dev' )
]

{ #category : 'tests' }
OCRBaseChoicesTest >> testRemoteHeadIsNotOffered [

	| descriptions |
	descriptions := self descriptionsWithDefault: OCRLastCommitBase new branchNames: #( 'origin/HEAD' 'origin/main' ).

	self assert: descriptions equals: #( 'last commit' 'split from origin/main' )
]

{ #category : 'tests' }
OCRBaseChoicesTest >> testWithoutBranchesOnlyTheDefaultAndLastCommitAreOffered [

	| descriptions |
	descriptions := self descriptionsWithDefault: (OCRSplitBase fromBranchNamed: 'origin/main') branchNames: #(  ).

	self assert: descriptions equals: #( 'split from origin/main' 'last commit' )
]
