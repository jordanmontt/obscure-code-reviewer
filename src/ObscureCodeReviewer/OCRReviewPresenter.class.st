"
I am the review window:
- a header with the repository, what it is compared with, how much is reviewed and commented, and the Refresh and Finish review buttons;
- on the left, the Files and Topics trees (OCRReviewSidebarPresenter), each starting with the Overview;
- on the right, what is selected: its title and the buttons that act on it, then the change (OCRChangeAreaPresenter), the topic (OCRTopicPresenter) or the overview (OCROverviewPresenter), then the comment on it;
- at the bottom, the shortcuts.

Reviewed marks the selection and goes to the next change not reviewed. Finish review opens OCRFinishReviewPresenter: the general comment, and Copy review.

While editing, the trees are disabled: Save or Cancel first. Saving refreshes the review.

	(OCRReviewPresenter onRepositoryNamed: 'my-project') open
"
Class {
	#name : 'OCRReviewPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'review',
		'changeArea',
		'commentPane',
		'buttonActions',
		'sidebar',
		'topicPresenter',
		'overview',
		'content',
		'commentLabel',
		'commentBox',
		'kickerLabel',
		'titleLabel',
		'kindLabel',
		'buttons',
		'moreActions',
		'moreButton',
		'pageActions',
		'editBar',
		'header'
	],
	#category : 'ObscureCodeReviewer-UI',
	#package : 'ObscureCodeReviewer',
	#tag : 'UI'
}

{ #category : 'accessing' }
OCRReviewPresenter class >> currentApplication [

	^ OCRApplication new
]

{ #category : 'instance creation' }
OCRReviewPresenter class >> onRepositoryNamed: aString [
	"Review the repository against its default base (see OCRIcebergReader>>#defaultBaseOf:)."

	^ self on: (OCRIcebergReader reviewOfRepositoryNamed: aString)
]

{ #category : 'instance creation' }
OCRReviewPresenter class >> onRepositoryNamed: aString guide: aGuide [
	"Review the repository against its default base, with aGuide (an OCRReviewGuide)."

	^ self on: ((OCRIcebergReader reviewOfRepositoryNamed: aString)
		   guide: aGuide;
		   yourself)
]

{ #category : 'actions' }
OCRReviewPresenter >> actionGroupOf: someActions [

	^ someActions inject: SpActionGroup new into: [ :group :each |
		  group add: each.
		  group ]
]

{ #category : 'accessing' }
OCRReviewPresenter >> actionsOnScreen [
	"The actions the reviewer finds on a button, or in the More menu."

	^ buttonActions allCommands , moreActions allCommands
]

{ #category : 'actions' }
OCRReviewPresenter >> applyGuide: aString [
	"Show the review with this guide. Refresh keeps it; nothing else does: it lives as long as the window."

	self refreshWithGuide: (OCRReviewGuide fromText: aString)
]

{ #category : 'actions' }
OCRReviewPresenter >> browseAction [

	^ SpAction new
		  name: 'Browse';
		  iconName: #glamorousBrowse;
		  description: 'Open the System Browser on the selected method or class (Cmd+B)';
		  shortcutKey: $b actionModifier;
		  actionEnabled: [ self isEditing not and: [ self canBrowseSelection ] ];
		  action: [ self browseSelection ];
		  yourself
]

{ #category : 'actions' }
OCRReviewPresenter >> browseImplementorsOfSelection [
	"In my application, as Code search does (see SpToolCurrentApplicationCommand>>#execute)."

	SpToolCurrentApplication
		value: self application
		during: [ self systemNavigation browseAllImplementorsOf: self selectedChange selector ]
]

{ #category : 'actions' }
OCRReviewPresenter >> browseSelection [

	sidebar selectedNode browse
]

{ #category : 'actions' }
OCRReviewPresenter >> browseSendersOfSelection [
	"In my application, as Code search does (see SpToolCurrentApplicationCommand>>#execute)."

	SpToolCurrentApplication
		value: self application
		during: [ self systemNavigation browseAllSendersOf: self selectedChange selector ]
]

{ #category : 'initialization' }
OCRReviewPresenter >> buttonFor: anActionName [

	^ buttons associations
		  detect: [ :each | each key name = anActionName ]
		  ifFound: [ :each | each value ]
		  ifNone: [ self error: 'No button for ' , anActionName ]
]

{ #category : 'testing' }
OCRReviewPresenter >> canBrowseMessagesOfSelection [
	"Implementors and senders need a selector: a method, even a removed one."

	^ self hasSelectedChange and: [ self selectedChange isMethodChange ]
]

{ #category : 'testing' }
OCRReviewPresenter >> canBrowseSelection [

	^ sidebar selectedNode canBrowse
]

{ #category : 'testing' }
OCRReviewPresenter >> canEditSelection [

	^ self hasSelectedChange and: [ self selectedChange isEditable ]
]

{ #category : 'selection' }
OCRReviewPresenter >> canMarkSelection [

	^ sidebar selectedNode changesBelow isNotEmpty
]

{ #category : 'actions' }
OCRReviewPresenter >> cancelAction [

	^ SpAction new
		  name: 'Cancel';
		  iconName: #smallCancel;
		  description: 'Stop editing without saving (Esc)';
		  shortcutKey: Character escape asKeyCombination;
		  actionEnabled: [ self isEditing ];
		  action: [ self stopEditing ];
		  yourself
]

{ #category : 'actions' }
OCRReviewPresenter >> commentChanged: aString [

	self hasSelectedCommentable ifFalse: [ ^ self ].
	review comment: aString on: self selectedCommentable.
	sidebar refreshTrees.
	topicPresenter refresh.
	self updateHeader
]

{ #category : 'initialization' }
OCRReviewPresenter >> connectPresenters [

	sidebar whenSelectionChangedDo: [ self showSelection ].
	sidebar whenChangeActivatedDo: [ :change | self openChangeInWindow: change ].
	sidebar whenMarkChangedDo: [ :node :aBoolean | self mark: node changesBelow reviewed: aBoolean ].
	topicPresenter whenChangeActivatedDo: [ :change | self selectItemReferenced: change reference ].
	overview whenGuideAppliedDo: [ :text | self applyGuide: text ].
	overview whenPullRequestChangedDo: [ :pullRequest | review pullRequest: pullRequest ].
	changeArea whenSaveRequestedDo: [ self saveEdit ].
	commentPane whenTextChangedDo: [ :text | self commentChanged: text asString ].
	self updateHeader.
	sidebar selectOverview
]

{ #category : 'layout' }
OCRReviewPresenter >> defaultLayout [
	"A header with the review's progress, the tree on the left, the selection on the right, the shortcuts at the bottom."

	^ SpBoxLayout newTopToBottom
		  add: self headerBar expand: false;
		  add: (SpPanedLayout newLeftToRight
			   positionOfSlider: 28 percent;
			   add: sidebar;
			   add: self pageLayout;
			   yourself);
		  add: self footer expand: false;
		  yourself
]

{ #category : 'actions' }
OCRReviewPresenter >> editAction [

	^ SpAction new
		  name: 'Edit';
		  iconName: #edit;
		  description: 'Edit the selected method by hand (Cmd+E)';
		  shortcutKey: $e actionModifier;
		  actionEnabled: [ self isEditing not and: [ self canEditSelection ] ];
		  action: [ self startEditing ];
		  yourself
]

{ #category : 'showing' }
OCRReviewPresenter >> enableCommentOn: anItem labelled: aString [

	commentLabel label: aString.
	commentPane
		enabled: true;
		text: (review commentOn: anItem)
]

{ #category : 'editing' }
OCRReviewPresenter >> enableReviewing: aBoolean [
	"While editing, only Save and Cancel are possible."

	sidebar enableSelecting: aBoolean.
	commentPane enabled: aBoolean.
	self updateButtons
]

{ #category : 'actions' }
OCRReviewPresenter >> finishReviewAction [

	^ SpAction new
		  name: 'Finish review';
		  iconName: #smallCopy;
		  description: 'Write a general comment, then copy all comments as Markdown, ready to paste to the agent';
		  action: [ self newFinishReview openDialog ];
		  yourself
]

{ #category : 'layout' }
OCRReviewPresenter >> footer [

	^ self newPresenter
		  addStyle: 'ocrBar';
		  layout: (SpBoxLayout newLeftToRight
			   add: (self newLabel
				    label:
					    'Cmd+R reviewed & next     Cmd+A select all     Cmd+B browse     Cmd+E edit     Cmd+M implementors     Cmd+N senders     Double-click: open in its own window';
				    addStyle: 'ocrMuted';
				    yourself);
			   yourself);
		  yourself
]

{ #category : 'selection' }
OCRReviewPresenter >> hasSelectedChange [
	"Nothing selected, or a section, package, topic or unchanged class selected, means no change to show."

	^ sidebar selectedNode hasChange
]

{ #category : 'selection' }
OCRReviewPresenter >> hasSelectedCommentable [

	^ sidebar selectedNode isCommentable
]

{ #category : 'layout' }
OCRReviewPresenter >> headerBar [

	^ self newPresenter
		  addStyle: 'ocrBar';
		  layout: (SpBoxLayout newLeftToRight
			   spacing: 12;
			   vAlignCenter;
			   add: header;
			   add: (self buttonFor: 'Review all') expand: false;
			   add: (self buttonFor: 'Refresh') expand: false;
			   add: (self buttonFor: 'Finish review') expand: false;
			   yourself);
		  yourself
]

{ #category : 'showing' }
OCRReviewPresenter >> hideComment [

	commentPane
		enabled: false;
		text: ''
]

{ #category : 'actions' }
OCRReviewPresenter >> implementorsAction [

	^ SpAction new
		  name: 'Implementors';
		  iconName: #smallFind;
		  description: 'Browse the implementors of the selected method (Cmd+M)';
		  shortcutKey: $m actionModifier;
		  actionEnabled: [ self isEditing not and: [ self canBrowseMessagesOfSelection ] ];
		  action: [ self browseImplementorsOfSelection ];
		  yourself
]

{ #category : 'initialization' }
OCRReviewPresenter >> initializeActions [
	"Each action is written once, in its own method. The buttons and the window (its shortcuts, and the right-click menu of the trees) each get their own instances.
	A text pane answers its own keys first: there Cmd+B, Cmd+M and Cmd+N are Code search on the selected word, and Cmd+A selects its text.
	More is a plain button that pops up its menu: a menu button does not ask for the width of its label."

	self actions: (self actionGroupOf: {
		 self reviewedAction.
		 self selectAllAction.
		 self browseAction.
		 self editAction.
		 self implementorsAction.
		 self sendersAction.
		 (self cancelAction
			  beShortcutOnly;
			  yourself) }).
	sidebar treeActions: self actions.
	moreActions := self actionGroupOf: ({
		                self editAction.
		                self implementorsAction.
		                self sendersAction } do: [ :each | each actionVisible: [ self showsChangeActions ] ]).
	pageActions := {
		               (self browseAction
			                actionVisible: [ self showsChangeActions ];
			                yourself).
		               (self reviewedAction
			                actionVisible: [ self isEditing not and: [ self canMarkSelection ] ];
			                yourself).
		               (self saveAction
			                actionVisible: [ self isEditing ];
			                yourself).
		               (self cancelAction
			                actionVisible: [ self isEditing ];
			                yourself) }.
	buttonActions := self actionGroupOf: {
		                 self reviewAllAction.
		                 self refreshAction.
		                 self finishReviewAction } , pageActions.
	buttons := IdentityDictionary new.
	buttonActions allCommands do: [ :each | buttons at: each put: (self newButtonFor: each) ].
	moreButton := self newButton
		              label: 'More';
		              iconName: #arrowDown;
		              help: 'Edit the method, browse its implementors or senders';
		              action: [
			              (self newMenu
				               fillWith: moreActions;
				               yourself) openWithSpecAtPointer ];
		              yourself.
	editBar := self newPresenter
		           layout: (SpBoxLayout newLeftToRight
			            spacing: 6;
			            add: (self newLabel
				             label: 'Editing the method in the image. Cmd+S saves, Esc cancels.';
				             addStyle: 'ocrMuted';
				             yourself);
			            add: (self buttonFor: 'Save') expand: false;
			            add: (self buttonFor: 'Cancel') expand: false;
			            yourself);
		           yourself
]

{ #category : 'initialization' }
OCRReviewPresenter >> initializePresenters [

	header := self instantiate: OCRReviewHeaderPresenter.
	sidebar := self instantiate: OCRReviewSidebarPresenter on: review.
	changeArea := self instantiate: OCRChangeAreaPresenter.
	topicPresenter := self instantiate: OCRTopicPresenter.
	overview := self instantiate: OCROverviewPresenter.
	kickerLabel := self newLabel
		               addStyle: 'ocrMuted';
		               yourself.
	titleLabel := self newLabel
		              addStyle: 'ocrPageTitle';
		              yourself.
	kindLabel := self newLabel.
	commentLabel := self newLabel
		                addStyle: 'ocrMuted';
		                yourself.
	commentPane := self newCommentPane
		               placeholder: 'Comment on the selected change or topic (Markdown)';
		               enabled: false;
		               yourself.
	content := self newPresenter
		           layout: SpBoxLayout newTopToBottom;
		           yourself.
	commentBox := self newPresenter
		              layout: (SpBoxLayout newTopToBottom
			               spacing: 4;
			               add: commentLabel expand: false;
			               add: commentPane;
			               yourself);
		              yourself.
	self initializeActions
]

{ #category : 'initialization' }
OCRReviewPresenter >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter initialExtent: 1200 @ 760
]

{ #category : 'editing' }
OCRReviewPresenter >> isEditing [

	^ changeArea isEditing
]

{ #category : 'selection' }
OCRReviewPresenter >> isSelectingInFiles [

	^ sidebar isSelectingInFiles
]

{ #category : 'selection' }
OCRReviewPresenter >> isSelectionReviewed [

	^ self canMarkSelection and: [ review areAllReviewed: sidebar selectedNode changesBelow ]
]

{ #category : 'showing' }
OCRReviewPresenter >> kickerOf: aChange [
	"The groups the selected change is in, and the topic of the guide it is in, if any."

	| groups |
	groups := ' › ' join: (sidebar pathOf: sidebar selectedNode).
	^ review topicTree
		  detect: [ :each | each isCommentable and: [ each changesBelow includes: aChange ] ]
		  ifFound: [ :each |
			  '{1}     Topic: {2}' format: {
				  groups.
				  each name } ]
		  ifNone: [ groups ]
]

{ #category : 'actions' }
OCRReviewPresenter >> mark: someChanges reviewed: aBoolean [

	someChanges do: [ :each |
		aBoolean
			ifTrue: [ review markReviewed: each ]
			ifFalse: [ review unmarkReviewed: each ] ].
	self updateReviewState
]

{ #category : 'initialization' }
OCRReviewPresenter >> newButtonFor: anAction [

	^ self newButton
		  label: anAction dynamicName;
		  iconName: anAction iconName;
		  help: anAction description;
		  action: [ anAction canBeExecuted ifTrue: [ anAction execute ] ];
		  yourself
]

{ #category : 'initialization' }
OCRReviewPresenter >> newCommentPane [

	^ self instantiate: OCRCommentPresenter
]

{ #category : 'actions' }
OCRReviewPresenter >> newFinishReview [

	^ self instantiate: OCRFinishReviewPresenter on: review
]

{ #category : 'showing' }
OCRReviewPresenter >> openChangeInWindow: aChange [
	"A double-clicked change opens alone in a large window, read-only, for long lines and long methods. Several can stay open side by side."

	| area |
	area := OCRChangeAreaPresenter newApplication: self application.
	area showChange: aChange comparedWith: (review baseSourceOf: aChange) notes: (review notesAbout: aChange).
	area asWindow
		title: aChange reference;
		initialExtent: 1200 @ 800;
		open
]

{ #category : 'testing' }
OCRReviewPresenter >> overview [

	^ overview
]

{ #category : 'layout' }
OCRReviewPresenter >> pageLayout [
	"What is selected: its title and the buttons that act on it, then what it is (see #showContent:)."

	^ SpBoxLayout newTopToBottom
		  spacing: 6;
		  borderWidth: 8;
		  add: (SpBoxLayout newLeftToRight
			   spacing: 6;
			   vAlignCenter;
			   add: (SpBoxLayout newTopToBottom
				    add: kickerLabel expand: false;
				    add: (SpBoxLayout newLeftToRight
					     spacing: 10;
					     add: titleLabel expand: false;
					     add: kindLabel;
					     yourself)
				    expand: false;
				    yourself);
			   add: (self buttonFor: 'Browse') expand: false;
			   add: moreButton expand: false;
			   add: (self buttonFor: 'Reviewed') expand: false;
			   yourself)
		  expand: false;
		  add: content;
		  yourself
]

{ #category : 'actions' }
OCRReviewPresenter >> recomputedReview [
	"The review recomputed from the image against the same base, without the reviewer's work yet."

	^ OCRIcebergReader reviewOfRepositoryNamed: review repositoryName against: review base
]

{ #category : 'actions' }
OCRReviewPresenter >> refresh [
	"Recompute the changes from the image, with the same guide (see #refreshWithGuide:)."

	self refreshWithGuide: review guide
]

{ #category : 'actions' }
OCRReviewPresenter >> refreshAction [

	^ SpAction new
		  name: 'Refresh';
		  iconName: #glamorousRefresh;
		  description: 'Recompute the changes from the image, keeping the guide, comments and marks';
		  actionEnabled: [ self isEditing not ];
		  action: [ self refresh ];
		  yourself
]

{ #category : 'actions' }
OCRReviewPresenter >> refreshWithGuide: aGuide [
	"Recompute the changes from the image against the same base, and show them with aGuide. What the reviewer did is kept (see OCRReview>>#continueFrom:), and so is the selected change or topic when it is still there."

	| selected newReview |
	selected := sidebar selectedNode.
	newReview := self recomputedReview.
	newReview guide: aGuide.
	newReview continueFrom: review.
	review := newReview.
	self showReview.
	selected isCommentable ifTrue: [ self selectItemReferenced: selected commentable reference ]
]

{ #category : 'actions' }
OCRReviewPresenter >> reviewAllAction [

	^ SpAction new
		  name: 'Review all';
		  iconName: #smallOk;
		  description: 'Mark every change of the review as reviewed. Untick a row to take it back';
		  actionEnabled: [ self isEditing not and: [ review unreviewedChanges isNotEmpty ] ];
		  action: [ self mark: review changes reviewed: true ];
		  yourself
]

{ #category : 'actions' }
OCRReviewPresenter >> reviewedAction [
	"When everything selected is already reviewed, it unmarks it, with the undo icon."

	^ SpAction new
		  name: 'Reviewed';
		  dynamicName: [
			  self isSelectionReviewed
				  ifTrue: [ 'Unmark' ]
				  ifFalse: [ 'Reviewed' ] ];
		  iconName: #smallOk;
		  dynamicIconName: [
			  self isSelectionReviewed
				  ifTrue: [ #smallUndo ]
				  ifFalse: [ #smallOk ] ];
		  description:
			  'Mark the selected change as reviewed and go to the next one not reviewed. On a group or a topic, mark everything in it. When it already is, unmark it (Cmd+R)';
		  shortcutKey: $r actionModifier;
		  actionEnabled: [ self isEditing not and: [ self canMarkSelection ] ];
		  action: [ self toggleReviewed ];
		  yourself
]

{ #category : 'actions' }
OCRReviewPresenter >> saveAction [
	"Cmd+S in the editor saves too (see #connectPresenters)."

	^ SpAction new
		  name: 'Save';
		  iconName: #smallSave;
		  description: 'Compile the edited method and refresh the review (Cmd+S)';
		  actionEnabled: [ self isEditing ];
		  action: [ self saveEdit ];
		  yourself
]

{ #category : 'editing' }
OCRReviewPresenter >> saveEdit [
	"When the method does not compile, the editor shows the error and we stay in it."

	(changeArea compileEditOf: self selectedChange) ifFalse: [ ^ self ].
	self stopEditing.
	self refresh
]

{ #category : 'actions' }
OCRReviewPresenter >> selectAllAction [

	^ SpAction new
		  name: 'Select all';
		  iconName: #smallSelectAll;
		  description: 'Select every row, then Reviewed marks them all (Cmd+A)';
		  shortcutKey: $a actionModifier;
		  actionEnabled: [ self isEditing not ];
		  action: [ sidebar selectAll ];
		  yourself
]

{ #category : 'selection' }
OCRReviewPresenter >> selectItemReferenced: aReference [
	"Select the change or topic written aReference, e.g. 'MyClass>>#myMethod', when it is in the tree shown."

	sidebar selectItemReferenced: aReference
]

{ #category : 'actions' }
OCRReviewPresenter >> selectNextUnreviewedAfter: aChange [
	"In the order of the tree shown, starting over at the top. When every change is reviewed, the selection stays."

	| ordered index candidates |
	ordered := sidebar changesInOrder.
	index := ordered indexOf: aChange.
	candidates := (ordered copyFrom: index + 1 to: ordered size) , (ordered copyFrom: 1 to: index - 1).
	candidates detect: [ :each | (review isReviewed: each) not ] ifFound: [ :each | self selectItemReferenced: each reference ]
]

{ #category : 'selection' }
OCRReviewPresenter >> selectedChange [
	"Only valid when #hasSelectedChange is true."

	^ sidebar selectedNode change
]

{ #category : 'selection' }
OCRReviewPresenter >> selectedCommentable [
	"A change or a topic. Only valid when #hasSelectedCommentable is true."

	^ sidebar selectedNode commentable
]

{ #category : 'actions' }
OCRReviewPresenter >> sendersAction [

	^ SpAction new
		  name: 'Senders';
		  iconName: #smallFind;
		  description: 'Browse the senders of the selected method (Cmd+N)';
		  shortcutKey: $n actionModifier;
		  actionEnabled: [ self isEditing not and: [ self canBrowseMessagesOfSelection ] ];
		  action: [ self browseSendersOfSelection ];
		  yourself
]

{ #category : 'accessing - model' }
OCRReviewPresenter >> setModelBeforeInitialization: aReview [

	review := aReview
]

{ #category : 'showing' }
OCRReviewPresenter >> showChange: aChange [

	self showTitle: aChange reference kicker: (self kickerOf: aChange).
	self showKindOf: aChange.
	changeArea showChange: aChange comparedWith: (review baseSourceOf: aChange) notes: (review notesAbout: aChange).
	self showContentWithComment: changeArea.
	self enableCommentOn: aChange labelled: 'Your comment on ' , aChange reference
]

{ #category : 'showing' }
OCRReviewPresenter >> showContent: aPresenter [
	"aPresenter alone, without a comment.
	Spec cannot add a layout to the layout of an open window, only presenters: the content is one presenter whose children are replaced. Morphic does not lay out again a presenter hidden then shown, so nothing is hidden."

	content layout
		removeAll;
		add: aPresenter
]

{ #category : 'showing' }
OCRReviewPresenter >> showContentWithComment: aPresenter [
	"aPresenter, with the comment on the selection below it."

	content layout
		removeAll;
		add: aPresenter;
		add: commentBox height: 110
]

{ #category : 'showing' }
OCRReviewPresenter >> showKindOf: aChange [

	#( 'ocrAdded' 'ocrRemoved' 'ocrModified' ) do: [ :each | kindLabel removeStyle: each ].
	kindLabel
		label: aChange kindDescription;
		addStyle: (aChange isAddition
			 ifTrue: [ 'ocrAdded' ]
			 ifFalse: [
				 aChange isRemoval
					 ifTrue: [ 'ocrRemoved' ]
					 ifFalse: [ 'ocrModified' ] ])
]

{ #category : 'showing' }
OCRReviewPresenter >> showNothing [
	"A section, a package or a class whose definition did not change: nothing to show but where it is."

	self showTitle: sidebar selectedNode name kicker: (' › ' join: (sidebar pathOf: sidebar selectedNode)).
	changeArea showNothing.
	self showContent: changeArea.
	self hideComment
]

{ #category : 'showing' }
OCRReviewPresenter >> showOverview [

	self showTitle: 'Overview' kicker: review repositoryName.
	overview showReview: review.
	self showContent: overview.
	self hideComment
]

{ #category : 'showing' }
OCRReviewPresenter >> showReview [

	sidebar showReview: review.
	self updateHeader.
	self updateWindowTitle.
	sidebar selectOverview
]

{ #category : 'showing' }
OCRReviewPresenter >> showSelection [

	self updateButtons.
	sidebar selectedNode showIn: self
]

{ #category : 'showing' }
OCRReviewPresenter >> showTitle: aTitle kicker: aString [

	kickerLabel label: aString.
	titleLabel label: aTitle.
	kindLabel label: ''
]

{ #category : 'showing' }
OCRReviewPresenter >> showTopic: aTopic [

	self showTitle: aTopic title kicker: 'Topic'.
	topicPresenter showTopic: aTopic changes: sidebar selectedNode changesBelow of: review.
	self showContentWithComment: topicPresenter.
	self enableCommentOn: aTopic labelled: 'Your comment on the topic'
]

{ #category : 'testing' }
OCRReviewPresenter >> shownKicker [

	^ kickerLabel label
]

{ #category : 'testing' }
OCRReviewPresenter >> shownProgress [

	^ header shownProgress
]

{ #category : 'testing' }
OCRReviewPresenter >> shownTitle [

	^ titleLabel label
]

{ #category : 'testing' }
OCRReviewPresenter >> showsChangeActions [
	"Browse, Edit, Implementors and Senders act on one change, and not while editing."

	^ self isEditing not and: [ self hasSelectedChange ]
]

{ #category : 'testing' }
OCRReviewPresenter >> sidebar [

	^ sidebar
]

{ #category : 'editing' }
OCRReviewPresenter >> startEditing [
	"The editor takes the place of the change, with Save and Cancel above it."

	changeArea startEditing: self selectedChange methodInImage.
	content layout
		removeAll;
		add: editBar expand: false;
		add: changeArea.
	self enableReviewing: false
]

{ #category : 'editing' }
OCRReviewPresenter >> stopEditing [

	changeArea stopEditing.
	self enableReviewing: true.
	self showSelection
]

{ #category : 'actions' }
OCRReviewPresenter >> toggleReviewed [
	"Mark everything under the selection as reviewed, and go to the next change not reviewed; when it already is, unmark it."

	| node changes |
	node := sidebar selectedNode.
	changes := node changesBelow.
	(review areAllReviewed: changes) ifTrue: [ ^ self mark: changes reviewed: false ].
	self mark: changes reviewed: true.
	node hasChange ifTrue: [ self selectNextUnreviewedAfter: node change ]
]

{ #category : 'selection' }
OCRReviewPresenter >> topRowLabels [

	^ sidebar topRowLabels
]

{ #category : 'testing' }
OCRReviewPresenter >> topicPresenter [

	^ topicPresenter
]

{ #category : 'testing' }
OCRReviewPresenter >> typeComment: aString [

	commentPane text: aString
]

{ #category : 'showing' }
OCRReviewPresenter >> updateButtons [
	"The buttons follow the selection and the editing. Spec does not update a button from its action: done here, its label and icon too (Reviewed or Unmark).
	They are never hidden: Morphic does not lay out again a button hidden then shown. Save and Cancel come with the editor (see #startEditing)."

	buttons keysAndValuesDo: [ :action :button |
		button
			label: action dynamicName;
			iconName: action dynamicIconName;
			enabled: action canBeExecuted ].
	moreButton enabled: self showsChangeActions
]

{ #category : 'showing' }
OCRReviewPresenter >> updateHeader [

	header showReview: review
]

{ #category : 'showing' }
OCRReviewPresenter >> updateReviewState [
	"After a mark: the rows, the progress, the Reviewed button and the topic's list change."

	sidebar refreshTrees.
	topicPresenter refresh.
	self updateHeader.
	self updateButtons
]

{ #category : 'accessing' }
OCRReviewPresenter >> windowTitle [

	| title |
	title := 'Obscure Code Reviewer - {1} - base: {2}' format: {
		         review repositoryName.
		         review baseLabel }.
	review hasBaseWarning ifFalse: [ ^ title ].
	^ '{1} - WARNING: {2}' format: {
		  title.
		  review baseWarning }
]
