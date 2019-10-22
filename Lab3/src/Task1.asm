.486
.model flat, stdcall
option casemap :none


include WINDOWS.INC

include masm32.inc
includelib masm32.lib

include kernel32.inc
includelib kernel32.lib


public Task1


.data
	taskMessage db "Enter two numbers:", 0Dh, 0Ah;\r\n
	taskMessageLength dd 20

	numberString db 10+2 dup(0);For number & \r\n

	numberOutputString db 10 dup(0), 0Dh, 0Ah;\r\n
	numberOutputStringLength dd 12;Should be enough for everybody


	sumMessage db "Sum: "
	sumMessageLength dd 5

	diffMessage db "Diff: "
	diffMessageLength dd 6

	prodMessage db "Prod: "
	prodMessageLength dd 6

	quotMessage db "Quot: "
	quotMessageLength dd 6


	multiplyOverflowMessage db "Numbers are too big for this!", 0Dh, 0Ah;\r\n
	multiplyOverflowMessageLength dd 31

	divisionErrorMessage db "Cannot divide byte zero", 0Dh, 0Ah;\r\n
	divisionErrorMessageLength dd 25

.data?
	inputHandle dd ?
	outputHandle dd ?
	
	charsWritten dd ?
	charsRead dd ?

	firstNumber dd ?
	secondNumber dd ?

.code
Task1:
;Get system I/O Handles
	;Get I
	push STD_INPUT_HANDLE
	call GetStdHandle
	mov inputHandle, EAX
	
	;Get O
	push STD_OUTPUT_HANDLE
	call GetStdHandle
	mov outputHandle, EAX

;Print input sprompt
	push NULL                
	push offset charsWritten
	push taskMessageLength
	push offset taskMessage
	push outputHandle
	call WriteConsole

;Read two numbers, assuming they are valid 32-bit values
;First
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
	mov firstNumber, EAX

;And second
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
	mov secondNumber, EAX

;Now calculate
;Sum
	mov EAX, firstNumber
	add EAX, secondNumber

	;Reset output string
	;First element to clear, using EBX as current
	mov EBX, offset numberOutputString
	;After last element to clear
	mov ECX, offset numberOutputString
	add ECX, numberOutputStringLength
	sub ECX, 2
	;Start reseting
ResetNextInSum:
	mov byte ptr [EBX], 0
	inc EBX
	cmp EBX, ECX
	je ResetNextInSum

	;Convert to string
	push offset numberOutputString
	push EAX
	call dwtoa

	;Print to console message
	push NULL                
	push offset charsWritten
	push sumMessageLength
	push offset sumMessage
	push outputHandle
	call WriteConsole

	;And number itself
	push NULL                
	push offset charsWritten
	push numberOutputStringLength
	push offset numberOutputString
	push outputHandle
	call WriteConsole

;Diff
	mov EAX, firstNumber
	sub EAX, secondNumber

	;Reset output string
	;First element to clear, using EBX as current
	mov EBX, offset numberOutputString
	;After last element to clear
	mov ECX, offset numberOutputString
	add ECX, numberOutputStringLength
	sub ECX, 2
	;Start reseting
ResetNextInDiff:
	mov byte ptr [EBX], 0
	inc EBX
	cmp EBX, ECX
	je ResetNextInDiff
	
	;Convert to string
	push offset numberOutputString
	push EAX
	call dwtoa

	;Print to console message
	push NULL                
	push offset charsWritten
	push diffMessageLength
	push offset diffMessage
	push outputHandle
	call WriteConsole

	;And number itself
	push NULL                
	push offset charsWritten
	push numberOutputStringLength
	push offset numberOutputString
	push outputHandle
	call WriteConsole

;Prod
	;Print to console message
	push NULL                
	push offset charsWritten
	push prodMessageLength
	push offset prodMessage
	push outputHandle
	call WriteConsole

	;Multiply
	mov EAX, firstNumber
	mul secondNumber
	
	;If production overflows 32 bit
	jo PrintMultiplyOverflowMessage
	
	;Else reset output string
	;First element to clear, using EBX as current
	mov EBX, offset numberOutputString
	;After last element to clear
	mov ECX, offset numberOutputString
	add ECX, numberOutputStringLength
	sub ECX, 2
	;Start reseting
ResetNextInProd:
	mov byte ptr [EBX], 0
	inc EBX
	cmp EBX, ECX
	je ResetNextInProd

	;Convert to string
	push offset numberOutputString
	push EAX
	call dwtoa

	;And print number
	push NULL                
	push offset charsWritten
	push numberOutputStringLength
	push offset numberOutputString
	push outputHandle
	call WriteConsole
	
	;Continue
	jmp Divide

PrintMultiplyOverflowMessage:
	push NULL                
	push offset charsWritten
	push multiplyOverflowMessageLength
	push offset multiplyOverflowMessage
	push outputHandle
	call WriteConsole

;Quot
Divide:
	;Print to console message
	push NULL                
	push offset charsWritten
	push quotMessageLength
	push offset quotMessage
	push outputHandle
	call WriteConsole

	cmp secondNumber, 0
	je PrintDivisionErrorMessage

	;Divide
	mov EDX, 0
	mov EAX, firstNumber
	div secondNumber
	
	;If division fails 
	jo PrintDivisionErrorMessage
	
	;Else reset output string
	;First element to clear, using EBX as current
	mov EBX, offset numberOutputString
	;After last element to clear
	mov ECX, offset numberOutputString
	add ECX, numberOutputStringLength
	sub ECX, 2
	;Start reseting
ResetNextInQuot:
	mov byte ptr [EBX], 0
	inc EBX
	cmp EBX, ECX
	je ResetNextInQuot

	;Convert to string
	push offset numberOutputString
	push EAX
	call dwtoa

	;And print number
	push NULL                
	push offset charsWritten
	push numberOutputStringLength
	push offset numberOutputString
	push outputHandle
	call WriteConsole
	
	;Continue
	jmp Exit

PrintDivisionErrorMessage:
	push NULL                
	push offset charsWritten
	push divisionErrorMessageLength
	push offset divisionErrorMessage
	push outputHandle
	call WriteConsole

Exit:
	ret
end