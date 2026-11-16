"
I test OCRReview, mainly how it organizes its changes into a tree.
"
Class {
	#name : 'OCRReviewTest',
	#superclass : 'TestCase',
	#category : 'ObscureCodeReviewer-Tests',
	#package : 'ObscureCodeReviewer-Tests'
}

{ #category : 'helpers' }
OCRReviewTest >> classChange: aClassName package: aPackageName [

	^ OCRChange modification
		  packageName: aPackageName;
		  className: aClassName;
		  yourself
]

{ #category : 'helpers' }
OCRReviewTest >> methodChange: aSelector class: aClassName package: aPackageName [

	^ OCRChange modification
		  packageName: aPackageName;
		  className: aClassName;
		  selector: aSelector;
		  yourself
]

{ #category : 'helpers' }
OCRReviewTest >> namesOf: someNodes [

	^ (someNodes collect: [ :each | each name ]) asArray
]

{ #category : 'helpers' }
OCRReviewTest >> reviewWith: someChanges [

	^ OCRReview repositoryName: 'my-project' baseLabel: 'abc1234 (last commit)' changes: someChanges
]

{ #category : 'tests' }
OCRReviewTest >> testChangedClassDefinitionIsTheClassNode [

	| classChange classNode |
	classChange := self classChange: 'MyClass' package: 'MyPackage'.
	classNode := (self reviewWith: {
		              classChange.
		              (self methodChange: #a class: 'MyClass' package: 'MyPackage') }) structuralTree first children first.

	self assert: classNode change equals: classChange.
	self assert: (self namesOf: classNode children) equals: #( 'a' )
]

{ #category : 'tests' }
OCRReviewTest >> testClassSideMethodsHaveTheirOwnNode [

	| tree |
	tree := (self reviewWith: {
		         (self methodChange: #a class: 'MyClass' package: 'MyPackage').
		         (self methodChange: #new class: 'MyClass class' package: 'MyPackage') }) structuralTree.

	self assert: (self namesOf: tree first children) equals: #( 'MyClass' 'MyClass class' )
]

{ #category : 'tests' }
OCRReviewTest >> testEmptyReview [

	| review |
	review := self reviewWith: #(  ).

	self assert: review isEmpty.
	self assert: review structuralTree isEmpty
]

{ #category : 'tests' }
OCRReviewTest >> testExtensionMethodsHaveTheirOwnNode [

	| extension tree |
	extension := self methodChange: #isMyThing class: 'Object' package: 'MyPackage'.
	extension beExtension.
	tree := (self reviewWith: { extension }) structuralTree.

	self assert: (self namesOf: tree first children) equals: #( 'Object (extension)' )
]

{ #category : 'tests' }
OCRReviewTest >> testMethodNodeLabelShowsKind [

	| added methodNode |
	added := OCRChange addition
		         packageName: 'MyPackage';
		         className: 'MyClass';
		         selector: #myMethod;
		         yourself.
	methodNode := (self reviewWith: { added }) structuralTree first children first children first.

	self assert: methodNode label equals: '+ myMethod'
]

{ #category : 'tests' }
OCRReviewTest >> testMethodsAreSortedBySelector [

	| classNode |
	classNode := (self reviewWith: {
		              (self methodChange: #zeta class: 'MyClass' package: 'MyPackage').
		              (self methodChange: #alpha class: 'MyClass' package: 'MyPackage') }) structuralTree first children first.

	self assert: (self namesOf: classNode children) equals: #( 'alpha' 'zeta' )
]

{ #category : 'tests' }
OCRReviewTest >> testPackagesAndClassesAreSortedByName [

	| tree |
	tree := (self reviewWith: {
		         (self methodChange: #a class: 'Zeta' package: 'PackageB').
		         (self methodChange: #a class: 'Beta' package: 'PackageA').
		         (self methodChange: #a class: 'Alpha' package: 'PackageB') }) structuralTree.

	self assert: (self namesOf: tree) equals: #( 'PackageA' 'PackageB' ).
	self assert: (self namesOf: tree second children) equals: #( 'Alpha' 'Zeta' )
]

{ #category : 'tests' }
OCRReviewTest >> testTreeGroupsMethodsByPackageThenClass [

	| tree |
	tree := (self reviewWith: {
		         (self methodChange: #a class: 'ClassA' package: 'PackageA').
		         (self methodChange: #b class: 'ClassB' package: 'PackageA') }) structuralTree.

	self assert: (self namesOf: tree) equals: #( 'PackageA' ).
	self assert: (self namesOf: tree first children) equals: #( 'ClassA' 'ClassB' ).
	self assert: (self namesOf: tree first children first children) equals: #( 'a' )
]

{ #category : 'tests' }
OCRReviewTest >> testUnchangedClassNodeHasNoChange [

	| classNode |
	classNode := (self reviewWith: { (self methodChange: #a class: 'MyClass' package: 'MyPackage') }) structuralTree first children
		             first.

	self deny: classNode hasChange.
	self assert: classNode label equals: 'MyClass'
]
