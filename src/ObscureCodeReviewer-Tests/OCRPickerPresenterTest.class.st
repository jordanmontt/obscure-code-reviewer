"
I test OCRPickerPresenter without opening it: it runs in the reviewer's application, and the review it opens shares it.
"
Class {
	#name : 'OCRPickerPresenterTest',
	#superclass : 'OCRTestCase',
	#category : 'ObscureCodeReviewer-Tests',
	#package : 'ObscureCodeReviewer-Tests'
}

{ #category : 'tests' }
OCRPickerPresenterTest >> testTheReviewRunsInThePickerApplication [

	| picker presenter |
	picker := OCRPickerPresenter new.
	presenter := picker presenterOnReview: (self reviewWith: #(  )).

	self assert: (picker application isKindOf: OCRApplication).
	self assert: presenter application identicalTo: picker application
]
