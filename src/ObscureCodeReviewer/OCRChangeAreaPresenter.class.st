"
I am the change selected in the review window, and the whole of the window that opens when a change is double-clicked. I show one of:
- the diff of the selected change (base | image), with what the guide says about it in a strip above;
- an added or removed change alone, in one read-only code pane, as it has one side only (see #showSource:titled:of:);
- a Markdown file, rendered or as a diff (see OCRMarkdownFilePresenter);
- a binary file (see OCRBinaryFilePresenter);
- the code editor, while the reviewer edits a method by hand (see #startEditing:).
"
Class {
	#name : 'OCRChangeAreaPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'diff',
		'editor',
		'binaryFilePresenter',
		'isEditing',
		'markdownPresenter',
		'sourceText',
		'sourceTitle',
		'notesLabel',
		'sourceTitleStrip',
		'messageLabel'
	],
	#category : 'ObscureCodeReviewer-UI',
	#package : 'ObscureCodeReviewer',
	#tag : 'UI'
}

{ #category : 'editing' }
OCRChangeAreaPresenter >> compileEditOf: aMethodChange [
	"Answer whether the edited source compiled; when it did not, the editor shows the error."

	^ aMethodChange compileInImage: editor text asString notifying: editor interactionModel
]

{ #category : 'initialization' }
OCRChangeAreaPresenter >> initializePresenters [

	diff := self newDiff
		        showOptions: false;
		        leftLabel: 'Base';
		        rightLabel: 'Image';
		        yourself.
	sourceText := self newCode.
	editor := self newCode.
	notesLabel := self newLabel
		              addStyle: 'ocrNote';
		              beWrap;
		              yourself.
	messageLabel := self newLabel
		                addStyle: 'ocrMuted';
		                yourself.
	binaryFilePresenter := self instantiate: OCRBinaryFilePresenter.
	markdownPresenter := self instantiate: OCRMarkdownFilePresenter.
	isEditing := false.
	self layout: (SpBoxLayout newTopToBottom
		 add: diff;
		 yourself)
]

{ #category : 'editing' }
OCRChangeAreaPresenter >> isEditing [

	^ isEditing
]

{ #category : 'testing' }
OCRChangeAreaPresenter >> isShowingDiff [

	^ self layout presenters includes: diff
]

{ #category : 'testing' }
OCRChangeAreaPresenter >> markdownPresenter [

	^ markdownPresenter
]

{ #category : 'showing' }
OCRChangeAreaPresenter >> show: aPresenter [

	self showPresenters: { aPresenter }
]

{ #category : 'showing' }
OCRChangeAreaPresenter >> showBinaryFile: aBinaryFileChange [

	binaryFilePresenter showFile: aBinaryFileChange.
	self show: binaryFilePresenter
]

{ #category : 'showing' }
OCRChangeAreaPresenter >> showChange: aChange comparedWith: aBaseSource notes: aString [
	"aString is what the guide says about the change alone; it goes above the change, tinted, on as many lines as it needs."

	notesLabel label: aString.
	aChange showContentsIn: self comparedWith: aBaseSource
]

{ #category : 'showing' }
OCRChangeAreaPresenter >> showDiffFrom: anOldSource to: aNewSource [
	"Both sides are cleared first, as Iceberg does, so the diff never mixes two changes."

	self show: diff.
	diff
		leftText: '';
		rightText: ''.
	diff
		leftText: anOldSource;
		rightText: aNewSource
]

{ #category : 'showing' }
OCRChangeAreaPresenter >> showMarkdown: aSource aloneTitled: aTitle [

	markdownPresenter show: aSource aloneTitled: aTitle.
	self show: markdownPresenter
]

{ #category : 'showing' }
OCRChangeAreaPresenter >> showMarkdownFrom: anOldSource to: aNewSource [

	markdownPresenter showFrom: anOldSource to: aNewSource.
	self show: markdownPresenter
]

{ #category : 'showing' }
OCRChangeAreaPresenter >> showMessage: aString [
	"Nothing to compare: a group, several rows, or nothing selected."

	notesLabel label: ''.
	messageLabel label: aString.
	self show: messageLabel
]

{ #category : 'showing' }
OCRChangeAreaPresenter >> showNothing [

	self showMessage: 'Select a change to see what changed.'
]

{ #category : 'showing' }
OCRChangeAreaPresenter >> showPresenters: somePresenters [
	"Show somePresenters, below the notes when the guide has some. The children are replaced only when they change: a change of the same kind as the one shown only changes texts. Adding a presenter again to an open window builds its widget again (see SpBoxLayout>>#ocrRemoveAll)."

	| wanted |
	wanted := notesLabel label isEmpty
		          ifTrue: [ somePresenters asArray ]
		          ifFalse: [ { notesLabel } , somePresenters ].
	self layout children asArray = wanted ifTrue: [ ^ self ].
	self layout ocrRemoveAll.
	wanted do: [ :each |
		(each == notesLabel or: [ each == sourceTitleStrip ])
			ifTrue: [ self layout add: each expand: false ]
			ifFalse: [ self layout add: each ] ]
]

{ #category : 'showing' }
OCRChangeAreaPresenter >> showSource: aString titled: aTitle of: aChange [
	"A new code presenter each time: aChange sets how it highlights (see OCRChange>>#styleSource:), and that setting would stay for the next change.
	The title and the code are added one by one: Spec cannot add a layout to the layout of an open window, only presenters.
	The title sits in a strip styled like the header of a diff (see OCRStyleContributor), so both views look the same. Its margin is a padding: the style's border replaces the layout's borderWidth."

	sourceTitle := self newLabel
		               label: aTitle;
		               yourself.
	sourceTitleStrip := self newPresenter
		                    addStyle: 'ocrSourceTitle';
		                    layout: (SpBoxLayout newLeftToRight
			                     add: sourceTitle
			                     expand: true
			                     fill: true
			                     padding: 5;
			                     yourself);
		                    yourself.
	sourceText := self newCode
		              beNotEditable;
		              yourself.
	aChange styleSource: sourceText.
	sourceText text: aString.
	self showPresenters: {
		sourceTitleStrip.
		sourceText }
]

{ #category : 'testing' }
OCRChangeAreaPresenter >> shownNotes [
	"What the guide says about the change shown, above it."

	^ notesLabel label
]

{ #category : 'testing' }
OCRChangeAreaPresenter >> shownSource [
	"The source shown alone, for an added or removed change."

	^ sourceText text asString
]

{ #category : 'testing' }
OCRChangeAreaPresenter >> shownSourceTitle [
	"The title of the source shown alone, for an added or removed change."

	^ sourceTitle label
]

{ #category : 'testing' }
OCRChangeAreaPresenter >> shownSourceTitleStyles [
	"The styles of the strip around the title of the source shown alone."

	^ sourceTitleStrip styles
]

{ #category : 'editing' }
OCRChangeAreaPresenter >> startEditing: aMethod [

	editor
		beForMethod: aMethod;
		text: aMethod sourceCode.
	notesLabel label: ''.
	self show: editor.
	isEditing := true
]

{ #category : 'editing' }
OCRChangeAreaPresenter >> stopEditing [

	isEditing := false
]

{ #category : 'editing' }
OCRChangeAreaPresenter >> whenSaveRequestedDo: aBlock [
	"aBlock is evaluated when the reviewer presses Cmd+S in the editor."

	editor whenSubmitDo: [ :text | aBlock value ]
]

{ #category : 'testing' }
OCRChangeAreaPresenter >> wrapsNotes [

	^ notesLabel isWrap
]
