"
I am a tree node grouping the changed methods of a class whose definition did not change: a class, a class side ('Foo class'), or the extension methods of a class. I hold one of those changes, and browse its class while it is in the image. See OCRTreeNode.
"
Class {
	#name : 'OCRClassNode',
	#superclass : 'OCRContainerNode',
	#instVars : [
		'change'
	],
	#category : 'ObscureCodeReviewer-Model',
	#package : 'ObscureCodeReviewer',
	#tag : 'Model'
}

{ #category : 'instance creation' }
OCRClassNode class >> named: aString iconName: aSymbol change: aChange [

	^ (self named: aString iconName: aSymbol)
		  change: aChange;
		  yourself
]

{ #category : 'browsing' }
OCRClassNode >> browse [
	"Only valid when #canBrowse is true."

	^ change browseClass
]

{ #category : 'testing' }
OCRClassNode >> canBrowse [

	^ change isClassInImage
]

{ #category : 'accessing' }
OCRClassNode >> change: aChange [
	"One of the changes I group: it knows my class."

	change := aChange
]
