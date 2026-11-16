"
I am the only class that knows Iceberg. I turn an Iceberg diff into an OCRReview made of OCRChanges.

I am kept small on purpose and I am not tested: everything after me works on plain OCRChanges.

	OCRIcebergReader reviewOfRepositoryNamed: 'my-project'
	OCRIcebergReader reviewOfRepositoryNamed: 'my-project' against: OCRLastCommitBase new

Without a base I use the default one (see #defaultBaseOf:).
Iceberg diffs have two sides: left is the newer one (the image), right is the older one (the base commit).
"
Class {
	#name : 'OCRIcebergReader',
	#superclass : 'Object',
	#category : 'ObscureCodeReviewer-Model',
	#package : 'ObscureCodeReviewer',
	#tag : 'Model'
}

{ #category : 'instance creation' }
OCRIcebergReader class >> repositoryNamed: aString [

	^ IceRepository registry detect: [ :each | each name = aString ]
]

{ #category : 'instance creation' }
OCRIcebergReader class >> reviewOfRepositoryNamed: aString [

	| repository reader |
	repository := self repositoryNamed: aString.
	reader := self new.
	^ reader reviewOf: repository against: (reader defaultBaseOf: repository)
]

{ #category : 'instance creation' }
OCRIcebergReader class >> reviewOfRepositoryNamed: aString against: aBase [

	^ self new reviewOf: (self repositoryNamed: aString) against: aBase
]

{ #category : 'reading' }
OCRIcebergReader >> changeFrom: aNode [

	| operation change |
	operation := aNode value.
	change := (self newChangeFor: aNode definition)
		          kind: (self kindOf: operation);
		          packageName: (self packageNameOf: aNode);
		          className: (self classNameOf: aNode);
		          oldSource: operation rightContents;
		          newSource: operation leftContents;
		          yourself.
	(self isExtension: aNode) ifTrue: [ change beExtension ].
	^ change
]

{ #category : 'reading' }
OCRIcebergReader >> changesIn: anIceDiff [

	| changes |
	changes := OrderedCollection new.
	anIceDiff tree allChildrenDo: [ :node | (self isReviewable: node) ifTrue: [ changes add: (self changeFrom: node) ] ].
	^ changes
]

{ #category : 'reading' }
OCRIcebergReader >> classNameOf: aNode [
	"For a method, the class node above it is named 'MyClass' or 'MyClass class'."

	aNode definition isMethodDefinition ifTrue: [ ^ aNode parent definition name asString ].
	^ aNode definition name asString
]

{ #category : 'reading' }
OCRIcebergReader >> classSideVariablesOf: anOperation [
	"The class-side variables on both sides of the change."

	| variables |
	variables := anOperation definition asMCDefinition classInstVarNames.
	anOperation isModification ifTrue: [ variables := variables , anOperation oldDefinition asMCDefinition classInstVarNames ].
	^ variables
]

{ #category : 'bases' }
OCRIcebergReader >> defaultBaseOf: aRepository [
	"See OCRDefaultBaseRule. Never fails: it falls back to the last commit."

	^ OCRDefaultBaseRule new
		  currentBranchName: aRepository branchName;
		  localBranchNames: aRepository localBranchNames;
		  upstreamNames: (self upstreamNamesOf: aRepository);
		  base
]

{ #category : 'reading' }
OCRIcebergReader >> isEmptyClassSideDefinition: aNode [
	"Iceberg reports a class-side definition ('MyClass class') for every new class.
	It is only worth reviewing when the class side declares variables."

	aNode definition isClassDefinition ifFalse: [ ^ false ].
	aNode definition isMeta ifFalse: [ ^ false ].
	^ (self classSideVariablesOf: aNode value) isEmpty
]

{ #category : 'reading' }
OCRIcebergReader >> isExtension: aNode [

	^ aNode definition isMethodDefinition and: [ aNode parent definition isExtensionDefinition ]
]

{ #category : 'reading' }
OCRIcebergReader >> isReviewable: aNode [
	"Only changed classes and methods are reviewed. Directories and packages are just containers."

	| definition |
	definition := aNode definition.
	aNode value hasChanges ifFalse: [ ^ false ].
	(self isEmptyClassSideDefinition: aNode) ifTrue: [ ^ false ].
	^ definition isMethodDefinition or: [ definition isClassDefinition ]
]

{ #category : 'reading' }
OCRIcebergReader >> kindOf: anOperation [

	anOperation isAddition ifTrue: [ ^ #addition ].
	anOperation isRemoval ifTrue: [ ^ #removal ].
	^ #modification
]

{ #category : 'bases' }
OCRIcebergReader >> lastCommitOf: aRepository [

	^ aRepository workingCopy referenceCommit
]

{ #category : 'reading' }
OCRIcebergReader >> newChangeFor: aDefinition [

	aDefinition isMethodDefinition ifTrue: [
		^ OCRMethodChange new
			  selector: aDefinition selector asSymbol;
			  yourself ].
	^ OCRClassChange new
]

{ #category : 'reading' }
OCRIcebergReader >> packageNameOf: aNode [

	| current |
	current := aNode.
	[ current definition isPackageDefinition ] whileFalse: [ current := current parent ].
	^ current definition name asString
]

{ #category : 'reading' }
OCRIcebergReader >> reviewOf: aRepository against: aBase [

	| baseCommit |
	baseCommit := aBase commitIn: aRepository by: self.
	^ OCRReview
		  repositoryName: aRepository name
		  base: aBase
		  baseLabel: baseCommit shortId , ' (' , aBase description , ')'
		  changes: (self changesIn: (IceDiff from: aRepository workingCopy to: baseCommit))
]

{ #category : 'bases' }
OCRIcebergReader >> splitPointOf: aRepository fromBranchNamed: aBranchName [
	"The commit where the current branch split from aBranchName, a local branch or a remote one like 'origin/main'."

	| branch |
	branch := aRepository branchNamed: aBranchName ifAbsent: [ aRepository remoteBranchNamed: aBranchName ].
	^ (self lastCommitOf: aRepository) commonAncestorWith: branch commit
]

{ #category : 'bases' }
OCRIcebergReader >> upstreamNamesOf: aRepository [
	"Local branch name -> upstream branch name, for the local branches that have one."

	| names |
	names := Dictionary new.
	aRepository localBranches do: [ :each | each hasUpstream ifTrue: [ names at: each name put: each upstream name ] ].
	^ names
]
