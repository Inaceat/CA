.486
.model flat, stdcall
option casemap :none


include WINDOWS.INC

include masm32.inc
includelib masm32.lib

include kernel32.inc
includelib kernel32.lib


.code
;int GetNthFibonacciNumber(int N)
;		
;		Returns Nth Fibonacci number
;
;Input:
;	N - [EBP + 8]
;
;Output:
;	EAX - Nth Fibonacci number
GetNthFibonacciNumber proc
;Prologue
	push EBP
	mov EBP, ESP
	push EBX
	push ECX

;Stop condition
	;If {N} == 0 or {N} < 0
	cmp dword ptr [EBP + 8], 0
	;Return 0
	mov EAX, 0
	jle Return

	;If {N} == 1
	cmp dword ptr [EBP + 8], 1
	;Return 1
	mov EAX, 1
	je Return

;If {N} > 1, return F(N-2) + F(N-1)
	;ECX = N-2
	mov ECX, [EBP + 8]
	sub ECX, 2
	;Get (N-2)th Fib. number
	push ECX
	call GetNthFibonacciNumber
	
	;EBX = F(N-2)
	mov EBX, EAX

	;ECX = N-1
	add ECX, 1
	;Get (N-1)th Fib. number
	push ECX
	call GetNthFibonacciNumber
	
	;EAX is F(N-1) now, so add F(N-2)
	add EAX, EBX
	;Now Nth number in EAX is ready for returning

Return:
;Epilogue & return
	pop ECX
	pop EBX
	pop EBP	
	ret 4
GetNthFibonacciNumber endp


.data
	taskMessage db "Enter N:", 0Dh, 0Ah;\r\n
	taskMessageLength dd 10

	numberString db 10+2 dup(0);For number & \r\n

	resultMessage db "Nth Fibonacci number is "
	resultMessageLength dd 24

	resultNumberString db 10 dup(0), 0Dh, 0Ah;For number & \r\n
	resultNumberStringLength dd 12;Should be enough

.data?
	inputHandle dd ?
	outputHandle dd ?
	
	charsWritten dd ?
	charsRead dd ?

	number dd ?

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

;Read number, assuming it is valid 32-bit value
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
	mov number, EAX


;Find {number}th Fibonacci number
	push number
	call GetNthFibonacciNumber


;And print it
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