"
I am a change of a class definition (its slots, superclass, comment...). See OCRChange.
"
Class {
	#name : 'OCRClassChange',
	#superclass : 'OCRChange',
	#category : 'ObscureCodeReviewer-Model',
	#package : 'ObscureCodeReviewer',
	#tag : 'Model'
}

{ #category : 'image' }
OCRClassChange >> browse [
	"Not tested: it opens a window."

	^ self classInImage browse
]

{ #category : 'image' }
OCRClassChange >> classInImage [
	"The class in the image. Not tested: it reads the live system."

	^ self class environment classNamed: className
]

{ #category : 'testing' }
OCRClassChange >> isClassChange [

	^ true
]

{ #category : 'displaying' }
OCRClassChange >> name [

	^ className
]

{ #category : 'displaying' }
OCRClassChange >> reference [

	^ className
]
