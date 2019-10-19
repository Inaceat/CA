.486
.model flat, stdcall
option casemap :none

include WINDOWS.INC

include kernel32.inc
includelib kernel32.lib

include Task1.inc


.data
	taskSelectionPrompt db "Enter task number, or 0 to exit:", 0Dh, 0Ah;/r/n
	taskSelectionPromptLength dd 34

	taskInputString db 3 dup(0)

	wrongTaskNumberMessage db "Wrong task number!", 0Dh, 0Ah;/r/n
	wrongTaskNumberMessageLength dd 20


	DescriptionTask1 db "1. Do nothing useful", 0Dh, 0Ah, 0;/r/n

	tasksArray dd Exit, Task1
	tasksArraySize dd 2

	tasksDescriptionsArray dd DescriptionTask1
	tasksDescriptionsArraySize dd 1

.data?
	inputHandle dd ?
	outputHandle dd ?
	
	charsWritten dd ?
	charsRead dd ?

	selectedTaskNumber dd ?

.code
main:

;Get system I/O Handles
	;Get I
	push STD_INPUT_HANDLE
	call GetStdHandle
	mov inputHandle, EAX
	
	;Get O
	push STD_OUTPUT_HANDLE
	call GetStdHandle
	mov outputHandle, EAX

TaskSelection:
;Print task selection prompt
	push NULL                
	push offset charsWritten
	push taskSelectionPromptLength
	push offset taskSelectionPrompt
	push outputHandle
	call WriteConsole

;Print tasks
	

;Read number of selected task
	;Read user input, 1+2(/r/n) symbol max
	push NULL
	push offset charsRead
	push 3
	push offset taskInputString
	push inputHandle
	call ReadConsole
	
	;Check user input for being 0 to 9 digit
	cmp taskInputString, 30h
	jl WrongTaskNumber
	cmp taskInputString, 39h
	jg WrongTaskNumber

	;Convert task string to number
	xor EAX, EAX
	mov AL, taskInputString
	sub AL, 30h
	mov selectedTaskNumber, EAX

	;Check if task exists
	mov EAX, tasksArraySize
	cmp selectedTaskNumber, EAX
	jge WrongTaskNumber

;Call selected task
	mov EAX, selectedTaskNumber
	call [tasksArray + 4 * EAX]
;After task completed, do again
	jmp TaskSelection

WrongTaskNumber:
	;Print error message
	push NULL
	push offset charsWritten
	push wrongTaskNumberMessageLength                  
	push offset wrongTaskNumberMessage
	push outputHandle
	call WriteConsole

	;Try again
	jmp TaskSelection

Exit:
	push 0
	call ExitProcess

end main