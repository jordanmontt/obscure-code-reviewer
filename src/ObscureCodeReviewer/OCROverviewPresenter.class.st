"
I am the overview of a review, shown when the Overview row is selected: the pull request the changes will become, which the reviewer can edit; how much of each topic is reviewed; the warnings about the review guide, with a button to edit the guide; and what the image is compared with.
"
Class {
	#name : 'OCROverviewPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'review',
		'pullRequestPresenter',
		'topicsTable',
		'warningsLabel',
		'editGuideButton',
		'baseLabel',
		'guideAppliedBlock'
	],
	#category : 'ObscureCodeReviewer-UI',
	#package : 'ObscureCodeReviewer',
	#tag : 'UI'
}

{ #category : 'layout' }
OCROverviewPresenter >> defaultLayout [

	^ SpPanedLayout newLeftToRight
		  positionOfSlider: 62 percent;
		  add: (SpBoxLayout newTopToBottom
			   spacing: 6;
			   add: (self heading: 'Pull request') expand: false;
			   add: (self mutedLabel: 'Drafted by the agent. Your edits go into the copied review.') expand: false;
			   add: pullRequestPresenter;
			   yourself);
		  add: (SpBoxLayout newTopToBottom
			   spacing: 6;
			   add: (self heading: 'Progress by topic') expand: false;
			   add: topicsTable;
			   add: (self heading: 'Review guide') expand: false;
			   add: warningsLabel expand: false;
			   add: (SpBoxLayout newLeftToRight
				    add: editGuideButton expand: false;
				    yourself)
			   expand: false;
			   add: (self mutedLabel: 'The guide lives as long as this window. Refresh keeps it.') expand: false;
			   add: (self heading: 'Base') expand: false;
			   add: baseLabel expand: false;
			   yourself);
		  yourself
]

{ #category : 'initialization' }
OCROverviewPresenter >> heading: aString [

	^ self newLabel
		  label: aString;
		  addStyle: 'ocrHeading';
		  yourself
]

{ #category : 'initialization' }
OCROverviewPresenter >> initialize [

	super initialize.
	guideAppliedBlock := [ :text |  ]
]

{ #category : 'initialization' }
OCROverviewPresenter >> initializePresenters [

	pullRequestPresenter := self instantiate: OCRPullRequestPresenter.
	topicsTable := self newTable
		               addColumn: (SpStringTableColumn title: 'Topic' evaluated: [ :node | node name ]);
		               addColumn: ((SpStringTableColumn title: 'Reviewed' evaluated: [ :node | self progressOf: node ])
			                width: 70;
			                displayAlignment: [ :node | SpColumnAlignment right ];
			                yourself);
		               yourself.
	warningsLabel := self newLabel
		                 beWrap;
		                 yourself.
	editGuideButton := self newButton
		                   label: 'Edit guide…';
		                   help: 'Paste or edit the review guide, then apply it to the Topics view';
		                   action: [ self openGuideEditor ];
		                   yourself.
	baseLabel := self newLabel
		             beWrap;
		             yourself
]

{ #category : 'initialization' }
OCROverviewPresenter >> mutedLabel: aString [

	^ self newLabel
		  label: aString;
		  addStyle: 'ocrMuted';
		  beWrap;
		  yourself
]

{ #category : 'actions' }
OCROverviewPresenter >> newGuideEditor [
	"The guide, its Apply button and its warnings. Applying closes the editor's window."

	^ (self instantiate: OCRGuidePresenter)
		  showGuide: review guide text warnings: review guideWarnings;
		  yourself
]

{ #category : 'actions' }
OCROverviewPresenter >> openGuideEditor [

	| editor window |
	editor := self newGuideEditor.
	window := editor asWindow
		          title: 'Review guide';
		          initialExtent: 700 @ 600;
		          yourself.
	editor whenAppliedDo: [ :text |
		window close.
		guideAppliedBlock value: text ].
	window open
]

{ #category : 'showing' }
OCROverviewPresenter >> progressOf: aNode [

	| changes |
	changes := aNode changesBelow.
	^ '{1} / {2}' format: {
		  (changes count: [ :each | review isReviewed: each ]).
		  changes size }
]

{ #category : 'showing' }
OCROverviewPresenter >> showReview: aReview [

	review := aReview.
	pullRequestPresenter showPullRequest: review pullRequest.
	topicsTable items: review topicTree asArray.
	warningsLabel label: self warningsText.
	baseLabel label: review baseLabel
]

{ #category : 'showing' }
OCROverviewPresenter >> shownTopicProgress [
	"Each topic shown, with how much of it is reviewed, e.g. 'Parse faster 1 / 3'."

	^ topicsTable items
		  collect: [ :each |
			  '{1} {2}' format: {
				  each name.
				  (self progressOf: each) } ]
		  as: Array
]

{ #category : 'showing' }
OCROverviewPresenter >> shownWarnings [

	^ warningsLabel label
]

{ #category : 'showing' }
OCROverviewPresenter >> warningsText [

	| warnings |
	warnings := review guideWarnings.
	warnings ifEmpty: [ ^ 'No warnings.' ].
	^ String streamContents: [ :stream |
		  stream nextPutAll: (warnings size = 1
			   ifTrue: [ '1 warning:' ]
			   ifFalse: [ warnings size printString , ' warnings:' ]).
		  warnings do: [ :each |
			  stream
				  cr;
				  nextPutAll: '- ';
				  nextPutAll: each ] ]
]

{ #category : 'events' }
OCROverviewPresenter >> whenGuideAppliedDo: aBlock [
	"aBlock receives the guide text when the reviewer applies an edited guide."

	guideAppliedBlock := aBlock
]

{ #category : 'events' }
OCROverviewPresenter >> whenPullRequestChangedDo: aBlock [
	"aBlock receives the OCRPullRequest the reviewer edited."

	pullRequestPresenter whenPullRequestChangedDo: aBlock
]
