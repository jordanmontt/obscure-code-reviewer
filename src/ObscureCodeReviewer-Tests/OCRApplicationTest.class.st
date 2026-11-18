"
I test OCRApplication: the reviewer's own application, which Pharo's tools opened from the reviewer can run in.
"
Class {
	#name : 'OCRApplicationTest',
	#superclass : 'TestCase',
	#category : 'ObscureCodeReviewer-Tests',
	#package : 'ObscureCodeReviewer-Tests'
}

{ #category : 'tests' }
OCRApplicationTest >> testPharoToolsCanRunInIt [
	"The browsers Code search opens ask their application for its toolbar mode."

	self assert: OCRApplication new toolbarDisplayMode equals: StPharoApplication current toolbarDisplayMode
]
