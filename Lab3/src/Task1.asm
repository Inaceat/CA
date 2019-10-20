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
	;Prod
	;Quot

	ret
end