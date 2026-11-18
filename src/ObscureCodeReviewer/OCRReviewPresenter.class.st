"
I am the review window:
- a toolbar (OCRReviewToolbar);
- on the left, the Structure, Topics, Guide and Pull request tabs (OCRReviewTabsPresenter);
- on the right, the selected change (OCRChangeAreaPresenter): its diff, a binary file, a topic's explanation, or the code editor while editing; below it, the comment on the selected change or topic;
- a general comment at the bottom.

While editing, the tabs are disabled: Save or Cancel first. Saving refreshes the review.

	(OCRReviewPresenter onRepositoryNamed: 'my-project') open
"
Class {
	#name : 'OCRReviewPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'review',
		'toolbar',
		'tabs',
		'changeArea',
		'commentText',
		'generalCommentText'
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
OCRReviewPresenter >> applyGuide: aString [
	"Show the review with this guide. Refresh keeps it; nothing else does: it lives as long as the window."

	self refreshWithGuide: (OCRReviewGuide fromText: aString)
]

{ #category : 'actions' }
OCRReviewPresenter >> browseSelection [

	self selectedChange browse
]

{ #category : 'testing' }
OCRReviewPresenter >> canBrowseSelection [

	^ self hasSelectedChange and: [ self selectedChange isInImage ]
]

{ #category : 'testing' }
OCRReviewPresenter >> canEditSelection [

	^ self hasSelectedChange and: [ self selectedChange isEditable ]
]

{ #category : 'selection' }
OCRReviewPresenter >> canMarkSelection [

	tabs isSelectionEmpty ifTrue: [ ^ false ].
	^ tabs selectedNode changesBelow isNotEmpty
]

{ #category : 'layout' }
OCRReviewPresenter >> changesLayout [
	"The tabs on the left; the change (or the editor, or a topic's explanation) and its comment on the right."

	^ SpPanedLayout newLeftToRight
		  positionOfSlider: 22 percent;
		  add: tabs;
		  add: (SpPanedLayout newTopToBottom
			   positionOfSlider: 80 percent;
			   add: changeArea;
			   add: commentText;
			   yourself);
		  yourself
]

{ #category : 'actions' }
OCRReviewPresenter >> commentChanged: aString [

	self hasSelectedCommentable ifFalse: [ ^ self ].
	review comment: aString on: self selectedCommentable.
	tabs refreshTrees
]

{ #category : 'initialization' }
OCRReviewPresenter >> connectPresenters [

	tabs whenSelectionChangedDo: [ self showSelection ].
	tabs whenChangeActivatedDo: [ :change | self openChangeInWindow: change ].
	tabs whenGuideAppliedDo: [ :text | self applyGuide: text ].
	tabs whenPullRequestChangedDo: [ :pullRequest | review pullRequest: pullRequest ].
	changeArea whenSaveRequestedDo: [ self saveEdit ].
	commentText whenTextChangedDo: [ :text | self commentChanged: text asString ].
	generalCommentText whenTextChangedDo: [ :text | review generalComment: text asString ].
	toolbar updateButtons
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

{ #category : 'editing' }
OCRReviewPresenter >> enableReviewing: aBoolean [
	"While editing, only Save and Cancel are possible."

	tabs enableSelecting: aBoolean.
	toolbar updateButtons
]

{ #category : 'selection' }
OCRReviewPresenter >> hasSelectedChange [
	"Nothing selected, or a section, package, topic or unchanged class selected, means no change to show."

	tabs isSelectionEmpty ifTrue: [ ^ false ].
	^ tabs selectedNode hasChange
]

{ #category : 'selection' }
OCRReviewPresenter >> hasSelectedCommentable [

	tabs isSelectionEmpty ifTrue: [ ^ false ].
	^ tabs selectedNode isCommentable
]

{ #category : 'initialization' }
OCRReviewPresenter >> initializePresenters [

	toolbar := self instantiate: OCRReviewToolbar on: self.
	tabs := self instantiate: OCRReviewTabsPresenter on: review.
	changeArea := self instantiate: OCRChangeAreaPresenter.
	commentText := self newCommentPane
		               placeholder: 'Comment on the selected change or topic';
		               enabled: false;
		               yourself.
	generalCommentText := self newCommentPane
		                      placeholder: 'General comment on the whole review';
		                      yourself
]

{ #category : 'initialization' }
OCRReviewPresenter >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		title: self windowTitle;
		initialExtent: 1100 @ 700
]

{ #category : 'editing' }
OCRReviewPresenter >> isEditing [

	^ changeArea isEditing
]

{ #category : 'selection' }
OCRReviewPresenter >> isSelectionReviewed [

	^ self canMarkSelection and: [ review areAllReviewed: tabs selectedNode changesBelow ]
]

{ #category : 'initialization' }
OCRReviewPresenter >> newCommentPane [
	"A comment is text, but a code pane gives it Code search (implementors, senders) on what the reviewer selects. Without highlighting, line numbers or smart characters, it reads and types as plain text."

	^ self newCode
		  withoutSyntaxHighlight;
		  withoutLineNumbers;
		  withoutSmartCharacters;
		  yourself
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

{ #category : 'actions' }
OCRReviewPresenter >> recomputedReview [
	"The review recomputed from the image against the same base, without the reviewer's work yet."

	^ OCRIcebergReader reviewOfRepositoryNamed: review repositoryName against: review base
]

{ #category : 'actions' }
OCRReviewPresenter >> refresh [
	"Recompute the changes from the image, with the same guide. The comments are kept (see OCRReview>>#takeCommentsFrom:),
	and so is the selected change or topic when it is still there."

	self refreshWithGuide: review guide
]

{ #category : 'actions' }
OCRReviewPresenter >> refreshWithGuide: aGuide [
	"Recompute the changes from the image and show them with aGuide. The comments are kept (see OCRReview>>#takeCommentsFrom:),
	and so is the selected change or topic when it is still there."

	self hasSelectedCommentable ifFalse: [ ^ self reloadReviewWithGuide: aGuide ].
	self reloadReviewWithGuide: aGuide selecting: self selectedCommentable reference
]

{ #category : 'actions' }
OCRReviewPresenter >> reloadReviewWithGuide: aGuide [
	"Recompute the review against the same base, with aGuide, keeping what the reviewer did."

	| newReview |
	newReview := self recomputedReview.
	newReview guide: aGuide.
	newReview continueFrom: review.
	review := newReview.
	self showReview
]

{ #category : 'actions' }
OCRReviewPresenter >> reloadReviewWithGuide: aGuide selecting: aReference [

	self reloadReviewWithGuide: aGuide.
	tabs selectItemReferenced: aReference
]

{ #category : 'editing' }
OCRReviewPresenter >> saveEdit [
	"When the method does not compile, the editor shows the error and we stay in it."

	(changeArea compileEditOf: self selectedChange) ifFalse: [ ^ self ].
	self stopEditing.
	self refresh
]

{ #category : 'selection' }
OCRReviewPresenter >> selectedChange [
	"Only valid when #hasSelectedChange is true."

	^ tabs selectedNode change
]

{ #category : 'selection' }
OCRReviewPresenter >> selectedCommentable [
	"A change or a topic. Only valid when #hasSelectedCommentable is true."

	^ tabs selectedNode commentable
]

{ #category : 'accessing - model' }
OCRReviewPresenter >> setModelBeforeInitialization: aReview [

	review := aReview
]

{ #category : 'showing' }
OCRReviewPresenter >> showChange: aChange [

	changeArea showChange: aChange comparedWith: (review baseSourceOf: aChange) notes: (review notesAbout: aChange).
	self enableCommentOn: aChange
]

{ #category : 'showing' }
OCRReviewPresenter >> showNothing [

	changeArea showNothing.
	self disableComment
]

{ #category : 'showing' }
OCRReviewPresenter >> showReview [

	tabs showReview: review.
	generalCommentText text: review generalComment.
	self withWindowDo: [ :window | window title: self windowTitle ]
]

{ #category : 'showing' }
OCRReviewPresenter >> showSelection [

	toolbar updateButtons.
	tabs isSelectionEmpty ifTrue: [ ^ self showNothing ].
	tabs selectedNode showIn: self
]

{ #category : 'showing' }
OCRReviewPresenter >> showTopic: aTopic [

	changeArea showTopic: aTopic.
	self enableCommentOn: aTopic
]

{ #category : 'editing' }
OCRReviewPresenter >> startEditing [

	changeArea startEditing: self selectedChange methodInImage.
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
	"Mark everything under the selection as reviewed; when it already is, unmark it."

	| changes |
	changes := tabs selectedNode changesBelow.
	(review areAllReviewed: changes)
		ifTrue: [ changes do: [ :each | review unmarkReviewed: each ] ]
		ifFalse: [ changes do: [ :each | review markReviewed: each ] ].
	tabs refreshTrees.
	toolbar updateButtons
]

{ #category : 'accessing' }
OCRReviewPresenter >> windowTitle [

	^ 'Obscure Code Reviewer - {1} - base: {2}' format: {
		  review repositoryName.
		  review baseLabel }
]
