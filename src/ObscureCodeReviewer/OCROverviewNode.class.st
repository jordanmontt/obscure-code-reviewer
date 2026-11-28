"
I am the first row of both trees of the review window: selecting me shows the overview of the review, its pull request, its progress and its guide.
"
Class {
	#name : 'OCROverviewNode',
	#superclass : 'OCRTreeNode',
	#category : 'ObscureCodeReviewer-Model',
	#package : 'ObscureCodeReviewer',
	#tag : 'Model'
}

{ #category : 'instance creation' }
OCROverviewNode class >> new [

	^ super new
		  name: 'Overview';
		  iconName: #smallInfo;
		  yourself
]

{ #category : 'testing' }
OCROverviewNode >> hasChange [

	^ false
]

{ #category : 'testing' }
OCROverviewNode >> isCommentable [

	^ false
]

{ #category : 'displaying' }
OCROverviewNode >> showIn: aReviewPresenter [

	aReviewPresenter showOverview
]
