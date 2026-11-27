"
I test the Structure tree of a review (OCRStructuralTreeBuilder): sections, packages, classes and methods, their order, icons and labels, and what can be browsed.
"
Class {
	#name : 'OCRStructuralTreeTest',
	#superclass : 'OCRTestCase',
	#category : 'ObscureCodeReviewer-Tests',
	#package : 'ObscureCodeReviewer-Tests'
}

{ #category : 'helpers' }
OCRStructuralTreeTest >> classChange: aClassName package: aPackageName [

	^ OCRClassChange modification
		  packageName: aPackageName;
		  className: aClassName;
		  yourself
]

{ #category : 'helpers' }
OCRStructuralTreeTest >> codePackagesOf: someChanges [
	"The package nodes of the Code section."

	^ (self reviewWith: someChanges) structuralTree first children
]

{ #category : 'helpers' }
OCRStructuralTreeTest >> methodChange: aSelector class: aClassName package: aPackageName [

	^ OCRMethodChange modification
		  packageName: aPackageName;
		  className: aClassName;
		  selector: aSelector;
		  yourself
]

{ #category : 'helpers' }
OCRStructuralTreeTest >> namesOf: someNodes [

	^ someNodes collect: [ :each | each name ] as: Array
]

{ #category : 'tests' }
OCRStructuralTreeTest >> testAClassNotInTheImageCannotBeBrowsed [

	| classNode |
	classNode := (self reviewWith: { (self methodChange: #a class: 'OCRNoSuchClass' package: 'MyPackage') }) structuralTree first
		             children first children first.

	self deny: classNode canBrowse
]

{ #category : 'tests' }
OCRStructuralTreeTest >> testAnUnchangedClassCanBeBrowsed [

	| package |
	package := (self reviewWith: {
		            (self methodChange: #a class: 'OCRStructuralTreeTest' package: 'MyPackage').
		            (self methodChange: #b class: 'OCRStructuralTreeTest class' package: 'MyPackage') }) structuralTree first children
		           first.

	self assert: package children first canBrowse.
	self assert: package children second canBrowse
]

{ #category : 'tests' }
OCRStructuralTreeTest >> testChangedClassDefinitionIsTheClassNode [

	| classChange classNode |
	classChange := self classChange: 'MyClass' package: 'MyPackage'.
	classNode := (self codePackagesOf: {
		              classChange.
		              (self methodChange: #a class: 'MyClass' package: 'MyPackage') }) first children first.

	self assert: classNode change equals: classChange.
	self assert: (self namesOf: classNode children) equals: #( 'a' )
]

{ #category : 'tests' }
OCRStructuralTreeTest >> testChangesAreSplitIntoCodeTestsAndBaseline [

	| tree |
	tree := (self reviewWith: {
		         (self methodChange: #baseline: class: 'BaselineOfMyProject' package: 'BaselineOfMyProject').
		         (self methodChange: #testA class: 'MyTest' package: 'MyProject-Tests').
		         (self methodChange: #a class: 'MyClass' package: 'MyProject') }) structuralTree.

	self assert: (self namesOf: tree) equals: #( 'Code' 'Tests' 'Baseline' ).
	self assert: (self namesOf: tree second children) equals: #( 'MyProject-Tests' )
]

{ #category : 'tests' }
OCRStructuralTreeTest >> testClassSideMethodsHaveTheirOwnNode [

	| packages |
	packages := self codePackagesOf: {
		            (self methodChange: #a class: 'MyClass' package: 'MyPackage').
		            (self methodChange: #new class: 'MyClass class' package: 'MyPackage') }.

	self assert: (self namesOf: packages first children) equals: #( 'MyClass' 'MyClass class' )
]

{ #category : 'tests' }
OCRStructuralTreeTest >> testEmptyReview [

	| review |
	review := self reviewWith: #(  ).

	self assert: review isEmpty.
	self assert: review structuralTree isEmpty
]

{ #category : 'tests' }
OCRStructuralTreeTest >> testEmptySectionsAreLeftOut [

	| tree |
	tree := (self reviewWith: { (self methodChange: #a class: 'MyClass' package: 'MyProject') }) structuralTree.

	self assert: (self namesOf: tree) equals: #( 'Code' )
]

{ #category : 'tests' }
OCRStructuralTreeTest >> testExtensionMethodsHaveTheirOwnNode [

	| extension packages |
	extension := self methodChange: #isMyThing class: 'Object' package: 'MyPackage'.
	extension beExtension.
	packages := self codePackagesOf: { extension }.

	self assert: (self namesOf: packages first children) equals: #( 'Object (extension)' )
]

{ #category : 'tests' }
OCRStructuralTreeTest >> testMethodNodeLabelShowsKind [

	| added methodNode |
	added := OCRMethodChange addition
		         packageName: 'MyPackage';
		         className: 'MyClass';
		         selector: #myMethod;
		         yourself.
	methodNode := (self codePackagesOf: { added }) first children first children first.

	self assert: methodNode label equals: '+ myMethod'
]

{ #category : 'tests' }
OCRStructuralTreeTest >> testMethodsAreSortedBySelector [

	| classNode |
	classNode := (self codePackagesOf: {
		              (self methodChange: #zeta class: 'MyClass' package: 'MyPackage').
		              (self methodChange: #alpha class: 'MyClass' package: 'MyPackage') }) first children first.

	self assert: (self namesOf: classNode children) equals: #( 'alpha' 'zeta' )
]

{ #category : 'tests' }
OCRStructuralTreeTest >> testNodesHaveIconsForWhatTheyAre [

	| extension section package |
	extension := self methodChange: #isMyThing class: 'Object' package: 'MyProject'.
	extension beExtension.
	section := (self reviewWith: {
		            (self methodChange: #a class: 'MyClass' package: 'MyProject').
		            extension }) structuralTree first.
	package := section children first.

	self assert: section iconName equals: #smallSystemBrowser.
	self assert: package iconName equals: #package.
	self assert: package children first iconName equals: #class.
	self assert: package children first children first iconName equals: #page.
	self assert: package children second iconName equals: #group
]

{ #category : 'tests' }
OCRStructuralTreeTest >> testPackagesAndClassesAreSortedByName [

	| packages |
	packages := self codePackagesOf: {
		            (self methodChange: #a class: 'Zeta' package: 'PackageB').
		            (self methodChange: #a class: 'Beta' package: 'PackageA').
		            (self methodChange: #a class: 'Alpha' package: 'PackageB') }.

	self assert: (self namesOf: packages) equals: #( 'PackageA' 'PackageB' ).
	self assert: (self namesOf: packages second children) equals: #( 'Alpha' 'Zeta' )
]

{ #category : 'tests' }
OCRStructuralTreeTest >> testSectionsAndPackagesCannotBeBrowsed [

	| section |
	section := (self reviewWith: { (self methodChange: #a class: 'OCRStructuralTreeTest' package: 'MyPackage') }) structuralTree
		           first.

	self deny: section canBrowse.
	self deny: section children first canBrowse
]

{ #category : 'tests' }
OCRStructuralTreeTest >> testSectionsAndPackagesHaveNoChange [

	| section |
	section := (self reviewWith: { (self methodChange: #a class: 'MyClass' package: 'MyPackage') }) structuralTree first.

	self deny: section hasChange.
	self deny: section children first hasChange
]

{ #category : 'tests' }
OCRStructuralTreeTest >> testTreeGroupsMethodsByPackageThenClass [

	| packages |
	packages := self codePackagesOf: {
		            (self methodChange: #a class: 'ClassA' package: 'PackageA').
		            (self methodChange: #b class: 'ClassB' package: 'PackageA') }.

	self assert: (self namesOf: packages) equals: #( 'PackageA' ).
	self assert: (self namesOf: packages first children) equals: #( 'ClassA' 'ClassB' ).
	self assert: (self namesOf: packages first children first children) equals: #( 'a' )
]

{ #category : 'tests' }
OCRStructuralTreeTest >> testUnchangedClassNodeHasNoChange [

	| classNode |
	classNode := (self codePackagesOf: { (self methodChange: #a class: 'MyClass' package: 'MyPackage') }) first children first.

	self deny: classNode hasChange.
	self assert: classNode label equals: 'MyClass'
]
