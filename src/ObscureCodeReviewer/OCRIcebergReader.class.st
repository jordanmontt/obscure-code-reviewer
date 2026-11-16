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
OCRIcebergReader >> reviewOfUncommittedChangesIn: aRepository [

	| base |
	base := aRepository workingCopy referenceCommit.
	^ OCRReview
		  repositoryName: aRepository name
		  baseLabel: base shortId , ' (last commit)'
		  changes: (self changesIn: (IceDiff from: aRepository workingCopy to: base))
]
