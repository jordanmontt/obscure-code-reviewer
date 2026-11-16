"
I am the description of the pull request the reviewed changes will become: a title and a Markdown body.

The agent drafts me at the top of the review guide, before the first topic (see OCRGuideParser). The reviewer can edit me in the Pull request tab; Copy review then includes me, so the agent opens the pull request with the reviewer's version.

I am a value: two pull requests with the same title and body are equal.

	OCRPullRequest title: 'Add topics to the review' body: 'The agent groups its changes by purpose.'
"
Class {
	#name : 'OCRPullRequest',
	#superclass : 'Object',
	#instVars : [
		'title',
		'body'
	],
	#category : 'ObscureCodeReviewer-Model',
	#package : 'ObscureCodeReviewer',
	#tag : 'Model'
}

{ #category : 'instance creation' }
OCRPullRequest class >> empty [

	^ self title: '' body: ''
]

{ #category : 'instance creation' }
OCRPullRequest class >> title: aTitle body: aBody [

	^ self new
		  setTitle: aTitle body: aBody;
		  yourself
]

{ #category : 'comparing' }
OCRPullRequest >> = anObject [

	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	^ title = anObject title and: [ body = anObject body ]
]

{ #category : 'accessing' }
OCRPullRequest >> body [

	^ body
]

{ #category : 'comparing' }
OCRPullRequest >> hash [

	^ title hash bitXor: body hash
]

{ #category : 'testing' }
OCRPullRequest >> isEmpty [

	^ title trimBoth isEmpty and: [ body trimBoth isEmpty ]
]

{ #category : 'initialization' }
OCRPullRequest >> setTitle: aTitle body: aBody [

	title := aTitle.
	body := aBody
]

{ #category : 'accessing' }
OCRPullRequest >> title [

	^ title
]
