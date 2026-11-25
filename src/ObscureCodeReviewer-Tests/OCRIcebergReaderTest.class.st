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
OCRIcebergReaderTest >> testFileChangesIncludeAFileOfAGitCommitIcebergDoesNotKnow [
	"After a commit made with git itself, Iceberg's reference commit is behind HEAD. A nested file added by that commit is still in the diff: an addition since the base."

	| base repository changes |
	base := self commitWith: { ('docs/progress.md' -> 'old') } asDictionary.
	repository := OCRRepositoryStub new
		              referenceCommit: base;
		              headCommit: (self commitWith: {
			               ('docs/progress.md' -> 'old').
			               ('docs/features/sheets/SEL.md' -> 'committed') } asDictionary);
		              location: (self fileSystemWith: {
			               ('docs/progress.md' -> 'new').
			               ('docs/features/sheets/SEL.md' -> 'modified') } asDictionary);
		              yourself.

	changes := OCRIcebergReader new fileChangesIn: repository since: base.

	self assert: (changes collect: [ :each | each reference -> each kind ] as: Array) equals: {
		('docs/features/sheets/SEL.md' -> #addition).
		('docs/progress.md' -> #modification) }
]
