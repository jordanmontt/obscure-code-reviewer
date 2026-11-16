"
I am the Pull request tab of the review window: the title and the body of the pull request the changes will become (an OCRPullRequest).

The agent drafts them at the top of the review guide; the reviewer edits them here. Copy review includes them when they were edited, and the agent opens the pull request from them.
"
Class {
	#name : 'OCRPullRequestPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'titleInput',
		'bodyText',
		'changedBlock'
	],
	#category : 'ObscureCodeReviewer-UI',
	#package : 'ObscureCodeReviewer',
	#tag : 'UI'
}

{ #category : 'initialization' }
OCRPullRequestPresenter >> connectPresenters [

	titleInput whenTextChangedDo: [ self notifyChange ].
	bodyText whenTextChangedDo: [ self notifyChange ]
]

{ #category : 'layout' }
OCRPullRequestPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  spacing: 5;
		  add: titleInput expand: false;
		  add: bodyText;
		  yourself
]

{ #category : 'initialization' }
OCRPullRequestPresenter >> initialize [

	super initialize.
	changedBlock := [ :pullRequest |  ]
]

{ #category : 'initialization' }
OCRPullRequestPresenter >> initializePresenters [

	titleInput := self newTextInput
		              placeholder: 'Title';
		              yourself.
	bodyText := self newText
		            placeholder: 'Description (Markdown)';
		            yourself
]

{ #category : 'private' }
OCRPullRequestPresenter >> notifyChange [

	changedBlock value: (OCRPullRequest title: titleInput text asString body: bodyText text asString)
]

{ #category : 'api' }
OCRPullRequestPresenter >> showPullRequest: aPullRequest [

	titleInput text: aPullRequest title.
	bodyText text: aPullRequest body
]

{ #category : 'events' }
OCRPullRequestPresenter >> whenPullRequestChangedDo: aBlock [
	"aBlock receives the edited OCRPullRequest."

	changedBlock := aBlock
]
