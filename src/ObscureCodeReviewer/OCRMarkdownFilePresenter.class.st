"
I show a changed Markdown file (an OCRMarkdownFileChange): by default, with Rendered, the file rendered with Microdown, the base commit on the left and the disk on the right; with Source, the text diff that shows exactly which lines changed.

An added or removed file has one side only: I show that side alone, titled Added or Removed, rendered or as source.

I render only when Rendered is shown. When Microdown fails on a file (e.g. inline code holding only a number, pillar-markup/Microdown#1114), I show its source instead, and say why above it.

The choice stays while the reviewer moves from one Markdown file to another.
"
Class {
	#name : 'OCRMarkdownFilePresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'renderedButton',
		'sourceButton',
		'diff',
		'aloneText',
		'aloneTitle',
		'isAlone',
		'baseSource',
		'diskSource'
	],
	#category : 'ObscureCodeReviewer-UI',
	#package : 'ObscureCodeReviewer',
	#tag : 'UI'
}

{ #category : 'showing' }
OCRMarkdownFilePresenter >> beRendered [

	renderedButton state: true
]

{ #category : 'showing' }
OCRMarkdownFilePresenter >> beSource [

	sourceButton state: true
]

{ #category : 'initialization' }
OCRMarkdownFilePresenter >> connectPresenters [

	sourceButton whenChangedDo: [ self showLayout ]
]

{ #category : 'initialization' }
OCRMarkdownFilePresenter >> initializePresenters [

	renderedButton := self newRadioButton
		                  label: 'Rendered';
		                  yourself.
	sourceButton := self newRadioButton
		                label: 'Source';
		                yourself.
	renderedButton associatedRadioButtons: { sourceButton }.
	renderedButton state: true.

	diff := self newDiff
		        showOptions: false;
		        leftLabel: 'Base';
		        rightLabel: 'Disk';
		        yourself.
	aloneText := self newCode
		             beNotEditable;
		             withoutSyntaxHighlight;
		             yourself.
	aloneTitle := ''.
	baseSource := ''.
	diskSource := ''.
	isAlone := false.
	self showLayout
]

{ #category : 'testing' }
OCRMarkdownFilePresenter >> isShowingDiff [

	^ self layout allPresenters includes: diff
]

{ #category : 'showing' }
OCRMarkdownFilePresenter >> layoutOf: aPresenter titled: aString [

	^ SpBoxLayout newTopToBottom
		  add: (self newLabel label: aString) expand: false;
		  add: aPresenter;
		  yourself
]

{ #category : 'showing' }
OCRMarkdownFilePresenter >> renderedLayout [
	"Microdown fails on some files; the reviewer then reads the source, and why it is not rendered."

	| titledTexts |
	titledTexts := [ self renderedTexts ]
		               on: Error
		               do: [ :error | ^ self unrenderedLayoutBecause: error ].
	^ titledTexts
		  inject: (SpBoxLayout newLeftToRight
			   spacing: 10;
			   yourself)
		  into: [ :sides :each |
			  sides
				  add: (self layoutOf: (self richTextPresenterOn: each value) titled: each key);
				  yourself ]
]

{ #category : 'rendering' }
OCRMarkdownFilePresenter >> renderedTexts [
	"Title -> rich text, for each side shown. Composed here, not in a MicrodownPresenter, whose Morphic adapter composes when it builds its widget, where #renderedLayout could not catch a Microdown error."

	isAlone ifTrue: [ ^ { (aloneTitle -> (Microdown asRichText: diskSource)) } ].
	^ {
		  ('Base' -> (Microdown asRichText: baseSource)).
		  ('Disk' -> (Microdown asRichText: diskSource)) }
]

{ #category : 'showing' }
OCRMarkdownFilePresenter >> richTextPresenterOn: aText [

	^ (self instantiate: MicTextPresenter)
		  text: aText;
		  yourself
]

{ #category : 'showing' }
OCRMarkdownFilePresenter >> show: aSource aloneTitled: aTitle [
	"An added or removed file has one side only, so it is shown alone, as an added or removed method is."

	isAlone := true.
	aloneTitle := aTitle.
	diskSource := aSource.
	aloneText text: aSource.
	self showLayout
]

{ #category : 'showing' }
OCRMarkdownFilePresenter >> showFrom: anOldSource to: aNewSource [

	isAlone := false.
	baseSource := anOldSource.
	diskSource := aNewSource.
	diff
		leftText: '';
		rightText: ''.
	diff
		leftText: anOldSource;
		rightText: aNewSource.
	self showLayout
]

{ #category : 'showing' }
OCRMarkdownFilePresenter >> showLayout [
	"Read the Source button: it is the one #connectPresenters listens to, and the other one may not have changed yet."

	self layout: (SpBoxLayout newTopToBottom
		 spacing: 5;
		 add: (SpBoxLayout newLeftToRight
			  spacing: 10;
			  add: renderedButton expand: false;
			  add: sourceButton expand: false;
			  yourself)
		 expand: false;
		 add: (sourceButton state
			  ifTrue: [ self sourceLayout ]
			  ifFalse: [ self renderedLayout ]);
		 yourself)
]

{ #category : 'showing' }
OCRMarkdownFilePresenter >> sourceLayout [

	^ isAlone
		  ifTrue: [ self layoutOf: aloneText titled: aloneTitle ]
		  ifFalse: [ diff ]
]

{ #category : 'showing' }
OCRMarkdownFilePresenter >> unrenderedLayoutBecause: anError [

	^ SpBoxLayout newTopToBottom
		  spacing: 5;
		  add: (self newLabel label: ('Could not render with Microdown ({1}): showing the source.' format: { anError description }))
		  expand: false;
		  add: self sourceLayout;
		  yourself
]
