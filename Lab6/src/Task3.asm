.486
.model flat, stdcall
option casemap :none


include WINDOWS.INC

include masm32.inc
includelib masm32.lib

include kernel32.inc
includelib kernel32.lib


;void ConsoleReadDouble(char* inputPromptString, double* valuePointer)
;
;		Prints to console null-terminated string {inputPromptString},
;	reads from console floating-point number and stores in memory,
;	at {valuePointer} address.
;
;Input:
;	inputPromptString	- [EBP + 8]
;	valuePointer		- [EBP + 12]
;
;Output:
;	none
.data
	numberInputString db 100+2 dup(0);For number & \r\n
.code
ConsoleReadDouble proc
;Prologue
	push EBP
	mov EBP, ESP
	push EAX
	push EBX
	push ECX
	push EDX

;Print input prompt
	;Get prompt length
	push [EBP + 8]
	call lstrlen
	;Print prompt
	push NULL                
	push offset charsWritten
	push EAX
	push [EBP + 8]
	push outputHandle
	call WriteConsole
	
;Read number, assuming it is valid floating-point number
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
	push [EBP + 12]
	push offset numberInputString
	call StrToFloat

;Epilogue & return
	pop EDX
	pop ECX
	pop EBX
	pop EAX
	pop EBP

	ret 8
ConsoleReadDouble endp



;void CalculateWeirdFunctionArgsAndValues
;	(double aParam,
;	 double bParam,
;	 double xStart,
;	 double xEnd,
;	 double xDelta,
;	 double** argsArray,
;	 double** valsArray,
;	 int* arraySize)
;
;		Creates and fills {argsArray} and {valsArray} of size {arraySize} with, respectively, arguments
;	and values of function F(a, b, x), where x belongs to [{xStart}, {xEnd}] in increment {xDelta},
;	i.e. {xStart}, {xStart} + {xDelta}, {xStart} + 2*{xDelta}, etc.
;
;					  |sqrt(-ax+a), if x < 1
;		F(a, b, x) = {
;					 |b*ln(x), if x >= 1
;
;		{argsArray} and {valsArray} are pointers to variables that store pointers to first array element,
;	allocated dynamically on process heap, so caller is responsible for deleting them.
;
;		[{xStart}, {xEnd}] is assumed to be correct interval, i.e. {xStart} <= {xEnd}.
;
;Input:
;	aParam		- [EBP + 8]
;	bParam		- [EBP + 16]
;	xStart		- [EBP + 24]
;	xEnd		- [EBP + 32]
;	xDelta		- [EBP + 40]
;	argsArray	- [EBP + 48]
;	valsArray	- [EBP + 52]
;	arraySize	- [EBP + 56]
;
;Output:
;	none
.data
	fpuControlWord dw ?

	arraySize dd ?
	arraySizeBytes dd ?

	heapHandle dd ?
.code
CalculateWeirdFunctionArgsAndValues proc
;Prologue
	push EBP
	mov EBP, ESP
	push EAX
	push EBX
	push ECX
	push EDX

;Calculate array size needed to store args and vals
;Size == floor((xEnd - xStart) / xDelta) + 1
	finit

	fld qword ptr [EBP + 32];xEnd
	fsub qword ptr [EBP + 24];xStart
	;ST == xEnd - xStart

	fdiv qword ptr [EBP + 40];xDelta
	;ST == (xEnd - xStart) / xDelta

	;Change rounding mode to floor
	fstcw fpuControlWord	;Get Control Word Register (CWR) to AX
	mov AX, fpuControlWord	;
	or AX, 0C00h			;Change RC field to 11, it causes numbers to be rounded towards zero (0C00h == 0000_1100_0000_0000b)
	push EAX				;Load back to CWR
	fldcw [ESP]				;
	pop EAX					;Clear stack
	
	;Round
	frndint
	;ST == floor((xEnd - xStart) / xDelta)

	;Restore CWR
	fldcw fpuControlWord

	fld1
	fadd
	;ST == floor((xEnd - xStart) / xDelta) + 1
	
	;Get calculated array size
	fist arraySize					;Load size to 'local' variable
	mov EBX, arraySize				;Copy to EBX
	mov EAX, dword ptr [EBP + 56]	;Address of output variable
	mov dword ptr [EAX], EBX		;Copy to output, {arraySize} variable
	
	;Now arraySize variable (and EBX) contains NUMBER of elements in array
	;But we need BYTES. Array contains 'double' values with sizeof == 8, so:
	shl EBX, 3
	mov arraySizeBytes, EBX


;Allocate memory and store pointers in memory {argsArray} and {valsArray} point to
	;Get Heap handle to EAX
	call GetProcessHeap
	mov heapHandle, EAX

	;Allocate for vals array
	push arraySizeBytes
	push 12				;HEAP_ZERO_MEMORY | HEAP_GENERATE_EXCEPTIONS
	push heapHandle
	call HeapAlloc 
	;Store allocated memory pointer to {valsArray}
	mov EBX, [EBP + 52]
	mov [EBX], EAX

	;Allocate for args array
	push arraySizeBytes
	push 12				;HEAP_ZERO_MEMORY | HEAP_GENERATE_EXCEPTIONS
	push heapHandle
	call HeapAlloc 
	;Store allocated memory pointer to {argsArray}
	mov EBX, [EBP + 48]
	mov [EBX], EAX
	
;Calculate function args & vals

	;Prepare cycle
	mov ECX, EAX			;EAX == pointer to current (now first) {argsArray} empty cell
	add ECX, arraySizeBytes	;ECX == pointer to {argsArray} after-the-last cell
	
	mov EBX, [EBP + 52]		;EBX == pointer to current (now first) {valsArray} empty cell
	mov EBX, [EBX]

	;Loading {xStart} value into first {argsArray} cell
	push [EBP + 24]
	pop [EAX]
	push [EBP + 28]
	pop [EAX + 4]	;Smth like "mov qword ptr [EAX], qword ptr [EBP + 24]"


	finit
	fld qword ptr [EAX]		;Now ST == argument, X

	Cycle:;At the beginning ST == X
		fld1					;Now ST == 1, ST(1) == X
		
		fcomi ST, ST(1)			;Compare 1 and X
		ja IfXLowerThanOne		;If 1 > X, i.e. X < 1, f(X) = a(1-X)
	
		;Now X >= 1, so f(X) == b * ln(X) == (b / log2(e)) * log2(X) == b * 1/logE(2) * log2(X)
		fstp ST						;Now ST == X
		fldln2						;Now ST == logE(2), ST(1) == X
		fmul qword ptr [EBP + 16]	;Now ST == b * logE(2), ST(1) == X
		fxch						;Now ST == X, ST(1) == b * logE(2)
		fyl2x						;Now ST == b * ln(X)
		jmp AfterFuncCalculation
	
	IfXLowerThanOne:
		;Now X < 1, so f(X) == a * (1-X)
		fsubrp						;Now ST == (1-X)
		fmul qword ptr [EBP + 8]	;Now ST == a * (1-X)
		
	AfterFuncCalculation:
		fstp qword ptr [EBX]	;Store f(X) to {valsArray}

		fld qword ptr [EAX]			;Load X
		fadd qword ptr [EBP + 40]	;Add {xDelta}
		
		add EAX, 8			;Increase {argsArray}
		add EBX, 8			;and {valsArray} pointers.
		
		cmp EAX, ECX		;If {argsArray} current ptr is after last array cell
		jae CycleExit		;Exit cycle

		fst qword ptr [EAX]	;Else load X + {xDelta} to new {argsArray} empty cell
							;So ST == X, as we need at the cycle beginning
		jmp Cycle			;Repeat

CycleExit:
;Epilogue & return
	pop EDX
	pop ECX
	pop EBX
	pop EAX
	pop EBP

	ret 28
CalculateWeirdFunctionArgsAndValues endp




.data
	taskMessage db "Enter some data, please:", 0Dh, 0Ah;\r\n
	taskMessageLength dd 26
	
	aParamInputPrompt db "  a: ", 0
	bParamInputPrompt db "  b: ", 0

	xStartInputPrompt db "  x1: ", 0
	xEndInputPrompt db "  x2: ", 0
	xDeltaInputPrompt db "  dx: ", 0

	functionTableCaption db "     x     |    f(x)   ", 0
	
	;numberString db 10+2 dup(0);For number & \r\n
	;
	;resultMessage db "3a - (a+b)/2 = "
	;resultMessageLength dd 15
	;
	;resultNumberString db 10 dup(0), 0Dh, 0Ah;For number & \r\n
	;resultNumberStringLength dd 12;Should be enough

	aParamNumber dq 3.7
	bParamNumber dq 2.0
	
	xStartNumber dq -6.0
	xEndNumber dq 6.0
	xDeltaNumber dq 3.5

.data?
	inputHandle dd ?
	outputHandle dd ?
	
	charsWritten dd ?
	charsRead dd ?


	;aParamNumber dq ?
	;bParamNumber dq ?
	;
	;xStartNumber dq ?
	;xEndNumber dq ?
	;xDeltaNumber dq ?


	functionArgumentsArrayPointer dd ?
	functionValuesArrayPointer dd ?

	functionValuesCount dd ?

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
	
;Read user input
	;push offset aParamNumber
	;push offset aParamInputPrompt
	;call ConsoleReadDouble
	;
	;push offset bParamNumber
	;push offset bParamInputPrompt
	;call ConsoleReadDouble
	;
	;push offset xStartNumber
	;push offset xStartInputPrompt
	;call ConsoleReadDouble
	;
	;push offset xEndNumber
	;push offset xEndInputPrompt
	;call ConsoleReadDouble
	;
	;push offset xDeltaNumber
	;push offset xDeltaInputPrompt
	;call ConsoleReadDouble

;Calculate weird function arguments and values tables
	push offset functionValuesCount
	push offset functionValuesArrayPointer
	push offset functionArgumentsArrayPointer
	push dword ptr xDeltaNumber + 4
	push dword ptr xDeltaNumber
	push dword ptr xEndNumber + 4
	push dword ptr xEndNumber
	push dword ptr xStartNumber + 4
	push dword ptr xStartNumber
	push dword ptr bParamNumber + 4
	push dword ptr bParamNumber
	push dword ptr aParamNumber + 4
	push dword ptr aParamNumber
	call CalculateWeirdFunctionArgsAndValues

;Print resulting table
	
	
	ret
Task3 endp
end