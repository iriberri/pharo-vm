primitive generators
genPrimitiveSmallFloatSquareRoot
	<option: #Spur64BitMemoryManager>
	"Stack looks like
		receiver (also in ResultReceiverReg)
		return address"
	| jumpFailAlloc |
	<var: #jumpFailAlloc type: #'AbstractInstruction *'>
	objectRepresentation genGetSmallFloatValueOf: ReceiverResultReg scratch: SendNumArgsReg into: DPFPReg0.
	self SqrtRd: DPFPReg0.
	jumpFailAlloc := objectRepresentation
					genAllocFloatValue: DPFPReg0
					into: SendNumArgsReg
					scratchReg: ClassReg
					scratchReg: TempReg.
	self MoveR: SendNumArgsReg R: ReceiverResultReg.
	self RetN: (self primRetNOffsetFor: 0).
	jumpFailAlloc jmpTarget: self Label.
	^self compileFallbackToInterpreterPrimitive: 0