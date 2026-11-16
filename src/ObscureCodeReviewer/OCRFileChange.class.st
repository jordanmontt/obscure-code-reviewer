"
I am a changed file that is not code loaded in the image: a README, a DESIGN.md, a .properties file, or a file of a package that is not loaded. My sources are the whole file, in the base commit and on disk.

My path is relative to the repository root, e.g. 'README.md' or 'src/MyPackage/MyClass.class.st'. It is also my reference in comments and guides.

	OCRFileChange modification
		path: 'README.md';
		oldSource: 'Old text';
		newSource: 'New text';
		yourself

I am not in the image, so I cannot be browsed or edited.
"
Class {
	#name : 'OCRFileChange',
	#superclass : 'OCRChange',
	#instVars : [
		'path'
	],
	#category : 'ObscureCodeReviewer-Model',
	#package : 'ObscureCodeReviewer',
	#tag : 'Model'
}

{ #category : 'testing' }
OCRFileChange class >> isText: someBytes [
	"UTF-8 without NUL bytes. Pictures, videos and archives fail one of the two."

	(someBytes includes: 0) ifTrue: [ ^ false ].
	^ [
		  someBytes utf8Decoded.
		  true ]
		  on: ZnCharacterEncodingError
		  do: [ false ]
]

{ #category : 'instance creation' }
OCRFileChange class >> kind: aSymbol path: aPath oldBytes: someOldBytes newBytes: someNewBytes [
	"A file that is text on both sides shows a diff, rendered for Markdown (OCRMarkdownFileChange); any other file is an OCRBinaryFileChange.
	The bytes are empty on the side where the file does not exist."

	((self isText: someOldBytes) and: [ self isText: someNewBytes ]) ifFalse: [
		^ OCRBinaryFileChange new
			  kind: aSymbol;
			  path: aPath;
			  setOldBytes: someOldBytes newBytes: someNewBytes;
			  yourself ].
	^ (self textFileClassFor: aPath) new
		  kind: aSymbol;
		  path: aPath;
		  oldSource: someOldBytes utf8Decoded;
		  newSource: someNewBytes utf8Decoded;
		  yourself
]

{ #category : 'instance creation' }
OCRFileChange class >> textFileClassFor: aPath [
	"Markdown files are rendered; other text files only diffed."

	^ (#( 'md' 'markdown' ) includes: (aPath copyAfterLast: $.) asLowercase)
		  ifTrue: [ OCRMarkdownFileChange ]
		  ifFalse: [ self ]
]

{ #category : 'image' }
OCRFileChange >> browse [
	"Never sent: I am not in the image (see #isInImage)."

	^ self shouldNotImplement
]

{ #category : 'testing' }
OCRFileChange >> isFileChange [

	^ true
]

{ #category : 'testing' }
OCRFileChange >> isInImage [
	"Files are on disk, not in the image."

	^ false
]

{ #category : 'displaying' }
OCRFileChange >> name [

	^ path
]

{ #category : 'accessing' }
OCRFileChange >> path [

	^ path
]

{ #category : 'accessing' }
OCRFileChange >> path: aString [

	path := aString
]

{ #category : 'displaying' }
OCRFileChange >> reference [

	^ path
]
