"
I am the right side of the review window. I show one of:
- the diff of the selected change (base | image), with what the guide says about it above;
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
		'notesText',
		'binaryFilePresenter',
		'isEditing',
		'markdownPresenter'
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
	editor := self newCode.
	topicText := self newText
		             beNotEditable;
		             yourself.
	notesText := self newText
		             beNotEditable;
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
	"aString is what the guide says about the change alone; it goes above the change."

	self layout removeAll.
	aString ifNotEmpty: [
		notesText text: aString.
		self layout add: notesText height: 50 ].
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
OCRChangeAreaPresenter >> showTopic: aTopic [

	topicText text: aTopic explanation.
	self show: topicText
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
