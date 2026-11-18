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

{ #category : 'browsing' }
OCRChangeNode >> browse [
	"Only valid when #canBrowse is true."

	^ change browse
]

{ #category : 'testing' }
OCRChangeNode >> canBrowse [

	^ change isInImage
]

{ #category : 'accessing' }
OCRChangeNode >> change [

	^ change
]

{ #category : 'accessing' }
OCRChangeNode >> change: aChange [

	change := aChange
]

{ #category : 'accessing' }
OCRChangeNode >> commentable [
	"What a comment on me is attached to."

	^ change
]

{ #category : 'testing' }
OCRChangeNode >> hasChange [

	^ true
]

{ #category : 'testing' }
OCRChangeNode >> isCommentable [

	^ true
]

{ #category : 'displaying' }
OCRChangeNode >> label [
	"The text shown in the tree, e.g. '+ myMethod' for an added method."

	^ ' ' join: {
		  change kindMarker.
		  name }
]

{ #category : 'displaying' }
OCRChangeNode >> showIn: aReviewPresenter [

	aReviewPresenter showChange: change
]
