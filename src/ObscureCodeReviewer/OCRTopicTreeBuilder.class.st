"
I build the Topics tree of a review: one node per topic of the guide, in the guide's order, with the changes it lists; then a 'Not covered by any topic' node with the changes no topic lists.

A change belongs to exactly one topic: when two topics list it, the first one keeps it. Problems in the guide never block the review; they are reported by #warnings.

	(OCRTopicTreeBuilder changes: aReview changes guide: aReview guide) tree
"
Class {
	#name : 'OCRTopicTreeBuilder',
	#superclass : 'Object',
	#instVars : [
		'changes',
		'guide'
	],
	#category : 'ObscureCodeReviewer-Model',
	#package : 'ObscureCodeReviewer',
	#tag : 'Model'
}

{ #category : 'instance creation' }
OCRTopicTreeBuilder class >> changes: someChanges guide: aGuide [

	^ self new
		  setChanges: someChanges guide: aGuide;
		  yourself
]

{ #category : 'private' }
OCRTopicTreeBuilder >> addWarningsAbout: aReference in: aTopic to: someWarnings [

	| owner |
	(self isInDiff: aReference) ifFalse: [ ^ someWarnings add: aReference , ' (in "' , aTopic title , '") is not in the diff' ].
	owner := guide firstTopicListing: aReference ifNone: [ aTopic ].
	owner == aTopic ifFalse: [
		someWarnings add:
			aReference , ' is listed in "' , owner title , '" and in "' , aTopic title , '"; it stays in "' , owner title , '"' ]
]

{ #category : 'private' }
OCRTopicTreeBuilder >> changeReferenced: aReference [
	"Only valid when #isInDiff: is true."

	^ changes detect: [ :each | each reference = aReference ]
]

{ #category : 'private' }
OCRTopicTreeBuilder >> changesOf: aTopic [
	"The changes aTopic lists that are in the diff and not kept by an earlier topic."

	| owned |
	owned := aTopic references select: [ :each |
		         (self isInDiff: each) and: [ (guide firstTopicListing: each ifNone: [ aTopic ]) == aTopic ] ].
	^ owned collect: [ :each | self changeReferenced: each ]
]

{ #category : 'private' }
OCRTopicTreeBuilder >> isInDiff: aReference [

	^ changes anySatisfy: [ :each | each reference = aReference ]
]

{ #category : 'private' }
OCRTopicTreeBuilder >> nodeForChange: aChange [
	"Under a topic, changes of many classes are mixed, so they show their full reference."

	^ OCRChangeNode
		  named: aChange reference
		  iconName: (aChange isMethodChange
			   ifTrue: [ #page ]
			   ifFalse: [ #class ])
		  change: aChange
]

{ #category : 'private' }
OCRTopicTreeBuilder >> nodeForTopic: aTopic [

	| node |
	node := OCRTopicNode topic: aTopic.
	(self changesOf: aTopic) do: [ :each | node addChild: (self nodeForChange: each) ].
	^ node
]

{ #category : 'initialization' }
OCRTopicTreeBuilder >> setChanges: someChanges guide: aGuide [

	changes := someChanges.
	guide := aGuide
]

{ #category : 'building' }
OCRTopicTreeBuilder >> tree [

	| nodes uncovered |
	nodes := (guide topics collect: [ :each | self nodeForTopic: each ]) asOrderedCollection.
	uncovered := self uncoveredChanges.
	uncovered ifNotEmpty: [ nodes add: (self uncoveredNodeFor: uncovered) ].
	^ nodes
]

{ #category : 'private' }
OCRTopicTreeBuilder >> uncoveredChanges [

	^ (changes reject: [ :each | guide topics anySatisfy: [ :topic | topic lists: each reference ] ]) asSortedCollection: [ :a :b |
		  a reference <= b reference ]
]

{ #category : 'private' }
OCRTopicTreeBuilder >> uncoveredNodeFor: someChanges [

	| node |
	node := OCRContainerNode named: 'Not covered by any topic' iconName: #smallQuestion.
	someChanges do: [ :each | node addChild: (self nodeForChange: each) ].
	^ node
]

{ #category : 'building' }
OCRTopicTreeBuilder >> warnings [
	"Descriptions of the problems in the guide, in the guide's order."

	| warnings |
	warnings := OrderedCollection new.
	guide topics do: [ :topic | topic references do: [ :reference | self addWarningsAbout: reference in: topic to: warnings ] ].
	^ warnings
]
