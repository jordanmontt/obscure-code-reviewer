"
I load the Obscure Code Reviewer with Metacello.
"
Class {
	#name : 'BaselineOfObscureCodeReviewer',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfObscureCodeReviewer',
	#package : 'BaselineOfObscureCodeReviewer'
}

{ #category : 'baselines' }
BaselineOfObscureCodeReviewer >> baseline: spec [

	<baseline>
	spec for: #common do: [
		spec
			package: 'ObscureCodeReviewer';
			package: 'ObscureCodeReviewer-Tests' with: [ spec requires: #( 'ObscureCodeReviewer' ) ].
		spec group: 'default' with: #( 'ObscureCodeReviewer' 'ObscureCodeReviewer-Tests' ) ]
]
