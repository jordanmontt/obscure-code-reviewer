"
I test how a changed file becomes a text change (with a diff) or an OCRBinaryFileChange (sizes and pictures), from its bytes.
"
Class {
	#name : 'OCRBinaryFileChangeTest',
	#superclass : 'TestCase',
	#category : 'ObscureCodeReviewer-Tests',
	#package : 'ObscureCodeReviewer-Tests'
}

{ #category : 'helpers' }
OCRBinaryFileChangeTest >> fileAt: aPath from: someOldBytes to: someNewBytes [

	^ OCRFileChange
		  kind: #modification
		  path: aPath
		  oldBytes: someOldBytes
		  newBytes: someNewBytes
]

{ #category : 'helpers' }
OCRBinaryFileChangeTest >> pngBytes [
	"The PNG signature: not UTF-8, and with a NUL byte further on."

	^ #[ 137 80 78 71 13 10 26 10 0 0 0 13 ]
]

{ #category : 'tests' }
OCRBinaryFileChangeTest >> testABinaryFileHasNoLines [

	self assert: (self fileAt: 'logo.png' from: self pngBytes to: #[ 1 2 ]) lineCount equals: 0
]

{ #category : 'tests' }
OCRBinaryFileChangeTest >> testAMarkIsKeptOnlyWhileTheBytesAreTheSame [

	| old |
	old := self fileAt: 'logo.png' from: self pngBytes to: #[ 0 1 ].

	self assert: (old hasSameSourcesAs: (self fileAt: 'logo.png' from: self pngBytes to: #[ 0 1 ])).
	self deny: (old hasSameSourcesAs: (self fileAt: 'logo.png' from: self pngBytes to: #[ 0 2 ]))
]

{ #category : 'tests' }
OCRBinaryFileChangeTest >> testANulByteMakesAFileBinary [

	self assert: (self fileAt: 'data.bin' from: #[ 65 0 66 ] to: #[ 65 66 ]) isBinary
]

{ #category : 'tests' }
OCRBinaryFileChangeTest >> testAnAddedBinaryFileHasOnlyItsNewSize [

	| change |
	change := OCRFileChange
		          kind: #addition
		          path: 'logo.png'
		          oldBytes: ByteArray new
		          newBytes: self pngBytes.

	self assert: change description equals: 'Binary file, added: ' , self pngBytes size humanReadableByteSizeString
]

{ #category : 'tests' }
OCRBinaryFileChangeTest >> testBytesThatAreNotUTF8AreBinary [

	self assert: (self fileAt: 'logo.png' from: self pngBytes to: self pngBytes reversed) isBinary
]

{ #category : 'tests' }
OCRBinaryFileChangeTest >> testDescriptionGivesKindAndSizes [

	| change |
	change := self fileAt: 'movie.mp4' from: (ByteArray new: 2048) to: (ByteArray new: 3072).

	self assert: change description equals: ('Binary file, modified: {1} → {2}' format: {
		 2048 humanReadableByteSizeString.
		 3072 humanReadableByteSizeString })
]

{ #category : 'tests' }
OCRBinaryFileChangeTest >> testPicturesAreKnownByTheirExtension [

	self assert: (self fileAt: 'images/Logo.PNG' from: self pngBytes to: #[ 0 ]) isPicture.
	self deny: (self fileAt: 'movie.mp4' from: self pngBytes to: #[ 0 ]) isPicture
]

{ #category : 'tests' }
OCRBinaryFileChangeTest >> testTextBytesGiveATextDiff [

	| change |
	change := self fileAt: 'README.md' from: 'old' utf8Encoded to: 'new' utf8Encoded.

	self deny: change isBinary.
	self assert: change oldSource equals: 'old'.
	self assert: change newSource equals: 'new'
]
