"
I am a Markdown file presenter whose rendering always fails, as Microdown does on some files (e.g. inline code holding only a number, pillar-markup/Microdown#1114): what the reviewer sees then can be tested without depending on a Microdown bug.
"
Class {
	#name : 'OCRMarkdownFilePresenterStub',
	#superclass : 'OCRMarkdownFilePresenter',
	#category : 'ObscureCodeReviewer-Tests',
	#package : 'ObscureCodeReviewer-Tests'
}

{ #category : 'rendering' }
OCRMarkdownFilePresenterStub >> renderedTexts [

	self error: 'Cannot render'
]
