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
		fsqrt						;Now ST == sqrt(a(1-X))
		
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

	ret 52
CalculateWeirdFunctionArgsAndValues endp



;void BuildTableLine(double arg, double val, char* tableLine, const char* lineFormat)
;
;		Fills {tableLine} with string representation of {arg} and {val},
;	using specified {lineFormat}.
;		Caller is responsible for assuring that {tableLine} has enough space to store
;	formatted table line.
;
;Input:
;	arg			- [EBP + 8]
;	val			- [EBP + 16]
;	tableLine	- [EBP + 24]
;	lineFormat	- [EBP + 28]
;
;Output:
;	none
.data
	argNumberString db 100 dup(0)
	valNumberString db 100 dup(0)
	
	numberStringLength dd 100
.code
BuildTableLine proc
;Prologue
	push EBP
	mov EBP, ESP
	push EAX
	push EBX
	push ECX
	push EDX

;Convert function argument to string
	push offset argNumberString
	push dword ptr [EBP + 12]
	push dword ptr [EBP + 8]
	call FloatToStr

;Convert function value to string
	push offset valNumberString
	push dword ptr [EBP + 20]
	push dword ptr [EBP + 16]
	call FloatToStr
	

;Format arg and val strings, copy to output string
	push offset valNumberString
	push offset argNumberString
	push [EBP + 28]
	push [EBP + 24]
	call wsprintf
	;Align stack after 'wsprintf'
	add ESP, 16

;Clear arg and val strings
	mov ECX, offset argNumberString
	add ECX, numberStringLength		;ECX == after-the-last address of argumebt string
	
	mov EAX, offset argNumberString	;EAX == current 'argNumberString' char pointer
	mov EBX, offset valNumberString	;EBX == current 'valNumberString' char pointer

	ClearCycle:
		;Clear current bytes
		mov byte ptr [EAX], 0
		mov byte ptr [EBX], 0

		;Increase current byte pointers
		add EAX, 1
		add EBX, 1

		;If current byte belongs to string, repeat
		cmp EAX, ECX
		jb ClearCycle

;Epilogue & return
	pop EDX
	pop ECX
	pop EBX
	pop EAX
	pop EBP

	ret 24
BuildTableLine endp

;void PrintFormattedFunctionTable(double* argsArray, double* valsArray, int arraySize)
;
;		Prints to console table of function arguments from {argsArray} 
;	and values from {valsArray}.
;
;Input:
;	argsArray	- [EBP + 8]
;	valsArray	- [EBP + 12]
;	arraySize	- [EBP + 16]
;
;Output:
;	none
.data
	functionTableCaption db "     x     |    f(x)   ", 0Dh, 0Ah;\r\n
	functionTableCaptionLength dd 11+1+11+2

	formatString db "%11.11s|%11.11s", 0Dh, 0Ah, 0;11 symbols, '|', 11 symbols again, \r\n

	tableLineString db 11+1+11+2 dup(0),0;Ends with \0 because 'wsprintf' writes \0 after last char.
	tableLineStringLength dd 25;11+1+11+2

.code
PrintFormattedFunctionTable proc
;Prologue
	push EBP
	mov EBP, ESP
	push EAX
	push EBX
	push ECX
	push EDX
	push ESI
	push EDI


;Print table caption
	push NULL                
	push offset charsWritten
	push functionTableCaptionLength
	push offset functionTableCaption
	push outputHandle
	call WriteConsole

;Print table values
	
	mov ESI, dword ptr [EBP + 8]	;ESI == address of current element in {argsArray}
	mov EDI, dword ptr [EBP + 12]	;EDI == address of current element in {valsArray}
	
	mov EBX, dword ptr [EBP + 16]	;EBX == number of elements in {argsArray}
	shl EBX, 3						;EBX == number of bytes in {argsArray}
	add EBX, ESI					;EBX == address of after-the-last {argsArray} element

	LinePrintCycle:
		push offset formatString
		push offset tableLineString
		push [EDI + 4]
		push [EDI]
		push [ESI + 4]
		push [ESI]
		call BuildTableLine
	
		;Print table line
		push NULL                
		push offset charsWritten
		push tableLineStringLength
		push offset tableLineString
		push outputHandle
		call WriteConsole

		add ESI, 8
		add EDI, 8

		cmp ESI, EBX
		jb LinePrintCycle

;Epilogue & return
	pop EDI
	pop ESI
	pop EDX
	pop ECX
	pop EBX
	pop EAX
	pop EBP	
	
	ret 12
PrintFormattedFunctionTable endp



.data
	taskMessage db "Enter some data, please:", 0Dh, 0Ah;\r\n
	taskMessageLength dd 26
	
	aParamInputPrompt db "  a: ", 0
	bParamInputPrompt db "  b: ", 0

	xStartInputPrompt db "  x1: ", 0
	xEndInputPrompt db "  x2: ", 0
	xDeltaInputPrompt db "  dx: ", 0

	
.data?
	inputHandle dd ?
	outputHandle dd ?
	
	charsWritten dd ?
	charsRead dd ?


	aParamNumber dq ?
	bParamNumber dq ?
	
	xStartNumber dq ?
	xEndNumber dq ?
	xDeltaNumber dq ?


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
	push offset aParamNumber
	push offset aParamInputPrompt
	call ConsoleReadDouble
	
	push offset bParamNumber
	push offset bParamInputPrompt
	call ConsoleReadDouble
	
	push offset xStartNumber
	push offset xStartInputPrompt
	call ConsoleReadDouble
	
	push offset xEndNumber
	push offset xEndInputPrompt
	call ConsoleReadDouble
	
	push offset xDeltaNumber
	push offset xDeltaInputPrompt
	call ConsoleReadDouble

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
	push functionValuesCount
	push functionValuesArrayPointer
	push functionArgumentsArrayPointer
	call PrintFormattedFunctionTable

;Clear memory
	push functionArgumentsArrayPointer
	push 0
	push heapHandle
	call HeapFree

	push functionValuesArrayPointer
	push 0
	push heapHandle
	call HeapFree

	ret
Task3 endp
end