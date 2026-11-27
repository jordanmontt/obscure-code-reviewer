"
I am the right side of the review window, and the whole of the window that opens when a change is double-clicked. I show one of:
- the diff of the selected change (base | image), with what the guide says about it above;
- an added or removed change alone, in one read-only code pane, as it has one side only (see #showSource:titled:of:);
- a Markdown file, rendered or as a diff (see OCRMarkdownFilePresenter);
- a binary file (see OCRBinaryFilePresenter);
- the explanation of the selected topic;
- the code editor, while the reviewer edits a method by hand (see #startEditing:).
"
Class {
	#name : 'OCRChangeAreaPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'diff',
		'editor',
		'topicText',
		'binaryFilePresenter',
		'isEditing',
		'markdownPresenter',
		'sourceText',
		'sourceTitle',
		'notesLabel'
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
	topicText := self newText
		             beNotEditable;
		             yourself.
	notesLabel := self newLabel
		              beWrap;
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

	self layout
		removeAll;
		add: aPresenter
]

{ #category : 'showing' }
OCRChangeAreaPresenter >> showBinaryFile: aBinaryFileChange [

	binaryFilePresenter showFile: aBinaryFileChange.
	self layout add: binaryFilePresenter
]

{ #category : 'showing' }
OCRChangeAreaPresenter >> showChange: aChange comparedWith: aBaseSource notes: aString [
	"aString is what the guide says about the change alone; it goes above the change, on as many lines as it needs."

	self layout removeAll.
	aString ifNotEmpty: [
		notesLabel label: aString.
		self layout add: notesLabel expand: false ].
	aChange showContentsIn: self comparedWith: aBaseSource
]

{ #category : 'showing' }
OCRChangeAreaPresenter >> showDiffFrom: anOldSource to: aNewSource [
	"Both sides are cleared first, as Iceberg does, so the diff never mixes two changes."

	self layout add: diff.
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
	self layout add: markdownPresenter
]

{ #category : 'showing' }
OCRChangeAreaPresenter >> showMarkdownFrom: anOldSource to: aNewSource [

	markdownPresenter showFrom: anOldSource to: aNewSource.
	self layout add: markdownPresenter
]

{ #category : 'showing' }
OCRChangeAreaPresenter >> showNothing [

	self show: diff.
	diff
		leftText: '';
		rightText: ''
]

{ #category : 'showing' }
OCRChangeAreaPresenter >> showSource: aString titled: aTitle of: aChange [
	"A new code presenter each time: aChange sets how it highlights (see OCRChange>>#styleSource:), and that setting would stay for the next change.
	The title and the code are added one by one: Spec cannot add a layout to the layout of an open window, only presenters."

	sourceTitle := self newLabel
		               label: aTitle;
		               yourself.
	sourceText := self newCode
		              beNotEditable;
		              yourself.
	aChange styleSource: sourceText.
	sourceText text: aString.
	self layout
		add: sourceTitle expand: false;
		add: sourceText
]

{ #category : 'showing' }
OCRChangeAreaPresenter >> showTopic: aTopic [

	topicText text: aTopic explanation.
	self show: topicText
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

{ #category : 'editing' }
OCRChangeAreaPresenter >> startEditing: aMethod [

	editor
		beForMethod: aMethod;
		text: aMethod sourceCode.
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
