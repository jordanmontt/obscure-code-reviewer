"
I test OCRFileChange: files that are not code loaded in the image, and where they appear.
"
Class {
	#name : 'OCRFileChangeTest',
	#superclass : 'TestCase',
	#category : 'ObscureCodeReviewer-Tests',
	#package : 'ObscureCodeReviewer-Tests'
}

{ #category : 'helpers' }
OCRFileChangeTest >> fileChange: aPath [

	^ OCRFileChange modification
		  path: aPath;
		  oldSource: 'old';
		  newSource: 'new';
		  yourself
]

{ #category : 'helpers' }
OCRFileChangeTest >> labelsOf: someNodes [

	^ someNodes collect: [ :each | each label ] as: Array
]

{ #category : 'helpers' }
OCRFileChangeTest >> methodChange: aSelector class: aClassName [

	^ OCRMethodChange modification
		  packageName: 'MyProject';
		  className: aClassName;
		  selector: aSelector;
		  oldSource: aSelector , ' ^ 1';
		  newSource: aSelector , ' ^ 2';
		  yourself
]

{ #category : 'helpers' }
OCRFileChangeTest >> reviewWith: someChanges [

	^ self reviewWith: someChanges guide: ''
]

{ #category : 'helpers' }
OCRFileChangeTest >> reviewWith: someChanges guide: aString [

	^ (OCRReview
		   repositoryName: 'my-project'
		   reviewBase: (OCRReviewBase base: OCRLastCommitBase new commitId: 'abc1234')
		   changes: someChanges)
		  guide: (OCRReviewGuide fromText: aString);
		  yourself
]

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
