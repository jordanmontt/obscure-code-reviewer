"
I test OCRReviewComments: the reviewer's comments, attached to changes and topics by their reference.
"
Class {
	#name : 'OCRReviewCommentsTest',
	#superclass : 'TestCase',
	#instVars : [
		'comments'
	],
	#category : 'ObscureCodeReviewer-Tests',
	#package : 'ObscureCodeReviewer-Tests'
}

{ #category : 'helpers' }
OCRReviewCommentsTest >> change [

	^ OCRMethodChange modification
		  packageName: 'MyProject';
		  className: 'A';
		  selector: #a;
		  yourself
]

{ #category : 'running' }
OCRReviewCommentsTest >> setUp [

	super setUp.
	comments := OCRReviewComments new
]

{ #category : 'tests' }
OCRReviewCommentsTest >> testACommentIsFoundByItsItem [

	comments comment: 'Rename it' on: self change.

	self assert: (comments hasCommentOn: self change).
	self assert: (comments commentOn: self change) equals: 'Rename it'.
	self assert: comments commentedReferences equals: #( 'A>>#a' )
]

{ #category : 'tests' }
OCRReviewCommentsTest >> testALostCommentGoesIntoTheGeneralComment [

	comments general: 'Overall fine'.
	comments addLostComment: 'Rename it' on: 'A>>#a'.

	self assert: comments general equals: (String cr join: #( 'Overall fine' '' 'A>>#a (item no longer in diff): Rename it' ))
]

{ #category : 'tests' }
OCRReviewCommentsTest >> testAnEmptyCommentRemovesTheComment [

	comments comment: 'Rename it' on: self change.
	comments comment: '  ' on: self change.

	self deny: (comments hasCommentOn: self change).
	self assert: (comments commentOn: self change) equals: ''
]
