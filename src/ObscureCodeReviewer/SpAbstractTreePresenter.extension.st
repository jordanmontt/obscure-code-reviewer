Extension { #name : 'SpAbstractTreePresenter' }

{ #category : '*ObscureCodeReviewer' }
SpAbstractTreePresenter >> ocrReleaseAdapter [
	"My adapter also subscribes to my vertical alignment (SpMorphicTreeTableAdapter>>#configureScrolling), which #unsubscribe: does not reach."

	self adapter ifNotNil: [ :anAdapter |
		(self verticalAlignment observablePropertyNamed: #desiredVisibleRow) unsubscribe: anAdapter ].
	super ocrReleaseAdapter
]
