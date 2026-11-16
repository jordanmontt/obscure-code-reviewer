"
I am a code review: the changes between a base commit and the image, for one repository.

I know how to organize my changes for the review window. See #structuralTree.

	OCRReview
		repositoryName: 'my-project'
		baseLabel: 'abc1234 (last commit)'
		changes: someChanges
"
Class {
	#name : 'OCRReview',
	#superclass : 'Object',
	#instVars : [
		'repositoryName',
		'baseLabel',
		'changes'
	],
	#category : 'ObscureCodeReviewer-Model',
	#package : 'ObscureCodeReviewer',
	#tag : 'Model'
}

{ #category : 'instance creation' }
OCRReview class >> repositoryName: aRepositoryName baseLabel: aBaseLabel changes: someChanges [

	^ self new setRepositoryName: aRepositoryName baseLabel: aBaseLabel changes: someChanges
]

{ #category : 'accessing' }
OCRReview >> baseLabel [
	"Describes the base commit of the review, e.g. 'abc1234 (last commit)'."

	^ baseLabel
]

{ #category : 'accessing' }
OCRReview >> changes [

	^ changes
]

{ #category : 'structural tree' }
OCRReview >> groupNodeNamed: aGroupName in: someChanges [
	"A group is a class, a class side, or the extension methods of a class."

	| groupChanges node methodChanges |
	groupChanges := someChanges select: [ :each | each groupName = aGroupName ].
	node := OCRTreeNode named: aGroupName.
	groupChanges detect: [ :each | each isClassChange ] ifFound: [ :classChange | node change: classChange ].
	methodChanges := groupChanges select: [ :each | each isMethodChange ].
	(methodChanges asSortedCollection: [ :a :b | a selector <= b selector ]) do: [ :each |
		node addChild: (OCRTreeNode forChange: each) ].
	^ node
]

{ #category : 'testing' }
OCRReview >> isEmpty [

	^ changes isEmpty
]

{ #category : 'structural tree' }
OCRReview >> packageNodeNamed: aPackageName [

	| packageChanges node |
	packageChanges := changes select: [ :each | each packageName = aPackageName ].
	node := OCRTreeNode named: aPackageName.
	(self sortedNamesOf: packageChanges by: [ :each | each groupName ]) do: [ :groupName |
		node addChild: (self groupNodeNamed: groupName in: packageChanges) ].
	^ node
]

{ #category : 'accessing' }
OCRReview >> repositoryName [

	^ repositoryName
]

{ #category : 'initialization' }
OCRReview >> setRepositoryName: aRepositoryName baseLabel: aBaseLabel changes: someChanges [

	repositoryName := aRepositoryName.
	baseLabel := aBaseLabel.
	changes := someChanges asOrderedCollection
]

{ #category : 'structural tree' }
OCRReview >> sortedNamesOf: someChanges by: aBlock [

	^ (someChanges collect: aBlock as: Set) asSortedCollection asArray
]

{ #category : 'structural tree' }
OCRReview >> structuralTree [
	"Answer my changes as tree nodes: package > class > method, sorted by name."

	^ (self sortedNamesOf: changes by: [ :each | each packageName ]) collect: [ :packageName | self packageNodeNamed: packageName ]
]
