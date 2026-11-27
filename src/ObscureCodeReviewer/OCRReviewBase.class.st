"
I am what a review is compared to: the base chosen (an OCRLastCommitBase or an OCRSplitBase), the short id of the commit it resolved to, and a warning when that base may be wrong (empty when it is not), e.g. a local main behind its upstream.

The window title and Copy review show my label and my warning.

	(OCRReviewBase base: (OCRSplitBase fromBranchNamed: main) commitId: d274ab5) label
	>>> d274ab5 (split from main)
"
Class {
	#name : 'OCRReviewBase',
	#superclass : 'Object',
	#instVars : [
		'base',
		'commitId',
		'warning'
	],
	#category : 'ObscureCodeReviewer-Model',
	#package : 'ObscureCodeReviewer',
	#tag : 'Model'
}

{ #category : 'instance creation' }
OCRReviewBase class >> base: aBase commitId: aString [

	^ self base: aBase commitId: aString warning: ''
]

{ #category : 'instance creation' }
OCRReviewBase class >> base: aBase commitId: aString warning: aWarning [

	^ self new
		  setBase: aBase commitId: aString warning: aWarning;
		  yourself
]

{ #category : 'accessing' }
OCRReviewBase >> base [
	"The base chosen: an OCRLastCommitBase or an OCRSplitBase. A refresh uses it again."

	^ base
]

{ #category : 'testing' }
OCRReviewBase >> hasWarning [

	^ warning isNotEmpty
]

{ #category : 'accessing' }
OCRReviewBase >> label [
	"E.g. 'd274ab5 (split from main)'."

	^ '{1} ({2})' format: {
		  commitId.
		  base description }
]

{ #category : 'initialization' }
OCRReviewBase >> setBase: aBase commitId: aString warning: aWarning [

	base := aBase.
	commitId := aString.
	warning := aWarning
]

{ #category : 'accessing' }
OCRReviewBase >> warning [
	"Why I may be the wrong base, e.g. 'main (d274ab5) is behind origin/main (ae02d54)'; empty when I am not."

	^ warning
]
