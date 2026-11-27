"
I am a tree node that only groups other nodes: a section, a package, or a class whose definition did not change. See OCRTreeNode.

Empty, I also stand for no selection (see OCRReviewTabsPresenter>>#selectedNode): nothing to show, comment, browse or mark.
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

{ #category : 'testing' }
OCRContainerNode >> isCommentable [

	^ false
]

{ #category : 'displaying' }
OCRContainerNode >> showIn: aReviewPresenter [

	aReviewPresenter showNothing
]
