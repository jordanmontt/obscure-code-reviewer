"
I am the left side of the review window: the Files and Topics trees, as the two pages of a notebook, which builds each tree once and keeps it. Both trees start with the Overview row.

Each row shows what it is (icon), whether it was added, modified or removed (A, M, D in color), its name (bold when commented, struck through when removed), how much is reviewed below it or that it is commented, and a checkbox: ticking it marks everything below as reviewed.

The selection is the one of the tree shown. Several rows can be selected; Cmd+A selects them all.
"
Class {
	#name : 'OCRReviewSidebarPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'review',
		'filesTree',
		'topicsTree',
		'activeTree',
		'selectionBlock',
		'markBlock',
		'notebook'
	],
	#category : 'ObscureCodeReviewer-UI',
	#package : 'ObscureCodeReviewer',
	#tag : 'UI'
}

{ #category : 'selection' }
OCRReviewSidebarPresenter >> changesInOrder [
	"The changes of the tree shown, in the order the reviewer reads them, each once."

	| changes |
	changes := OrderedCollection new.
	self nodesDo: [ :node | (node hasChange and: [ (changes includes: node change) not ]) ifTrue: [ changes add: node change ] ].
	^ changes
]

{ #category : 'layout' }
OCRReviewSidebarPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  add: notebook;
		  yourself
]

{ #category : 'showing' }
OCRReviewSidebarPresenter >> enableSelecting: aBoolean [
	"While the reviewer edits a method, the selection cannot change."

	notebook enabled: aBoolean.
	filesTree enabled: aBoolean.
	topicsTree enabled: aBoolean
]

{ #category : 'initialization' }
OCRReviewSidebarPresenter >> infoColumn [

	^ (SpStringTableColumn evaluated: [ :node | self infoFor: node ])
		  width: 72;
		  displayColor: [ :node | self theme ghostTextColor ];
		  displayAlignment: [ :node | SpColumnAlignment right ];
		  yourself
]

{ #category : 'showing' }
OCRReviewSidebarPresenter >> infoFor: aNode [
	"A change says whether it is commented; a group how many of its changes are reviewed."

	| changes |
	aNode hasChange ifTrue: [
		^ (self isCommented: aNode)
			  ifTrue: [ 'commented' ]
			  ifFalse: [ '' ] ].
	changes := aNode changesBelow.
	changes ifEmpty: [ ^ '' ].
	^ '{1} / {2}' format: {
		  (changes count: [ :each | review isReviewed: each ]).
		  changes size }
]

{ #category : 'initialization' }
OCRReviewSidebarPresenter >> initializePresenters [
	"The two trees are the pages of a notebook: it builds each tree once and keeps it, so switching is fast and keeps no old widget in memory, which taking a tree off an open window and adding it back did (see SpPresenter>>#ocrReleaseWidgets)."

	filesTree := self newChangesTree.
	topicsTree := self newChangesTree.
	activeTree := filesTree.
	selectionBlock := [ ].
	markBlock := [ :node :aBoolean |  ].
	notebook := self newNotebook
		            addPage:
			            (self
				             pageTitled: 'Files'
				             help: 'Every change, by section (Code, Tests, Baseline, Files), package and class'
				             tree: filesTree);
		            addPage:
			            (self pageTitled: 'Topics' help: 'The changes grouped by purpose, from the agent''s review guide' tree: topicsTree);
		            yourself.
	notebook whenSelectedPageChangedDo: [
		self showTree: (notebook selectedPageIndex = 1
			 ifTrue: [ filesTree ]
			 ifFalse: [ topicsTree ]) ].
	self showReview: review
]

{ #category : 'showing' }
OCRReviewSidebarPresenter >> isCommented: aNode [

	^ aNode isCommentable and: [ review hasCommentOn: aNode commentable ]
]

{ #category : 'showing' }
OCRReviewSidebarPresenter >> isRemoval: aNode [

	^ aNode hasChange and: [ aNode change isRemoval ]
]

{ #category : 'selection' }
OCRReviewSidebarPresenter >> isSelectingInFiles [

	^ activeTree == filesTree
]

{ #category : 'showing' }
OCRReviewSidebarPresenter >> kindColorOf: aNode [

	aNode hasChange ifFalse: [ ^ self theme textColor ].
	^ aNode change kindColorIn: self theme
]

{ #category : 'initialization' }
OCRReviewSidebarPresenter >> kindColumn [

	^ (SpStringTableColumn evaluated: [ :node | self kindLetterOf: node ])
		  width: 14;
		  displayBold: [ :node | true ];
		  displayColor: [ :node | self kindColorOf: node ];
		  yourself
]

{ #category : 'showing' }
OCRReviewSidebarPresenter >> kindLetterOf: aNode [

	aNode hasChange ifFalse: [ ^ '' ].
	^ aNode change kindLetter
]

{ #category : 'initialization' }
OCRReviewSidebarPresenter >> nameColumn [
	"What a row is: its icon, its kind letter (A, M, D) and its name."

	^ SpCompositeTableColumn new
		  addColumn: (SpImageTableColumn evaluated: [ :node | self iconNamed: node iconName ]);
		  addColumn: self kindColumn;
		  addColumn: ((SpStringTableColumn evaluated: [ :node | node name ])
			   displayBold: [ :node | self isCommented: node ];
			   displayStrikethrough: [ :node | self isRemoval: node ];
			   yourself);
		  beExpandable;
		  yourself
]

{ #category : 'initialization' }
OCRReviewSidebarPresenter >> newChangesTree [
	"Several rows can be selected (Cmd+A selects them all), so Reviewed marks them together."

	^ self newTreeTable
		  beMultipleSelection;
		  hideColumnHeaders;
		  addColumn: self nameColumn;
		  addColumn: self infoColumn;
		  addColumn: self reviewedColumn;
		  children: [ :node | node children ];
		  yourself
]

{ #category : 'selection' }
OCRReviewSidebarPresenter >> nodeGrouping: someNodes [

	| node changes |
	changes := (someNodes flatCollect: [ :each | each changesBelow ]) asSet.
	node := OCRContainerNode named: ('{1} {2} selected' format: {
		         changes size.
		         ('change' asPluralBasedOn: changes size) }).
	someNodes do: [ :each | node addChild: each ].
	^ node
]

{ #category : 'selection' }
OCRReviewSidebarPresenter >> nodesDo: aBlock [
	"The nodes of the tree shown, in the order the reviewer reads them."

	activeTree roots do: [ :root | root withAllChildrenDo: aBlock ]
]

{ #category : 'initialization' }
OCRReviewSidebarPresenter >> pageTitled: aTitle help: aString tree: aTree [

	^ (SpNotebookPage title: aTitle provider: [ aTree ])
		  help: aString;
		  yourself
]

{ #category : 'selection' }
OCRReviewSidebarPresenter >> path: aPath to: aNode from: aRoot [
	"The names from aRoot down to aNode, or nil when aNode is not below aRoot."

	aPath add: aRoot name.
	aRoot == aNode ifTrue: [ ^ aPath ].
	aRoot children do: [ :each | (self path: aPath copy to: aNode from: each) ifNotNil: [ :found | ^ found ] ].
	^ nil
]

{ #category : 'selection' }
OCRReviewSidebarPresenter >> pathOf: aNode [
	"The names of the groups above aNode, from the top, e.g. #('Code' 'MyPackage' 'MyClass')."

	activeTree roots do: [ :root |
		(self path: OrderedCollection new to: aNode from: root) ifNotNil: [ :path | ^ path allButLast asArray ] ].
	^ #(  )
]

{ #category : 'showing' }
OCRReviewSidebarPresenter >> refreshTrees [
	"After a comment or a mark: labels and styles change, the nodes do not."

	filesTree refresh.
	topicsTree refresh
]

{ #category : 'initialization' }
OCRReviewSidebarPresenter >> reviewedColumn [

	^ (SpCheckBoxTableColumn evaluated: [ :node | review areAllReviewed: node changesBelow ])
		  width: 24;
		  onActivation: [ :node | markBlock value: node value: true ];
		  onDeactivation: [ :node | markBlock value: node value: false ];
		  yourself
]

{ #category : 'selection' }
OCRReviewSidebarPresenter >> selectAll [

	activeTree selectAll
]

{ #category : 'showing' }
OCRReviewSidebarPresenter >> selectCounterpartOf: aNode [
	"Select the row of the tree shown that stands for the same change or topic as aNode, or else the Overview."

	aNode isCommentable ifTrue: [
		self nodesDo: [ :each | (each isCommentable and: [ each commentable == aNode commentable ]) ifTrue: [ ^ self selectOnly: each ] ] ].
	self selectOverview
]

{ #category : 'selection' }
OCRReviewSidebarPresenter >> selectItemReferenced: aReference [
	"Select only the change or topic written aReference, when it is in the tree shown."

	self nodesDo: [ :node |
		(node isCommentable and: [ node commentable reference = aReference ]) ifTrue: [ ^ self selectOnly: node ] ]
]

{ #category : 'selection' }
OCRReviewSidebarPresenter >> selectOnly: aNode [
	"In a tree with multiple selection, #selectItem: and #selectItems: add to the selection, row by row: only #selectPaths: replaces it."

	activeTree selectPaths: { (activeTree selection pathOf: aNode) }
]

{ #category : 'selection' }
OCRReviewSidebarPresenter >> selectOverview [

	self selectOnly: activeTree roots first
]

{ #category : 'selection' }
OCRReviewSidebarPresenter >> selectedNode [
	"With nothing selected, an empty node: nothing to show, comment, browse or mark. With several rows selected, a node grouping them: it shows how many changes they hold, and marks them all."

	| nodes |
	nodes := activeTree selectedItems.
	nodes ifEmpty: [ ^ OCRContainerNode named: 'Nothing selected' ].
	nodes size = 1 ifTrue: [ ^ nodes first ].
	^ self nodeGrouping: nodes
]

{ #category : 'accessing - model' }
OCRReviewSidebarPresenter >> setModelBeforeInitialization: aReview [

	review := aReview
]

{ #category : 'selection' }
OCRReviewSidebarPresenter >> showFiles [

	notebook selectPageIndex: 1
]

{ #category : 'showing' }
OCRReviewSidebarPresenter >> showReview: aReview [
	"Show aReview, the first one or a newer one after a refresh."

	review := aReview.
	filesTree
		roots: { OCROverviewNode new } , review structuralTree;
		expandAll.
	topicsTree
		roots: { OCROverviewNode new } , review topicTree;
		expandAll
]

{ #category : 'selection' }
OCRReviewSidebarPresenter >> showTopics [

	notebook selectPageIndex: 2
]

{ #category : 'showing' }
OCRReviewSidebarPresenter >> showTree: aTree [
	"The notebook shows aTree, expanded by #showReview: (which waits until the tree is built). When nothing is selected in it, the change selected in the other tree stays selected, or else the Overview: never an empty page."

	| previous |
	aTree == activeTree ifTrue: [ ^ self ].
	previous := self selectedNode.
	activeTree := aTree.
	aTree selectedItems ifEmpty: [ ^ self selectCounterpartOf: previous ].
	selectionBlock value
]

{ #category : 'selection' }
OCRReviewSidebarPresenter >> tickRowNamed: aString [
	"Click the checkbox of the first row named aString in the tree shown."

	self nodesDo: [ :node |
		node name = aString ifTrue: [ ^ markBlock value: node value: (review areAllReviewed: node changesBelow) not ] ].
	self error: 'No row named ' , aString
]

{ #category : 'showing' }
OCRReviewSidebarPresenter >> topRowLabels [

	^ filesTree roots collect: [ :each | each name ] as: Array
]

{ #category : 'events' }
OCRReviewSidebarPresenter >> treeActions: anActionGroup [
	"Both trees offer anActionGroup in their right-click menu, and answer its shortcuts when focused."

	filesTree actions: anActionGroup.
	topicsTree actions: anActionGroup
]

{ #category : 'accessing' }
OCRReviewSidebarPresenter >> trees [

	^ {
		  filesTree.
		  topicsTree }
]

{ #category : 'events' }
OCRReviewSidebarPresenter >> whenChangeActivatedDo: aBlock [
	"aBlock receives the change of a row double-clicked in either tree. Rows without a change are ignored."

	{
		filesTree.
		topicsTree } do: [ :tree |
		tree whenActivatedDo: [ :selection | selection selectedItem hasChange ifTrue: [ aBlock value: selection selectedItem change ] ] ]
]

{ #category : 'events' }
OCRReviewSidebarPresenter >> whenMarkChangedDo: aBlock [
	"aBlock receives a row whose checkbox the reviewer clicked, and whether it is now ticked."

	markBlock := aBlock
]

{ #category : 'events' }
OCRReviewSidebarPresenter >> whenSelectionChangedDo: aBlock [
	"aBlock is evaluated when the selection of the tree shown changes, and when the other tree is shown."

	selectionBlock := aBlock.
	{
		filesTree.
		topicsTree } do: [ :tree | tree whenSelectionChangedDo: [ tree == activeTree ifTrue: [ selectionBlock value ] ] ]
]
