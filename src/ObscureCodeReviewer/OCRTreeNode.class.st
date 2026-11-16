"
I am a node of the changes tree shown in the review window. I have a name, an icon name and children.

My subclasses are OCRContainerNode (a section, a package, or a class whose definition did not change) and OCRChangeNode (a changed method or class definition).

OCRStructuralTreeBuilder creates them.
"
Class {
	#name : 'OCRTreeNode',
	#superclass : 'Object',
	#instVars : [
		'name',
		'children',
		'iconName'
	],
	#category : 'ObscureCodeReviewer-Model',
	#package : 'ObscureCodeReviewer',
	#tag : 'Model'
}

{ #category : 'instance creation' }
OCRTreeNode class >> named: aString [

	^ self new
		  name: aString;
		  yourself
]

{ #category : 'instance creation' }
OCRTreeNode class >> named: aString iconName: aSymbol [

	^ (self named: aString)
		  iconName: aSymbol;
		  yourself
]

{ #category : 'adding' }
OCRTreeNode >> addChild: aNode [

	children add: aNode
]

{ #category : 'accessing' }
OCRTreeNode >> changesBelow [
	"The changes of me and of all my children."

	| all |
	all := OrderedCollection new.
	self withAllChildrenDo: [ :each | each hasChange ifTrue: [ all add: each change ] ].
	^ all
]

{ #category : 'accessing' }
OCRTreeNode >> children [

	^ children
]

{ #category : 'testing' }
OCRTreeNode >> hasChange [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
OCRTreeNode >> iconName [
	"The name of the icon shown in the tree, e.g. #class."

	^ iconName
]

{ #category : 'accessing' }
OCRTreeNode >> iconName: aSymbol [

	iconName := aSymbol
]

{ #category : 'initialization' }
OCRTreeNode >> initialize [

	super initialize.
	children := OrderedCollection new
]

{ #category : 'testing' }
OCRTreeNode >> isCommentable [
	"Changes and topics can be commented; sections, packages and unchanged classes cannot."

	^ self subclassResponsibility
]

{ #category : 'displaying' }
OCRTreeNode >> label [
	"The text shown in the tree."

	^ name
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

{ #category : 'displaying' }
OCRTreeNode >> showIn: aReviewPresenter [
	"Ask aReviewPresenter to show what I stand for."

	^ self subclassResponsibility
]

{ #category : 'enumerating' }
OCRTreeNode >> withAllChildrenDo: aBlock [
	"Evaluate aBlock with me and then with all my children, in tree order."

	aBlock value: self.
	children do: [ :each | each withAllChildrenDo: aBlock ]
]
