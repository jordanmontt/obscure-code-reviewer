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
	change := OCRClassChange modification
		          className: 'MyClass';
		          yourself.

	self assert: change isClassChange.
	self assert: change reference equals: 'MyClass'
]

{ #category : 'tests' }
OCRChangeTest >> testClassSideMethodReferenceIncludesClass [

	| change |
	change := OCRMethodChange modification
		          className: 'MyClass class';
		          selector: #new;
		          yourself.

	self assert: change reference equals: 'MyClass class>>#new'
]

{ #category : 'tests' }
OCRChangeTest >> testExtensionHasItsOwnGroupName [

	| change |
	change := OCRMethodChange addition
		          className: 'Object';
		          selector: #isMyThing;
		          yourself.
	change beExtension.

	self assert: change groupName equals: 'Object (extension)'.
	self assert: change reference equals: 'Object>>#isMyThing'
]

{ #category : 'tests' }
OCRChangeTest >> testKindIsSetByInstanceCreation [

	self assert: OCRMethodChange addition isAddition.
	self assert: OCRMethodChange modification isModification.
	self assert: OCRMethodChange removal isRemoval.
	self deny: OCRMethodChange addition isModification
]

{ #category : 'tests' }
OCRChangeTest >> testKindMarker [

	self assert: OCRMethodChange addition kindMarker equals: '+'.
	self assert: OCRMethodChange modification kindMarker equals: '~'.
	self assert: OCRMethodChange removal kindMarker equals: '-'
]

{ #category : 'tests' }
OCRChangeTest >> testMethodAndClassChangesSayWhatTheyAre [

	self assert: OCRMethodChange modification isMethodChange.
	self deny: OCRMethodChange modification isClassChange.
	self assert: OCRClassChange modification isClassChange.
	self deny: OCRClassChange modification isMethodChange
]

{ #category : 'tests' }
OCRChangeTest >> testMethodReferenceIsClassAndSelector [

	| change |
	change := OCRMethodChange modification
		          className: 'MyClass';
		          selector: #myMethod;
		          yourself.

	self assert: change reference equals: 'MyClass>>#myMethod'
]

{ #category : 'tests' }
OCRChangeTest >> testSourcesAreEmptyByDefault [

	| change |
	change := OCRMethodChange addition.

	self assert: change oldSource equals: ''.
	self assert: change newSource equals: ''
]
