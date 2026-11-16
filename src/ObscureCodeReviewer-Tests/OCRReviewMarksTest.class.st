"
I test the Reviewed marks: marking changes, nodes, keeping marks across a refresh, and Copy review.
"
Class {
	#name : 'OCRReviewMarksTest',
	#superclass : 'TestCase',
	#category : 'ObscureCodeReviewer-Tests',
	#package : 'ObscureCodeReviewer-Tests'
}

{ #category : 'helpers' }
OCRReviewMarksTest >> fileChange: aPath [

	^ OCRFileChange modification
		  path: aPath;
		  oldSource: 'old';
		  newSource: 'new';
		  yourself
]

{ #category : 'helpers' }
OCRReviewMarksTest >> methodChange: aSelector class: aClassName [

	^ OCRMethodChange modification
		  packageName: 'MyProject';
		  className: aClassName;
		  selector: aSelector;
		  oldSource: aSelector , ' ^ 1';
		  newSource: aSelector , ' ^ 2';
		  yourself
]

{ #category : 'helpers' }
OCRReviewMarksTest >> reviewWith: someChanges [

	^ self reviewWith: someChanges guide: ''
]

{ #category : 'helpers' }
OCRReviewMarksTest >> reviewWith: someChanges guide: aString [

	^ (OCRReview
		   repositoryName: 'my-project'
		   base: OCRLastCommitBase new
		   baseLabel: 'abc1234 (last commit)'
		   changes: someChanges)
		  guide: (OCRReviewGuide fromText: aString);
		  yourself
]

{ #category : 'tests' }
OCRReviewMarksTest >> testANodeIsReviewedWhenAllItsChangesAre [

	| a b review classNode |
	a := self methodChange: #a class: 'A'.
	b := self methodChange: #b class: 'A'.
	review := self reviewWith: {
		          a.
		          b }.
	classNode := review structuralTree first children first children first.

	review markReviewed: a.
	self deny: (review areAllReviewed: classNode changesBelow).
	review markReviewed: b.
	self assert: (review areAllReviewed: classNode changesBelow)
]

{ #category : 'tests' }
OCRReviewMarksTest >> testFeedbackListsWhatIsNotReviewedYet [

	| a b review feedback |
	a := self methodChange: #a class: 'A'.
	b := self methodChange: #b class: 'A'.
	review := self reviewWith: {
		          a.
		          b }.
	review markReviewed: a.

	feedback := review feedback.

	self assert: (feedback includesSubstring: 'Reviewed: 1 of 2 changes.').
	self assert: (feedback includesSubstring: (String lf join: #( '## Not reviewed yet' '- A>>#b (modified)' ))).
	self deny: (feedback includesSubstring: '- A>>#a (modified)')
]

{ #category : 'tests' }
OCRReviewMarksTest >> testFeedbackWithoutMarksHasNoProgress [

	| feedback |
	feedback := (self reviewWith: { (self methodChange: #a class: 'A') }) feedback.

	self deny: (feedback includesSubstring: 'Reviewed:').
	self deny: (feedback includesSubstring: 'Not reviewed yet')
]

{ #category : 'tests' }
OCRReviewMarksTest >> testMarkAndUnmark [

	| change review |
	change := self methodChange: #a class: 'A'.
	review := self reviewWith: { change }.

	review markReviewed: change.
	self assert: (review isReviewed: change).
	review unmarkReviewed: change.
	self deny: (review isReviewed: change)
]

{ #category : 'tests' }
OCRReviewMarksTest >> testNothingToReviewIsNotReviewed [

	self deny: ((self reviewWith: #(  )) areAllReviewed: #(  ))
]

{ #category : 'tests' }
OCRReviewMarksTest >> testRefreshDropsMarksOfChangedCode [

	| old new |
	old := self reviewWith: { (self methodChange: #a class: 'A') }.
	old markReviewed: old changes first.
	new := self reviewWith: { ((self methodChange: #a class: 'A')
		        newSource: 'a ^ 3';
		        yourself) }.

	new continueFrom: old.

	self deny: (new isReviewed: new changes first)
]

{ #category : 'tests' }
OCRReviewMarksTest >> testRefreshKeepsMarksOfUnchangedCode [

	| old new |
	old := self reviewWith: { (self methodChange: #a class: 'A') }.
	old markReviewed: old changes first.
	new := self reviewWith: { (self methodChange: #a class: 'A') }.

	new continueFrom: old.

	self assert: (new isReviewed: new changes first)
]
