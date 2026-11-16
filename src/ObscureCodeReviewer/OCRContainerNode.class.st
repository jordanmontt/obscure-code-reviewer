"
I am a tree node that only groups other nodes: a section, a package, or a class whose definition did not change. See OCRTreeNode.
"
Class {
	#name : 'OCRContainerNode',
	#superclass : 'OCRTreeNode',
	#category : 'ObscureCodeReviewer-Model',
	#package : 'ObscureCodeReviewer',
	#tag : 'Model'
}

{ #category : 'testing' }
OCRContainerNode >> hasChange [

	^ false
]
