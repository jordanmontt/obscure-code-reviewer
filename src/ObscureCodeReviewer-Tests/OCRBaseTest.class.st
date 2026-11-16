"
I test the bases a review can be compared to: OCRLastCommitBase and OCRSplitBase.
"
Class {
	#name : 'OCRBaseTest',
	#superclass : 'TestCase',
	#category : 'ObscureCodeReviewer-Tests',
	#package : 'ObscureCodeReviewer-Tests'
}

{ #category : 'tests' }
OCRBaseTest >> testLastCommitBaseDescription [

	self assert: OCRLastCommitBase new description equals: 'last commit'
]

{ #category : 'tests' }
OCRBaseTest >> testReviewKeepsItsBase [

	| base review |
	base := OCRSplitBase fromBranchNamed: 'main'.
	review := OCRReview
		          repositoryName: 'my-project'
		          base: base
		          baseLabel: 'abc1234 (split from main)'
		          changes: #(  ).

	self assert: review base equals: base
]

{ #category : 'tests' }
OCRBaseTest >> testSplitBaseDescriptionNamesTheBranch [

	self assert: (OCRSplitBase fromBranchNamed: 'main') description equals: 'split from main'.
	self assert: (OCRSplitBase fromBranchNamed: 'origin/main') description equals: 'split from origin/main'
]
