"
I show a binary file of a review (an OCRBinaryFileChange) where a diff makes no sense: its kind and sizes, and for a picture, the version in the base commit and the one on disk side by side.
"
Class {
	#name : 'OCRBinaryFilePresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'descriptionLabel'
	],
	#category : 'ObscureCodeReviewer-UI',
	#package : 'ObscureCodeReviewer',
	#tag : 'UI'
}

{ #category : 'initialization' }
OCRBinaryFilePresenter >> initializePresenters [

	descriptionLabel := self newLabel.
	self layout: (SpBoxLayout newTopToBottom
		 add: descriptionLabel expand: false;
		 yourself)
]

{ #category : 'showing' }
OCRBinaryFilePresenter >> picture: someBytes titled: aString [

	^ SpBoxLayout newTopToBottom
		  add: (self newLabel label: aString) expand: false;
		  add: (self presenterForPicture: someBytes);
		  yourself
]

{ #category : 'showing' }
OCRBinaryFilePresenter >> picturesOf: aBinaryFileChange [
	"The base commit on the left and the disk on the right, like the diff."

	^ SpBoxLayout newLeftToRight
		  spacing: 10;
		  add: (self picture: aBinaryFileChange oldBytes titled: 'Base');
		  add: (self picture: aBinaryFileChange newBytes titled: 'Disk');
		  yourself
]

{ #category : 'showing' }
OCRBinaryFilePresenter >> presenterForPicture: someBytes [
	"Nothing on the side where the file does not exist. A file named like a picture may not be one: ImageReadWriter signals an Error, and we say so."

	someBytes ifEmpty: [ ^ self newLabel label: '(none)' ].
	^ [
		  self newImage
			  autoScale: true;
			  image: (ImageReadWriter formFromStream: someBytes readStream);
			  yourself ]
		  on: Error
		  do: [ self newLabel label: '(cannot be read as a picture)' ]
]

{ #category : 'showing' }
OCRBinaryFilePresenter >> showFile: aBinaryFileChange [

	descriptionLabel label: aBinaryFileChange description.
	self layout: (SpBoxLayout newTopToBottom
		 spacing: 5;
		 add: descriptionLabel expand: false;
		 yourself).
	aBinaryFileChange isPicture ifTrue: [ self layout add: (self picturesOf: aBinaryFileChange) ]
]
