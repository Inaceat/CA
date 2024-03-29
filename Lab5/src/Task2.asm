.486
.model flat, stdcall
option casemap :none


include WINDOWS.INC

include masm32.inc
includelib masm32.lib

include kernel32.inc
includelib kernel32.lib


public Task2


;void FillArithmeticalProgressionArray(int first, int difference, int* array, int arraySize)
;		
;		Fills array {array} of size {arraySize} with members of arithmetical progression with
;	first member {first} and common difference {difference}.
;
;Input:
;	first		- [EBP + 8]
;	difference	- [EBP + 12]
;	array		- [EBP + 16]
;	arraySize	- [EBP + 20]
;
;Output:
;	none
.data
.code
FillArithmeticalProgressionArray proc
;Prologue
	push EBP
	mov EBP, ESP
	push EAX
	push EBX
	push ECX

;Prepare
	;Move address of after-the-last element of array to ECX
	;ECX = {array} + 4 * {arraySize}
	mov ECX, [EBP + 16]
	shl dword ptr [EBP + 20], 2
	add ECX, [EBP + 20]
	
	;Move address of first array element to EAX
	;Will be used as current in cycle
	mov EAX, [EBP + 16]

	;Move first member to EBX
	;Will be used as current
	mov EBX, [EBP + 8]

	Cycle:
		;If current element address is outside array
		cmp EAX, ECX
		je EndCycle

		;Else put next progression element to array
		mov [EAX], EBX

		;Get next array element address
		;EAX = EAX + dwordSize
		add EAX, 4
		;Get next progression member
		;EBX = EBX + {difference}
		add EBX, [EBP + 12]

		;Repeat
		jmp Cycle

EndCycle:
;Epilogue & return
	pop ECX
	pop EBX
	pop EAX
	pop EBP

	ret 16
FillArithmeticalProgressionArray endp


;void ShowNumbersArray(int* array, int arraySize)
;		
;		Prints array {array} of size {arraySize} of 32bit numbers to console.
;
;Input:
;	array		- [EBP + 8]
;	arraySize	- [EBP + 12]
;
;Output:
;	none
.data
	formatString db "%d ", 0

	heapHandle dd 0

	outputStringPtr dd 0
	outputStringBufferSize dd 0
	outputStringLength dd 0

.code
ShowNumbersArray proc
;Prologue
	push EBP
	mov EBP, ESP
	push EAX
	push ECX

;Calculate size of string buffer needed for string representation of array
	;Size == 12 * arraySize + 1 == arraySize * (11 + 1) + 1, 11 symbols should be enough for any 32bit number, 1 for space, and 1 for '\0'
	mov EAX, 12
	mul dword ptr [EBP + 12];Assuming result to be 32bit value
	add EAX, 1
	mov outputStringBufferSize, EAX

;Allocate memory for string
	call GetProcessHeap
	mov heapHandle, EAX

	push outputStringBufferSize
	push 12; HEAP_ZERO_MEMORY | HEAP_GENERATE_EXCEPTIONS
	push heapHandle
	call HeapAlloc
	mov outputStringPtr, EAX


;Convert array to string
	;Counter
	mov ECX, 0
	mov outputStringLength, 0

	Cycle:
		;If no elements left, exit
		cmp ECX, [EBP + 12]
		je ExitCycle
	
		;Get current number from array
		mov EAX, [EBP + 8]
		mov EAX, [EAX + 4*ECX]
		
		;Store ECX as it's modified by {wsprintf}
		push ECX
		;Convert number
		push EAX
		push offset formatString
		push outputStringPtr
		call wsprintf
		
		;Align stack after {wsprintf}, removing 3 parameters
		add ESP, 12
		;Restore ECX
		pop ECX
		
		;Add number of written chars to {outputString}'s "real" length
		add outputStringLength, EAX
		;Align string buffer ptr to be first non-used byte
		add outputStringPtr, EAX
		
		;Increase counter
		inc ECX
		;Repeat
		jmp Cycle

ExitCycle:
	;Add \r\n to string end
	mov EAX, outputStringPtr
	mov dword ptr [EAX], 0Dh;\r
	mov dword ptr [EAX + 1], 0Ah;\n
	
	;Move {outputStringPtr} to the beginning of string
	sub EAX, outputStringLength
	mov outputStringPtr, EAX

	;Add 2 to string length 'cause of \r\n
	add outputStringLength, 2
	
;Print string representation of array
	push NULL                
	push offset charsWritten
	push outputStringLength
	push outputStringPtr
	push outputHandle
	call WriteConsole


;Free memory
	push outputStringPtr
	push 0
	push heapHandle
	call HeapFree

;Epilogue & return
	pop ECX
	pop EAX
	pop EBP
	ret 8

ShowNumbersArray endp


;int GetArraySum(int* array, int arraySize)
;		
;		Returns sum of all elements of array {array} of size {arraySize} of 32bit numbers.
;
;Input:
;	array		- [EBP + 8]
;	arraySize	- [EBP + 12]
;
;Output:
;	EAX - sum of all elements
.data
.code
GetArraySum proc
	;Prologue
	push EBP
	mov EBP, ESP
	push EBX
	push ECX
	
;Prepare 
	;EAX to store result
	mov EAX, 0
	;ECX to store counter
	mov ECX, 0

;Calculate sum
	Cycle:
		;If no elements left, exit
		cmp ECX, [EBP + 12]
		je ExitCycle

		;Get current number from array
		mov EBX, [EBP + 8]
		mov EBX, [EBX + 4*ECX]

		;Add to result
		add EAX, EBX

		;Increase counter
		inc ECX
		;Repeat
		jmp Cycle

ExitCycle:
	;Epilogue & return
	pop ECX
	pop EBX
	pop EBP
	ret 8
GetArraySum endp


;void SomehowChangeArray(int* array, int arraySize)
;		
;		Decreases elements that are divisable by 4 by factor of 4.
;
;Input:
;	array		- [EBP + 8]
;	arraySize	- [EBP + 12]
;
;Output:
;	none
.data
.code
SomehowChangeArray proc
;Prologue
	push EBP
	mov EBP, ESP
	push EAX
	push EBX
	push ECX
	
;Prepare 
	;ECX to store counter
	mov ECX, 0

;Calculate
	Cycle:
		;If no elements left, exit
		cmp ECX, [EBP + 12]
		je ExitCycle

		;Get current number address
		mov EAX, [EBP + 8]
		add EAX, ECX
		add EAX, ECX
		add EAX, ECX
		add EAX, ECX
		;EAX = EAX + 4*ECX
		;Now eax has number address

		;Get current number
		mov EBX, [EAX]

		;Check if number is divisable by 4
		;If number N % 4 == 0, last 2 bits of it are 00, so N & ..0011 == ..0000
		;And ZF is set to 1
		test EBX, 3
		;So if ZF == 0, N % 4 != 0, and N should remain intact
		jnz AfterDivision

		;Divide number by 4 by shifting it
		shr EBX, 2
		;Move divided number to array
		mov [EAX], EBX


	AfterDivision:
		;Increase counter
		inc ECX
		;Repeat
		jmp Cycle

ExitCycle:
;Epilogue & return
	pop ECX
	pop EBX
	pop EAX
	pop EBP
	ret 8
SomehowChangeArray endp


.data
	taskMessage db "Enter arithmetical progression first member & common difference:", 0Dh, 0Ah;\r\n
	taskMessageLength dd 66

	;For number input
	numberString db 10+2 dup(0);For number & \r\n
	;For number output
	numberOutputString db 10 dup(0), 0Dh, 0Ah;\r\n
	numberOutputStringLength dd 12;Should be enough for everybody


	;Numbers array
	array dd 10 dup(0)
	arraySize dd 10

	;Messages
	initialArrayMessage db "Initial array:", 0Dh, 0Ah;\r\n
	initialArrayMessageLength dd 16

	initialArraySumMessage db "Array sum: "
	initialArraySumMessageLength dd 11

	changedArrayMessage db "Array after decreasing by factor of 4 numbers divisable by 4:", 0Dh, 0Ah;\r\n
	changedArrayMessageLength dd 63

	changedArraySumMessage db "Changed array sum: "
	changedArraySumMessageLength dd 19

.data?
	inputHandle dd ?
	outputHandle dd ?
	
	charsWritten dd ?
	charsRead dd ?

	firstMemberNumber dd ?
	commonDifferenceNumber dd ?

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

;Print input prompt
	push NULL                
	push offset charsWritten
	push taskMessageLength
	push offset taskMessage
	push outputHandle
	call WriteConsole
	
;Read two numbers, assuming they are valid 32-bit values
;First member
	push NULL
	push offset charsRead
	push 10+2
	push offset numberString
	push inputHandle
	call ReadConsole

	;Put \0 after last digit
	mov EAX, charsRead
	mov [numberString + EAX - 2], 0

	;Convert from string to number
	push offset numberString
	call atodw
	mov firstMemberNumber, EAX
;Common difference
	push NULL
	push offset charsRead
	push 10+2
	push offset numberString
	push inputHandle
	call ReadConsole

	;Put \0 after last digit
	mov EAX, charsRead
	mov [numberString + EAX - 2], 0

	;Convert from string to number
	push offset numberString
	call atodw
	mov commonDifferenceNumber, EAX

;Fill array with arithmetical progression members
	push arraySize
	push offset array
	push commonDifferenceNumber
	push firstMemberNumber
	call FillArithmeticalProgressionArray

;Show initial array
	push NULL                
	push offset charsWritten
	push initialArrayMessageLength
	push offset initialArrayMessage
	push outputHandle
	call WriteConsole
	
	push arraySize
	push offset array
	call ShowNumbersArray


;Calculate initial array sum
	push arraySize
	push offset array
	call GetArraySum

;Show it
	;Convert to string
	push offset numberOutputString
	push EAX
	call dwtoa
	;Print description message
	push NULL                
	push offset charsWritten
	push initialArraySumMessageLength
	push offset initialArraySumMessage
	push outputHandle
	call WriteConsole

	;And print number
	push NULL                
	push offset charsWritten
	push numberOutputStringLength
	push offset numberOutputString
	push outputHandle
	call WriteConsole


;Change array
	push arraySize
	push offset array
	call SomehowChangeArray

;Show changed array
	push NULL                
	push offset charsWritten
	push changedArrayMessageLength
	push offset changedArrayMessage
	push outputHandle
	call WriteConsole
	
	push arraySize
	push offset array
	call ShowNumbersArray


;Calculate changed array sum
	push arraySize
	push offset array
	call GetArraySum

;Show it
	;Convert to string
	push offset numberOutputString
	push EAX
	call dwtoa
	
	;Print description message
	push NULL                
	push offset charsWritten
	push changedArraySumMessageLength
	push offset changedArraySumMessage
	push outputHandle
	call WriteConsole

	;And print number
	push NULL                
	push offset charsWritten
	push numberOutputStringLength
	push offset numberOutputString
	push outputHandle
	call WriteConsole

	ret
Task2 endp

end