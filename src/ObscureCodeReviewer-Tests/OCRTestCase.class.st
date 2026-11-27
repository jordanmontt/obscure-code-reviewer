"
I am the superclass of the tests that build reviews and changes by hand: I hold the builders they share, so a change of OCRReview or OCRChange is made in one place.
"
Class {
	#name : 'OCRTestCase',
	#superclass : 'TestCase',
	#category : 'ObscureCodeReviewer-Tests',
	#package : 'ObscureCodeReviewer-Tests'
}

{ #category : 'testing' }
OCRTestCase class >> isAbstract [

	^ self = OCRTestCase
]

{ #category : 'helpers' }
OCRTestCase >> fileChange: aPath [

	^ OCRFileChange modification
		  path: aPath;
		  oldSource: 'old';
		  newSource: 'new';
		  yourself
]

{ #category : 'helpers' }
OCRTestCase >> labelsOf: someNodes [

	^ someNodes collect: [ :each | each label ] as: Array
]

{ #category : 'helpers' }
OCRTestCase >> methodChange: aSelector class: aClassName [

	^ OCRMethodChange modification
		  packageName: 'MyProject';
		  className: aClassName;
		  selector: aSelector;
		  oldSource: aSelector , ' ^ 1';
		  newSource: aSelector , ' ^ 2';
		  yourself
]

{ #category : 'helpers' }
OCRTestCase >> reviewWith: someChanges [

	^ self reviewWith: someChanges guide: ''
]

{ #category : 'helpers' }
OCRTestCase >> reviewWith: someChanges guide: aString [
	"aString is the guide's Markdown."

	^ (OCRReview
		   repositoryName: 'my-project'
		   reviewBase: (OCRReviewBase base: OCRLastCommitBase new commitId: 'abc1234')
		   changes: someChanges)
		  guide: (OCRReviewGuide fromText: aString);
		  yourself
]
