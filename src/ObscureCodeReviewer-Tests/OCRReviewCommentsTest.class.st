"
I test the comments of an OCRReview and the Markdown feedback written from them.
"
Class {
	#name : 'OCRReviewCommentsTest',
	#superclass : 'TestCase',
	#category : 'ObscureCodeReviewer-Tests',
	#package : 'ObscureCodeReviewer-Tests'
}

{ #category : 'helpers' }
OCRReviewCommentsTest >> methodChange: aSelector class: aClassName [

	^ OCRMethodChange modification
		  packageName: 'MyProject';
		  className: aClassName;
		  selector: aSelector;
		  yourself
]

{ #category : 'helpers' }
OCRReviewCommentsTest >> reviewWith: someChanges [

	^ OCRReview
		  repositoryName: 'my-project'
		  base: OCRLastCommitBase new
		  baseLabel: 'abc1234 (last commit)'
		  changes: someChanges
]

{ #category : 'tests' }
OCRReviewCommentsTest >> testChangeWithoutCommentHasEmptyComment [

	| change review |
	change := self methodChange: #a class: 'MyClass'.
	review := self reviewWith: { change }.

	self deny: (review hasCommentOn: change).
	self assert: (review commentOn: change) equals: ''
]

{ #category : 'tests' }
OCRReviewCommentsTest >> testCommentOnChange [

	| change review |
	change := self methodChange: #a class: 'MyClass'.
	review := self reviewWith: { change }.

	review comment: 'Rename this' on: change.

	self assert: (review hasCommentOn: change).
	self assert: (review commentOn: change) equals: 'Rename this'
]

{ #category : 'tests' }
OCRReviewCommentsTest >> testCommentsAreAttachedByReference [
	"A recomputed change for the same method finds the same comment."

	| review |
	review := self reviewWith: { (self methodChange: #a class: 'MyClass') }.

	review comment: 'Rename this' on: (self methodChange: #a class: 'MyClass').

	self assert: (review commentOn: (self methodChange: #a class: 'MyClass')) equals: 'Rename this'
]

{ #category : 'tests' }
OCRReviewCommentsTest >> testEmptyCommentRemovesComment [

	| change review |
	change := self methodChange: #a class: 'MyClass'.
	review := self reviewWith: { change }.
	review comment: 'Rename this' on: change.

	review comment: '  ' on: change.

	self deny: (review hasCommentOn: change)
]

{ #category : 'tests' }
OCRReviewCommentsTest >> testFeedbackDescribesKind [

	| added review |
	added := OCRMethodChange addition
		         packageName: 'MyProject';
		         className: 'MyClass';
		         selector: #a;
		         yourself.
	review := self reviewWith: { added }.
	review comment: 'Why?' on: added.

	self assert: (review feedback includesSubstring: '## MyClass>>#a (added)')
]

{ #category : 'tests' }
OCRReviewCommentsTest >> testFeedbackFollowsTreeOrder [

	| first second review feedback |
	first := self methodChange: #alpha class: 'MyClass'.
	second := self methodChange: #zeta class: 'MyClass'.
	review := self reviewWith: {
		          second.
		          first }.
	review comment: 'Second' on: second.
	review comment: 'First' on: first.

	feedback := review feedback.

	self assert: (feedback indexOfSubCollection: '#alpha') < (feedback indexOfSubCollection: '#zeta')
]

{ #category : 'tests' }
OCRReviewCommentsTest >> testFeedbackHasGeneralCommentThenCommentedItems [

	| commented review |
	commented := self methodChange: #a class: 'MyClass'.
	review := self reviewWith: {
		          commented.
		          (self methodChange: #b class: 'MyClass') }.
	review generalComment: 'Good start.'.
	review comment: 'Rename this' on: commented.

	self assert: review feedback equals: (String lf join:
		 #( 'Review of my-project, base abc1234 (last commit)' '' '## General' 'Good start.' '' '## MyClass>>#a (modified)'
		    'Rename this' '' '' ))
]

{ #category : 'tests' }
OCRReviewCommentsTest >> testFeedbackWithoutCommentsIsOnlyTheHeader [

	| review |
	review := self reviewWith: { (self methodChange: #a class: 'MyClass') }.

	self assert: review feedback equals: 'Review of my-project, base abc1234 (last commit)' , String lf , String lf
]
