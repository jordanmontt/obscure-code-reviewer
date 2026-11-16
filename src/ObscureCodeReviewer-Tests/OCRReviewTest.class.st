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
OCRReviewTest >> codePackagesOf: someChanges [
	"The package nodes of the Code section."

	^ (self reviewWith: someChanges) structuralTree first children
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
	classNode := (self codePackagesOf: {
		              classChange.
		              (self methodChange: #a class: 'MyClass' package: 'MyPackage') }) first children first.

	self assert: classNode change equals: classChange.
	self assert: (self namesOf: classNode children) equals: #( 'a' )
]

{ #category : 'tests' }
OCRReviewTest >> testChangesAreSplitIntoCodeTestsAndBaseline [

	| tree |
	tree := (self reviewWith: {
		         (self methodChange: #baseline: class: 'BaselineOfMyProject' package: 'BaselineOfMyProject').
		         (self methodChange: #testA class: 'MyTest' package: 'MyProject-Tests').
		         (self methodChange: #a class: 'MyClass' package: 'MyProject') }) structuralTree.

	self assert: (self namesOf: tree) equals: #( 'Code' 'Tests' 'Baseline' ).
	self assert: (self namesOf: tree second children) equals: #( 'MyProject-Tests' )
]

{ #category : 'tests' }
OCRReviewTest >> testClassSideMethodsHaveTheirOwnNode [

	| packages |
	packages := self codePackagesOf: {
		            (self methodChange: #a class: 'MyClass' package: 'MyPackage').
		            (self methodChange: #new class: 'MyClass class' package: 'MyPackage') }.

	self assert: (self namesOf: packages first children) equals: #( 'MyClass' 'MyClass class' )
]

{ #category : 'tests' }
OCRReviewTest >> testEmptyReview [

	| review |
	review := self reviewWith: #(  ).

	self assert: review isEmpty.
	self assert: review structuralTree isEmpty
]

{ #category : 'tests' }
OCRReviewTest >> testEmptySectionsAreLeftOut [

	| tree |
	tree := (self reviewWith: { (self methodChange: #a class: 'MyClass' package: 'MyProject') }) structuralTree.

	self assert: (self namesOf: tree) equals: #( 'Code' )
]

{ #category : 'tests' }
OCRReviewTest >> testExtensionMethodsHaveTheirOwnNode [

	| extension packages |
	extension := self methodChange: #isMyThing class: 'Object' package: 'MyPackage'.
	extension beExtension.
	packages := self codePackagesOf: { extension }.

	self assert: (self namesOf: packages first children) equals: #( 'Object (extension)' )
]

{ #category : 'tests' }
OCRReviewTest >> testMethodNodeLabelShowsKind [

	| added methodNode |
	added := OCRChange addition
		         packageName: 'MyPackage';
		         className: 'MyClass';
		         selector: #myMethod;
		         yourself.
	methodNode := (self codePackagesOf: { added }) first children first children first.

	self assert: methodNode label equals: '+ myMethod'
]

{ #category : 'tests' }
OCRReviewTest >> testMethodsAreSortedBySelector [

	| classNode |
	classNode := (self codePackagesOf: {
		              (self methodChange: #zeta class: 'MyClass' package: 'MyPackage').
		              (self methodChange: #alpha class: 'MyClass' package: 'MyPackage') }) first children first.

	self assert: (self namesOf: classNode children) equals: #( 'alpha' 'zeta' )
]

{ #category : 'tests' }
OCRReviewTest >> testNodesHaveIconsForWhatTheyAre [

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
OCRReviewTest >> testPackagesAndClassesAreSortedByName [

	| packages |
	packages := self codePackagesOf: {
		            (self methodChange: #a class: 'Zeta' package: 'PackageB').
		            (self methodChange: #a class: 'Beta' package: 'PackageA').
		            (self methodChange: #a class: 'Alpha' package: 'PackageB') }.

	self assert: (self namesOf: packages) equals: #( 'PackageA' 'PackageB' ).
	self assert: (self namesOf: packages second children) equals: #( 'Alpha' 'Zeta' )
]

{ #category : 'tests' }
OCRReviewTest >> testTreeGroupsMethodsByPackageThenClass [

	| packages |
	packages := self codePackagesOf: {
		            (self methodChange: #a class: 'ClassA' package: 'PackageA').
		            (self methodChange: #b class: 'ClassB' package: 'PackageA') }.

	self assert: (self namesOf: packages) equals: #( 'PackageA' ).
	self assert: (self namesOf: packages first children) equals: #( 'ClassA' 'ClassB' ).
	self assert: (self namesOf: packages first children first children) equals: #( 'a' )
]

{ #category : 'tests' }
OCRReviewTest >> testUnchangedClassNodeHasNoChange [

	| classNode |
	classNode := (self codePackagesOf: { (self methodChange: #a class: 'MyClass' package: 'MyPackage') }) first children first.

	self deny: classNode hasChange.
	self assert: classNode label equals: 'MyClass'
]
