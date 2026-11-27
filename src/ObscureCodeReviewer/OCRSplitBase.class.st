"
I am the base of a review that shows a whole branch, like a pull request: the commit where the current branch split from another branch (local, like 'main', or remote, like 'origin/main'). The review shows everything since then: the commits of the branch and the uncommitted changes.

	OCRSplitBase fromBranchNamed: 'main'

OCRIcebergReader asks me for my commit (see #commitIn:by:), so all Iceberg code stays in the reader.
"
Class {
	#name : 'OCRSplitBase',
	#superclass : 'Object',
	#instVars : [
		'branchName'
	],
	#category : 'ObscureCodeReviewer-Model',
	#package : 'ObscureCodeReviewer',
	#tag : 'Model'
}

{ #category : 'instance creation' }
OCRSplitBase class >> fromBranchNamed: aString [

	^ self new
		  setBranchName: aString;
		  yourself
]

{ #category : 'comparing' }
OCRSplitBase >> = anObject [

	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	^ branchName = anObject branchName
]

{ #category : 'accessing' }
OCRSplitBase >> branchName [

	^ branchName
]

{ #category : 'reading' }
OCRSplitBase >> commitIn: aRepository by: aReader [

	^ aReader splitPointOf: aRepository fromBranchNamed: branchName
]

{ #category : 'accessing' }
OCRSplitBase >> description [
	"How I am shown in the window title and the feedback header."

	^ 'split from ' , branchName
]

{ #category : 'comparing' }
OCRSplitBase >> hash [

	^ branchName hash
]

{ #category : 'initialization' }
OCRSplitBase >> setBranchName: aString [

	branchName := aString
]

{ #category : 'reading' }
OCRSplitBase >> warningIn: aRepository by: aReader [
	"Why I may be the wrong base, or an empty string: a local branch behind its upstream misses what the upstream merged."

	^ aReader warningIfBranchNamed: branchName isBehindIn: aRepository
]
