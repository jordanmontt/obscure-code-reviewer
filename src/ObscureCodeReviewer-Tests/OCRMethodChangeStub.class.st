"
I am a method change whose edit compiles without touching the image: saving an edit by hand can be tested in memory.
"
Class {
	#name : 'OCRMethodChangeStub',
	#superclass : 'OCRMethodChange',
	#category : 'ObscureCodeReviewer-Tests',
	#package : 'ObscureCodeReviewer-Tests'
}

{ #category : 'editing' }
OCRMethodChangeStub >> compileInImage: aString notifying: aRequestor [

	^ true
]
