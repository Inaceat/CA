.486
.model flat, stdcall
option casemap :none


include WINDOWS.INC

include masm32.inc
includelib masm32.lib

include kernel32.inc
includelib kernel32.lib



.data
	taskMessage db "Enter three numbers:", 0Dh, 0Ah;\r\n
	taskMessageLength dd 22

	numberString db 10+2 dup(0);For number & \r\n

	resultMessage db "3a - (a+b)/2 = "
	resultMessageLength dd 15

	resultNumberString db 10 dup(0), 0Dh, 0Ah;For number & \r\n
	resultNumberStringLength dd 12;Should be enough

.data?
	inputHandle dd ?
	outputHandle dd ?
	
	charsWritten dd ?
	charsRead dd ?

	aNumber dd ?
	bNumber dd ?
	cNumber dd ?

	resultNumber dd ?

.code
Task3 proc
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
	
;Read three numbers, assuming they are valid 32-bit values
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
;Third
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
	mov cNumber, EAX


;Calculate weird function values table

	mov EAX, 43

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
Task3 endp

end