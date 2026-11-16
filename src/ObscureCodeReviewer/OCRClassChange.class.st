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
