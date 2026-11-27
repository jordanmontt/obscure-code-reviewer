"
I test OCRReviewBase: how the base of a review is described, and its warning.
"
Class {
	#name : 'OCRReviewBaseTest',
	#superclass : 'TestCase',
	#category : 'ObscureCodeReviewer-Tests',
	#package : 'ObscureCodeReviewer-Tests'
}

{ #category : 'tests' }
OCRReviewBaseTest >> testABaseCanWarnThatItMayBeWrong [

	| reviewBase |
	reviewBase := OCRReviewBase
		              base: (OCRSplitBase fromBranchNamed: 'main')
		              commitId: 'd274ab5'
		              warning: 'main (d274ab5) is behind origin/main (ae02d54)'.

	self assert: reviewBase hasWarning.
	self assert: reviewBase warning equals: 'main (d274ab5) is behind origin/main (ae02d54)'
]

{ #category : 'tests' }
OCRReviewBaseTest >> testABaseHasNoWarningByDefault [

	self deny: (OCRReviewBase base: OCRLastCommitBase new commitId: 'abc1234') hasWarning
]

{ #category : 'tests' }
OCRReviewBaseTest >> testTheLabelIsTheCommitAndTheBase [

	self
		assert: (OCRReviewBase base: (OCRSplitBase fromBranchNamed: 'main') commitId: 'd274ab5') label
		equals: 'd274ab5 (split from main)'
]
