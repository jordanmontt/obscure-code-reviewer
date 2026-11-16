"
I am the only class that knows Iceberg. I turn an Iceberg diff into an OCRReview made of OCRChanges.

I am kept small on purpose and I am not tested: everything after me works on plain OCRChanges.

	OCRIcebergReader reviewOfUncommittedChangesInRepositoryNamed: 'my-project'

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
OCRIcebergReader class >> reviewOfUncommittedChangesInRepositoryNamed: aString [

	^ self new reviewOfUncommittedChangesIn: (IceRepository registry detect: [ :each | each name = aString ])
]

{ #category : 'reading' }
OCRIcebergReader >> changeFrom: aNode [

	| operation change |
	operation := aNode value.
	change := OCRChange new
		          kind: (self kindOf: operation);
		          packageName: (self packageNameOf: aNode);
		          className: (self classNameOf: aNode);
		          oldSource: operation rightContents;
		          newSource: operation leftContents;
		          yourself.
	aNode definition isMethodDefinition ifTrue: [ change selector: aNode definition selector asSymbol ].
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
OCRIcebergReader >> declaresNoVariables: aClassSideDefinition [

	^ aClassSideDefinition isEmpty or: [ aClassSideDefinition endsWith: 'instanceVariableNames: ''''' ]
]

{ #category : 'reading' }
OCRIcebergReader >> isEmptyClassSideDefinition: aNode [
	"Iceberg reports a class-side definition ('MyClass class instanceVariableNames: ''''') for every new class.
	It is only worth reviewing when the class side declares variables."

	| operation |
	aNode definition isClassDefinition ifFalse: [ ^ false ].
	aNode definition isMeta ifFalse: [ ^ false ].
	operation := aNode value.
	^ (self declaresNoVariables: operation leftContents) and: [ self declaresNoVariables: operation rightContents ]
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

{ #category : 'reading' }
OCRIcebergReader >> packageNameOf: aNode [

	| current |
	current := aNode.
	[ current definition isPackageDefinition ] whileFalse: [ current := current parent ].
	^ current definition name asString
]

{ #category : 'reading' }
OCRIcebergReader >> reviewOfUncommittedChangesIn: aRepository [

	| base |
	base := aRepository workingCopy referenceCommit.
	^ OCRReview
		  repositoryName: aRepository name
		  baseLabel: base shortId , ' (last commit)'
		  changes: (self changesIn: (IceDiff from: aRepository workingCopy to: base))
]
