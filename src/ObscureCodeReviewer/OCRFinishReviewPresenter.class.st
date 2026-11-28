"
I am the dialog that ends a review: what the reviewer did, what is not reviewed yet, and the general comment on the whole review. Copy review puts all the comments on the clipboard as Markdown, ready to paste to the agent (see OCRReview>>#feedback). Keep reviewing closes me; the general comment is kept either way.
"
Class {
	#name : 'OCRFinishReviewPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'review',
		'summaryLabel',
		'unreviewedLabel',
		'generalCommentText'
	],
	#category : 'ObscureCodeReviewer-UI',
	#package : 'ObscureCodeReviewer',
	#tag : 'UI'
}

{ #category : 'initialization' }
OCRFinishReviewPresenter >> connectPresenters [

	generalCommentText whenTextChangedDo: [ :text | review generalComment: text asString ]
]

{ #category : 'actions' }
OCRFinishReviewPresenter >> copyReview [

	Clipboard clipboardText: review feedback informing: 'Review copied to the clipboard'
]

{ #category : 'layout' }
OCRFinishReviewPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  spacing: 8;
		  borderWidth: 8;
		  add: summaryLabel expand: false;
		  add: unreviewedLabel expand: false;
		  add: (self newLabel
			   label: 'General comment on the whole review';
			   addStyle: 'ocrMuted';
			   yourself)
		  expand: false;
		  add: generalCommentText;
		  yourself
]

{ #category : 'actions' }
OCRFinishReviewPresenter >> generalComment: aString [
	"Type aString as the general comment."

	generalCommentText text: aString
]

{ #category : 'initialization' }
OCRFinishReviewPresenter >> initializeDialogWindow: aDialogWindowPresenter [

	aDialogWindowPresenter
		addButton: 'Keep reviewing' do: [ :dialog | dialog close ];
		addDefaultButton: 'Copy review' do: [ :dialog |
			self copyReview.
			dialog close ]
]

{ #category : 'initialization' }
OCRFinishReviewPresenter >> initializePresenters [

	summaryLabel := self newLabel
		                addStyle: 'ocrHeading';
		                yourself.
	unreviewedLabel := self newLabel
		                   addStyle: 'ocrWarning';
		                   beWrap;
		                   yourself.
	generalCommentText := (self instantiate: OCRCommentPresenter)
		                      placeholder: 'General comment on the whole review (Markdown)';
		                      yourself.
	self showReview
]

{ #category : 'initialization' }
OCRFinishReviewPresenter >> initializeWindow: aWindowPresenter [

	super initializeWindow: aWindowPresenter.
	aWindowPresenter
		title: 'Finish review';
		initialExtent: 560 @ 420
]

{ #category : 'accessing - model' }
OCRFinishReviewPresenter >> setModelBeforeInitialization: aReview [

	review := aReview
]

{ #category : 'showing' }
OCRFinishReviewPresenter >> showReview [

	summaryLabel label: self summary.
	unreviewedLabel label: self unreviewedText.
	generalCommentText text: review generalComment
]

{ #category : 'showing' }
OCRFinishReviewPresenter >> shownSummary [

	^ summaryLabel label
]

{ #category : 'showing' }
OCRFinishReviewPresenter >> shownUnreviewed [

	^ unreviewedLabel label
]

{ #category : 'showing' }
OCRFinishReviewPresenter >> summary [
	"E.g. '12 of 40 changes reviewed, 5 comments, pull request edited'."

	| comments |
	comments := review commentedReferences size.
	^ String streamContents: [ :stream |
		  stream nextPutAll: ('{1} of {2} changes reviewed, {3} {4}' format: {
			   review reviewedCount.
			   review changes size.
			   comments.
			   ('comment' asPluralBasedOn: comments) }).
		  review isPullRequestEdited ifTrue: [ stream nextPutAll: ', pull request edited' ] ]
]

{ #category : 'showing' }
OCRFinishReviewPresenter >> unreviewedText [

	| count |
	count := review unreviewedChanges size.
	count = 0 ifTrue: [ ^ 'Every change is reviewed.' ].
	^ '{1} not reviewed yet. The agent gets them as a list, and will not assume they are approved.' format: { (count = 1
		   ifTrue: [ '1 change is' ]
		   ifFalse: [ count printString , ' changes are' ]) }
]
