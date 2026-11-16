"
I show a changed Markdown file (an OCRMarkdownFileChange): rendered with Microdown, the base commit on the left and the disk on the right, or, with Source, the text diff that shows exactly which lines changed.

The choice stays while the reviewer moves from one Markdown file to another.
"
Class {
	#name : 'OCRMarkdownFilePresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'renderedButton',
		'sourceButton',
		'basePresenter',
		'diskPresenter',
		'diff'
	],
	#category : 'ObscureCodeReviewer-UI',
	#package : 'ObscureCodeReviewer',
	#tag : 'UI'
}

{ #category : 'initialization' }
OCRMarkdownFilePresenter >> connectPresenters [

	renderedButton whenChangedDo: [ self showLayout ]
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
	basePresenter := self instantiate: MicrodownPresenter.
	diskPresenter := self instantiate: MicrodownPresenter.
	diff := self newDiff
		        showOptions: false;
		        leftLabel: 'Base';
		        rightLabel: 'Disk';
		        yourself.
	self showLayout
]

{ #category : 'showing' }
OCRMarkdownFilePresenter >> renderedLayout [

	^ SpBoxLayout newLeftToRight
		  spacing: 10;
		  add: (self rendering: basePresenter titled: 'Base');
		  add: (self rendering: diskPresenter titled: 'Disk');
		  yourself
]

{ #category : 'showing' }
OCRMarkdownFilePresenter >> rendering: aMicrodownPresenter titled: aString [

	^ SpBoxLayout newTopToBottom
		  add: (self newLabel label: aString) expand: false;
		  add: aMicrodownPresenter;
		  yourself
]

{ #category : 'showing' }
OCRMarkdownFilePresenter >> showFrom: anOldSource to: aNewSource [

	basePresenter documentFromString: anOldSource.
	diskPresenter documentFromString: aNewSource.
	diff
		leftText: '';
		rightText: ''.
	diff
		leftText: anOldSource;
		rightText: aNewSource
]

{ #category : 'showing' }
OCRMarkdownFilePresenter >> showLayout [

	self layout: (SpBoxLayout newTopToBottom
		 spacing: 5;
		 add: (SpBoxLayout newLeftToRight
			  spacing: 10;
			  add: renderedButton expand: false;
			  add: sourceButton expand: false;
			  yourself)
		 expand: false;
		 add: (renderedButton state
			  ifTrue: [ self renderedLayout ]
			  ifFalse: [ diff ]);
		 yourself)
]
