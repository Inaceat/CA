.486
.model flat, stdcall
option casemap :none


include WINDOWS.INC

include masm32.inc
includelib masm32.lib

include kernel32.inc
includelib kernel32.lib


; -------------------------- ArrayToStr ---------------------
; void arrayToStr(char* buffer, int* array, int size)
;
; Converts array of 32bit numbers to string
;
;Input:
;	buffer ( [EBP + 8] )  - pointer to string as array of chars
;   array  ( [EBP + 12] ) - pointer to array of numbers
;   size   ( [EBP + 16] ) - numbers array size
.data
        template db "%d ", 0    ;String template for one number
.code
ArrayToStr proc
	;Standart prologue
	push EBP
	mov EBP, ESP
	;While there are numbers in array
	cycle:
	        cmp dword ptr [EBP + 16], 0
	        je endFunction
	        ; Convert current number to string
	        mov EAX, [EBP + 12]         ;Pointer to current number
	        push [ EAX ]                ;Number to convert
	        push offset template        ;Conversion template
	        push [EBP + 8]              ;Resulting buffer address
	        call wsprintf               ;EAX will contain chars count written to buffer
	        add ESP, 12                 ;Align stack after wsprintf usage
	        ;Prepare for next number processing
	        add [EBP + 8], EAX          ;Calculate address for next number string
	        add dword ptr [EBP + 12], 4 ;Get next array element
	        dec dword ptr [EBP + 16]    ;Decrease counter
	;Cycle end
	jmp cycle
	endFunction:
	;Standart epilogue
	pop EBP
	;Exit & align stack
	ret 12
ArrayToStr endp

public Task1


.data
	taskMessage db "Enter two numbers:", 0Dh, 0Ah;\r\n
	taskMessageLength dd 20

	numberString db 10+2 dup(0);For number & \r\n

	numberArray dd 2 dup(0);Array of 2 32bit numbers
	numberArrayLength dd 2 

	numberArrayOutputString db 100 dup(0), 0Dh, 0Ah;\r\n
	numberArrayOutputStringLength dd 102;Should be enough for everybody

.data?
	inputHandle dd ?
	outputHandle dd ?
	
	charsWritten dd ?
	charsRead dd ?

	firstNumber dd ?
	secondNumber dd ?

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

;Now create array of two numbers
	mov EAX, firstNumber
	mov numberArray, EAX
	mov EAX, secondNumber
	mov numberArray + 4, EAX

;Convert it to string
	push numberArrayLength
	push offset numberArray
	push offset numberArrayOutputString
	call ArrayToStr

;And print 
	push NULL                
	push offset charsWritten
	push numberArrayOutputStringLength
	push offset numberArrayOutputString
	push outputHandle
	call WriteConsole

	ret
Task1 endp
end