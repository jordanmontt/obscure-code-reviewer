"
I am the review window: a tree of changes on the left and a side-by-side diff (base | image) on the right.

	(OCRReviewPresenter onRepositoryNamed: 'my-project') open
"
Class {
	#name : 'OCRReviewPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'review',
		'changesTree',
		'diff'
	],
	#category : 'ObscureCodeReviewer-UI',
	#package : 'ObscureCodeReviewer',
	#tag : 'UI'
}

{ #category : 'instance creation' }
OCRReviewPresenter class >> onRepositoryNamed: aString [

	^ self on: (OCRIcebergReader reviewOfUncommittedChangesInRepositoryNamed: aString)
]

{ #category : 'initialization' }
OCRReviewPresenter >> connectPresenters [

	changesTree whenSelectedItemChangedDo: [ :node | self showChangeOf: node ]
]

{ #category : 'layout' }
OCRReviewPresenter >> defaultLayout [

	^ SpPanedLayout newLeftToRight
		  positionOfSlider: 30 percent;
		  add: changesTree;
		  add: diff;
		  yourself
]

{ #category : 'initialization' }
OCRReviewPresenter >> initializePresenters [

	changesTree := self newTree
		               roots: review structuralTree;
		               children: [ :node | node children ];
		               display: [ :node | node label ];
		               expandAll;
		               yourself.
	diff := self newDiff
		        showOptions: false;
		        leftLabel: 'Base';
		        rightLabel: 'Image';
		        yourself
]

{ #category : 'initialization' }
OCRReviewPresenter >> initializeWindow: aWindowPresenter [

	aWindowPresenter
		title: 'Obscure Code Reviewer - ' , review repositoryName , ' - base: ' , review baseLabel;
		initialExtent: 1100 @ 700
]

{ #category : 'initialization' }
OCRReviewPresenter >> setModelBeforeInitialization: aReview [

	review := aReview
]

{ #category : 'actions' }
OCRReviewPresenter >> showChangeOf: aNode [
	"Both sides are cleared first, as Iceberg does, so the diff never mixes two changes."

	diff
		leftText: '';
		rightText: ''.
	(aNode notNil and: [ aNode hasChange ]) ifFalse: [ ^ self ].
	diff
		leftText: aNode change oldSource;
		rightText: aNode change newSource
]
