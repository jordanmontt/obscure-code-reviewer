"
I test OCRReviewPresenter without opening it: the guide is the one the review comes with, never a stored one.
"
Class {
	#name : 'OCRReviewPresenterTest',
	#superclass : 'TestCase',
	#category : 'ObscureCodeReviewer-Tests',
	#package : 'ObscureCodeReviewer-Tests'
}

{ #category : 'helpers' }
OCRReviewPresenterTest >> emptyReview [

	^ OCRReview
		  repositoryName: 'my-project'
		  base: OCRLastCommitBase new
		  baseLabel: 'abc1234 (last commit)'
		  changes: #(  )
]

{ #category : 'helpers' }
OCRReviewPresenterTest >> reviewWithMethod: aSelector [

	^ OCRReview
		  repositoryName: 'my-project'
		  base: OCRLastCommitBase new
		  baseLabel: 'abc1234 (last commit)'
		  changes: { (OCRMethodChange modification
			   packageName: 'MyPackage';
			   className: 'OCRReviewPresenterTest';
			   selector: aSelector;
			   yourself) }
]

{ #category : 'helpers' }
OCRReviewPresenterTest >> shortcutOf: aPresenter keyed: aKeyCombination [

	^ aPresenter actions allCommands detect: [ :each | each shortcutKey = aKeyCombination ]
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testApplyKeepsTheReviewerEditsOfThePullRequest [

	| review presenter next |
	review := self emptyReview
		          guide: (OCRReviewGuide fromText: 'Title: Draft');
		          yourself.
	presenter := OCRReviewPresenterStub on: review.
	review pullRequest: (OCRPullRequest title: 'Mine' body: '').
	next := self emptyReview.
	presenter nextReview: next.

	presenter applyGuide: 'Title: New draft'.

	self assert: next pullRequest title equals: 'Mine'
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testApplyShowsTheNewGuide [

	| presenter next |
	presenter := OCRReviewPresenterStub on: (self emptyReview
		              guide: (OCRReviewGuide fromText: '# Parse faster');
		              yourself).
	next := self emptyReview.
	presenter nextReview: next.

	presenter applyGuide: '# Clean up'.

	self assert: (next guide topics collect: [ :each | each title ] as: Array) equals: #( 'Clean up' )
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testCommentPanesOfferImplementorsAndSenders [
	"A reviewer selects a selector in a comment and looks it up, as in a code pane."

	| pane names |
	pane := (OCRReviewPresenter on: self emptyReview) newCommentPane.

	names := pane rootCommandsGroup allCommands collect: [ :each | each name ].

	self assert: (names includes: 'Implementors of it').
	self assert: (names includes: 'Senders of it')
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testEachReviewHasItsOwnApplication [

	self
		deny: (OCRReviewPresenter on: self emptyReview) application
		identicalTo: (OCRReviewPresenter on: self emptyReview) application
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testEscapeCancelsOnlyWhileEditing [

	| presenter |
	presenter := OCRReviewPresenter on: self emptyReview.

	self deny: (self shortcutOf: presenter keyed: Character escape asKeyCombination) canBeExecuted
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testImplementorsAndSendersOfASelectedMethod [

	| presenter |
	presenter := OCRReviewPresenterStub on: (self reviewWithMethod: #a).
	presenter nextReview: (self reviewWithMethod: #a).

	presenter reloadReviewWithGuide: OCRReviewGuide empty selecting: 'OCRReviewPresenterTest>>#a'.

	self assert: (self shortcutOf: presenter keyed: $m actionModifier) canBeExecuted.
	self assert: (self shortcutOf: presenter keyed: $n actionModifier) canBeExecuted
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testRefreshKeepsTheGuide [

	| guide presenter next |
	guide := OCRReviewGuide fromText: '# Parse faster'.
	presenter := OCRReviewPresenterStub on: (self emptyReview
		              guide: guide;
		              yourself).
	next := self emptyReview.
	presenter nextReview: next.

	presenter refresh.

	self assert: next guide identicalTo: guide
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testShortcutsAreDisabledLikeTheirButtonsWhenNothingIsSelected [
	"Cmd+R marks as reviewed, Cmd+B browses, Cmd+E edits, Cmd+M and Cmd+N browse implementors and senders: they need a selection."

	| presenter |
	presenter := OCRReviewPresenter on: self emptyReview.

	{
		$r actionModifier.
		$b actionModifier.
		$e actionModifier.
		$m actionModifier.
		$n actionModifier } do: [ :each | self deny: (self shortcutOf: presenter keyed: each) canBeExecuted ]
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testTheActionsAreInTheMenuExceptEscape [
	"The trees show the window's actions in their right-click menu, each with its key."

	| presenter visible |
	presenter := OCRReviewPresenter on: self emptyReview.

	visible := presenter actions allCommands select: [ :each | each isVisible ] thenCollect: [ :each | each shortcutKey ].

	self assert: visible asSet equals: {
		$r actionModifier.
		$b actionModifier.
		$e actionModifier.
		$m actionModifier.
		$n actionModifier } asSet
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testTheGuideIsTheOneOfTheReview [

	| review guide |
	guide := OCRReviewGuide fromText: '# Parse faster'.
	review := self emptyReview
		          guide: guide;
		          yourself.

	OCRReviewPresenter on: review.

	self assert: review guide identicalTo: guide
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testTheMenuItemsHaveTheIconsOfTheirButtons [
	"Implementors and senders have the magnifier of the System Browser's code menu."

	| presenter |
	presenter := OCRReviewPresenter on: self emptyReview.

	{
		($r actionModifier -> #smallOk).
		($b actionModifier -> #glamorousBrowse).
		($e actionModifier -> #edit).
		($m actionModifier -> #smallFind).
		($n actionModifier -> #smallFind) } do: [ :each |
		self assert: (self shortcutOf: presenter keyed: each key) iconName equals: each value ]
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testTheWindowRunsInTheReviewerApplication [

	| presenter |
	presenter := OCRReviewPresenter on: self emptyReview.

	self assert: (presenter application isKindOf: OCRApplication)
]
