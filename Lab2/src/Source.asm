.486
.model flat, stdcall
option casemap :none

include WINDOWS.INC

include kernel32.inc
includelib kernel32.lib

.data
	messageString db "Hello, World!!!"
	inputBuffer db 12 dup('x')
	fillingChar db 'x'

.data?
	inputHandle dd ?
	outputHandle dd ?
	numberOfChars dd ?

.code
main:

	push STD_INPUT_HANDLE     
	call GetStdHandle         
	mov inputHandle, EAX      
	
	push STD_OUTPUT_HANDLE
	call GetStdHandle
	mov outputHandle, EAX
                        
        ;Read user input, 10 + 2(\r\n) symbols max
	push NULL
	push offset numberOfChars
	push 12
	push offset inputBuffer
	push inputHandle
	call ReadConsole
	
	;remove \r\n from input
	mov EAX, offset inputBuffer
	mov EBX, numberOfChars
	mov CL, fillingChar             
	mov byte ptr [EAX + EBX - 2], CL
	mov byte ptr [EAX + EBX - 1], CL
	
	push NULL                
	push offset numberOfChars
	push 10                  
	push offset inputBuffer
	push outputHandle
	call WriteConsole

	push 0
	call ExitProcess

end main