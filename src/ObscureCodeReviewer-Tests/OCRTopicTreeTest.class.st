"
I test the Topics tree of a review (OCRTopicTreeBuilder): which change goes under which topic, and the warnings about the guide.
"
Class {
	#name : 'OCRTopicTreeTest',
	#superclass : 'TestCase',
	#category : 'ObscureCodeReviewer-Tests',
	#package : 'ObscureCodeReviewer-Tests'
}

{ #category : 'helpers' }
OCRTopicTreeTest >> labelsOf: someNodes [

	^ (someNodes collect: [ :each | each label ]) asArray
]

{ #category : 'helpers' }
OCRTopicTreeTest >> methodChange: aSelector class: aClassName [

	^ OCRMethodChange modification
		  packageName: 'MyProject';
		  className: aClassName;
		  selector: aSelector;
		  yourself
]

{ #category : 'helpers' }
OCRTopicTreeTest >> reviewWith: someChanges guide: aString [

	^ (OCRReview
		   repositoryName: 'my-project'
		   base: OCRLastCommitBase new
		   baseLabel: 'abc1234 (last commit)'
		   changes: someChanges)
		  guide: (OCRReviewGuide fromText: aString);
		  yourself
]

{ #category : 'tests' }
OCRTopicTreeTest >> testAChangeInTwoTopicsStaysInTheFirst [

	| review tree |
	review := self reviewWith: { (self methodChange: #a class: 'A') } guide: '# First
- A>>#a
# Second
- A>>#a'.

	tree := review topicTree.

	self assert: (self labelsOf: tree first children) equals: #( '~ A>>#a' ).
	self assert: tree second children isEmpty.
	self assert: review guideWarnings asArray equals: #( 'A>>#a is listed in "First" and in "Second"; it stays in "First"' )
]

{ #category : 'tests' }
OCRTopicTreeTest >> testAChangeNotInTheDiffIsAWarning [

	| review |
	review := self reviewWith: { (self methodChange: #a class: 'A') } guide: '# Topic
- A>>#a
- A>>#gone'.

	self assert: (self labelsOf: review topicTree first children) equals: #( '~ A>>#a' ).
	self assert: review guideWarnings asArray equals: #( 'A>>#gone (in "Topic") is not in the diff' )
]

{ #category : 'tests' }
OCRTopicTreeTest >> testChangesGoUnderTheirTopicInTheGuideOrder [

	| review tree |
	review := self
		          reviewWith: {
			          (self methodChange: #a class: 'A').
			          (self methodChange: #b class: 'A') }
		          guide: '# Topic
- A>>#b
- A>>#a'.

	tree := review topicTree.

	self assert: (self labelsOf: tree) equals: #( 'Topic' ).
	self assert: (self labelsOf: tree first children) equals: #( '~ A>>#b' '~ A>>#a' )
]

{ #category : 'tests' }
OCRTopicTreeTest >> testUnlistedChangesAreNotCoveredByAnyTopic [

	| review tree |
	review := self
		          reviewWith: {
			          (self methodChange: #a class: 'A').
			          (self methodChange: #b class: 'A') }
		          guide: '# Topic
- A>>#a'.

	tree := review topicTree.

	self assert: (self labelsOf: tree) equals: #( 'Topic' 'Not covered by any topic' ).
	self assert: (self labelsOf: tree last children) equals: #( '~ A>>#b' )
]

{ #category : 'tests' }
OCRTopicTreeTest >> testWithoutGuideEverythingIsNotCovered [

	| review |
	review := self reviewWith: { (self methodChange: #a class: 'A') } guide: ''.

	self assert: (self labelsOf: review topicTree) equals: #( 'Not covered by any topic' )
]
