"
I am the tab of an OCRNotebookPage: Spec's tab label, showing the page's help text when the mouse is over it.
"
Class {
	#name : 'OCRNotebookPageLabelPresenter',
	#superclass : 'SpNotebookPageLabelPresenter',
	#category : 'ObscureCodeReviewer-UI',
	#package : 'ObscureCodeReviewer',
	#tag : 'UI'
}

{ #category : 'initialization' }
OCRNotebookPageLabelPresenter >> initializePresenters [

	super initializePresenters.
	labelPresenter help: self model help
]
