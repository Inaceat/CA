.486
.model flat, stdcall
option casemap :none


include WINDOWS.INC

include masm32.inc
includelib masm32.lib

include kernel32.inc
includelib kernel32.lib


public Task3


.data
	taskMessage db "Enter three numbers:", 0Dh, 0Ah;\r\n
	taskMessageLength dd 22

	numberString db 10+2 dup(0);For number & \r\n

	numberOutputString db 10 dup(0), 0Dh, 0Ah;\r\n
	numberOutputStringLength dd 12;Should be enough for everybody

	resultMessage db "Result: "
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
	cNumber dd ?

	resultNumber dd ?

.code
Task3:
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

;Calculate expression (a^7 + b/32)/c + (a^7 + b/32)%c
	mov EAX, aNumber
	mul aNumber;1, assuming a^2 is still 32bit. OF = 1 if not.
	mov EBX, EAX;Saving a^2
	mul EAX;2, now EAX = a^4, assuming still 32bit.
	mul EBX;3, EAX = a^6
	mul aNumber;4, now EDX:EAX = a^7, not 32 bit anymore.

	mov EBX, bNumber
	shr EBX, 5; b = b / 32

	add EAX, EBX;lower part
	adc EDX, 0;if EAX, lower is overflowed, carry should be added to EDX, higher part
	;Now EDX:EAX contains (a^7 + b/32)
	
	;NOW I ASSUME THERE WON'T BE ANY OVERFLOWS
	div cNumber;EAX now has quotient, EDX - remainder

	add EAX, EDX
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