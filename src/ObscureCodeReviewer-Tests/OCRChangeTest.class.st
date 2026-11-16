"
I test OCRChange.
"
Class {
	#name : 'OCRChangeTest',
	#superclass : 'TestCase',
	#category : 'ObscureCodeReviewer-Tests',
	#package : 'ObscureCodeReviewer-Tests'
}

{ #category : 'tests' }
OCRChangeTest >> testClassDefinitionReferenceIsClassName [

	| change |
	change := OCRChange modification
		          className: 'MyClass';
		          yourself.

	self assert: change isClassChange.
	self assert: change reference equals: 'MyClass'
]

{ #category : 'tests' }
OCRChangeTest >> testClassSideMethodReferenceIncludesClass [

	| change |
	change := OCRChange modification
		          className: 'MyClass class';
		          selector: #new;
		          yourself.

	self assert: change reference equals: 'MyClass class>>#new'
]

{ #category : 'tests' }
OCRChangeTest >> testExtensionHasItsOwnGroupName [

	| change |
	change := OCRChange addition
		          className: 'Object';
		          selector: #isMyThing;
		          yourself.
	change beExtension.

	self assert: change groupName equals: 'Object (extension)'.
	self assert: change reference equals: 'Object>>#isMyThing'
]

{ #category : 'tests' }
OCRChangeTest >> testKindIsSetByInstanceCreation [

	self assert: OCRChange addition isAddition.
	self assert: OCRChange modification isModification.
	self assert: OCRChange removal isRemoval.
	self deny: OCRChange addition isModification
]

{ #category : 'tests' }
OCRChangeTest >> testKindMarker [

	self assert: OCRChange addition kindMarker equals: '+'.
	self assert: OCRChange modification kindMarker equals: '~'.
	self assert: OCRChange removal kindMarker equals: '-'
]

{ #category : 'tests' }
OCRChangeTest >> testMethodReferenceIsClassAndSelector [

	| change |
	change := OCRChange modification
		          className: 'MyClass';
		          selector: #myMethod;
		          yourself.

	self assert: change reference equals: 'MyClass>>#myMethod'
]

{ #category : 'tests' }
OCRChangeTest >> testSourcesAreEmptyByDefault [

	| change |
	change := OCRChange addition.

	self assert: change oldSource equals: ''.
	self assert: change newSource equals: ''
]
