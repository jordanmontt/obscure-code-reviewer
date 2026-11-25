"
I am an Iceberg repository without git or loaded packages: a disk (location), git's HEAD commit (headCommit) and the commit Iceberg believes is checked out (referenceCommit), which lags behind HEAD after a commit made outside Iceberg.
"
Class {
	#name : 'OCRRepositoryStub',
	#superclass : 'Object',
	#instVars : [
		'location',
		'referenceCommit',
		'headCommit'
	],
	#category : 'ObscureCodeReviewer-Tests',
	#package : 'ObscureCodeReviewer-Tests'
}

{ #category : 'accessing' }
OCRRepositoryStub >> headCommit [

	^ headCommit
]

{ #category : 'accessing' }
OCRRepositoryStub >> headCommit: aCommit [

	headCommit := aCommit
]

{ #category : 'accessing' }
OCRRepositoryStub >> loadedPackages [

	^ #(  )
]

{ #category : 'accessing' }
OCRRepositoryStub >> location [

	^ location
]

{ #category : 'accessing' }
OCRRepositoryStub >> location: aFileReference [

	location := aFileReference
]

{ #category : 'accessing' }
OCRRepositoryStub >> referenceCommit [

	^ referenceCommit
]

{ #category : 'accessing' }
OCRRepositoryStub >> referenceCommit: aCommit [

	referenceCommit := aCommit
]

{ #category : 'accessing' }
OCRRepositoryStub >> subdirectoryPath [

	^ Path from: 'src'
]

{ #category : 'accessing' }
OCRRepositoryStub >> workingCopy [
	"Iceberg's working copy answers referenceCommit; I play both roles."

	^ self
]
