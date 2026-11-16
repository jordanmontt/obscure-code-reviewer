"
I am a node of the changes tree shown in the review window.

I have a name and children. When I represent a changed item, I also hold its OCRChange. A class node can hold a change too, when its class definition changed.
"
Class {
	#name : 'OCRTreeNode',
	#superclass : 'Object',
	#instVars : [
		'name',
		'children',
		'change'
	],
	#category : 'ObscureCodeReviewer-Model',
	#package : 'ObscureCodeReviewer',
	#tag : 'Model'
}

{ #category : 'instance creation' }
OCRTreeNode class >> forChange: aChange [

	^ (self named: aChange name)
		  change: aChange;
		  yourself
]

{ #category : 'instance creation' }
OCRTreeNode class >> named: aString [

	^ self new
		  name: aString;
		  yourself
]

{ #category : 'accessing' }
OCRTreeNode >> addChild: aNode [

	^ children add: aNode
]

{ #category : 'accessing' }
OCRTreeNode >> change [

	^ change
]

{ #category : 'accessing' }
OCRTreeNode >> change: aChange [

	change := aChange
]

{ #category : 'accessing' }
OCRTreeNode >> children [

	^ children
]

{ #category : 'testing' }
OCRTreeNode >> hasChange [

	^ change notNil
]

{ #category : 'initialization' }
OCRTreeNode >> initialize [

	super initialize.
	children := OrderedCollection new
]

{ #category : 'displaying' }
OCRTreeNode >> label [
	"The text shown in the tree, e.g. '+ myMethod' for an added method."

	self hasChange ifFalse: [ ^ name ].
	^ change kindMarker , ' ' , name
]

{ #category : 'accessing' }
OCRTreeNode >> name [

	^ name
]

{ #category : 'accessing' }
OCRTreeNode >> name: aString [

	name := aString
]

{ #category : 'printing' }
OCRTreeNode >> printOn: aStream [

	aStream nextPutAll: self label
]
