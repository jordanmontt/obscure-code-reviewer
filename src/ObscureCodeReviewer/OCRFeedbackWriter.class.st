"
I write a review as Markdown, ready to paste to the agent:

- a header naming the repository and the base, and how many changes are marked as reviewed (when any is);
- the pull request description, when the reviewer edited the agent's draft;
- the general comment, then the comments on topics (in the guide's order), then the comments on changes (in the Structure tree's order);
- the changes not reviewed yet, when the reviewer marked any.

Lines end with line feeds, as the agent expects.
"
Class {
	#name : 'OCRFeedbackWriter',
	#superclass : 'Object',
	#category : 'ObscureCodeReviewer-Model',
	#package : 'ObscureCodeReviewer',
	#tag : 'Model'
}

{ #category : 'private' }
OCRFeedbackWriter >> commentedChangesOf: aReview [

	^ aReview changesInTreeOrder select: [ :each | aReview hasCommentOn: each ]
]

{ #category : 'private' }
OCRFeedbackWriter >> commentedTopicsOf: aReview [

	^ aReview guide topics select: [ :each | aReview hasCommentOn: each ]
]

{ #category : 'writing' }
OCRFeedbackWriter >> feedbackFor: aReview [

	^ String streamContents: [ :stream |
		  self writeHeaderOf: aReview on: stream.
		  self writePullRequestOf: aReview on: stream.
		  self writeGeneralCommentOf: aReview on: stream.
		  (self commentedTopicsOf: aReview) do: [ :each | self writeSection: each reference text: (aReview commentOn: each) on: stream ].
		  (self commentedChangesOf: aReview) do: [ :each |
			  self writeSection: (self titleOf: each) text: (aReview commentOn: each) on: stream ].
		  self writeUnreviewedOf: aReview on: stream ]
]

{ #category : 'writing' }
OCRFeedbackWriter >> titleOf: aChange [

	^ '{1} ({2})' format: {
		  aChange reference.
		  aChange kindDescription }
]

{ #category : 'writing' }
OCRFeedbackWriter >> writeGeneralCommentOf: aReview on: aStream [

	aReview generalComment trimBoth isEmpty ifTrue: [ ^ self ].
	self writeSection: 'General' text: aReview generalComment on: aStream
]

{ #category : 'private' }
OCRFeedbackWriter >> writeHeaderOf: aReview on: aStream [

	aStream
		nextPutAll: 'Review of ';
		nextPutAll: aReview repositoryName;
		nextPutAll: ', base ';
		nextPutAll: aReview baseLabel;
		lf.
	aReview reviewedCount > 0 ifTrue: [
		aStream
			nextPutAll: 'Reviewed: ';
			print: aReview reviewedCount;
			nextPutAll: ' of ';
			print: aReview changes size;
			nextPutAll: ' changes.';
			lf ].
	aStream lf
]

{ #category : 'writing' }
OCRFeedbackWriter >> writePullRequestOf: aReview on: aStream [

	aReview isPullRequestEdited ifFalse: [ ^ self ].
	self
		writeSection: 'Pull request (edited by the reviewer)'
		text: (String lf join: {
			 ('Title: ' , aReview pullRequest title).
			 ''.
			 aReview pullRequest body })
		on: aStream
]

{ #category : 'writing' }
OCRFeedbackWriter >> writeSection: aTitle text: aString on: aStream [

	aStream
		nextPutAll: '## ';
		nextPutAll: aTitle;
		lf;
		nextPutAll: aString trimBoth withUnixLineEndings;
		lf;
		lf
]

{ #category : 'private' }
OCRFeedbackWriter >> writeUnreviewedOf: aReview on: aStream [
	"Only when the reviewer uses the marks: otherwise it would list every change."

	| unreviewed |
	aReview reviewedCount = 0 ifTrue: [ ^ self ].
	unreviewed := aReview unreviewedChanges.
	unreviewed ifEmpty: [ ^ self ].
	aStream
		nextPutAll: '## Not reviewed yet';
		lf.
	unreviewed do: [ :each |
		aStream
			nextPutAll: '- ';
			nextPutAll: (self titleOf: each);
			lf ].
	aStream lf
]
