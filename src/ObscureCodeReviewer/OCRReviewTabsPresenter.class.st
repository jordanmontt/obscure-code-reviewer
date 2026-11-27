"
I am the left side of the review window: the Structure, Topics, Guide and Pull request tabs of a review. Each tab explains itself when the mouse is over it.

The selection is the one of the tree clicked last (Structure or Topics). In the trees:
- the icon says what a node is, + / ~ / - and the color say whether it was added, modified or removed;
- a node shows whether everything under it is reviewed;
- a commented node is bold, and marked [commented].
"
Class {
	#name : 'OCRReviewTabsPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'review',
		'notebook',
		'changesTree',
		'topicsTree',
		'activeTree',
		'guidePresenter',
		'pullRequestPresenter'
	],
	#category : 'ObscureCodeReviewer-UI',
	#package : 'ObscureCodeReviewer',
	#tag : 'UI'
}

{ #category : 'showing' }
OCRReviewTabsPresenter >> colorFor: aNode [
	"Colors come from the current theme, so they also work with dark and custom themes."

	aNode hasChange ifFalse: [ ^ self theme textColor ].
	aNode change isAddition ifTrue: [ ^ self theme successTextColor ].
	aNode change isRemoval ifTrue: [ ^ self theme dangerTextColor ].
	^ self theme textColor
]

{ #category : 'layout' }
OCRReviewTabsPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  add: notebook;
		  yourself
]

{ #category : 'showing' }
OCRReviewTabsPresenter >> enableSelecting: aBoolean [
	"While the reviewer edits a method, the selection cannot change."

	notebook enabled: aBoolean.
	changesTree enabled: aBoolean.
	topicsTree enabled: aBoolean
]

{ #category : 'initialization' }
OCRReviewTabsPresenter >> initializeNotebook [

	notebook := self newNotebook
		            addPage: (self
			             pageTitled: 'Structure'
			             help:
				             'Every change, by section (Code, Tests, Baseline, Files), package and class. + added, ~ modified, - removed; bold means commented.'
			             presenter: changesTree);
		            addPage: (self
			             pageTitled: 'Topics'
			             help:
				             'The changes grouped by purpose, from the agent''s review guide. Select a topic to read its explanation and comment on it.'
			             presenter: topicsTree);
		            addPage: (self
			             pageTitled: 'Guide'
			             help:
				             'The review guide written by the agent: the pull request draft and the topics. Edit it and click Apply; problems are listed under Warnings.'
			             presenter: guidePresenter);
		            addPage: (self
			             pageTitled: 'Pull request'
			             help:
				             'The title and description of the pull request, drafted by the agent in the guide. Copy review includes your edits.'
			             presenter: pullRequestPresenter);
		            yourself
]

{ #category : 'initialization' }
OCRReviewTabsPresenter >> initializePresenters [

	changesTree := self newChangesTree.
	topicsTree := self newChangesTree.
	activeTree := changesTree.
	guidePresenter := self instantiate: OCRGuidePresenter.
	pullRequestPresenter := self instantiate: OCRPullRequestPresenter.
	self initializeNotebook.
	self showReview: review
]

{ #category : 'showing' }
OCRReviewTabsPresenter >> isCommented: aNode [

	^ aNode isCommentable and: [ review hasCommentOn: aNode commentable ]
]

{ #category : 'testing' }
OCRReviewTabsPresenter >> isSelectingInStructure [
	"Whether the selection is the one of the Structure tab, not of the Topics tab."

	^ activeTree == changesTree
]

{ #category : 'showing' }
OCRReviewTabsPresenter >> labelFor: aNode [
	"The node, and whether it is reviewed and commented."

	^ String streamContents: [ :stream |
		  stream nextPutAll: aNode label.
		  (review areAllReviewed: aNode changesBelow) ifTrue: [ stream nextPutAll: '  [reviewed]' ].
		  (self isCommented: aNode) ifTrue: [ stream nextPutAll: '  [commented]' ] ]
]

{ #category : 'initialization' }
OCRReviewTabsPresenter >> newChangesTree [

	^ self newTree
		  children: [ :node | node children ];
		  display: [ :node | self labelFor: node ];
		  displayIcon: [ :node | self iconNamed: node iconName ];
		  displayColor: [ :node | self colorFor: node ];
		  displayBold: [ :node | self isCommented: node ];
		  yourself
]

{ #category : 'initialization' }
OCRReviewTabsPresenter >> pageTitled: aTitle help: aString presenter: aPresenter [

	^ (SpNotebookPage title: aTitle provider: [ aPresenter ])
		  help: aString;
		  yourself
]

{ #category : 'showing' }
OCRReviewTabsPresenter >> refreshTrees [
	"After a comment or a mark: labels and styles change, the nodes do not."

	changesTree refresh.
	topicsTree refresh
]

{ #category : 'selection' }
OCRReviewTabsPresenter >> selectItemReferenced: aReference [
	"Select the change or topic written aReference, when it is still in the active tree."

	activeTree roots do: [ :root |
		root withAllChildrenDo: [ :node |
			(node isCommentable and: [ node commentable reference = aReference ]) ifTrue: [ ^ activeTree selectItem: node ] ] ]
]

{ #category : 'selection' }
OCRReviewTabsPresenter >> selectedNode [
	"With nothing selected, an empty node: nothing to show, comment, browse or mark."

	^ activeTree selectedItem ifNil: [ OCRContainerNode named: 'Nothing selected' ]
]

{ #category : 'accessing - model' }
OCRReviewTabsPresenter >> setModelBeforeInitialization: aReview [

	review := aReview
]

{ #category : 'showing' }
OCRReviewTabsPresenter >> showReview: aReview [
	"Show aReview, the first one or a newer one after a refresh."

	review := aReview.
	changesTree
		roots: review structuralTree;
		expandAll.
	topicsTree
		roots: review topicTree;
		expandAll.
	guidePresenter showGuide: review guide text warnings: review guideWarnings.
	pullRequestPresenter showPullRequest: review pullRequest
]

{ #category : 'api' }
OCRReviewTabsPresenter >> treeActions: anActionGroup [
	"Both trees offer anActionGroup in their right-click menu, and answer its shortcuts when focused."

	changesTree actions: anActionGroup.
	topicsTree actions: anActionGroup
]

{ #category : 'events' }
OCRReviewTabsPresenter >> whenChangeActivatedDo: aBlock [
	"aBlock receives the change of a node double-clicked in either tree. Sections, packages, topics and unchanged classes have no change and are ignored."

	{
		changesTree.
		topicsTree } do: [ :tree |
		tree whenActivatedDo: [ :selection | selection selectedItem hasChange ifTrue: [ aBlock value: selection selectedItem change ] ] ]
]

{ #category : 'events' }
OCRReviewTabsPresenter >> whenGuideAppliedDo: aBlock [
	"aBlock receives the guide text when the reviewer clicks Apply in the Guide tab."

	guidePresenter whenAppliedDo: aBlock
]

{ #category : 'events' }
OCRReviewTabsPresenter >> whenPullRequestChangedDo: aBlock [
	"aBlock receives the OCRPullRequest the reviewer edited in the Pull request tab."

	pullRequestPresenter whenPullRequestChangedDo: aBlock
]

{ #category : 'events' }
OCRReviewTabsPresenter >> whenSelectionChangedDo: aBlock [
	"The selection follows the tree clicked last. A tree whose selection was cleared, as #showReview: clears both, does not take it."

	{
		changesTree.
		topicsTree } do: [ :tree |
			tree whenSelectionChangedDo: [
				tree selection isEmpty ifFalse: [ activeTree := tree ].
				aBlock value ] ]
]
