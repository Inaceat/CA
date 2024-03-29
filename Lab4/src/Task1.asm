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


.data?
	inputHandle dd ?
	outputHandle dd ?
	
	charsWritten dd ?
	charsRead dd ?

	firstNumber dd ?
	secondNumber dd ?

.code
;Get minimum of two 32bit unsigned values
;	EAX - first number
;	EBX - second number
;Return:
;	EAX - minimum of two numbers
Min proc
	;If EAX < EBX
	cmp EAX, EBX
	;Return, as EAX is min, and already in EAX
	jb Exit
	;Else, put EBX, as it's min, to EAX
	mov EAX, EBX

Exit:
	ret
Min endp

;Get maximum of two 32bit unsigned values
;	EAX - first number
;	EBX - second number
;Return:
;	EAX - maximum of two numbers
Max proc
	;If EAX > EBX
	cmp EAX, EBX
	;Return, as EAX is max, and already in EAX
	ja Exit
	;Else, put EBX, as it's max, to EAX
	mov EAX, EBX

Exit:
	ret
Max endp


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

;Now calculate : max(x^2, max(y,10)) / min(x,y)
	;Find min(x,y) and save to ECX
	mov EAX, firstNumber
	mov EBX, secondNumber
	call Min
	mov ECX, EAX

	;Find max(y,10) and save to EBX
	mov EAX, secondNumber
	mov EBX, 10
	call Max
	mov EBX, EAX
	
	;Put x^2 to EAX
	mov EAX, firstNumber
	mul firstNumber

	;Now EAX == x^2, EBX == max(y,10), so
	call Max

	;Now EAX == numerator, ECX == denominator, so
	mov EDX, 0
	div ECX

;Convert result to string
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

	ret
end