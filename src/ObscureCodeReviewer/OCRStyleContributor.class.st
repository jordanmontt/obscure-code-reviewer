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
		Draw { #backgroundColor: EnvironmentColor(#lightBackground) } ] ]'
]
