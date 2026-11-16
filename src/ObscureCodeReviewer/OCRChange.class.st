"
I am one changed item of a review: a method or a class definition that was added, modified, or removed between the base and the image.

I am a plain object. OCRIcebergReader creates me from an Iceberg diff, and tests create me by hand:

	OCRChange modification
		packageName: 'MyPackage';
		className: 'MyClass';
		selector: #myMethod;
		oldSource: 'myMethod ^ 1';
		newSource: 'myMethod ^ 2';
		yourself

- className is 'MyClass class' for class-side methods.
- selector is nil when I represent a class definition.
"
Class {
	#name : 'OCRChange',
	#superclass : 'Object',
	#instVars : [
		'kind',
		'packageName',
		'className',
		'selector',
		'isExtension',
		'oldSource',
		'newSource'
	],
	#category : 'ObscureCodeReviewer-Model',
	#package : 'ObscureCodeReviewer',
	#tag : 'Model'
}

{ #category : 'instance creation' }
OCRChange class >> addition [

	^ self new
		  kind: #addition;
		  yourself
]

{ #category : 'instance creation' }
OCRChange class >> modification [

	^ self new
		  kind: #modification;
		  yourself
]

{ #category : 'instance creation' }
OCRChange class >> removal [

	^ self new
		  kind: #removal;
		  yourself
]

{ #category : 'accessing' }
OCRChange >> beExtension [
	"Mark me as an extension method: my class is defined in another package."

	isExtension := true
]

{ #category : 'accessing' }
OCRChange >> className [

	^ className
]

{ #category : 'accessing' }
OCRChange >> className: aString [

	className := aString
]

{ #category : 'displaying' }
OCRChange >> groupName [
	"The name of the tree node grouping me inside my package."

	self isExtension ifTrue: [ ^ className , ' (extension)' ].
	^ className
]

{ #category : 'initialization' }
OCRChange >> initialize [

	super initialize.
	isExtension := false.
	oldSource := ''.
	newSource := ''
]

{ #category : 'testing' }
OCRChange >> isAddition [

	^ kind = #addition
]

{ #category : 'testing' }
OCRChange >> isClassChange [

	^ selector isNil
]

{ #category : 'testing' }
OCRChange >> isExtension [

	^ isExtension
]

{ #category : 'testing' }
OCRChange >> isMethodChange [

	^ selector notNil
]

{ #category : 'testing' }
OCRChange >> isModification [

	^ kind = #modification
]

{ #category : 'testing' }
OCRChange >> isRemoval [

	^ kind = #removal
]

{ #category : 'accessing' }
OCRChange >> kind [

	^ kind
]

{ #category : 'accessing' }
OCRChange >> kind: aSymbol [
	"One of #addition, #modification or #removal."

	kind := aSymbol
]

{ #category : 'displaying' }
OCRChange >> kindDescription [
	"How my kind is written in review feedback."

	self isAddition ifTrue: [ ^ 'added' ].
	self isRemoval ifTrue: [ ^ 'removed' ].
	^ 'modified'
]

{ #category : 'displaying' }
OCRChange >> kindMarker [

	self isAddition ifTrue: [ ^ '+' ].
	self isRemoval ifTrue: [ ^ '-' ].
	^ '~'
]

{ #category : 'displaying' }
OCRChange >> name [
	"The name shown for me in the changes tree."

	self isMethodChange ifTrue: [ ^ selector asString ].
	^ className
]

{ #category : 'accessing' }
OCRChange >> newSource [
	"The source in the image. Empty for a removal."

	^ newSource
]

{ #category : 'accessing' }
OCRChange >> newSource: aString [

	newSource := aString
]

{ #category : 'accessing' }
OCRChange >> oldSource [
	"The source in the base commit. Empty for an addition."

	^ oldSource
]

{ #category : 'accessing' }
OCRChange >> oldSource: aString [

	oldSource := aString
]

{ #category : 'accessing' }
OCRChange >> packageName [

	^ packageName
]

{ #category : 'accessing' }
OCRChange >> packageName: aString [

	packageName := aString
]

{ #category : 'printing' }
OCRChange >> printOn: aStream [

	aStream
		nextPutAll: self reference;
		nextPutAll: ' (';
		nextPutAll: kind;
		nextPutAll: ')'
]

{ #category : 'displaying' }
OCRChange >> reference [
	"How I am written in review feedback and in review guides, e.g. 'MyClass>>#myMethod'."

	self isMethodChange ifTrue: [ ^ className , '>>#' , selector ].
	^ className
]

{ #category : 'accessing' }
OCRChange >> selector [

	^ selector
]

{ #category : 'accessing' }
OCRChange >> selector: aSymbol [

	selector := aSymbol
]
