in-line cacheing
compileCPIC: cPIC Case0: case0CogMethod Case1Method: case1Method tag: case1Tag isMNUCase: isMNUCase numArgs: numArgs
	"Compile the code for a two-case PIC for case0CogMethod and  case1Method,case1Tag.
	 The tag for case0CogMethod is at the send site and so doesn't need to be generated.
	 case1Method may be any of
		- a Cog method; jump to its unchecked entry-point
		- a CompiledMethod; jump to the ceInterpretFromPIC trampoline
		- nil; call ceMNUFromPIC"
	<var: #cPIC type: #'CogMethod *'>
	| operand targetEntry jumpNext |
	<var: #case0CogMethod type: #'CogMethod *'>
	<var: #targetEntry type: #'void *'>
	<var: #jumpNext type: #'AbstractInstruction *'>
	self assert: case1Method notNil.
	self compilePICAbort: numArgs.
	self assert: (objectRepresentation inlineCacheTagIsYoung: case1Tag) not.
	(isMNUCase not
	 and: [coInterpreter methodHasCogMethod: case1Method])
		ifTrue:
			[operand := 0.
			 targetEntry := ((coInterpreter cogMethodOf: case1Method) asInteger + cmNoCheckEntryOffset) asVoidPointer]
		ifFalse: "We do not scavenge PICs, hence we cannot cache the MNU method if it is in new space."
			[operand := (case1Method isNil or: [objectMemory isYoungObject: case1Method])
							ifTrue: [0]
							ifFalse: [case1Method].
			 targetEntry := case1Method isNil ifTrue: [picMNUAbort] ifFalse: [picInterpretAbort]].

	jumpNext := self compileCPICEntry.
	self MoveUniqueCw: 0 R: SendNumArgsReg.
	self DumpJumpLong: case0CogMethod asInteger + cmNoCheckEntryOffset.
	endCPICCase0 := self CmpCw: case1Tag R: TempReg.
	jumpNext jmpTarget: endCPICCase0.
	self MoveUniqueCw: operand R: SendNumArgsReg.
	self DumpJumpLongZero: (isMNUCase ifTrue: [picMNUAbort] ifFalse: [targetEntry]) asInteger.
	endCPICCase1 := self MoveCw: cPIC asUnsignedInteger R: ClassReg.
	self JumpLong: (self cPICMissTrampolineFor: numArgs).
	^0