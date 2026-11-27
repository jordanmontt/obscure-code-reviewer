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
		  reviewBase: (OCRReviewBase base: OCRLastCommitBase new commitId: 'abc1234')
		  changes: #(  )
]

{ #category : 'helpers' }
OCRReviewPresenterTest >> reviewWithEditableMethod [

	^ OCRReview
		  repositoryName: 'my-project'
		  reviewBase: (OCRReviewBase base: OCRLastCommitBase new commitId: 'abc1234')
		  changes: { (OCRMethodChangeStub modification
			   packageName: 'MyPackage';
			   className: 'OCRReviewPresenterTest';
			   selector: #emptyReview;
			   yourself) }
]

{ #category : 'helpers' }
OCRReviewPresenterTest >> reviewWithMethod: aSelector [

	^ OCRReview
		  repositoryName: 'my-project'
		  reviewBase: (OCRReviewBase base: OCRLastCommitBase new commitId: 'abc1234')
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
OCRReviewPresenterTest >> testANewReviewKeepsTheSelectionInTheStructureTab [
	"Showing a new review resets both trees; clearing the Topics tree must not move the selection there."

	| tabs |
	tabs := OCRReviewTabsPresenter on: (self reviewWithMethod: #a).
	tabs whenSelectionChangedDo: [ ].
	tabs selectItemReferenced: 'OCRReviewPresenterTest>>#a'.

	tabs showReview: (self reviewWithMethod: #a).
	tabs selectItemReferenced: 'OCRReviewPresenterTest>>#a'.

	self assert: tabs isSelectingInStructure
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testATreeLabelIsTheNodeAndItsMarks [
	"No line count: only what the node is, and whether it is reviewed or commented."

	| review |
	review := OCRReview
		          repositoryName: 'my-project'
		          reviewBase: (OCRReviewBase base: OCRLastCommitBase new commitId: 'abc1234')
		          changes: { (OCRMethodChange modification
			           packageName: 'MyPackage';
			           className: 'OCRReviewPresenterTest';
			           selector: #a;
			           oldSource: 'a ^ 1';
			           newSource: 'a ^ 2';
			           yourself) }.

	self assert: ((OCRReviewTabsPresenter on: review) labelFor: review structuralTree first) equals: 'Code'
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
OCRReviewPresenterTest >> testSavingAnEditKeepsTheSelection [

	| presenter |
	presenter := OCRReviewPresenterStub on: self reviewWithEditableMethod.
	presenter nextReview: self reviewWithEditableMethod.
	presenter reloadReviewWithGuide: OCRReviewGuide empty selecting: 'OCRReviewPresenterTest>>#emptyReview'.
	presenter startEditing.

	presenter saveEdit.

	self assert: presenter hasSelectedChange.
	self assert: presenter selectedChange reference equals: 'OCRReviewPresenterTest>>#emptyReview'
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
OCRReviewPresenterTest >> testTheTitleHasNoWarningWhenTheBaseIsUpToDate [

	self
		assert: (OCRReviewPresenter on: self emptyReview) windowTitle
		equals: 'Obscure Code Reviewer - my-project - base: abc1234 (last commit)'
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testTheTitleWarnsWhenTheBaseIsStale [
	"The local main is behind its upstream: a split from it shows what the upstream already merged."

	| review |
	review := OCRReview
		          repositoryName: 'my-project'
		          reviewBase: (OCRReviewBase
			           base: (OCRSplitBase fromBranchNamed: 'main')
			           commitId: 'd274ab5'
			           warning: 'main (d274ab5) is behind origin/main (ae02d54)')
		          changes: #(  ).

	self
		assert: (OCRReviewPresenter on: review) windowTitle
		equals:
		'Obscure Code Reviewer - my-project - base: d274ab5 (split from main) - WARNING: main (d274ab5) is behind origin/main (ae02d54)'
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testTheWindowRunsInTheReviewerApplication [

	| presenter |
	presenter := OCRReviewPresenter on: self emptyReview.

	self assert: (presenter application isKindOf: OCRApplication)
]
