"
I am the review window:
- a toolbar: Refresh recomputes the changes and keeps the comments; Copy review copies all comments as Markdown, ready to paste to the agent; Browse opens the System Browser on the selected change; Edit, Save and Cancel let the reviewer fix a method by hand,
- a tree of changes on the left,
- on the right, a side-by-side diff (base | image), or the code editor while editing, and a comment box for the selected change,
- a general comment at the bottom.

While editing, the tree is disabled: Save or Cancel first. Saving refreshes the review.

	(OCRReviewPresenter onRepositoryNamed: 'my-project') open
"
Class {
	#name : 'OCRReviewPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'review',
		'changesTree',
		'diff',
		'commentText',
		'generalCommentText',
		'toolbar',
		'editor',
		'changeArea',
		'refreshButton',
		'editButton',
		'saveButton',
		'cancelButton',
		'browseButton'
	],
	#category : 'ObscureCodeReviewer-UI',
	#package : 'ObscureCodeReviewer',
	#tag : 'UI'
}

{ #category : 'instance creation' }
OCRReviewPresenter class >> onRepositoryNamed: aString [
	"Review the repository against its default base (see OCRIcebergReader>>#defaultBaseOf:)."

	^ self on: (OCRIcebergReader reviewOfRepositoryNamed: aString)
]

{ #category : 'testing' }
OCRReviewPresenter >> canBrowseSelection [

	^ self hasSelectedChange and: [ self selectedChange isInImage ]
]

{ #category : 'testing' }
OCRReviewPresenter >> canEditSelection [

	^ self hasSelectedChange and: [ self selectedChange isEditable ]
]

{ #category : 'layout' }
OCRReviewPresenter >> changesLayout [
	"The tree on the left; the diff (or the editor) and the comment of the selected change on the right."

	^ SpPanedLayout newLeftToRight
		  positionOfSlider: 22 percent;
		  add: changesTree;
		  add: (SpPanedLayout newTopToBottom
			   positionOfSlider: 80 percent;
			   add: changeArea;
			   add: commentText;
			   yourself);
		  yourself
]

{ #category : 'displaying' }
OCRReviewPresenter >> colorFor: aNode [
	"Colors come from the current theme, so they also work with dark and custom themes."

	aNode hasChange ifFalse: [ ^ self theme textColor ].
	aNode change isAddition ifTrue: [ ^ self theme successTextColor ].
	aNode change isRemoval ifTrue: [ ^ self theme dangerTextColor ].
	^ self theme textColor
]

{ #category : 'actions' }
OCRReviewPresenter >> commentChanged: aString [

	self hasSelectedChange ifFalse: [ ^ self ].
	review comment: aString on: self selectedChange.
	changesTree refresh
]

{ #category : 'initialization' }
OCRReviewPresenter >> connectPresenters [

	changesTree whenSelectionChangedDo: [ self showSelection ].
	commentText whenTextChangedDo: [ :text | self commentChanged: text asString ].
	generalCommentText whenTextChangedDo: [ :text | review generalComment: text asString ].
	editor whenSubmitDo: [ :text | self saveEdit: text asString ]
]

{ #category : 'actions' }
OCRReviewPresenter >> copyReview [

	Clipboard clipboardText: review feedback informing: 'Review copied to the clipboard'
]

{ #category : 'layout' }
OCRReviewPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  spacing: 5;
		  add: toolbar expand: false;
		  add: (SpPanedLayout newTopToBottom
			   positionOfSlider: 85 percent;
			   add: self changesLayout;
			   add: generalCommentText;
			   yourself);
		  yourself
]

{ #category : 'actions' }
OCRReviewPresenter >> disableComment [

	commentText
		enabled: false;
		text: ''
]

{ #category : 'actions' }
OCRReviewPresenter >> enableReviewing: aBoolean [
	"While editing, only Save and Cancel are possible."

	changesTree enabled: aBoolean.
	refreshButton enabled: aBoolean.
	browseButton enabled: (aBoolean and: [ self canBrowseSelection ]).
	editButton enabled: (aBoolean and: [ self canEditSelection ]).
	saveButton enabled: aBoolean not.
	cancelButton enabled: aBoolean not
]

{ #category : 'testing' }
OCRReviewPresenter >> hasSelectedChange [
	"Nothing selected, or a section, package or unchanged class selected, means no change to show."

	^ changesTree selection isEmpty not and: [ changesTree selectedItem hasChange ]
]

{ #category : 'initialization' }
OCRReviewPresenter >> initializePresenters [

	self initializeToolbar.
	changesTree := self newTree
		               roots: review structuralTree;
		               children: [ :node | node children ];
		               display: [ :node | self labelFor: node ];
		               displayIcon: [ :node | self iconNamed: node iconName ];
		               displayColor: [ :node | self colorFor: node ];
		               expandAll;
		               yourself.
	diff := self newDiff
		        showOptions: false;
		        leftLabel: 'Base';
		        rightLabel: 'Image';
		        yourself.
	editor := self newCode.
	changeArea := SpBoxLayout newTopToBottom
		              add: diff;
		              yourself.
	commentText := self newText
		               placeholder: 'Comment on the selected change';
		               enabled: false;
		               yourself.
	generalCommentText := self newText
		                      placeholder: 'General comment on the whole review';
		                      yourself
]

{ #category : 'initialization' }
OCRReviewPresenter >> initializeToolbar [
	"A toolbar like the Playground's."

	refreshButton := self newToolbarButton
		                 label: 'Refresh';
		                 icon: (self iconNamed: #glamorousRefresh);
		                 help: 'Recompute the changes from the image, keeping the comments';
		                 action: [ self refresh ];
		                 yourself.
	browseButton := self newToolbarButton
		                label: 'Browse';
		                icon: (self iconNamed: #glamorousBrowse);
		                help: 'Open the System Browser on the selected method or class';
		                action: [ self selectedChange browse ];
		                enabled: false;
		                yourself.
	editButton := self newToolbarButton
		              label: 'Edit';
		              icon: (self iconNamed: #edit);
		              help: 'Edit the selected method by hand';
		              action: [ self startEditing ];
		              enabled: false;
		              yourself.
	saveButton := self newToolbarButton
		              label: 'Save';
		              icon: (self iconNamed: #smallSave);
		              help: 'Compile the edited method and refresh the review (Cmd+S)';
		              action: [ self saveEdit: editor text asString ];
		              enabled: false;
		              yourself.
	cancelButton := self newToolbarButton
		                label: 'Cancel';
		                icon: (self iconNamed: #smallCancel);
		                help: 'Stop editing without saving';
		                action: [ self stopEditing ];
		                enabled: false;
		                yourself.
	toolbar := self newToolbar
		           addStyle: 'stToolbar';
		           addItem: refreshButton;
		           addItem: (self newToolbarButton
			            label: 'Copy review';
			            icon: (self iconNamed: #smallCopy);
			            help: 'Copy all comments as Markdown, ready to paste to the agent';
			            action: [ self copyReview ];
			            yourself);
		           addItem: browseButton;
		           addItem: editButton;
		           addItem: saveButton;
		           addItem: cancelButton;
		           yourself
]

{ #category : 'initialization' }
OCRReviewPresenter >> initializeWindow: aWindowPresenter [

	aWindowPresenter
		title: self windowTitle;
		initialExtent: 1100 @ 700
]

{ #category : 'displaying' }
OCRReviewPresenter >> labelFor: aNode [
	"Commented changes are marked, so the reviewer sees what is already done."

	(aNode hasChange and: [ review hasCommentOn: aNode change ]) ifTrue: [ ^ aNode label , '   [commented]' ].
	^ aNode label
]

{ #category : 'actions' }
OCRReviewPresenter >> refresh [
	"Recompute the changes from the image. The comments are kept (see OCRReview>>#takeCommentsFrom:),
	and so is the selected change when it is still there."

	self hasSelectedChange ifFalse: [ ^ self reloadReview ].
	self reloadReviewSelecting: self selectedChange reference
]

{ #category : 'actions' }
OCRReviewPresenter >> reloadReview [
	"Recompute the review against the same base."

	| newReview |
	newReview := OCRIcebergReader reviewOfRepositoryNamed: review repositoryName against: review base.
	newReview takeCommentsFrom: review.
	review := newReview.
	self showReview
]

{ #category : 'actions' }
OCRReviewPresenter >> reloadReviewSelecting: aReference [

	self reloadReview.
	self selectChangeReferenced: aReference
]

{ #category : 'actions' }
OCRReviewPresenter >> saveEdit: aString [
	"When the method does not compile, the editor shows the error and we stay in it."

	(self selectedChange compileInImage: aString notifying: editor interactionModel) ifFalse: [ ^ self ].
	self stopEditing.
	self refresh
]

{ #category : 'actions' }
OCRReviewPresenter >> selectChangeReferenced: aReference [

	changesTree roots do: [ :section |
		section withAllChildrenDo: [ :node |
			(node hasChange and: [ node change reference = aReference ]) ifTrue: [ ^ changesTree selectItem: node ] ] ]
]

{ #category : 'accessing' }
OCRReviewPresenter >> selectedChange [
	"Only valid when #hasSelectedChange is true."

	^ changesTree selectedItem change
]

{ #category : 'initialization' }
OCRReviewPresenter >> setModelBeforeInitialization: aReview [

	review := aReview
]

{ #category : 'actions' }
OCRReviewPresenter >> showChange: aChange [

	diff
		leftText: aChange oldSource;
		rightText: aChange newSource.
	commentText
		enabled: true;
		text: (review commentOn: aChange)
]

{ #category : 'actions' }
OCRReviewPresenter >> showReview [
	"Show the current review, after a refresh."

	changesTree
		roots: review structuralTree;
		expandAll.
	generalCommentText text: review generalComment.
	self withWindowDo: [ :window | window title: self windowTitle ]
]

{ #category : 'actions' }
OCRReviewPresenter >> showSelection [
	"Both diff sides are cleared first, as Iceberg does, so the diff never mixes two changes."

	diff
		leftText: '';
		rightText: ''.
	browseButton enabled: self canBrowseSelection.
	editButton enabled: self canEditSelection.
	self hasSelectedChange
		ifTrue: [ self showChange: self selectedChange ]
		ifFalse: [ self disableComment ]
]

{ #category : 'actions' }
OCRReviewPresenter >> startEditing [

	| method |
	method := self selectedChange methodInImage.
	editor
		beForMethod: method;
		text: method sourceCode.
	self switchToEditor
]

{ #category : 'actions' }
OCRReviewPresenter >> stopEditing [

	self switchToDiff
]

{ #category : 'actions' }
OCRReviewPresenter >> switchToDiff [

	changeArea
		removeAll;
		add: diff.
	self enableReviewing: true
]

{ #category : 'actions' }
OCRReviewPresenter >> switchToEditor [

	changeArea
		removeAll;
		add: editor.
	self enableReviewing: false
]

{ #category : 'displaying' }
OCRReviewPresenter >> windowTitle [

	^ 'Obscure Code Reviewer - ' , review repositoryName , ' - base: ' , review baseLabel
]
