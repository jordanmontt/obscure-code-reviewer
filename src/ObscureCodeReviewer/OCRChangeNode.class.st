"
I am a tree node for a changed method or class definition, and I hold its OCRChange. A class node can have children too: its changed methods. See OCRTreeNode.
"
Class {
	#name : 'OCRChangeNode',
	#superclass : 'OCRTreeNode',
	#instVars : [
		'change'
	],
	#category : 'ObscureCodeReviewer-Model',
	#package : 'ObscureCodeReviewer',
	#tag : 'Model'
}

{ #category : 'instance creation' }
OCRChangeNode class >> named: aString iconName: aSymbol change: aChange [

	^ (self named: aString iconName: aSymbol)
		  change: aChange;
		  yourself
]

{ #category : 'accessing' }
OCRChangeNode >> change [

	^ change
]

{ #category : 'accessing' }
OCRChangeNode >> change: aChange [

	change := aChange
]

{ #category : 'testing' }
OCRChangeNode >> hasChange [

	^ true
]

{ #category : 'displaying' }
OCRChangeNode >> label [
	"The text shown in the tree, e.g. '+ myMethod' for an added method."

	^ change kindMarker , ' ' , name
]
