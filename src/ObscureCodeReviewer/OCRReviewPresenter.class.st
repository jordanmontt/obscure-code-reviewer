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
		'browseButton',
		'topicsTree',
		'notebook',
		'topicText',
		'guidePresenter',
		'activeTree'
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

{ #category : 'actions' }
OCRReviewPresenter >> applyGuide: aString [
	"Keep the guide for this repository, so a refresh or a new review finds it, then show it."

	OCRReviewGuide forRepositoryNamed: review repositoryName put: aString.
	self refresh
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
	"The Structure, Topics and Guide tabs on the left; the diff (or the editor, or a topic's explanation) and the comment on the right."

	^ SpPanedLayout newLeftToRight
		  positionOfSlider: 22 percent;
		  add: notebook;
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

	self hasSelectedCommentable ifFalse: [ ^ self ].
	review comment: aString on: self selectedCommentable.
	changesTree refresh.
	topicsTree refresh
]

{ #category : 'initialization' }
OCRReviewPresenter >> connectPresenters [

	changesTree whenSelectionChangedDo: [ self selectionChangedIn: changesTree ].
	topicsTree whenSelectionChangedDo: [ self selectionChangedIn: topicsTree ].
	guidePresenter whenAppliedDo: [ :text | self applyGuide: text ].
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

{ #category : 'showing' }
OCRReviewPresenter >> enableCommentOn: anItem [

	commentText
		enabled: true;
		text: (review commentOn: anItem)
]

{ #category : 'actions' }
OCRReviewPresenter >> enableReviewing: aBoolean [
	"While editing, only Save and Cancel are possible."

	notebook enabled: aBoolean.
	changesTree enabled: aBoolean.
	topicsTree enabled: aBoolean.
	refreshButton enabled: aBoolean.
	browseButton enabled: (aBoolean and: [ self canBrowseSelection ]).
	editButton enabled: (aBoolean and: [ self canEditSelection ]).
	saveButton enabled: aBoolean not.
	cancelButton enabled: aBoolean not
]

{ #category : 'selection' }
OCRReviewPresenter >> hasSelectedChange [
	"Nothing selected, or a section, package, topic or unchanged class selected, means no change to show."

	^ activeTree selection isEmpty not and: [ activeTree selectedItem hasChange ]
]

{ #category : 'selection' }
OCRReviewPresenter >> hasSelectedCommentable [

	^ activeTree selection isEmpty not and: [ activeTree selectedItem isCommentable ]
]

{ #category : 'initialization' }
OCRReviewPresenter >> initializePresenters [

	self initializeToolbar.
	changesTree := self newChangesTreeOn: review structuralTree.
	topicsTree := self newChangesTreeOn: review topicTree.
	activeTree := changesTree.
	guidePresenter := self instantiate: OCRGuidePresenter.
	guidePresenter showGuide: review guide text warnings: review guideWarnings.
	notebook := self newNotebook
		            addPageTitle: 'Structure' provider: [ changesTree ];
		            addPageTitle: 'Topics' provider: [ topicsTree ];
		            addPageTitle: 'Guide' provider: [ guidePresenter ];
		            yourself.
	diff := self newDiff
		        showOptions: false;
		        leftLabel: 'Base';
		        rightLabel: 'Image';
		        yourself.
	editor := self newCode.
	topicText := self newText
		             beNotEditable;
		             yourself.
	changeArea := SpBoxLayout newTopToBottom
		              add: diff;
		              yourself.
	commentText := self newText
		               placeholder: 'Comment on the selected change or topic';
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
	"Commented changes and topics are marked, so the reviewer sees what is already done."

	(aNode isCommentable and: [ review hasCommentOn: aNode commentable ]) ifTrue: [ ^ aNode label , '   [commented]' ].
	^ aNode label
]

{ #category : 'initialization' }
OCRReviewPresenter >> newChangesTreeOn: someNodes [

	^ self newTree
		  roots: someNodes;
		  children: [ :node | node children ];
		  display: [ :node | self labelFor: node ];
		  displayIcon: [ :node | self iconNamed: node iconName ];
		  displayColor: [ :node | self colorFor: node ];
		  expandAll;
		  yourself
]

{ #category : 'actions' }
OCRReviewPresenter >> refresh [
	"Recompute the changes from the image and re-read the guide. The comments are kept (see OCRReview>>#takeCommentsFrom:),
	and so is the selected change or topic when it is still there."

	self hasSelectedCommentable ifFalse: [ ^ self reloadReview ].
	self reloadReviewSelecting: self selectedCommentable reference
]

{ #category : 'actions' }
OCRReviewPresenter >> reloadReview [
	"Recompute the review against the same base, with the stored guide."

	| newReview |
	newReview := OCRIcebergReader reviewOfRepositoryNamed: review repositoryName against: review base.
	newReview guide: (OCRReviewGuide forRepositoryNamed: review repositoryName).
	newReview takeCommentsFrom: review.
	review := newReview.
	self showReview
]

{ #category : 'actions' }
OCRReviewPresenter >> reloadReviewSelecting: aReference [

	self reloadReview.
	self selectItemReferenced: aReference
]

{ #category : 'actions' }
OCRReviewPresenter >> saveEdit: aString [
	"When the method does not compile, the editor shows the error and we stay in it."

	(self selectedChange compileInImage: aString notifying: editor interactionModel) ifFalse: [ ^ self ].
	self stopEditing.
	self refresh
]

{ #category : 'selection' }
OCRReviewPresenter >> selectItemReferenced: aReference [

	activeTree roots do: [ :root |
		root withAllChildrenDo: [ :node |
			(node isCommentable and: [ node commentable reference = aReference ]) ifTrue: [ ^ activeTree selectItem: node ] ] ]
]

{ #category : 'selection' }
OCRReviewPresenter >> selectedChange [
	"Only valid when #hasSelectedChange is true."

	^ activeTree selectedItem change
]

{ #category : 'selection' }
OCRReviewPresenter >> selectedCommentable [
	"A change or a topic. Only valid when #hasSelectedCommentable is true."

	^ activeTree selectedItem commentable
]

{ #category : 'selection' }
OCRReviewPresenter >> selectionChangedIn: aTree [
	"The diff and the comment follow the tree that was clicked last."

	activeTree := aTree.
	self showSelection
]

{ #category : 'initialization' }
OCRReviewPresenter >> setModelBeforeInitialization: aReview [

	review := aReview.
	review guide: (OCRReviewGuide forRepositoryNamed: review repositoryName)
]

{ #category : 'showing' }
OCRReviewPresenter >> showChange: aChange [
	"Both diff sides are cleared first, as Iceberg does, so the diff never mixes two changes."

	self showInChangeArea: diff.
	diff
		leftText: '';
		rightText: ''.
	diff
		leftText: aChange oldSource;
		rightText: aChange newSource.
	self enableCommentOn: aChange
]

{ #category : 'showing' }
OCRReviewPresenter >> showInChangeArea: aPresenter [

	changeArea
		removeAll;
		add: aPresenter
]

{ #category : 'showing' }
OCRReviewPresenter >> showNothing [

	self showInChangeArea: diff.
	diff
		leftText: '';
		rightText: ''.
	self disableComment
]

{ #category : 'actions' }
OCRReviewPresenter >> showReview [
	"Show the current review, after a refresh."

	changesTree
		roots: review structuralTree;
		expandAll.
	topicsTree
		roots: review topicTree;
		expandAll.
	guidePresenter showGuide: review guide text warnings: review guideWarnings.
	generalCommentText text: review generalComment.
	self withWindowDo: [ :window | window title: self windowTitle ]
]

{ #category : 'selection' }
OCRReviewPresenter >> showSelection [

	browseButton enabled: self canBrowseSelection.
	editButton enabled: self canEditSelection.
	activeTree selection isEmpty ifTrue: [ ^ self showNothing ].
	activeTree selectedItem showIn: self
]

{ #category : 'showing' }
OCRReviewPresenter >> showTopic: aTopic [

	topicText text: aTopic explanation.
	self showInChangeArea: topicText.
	self enableCommentOn: aTopic
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

	self showInChangeArea: diff.
	self enableReviewing: true
]

{ #category : 'actions' }
OCRReviewPresenter >> switchToEditor [

	self showInChangeArea: editor.
	self enableReviewing: false
]

{ #category : 'displaying' }
OCRReviewPresenter >> windowTitle [

	^ 'Obscure Code Reviewer - ' , review repositoryName , ' - base: ' , review baseLabel
]
