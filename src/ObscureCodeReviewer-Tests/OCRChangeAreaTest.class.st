"
I test what OCRChangeAreaPresenter shows for each kind of change: a diff, or one side alone for an added or removed change. The presenter is never opened.
"
Class {
	#name : 'OCRChangeAreaTest',
	#superclass : 'TestCase',
	#instVars : [
		'area'
	],
	#category : 'ObscureCodeReviewer-Tests',
	#package : 'ObscureCodeReviewer-Tests'
}

{ #category : 'helpers' }
OCRChangeAreaTest >> markdownFile: aKind from: anOldSource to: aNewSource [

	^ OCRFileChange
		  kind: aKind
		  path: 'NOTES.md'
		  oldBytes: anOldSource utf8Encoded
		  newBytes: aNewSource utf8Encoded
]

{ #category : 'helpers' }
OCRChangeAreaTest >> method: aChange [

	^ aChange
		  className: 'OCRChangeAreaTest';
		  selector: #foo;
		  yourself
]

{ #category : 'running' }
OCRChangeAreaTest >> setUp [

	super setUp.
	area := OCRChangeAreaPresenter new
]

{ #category : 'helpers' }
OCRChangeAreaTest >> shownMarkdownTitles [

	^ self titlesShownBy: area markdownPresenter
]

{ #category : 'tests' }
OCRChangeAreaTest >> testAMarkdownFileIsRenderedByDefault [

	area showChange: (self markdownFile: #modification from: '# Notes' to: '# Notes!') comparedWith: '# Notes' notes: ''.

	self deny: area markdownPresenter isShowingDiff.
	self assert: self shownMarkdownTitles equals: #( 'Base' 'Disk' )
]

{ #category : 'tests' }
OCRChangeAreaTest >> testAMarkdownFileMicrodownCannotRenderShowsItsSourceAndWhy [

	| presenter |
	presenter := OCRMarkdownFilePresenterStub new.

	presenter showFrom: '# Notes' to: '# Notes!'.

	self assert: presenter isShowingDiff.
	self
		assert: (self titlesShownBy: presenter)
		equals: #( 'Could not render with Microdown (Error: Cannot render): showing the source.' )
]

{ #category : 'tests' }
OCRChangeAreaTest >> testAMethodOfAMissingClassIsHighlightedForObject [

	self
		assert: (OCRMethodChange addition
			 className: 'NoSuchClassAnywhere';
			 behaviorForHighlighting)
		equals: Object.
	self
		assert: (OCRMethodChange addition
			 className: 'OCRChangeAreaTest class';
			 behaviorForHighlighting)
		equals: OCRChangeAreaTest class
]

{ #category : 'tests' }
OCRChangeAreaTest >> testAMethodStartingWithACommentKeepsIt [

	area
		showChange: ((self method: OCRMethodChange addition)
			 newSource: '"a comment" foo ^ 2';
			 yourself)
		comparedWith: ''
		notes: ''.

	self assert: area shownSource equals: '"a comment" foo ^ 2'.
	self assert: area shownSourceTitle equals: 'Added'
]

{ #category : 'tests' }
OCRChangeAreaTest >> testAModifiedMarkdownFileIsRenderedSideBySide [

	area showChange: (self markdownFile: #modification from: '# Notes' to: '# Notes!') comparedWith: '# Notes' notes: ''.
	area markdownPresenter beRendered.

	self assert: self shownMarkdownTitles equals: #( 'Base' 'Disk' )
]

{ #category : 'tests' }
OCRChangeAreaTest >> testAModifiedMarkdownFileShowsItsDiff [

	area showChange: (self markdownFile: #modification from: '# Notes' to: '# Notes!') comparedWith: '# Notes' notes: ''.
	area markdownPresenter beSource.

	self assert: area markdownPresenter isShowingDiff
]

{ #category : 'tests' }
OCRChangeAreaTest >> testAModifiedMethodKeepsItsProtocolLineInTheDiff [

	area
		showChange: ((self method: OCRMethodChange modification)
			 oldSource: '"accessing"' , String cr , 'foo ^ 1';
			 newSource: '"private"' , String cr , 'foo ^ 1';
			 yourself)
		comparedWith: '"accessing"' , String cr , 'foo ^ 1'
		notes: ''.

	self assert: area isShowingDiff
]

{ #category : 'tests' }
OCRChangeAreaTest >> testAModifiedMethodShowsItsDiff [

	area
		showChange: ((self method: OCRMethodChange modification)
			 oldSource: 'foo ^ 1';
			 newSource: 'foo ^ 2';
			 yourself)
		comparedWith: 'foo ^ 1'
		notes: ''.

	self assert: area isShowingDiff
]

{ #category : 'tests' }
OCRChangeAreaTest >> testARemovedMarkdownFileIsShownAlone [

	area showChange: (self markdownFile: #removal from: '# Notes' to: '') comparedWith: '# Notes' notes: ''.
	area markdownPresenter beSource.

	self deny: area markdownPresenter isShowingDiff.
	self assert: self shownMarkdownTitles equals: #( 'Removed' )
]

{ #category : 'tests' }
OCRChangeAreaTest >> testARemovedMethodIsShownAlone [

	area
		showChange: ((self method: OCRMethodChange removal)
			 oldSource: 'foo ^ 1';
			 yourself)
		comparedWith: 'foo ^ 1'
		notes: ''.

	self deny: area isShowingDiff.
	self assert: area shownSource equals: 'foo ^ 1'
]

{ #category : 'tests' }
OCRChangeAreaTest >> testAnAddedMarkdownFileIsRenderedAlone [

	area showChange: (self markdownFile: #addition from: '' to: '# Notes') comparedWith: '' notes: ''.
	area markdownPresenter beRendered.

	self assert: self shownMarkdownTitles equals: #( 'Added' )
]

{ #category : 'tests' }
OCRChangeAreaTest >> testAnAddedMarkdownFileIsShownAlone [

	area showChange: (self markdownFile: #addition from: '' to: '# Notes') comparedWith: '' notes: ''.
	area markdownPresenter beSource.

	self deny: area markdownPresenter isShowingDiff.
	self assert: self shownMarkdownTitles equals: #( 'Added' )
]

{ #category : 'tests' }
OCRChangeAreaTest >> testAnAddedMarkdownFileMicrodownCannotRenderShowsItsSourceAndWhy [

	| presenter |
	presenter := OCRMarkdownFilePresenterStub new.

	presenter show: '# Notes' aloneTitled: 'Added'.

	self deny: presenter isShowingDiff.
	self
		assert: (self titlesShownBy: presenter)
		equals: #( 'Could not render with Microdown (Error: Cannot render): showing the source.'
			   'Added' )
]

{ #category : 'tests' }
OCRChangeAreaTest >> testAnAddedMethodIsShownAlone [

	area
		showChange: ((self method: OCRMethodChange addition)
			 newSource: 'foo ^ 2';
			 yourself)
		comparedWith: ''
		notes: ''.

	self deny: area isShowingDiff.
	self assert: area shownSource equals: 'foo ^ 2'.
	self assert: area shownSourceTitle equals: 'Added'
]

{ #category : 'tests' }
OCRChangeAreaTest >> testAnAddedMethodMovedFromAnotherShowsItsDiff [

	area
		showChange: ((self method: OCRMethodChange addition)
			 newSource: 'foo ^ 2';
			 yourself)
		comparedWith: 'bar ^ 2'
		notes: ''.

	self assert: area isShowingDiff
]

{ #category : 'tests' }
OCRChangeAreaTest >> testTheProtocolOfARemovedMethodIsInTheTitle [

	| source |
	source := '"private"' , String lf , 'foo ^ 1'.
	area
		showChange: ((self method: OCRMethodChange removal)
			 oldSource: source;
			 yourself)
		comparedWith: source
		notes: ''.

	self assert: area shownSource equals: 'foo ^ 1'.
	self assert: area shownSourceTitle equals: 'Removed — protocol: private'
]

{ #category : 'tests' }
OCRChangeAreaTest >> testTheProtocolOfAnAddedMethodIsInTheTitle [

	area
		showChange: ((self method: OCRMethodChange addition)
			 newSource: '"accessing"' , String cr , 'foo ^ 2';
			 yourself)
		comparedWith: ''
		notes: ''.

	self assert: area shownSource equals: 'foo ^ 2'.
	self assert: area shownSourceTitle equals: 'Added — protocol: accessing'
]

{ #category : 'helpers' }
OCRChangeAreaTest >> titlesShownBy: aMarkdownFilePresenter [
	"The titles above what aMarkdownFilePresenter shows: none for the diff, which labels its own sides."

	^ (aMarkdownFilePresenter layout allPresenters select: [ :each | each class = SpLabelPresenter ])
		  collect: [ :each | each label ]
		  as: Array
]
