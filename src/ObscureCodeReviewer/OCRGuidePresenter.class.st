"
I am the editor of the review guide, opened by Edit guide… in the overview of the review window: the guide's Markdown (see OCRGuideParser), an Apply button, and the warnings about the guide.

The agent gives the guide to the window when it opens it (OCRReviewPresenter class>>#onRepositoryNamed:guide:). The user can also paste or edit it here and click Apply: the window then shows the new guide, until it is closed. Guides are not stored anywhere.
"
Class {
	#name : 'OCRGuidePresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'guideText',
		'applyButton',
		'warningsList',
		'applyBlock',
		'warningsLabel'
	],
	#category : 'ObscureCodeReviewer-UI',
	#package : 'ObscureCodeReviewer',
	#tag : 'UI'
}

{ #category : 'layout' }
OCRGuidePresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  spacing: 5;
		  add: guideText;
		  add: (SpBoxLayout newLeftToRight
			   addLast: applyButton expand: false;
			   yourself)
		  expand: false;
		  add: warningsLabel expand: false;
		  add: warningsList height: 120;
		  yourself
]

{ #category : 'initialization' }
OCRGuidePresenter >> initialize [

	super initialize.
	applyBlock := [ :text |  ]
]

{ #category : 'initialization' }
OCRGuidePresenter >> initializePresenters [

	guideText := self newText
		             placeholder: '# Topic title
Why the changes were made.
- MyClass>>#myMethod
- MyClass';
		             yourself.
	applyButton := self newButton
		               label: 'Apply';
		               icon: (self iconNamed: #smallOk);
		               help: 'Use this guide for the Topics view';
		               action: [ applyBlock value: guideText text asString ];
		               yourself.
	warningsLabel := self newLabel label: 'Warnings'.
	warningsList := self newList
]

{ #category : 'api' }
OCRGuidePresenter >> showGuide: aString warnings: someStrings [

	guideText text: aString.
	warningsList items: someStrings
]

{ #category : 'api' }
OCRGuidePresenter >> whenAppliedDo: aBlock [
	"aBlock receives the guide text when the user clicks Apply."

	applyBlock := aBlock
]
