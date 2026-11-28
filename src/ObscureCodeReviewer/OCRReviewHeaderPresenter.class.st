"
I am the top of the review window: the repository, what the image is compared with (with a warning when that base may be wrong), and how many changes are reviewed and commented.
"
Class {
	#name : 'OCRReviewHeaderPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'repositoryLabel',
		'baseLabel',
		'progressLabel',
		'progressBar'
	],
	#category : 'ObscureCodeReviewer-UI',
	#package : 'ObscureCodeReviewer',
	#tag : 'UI'
}

{ #category : 'showing' }
OCRReviewHeaderPresenter >> baseLineOf: aReview [

	aReview hasBaseWarning ifFalse: [ ^ 'compared with ' , aReview baseLabel ].
	^ 'compared with {1}. WARNING: {2}' format: {
		  aReview baseLabel.
		  aReview baseWarning }
]

{ #category : 'layout' }
OCRReviewHeaderPresenter >> defaultLayout [

	^ SpBoxLayout newLeftToRight
		  spacing: 12;
		  vAlignCenter;
		  add: (SpBoxLayout newTopToBottom
			   add: repositoryLabel expand: false;
			   add: baseLabel expand: false;
			   yourself);
		  add: (SpBoxLayout newTopToBottom
			   spacing: 3;
			   add: progressLabel expand: false;
			   add: progressBar expand: false;
			   yourself)
		  width: 230;
		  yourself
]

{ #category : 'initialization' }
OCRReviewHeaderPresenter >> initializePresenters [

	repositoryLabel := self newLabel
		                   addStyle: 'ocrRepository';
		                   yourself.
	baseLabel := self newLabel
		             addStyle: 'ocrMuted';
		             yourself.
	progressLabel := self newLabel
		                 addStyle: 'ocrMuted';
		                 yourself.
	progressBar := self newProgressBar
]

{ #category : 'showing' }
OCRReviewHeaderPresenter >> showReview: aReview [

	| total reviewed comments |
	total := aReview changes size.
	reviewed := aReview reviewedCount.
	comments := aReview commentedReferences size.
	repositoryLabel label: aReview repositoryName.
	baseLabel label: (self baseLineOf: aReview).
	aReview hasBaseWarning ifTrue: [ baseLabel addStyle: 'ocrWarning' ].
	progressLabel label: ('{1} of {2} reviewed, {3} {4}' format: {
		 reviewed.
		 total.
		 comments.
		 ('comment' asPluralBasedOn: comments) }).
	progressBar fixedAt: (total = 0
		 ifTrue: [ 0 ]
		 ifFalse: [ reviewed / total ]) asFloat
]

{ #category : 'showing' }
OCRReviewHeaderPresenter >> shownProgress [

	^ progressLabel label
]
