C translation support
tryToCollapseBothArmsOfConditional: msgNode on: aStream indent: level
	"Attempt to generate the code for an ifTrue:ifFalse: if both arms are found to be the same, in which case
	 answer true.  Otherwise output nothing and answer false."
	(msgNode args first isSameAs: msgNode args second) ifFalse:
		[^false].
	msgNode receiver hasSideEffect ifTrue:
		[msgNode receiver emitCCodeAsExpressionOn: aStream level: level generator: self.
		 aStream nextPut: $; ; crtab: level].
	msgNode args first emitCCodeOn: aStream level: level generator: self.
	^true