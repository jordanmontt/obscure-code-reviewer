Extension { #name : 'SpBoxLayout' }

{ #category : '*ObscureCodeReviewer' }
SpBoxLayout >> ocrRemoveAll [
	"Remove my children, releasing their widgets. On an open window, #removeAll and #remove: leave the adapters of the presenters inside a child subscribed, so their widgets stay in memory and every later build gets slower (see SpPresenter>>#ocrReleaseWidgets)."

	self children copy do: [ :each |
		each ocrReleaseWidgets.
		self remove: each ]
]
