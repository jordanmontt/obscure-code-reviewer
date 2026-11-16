"
I am the Guide tab of the review window: the review guide's Markdown (see OCRGuideParser), an Apply button, and the warnings about the guide.

The agent usually stores the guide through the MCP (OCRReviewGuide class>>#forRepositoryNamed:put:), and it shows up here. The user can also paste or edit it and click Apply.
"
Class {
	#name : 'OCRGuidePresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'guideText',
		'applyButton',
		'warningsList',
		'applyBlock'
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
		  add: 'Warnings' expand: false;
		  add: warningsList height: 120;
		  yourself
]

{ #category : 'initialization' }
OCRGuidePresenter >> initialize [

	applyBlock := [ :text |  ].
	super initialize
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
		               help: 'Use this guide for the Topics tab';
		               action: [ applyBlock value: guideText text asString ];
		               yourself.
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
