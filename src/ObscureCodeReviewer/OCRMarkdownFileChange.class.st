"
I am a changed Markdown file (.md or .markdown). The review window shows me rendered with Microdown, base and disk side by side, and can switch to the text diff to see exactly which lines changed.

OCRFileChange class>>#kind:path:oldBytes:newBytes: creates me for a text file with a Markdown extension.
"
Class {
	#name : 'OCRMarkdownFileChange',
	#superclass : 'OCRFileChange',
	#category : 'ObscureCodeReviewer-Model',
	#package : 'ObscureCodeReviewer',
	#tag : 'Model'
}

{ #category : 'displaying' }
OCRMarkdownFileChange >> show: aSource aloneTitled: aTitle in: aChangeArea [

	aChangeArea showMarkdown: aSource aloneTitled: aTitle
]

{ #category : 'displaying' }
OCRMarkdownFileChange >> showDiffFrom: aBaseSource in: aChangeArea [

	aChangeArea showMarkdownFrom: aBaseSource to: newSource
]
