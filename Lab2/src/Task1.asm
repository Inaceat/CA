.486
.model flat, stdcall
option casemap :none


include WINDOWS.INC

include kernel32.inc
includelib kernel32.lib


public Task1


.data
	msg db "task1"
	
.data?
	outH dd ?
	writtenChars dd ?



.code
Task1:

	push STD_OUTPUT_HANDLE
	call GetStdHandle
	mov outH, EAX
	
	push NULL                
	push offset writtenChars
	push 5                  
	push offset msg
	push outH
	call WriteConsole

	ret
end