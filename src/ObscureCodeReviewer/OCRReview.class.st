"
I am a code review: the changes between a base commit and the image, for one repository, and what the reviewer did with them: comments (an OCRReviewComments), reviewed marks and pull request edits.

Comments are attached to changes and topics by their reference (e.g. 'MyClass>>#myMethod'). There is also one general comment for the whole review.

	review := OCRReview
		repositoryName: 'my-project'
		reviewBase: (OCRReviewBase base: OCRLastCommitBase new commitId: 'abc1234')
		changes: someChanges.
	review comment: 'Please rename this' on: aChange.
	review feedback ""Markdown, ready to paste to the agent""
"
Class {
	#name : 'OCRReview',
	#superclass : 'Object',
	#instVars : [
		'repositoryName',
		'changes',
		'comments',
		'guide',
		'pullRequest',
		'reviewedChanges',
		'reviewBase'
	],
	#category : 'ObscureCodeReviewer-Model',
	#package : 'ObscureCodeReviewer',
	#tag : 'Model'
}

{ #category : 'instance creation' }
OCRReview class >> repositoryName: aRepositoryName reviewBase: aReviewBase changes: someChanges [

	^ self new setRepositoryName: aRepositoryName reviewBase: aReviewBase changes: someChanges
]

{ #category : 'reviewed marks' }
OCRReview >> areAllReviewed: someChanges [
	"Nothing to review counts as not reviewed, so empty nodes are never marked."

	^ someChanges isNotEmpty and: [ someChanges allSatisfy: [ :each | self isReviewed: each ] ]
]

{ #category : 'accessing' }
OCRReview >> base [
	"What my changes are compared to: an OCRLastCommitBase or an OCRSplitBase. A refresh uses the same base."

	^ reviewBase base
]

{ #category : 'moved code' }
OCRReview >> baseSourceOf: aChange [
	"What the new code of aChange is compared with: the old code it was moved from, or its own old code."

	^ (self movedOriginOf: aChange ifNone: [ aChange ]) oldSource
]

{ #category : 'accessing' }
OCRReview >> changes [

	^ changes
]

{ #category : 'marks' }
OCRReview >> changesInTreeOrder [
	"My changes in the order of the Structure tree."

	| ordered |
	ordered := OrderedCollection new.
	self structuralTree do: [ :section | ordered addAll: section changesBelow ].
	^ ordered
]

{ #category : 'comments' }
OCRReview >> comment: aString on: anItem [
	"anItem is a change or a topic. An empty comment removes the comment."

	comments comment: aString on: anItem
]

{ #category : 'comments' }
OCRReview >> commentAtReference: aReference [

	^ comments commentAtReference: aReference
]

{ #category : 'comments' }
OCRReview >> commentOn: anItem [
	"My comment on anItem (a change or a topic), or an empty string."

	^ comments commentOn: anItem
]

{ #category : 'comments' }
OCRReview >> commentedReferences [
	"The references of the changes and topics I have a comment on, sorted."

	^ comments commentedReferences
]

{ #category : 'refreshing' }
OCRReview >> continueFrom: aReview [
	"I am a newer computation of aReview: keep what the reviewer did. Set my guide first."

	self takeCommentsFrom: aReview.
	self takeMarksFrom: aReview.
	self takePullRequestFrom: aReview
]

{ #category : 'feedback' }
OCRReview >> feedback [
	"Answer my comments as Markdown, ready to paste to the agent."

	^ OCRFeedbackWriter new feedbackFor: self
]

{ #category : 'comments' }
OCRReview >> generalComment [

	^ comments general
]

{ #category : 'comments' }
OCRReview >> generalComment: aString [

	comments general: aString
]

{ #category : 'accessing' }
OCRReview >> guide [
	"The topics the agent wrote for these changes (see OCRReviewGuide). Empty when there is none."

	^ guide
]

{ #category : 'accessing' }
OCRReview >> guide: aGuide [
	"My pull request starts as the agent's draft in aGuide."

	guide := aGuide.
	pullRequest := aGuide pullRequest
]

{ #category : 'topics' }
OCRReview >> guideWarnings [

	^ (OCRTopicTreeBuilder changes: changes guide: guide) warnings
]

{ #category : 'comments' }
OCRReview >> hasCommentOn: anItem [

	^ comments hasCommentOn: anItem
]

{ #category : 'refreshing' }
OCRReview >> includesItemReferenced: aReference [
	"A change or a topic."

	^ (changes anySatisfy: [ :each | each reference = aReference ]) or: [ guide includesTopicReferenced: aReference ]
]

{ #category : 'initialization' }
OCRReview >> initialize [

	super initialize.
	comments := OCRReviewComments new.
	reviewedChanges := Dictionary new.
	self guide: OCRReviewGuide empty
]

{ #category : 'testing' }
OCRReview >> isEmpty [

	^ changes isEmpty
]

{ #category : 'pull request' }
OCRReview >> isPullRequestEdited [
	"Whether the reviewer changed the agent's draft."

	^ pullRequest ~= guide pullRequest
]

{ #category : 'marks' }
OCRReview >> isReviewed: aChange [

	^ reviewedChanges includesKey: aChange reference
]

{ #category : 'marks' }
OCRReview >> markReviewed: aChange [

	reviewedChanges at: aChange reference put: aChange
]

{ #category : 'moved code' }
OCRReview >> movedOriginOf: aChange ifNone: aBlock [
	"The change the guide says the code of aChange was moved or extracted from, when it is in my changes."

	| reference |
	reference := guide originOf: aChange reference ifNone: [ ^ aBlock value ].
	^ changes detect: [ :each | each reference = reference ] ifNone: aBlock
]

{ #category : 'guide' }
OCRReview >> notesAbout: aChange [
	"What the guide says about aChange alone: why, and where its code came from. Empty when nothing."

	| notes origin |
	notes := OrderedCollection new.
	(guide whyOf: aChange reference) ifNotEmpty: [ :why | notes add: 'Why: ' , why ].
	origin := self movedOriginOf: aChange ifNone: [ ^ String cr join: notes ].
	notes add: ('Moved from {1}: the left side shows its code before the move.' format: { origin reference }).
	^ String cr join: notes
]

{ #category : 'pull request' }
OCRReview >> pullRequest [
	"The pull request description, as the reviewer edited it."

	^ pullRequest
]

{ #category : 'pull request' }
OCRReview >> pullRequest: aPullRequest [

	pullRequest := aPullRequest
]

{ #category : 'accessing' }
OCRReview >> repositoryName [

	^ repositoryName
]

{ #category : 'accessing' }
OCRReview >> reviewBase [
	"What my changes are compared to, the commit it resolved to, and why it may be wrong (an OCRReviewBase)."

	^ reviewBase
]

{ #category : 'refreshing' }
OCRReview >> reviewedChangeReferenced: aReference ifNone: aBlock [

	^ reviewedChanges at: aReference ifAbsent: aBlock
]

{ #category : 'marks' }
OCRReview >> reviewedCount [

	^ changes count: [ :each | self isReviewed: each ]
]

{ #category : 'initialization' }
OCRReview >> setRepositoryName: aRepositoryName reviewBase: aReviewBase changes: someChanges [

	repositoryName := aRepositoryName.
	reviewBase := aReviewBase.
	changes := someChanges asOrderedCollection
]

{ #category : 'structural tree' }
OCRReview >> structuralTree [
	"Answer my changes as tree nodes: section > package > class > method."

	^ OCRStructuralTreeBuilder new treeFor: changes
]

{ #category : 'comments' }
OCRReview >> takeCommentsFrom: aReview [
	"Keep the comments of aReview, an older review of the same repository. Set my guide first.
	Comments on changes or topics that I no longer have are moved into my general comment, so nothing is lost."

	comments general: aReview generalComment.
	aReview commentedReferences do: [ :reference |
		(self includesItemReferenced: reference)
			ifTrue: [ comments comment: (aReview commentAtReference: reference) onReference: reference ]
			ifFalse: [ comments addLostComment: (aReview commentAtReference: reference) on: reference ] ]
]

{ #category : 'refreshing' }
OCRReview >> takeMarksFrom: aReview [
	"A change stays marked as reviewed only while its code is the same."

	changes do: [ :each | (self was: each reviewedIn: aReview) ifTrue: [ self markReviewed: each ] ]
]

{ #category : 'refreshing' }
OCRReview >> takePullRequestFrom: aReview [
	"The reviewer's edits win over a new draft of the agent."

	aReview isPullRequestEdited ifTrue: [ pullRequest := aReview pullRequest ]
]

{ #category : 'topics' }
OCRReview >> topicTree [
	"Answer my changes grouped by the topics of my guide."

	^ (OCRTopicTreeBuilder changes: changes guide: guide) tree
]

{ #category : 'marks' }
OCRReview >> unmarkReviewed: aChange [

	reviewedChanges removeKey: aChange reference ifAbsent: [ ^ self ]
]

{ #category : 'marks' }
OCRReview >> unreviewedChanges [
	"In the order of the Structure tree."

	^ self changesInTreeOrder reject: [ :each | self isReviewed: each ]
]

{ #category : 'refreshing' }
OCRReview >> was: aChange reviewedIn: aReview [

	| old |
	old := aReview reviewedChangeReferenced: aChange reference ifNone: [ ^ false ].
	^ old hasSameSourcesAs: aChange
]
