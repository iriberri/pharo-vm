accessing
headSP: aValue
	self assert: (address + 8 >= zoneBase and: [address + 15 < zoneLimit]).
	^memory long64At: address + 9 put: aValue