"
I test OCRDefaultBaseRule: which base a review uses by default, for each kind of repository.
"
Class {
	#name : 'OCRDefaultBaseRuleTest',
	#superclass : 'TestCase',
	#category : 'ObscureCodeReviewer-Tests',
	#package : 'ObscureCodeReviewer-Tests'
}

{ #category : 'helpers' }
OCRDefaultBaseRuleTest >> baseOnBranch: aBranchName localBranches: someNames upstreams: someAssociations [

	^ OCRDefaultBaseRule new
		  currentBranchName: aBranchName;
		  localBranchNames: someNames;
		  upstreamNames: someAssociations asDictionary;
		  base
]

{ #category : 'tests' }
OCRDefaultBaseRuleTest >> testFeatureBranchSplitsFromMain [

	| base |
	base := self baseOnBranch: 'feature' localBranches: #( 'main' 'feature' ) upstreams: { ('main' -> 'origin/main') }.

	self assert: base description equals: 'split from main'
]

{ #category : 'tests' }
OCRDefaultBaseRuleTest >> testFeatureBranchSplitsFromMasterWhenThereIsNoMain [

	| base |
	base := self baseOnBranch: 'feature' localBranches: #( 'master' 'feature' ) upstreams: #(  ).

	self assert: base description equals: 'split from master'
]

{ #category : 'tests' }
OCRDefaultBaseRuleTest >> testMainIsPreferredOverMaster [

	| base |
	base := self baseOnBranch: 'feature' localBranches: #( 'master' 'main' 'feature' ) upstreams: #(  ).

	self assert: base description equals: 'split from main'
]

{ #category : 'tests' }
OCRDefaultBaseRuleTest >> testOnMainNeverPushedTheBaseIsTheLastCommit [

	| base |
	base := self baseOnBranch: 'main' localBranches: #( 'main' ) upstreams: #(  ).

	self assert: base description equals: 'last commit'
]

{ #category : 'tests' }
OCRDefaultBaseRuleTest >> testOnMainTheBaseIsWhatIsNotPushed [

	| base |
	base := self baseOnBranch: 'main' localBranches: #( 'main' ) upstreams: { ('main' -> 'origin/main') }.

	self assert: base description equals: 'split from origin/main'
]

{ #category : 'tests' }
OCRDefaultBaseRuleTest >> testOnMasterTheBaseIsItsUpstream [

	| base |
	base := self baseOnBranch: 'master' localBranches: #( 'master' ) upstreams: { ('master' -> 'upstream/master') }.

	self assert: base description equals: 'split from upstream/master'
]

{ #category : 'tests' }
OCRDefaultBaseRuleTest >> testWithoutMainOrMasterTheBaseIsTheLastCommit [

	| base |
	base := self baseOnBranch: 'dev' localBranches: #( 'dev' 'Pharo13' ) upstreams: { ('dev' -> 'origin/dev') }.

	self assert: base description equals: 'last commit'
]
