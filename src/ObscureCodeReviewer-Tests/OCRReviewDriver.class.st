"
I drive a review window the way a reviewer does: select a change, run an action by the name on its button, comment, read what is shown. The tests of the window talk to me, not to its presenters, so a change of layout changes me and not them.

The window is never opened. Refresh and Apply get the review given with #nextReview: (see OCRReviewPresenterStub).
"
Class {
	#name : 'OCRReviewDriver',
	#superclass : 'Object',
	#instVars : [
		'presenter',
		'window'
	],
	#category : 'ObscureCodeReviewer-Tests',
	#package : 'ObscureCodeReviewer-Tests'
}

{ #category : 'instance creation' }
OCRReviewDriver class >> on: aReview [

	^ self new setReview: aReview
]

{ #category : 'actions' }
OCRReviewDriver >> actionNamed: aString [
	"The action whose button reads aString now, or read it before (Reviewed reads Unmark once reviewed)."

	^ presenter actionsOnScreen detect: [ :each | each name = aString or: [ each dynamicName = aString ] ]
]

{ #category : 'actions' }
OCRReviewDriver >> actionsOnScreen [
	"The names of all the buttons and menu items, enabled or not, sorted."

	^ (presenter actionsOnScreen collect: [ :each | each name ] as: Array) sort
]

{ #category : 'accessing' }
OCRReviewDriver >> application [

	^ presenter application
]

{ #category : 'actions' }
OCRReviewDriver >> applyGuide: aString [
	"Paste aString as the guide and apply it."

	presenter applyGuide: aString
]

{ #category : 'selecting' }
OCRReviewDriver >> canComment [
	"Whether the comment pane takes a comment on the selection."

	^ presenter hasSelectedCommentable
]

{ #category : 'actions' }
OCRReviewDriver >> canPress: aKeyCombination [

	^ (self shortcutKeyed: aKeyCombination) canBeExecuted
]

{ #category : 'selecting' }
OCRReviewDriver >> click: aReference [
	"Click the row of the change or topic written aReference, e.g. 'MyClass>>#myMethod'."

	presenter selectItemReferenced: aReference
]

{ #category : 'selecting' }
OCRReviewDriver >> comment: aString [
	"Type aString in the comment pane of the selection."

	presenter typeComment: aString
]

{ #category : 'accessing' }
OCRReviewDriver >> commentMenuItemNames [
	"The names in the right-click menu of a comment pane."

	^ presenter newCommentPane rootCommandsGroup allCommands collect: [ :each | each name ]
]

{ #category : 'actions' }
OCRReviewDriver >> do: anActionName [
	"Click the button, or the menu item, named anActionName. As for a reviewer, it must be shown and enabled."

	| action |
	action := self actionNamed: anActionName.
	(action isVisible and: [ action canBeExecuted ]) ifFalse: [ self error: anActionName , ' cannot be clicked' ].
	action execute
]

{ #category : 'actions' }
OCRReviewDriver >> enabledActions [
	"The names of the buttons and menu items the reviewer sees and can click now, sorted: where they sit is the layout's business."

	^ ((presenter actionsOnScreen select: [ :each | each isVisible and: [ each canBeExecuted ] ])
		   collect: [ :each | each dynamicName ]
		   as: Array) sort
]

{ #category : 'actions' }
OCRReviewDriver >> finishDialog [
	"The Finish review dialog, as the button opens it, without opening it."

	^ presenter newFinishReview
]

{ #category : 'actions' }
OCRReviewDriver >> finishWithGeneralComment: aString [
	"Click Finish review and type aString as the general comment."

	self finishDialog generalComment: aString
]

{ #category : 'reading' }
OCRReviewDriver >> iconOfButton: anActionName [
	"The name of the icon the button or menu item reading anActionName shows now."

	^ (self actionNamed: anActionName) dynamicIconName
]

{ #category : 'actions' }
OCRReviewDriver >> iconOfShortcut: aKeyCombination [

	^ (self shortcutKeyed: aKeyCombination) iconName
]

{ #category : 'selecting' }
OCRReviewDriver >> isSelectingInFiles [
	"Whether the selection is the one of the files view, not of the topics view."

	^ presenter isSelectingInFiles
]

{ #category : 'selecting' }
OCRReviewDriver >> isShowingAChange [

	^ presenter hasSelectedChange
]

{ #category : 'actions' }
OCRReviewDriver >> menuShortcuts [
	"The keys of the actions in the right-click menu of the changes."

	^ (presenter actions allCommands select: [ :each | each isVisible ] thenCollect: [ :each | each shortcutKey ]) asSet
]

{ #category : 'accessing' }
OCRReviewDriver >> nextReview: aReview [
	"The review Refresh and Apply recompute from the image."

	presenter nextReview: aReview
]

{ #category : 'reading' }
OCRReviewDriver >> overviewTopicProgress [

	^ presenter overview shownTopicProgress
]

{ #category : 'reading' }
OCRReviewDriver >> overviewWarnings [

	^ presenter overview shownWarnings
]

{ #category : 'actions' }
OCRReviewDriver >> press: aKeyCombination [
	"Press a shortcut of the window, with a row of the tree focused. As for a reviewer, nothing happens when it does not apply."

	| shortcut |
	shortcut := self shortcutKeyed: aKeyCombination.
	shortcut canBeExecuted ifTrue: [ shortcut execute ]
]

{ #category : 'actions' }
OCRReviewDriver >> refresh [

	presenter refresh
]

{ #category : 'selecting' }
OCRReviewDriver >> selectedChangeReference [

	presenter hasSelectedChange ifFalse: [ self error: 'No change is selected' ].
	^ presenter selectedChange reference
]

{ #category : 'initialization' }
OCRReviewDriver >> setReview: aReview [

	presenter := OCRReviewPresenterStub on: aReview.
	presenter nextReview: aReview
]

{ #category : 'actions' }
OCRReviewDriver >> shortcutKeyed: aKeyCombination [

	^ presenter actions allCommands detect: [ :each | each shortcutKey = aKeyCombination ]
]

{ #category : 'selecting' }
OCRReviewDriver >> showTopicsView [

	presenter sidebar showTopics
]

{ #category : 'reading' }
OCRReviewDriver >> shownKicker [
	"The groups above the selection, e.g. 'Code › MyPackage › MyClass'."

	^ presenter shownKicker
]

{ #category : 'reading' }
OCRReviewDriver >> shownProgress [

	^ presenter shownProgress
]

{ #category : 'reading' }
OCRReviewDriver >> shownTitle [

	^ presenter shownTitle
]

{ #category : 'reading' }
OCRReviewDriver >> shownTopicChanges [

	^ presenter topicPresenter shownChanges collect: [ :each | each reference ] as: Array
]

{ #category : 'reading' }
OCRReviewDriver >> shownTopicExplanation [

	^ presenter topicPresenter shownExplanation
]

{ #category : 'selecting' }
OCRReviewDriver >> tick: aRowName [
	"Click the reviewed checkbox of the row named aRowName."

	presenter sidebar tickRowNamed: aRowName
]

{ #category : 'selecting' }
OCRReviewDriver >> topRowLabels [
	"The labels of the top rows of the files view, as the reviewer reads them."

	^ presenter topRowLabels
]

{ #category : 'accessing' }
OCRReviewDriver >> windowTitle [
	"The title of the window, built once as when it opens: a refresh must update it."

	window ifNil: [ window := presenter asWindow ].
	^ window title
]
