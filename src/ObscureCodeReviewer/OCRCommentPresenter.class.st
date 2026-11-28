"
I am a pane where the reviewer writes a comment. A comment is text, but as a code pane I give it Code search (implementors, senders) on what the reviewer selects. Without highlighting, line numbers or smart characters, I read and type as plain text.
"
Class {
	#name : 'OCRCommentPresenter',
	#superclass : 'SpCodePresenter',
	#category : 'ObscureCodeReviewer-UI',
	#package : 'ObscureCodeReviewer',
	#tag : 'UI'
}

{ #category : 'initialization' }
OCRCommentPresenter >> initialize [

	super initialize.
	self
		withoutSyntaxHighlight;
		withoutLineNumbers;
		withoutSmartCharacters
]
