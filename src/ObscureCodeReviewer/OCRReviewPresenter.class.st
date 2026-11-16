"
I am the review window:
- a toolbar with Refresh, to recompute the changes and keep the comments, and Copy review, to copy all comments as Markdown, ready to paste to the agent,
- a tree of changes on the left,
- a side-by-side diff (base | image) and a comment box for the selected change on the right,
- a general comment at the bottom.

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
		'toolbar'
	],
	#category : 'ObscureCodeReviewer-UI',
	#package : 'ObscureCodeReviewer',
	#tag : 'UI'
}

{ #category : 'instance creation' }
OCRReviewPresenter class >> onRepositoryNamed: aString [

	^ self on: (OCRIcebergReader reviewOfUncommittedChangesInRepositoryNamed: aString)
]

{ #category : 'layout' }
OCRReviewPresenter >> changesLayout [
	"The tree on the left; the diff and the comment of the selected change on the right."

	^ SpPanedLayout newLeftToRight
		  positionOfSlider: 30 percent;
		  add: changesTree;
		  add: (SpPanedLayout newTopToBottom
			   positionOfSlider: 70 percent;
			   add: diff;
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
	generalCommentText whenTextChangedDo: [ :text | review generalComment: text asString ]
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
			   positionOfSlider: 80 percent;
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

	toolbar := self newToolbar
		           addStyle: 'stToolbar';
		           addItem: (self newToolbarButton
			            label: 'Refresh';
			            icon: (self iconNamed: #glamorousRefresh);
			            help: 'Recompute the changes from the image, keeping the comments';
			            action: [ self refresh ];
			            yourself);
		           addItem: (self newToolbarButton
			            label: 'Copy review';
			            icon: (self iconNamed: #smallCopy);
			            help: 'Copy all comments as Markdown, ready to paste to the agent';
			            action: [ self copyReview ];
			            yourself);
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
	"Recompute the changes from the image. The comments are kept; see OCRReview>>#takeCommentsFrom:."

	| newReview |
	newReview := OCRIcebergReader reviewOfUncommittedChangesInRepositoryNamed: review repositoryName.
	newReview takeCommentsFrom: review.
	review := newReview.
	self showReview
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
	self hasSelectedChange
		ifTrue: [ self showChange: self selectedChange ]
		ifFalse: [ self disableComment ]
]

{ #category : 'displaying' }
OCRReviewPresenter >> windowTitle [

	^ 'Obscure Code Reviewer - ' , review repositoryName , ' - base: ' , review baseLabel
]
