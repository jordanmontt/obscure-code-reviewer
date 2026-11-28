Extension { #name : 'SpExecutableLayout' }

{ #category : '*ObscureCodeReviewer' }
SpExecutableLayout >> ocrReleaseAdapters [
	"Unsubscribe my adapter, and the ones of the layouts inside me. A Morphic layout adapter subscribes to its layout (SpMorphicBoxAdapter>>#layout:) and never unsubscribes: when the layout is built again, for its presenter added again to an open window, the old adapter keeps building every child added to the layout, and keeps its old widgets in memory."

	self adapter ifNotNil: [ :anAdapter | self announcer unsubscribe: anAdapter ].
	self children do: [ :each | each isSpLayout ifTrue: [ each ocrReleaseAdapters ] ]
]
