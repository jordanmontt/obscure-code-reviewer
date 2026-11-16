"
I am a topic of the review guide in the Topics tree. My children are the changes of my topic. Selecting me shows the topic's explanation, and I can be commented.
"
Class {
	#name : 'OCRTopicNode',
	#superclass : 'OCRTreeNode',
	#instVars : [
		'topic'
	],
	#category : 'ObscureCodeReviewer-Model',
	#package : 'ObscureCodeReviewer',
	#tag : 'Model'
}

{ #category : 'instance creation' }
OCRTopicNode class >> topic: aTopic [

	^ (self named: aTopic title iconName: #book)
		  setTopic: aTopic;
		  yourself
]

{ #category : 'accessing' }
OCRTopicNode >> commentable [
	"What a comment on me is attached to."

	^ topic
]

{ #category : 'testing' }
OCRTopicNode >> hasChange [

	^ false
]

{ #category : 'testing' }
OCRTopicNode >> isCommentable [

	^ true
]

{ #category : 'initialization' }
OCRTopicNode >> setTopic: aTopic [

	topic := aTopic
]

{ #category : 'displaying' }
OCRTopicNode >> showIn: aReviewPresenter [

	aReviewPresenter showTopic: topic
]

{ #category : 'accessing' }
OCRTopicNode >> topic [

	^ topic
]
