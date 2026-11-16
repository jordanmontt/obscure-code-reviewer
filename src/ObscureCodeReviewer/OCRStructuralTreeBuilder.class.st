"
I organize the changes of a review as a tree, close to what Iceberg shows:

	section (Code, Tests, Baseline) > package > class > method

- A package goes to Tests when its name contains '-Test', and to Baseline when it starts with 'BaselineOf'.
- Class-side methods are under their own 'MyClass class' node, extension methods under 'MyClass (extension)'.
- A changed class definition is the class node itself.
- Everything is sorted by name. Empty sections are left out.

	OCRStructuralTreeBuilder new treeFor: someChanges
"
Class {
	#name : 'OCRStructuralTreeBuilder',
	#superclass : 'Object',
	#category : 'ObscureCodeReviewer-Model',
	#package : 'ObscureCodeReviewer',
	#tag : 'Model'
}

{ #category : 'building' }
OCRStructuralTreeBuilder >> groupNodeNamed: aGroupName in: someChanges [
	"A group is a class, a class side, or the extension methods of a class."

	| groupChanges node methodChanges |
	groupChanges := someChanges select: [ :each | each groupName = aGroupName ].
	node := self newGroupNodeNamed: aGroupName for: groupChanges.
	methodChanges := groupChanges select: [ :each | each isMethodChange ].
	(methodChanges asSortedCollection: [ :a :b | a selector <= b selector ]) do: [ :each | node addChild: (self methodNodeFor: each) ].
	^ node
]

{ #category : 'icons' }
OCRStructuralTreeBuilder >> iconNameOfGroup: someChanges [

	someChanges first isExtension ifTrue: [ ^ #group ].
	^ #class
]

{ #category : 'icons' }
OCRStructuralTreeBuilder >> iconNameOfSection: aSectionName [

	aSectionName = 'Tests' ifTrue: [ ^ #testGreen ].
	aSectionName = 'Baseline' ifTrue: [ ^ #config ].
	^ #smallSystemBrowser
]

{ #category : 'building' }
OCRStructuralTreeBuilder >> methodNodeFor: aChange [

	^ OCRChangeNode named: aChange name iconName: #page change: aChange
]

{ #category : 'building' }
OCRStructuralTreeBuilder >> newGroupNodeNamed: aGroupName for: groupChanges [
	"When the class definition changed, the group node is that change."

	| iconName |
	iconName := self iconNameOfGroup: groupChanges.
	^ groupChanges
		  detect: [ :each | each isClassChange ]
		  ifFound: [ :classChange | OCRChangeNode named: aGroupName iconName: iconName change: classChange ]
		  ifNone: [ OCRContainerNode named: aGroupName iconName: iconName ]
]

{ #category : 'building' }
OCRStructuralTreeBuilder >> packageNodeNamed: aPackageName in: someChanges [

	| packageChanges node |
	packageChanges := someChanges select: [ :each | each packageName = aPackageName ].
	node := OCRContainerNode named: aPackageName iconName: #package.
	(self sortedNamesOf: packageChanges by: [ :each | each groupName ]) do: [ :groupName |
		node addChild: (self groupNodeNamed: groupName in: packageChanges) ].
	^ node
]

{ #category : 'sections' }
OCRStructuralTreeBuilder >> sectionNameOf: aChange [

	(aChange packageName beginsWith: 'BaselineOf') ifTrue: [ ^ 'Baseline' ].
	(aChange packageName includesSubstring: '-Test') ifTrue: [ ^ 'Tests' ].
	^ 'Code'
]

{ #category : 'sections' }
OCRStructuralTreeBuilder >> sectionNames [
	"In the order they are shown."

	^ #( 'Code' 'Tests' 'Baseline' )
]

{ #category : 'building' }
OCRStructuralTreeBuilder >> sectionNodeNamed: aSectionName in: someChanges [

	| sectionChanges node |
	sectionChanges := someChanges select: [ :each | (self sectionNameOf: each) = aSectionName ].
	node := OCRContainerNode named: aSectionName iconName: (self iconNameOfSection: aSectionName).
	(self sortedNamesOf: sectionChanges by: [ :each | each packageName ]) do: [ :packageName |
		node addChild: (self packageNodeNamed: packageName in: sectionChanges) ].
	^ node
]

{ #category : 'private' }
OCRStructuralTreeBuilder >> sortedNamesOf: someChanges by: aBlock [

	^ (someChanges collect: aBlock as: Set) asSortedCollection asArray
]

{ #category : 'building' }
OCRStructuralTreeBuilder >> treeFor: someChanges [
	"Answer one node per non-empty section."

	^ (self sectionNames collect: [ :each | self sectionNodeNamed: each in: someChanges ]) reject: [ :each | each children isEmpty ]
]
