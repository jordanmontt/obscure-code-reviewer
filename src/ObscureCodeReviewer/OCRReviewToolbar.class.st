"
I am the toolbar of the review window (an OCRReviewPresenter, my model):
- Refresh recomputes the changes and keeps what the reviewer did;
- Copy review copies the comments as Markdown, ready to paste to the agent;
- Reviewed marks the selection as reviewed; when it already is, the button says Unmark and unmarks it;
- Browse opens the System Browser on the selected change;
- Edit, Save and Cancel let the reviewer fix a method by hand.

#updateButtons enables the buttons that make sense for the current selection.
"
Class {
	#name : 'OCRReviewToolbar',
	#superclass : 'SpPresenter',
	#instVars : [
		'reviewPresenter',
		'toolbar',
		'refreshButton',
		'reviewedButton',
		'browseButton',
		'editButton',
		'saveButton',
		'cancelButton'
	],
	#category : 'ObscureCodeReviewer-UI',
	#package : 'ObscureCodeReviewer',
	#tag : 'UI'
}

{ #category : 'layout' }
OCRReviewToolbar >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  add: toolbar;
		  yourself
]

{ #category : 'initialization' }
OCRReviewToolbar >> initializeEditingButtons [

	editButton := self newToolbarButton
		              label: 'Edit';
		              icon: (self iconNamed: #edit);
		              help: 'Edit the selected method by hand';
		              action: [ reviewPresenter startEditing ];
		              yourself.
	saveButton := self newToolbarButton
		              label: 'Save';
		              icon: (self iconNamed: #smallSave);
		              help: 'Compile the edited method and refresh the review (Cmd+S)';
		              action: [ reviewPresenter saveEdit ];
		              yourself.
	cancelButton := self newToolbarButton
		                label: 'Cancel';
		                icon: (self iconNamed: #smallCancel);
		                help: 'Stop editing without saving';
		                action: [ reviewPresenter stopEditing ];
		                yourself
]

{ #category : 'initialization' }
OCRReviewToolbar >> initializePresenters [
	"A toolbar like the Playground's."

	self initializeReviewingButtons.
	self initializeEditingButtons.
	toolbar := self newToolbar
		           addStyle: 'stToolbar';
		           addItem: refreshButton;
		           addItem: (self newToolbarButton
			            label: 'Copy review';
			            icon: (self iconNamed: #smallCopy);
			            help: 'Copy all comments as Markdown, ready to paste to the agent';
			            action: [ reviewPresenter copyReview ];
			            yourself);
		           addItem: reviewedButton;
		           addItem: browseButton;
		           addItem: editButton;
		           addItem: saveButton;
		           addItem: cancelButton;
		           yourself
]

{ #category : 'initialization' }
OCRReviewToolbar >> initializeReviewingButtons [

	refreshButton := self newToolbarButton
		                 label: 'Refresh';
		                 icon: (self iconNamed: #glamorousRefresh);
		                 help: 'Recompute the changes from the image and re-read the guide, keeping comments and marks';
		                 action: [ reviewPresenter refresh ];
		                 yourself.
	reviewedButton := self newToolbarButton
		                  label: 'Reviewed';
		                  icon: (self iconNamed: #smallOk);
		                  help:
			                  'Mark the selected change, or everything under the selected node, as reviewed. When it already is, unmark it.';
		                  action: [ reviewPresenter toggleReviewed ];
		                  yourself.
	browseButton := self newToolbarButton
		                label: 'Browse';
		                icon: (self iconNamed: #glamorousBrowse);
		                help: 'Open the System Browser on the selected method or class';
		                action: [ reviewPresenter browseSelection ];
		                yourself
]

{ #category : 'accessing - model' }
OCRReviewToolbar >> setModelBeforeInitialization: aReviewPresenter [

	reviewPresenter := aReviewPresenter
]

{ #category : 'updating' }
OCRReviewToolbar >> updateButtons [
	"While editing, only Save and Cancel are possible."

	| reviewing |
	reviewing := reviewPresenter isEditing not.
	refreshButton enabled: reviewing.
	reviewedButton enabled: (reviewing and: [ reviewPresenter canMarkSelection ]).
	browseButton enabled: (reviewing and: [ reviewPresenter canBrowseSelection ]).
	editButton enabled: (reviewing and: [ reviewPresenter canEditSelection ]).
	saveButton enabled: reviewing not.
	cancelButton enabled: reviewing not.
	self updateReviewedButton
]

{ #category : 'updating' }
OCRReviewToolbar >> updateReviewedButton [
	"When everything selected is already reviewed, the button unmarks it."

	reviewPresenter isSelectionReviewed
		ifTrue: [
			reviewedButton
				label: 'Unmark';
				icon: (self iconNamed: #smallUndo) ]
		ifFalse: [
			reviewedButton
				label: 'Reviewed';
				icon: (self iconNamed: #smallOk) ]
]
