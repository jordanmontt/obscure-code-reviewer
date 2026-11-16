"
I am the list of bases the picker offers for one repository: the default base first, then the last commit, then the split point from each branch. Each base appears once.

Remote 'HEAD' branches (like 'origin/HEAD') only point to another remote branch, so they are never offered.

I only work on branch names, so I am tested without a repository. OCRIcebergReader gives me the names:

	(OCRBaseChoices
		default: (OCRSplitBase fromBranchNamed: 'main')
		branchNames: #( 'main' 'origin/main' 'origin/HEAD' )) bases
"
Class {
	#name : 'OCRBaseChoices',
	#superclass : 'Object',
	#instVars : [
		'defaultBase',
		'branchNames'
	],
	#category : 'ObscureCodeReviewer-Model',
	#package : 'ObscureCodeReviewer',
	#tag : 'Model'
}

{ #category : 'instance creation' }
OCRBaseChoices class >> default: aBase branchNames: someNames [
	"someNames are the branches the current branch can be compared to: local ones like 'main' and remote ones like 'origin/main'."

	^ self new
		  setDefault: aBase branchNames: someNames;
		  yourself
]

{ #category : 'accessing' }
OCRBaseChoices >> bases [
	"The default base first, then the last commit, then the split point from each branch. A base already in the list is not repeated."

	^ self candidates asOrderedCollection removeDuplicates
]

{ #category : 'private' }
OCRBaseChoices >> candidates [

	^ {
		  defaultBase.
		  OCRLastCommitBase new } , (self offeredBranchNames collect: [ :each | OCRSplitBase fromBranchNamed: each ])
]

{ #category : 'accessing' }
OCRBaseChoices >> isDefault: aBase [

	^ aBase = defaultBase
]

{ #category : 'accessing' }
OCRBaseChoices >> labelFor: aBase [
	"How the picker shows aBase: its description, marked when it is the default."

	(self isDefault: aBase) ifTrue: [ ^ aBase description , ' (default)' ].
	^ aBase description
]

{ #category : 'private' }
OCRBaseChoices >> offeredBranchNames [

	^ branchNames reject: [ :each | each endsWith: '/HEAD' ]
]

{ #category : 'initialization' }
OCRBaseChoices >> setDefault: aBase branchNames: someNames [

	defaultBase := aBase.
	branchNames := someNames
]
