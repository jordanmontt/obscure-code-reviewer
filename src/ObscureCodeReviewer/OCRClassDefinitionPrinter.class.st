"
I print a class definition in Pharo's fluid format, the one the System Browser shows:

	Object << #MyClass
		slots: { #a . #b };
		tag: 'Model';
		package: 'MyPackage'

Iceberg prints its class definitions in the old format (subclass:instanceVariableNames:...). The version of a class in the base commit is not in the image, so Pharo's FluidClassDefinitionPrinter, which needs a real class, cannot print it. I print from the Monticello definition (MCClassDefinition) that Iceberg keeps for both versions, following FluidClassDefinitionPrinter line for line, so both sides of a diff have the same format.

	OCRClassDefinitionPrinter sourceOf: anMCClassDefinition.			""""definition, blank line, comment""""
	OCRClassDefinitionPrinter classSideSourceOf: anMCClassDefinition.	""""Foo class << Foo class ...""""

Monticello writes a simple slot as its name and a complex one as its definition (#x => PropertySlot); see Class>>#asClassDefinition.
"
Class {
	#name : 'OCRClassDefinitionPrinter',
	#superclass : 'Object',
	#instVars : [
		'definition',
		'stream'
	],
	#category : 'ObscureCodeReviewer-Model',
	#package : 'ObscureCodeReviewer',
	#tag : 'Model'
}

{ #category : 'instance creation' }
OCRClassDefinitionPrinter class >> classSideSourceOf: anMCClassDefinition [

	^ (self on: anMCClassDefinition) classSideDefinitionString
]

{ #category : 'instance creation' }
OCRClassDefinitionPrinter class >> on: anMCClassDefinition [

	^ self new
		  setDefinition: anMCClassDefinition;
		  yourself
]

{ #category : 'instance creation' }
OCRClassDefinitionPrinter class >> sourceOf: anMCClassDefinition [
	"The class definition, then its comment after a blank line, as Iceberg shows it."

	^ (self on: anMCClassDefinition) source
]

{ #category : 'printing' }
OCRClassDefinitionPrinter >> classDefinitionString [
	"FluidClassDefinitionPrinter>>#classDefinitionString"

	^ String streamContents: [ :aStream |
		  stream := aStream.
		  stream
			  nextPutAll: self superclassName;
			  nextPutAll: ' << #';
			  nextPutAll: definition className.
		  definition layoutClassName = #FixedLayout ifFalse: [
			  stream
				  crtab;
				  nextPutAll: 'layout: ';
				  nextPutAll: definition layoutClassName;
				  nextPut: $; ].
		  definition hasTraitComposition ifTrue: [ self printTraits: definition traitCompositionString ending: ';' ].
		  (self showsSlots: definition instVarNames) ifTrue: [
			  self printSlots: definition instVarNames.
			  stream nextPut: $; ].
		  definition classVarNames ifNotEmpty: [ :names | self printSharedVariables: names ].
		  definition poolDictionaries ifNotEmpty: [ :names | self printSharedPools: names ].
		  self printTag.
		  stream
			  crtab;
			  nextPutAll: 'package: ';
			  print: definition packageName asString ]
]

{ #category : 'printing' }
OCRClassDefinitionPrinter >> classSideDefinitionString [
	"FluidClassDefinitionPrinter>>#metaclassDefinitionString"

	^ String streamContents: [ :aStream |
		  | showsSlots |
		  stream := aStream.
		  stream
			  nextPutAll: self superclassName;
			  nextPutAll: ' class << ';
			  nextPutAll: definition className;
			  nextPutAll: ' class'.
		  showsSlots := self showsSlots: definition classInstVarNames.
		  definition hasClassTraitComposition ifTrue: [
			  self printTraits: definition classTraitCompositionString ending: (showsSlots
				   ifTrue: [ ';' ]
				   ifFalse: [ '' ]) ].
		  showsSlots ifTrue: [ self printSlots: definition classInstVarNames ] ]
]

{ #category : 'printing' }
OCRClassDefinitionPrinter >> isComplex: aString [

	^ aString includesSubstring: '=>'
]

{ #category : 'printing' }
OCRClassDefinitionPrinter >> printSharedPools: someNames [

	stream
		crtab;
		nextPutAll: 'sharedPools: {'.
	someNames
		do: [ :each |
			stream
				space;
				nextPutAll: each;
				space ]
		separatedBy: [ stream nextPut: $. ].
	stream nextPutAll: '};'
]

{ #category : 'printing' }
OCRClassDefinitionPrinter >> printSharedVariables: someNames [
	"FluidClassDefinitionPrinter>>#classVariableDefinitionsOn:"

	| isComplex |
	stream
		crtab;
		nextPutAll: 'sharedVariables: {'.
	isComplex := false.
	someNames
		do: [ :each |
			stream
				space;
				nextPutAll: (self variableDefinition: each);
				space.
			isComplex := self isComplex: each ]
		separatedBy: [
			stream nextPut: $..
			isComplex ifTrue: [
				stream
					cr;
					tab;
					tab;
					tab;
					tab ] ].
	stream nextPutAll: '};'
]

{ #category : 'printing' }
OCRClassDefinitionPrinter >> printSlots: someNames [
	"FluidClassDefinitionPrinter>>#slotDefinitionsOn:: one slot per line when there are many, or complex ones."

	| oneSlotPerLine |
	stream
		crtab;
		nextPutAll: 'slots: {'.
	oneSlotPerLine := someNames size ~= 1 and: [ someNames size > 8 or: [ someNames anySatisfy: [ :each | self isComplex: each ] ] ].
	oneSlotPerLine ifTrue: [ self shiftSlot ].
	someNames
		do: [ :each |
			stream
				space;
				nextPutAll: (self variableDefinition: each);
				space.
			oneSlotPerLine := oneSlotPerLine or: [ self isComplex: each ] ]
		separatedBy: [
			stream nextPut: $..
			oneSlotPerLine ifTrue: [ self shiftSlot ] ].
	stream nextPut: $}
]

{ #category : 'printing' }
OCRClassDefinitionPrinter >> printTag [
	"Monticello has no tag for a class in its package's root tag, which is not printed."

	definition tagName isEmptyOrNil ifTrue: [ ^ self ].
	stream
		crtab;
		nextPutAll: 'tag: ';
		print: definition tagName asString;
		nextPut: $;
]

{ #category : 'printing' }
OCRClassDefinitionPrinter >> printTraits: aCompositionString ending: aString [

	stream
		crtab;
		nextPutAll: 'traits: {';
		nextPutAll: aCompositionString;
		nextPut: $};
		nextPutAll: aString
]

{ #category : 'initialization' }
OCRClassDefinitionPrinter >> setDefinition: anMCClassDefinition [

	definition := anMCClassDefinition
]

{ #category : 'printing' }
OCRClassDefinitionPrinter >> shiftSlot [

	stream
		cr;
		tab;
		tab;
		tab
]

{ #category : 'printing' }
OCRClassDefinitionPrinter >> showsSlots: someNames [
	"Like Pharo's printer, empty slots are shown or not depending on its setting."

	^ ClassDefinitionPrinter displayEmptySlots or: [ someNames isNotEmpty ]
]

{ #category : 'printing' }
OCRClassDefinitionPrinter >> source [

	| comment |
	comment := definition comment asString.
	comment ifEmpty: [ ^ self classDefinitionString ].
	^ self classDefinitionString , String cr , String cr , comment
]

{ #category : 'printing' }
OCRClassDefinitionPrinter >> superclassName [
	"Monticello has no superclass name for a root class, such as a subclass of nil."

	^ definition superclassName ifNil: [ 'nil' ]
]

{ #category : 'printing' }
OCRClassDefinitionPrinter >> variableDefinition: aString [
	"Monticello writes a simple variable as its name, a complex one as its definition (#x => PropertySlot)."

	aString first = $# ifTrue: [ ^ aString ].
	^ '#' , aString
]
