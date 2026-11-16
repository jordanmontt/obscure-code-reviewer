"
I am a change of one method. See OCRChange.
"
Class {
	#name : 'OCRMethodChange',
	#superclass : 'OCRChange',
	#instVars : [
		'selector'
	],
	#category : 'ObscureCodeReviewer-Model',
	#package : 'ObscureCodeReviewer',
	#tag : 'Model'
}

{ #category : 'testing' }
OCRMethodChange >> isMethodChange [

	^ true
]

{ #category : 'displaying' }
OCRMethodChange >> name [

	^ selector asString
]

{ #category : 'displaying' }
OCRMethodChange >> reference [

	^ className , '>>#' , selector
]

{ #category : 'accessing' }
OCRMethodChange >> selector [

	^ selector
]

{ #category : 'accessing' }
OCRMethodChange >> selector: aSymbol [

	selector := aSymbol
]
