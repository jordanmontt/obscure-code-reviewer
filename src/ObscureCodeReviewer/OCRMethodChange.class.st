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

{ #category : 'image' }
OCRMethodChange >> browse [
	"Not tested: it opens a window."

	^ self methodInImage browse
]

{ #category : 'editing' }
OCRMethodChange >> compileInImage: aString notifying: aRequestor [
	"Compile aString in my method's class, keeping its protocol. Answer whether it compiled;
	when it did not, aRequestor (the code editor) shows the error. Not tested: it changes the live system."

	| method |
	method := self methodInImage.
	^ (method methodClass
		   compile: aString
		   classified: method protocolName
		   withStamp: DateAndTime now
		   notifying: aRequestor
		   logSource: true) isNotNil
]

{ #category : 'testing' }
OCRMethodChange >> isEditable [
	"A removed method is not in the image any more, so there is nothing to edit."

	^ self isRemoval not
]

{ #category : 'testing' }
OCRMethodChange >> isMethodChange [

	^ true
]

{ #category : 'image' }
OCRMethodChange >> methodInImage [
	"The method in the image. Not tested: it reads the live system."

	^ (self class environment classNamed: className) >> selector
]

{ #category : 'displaying' }
OCRMethodChange >> name [

	^ selector asString
]

{ #category : 'displaying' }
OCRMethodChange >> reference [

	^ '{1}>>#{2}' format: {
		  className.
		  selector }
]

{ #category : 'accessing' }
OCRMethodChange >> selector [

	^ selector
]

{ #category : 'accessing' }
OCRMethodChange >> selector: aSymbol [

	selector := aSymbol
]
