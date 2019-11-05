
.486
.model flat, stdcall
option casemap :none


include WINDOWS.INC

include masm32.inc
includelib masm32.lib

include kernel32.inc
includelib kernel32.lib


TWeightMeasureRecord struct
	Day dd ?
	Month dd ?
	Year dd ?
	Weight dq ?
TWeightMeasureRecord ends


;int PrintWeightMeasureRecord(TWeightMeasureRecord* record)
;		
;		Prints weight measure record to console.
;
;Input:
;	record	- [EBP + 8]
;
;Output:
;	none
.data
	weightString db 100 dup(0)

	weightMeasureRecordFormatTemplate db "  [%u.%u.%u	- %s kg]", 0Dh, 0Ah, 0

	weightMeasureRecordString db 100 dup(0)
.code
PrintWeightMeasureRecord proc
;Prologue
	push EBP
	mov EBP, ESP
	push EAX
	push EBX
	push ECX
	push EDX

	mov EBX, [EBP + 8]	;Load record address to EBX

;Convert weight part to string
	push offset weightString
	push dword ptr ((TWeightMeasureRecord ptr [EBX]).Weight + 4)
	push dword ptr ((TWeightMeasureRecord ptr [EBX]).Weight)
	call FloatToStr

;Format record string, copy to output string
	push offset weightString
	push dword ptr ((TWeightMeasureRecord ptr [EBX]).Year)
	push dword ptr ((TWeightMeasureRecord ptr [EBX]).Month)
	push dword ptr ((TWeightMeasureRecord ptr [EBX]).Day)
	push offset weightMeasureRecordFormatTemplate
	push offset weightMeasureRecordString
	call wsprintf
	;Align stack after 'wsprintf'
	add ESP, 24

;Print record
	push NULL                
	push offset charsWritten
	push EAX
	push offset weightMeasureRecordString
	push outputHandle
	call WriteConsole

;Epilogue & return
	pop EDX
	pop ECX
	pop EBX
	pop EAX
	pop EBP
	ret 4
PrintWeightMeasureRecord endp

;int PrintWeightMeasureRecordArray(TWeightMeasureRecord* array, int arraySize)
;
;		Prints {array} of {arraySize} weight measure records to console.
;
;Input:
;	array		- [EBP + 8]
;	arraySize	- [EBP + 12]
;
;Output:
;	none
.data
	newLineString db 0Dh, 0Ah
	newLineStringLength dd 2
.code
PrintWeightMeasureRecordArray proc
;Prologue
	push EBP
	mov EBP, ESP
	push EAX
	push ECX
	push EDX

	;Init cycle
	mov ECX, [EBP + 8]	;ECX == address of current array element, the first for now

	;Calculate address of after-the-last array element.
	mov EAX, sizeofTWeightMeasureRecord	;EAX == size of one element
	mul dword ptr [EBP + 12]		;EAX == array size in bytes
	add EAX, ECX					;EAX == address of after-the-last array element

	mov EDX, EAX					;Now EDX is after-the-last address, as EAX 'll be used as return value for comparer

	Cycle:
		;If no elements left in array, return.
		cmp ECX, EDX
		je Return

		;Else print current element
		push ECX
		call PrintWeightMeasureRecord

		;Prepare next iteration
		add ECX, sizeofTWeightMeasureRecord
		jmp Cycle

Return:
;Print new line chars
	push NULL                
	push offset charsWritten
	push newLineStringLength
	push offset newLineString
	push outputHandle
	call WriteConsole

;Epilogue & return
	pop EDX
	pop ECX
	pop EAX
	pop EBP
	ret 8
PrintWeightMeasureRecordArray endp



;int CompareWeightMeasureRecordByWeight(TWeightMeasureRecord* first, TWeightMeasureRecord* second)
;		
;		Compares records {first} and {second} by weight, returns:
;			-1 if {first}.Weight < {second}.Weight,
;			0 if {first}.Weight == {second}.Weight,
;			1 if {first}.Weight > {second}.Weight.
;
;Input:
;	first	- [EBP + 8]
;	second	- [EBP + 12]
;
;Output:
;	EAX - comparison result
.code
CompareWeightMeasureRecordByWeight proc
;Prologue
	push EBP
	mov EBP, ESP
	push EBX

	mov EAX, [EBP + 8];Get {first} address
	mov EBX, [EBP + 12];Get {second} address

	finit

	fld (TWeightMeasureRecord ptr [EBX]).Weight	;ST == {second}.Weight
	fld (TWeightMeasureRecord ptr [EAX]).Weight	;ST == {first}.Weight, ST(1) == {second}.Weight

;Compare, put result to EFLAGS
	fcomi ST, ST(1)

	;If {first}.Weight > {second}.Weight
	ja Greater
	
	;If {first}.Weight < {second}.Weight
	jb Less

	;Else {first}.Weight == {second}.Weight
	mov EAX, 0
	jmp Return

Greater:
	mov EAX, 1
	jmp Return

Less:
	mov EAX, -1

Return:
;Epilogue & return
	pop EBX
	pop EBP
	ret 8
CompareWeightMeasureRecordByWeight endp

;int CompareWeightMeasureRecordByDateDescending(TWeightMeasureRecord* first, TWeightMeasureRecord* second)
;		
;		Compares records {first} and {second} by date, returns:
;			-1 if {first} is later than {second},
;			0 if {first} and {second} are at the same time,
;			1 if {first} is earlier than {second}.
;
;Input:
;	first	- [EBP + 8]
;	second	- [EBP + 12]
;
;Output:
;	EAX - comparison result
.code
CompareWeightMeasureRecordByDateDescending proc
;Prologue
	push EBP
	mov EBP, ESP
	push EBX
	push ECX

	mov EAX, [EBP + 8];Get {first} address
	mov EBX, [EBP + 12];Get {second} address

;Compare years
	;Load {first}.Year to ECX, as 'cmp' doesn't accept two memory operands
	mov ECX, (TWeightMeasureRecord ptr [EAX]).Year
	
	;If {first}.Year > {second}.Year
	cmp ECX, (TWeightMeasureRecord ptr [EBX]).Year
	ja Later
	;If {first}.Year < {second}.Year
	jb Earlier

;If years are equal, compare months
	;Load {first}.Month to ECX
	mov ECX, (TWeightMeasureRecord ptr [EAX]).Month

	;If {first}.Month > {second}.Month
	cmp ECX, (TWeightMeasureRecord ptr [EBX]).Month
	ja Later
	;If {first}.Month < {second}.Month
	jb Earlier

;If years and months are equal, compare days
	;Load {first}.Day to ECX
	mov ECX, (TWeightMeasureRecord ptr [EAX]).Day

	;If {first}.Day > {second}.Day
	cmp ECX, (TWeightMeasureRecord ptr [EBX]).Day
	ja Later
	;If {first}.Day < {second}.Day
	jb Earlier

;If years, months & days are equal, dates are equal
	mov EAX, 0
	jmp Return

Later:
	mov EAX, -1
	jmp Return

Earlier:
	mov EAX, 1

Return:
;Epilogue & return
	pop ECX
	pop EBX
	pop EBP
	ret 8
CompareWeightMeasureRecordByDateDescending endp



;int FindAddressOfMinInArray(T* begin, T* end, int arrayElementBytes, int (*comparer)(TComplexNumber* first, TComplexNumber* second))
;
;		Returns address of min element in range [{begin}, {end}) of elements of {arrayElementBytes} size. 
;	Compares elements using procedure {comparer}, which returns to EAX:
;		-1 if {first} < {second},
;		0 if {first} == {second},
;		1 if {first} > {second}.
;
;Input:
;	begin				- [EBP + 8]
;	end					- [EBP + 12]
;	arrayElementBytes	- [EBP + 16]
;	comparer			- [EBP + 20]
;
;Output:
;	EAX - max element address
.code
FindAddressOfMinInArray proc
;Prologue
	push EBP
	mov EBP, ESP
	push EBX
	push ECX
	push EDX

	;Init cycle
	mov ECX, [EBP + 8]	;ECX == address of current array element, the first for now
	mov EBX, ECX		;EBX == address of min element, the first for now

	mov EDX, [EBP + 12]	;EDX == address of after-the-last element

	Cycle:
		;If no elements left in array, return.
		cmp ECX, EDX
		je Return

		;Else compare current array element and current min element
		push ECX
		push EBX
		call dword ptr [EBP + 20]	;compare(min, current)

		;Check comparison result:
		cmp EAX, 0
		;If EAX <= 0, current min element is less or equal to current array element
		;And current min remains the same.
		jle Continue
		;Else min > current, so save current as min
		mov EBX, ECX

		Continue:
		;Prepare next iteration
		add ECX, [EBP + 16]
		jmp Cycle

Return:
;Save result to output register
	mov EAX, EBX

;Epilogue & return
	pop EDX
	pop ECX
	pop EBX
	pop EBP
	ret 16
FindAddressOfMinInArray endp


;void SwapObjects(T* first, T* second, int sizeofTObject)
;
;		Swaps memory between 
;	[{first}, {first} + {sizeofTObject}) and
;	[{second}, {second} + {sizeofTObject}).
;
;Input:
;	first			- [EBP + 8]
;	second			- [EBP + 12]
;	sizeofTObject	- [EBP + 16]
;
;Output:
;	none
.code
SwapObjects proc
;Prologue
	push EBP
	mov EBP, ESP
	push EAX
	push EBX
	push ECX
	push EDX
	push ESI

	;Init cycle
	mov EAX, [EBP + 8]	;EAX == address of current byte in {first}, the first for now
	mov EBX, [EBP + 12]	;EBX == address of current byte in {second}, the first for now
	
	mov ESI, EAX
	add ESI, [EBP + 16]	;ESI == address of after-the-last byte of {first}

	Cycle:
		;If no bytes left, return.
		cmp EAX, ESI
		je Return

		;Else swap current bytes
		mov CL, [EAX]
		mov DL, [EBX]

		mov [EAX], DL
		mov [EBX], CL

		;Prepare next iteration
		inc EAX
		inc EBX
		jmp Cycle

Return:
;Epilogue & return
	pop ESI
	pop EDX
	pop ECX
	pop EBX
	pop EAX
	pop EBP
	ret 12
SwapObjects endp



;void SortArray(T* array, int arraySize, int arrayElementBytes, int (*comparer)(T* first, T* second))
;		
;		Sorts {array} of {arraySize} elements, each of {arrayElementBytes} bytes.
;	Comparer is used to determine elements order, {comparer} should return in EAX register:
;			-1 if {first} is before {second},
;			0 if {first} and {second} are equal,
;			1 if {first} is after {second} (i.e {second} is before {first}).
;
;Input:
;	array				- [EBP + 8]
;	arraySize			- [EBP + 12]
;	arrayElementBytes	- [EBP + 16]
;	comparer			- [EBP + 20]
;
;Output:
;	none
.code
SortArray proc
;Prologue
	push EBP
	mov EBP, ESP
	push EAX
	push EBX
	push ECX
	push EDX

;Init cycle
	mov ECX, [EBP + 8]	;ECX == address of current array element, the first for now

	mov EAX, [EBP + 12]
	mul dword ptr [EBP + 16]
	add EAX, ECX
	mov EDX, EAX			;EDX == address of after-the-last element

	Cycle:
		;If no elements left in array, return.
		cmp ECX, EDX
		je Return

		;Find address of min element in [ECX, EDX)
		push [EBP + 20]
		push [EBP + 16]
		push EDX
		push ECX
		call FindAddressOfMinInArray

		;Swap min element in [ECX, EDX) with current first, [ECX]
		push [EBP + 16]
		push EAX
		push ECX
		call SwapObjects

		Continue:
		;Prepare next iteration
		add ECX, [EBP + 16]
		jmp Cycle


Return:
;Epilogue & return
	pop EDX
	pop ECX
	pop EBX
	pop EAX
	pop EBP
	ret 16
SortArray endp



.data
	
	sizeofTWeightMeasureRecord dd 20

	weightDataArray TWeightMeasureRecord <1, 12, 2019, 124.6>,;W:5 D:2
										 <1, 12, 2016, 105.2>,;W:4 D:5
										 <25, 12, 2019, 50.8>,;W:1 D:1
										 <1, 7, 2019, 73.3>,  ;W:2 D:3
										 <4, 7, 2018, 83.3>	  ;W:3 D:4
	weightDataArraySize dd 5


	initialArrayMessage db "Array of weight measure records:", 0Dh, 0Ah;\r\n
	initialArrayMessageLength dd 34
	
	sortedByWeightArrayMessage db "Sorted by weight ascending:", 0Dh, 0Ah;\r\n
	sortedByWeightArrayMessageLength dd 29

	sortedByDateArray db "Sorted by date decending:", 0Dh, 0Ah;\r\n
	sortedByDateArrayLength dd 27

.data?
	inputHandle dd ?
	outputHandle dd ?
	
	charsWritten dd ?
	charsRead dd ?

.code
Task2 proc
;Get system I/O Handles
	;Get I
	push STD_INPUT_HANDLE
	call GetStdHandle
	mov inputHandle, EAX
	
	;Get O
	push STD_OUTPUT_HANDLE
	call GetStdHandle
	mov outputHandle, EAX

;Print initial array
	push NULL                
	push offset charsWritten
	push initialArrayMessageLength
	push offset initialArrayMessage
	push outputHandle
	call WriteConsole

	push weightDataArraySize
	push offset weightDataArray
	call PrintWeightMeasureRecordArray

;Sort by weight and print
	push NULL                
	push offset charsWritten
	push sortedByWeightArrayMessageLength
	push offset sortedByWeightArrayMessage
	push outputHandle
	call WriteConsole
	
	push CompareWeightMeasureRecordByWeight
	push sizeofTWeightMeasureRecord
	push weightDataArraySize
	push offset weightDataArray 
	call SortArray

	push weightDataArraySize
	push offset weightDataArray
	call PrintWeightMeasureRecordArray


;Sort by date and print
	push NULL                
	push offset charsWritten
	push sortedByDateArrayLength
	push offset sortedByDateArray
	push outputHandle
	call WriteConsole

	push CompareWeightMeasureRecordByDateDescending
	push sizeofTWeightMeasureRecord
	push weightDataArraySize
	push offset weightDataArray 
	call SortArray

	push weightDataArraySize
	push offset weightDataArray
	call PrintWeightMeasureRecordArray


	ret
Task2 endp
end