"
I test OCRReviewComments: the reviewer's comments, attached to changes and topics by their reference.
"
Class {
	#name : 'OCRCommentsTest',
	#superclass : 'TestCase',
	#instVars : [
		'comments'
	],
	#category : 'ObscureCodeReviewer-Tests',
	#package : 'ObscureCodeReviewer-Tests'
}

{ #category : 'helpers' }
OCRCommentsTest >> change [

	^ OCRMethodChange modification
		  packageName: 'MyProject';
		  className: 'A';
		  selector: #a;
		  yourself
]

{ #category : 'running' }
OCRCommentsTest >> setUp [

	super setUp.
	comments := OCRReviewComments new
]

{ #category : 'tests' }
OCRCommentsTest >> testACommentIsFoundByItsItem [

	comments comment: 'Rename it' on: self change.

	self assert: (comments hasCommentOn: self change).
	self assert: (comments commentOn: self change) equals: 'Rename it'.
	self assert: comments commentedReferences equals: #( 'A>>#a' )
]

{ #category : 'tests' }
OCRCommentsTest >> testALostCommentGoesIntoTheGeneralComment [

	comments general: 'Overall fine'.
	comments addLostComment: 'Rename it' on: 'A>>#a'.

	self assert: comments general equals: (String cr join: #( 'Overall fine' '' 'A>>#a (item no longer in diff): Rename it' ))
]

{ #category : 'tests' }
OCRCommentsTest >> testAnEmptyCommentRemovesTheComment [

	comments comment: 'Rename it' on: self change.
	comments comment: '  ' on: self change.

	self deny: (comments hasCommentOn: self change).
	self assert: (comments commentOn: self change) equals: ''
]
