"
I am a git commit made of the files of a memory file system, so OCRIcebergReader can compare files without a git repository.
"
Class {
	#name : 'OCRCommitStub',
	#superclass : 'Object',
	#instVars : [
		'fileSystem'
	],
	#category : 'ObscureCodeReviewer-Tests',
	#package : 'ObscureCodeReviewer-Tests'
}

{ #category : 'accessing' }
OCRCommitStub >> fileSystem [

	^ fileSystem
]

{ #category : 'accessing' }
OCRCommitStub >> fileSystem: aFileReference [

	fileSystem := aFileReference
]
