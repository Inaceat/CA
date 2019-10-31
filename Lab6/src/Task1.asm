.486
.model flat, stdcall
option casemap :none


include WINDOWS.INC

include masm32.inc
includelib masm32.lib

include kernel32.inc
includelib kernel32.lib


.data
	taskMessage db "Enter x:", 0Dh, 0Ah;\r\n
	taskMessageLength dd 10

	numberString db 10+2 dup(0);For number & \r\n

	resultMessage db "sqrt(abs(cos x + sin x)) = "
	resultMessageLength dd 27

	resultNumberString db 10 dup(0), 0Dh, 0Ah;For number & \r\n
	resultNumberStringLength dd 12;Should be enough

.data?
	inputHandle dd ?
	outputHandle dd ?
	
	charsWritten dd ?
	charsRead dd ?

	xNumber dd ?

.code
Task1 proc
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

;Read x, assuming it is valid 32-bit value
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
	mov xNumber, EAX

;Calculate sqrt(abs(cos x + sin x))
	
	mov EAX, 41

;Print result
	;Convert resulting number to string
	push offset resultNumberString
	push EAX
	call dwtoa

	;Print result description message
	push NULL                
	push offset charsWritten
	push resultMessageLength
	push offset resultMessage
	push outputHandle
	call WriteConsole

	;Print result number
	push NULL                
	push offset charsWritten
	push resultNumberStringLength
	push offset resultNumberString
	push outputHandle
	call WriteConsole

	;Clear result number string
	mov ECX, 0
	mov EBX, resultNumberStringLength
	sub EBX, 2;\r\n should remain, so Length - 2
	ClearingCycle:
		cmp ECX, EBX
		je ClearingCycleExit
		mov [resultNumberString + ECX], 0
		inc ECX
		jmp ClearingCycle

ClearingCycleExit:
	ret
Task1 endp
end