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

{ #category : 'displaying' }
OCRMethodChange >> behaviorForHighlighting [
	"The class my source is highlighted for, so its instance variables are known; Object when my class is no longer in the image."

	| instanceSide |
	instanceSide := self class environment at: (className copyUpTo: Character space) asSymbol ifAbsent: [ ^ Object ].
	^ (className endsWith: ' class')
		  ifTrue: [ instanceSide class ]
		  ifFalse: [ instanceSide ]
]

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

{ #category : 'displaying' }
OCRMethodChange >> isProtocolLine: aString [
	"Whether aString is the line Iceberg writes above a method: its protocol between double quotes."

	^ aString size >= 2 and: [ aString first = $" and: [ aString last = $" and: [ (aString occurrencesOf: $") = 2 ] ] ]
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

{ #category : 'displaying' }
OCRMethodChange >> show: aSource aloneTitled: aTitle in: aChangeArea [
	"Iceberg writes my protocol as a comment line above my code (IceMethodDefinition>>#contents). In a diff that line shows a change of protocol; shown alone, the protocol goes into the title and the code starts at the selector."

	| firstLine |
	firstLine := aSource lines ifEmpty: [ '' ] ifNotEmpty: [ :lines | lines first ].
	(self isProtocolLine: firstLine) ifFalse: [ ^ super show: aSource aloneTitled: aTitle in: aChangeArea ].
	aChangeArea
		showSource: ((aSource allButFirst: firstLine size) trimLeft: [ :each | String crlf includes: each ])
		titled: aTitle , ' — protocol: ' , (firstLine copyFrom: 2 to: firstLine size - 1)
		of: self
]

{ #category : 'displaying' }
OCRMethodChange >> styleSource: aCodePresenter [

	aCodePresenter beForBehavior: self behaviorForHighlighting
]
