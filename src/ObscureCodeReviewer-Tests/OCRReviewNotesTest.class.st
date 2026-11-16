"
I test what the guide says about a single change: why it was made and where its code was moved from.
"
Class {
	#name : 'OCRReviewNotesTest',
	#superclass : 'TestCase',
	#category : 'ObscureCodeReviewer-Tests',
	#package : 'ObscureCodeReviewer-Tests'
}

{ #category : 'helpers' }
OCRReviewNotesTest >> fileChange: aPath [

	^ OCRFileChange modification
		  path: aPath;
		  oldSource: 'old';
		  newSource: 'new';
		  yourself
]

{ #category : 'helpers' }
OCRReviewNotesTest >> methodChange: aSelector class: aClassName [

	^ OCRMethodChange modification
		  packageName: 'MyProject';
		  className: aClassName;
		  selector: aSelector;
		  oldSource: aSelector , ' ^ 1';
		  newSource: aSelector , ' ^ 2';
		  yourself
]

{ #category : 'helpers' }
OCRReviewNotesTest >> reviewWith: someChanges [

	^ self reviewWith: someChanges guide: ''
]

{ #category : 'helpers' }
OCRReviewNotesTest >> reviewWith: someChanges guide: aString [

	^ (OCRReview
		   repositoryName: 'my-project'
		   base: OCRLastCommitBase new
		   baseLabel: 'abc1234 (last commit)'
		   changes: someChanges)
		  guide: (OCRReviewGuide fromText: aString);
		  yourself
]

{ #category : 'tests' }
OCRReviewNotesTest >> testAChangeNotMovedIsComparedWithItsOwnOldCode [

	| change review |
	change := self methodChange: #a class: 'A'.
	review := self reviewWith: { change }.

	self assert: (review baseSourceOf: change) equals: 'a ^ 1'
]

{ #category : 'tests' }
OCRReviewNotesTest >> testMovedCodeIsComparedWithWhereItCameFrom [

	| moved origin review |
	moved := OCRMethodChange addition
		         packageName: 'MyProject';
		         className: 'A';
		         selector: #new;
		         newSource: 'new ^ 42';
		         yourself.
	origin := OCRMethodChange removal
		          packageName: 'MyProject';
		          className: 'B';
		          selector: #old;
		          oldSource: 'old ^ 42';
		          yourself.
	review := self
		          reviewWith: {
			          moved.
			          origin }
		          guide: '# Topic
- A>>#new <- B>>#old
- B>>#old'.

	self assert: (review baseSourceOf: moved) equals: 'old ^ 42'.
	self assert: (review baseSourceOf: origin) equals: 'old ^ 42'.
	self assert: (review notesAbout: moved) equals: 'Moved from B>>#old: the left side shows its code before the move.'
]

{ #category : 'tests' }
OCRReviewNotesTest >> testMovedFromAChangeNotInTheDiffIsAWarning [

	| review |
	review := self reviewWith: { (self methodChange: #a class: 'A') } guide: '# Topic
- A>>#a <- B>>#gone'.

	self assert: review guideWarnings asArray equals: #( 'A>>#a is moved from B>>#gone, which is not in the diff' ).
	self assert: (review baseSourceOf: review changes first) equals: 'a ^ 1'
]

{ #category : 'tests' }
OCRReviewNotesTest >> testNoNotesWithoutWhyOrMove [

	| change review |
	change := self methodChange: #a class: 'A'.
	review := self reviewWith: { change } guide: '# Topic
- A>>#a'.

	self assert: (review notesAbout: change) equals: ''
]

{ #category : 'tests' }
OCRReviewNotesTest >> testNotesSayWhy [

	| change review |
	change := self methodChange: #a class: 'A'.
	review := self reviewWith: { change } guide: '# Topic
- A>>#a keeps the order'.

	self assert: (review notesAbout: change) equals: 'Why: keeps the order'
]
