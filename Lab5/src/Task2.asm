.486
.model flat, stdcall
option casemap :none


include WINDOWS.INC

include masm32.inc
includelib masm32.lib

include kernel32.inc
includelib kernel32.lib


public Task2


;void FillArithmeticalProgressionArray(int first, int difference, OUT int* array, int arraySize)
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


;void GetArraySum(int* array, int arraySize)
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
	mov EAX, 42
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