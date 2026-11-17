"
I test that OCRClassDefinitionPrinter prints a Monticello class definition exactly as Pharo's FluidClassDefinitionPrinter prints the class itself: I convert real classes with Class>>#asClassDefinition and compare both texts.
"
Class {
	#name : 'OCRClassDefinitionPrinterTest',
	#superclass : 'TestCase',
	#category : 'ObscureCodeReviewer-Tests',
	#package : 'ObscureCodeReviewer-Tests'
}

{ #category : 'helpers' }
OCRClassDefinitionPrinterTest >> assertPrintsClassSideLikePharo: aClass [

	self
		assert: (OCRClassDefinitionPrinter classSideSourceOf: aClass asClassDefinition)
		equals: (ClassDefinitionPrinter fluid for: aClass class) metaclassDefinitionString
]

{ #category : 'helpers' }
OCRClassDefinitionPrinterTest >> assertPrintsLikePharo: aClass [

	self
		assert: (OCRClassDefinitionPrinter on: aClass asClassDefinition) classDefinitionString
		equals: (ClassDefinitionPrinter fluid for: aClass) classDefinitionString
]

{ #category : 'tests' }
OCRClassDefinitionPrinterTest >> testClassSide [

	self assertPrintsClassSideLikePharo: OCRBinaryFileChange.
	self assertPrintsClassSideLikePharo: TestCase
]

{ #category : 'tests' }
OCRClassDefinitionPrinterTest >> testCommentGoesBelowTheDefinition [

	| source |
	source := OCRClassDefinitionPrinter sourceOf: OCRBinaryFileChange asClassDefinition.

	self assert: (source beginsWith: 'OCRFileChange << #OCRBinaryFileChange').
	self assert: (source endsWith: String cr , String cr , OCRBinaryFileChange comment)
]

{ #category : 'tests' }
OCRClassDefinitionPrinterTest >> testComplexSlots [

	self assertPrintsLikePharo: SpPresenter
]

{ #category : 'tests' }
OCRClassDefinitionPrinterTest >> testManySlots [

	self assertPrintsLikePharo: OCRReviewPresenter
]

{ #category : 'tests' }
OCRClassDefinitionPrinterTest >> testNoSlots [

	self assertPrintsLikePharo: OCRClassChange
]

{ #category : 'tests' }
OCRClassDefinitionPrinterTest >> testSharedVariables [

	self assertPrintsLikePharo: ClassDefinitionPrinter
]

{ #category : 'tests' }
OCRClassDefinitionPrinterTest >> testSharedVariablesAreSortedLikeMonticello [
	"Pharo prints class variables in the order of its dictionary; Monticello, and so git, keeps them sorted, which keeps the diff stable."

	self assert: ((OCRClassDefinitionPrinter on: TestCase asClassDefinition) classDefinitionString includesSubstring:
		 'sharedVariables: { #DefaultTimeLimit . #HistoryAnnouncer };')
]

{ #category : 'tests' }
OCRClassDefinitionPrinterTest >> testSlotsAndTag [

	self assertPrintsLikePharo: OCRBinaryFileChange
]

{ #category : 'tests' }
OCRClassDefinitionPrinterTest >> testTraits [

	self assertPrintsLikePharo: SpAbstractListPresenter.
	self assertPrintsLikePharo: SpPresenter
]

{ #category : 'tests' }
OCRClassDefinitionPrinterTest >> testVariableLayout [

	self assertPrintsLikePharo: Array
]
