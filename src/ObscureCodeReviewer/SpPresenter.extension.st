Extension { #name : 'SpPresenter' }

{ #category : '*ObscureCodeReviewer' }
SpPresenter >> ocrReleaseAdapter [
	"Unsubscribe my adapter from me, before my widget is removed from an open window. Besides my observable slots (SpAbstractAdapter>>#unsubscribe), an adapter subscribes to my announcer (e.g. #whenDisplayDo:)."

	self adapter ifNil: [ ^ self ].
	self adapter unsubscribe.
	self announcer unsubscribe: self adapter
]

{ #category : '*ObscureCodeReviewer' }
SpPresenter >> ocrReleaseWidgets [
	"Unsubscribe the adapters of my widgets and of my layouts, mine and those of the presenters inside me, before I am removed from an open window (see SpBoxLayout>>#ocrRemoveAll). A widget presenter's layout only builds its widget: it has nothing to release."

	(self allPresenters copyWith: self) do: [ :each |
		each ocrReleaseAdapter.
		each layout ifNotNil: [ :aLayout | aLayout isSpLayout ifTrue: [ aLayout ocrReleaseAdapters ] ] ]
]
