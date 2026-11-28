"
I test the review window as a reviewer uses it, through OCRReviewDriver, without opening it: what can be clicked, selected, commented and refreshed, not where it sits. The guide is the one the review comes with, never a stored one.
"
Class {
	#name : 'OCRReviewPresenterTest',
	#superclass : 'OCRTestCase',
	#category : 'ObscureCodeReviewer-Tests',
	#package : 'ObscureCodeReviewer-Tests'
}

{ #category : 'helpers' }
OCRReviewPresenterTest >> driverOnEditableMethod [
	"A window whose selection is a modified method of this class, which can be marked, browsed and edited."

	^ (OCRReviewDriver on: self reviewWithEditableMethod)
		  click: 'OCRReviewPresenterTest>>#emptyReview';
		  yourself
]

{ #category : 'helpers' }
OCRReviewPresenterTest >> emptyReview [

	^ self reviewWith: #(  )
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
	"A method of this class, so implementors and senders find it."

	^ self reviewWith: { (self methodChange: aSelector class: 'OCRReviewPresenterTest') }
]

{ #category : 'helpers' }
OCRReviewPresenterTest >> reviewWithMethods: someSelectors [
	"Methods of this class, in this order in the tree."

	^ self reviewWith: (someSelectors collect: [ :each | self methodChange: each class: 'OCRReviewPresenterTest' ])
]

{ #category : 'helpers' }
OCRReviewPresenterTest >> reviewWithTopic [

	^ self reviewWith: { (self methodChange: #a class: 'OCRReviewPresenterTest') } guide: '# Parse faster
The stream was re-scanned.
- OCRReviewPresenterTest>>#a'
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testAChangeIsTitledWithItsReferenceUnderItsGroups [

	| driver |
	driver := OCRReviewDriver on: (self reviewWithMethods: #( #a )).

	driver click: 'OCRReviewPresenterTest>>#a'.

	self assert: driver shownTitle equals: 'OCRReviewPresenterTest>>#a'.
	self assert: driver shownKicker equals: 'Code › MyProject › OCRReviewPresenterTest'
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testARefreshKeepsTheSelectionInTheFilesView [
	"A refresh resets both views; resetting the topics view must not move the selection there."

	| driver |
	driver := OCRReviewDriver on: (self reviewWithMethod: #a).
	driver click: 'OCRReviewPresenterTest>>#a'.
	driver nextReview: (self reviewWithMethod: #a).

	driver refresh.

	self assert: driver isSelectingInFiles.
	self assert: driver selectedChangeReference equals: 'OCRReviewPresenterTest>>#a'
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testASelectedMethodCanBeMarkedBrowsedAndEdited [

	self
		assert: self driverOnEditableMethod enabledActions
		equals: #( 'Browse' 'Edit' 'Finish review' 'Implementors' 'Refresh' 'Review all' 'Reviewed' 'Senders' )
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testATopicShowsWhyAndItsChanges [

	| driver |
	driver := OCRReviewDriver on: self reviewWithTopic.
	driver showTopicsView.

	driver click: 'Topic: Parse faster'.

	self assert: driver shownTitle equals: 'Parse faster'.
	self assert: driver shownTopicExplanation equals: 'The stream was re-scanned.'.
	self assert: driver shownTopicChanges equals: #( 'OCRReviewPresenterTest>>#a' )
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testATreeLabelIsTheNodeAndItsMarks [
	"No line count: only what the node is. Whether it is reviewed or commented has its own columns."

	self
		assert: (OCRReviewDriver on: (self reviewWith: { (self methodChange: #a class: 'MyClass') })) topRowLabels
		equals: #( 'Overview' 'Code' )
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testApplyKeepsTheReviewerEditsOfThePullRequest [

	| review driver next |
	review := self emptyReview
		          guide: (OCRReviewGuide fromText: 'Title: Draft');
		          yourself.
	driver := OCRReviewDriver on: review.
	review pullRequest: (OCRPullRequest title: 'Mine' body: '').
	next := self emptyReview.
	driver nextReview: next.

	driver applyGuide: 'Title: New draft'.

	self assert: next pullRequest title equals: 'Mine'
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testApplyShowsTheNewGuide [

	| driver next |
	driver := OCRReviewDriver on: (self emptyReview
		           guide: (OCRReviewGuide fromText: '# Parse faster');
		           yourself).
	next := self emptyReview.
	driver nextReview: next.

	driver applyGuide: '# Clean up'.

	self assert: (next guide topics collect: [ :each | each title ] as: Array) equals: #( 'Clean up' )
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testClickingARowAfterSelectAllSelectsOnlyIt [

	| driver |
	driver := OCRReviewDriver on: (self reviewWithMethods: #( #a #b )).
	driver press: $a actionModifier.

	driver click: 'OCRReviewPresenterTest>>#b'.

	self assert: driver selectedChangeReference equals: 'OCRReviewPresenterTest>>#b'
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testCommentPanesOfferImplementorsAndSenders [
	"A reviewer selects a selector in a comment and looks it up, as in a code pane."

	| names |
	names := (OCRReviewDriver on: self emptyReview) commentMenuItemNames.

	self assert: (names includes: 'Implementors of it').
	self assert: (names includes: 'Senders of it')
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testEachReviewHasItsOwnApplication [

	self deny: (OCRReviewDriver on: self emptyReview) application identicalTo: (OCRReviewDriver on: self emptyReview) application
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testEscapeCancelsOnlyWhileEditing [

	self deny: ((OCRReviewDriver on: self emptyReview) canPress: Character escape asKeyCombination)
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testFinishingSaysWhatIsNotReviewedYet [

	| review dialog |
	review := self reviewWithMethods: #( #a #b ).
	review markReviewed: review changes first.

	dialog := (OCRReviewDriver on: review) finishDialog.

	self assert: dialog shownSummary equals: '1 of 2 changes reviewed, 0 comments'.
	self assert: (dialog shownUnreviewed beginsWith: '1 change is not reviewed yet')
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testImplementorsAndSendersOfASelectedMethod [

	| driver |
	driver := OCRReviewDriver on: (self reviewWithMethod: #a).

	driver click: 'OCRReviewPresenterTest>>#a'.

	self assert: (driver canPress: $m actionModifier).
	self assert: (driver canPress: $n actionModifier)
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testNothingSelectedShowsNothingToComment [

	| driver |
	driver := OCRReviewDriver on: self emptyReview.

	self deny: driver isShowingAChange.
	self deny: driver canComment
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testRefreshKeepsTheGuide [

	| guide driver next |
	guide := OCRReviewGuide fromText: '# Parse faster'.
	driver := OCRReviewDriver on: (self emptyReview
		           guide: guide;
		           yourself).
	next := self emptyReview.
	driver nextReview: next.

	driver refresh.

	self assert: next guide identicalTo: guide
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testRefreshUpdatesTheWindowTitle [
	"After new commits, a refresh compares with another base commit: the title says so."

	| driver |
	driver := OCRReviewDriver on: self emptyReview.
	driver windowTitle.
	driver nextReview:
		(OCRReview
			 repositoryName: 'my-project'
			 reviewBase: (OCRReviewBase base: OCRLastCommitBase new commitId: 'def5678')
			 changes: #(  )).

	driver refresh.

	self assert: driver windowTitle equals: 'Obscure Code Reviewer - my-project - base: def5678 (last commit)'
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testReviewAllMarksEveryChange [

	| review driver |
	review := self reviewWithMethods: #( #a #b ).
	driver := OCRReviewDriver on: review.

	driver do: 'Review all'.

	self assert: review reviewedCount equals: 2.
	self deny: (driver enabledActions includes: 'Review all')
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testReviewedGoesToTheNextChangeNotReviewed [

	| review driver |
	review := self reviewWithMethods: #( #a #b #c ).
	review markReviewed: review changes second.
	driver := OCRReviewDriver on: review.
	driver click: 'OCRReviewPresenterTest>>#a'.

	driver do: 'Reviewed'.

	self assert: driver selectedChangeReference equals: 'OCRReviewPresenterTest>>#c'
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testReviewedStaysWhenEverythingIsReviewed [

	| driver |
	driver := OCRReviewDriver on: (self reviewWithMethods: #( #a )).
	driver click: 'OCRReviewPresenterTest>>#a'.

	driver do: 'Reviewed'.

	self assert: driver selectedChangeReference equals: 'OCRReviewPresenterTest>>#a'
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testSavingAnEditKeepsTheSelection [

	| driver |
	driver := self driverOnEditableMethod.
	driver do: 'Edit'.

	driver do: 'Save'.

	self assert: driver selectedChangeReference equals: 'OCRReviewPresenterTest>>#emptyReview'
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testSelectAllThenReviewedMarksEveryChange [

	| review driver |
	review := self reviewWithMethods: #( #a #b ).
	driver := OCRReviewDriver on: review.

	driver press: $a actionModifier.
	driver do: 'Reviewed'.

	self assert: review reviewedCount equals: 2
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testSelectingSeveralRowsSaysHowManyChanges [

	| driver |
	driver := OCRReviewDriver on: (self reviewWithMethods: #( #a #b )).

	driver press: $a actionModifier.

	self assert: driver shownTitle equals: '2 changes selected'.
	self deny: driver canComment
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testShortcutsAreDisabledLikeTheirButtonsWhenNothingIsSelected [
	"Cmd+R marks as reviewed, Cmd+B browses, Cmd+E edits, Cmd+M and Cmd+N browse implementors and senders: they need a selection."

	| driver |
	driver := OCRReviewDriver on: self emptyReview.

	{
		$r actionModifier.
		$b actionModifier.
		$e actionModifier.
		$m actionModifier.
		$n actionModifier } do: [ :each | self deny: (driver canPress: each) ]
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testTheActionsAreInTheMenuExceptEscape [
	"The changes show the window's actions in their right-click menu, each with its key."

	self assert: (OCRReviewDriver on: self emptyReview) menuShortcuts equals: {
		$r actionModifier.
		$a actionModifier.
		$b actionModifier.
		$e actionModifier.
		$m actionModifier.
		$n actionModifier } asSet
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testTheGeneralCommentWrittenWhenFinishingIsInTheCopiedReview [

	| review |
	review := self reviewWithMethods: #( #a ).

	(OCRReviewDriver on: review) finishWithGeneralComment: 'Looks good'.

	self assert: (review feedback includesSubstring: 'Looks good')
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testTheGuideIsTheOneOfTheReview [

	| review guide |
	guide := OCRReviewGuide fromText: '# Parse faster'.
	review := self emptyReview
		          guide: guide;
		          yourself.

	OCRReviewDriver on: review.

	self assert: review guide identicalTo: guide
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testTheHeaderCountsReviewedChangesAndComments [

	| driver |
	driver := OCRReviewDriver on: (self reviewWithMethods: #( #a #b )).
	driver click: 'OCRReviewPresenterTest>>#a'.

	driver comment: 'Why?'.
	driver do: 'Reviewed'.

	self assert: driver shownProgress equals: '1 of 2 reviewed, 1 comment'
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testTheMenuItemsHaveTheIconsOfTheirButtons [
	"Implementors and senders have the magnifier of the System Browser's code menu."

	| driver |
	driver := OCRReviewDriver on: self emptyReview.

	{
		($r actionModifier -> #smallOk).
		($b actionModifier -> #glamorousBrowse).
		($e actionModifier -> #edit).
		($m actionModifier -> #smallFind).
		($n actionModifier -> #smallFind) } do: [ :each | self assert: (driver iconOfShortcut: each key) equals: each value ]
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testTheOverviewShowsHowMuchOfEachTopicIsReviewed [

	| review driver |
	review := self reviewWithTopic.
	review markReviewed: review changes first.

	driver := OCRReviewDriver on: review.

	self assert: driver shownTitle equals: 'Overview'.
	self assert: driver overviewTopicProgress equals: #( 'Parse faster 1 / 1' ).
	self assert: driver overviewWarnings equals: 'No warnings.'
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testTheReviewedButtonUnmarksAReviewedSelection [

	| driver |
	driver := self driverOnEditableMethod.

	driver do: 'Reviewed'.

	self assert: driver enabledActions equals: #( 'Browse' 'Edit' 'Finish review' 'Implementors' 'Refresh' 'Senders' 'Unmark' )
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testTheTitleHasNoWarningWhenTheBaseIsUpToDate [

	self
		assert: (OCRReviewDriver on: self emptyReview) windowTitle
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
		assert: (OCRReviewDriver on: review) windowTitle
		equals:
		'Obscure Code Reviewer - my-project - base: d274ab5 (split from main) - WARNING: main (d274ab5) is behind origin/main (ae02d54)'
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testTheWindowOffersTheActionsOfTheReview [

	self
		assert: (OCRReviewDriver on: self emptyReview) actionsOnScreen
		equals: #( 'Browse' 'Cancel' 'Edit' 'Finish review' 'Implementors' 'Refresh' 'Review all' 'Reviewed' 'Save' 'Senders' )
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testTheWindowRunsInTheReviewerApplication [

	self assert: ((OCRReviewDriver on: self emptyReview) application isKindOf: OCRApplication)
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testTheWindowTitleNamesTheRepositoryAndTheBase [

	self
		assert: (OCRReviewPresenter on: self emptyReview) asWindow title
		equals: 'Obscure Code Reviewer - my-project - base: abc1234 (last commit)'
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testTickingAGroupMarksEverythingInIt [

	| review |
	review := self reviewWithMethods: #( #a #b ).

	(OCRReviewDriver on: review) tick: 'Code'.

	self assert: review reviewedCount equals: 2
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testUnmarkHasTheUndoIcon [

	| driver |
	driver := self driverOnEditableMethod.
	self assert: (driver iconOfButton: 'Reviewed') equals: #smallOk.

	driver do: 'Reviewed'.

	self assert: (driver iconOfButton: 'Unmark') equals: #smallUndo
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testWhileEditingOnlySaveCancelAndFinishAreEnabled [

	| driver |
	driver := self driverOnEditableMethod.

	driver do: 'Edit'.

	self assert: driver enabledActions equals: #( 'Cancel' 'Finish review' 'Save' )
]

{ #category : 'tests' }
OCRReviewPresenterTest >> testWithoutSelectionOnlyRefreshAndFinishAreEnabled [

	self assert: (OCRReviewDriver on: self emptyReview) enabledActions equals: #( 'Finish review' 'Refresh' )
]
