"
I test the line counts shown in the tree: lines added and removed.
"
Class {
	#name : 'OCRLineCountTest',
	#superclass : 'TestCase',
	#category : 'ObscureCodeReviewer-Tests',
	#package : 'ObscureCodeReviewer-Tests'
}

{ #category : 'helpers' }
OCRLineCountTest >> fileChange: aPath [

	^ OCRFileChange modification
		  path: aPath;
		  oldSource: 'old';
		  newSource: 'new';
		  yourself
]

{ #category : 'helpers' }
OCRLineCountTest >> methodChange: aSelector class: aClassName [

	^ OCRMethodChange modification
		  packageName: 'MyProject';
		  className: aClassName;
		  selector: aSelector;
		  oldSource: aSelector , ' ^ 1';
		  newSource: aSelector , ' ^ 2';
		  yourself
]

{ #category : 'helpers' }
OCRLineCountTest >> reviewWith: someChanges [

	^ self reviewWith: someChanges guide: ''
]

{ #category : 'helpers' }
OCRLineCountTest >> reviewWith: someChanges guide: aString [

	^ (OCRReview
		   repositoryName: 'my-project'
		   reviewBase: (OCRReviewBase base: OCRLastCommitBase new commitId: 'abc1234')
		   changes: someChanges)
		  guide: (OCRReviewGuide fromText: aString);
		  yourself
]

{ #category : 'tests' }
OCRLineCountTest >> testAModifiedLineCountsTwice [

	self assert: (self methodChange: #a class: 'A') lineCount equals: 2
]

{ #category : 'tests' }
OCRLineCountTest >> testANodeCountsTheLinesBelowIt [

	| review |
	review := self reviewWith: {
		          (self methodChange: #a class: 'A').
		          (self methodChange: #b class: 'A') }.

	self assert: (review lineCountUnder: review structuralTree first) equals: 4
]

{ #category : 'tests' }
OCRLineCountTest >> testAnAddedMethodCountsItsLines [

	| change |
	change := OCRMethodChange addition
		          newSource: 'a
	^ 1';
		          yourself.

	self assert: change lineCount equals: 2
]
