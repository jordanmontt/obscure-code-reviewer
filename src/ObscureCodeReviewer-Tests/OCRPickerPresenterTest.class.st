"
I test OCRPickerPresenter without opening it: it runs in the reviewer's application, and the review it opens shares it.
"
Class {
	#name : 'OCRPickerPresenterTest',
	#superclass : 'TestCase',
	#category : 'ObscureCodeReviewer-Tests',
	#package : 'ObscureCodeReviewer-Tests'
}

{ #category : 'tests' }
OCRPickerPresenterTest >> testTheReviewRunsInThePickerApplication [

	| picker presenter |
	picker := OCRPickerPresenter new.
	presenter := picker presenterOnReview: (OCRReview
		              repositoryName: 'my-project'
		              base: OCRLastCommitBase new
		              baseLabel: 'abc1234 (last commit)'
		              changes: #(  )).

	self assert: (picker application isKindOf: OCRApplication).
	self assert: presenter application identicalTo: picker application
]
