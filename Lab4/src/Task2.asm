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

	overflowMessage db "Whoops, overflow occured. Try another numbers!", 0Dh, 0Ah;\r\n
	overflowMessageLength dd 48

.data?
	inputHandle dd ?
	outputHandle dd ?
	
	charsWritten dd ?
	charsRead dd ?

	aNumber dd ?
	bNumber dd ?

	resultNumber dd ?

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

;Calculate a * b WITHOUT mul
	mov ECX, bNumber;Counter
	mov EAX, 0;Result

DoIteration:
	;Check if should stop
	cmp ECX, 0
	je FinishMultiplication
	;If not, add a to result, decrease counter
	add EAX, aNumber
	dec ECX
	;And repeat
	jmp DoIteration

FinishMultiplication:
	mov resultNumber, EAX

;Convert result to string
	push offset numberOutputString
	push resultNumber
	call dwtoa

;Print to console message
	push NULL                
	push offset charsWritten
	push resultMessageLength
	push offset resultMessage
	push outputHandle
	call WriteConsole

;And number itself
	push NULL                
	push offset charsWritten
	push numberOutputStringLength
	push offset numberOutputString
	push outputHandle
	call WriteConsole

	ret

OverflowError:
	push NULL                
	push offset charsWritten
	push overflowMessageLength
	push offset overflowMessage
	push outputHandle
	call WriteConsole

	ret
end