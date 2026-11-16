"
I am the dialog that starts a review: the user picks a repository and what to compare it to, then clicks Open review.

I list the repositories with a local checkout and loaded packages. The base list starts on the default base (see OCRDefaultBaseRule).

	OCRPickerPresenter new openDialog

I am also in the world menu: Browse > Obscure Code Reviewer.
"
Class {
	#name : 'OCRPickerPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'repositoryLabel',
		'repositoryList',
		'baseLabel',
		'baseList'
	],
	#category : 'ObscureCodeReviewer-UI',
	#package : 'ObscureCodeReviewer',
	#tag : 'UI'
}

{ #category : 'world menu' }
OCRPickerPresenter class >> menuCommandOn: aBuilder [

	<worldMenu>
	(aBuilder item: #'Obscure Code Reviewer')
		parent: #InputOutput;
		action: [ self new openDialog ];
		order: 1.5;
		help: 'Review the changes of a repository: a diff organized by package and class, with comments you can copy for the agent.';
		iconName: #diff
]

{ #category : 'initialization' }
OCRPickerPresenter >> connectPresenters [

	repositoryList whenSelectionChangedDo: [ self showBases ].
	repositoryList items ifNotEmpty: [ repositoryList selectIndex: 1 ]
]

{ #category : 'layout' }
OCRPickerPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  spacing: 5;
		  add: repositoryLabel expand: false;
		  add: repositoryList;
		  add: baseLabel expand: false;
		  add: baseList expand: false;
		  yourself
]

{ #category : 'initialization' }
OCRPickerPresenter >> initializeDialogWindow: aDialogWindowPresenter [

	aDialogWindowPresenter
		addButton: 'Cancel' do: [ :dialog | dialog close ];
		addDefaultButton: 'Open review' do: [ :dialog | self openReviewFrom: dialog ]
]

{ #category : 'initialization' }
OCRPickerPresenter >> initializePresenters [

	repositoryLabel := self newLabel label: 'Repository'.
	repositoryList := self newList.
	repositoryList items: OCRIcebergReader reviewableRepositoryNames.
	baseLabel := self newLabel label: 'Compare with'.
	baseList := self newDropList
]

{ #category : 'initialization' }
OCRPickerPresenter >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		title: 'Obscure Code Reviewer';
		initialExtent: 400 @ 450
]

{ #category : 'actions' }
OCRPickerPresenter >> openReviewFrom: aDialog [

	repositoryList selection isEmpty ifTrue: [ ^ self ].
	(OCRReviewPresenter on: (OCRIcebergReader reviewOfRepositoryNamed: repositoryList selectedItem against: baseList selectedItem))
		open.
	aDialog close
]

{ #category : 'actions' }
OCRPickerPresenter >> showBases [

	| choices |
	repositoryList selection isEmpty ifTrue: [ ^ baseList items: #(  ) ].
	choices := OCRIcebergReader baseChoicesOfRepositoryNamed: repositoryList selectedItem.
	baseList
		display: [ :base | choices labelFor: base ];
		items: choices bases;
		selectIndex: 1
]
