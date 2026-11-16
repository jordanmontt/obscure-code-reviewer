"
I choose the base a review is compared to when the user does not choose one. I never fail: when nothing better fits, I choose the last commit.

The main branch is the first local branch named 'main' or 'master'.
- On another branch: the split point with the main branch, so the review is the whole branch, like a pull request.
- On the main branch: the split point with its upstream (e.g. 'origin/main'), so the review is everything not pushed yet.
- On the main branch without an upstream (never pushed): the last commit.
- Without a main branch: the last commit, so the review is the uncommitted changes.

I only work on branch names, so I am tested without a repository. OCRIcebergReader gives me the names:

	OCRDefaultBaseRule new
		currentBranchName: 'main';
		localBranchNames: #( 'main' 'feature' );
		upstreamNames: (Dictionary with: 'main' -> 'origin/main');
		base
"
Class {
	#name : 'OCRDefaultBaseRule',
	#superclass : 'Object',
	#instVars : [
		'currentBranchName',
		'localBranchNames',
		'upstreamNames'
	],
	#category : 'ObscureCodeReviewer-Model',
	#package : 'ObscureCodeReviewer',
	#tag : 'Model'
}

{ #category : 'choosing' }
OCRDefaultBaseRule >> base [
	"Answer an OCRSplitBase or an OCRLastCommitBase. See my class comment."

	| mainBranchName |
	self hasMainBranch ifFalse: [ ^ OCRLastCommitBase new ].
	mainBranchName := self mainBranchName.
	currentBranchName = mainBranchName ifFalse: [ ^ OCRSplitBase fromBranchNamed: mainBranchName ].
	(upstreamNames includesKey: mainBranchName) ifFalse: [ ^ OCRLastCommitBase new ].
	^ OCRSplitBase fromBranchNamed: (upstreamNames at: mainBranchName)
]

{ #category : 'accessing' }
OCRDefaultBaseRule >> currentBranchName: aString [

	currentBranchName := aString
]

{ #category : 'private' }
OCRDefaultBaseRule >> hasMainBranch [

	^ self mainBranchCandidates anySatisfy: [ :each | localBranchNames includes: each ]
]

{ #category : 'accessing' }
OCRDefaultBaseRule >> localBranchNames: someStrings [

	localBranchNames := someStrings
]

{ #category : 'private' }
OCRDefaultBaseRule >> mainBranchCandidates [
	"In order of preference."

	^ #( 'main' 'master' )
]

{ #category : 'private' }
OCRDefaultBaseRule >> mainBranchName [
	"Only valid when #hasMainBranch is true."

	^ self mainBranchCandidates detect: [ :each | localBranchNames includes: each ]
]

{ #category : 'accessing' }
OCRDefaultBaseRule >> upstreamNames: aDictionary [
	"Local branch name -> its upstream name, e.g. 'main' -> 'origin/main'. Branches without an upstream are not keys."

	upstreamNames := aDictionary
]
