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

	numberInputString db 100+2 dup(0);For number & \r\n

	resultMessage db "sqrt(abs(cos x + sin x)) = "
	resultMessageLength dd 27

	resultNumberString db 100 dup(0), 0Dh, 0Ah;For number & \r\n
	resultNumberStringMaxLength dd 102;Should be enough
	resultNumberStringUsedLength dd 0

.data?
	inputHandle dd ?
	outputHandle dd ?
	
	charsWritten dd ?
	charsRead dd ?

	xNumber dq ?;now with float-point

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

;Read x, assuming it is valid floating-point number
	push NULL
	push offset charsRead
	push 100+2
	push offset numberInputString
	push inputHandle
	call ReadConsole

	;Put \0 after last digit
	mov EAX, charsRead
	mov [numberInputString + EAX - 2], 0

	;Convert from string to number
	push offset xNumber
	push offset numberInputString
	call StrToFloat

;Calculate sqrt(abs(cos x + sin x))
	finit

	fld xNumber
	fsin
	;Now ST has sin x

	fld xNumber
	fcos
	;Now ST has cos x
	;And ST(1) has sin x

	fadd ST(0), ST(1)
	;Now ST has sin x + cos x
	
	fabs
	;Now ST has abs(sin x + cos x)

	fsqrt
	;Now ST has sqrt(abs(sin x + cos x))
	
	fstp xNumber

;Print result
	;Convert resulting number to string
	push offset resultNumberString
	push dword ptr xNumber + 4
	push dword ptr xNumber
	call FloatToStr

	;Get number representation length
	push offset resultNumberString
	call lstrlen
	;Now EAX has number of used bytes in resultString
	;Add \r\n to string and to used length
	mov [resultNumberString + EAX], 0Dh
	mov [resultNumberString + EAX + 1], 0Ah
	;Add \0
	mov [resultNumberString + EAX + 2], 0
	add EAX, 3
	mov resultNumberStringUsedLength, EAX

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
	push resultNumberStringUsedLength
	push offset resultNumberString
	push outputHandle
	call WriteConsole

	;Clear result number string
	mov ECX, 0
	mov EBX, resultNumberStringMaxLength
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