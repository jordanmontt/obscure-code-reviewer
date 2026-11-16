"
I am the review window:
- a tree of changes on the left,
- a side-by-side diff (base | image) and a comment box for the selected change on the right,
- a general comment at the bottom,
- a button to copy all comments as Markdown, ready to paste to the agent.

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
		'copyButton'
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
		  add: (SpBoxLayout newLeftToRight
			   add: copyButton expand: false;
			   yourself)
		  expand: false;
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

	copyButton := self newButton
		              label: 'Copy review';
		              icon: (self iconNamed: #smallCopy);
		              help: 'Copy all comments as Markdown, ready to paste to the agent';
		              action: [ self copyReview ];
		              yourself.
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
OCRReviewPresenter >> initializeWindow: aWindowPresenter [

	aWindowPresenter
		title: 'Obscure Code Reviewer - ' , review repositoryName , ' - base: ' , review baseLabel;
		initialExtent: 1100 @ 700
]

{ #category : 'displaying' }
OCRReviewPresenter >> labelFor: aNode [
	"Commented changes are marked, so the reviewer sees what is already done."

	(aNode hasChange and: [ review hasCommentOn: aNode change ]) ifTrue: [ ^ aNode label , '   [commented]' ].
	^ aNode label
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
OCRReviewPresenter >> showSelection [
	"Both diff sides are cleared first, as Iceberg does, so the diff never mixes two changes."

	diff
		leftText: '';
		rightText: ''.
	self hasSelectedChange
		ifTrue: [ self showChange: self selectedChange ]
		ifFalse: [ self disableComment ]
]
