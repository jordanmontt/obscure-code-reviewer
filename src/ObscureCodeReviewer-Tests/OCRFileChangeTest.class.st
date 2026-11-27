"
I test OCRFileChange: files that are not code loaded in the image, and where they appear.
"
Class {
	#name : 'OCRFileChangeTest',
	#superclass : 'OCRTestCase',
	#category : 'ObscureCodeReviewer-Tests',
	#package : 'ObscureCodeReviewer-Tests'
}

{ #category : 'tests' }
OCRFileChangeTest >> testAFileIsNamedAndReferencedByItsPath [

	| change |
	change := self fileChange: 'docs/README.md'.

	self assert: change name equals: 'docs/README.md'.
	self assert: change reference equals: 'docs/README.md'.
	self assert: change isFileChange
]

{ #category : 'tests' }
OCRFileChangeTest >> testAFileIsNotInTheImage [

	| change |
	change := self fileChange: 'README.md'.

	self deny: change isInImage.
	self deny: change isEditable
]

{ #category : 'tests' }
OCRFileChangeTest >> testATopicCanListAFile [

	| review |
	review := self reviewWith: { (self fileChange: 'README.md') } guide: '# Document it
- README.md'.

	self assert: (self labelsOf: review topicTree first children) equals: #( '~ README.md' ).
	self assert: review guideWarnings isEmpty
]

{ #category : 'tests' }
OCRFileChangeTest >> testFilesAreTheLastSectionSortedByPath [

	| tree |
	tree := (self reviewWith: {
		         (self fileChange: 'src/Unloaded/Foo.class.st').
		         (self methodChange: #a class: 'A').
		         (self fileChange: 'README.md') }) structuralTree.

	self assert: (self labelsOf: tree) equals: #( 'Code' 'Files' ).
	self assert: (self labelsOf: tree last children) equals: #( '~ README.md' '~ src/Unloaded/Foo.class.st' )
]
