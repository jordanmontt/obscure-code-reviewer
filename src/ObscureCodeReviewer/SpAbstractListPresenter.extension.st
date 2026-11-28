Extension { #name : 'SpAbstractListPresenter' }

{ #category : '*ObscureCodeReviewer' }
SpAbstractListPresenter >> ocrReleaseAdapter [
	"My adapter also subscribes to my vertical alignment (SpAbstractMorphicListAdapter>>#configureScrolling), which #unsubscribe: does not reach."

	self adapter ifNotNil: [ :anAdapter |
		(self verticalAlignment observablePropertyNamed: #desiredVisibleRow) unsubscribe: anAdapter ].
	super ocrReleaseAdapter
]
