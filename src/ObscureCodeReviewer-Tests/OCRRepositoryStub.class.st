"
I am an Iceberg repository without git: a disk (location) and the names of the packages loaded from me, so OCRIcebergReader can turn the paths git names into file changes without a git repository.
"
Class {
	#name : 'OCRRepositoryStub',
	#superclass : 'Object',
	#instVars : [
		'location',
		'loadedPackageNames'
	],
	#category : 'ObscureCodeReviewer-Tests',
	#package : 'ObscureCodeReviewer-Tests'
}

{ #category : 'initialization' }
OCRRepositoryStub >> initialize [

	super initialize.
	loadedPackageNames := #(  )
]

{ #category : 'accessing' }
OCRRepositoryStub >> loadedPackageNames: someNames [

	loadedPackageNames := someNames
]

{ #category : 'accessing' }
OCRRepositoryStub >> loadedPackages [

	^ loadedPackageNames collect: [ :each | IcePackage named: each repository: self ]
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
OCRRepositoryStub >> subdirectoryPath [

	^ Path from: 'src'
]

{ #category : 'accessing' }
OCRRepositoryStub >> workingCopy [
	"IcePackage asks its repository for it; I play both roles."

	^ self
]
