"
I add the reviewer's styles to Pharo's tools. A title above a source shown alone (an added or removed change) looks like the header of a diff, so both views read the same.
"
Class {
	#name : 'OCRStyleContributor',
	#superclass : 'StPharoStyleContributor',
	#category : 'ObscureCodeReviewer-UI',
	#package : 'ObscureCodeReviewer',
	#tag : 'UI'
}

{ #category : 'styles' }
OCRStyleContributor >> styleSheetContribution [

	^ SpStyleVariableSTONReader fromString: '.application [
	.ocrSourceTitle [
		Container { #borderWidth: 1, #borderColor: EnvironmentColor(#border) },
		Draw { #backgroundColor: EnvironmentColor(#lightBackground) } ],
	.ocrBar [
		Container { #padding: 8 },
		Draw { #backgroundColor: EnvironmentColor(#lightBackground) } ],
	.ocrRepository [ Font { #bold: true, #size: 13 } ],
	.ocrPageTitle [ Font { #name: EnvironmentFont(#code), #bold: true, #size: 12 } ],
	.ocrHeading [ Font { #bold: true, #size: 12 } ],
	.ocrMuted [ Draw { #color: EnvironmentColor(#ghostText) } ],
	.ocrNote [
		Container { #padding: 6 },
		Draw { #backgroundColor: EnvironmentColor(#lightBackground) } ],
	.ocrAdded [ Draw { #color: EnvironmentColor(#successText) } ],
	.ocrRemoved [ Draw { #color: EnvironmentColor(#dangerText) } ],
	.ocrModified [ Draw { #color: EnvironmentColor(#warningText) } ],
	.ocrWarning [ Draw { #color: EnvironmentColor(#warningText) } ] ]'
]
