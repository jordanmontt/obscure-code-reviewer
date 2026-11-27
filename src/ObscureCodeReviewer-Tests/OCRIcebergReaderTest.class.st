"
I test OCRIcebergReader on stub repositories and commits whose files are in memory.
"
Class {
	#name : 'OCRIcebergReaderTest',
	#superclass : 'TestCase',
	#category : 'ObscureCodeReviewer-Tests',
	#package : 'ObscureCodeReviewer-Tests'
}

{ #category : 'private' }
OCRIcebergReaderTest >> commitWith: someFiles [

	^ OCRCommitStub new
		  fileSystem: (self fileSystemWith: someFiles);
		  yourself
]

{ #category : 'private' }
OCRIcebergReaderTest >> fileSystemWith: someFiles [
	"someFiles maps a path to its contents."

	| root |
	root := FileSystem memory root.
	someFiles keysAndValuesDo: [ :path :contents |
		| file |
		file := root resolve: path.
		file parent ensureCreateDirectory.
		file writeStreamDo: [ :stream | stream nextPutAll: contents ] ].
	^ root
]

{ #category : 'tests' }
OCRIcebergReaderTest >> testFileChangesAreTheChangedFilesOutsideTheCode [
	"Git names the paths; a file of a loaded package is reviewed as code, and a file back to its old bytes is not a change."

	| base repository changes |
	base := self commitWith: {
		        ('docs/progress.md' -> 'old').
		        ('README.md' -> 'same').
		        ('OLD.md' -> 'gone').
		        ('src/MyPackage/A.class.st' -> 'old code') } asDictionary.
	repository := OCRRepositoryStub new
		              loadedPackageNames: #( 'MyPackage' );
		              location: (self fileSystemWith: {
			               ('docs/progress.md' -> 'new').
			               ('README.md' -> 'same').
			               ('docs/SEL.md' -> 'added').
			               ('src/MyPackage/A.class.st' -> 'new code') } asDictionary);
		              yourself.

	changes := OCRIcebergReader new
		           fileChanges: #( 'README.md' 'docs/progress.md' 'docs/SEL.md' 'OLD.md' 'src/MyPackage/A.class.st' )
		           in: repository
		           since: base.

	self assert: (changes collect: [ :each | each reference -> each kind ] as: Array) equals: {
		('OLD.md' -> #removal).
		('docs/SEL.md' -> #addition).
		('docs/progress.md' -> #modification) }
]
