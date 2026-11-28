"
I show the topic selected in the review window: why the agent made its changes, then the changes, each with what the guide says about it and whether it is reviewed or commented. Double-clicking a change (or Enter) selects it.
"
Class {
	#name : 'OCRTopicPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'review',
		'whyLabel',
		'changesTable'
	],
	#category : 'ObscureCodeReviewer-UI',
	#package : 'ObscureCodeReviewer',
	#tag : 'UI'
}

{ #category : 'layout' }
OCRTopicPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  spacing: 8;
		  add: whyLabel expand: false;
		  add: (self newLabel
			   label: 'Changes in this topic';
			   addStyle: 'ocrHeading';
			   yourself)
		  expand: false;
		  add: changesTable;
		  yourself
]

{ #category : 'initialization' }
OCRTopicPresenter >> initializePresenters [

	whyLabel := self newLabel
		            addStyle: 'ocrNote';
		            beWrap;
		            yourself.
	changesTable := self newTable
		                addColumn: self kindColumn;
		                addColumn: ((SpStringTableColumn title: 'Change' evaluated: [ :change | change reference ])
			                 width: 260;
			                 yourself);
		                addColumn: (SpStringTableColumn title: 'Note' evaluated: [ :change | review notesAbout: change ]);
		                addColumn: self stateColumn;
		                yourself
]

{ #category : 'initialization' }
OCRTopicPresenter >> kindColumn [

	^ (SpStringTableColumn title: '' evaluated: [ :change | change kindLetter ])
		  width: 20;
		  displayBold: [ :change | true ];
		  displayColor: [ :change | change kindColorIn: self theme ];
		  yourself
]

{ #category : 'showing' }
OCRTopicPresenter >> refresh [
	"After a mark or a comment: the states change, the changes do not."

	changesTable items: changesTable items
]

{ #category : 'showing' }
OCRTopicPresenter >> showTopic: aTopic changes: someChanges of: aReview [

	review := aReview.
	whyLabel label: aTopic explanation.
	changesTable items: someChanges asArray
]

{ #category : 'showing' }
OCRTopicPresenter >> shownChanges [

	^ changesTable items
]

{ #category : 'showing' }
OCRTopicPresenter >> shownExplanation [

	^ whyLabel label
]

{ #category : 'initialization' }
OCRTopicPresenter >> stateColumn [

	^ (SpStringTableColumn title: '' evaluated: [ :change | self stateOf: change ])
		  width: 80;
		  displayColor: [ :change | self theme ghostTextColor ];
		  yourself
]

{ #category : 'showing' }
OCRTopicPresenter >> stateOf: aChange [

	(review isReviewed: aChange) ifTrue: [ ^ 'reviewed' ].
	(review hasCommentOn: aChange) ifTrue: [ ^ 'commented' ].
	^ ''
]

{ #category : 'events' }
OCRTopicPresenter >> whenChangeActivatedDo: aBlock [
	"aBlock receives the change double-clicked, or chosen with Enter."

	changesTable whenActivatedDo: [ :selection | selection selectedItem ifNotNil: [ :change | aBlock value: change ] ]
]
