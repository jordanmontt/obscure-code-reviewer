"
I am a changed file that is not text: a picture, a video, an archive... A text diff of me makes no sense, so the review window shows my sizes instead, and pictures side by side.

My bytes are empty on the side where I do not exist (old for an addition, new for a removal).

	OCRFileChange
		kind: #modification
		path: 'images/logo.png'
		oldBytes: oldBytes
		newBytes: newBytes

answers one of me when either side is not text.
"
Class {
	#name : 'OCRBinaryFileChange',
	#superclass : 'OCRFileChange',
	#instVars : [
		'oldBytes',
		'newBytes'
	],
	#category : 'ObscureCodeReviewer-Model',
	#package : 'ObscureCodeReviewer',
	#tag : 'Model'
}

{ #category : 'accessing' }
OCRBinaryFileChange >> description [
	"What the review window shows instead of a diff, e.g. 'Binary file, modified: 1.20 KB → 2.00 KB'."

	^ String streamContents: [ :stream |
		  stream
			  nextPutAll: 'Binary file, ';
			  nextPutAll: self kindDescription;
			  nextPutAll: ': '.
		  self isAddition ifFalse: [ stream nextPutAll: oldBytes size humanReadableByteSizeString ].
		  self isModification ifTrue: [ stream nextPutAll: ' → ' ].
		  self isRemoval ifFalse: [ stream nextPutAll: newBytes size humanReadableByteSizeString ] ]
]

{ #category : 'comparing' }
OCRBinaryFileChange >> hasSameSourcesAs: aChange [

	^ aChange isBinary and: [ oldBytes = aChange oldBytes and: [ newBytes = aChange newBytes ] ]
]

{ #category : 'testing' }
OCRBinaryFileChange >> isBinary [

	^ true
]

{ #category : 'testing' }
OCRBinaryFileChange >> isPicture [
	"Whether the review window can show me as a picture."

	^ #( 'png' 'jpg' 'jpeg' 'gif' 'bmp' ) includes: (path copyAfterLast: $.) asLowercase
]

{ #category : 'accessing' }
OCRBinaryFileChange >> lineCount [
	"A binary file has no lines."

	^ 0
]

{ #category : 'accessing' }
OCRBinaryFileChange >> newBytes [
	"The file on disk. Empty for a removal."

	^ newBytes
]

{ #category : 'accessing' }
OCRBinaryFileChange >> oldBytes [
	"The file in the base commit. Empty for an addition."

	^ oldBytes
]

{ #category : 'initialization' }
OCRBinaryFileChange >> setOldBytes: someOldBytes newBytes: someNewBytes [

	oldBytes := someOldBytes.
	newBytes := someNewBytes
]

{ #category : 'displaying' }
OCRBinaryFileChange >> showContentsIn: aChangeArea comparedWith: aBaseSource [
	"No diff for me: my sizes, and the pictures when I am one."

	aChangeArea showBinaryFile: self
]
