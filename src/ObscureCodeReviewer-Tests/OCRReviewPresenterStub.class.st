"
I am a review window that recomputes its review without Iceberg: Refresh and Apply get the review a test gave me (nextReview:), so they can be tested in memory.
"
Class {
	#name : 'OCRReviewPresenterStub',
	#superclass : 'OCRReviewPresenter',
	#instVars : [
		'nextReview'
	],
	#category : 'ObscureCodeReviewer-Tests',
	#package : 'ObscureCodeReviewer-Tests'
}

{ #category : 'accessing' }
OCRReviewPresenterStub >> nextReview: aReview [
	"The review Refresh and Apply recompute."

	nextReview := aReview
]

{ #category : 'accessing' }
OCRReviewPresenterStub >> recomputedReview [

	^ nextReview
]
