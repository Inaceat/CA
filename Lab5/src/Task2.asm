.486
.model flat, stdcall
option casemap :none


include WINDOWS.INC

include masm32.inc
includelib masm32.lib

include kernel32.inc
includelib kernel32.lib


public Task2


.data
	taskMessage db "Enter two numbers:", 0Dh, 0Ah;\r\n
	taskMessageLength dd 20

	numberString db 10+2 dup(0);For number & \r\n

	numberOutputString db 10 dup(0), 0Dh, 0Ah;\r\n
	numberOutputStringLength dd 12;Should be enough for everybody

	resultMessage db "a * b = "
	resultMessageLength dd 8

.data?
	inputHandle dd ?
	outputHandle dd ?
	
	charsWritten dd ?
	charsRead dd ?

	firstMemberNumber dd ?
	commonDifferenceNumber dd ?

.code
Task2:
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
	mov aNumber, EAX
;Second
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
	mov bNumber, EAX


	ret
end