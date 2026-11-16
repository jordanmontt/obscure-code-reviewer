"
I am a page of a notebook whose tab shows a help text when the mouse is over it.

Spec's notebook pages have no help text, so I give my tab my own label presenter (see #newLabelPresenterFor:).

	(OCRNotebookPage title: 'Structure' provider: [ aPresenter ])
		help: 'Every change, by package and class';
		yourself
"
Class {
	#name : 'OCRNotebookPage',
	#superclass : 'SpNotebookPage',
	#instVars : [
		'help'
	],
	#category : 'ObscureCodeReviewer-UI',
	#package : 'ObscureCodeReviewer',
	#tag : 'UI'
}

{ #category : 'accessing' }
OCRNotebookPage >> help [
	"Shown when the mouse is over my tab."

	^ help
]

{ #category : 'accessing' }
OCRNotebookPage >> help: aString [

	help := aString
]

{ #category : 'initialization' }
OCRNotebookPage >> initialize [

	super initialize.
	help := ''
]

{ #category : 'private - factory' }
OCRNotebookPage >> newLabelPresenterFor: anOwnerPresenter [
	"Spec's extension point for custom tab labels."

	^ anOwnerPresenter instantiate: OCRNotebookPageLabelPresenter on: self
]
