"
I am the base of a review that shows only the uncommitted changes: the last commit.

OCRIcebergReader asks me for my commit (see #commitIn:by:), so all Iceberg code stays in the reader.
"
Class {
	#name : 'OCRLastCommitBase',
	#superclass : 'Object',
	#category : 'ObscureCodeReviewer-Model',
	#package : 'ObscureCodeReviewer',
	#tag : 'Model'
}

{ #category : 'reading' }
OCRLastCommitBase >> commitIn: aRepository by: aReader [

	^ aReader lastCommitOf: aRepository
]

{ #category : 'accessing' }
OCRLastCommitBase >> description [
	"How I am shown in the window title and the feedback header."

	^ 'last commit'
]
