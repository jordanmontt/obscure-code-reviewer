"
I am the application of one run of the Obscure Code Reviewer: a review window, the windows opened from it, and the tools its code panes open belong to me. Each review, or picker, gets its own instance (OCRApplication new).

I am a Pharo tool application (an StPharoApplication), because Spec runs the commands of a code pane, such as Code search → Implementors of it, in the application of the pane, and Pharo's browsers expect what a Pharo tool application answers (its toolbar mode, its tools, its settings).

Never send me #run: StPharoApplication>>#run would make me the Pharo IDE's application and close its windows.
"
Class {
	#name : 'OCRApplication',
	#superclass : 'StPharoApplication',
	#category : 'ObscureCodeReviewer-UI',
	#package : 'ObscureCodeReviewer',
	#tag : 'UI'
}
