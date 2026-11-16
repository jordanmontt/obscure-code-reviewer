"
I am the only class that knows Iceberg. I turn an Iceberg diff into an OCRReview made of OCRChanges.

I am kept small on purpose and I am not tested: everything after me works on plain OCRChanges.

	OCRIcebergReader reviewOfRepositoryNamed: 'my-project'
	OCRIcebergReader reviewOfRepositoryNamed: 'my-project' against: OCRLastCommitBase new

Without a base I use the default one (see #defaultBaseOf:).
Iceberg diffs have two sides: left is the newer one (the image), right is the older one (the base commit).

Code comes from Iceberg's diff, for the loaded packages. Every other file (README, .properties, the files of packages not loaded) is compared as a whole file, between the base commit and the disk (see #fileChangesIn:since:).
"
Class {
	#name : 'OCRIcebergReader',
	#superclass : 'Object',
	#category : 'ObscureCodeReviewer-Model',
	#package : 'ObscureCodeReviewer',
	#tag : 'Model'
}

{ #category : 'instance creation' }
OCRIcebergReader class >> baseChoicesOfRepositoryNamed: aString [

	| repository reader |
	repository := self repositoryNamed: aString.
	reader := self new.
	^ OCRBaseChoices default: (reader defaultBaseOf: repository) branchNames: (reader branchNamesToSplitFromIn: repository)
]

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

{ #category : 'repositories' }
OCRIcebergReader class >> reviewableRepositoryNames [
	"The repositories whose changes can be reviewed: those with a local checkout and loaded packages."

	^ (IceRepository registry
		   select: [ :each | each isValid and: [ each loadedPackages isNotEmpty ] ]
		   thenCollect: [ :each | each name ]) sorted
]

{ #category : 'files' }
OCRIcebergReader >> addFilePathsIn: aRoot of: aRepository to: aSet [
	"The paths of the files under aRoot, relative to it, skipping the directories of the loaded packages: Iceberg's diff reviews them as code."

	self
		addFilePathsIn: aRoot
		under: aRoot
		skipping: (self codeDirectoriesOf: aRepository)
		to: aSet
]

{ #category : 'files' }
OCRIcebergReader >> addFilePathsIn: aDirectory under: aRoot skipping: someDirectoryPaths to: aSet [

	aDirectory children do: [ :each |
		| path |
		path := (each relativeTo: aRoot) pathString.
		each isDirectory
			ifTrue: [
				(someDirectoryPaths includes: path) ifFalse: [
					self
						addFilePathsIn: each
						under: aRoot
						skipping: someDirectoryPaths
						to: aSet ] ]
			ifFalse: [ aSet add: path ] ]
]

{ #category : 'bases' }
OCRIcebergReader >> branchNamesToSplitFromIn: aRepository [
	"Local and remote branch names, without the current branch: splitting from itself is the last commit."

	| names |
	names := aRepository localBranchNames , aRepository remoteBranchNames.
	aRepository head isBranch ifFalse: [ ^ names ].
	^ names copyWithout: aRepository branchName
]

{ #category : 'files' }
OCRIcebergReader >> bytesOf: aFile [
	"Empty when the file does not exist on that side."

	aFile exists ifFalse: [ ^ ByteArray new ].
	^ aFile binaryReadStreamDo: [ :stream | stream upToEnd ]
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

{ #category : 'files' }
OCRIcebergReader >> codeDirectoriesOf: aRepository [
	"'.git', and the directory of each loaded package, e.g. 'src/MyPackage'."

	^ (aRepository loadedPackages collect: [ :each | (aRepository subdirectoryPath / each name) pathString ] as: Set)
		  add: '.git';
		  yourself
]

{ #category : 'bases' }
OCRIcebergReader >> defaultBaseOf: aRepository [
	"See OCRDefaultBaseRule. Never fails: it falls back to the last commit, also when no branch is checked out."

	aRepository head isBranch ifFalse: [ ^ OCRLastCommitBase new ].
	^ OCRDefaultBaseRule new
		  currentBranchName: aRepository branchName;
		  localBranchNames: aRepository localBranchNames;
		  upstreamNames: (self upstreamNamesOf: aRepository);
		  base
]

{ #category : 'files' }
OCRIcebergReader >> fileChangeAt: aPath in: aRepository since: aCommit [

	| old new |
	old := aCommit fileSystem resolve: aPath.
	new := aRepository location resolve: aPath.
	^ OCRFileChange
		  kind: (self fileChangeKindFrom: old to: new)
		  path: aPath
		  oldBytes: (self bytesOf: old)
		  newBytes: (self bytesOf: new)
]

{ #category : 'files' }
OCRIcebergReader >> fileChangeKindFrom: anOldFile to: aNewFile [

	anOldFile exists ifFalse: [ ^ #addition ].
	aNewFile exists ifFalse: [ ^ #removal ].
	^ #modification
]

{ #category : 'files' }
OCRIcebergReader >> fileChangesIn: aRepository since: aCommit [
	"The files outside the loaded packages that differ between aCommit and the disk.
	Only the files of aCommit or of the last commit are compared: a new file shows up once it is committed."

	| paths |
	paths := Set new.
	self addFilePathsIn: aCommit fileSystem of: aRepository to: paths.
	self addFilePathsIn: (self lastCommitOf: aRepository) fileSystem of: aRepository to: paths.
	^ paths sorted
		  select: [ :each | self isFileAt: each changedIn: aRepository since: aCommit ]
		  thenCollect: [ :each | self fileChangeAt: each in: aRepository since: aCommit ]
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

{ #category : 'files' }
OCRIcebergReader >> isFileAt: aPath changedIn: aRepository since: aCommit [

	| old new |
	old := aCommit fileSystem resolve: aPath.
	new := aRepository location resolve: aPath.
	old exists = new exists ifFalse: [ ^ true ].
	^ (self bytesOf: old) ~= (self bytesOf: new)
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
		  baseLabel: ('{1} ({2})' format: {
			   baseCommit shortId.
			   aBase description })
		  changes:
		  (self changesIn: (IceDiff from: aRepository workingCopy to: baseCommit)) , (self fileChangesIn: aRepository since: baseCommit)
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
