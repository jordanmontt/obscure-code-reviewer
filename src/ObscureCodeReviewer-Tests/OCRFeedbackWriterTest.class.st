"
I test the Markdown that Copy review writes (OCRFeedbackWriter): the header, the comments in order, and what is not reviewed yet.
"
Class {
	#name : 'OCRFeedbackWriterTest',
	#superclass : 'OCRTestCase',
	#category : 'ObscureCodeReviewer-Tests',
	#package : 'ObscureCodeReviewer-Tests'
}

{ #category : 'tests' }
OCRFeedbackWriterTest >> testFeedbackDescribesKind [

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
OCRFeedbackWriterTest >> testFeedbackFollowsTreeOrder [

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
OCRFeedbackWriterTest >> testFeedbackHasGeneralCommentThenCommentedItems [

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
OCRFeedbackWriterTest >> testFeedbackWarnsWhenTheBaseIsStale [

	| review |
	review := OCRReview
		          repositoryName: 'my-project'
		          reviewBase: (OCRReviewBase
			           base: (OCRSplitBase fromBranchNamed: 'main')
			           commitId: 'd274ab5'
			           warning: 'main (d274ab5) is behind origin/main (ae02d54)')
		          changes: #(  ).

	self assert: review feedback equals: (String lf join:
		 #( 'Review of my-project, base d274ab5 (split from main)' 'Warning: main (d274ab5) is behind origin/main (ae02d54)'
		    '' '' ))
]

{ #category : 'tests' }
OCRFeedbackWriterTest >> testFeedbackWithoutCommentsIsOnlyTheHeader [

	| review |
	review := self reviewWith: { (self methodChange: #a class: 'MyClass') }.

	self assert: review feedback equals: (String lf join: #( 'Review of my-project, base abc1234 (last commit)'
	    '' '' ))
]
