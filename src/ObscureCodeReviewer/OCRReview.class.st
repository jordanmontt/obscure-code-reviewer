"
I am a code review: the changes between a base commit and the image, for one repository, and the reviewer's comments on them.

Comments are attached to changes by their reference (e.g. 'MyClass>>#myMethod'). There is also one general comment for the whole review.

	review := OCRReview
		repositoryName: 'my-project'
		baseLabel: 'abc1234 (last commit)'
		changes: someChanges.
	review comment: 'Please rename this' on: aChange.
	review feedback ""Markdown, ready to paste to the agent""
"
Class {
	#name : 'OCRReview',
	#superclass : 'Object',
	#instVars : [
		'repositoryName',
		'baseLabel',
		'changes',
		'comments',
		'generalComment'
	],
	#category : 'ObscureCodeReviewer-Model',
	#package : 'ObscureCodeReviewer',
	#tag : 'Model'
}

{ #category : 'instance creation' }
OCRReview class >> repositoryName: aRepositoryName baseLabel: aBaseLabel changes: someChanges [

	^ self new setRepositoryName: aRepositoryName baseLabel: aBaseLabel changes: someChanges
]

{ #category : 'refreshing' }
OCRReview >> addLostComment: aComment on: aReference [
	"Append aComment to my general comment, saying which item it was about."

	generalComment := String streamContents: [ :stream |
		                  generalComment trimBoth ifNotEmpty: [ :text |
			                  stream
				                  nextPutAll: text;
				                  cr;
				                  cr ].
		                  stream
			                  nextPutAll: aReference;
			                  nextPutAll: ' (item no longer in diff): ';
			                  nextPutAll: aComment trimBoth ]
]

{ #category : 'accessing' }
OCRReview >> baseLabel [
	"Describes the base commit of the review, e.g. 'abc1234 (last commit)'."

	^ baseLabel
]

{ #category : 'accessing' }
OCRReview >> changes [

	^ changes
]

{ #category : 'comments' }
OCRReview >> comment: aString on: aChange [
	"An empty comment removes the comment."

	aString trimBoth isEmpty ifTrue: [ ^ comments removeKey: aChange reference ifAbsent: [ nil ] ].
	comments at: aChange reference put: aString
]

{ #category : 'comments' }
OCRReview >> commentAtReference: aReference [

	^ comments at: aReference
]

{ #category : 'comments' }
OCRReview >> commentOn: aChange [
	"Answer my comment on aChange, or an empty string."

	^ comments at: aChange reference ifAbsent: [ '' ]
]

{ #category : 'comments' }
OCRReview >> commentedReferences [
	"The references of the changes I have a comment on, sorted."

	^ comments keys asSortedCollection asArray
]

{ #category : 'feedback' }
OCRReview >> feedback [
	"Answer my comments as Markdown, ready to paste to the agent."

	^ OCRFeedbackWriter new feedbackFor: self
]

{ #category : 'comments' }
OCRReview >> generalComment [

	^ generalComment
]

{ #category : 'comments' }
OCRReview >> generalComment: aString [

	generalComment := aString
]

{ #category : 'comments' }
OCRReview >> hasCommentOn: aChange [

	^ comments includesKey: aChange reference
]

{ #category : 'refreshing' }
OCRReview >> includesChangeReferenced: aReference [

	^ changes anySatisfy: [ :each | each reference = aReference ]
]

{ #category : 'initialization' }
OCRReview >> initialize [

	super initialize.
	comments := Dictionary new.
	generalComment := ''
]

{ #category : 'testing' }
OCRReview >> isEmpty [

	^ changes isEmpty
]

{ #category : 'accessing' }
OCRReview >> repositoryName [

	^ repositoryName
]

{ #category : 'initialization' }
OCRReview >> setRepositoryName: aRepositoryName baseLabel: aBaseLabel changes: someChanges [

	repositoryName := aRepositoryName.
	baseLabel := aBaseLabel.
	changes := someChanges asOrderedCollection
]

{ #category : 'structural tree' }
OCRReview >> structuralTree [
	"Answer my changes as tree nodes: section > package > class > method."

	^ OCRStructuralTreeBuilder new treeFor: changes
]

{ #category : 'refreshing' }
OCRReview >> takeCommentsFrom: aReview [
	"Keep the comments of aReview, an older review of the same repository.
	Comments on items that are no longer in my changes are moved into my general comment, so nothing is lost."

	generalComment := aReview generalComment.
	aReview commentedReferences do: [ :reference |
		(self includesChangeReferenced: reference)
			ifTrue: [ comments at: reference put: (aReview commentAtReference: reference) ]
			ifFalse: [ self addLostComment: (aReview commentAtReference: reference) on: reference ] ]
]
