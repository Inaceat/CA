.486
.model flat, stdcall
option casemap :none


include WINDOWS.INC

include masm32.inc
includelib masm32.lib

include kernel32.inc
includelib kernel32.lib


TComplexNumber struct
	Re dq ?
	Im dq ?
TComplexNumber ends


;int PrintComplexNumber(TComplexNumber* complexNumber)
;		
;		Prints complex number to console.
;
;Input:
;	complexNumber	- [EBP + 8]
;
;Output:
;	none
.data
	reString db 100 dup(0)
	imString db 100 dup(0)

	complexNumberFormatTemplate db "(%.5s, %.5s) ", 0

	numberString db 100 dup(0)
.code
PrintComplexNumber proc
;Prologue
	push EBP
	mov EBP, ESP
	push EAX
	push EBX
	push ECX
	push EDX

	mov EBX, [EBP + 8]	;Load number address to EBX

;Convert real part to string
	push offset reString
	push dword ptr ((TComplexNumber ptr [EBX]).Re + 4)
	push dword ptr ((TComplexNumber ptr [EBX]).Re)
	call FloatToStr

;Convert imaginary part to string
	push offset imString
	push dword ptr ((TComplexNumber ptr [EBX]).Im + 4)
	push dword ptr ((TComplexNumber ptr [EBX]).Im)
	call FloatToStr

;Format number string, copy to output string
	push offset imString
	push offset reString
	push offset complexNumberFormatTemplate
	push offset numberString
	call wsprintf
	;Align stack after 'wsprintf'
	add ESP, 16

;Print number
	push NULL                
	push offset charsWritten
	push EAX
	push offset numberString
	push outputHandle
	call WriteConsole

;Epilogue & return
	pop EDX
	pop ECX
	pop EBX
	pop EAX
	pop EBP
	ret 4
PrintComplexNumber endp


;int PrintComplexNumbersArray(TComplexNumber* array, int arraySize)
;
;		Prints {array} of {arraySize} complex numbers to console.
;
;Input:
;	array		- [EBP + 8]
;	arraySize	- [EBP + 12]
;
;Output:
;	none
.data
	newLineString db 0Dh, 0Ah
	newLineStringLength dd 2
.code
PrintComplexNumbersArray proc
;Prologue
	push EBP
	mov EBP, ESP
	push EAX
	push ECX
	push EDX

	;Init cycle
	mov ECX, [EBP + 8]	;ECX == address of current array element, the first for now

	;Calculate address of after-the-last array element.
	mov EAX, sizeOfTComplexNumber	;EAX == size of one element
	mul dword ptr [EBP + 12]		;EAX == array size in bytes
	add EAX, ECX					;EAX == address of after-the-last array element

	mov EDX, EAX					;Now EDX is after-the-last address, as EAX 'll be used as return value for comparer

	Cycle:
		;If no elements left in array, return.
		cmp ECX, EDX
		je Return

		;Else print current element
		push ECX
		call PrintComplexNumber

		;Prepare next iteration
		add ECX, sizeOfTComplexNumber
		jmp Cycle

Return:
;Print new line chars
	push NULL                
	push offset charsWritten
	push newLineStringLength
	push offset newLineString
	push outputHandle
	call WriteConsole

;Epilogue & return
	pop EDX
	pop ECX
	pop EAX
	pop EBP
	ret 8
PrintComplexNumbersArray endp



;int CompareComplexByRealPart(TComplexNumber* first, TComplexNumber* second)
;		
;		Compares complex numbers {first} and {second} by real part,
;	returns:
;		-1 if {first}.Re < {second}.Re,
;		0 if {first}.Re == {second}.Re,
;		1 if {first}.Re > {second}.Re.
;
;Input:
;	first	- [EBP + 8]
;	second	- [EBP + 12]
;
;Output:
;	EAX - comparison result
.code
CompareComplexByRealPart proc
;Prologue
	push EBP
	mov EBP, ESP
	push EBX

	mov EAX, [EBP + 8];Get {first} address
	mov EBX, [EBP + 12];Get {second} address

	finit

	fld (TComplexNumber ptr [EBX]).Re	;ST == {second}.Re
	fld (TComplexNumber ptr [EAX]).Re	;ST == {first}.Re, ST(1) == {second}.Re

;Compare, put result to EFLAGS
	fcomi ST, ST(1)

	;If {first}.Re > {second}.Re
	ja Greater
	
	;If {first}.Re < {second}.Re
	jb Less

	;Else {first}.Re == {second}.Re
	mov EAX, 0
	jmp Return

Greater:
	mov EAX, 1
	jmp Return

Less:
	mov EAX, -1

Return:
;Epilogue & return
	pop EBX
	pop EBP
	ret 8
CompareComplexByRealPart endp


;int CompareComplexByModulus(TComplexNumber* first, TComplexNumber* second)
;		
;		Compares complex numbers {first} and {second} by modulus,
;	returns:
;		-1 if |{first}| < |{second}|,
;		0 if |{first}| == |{second}|,
;		1 if |{first}| > |{second}|.
;
;Input:
;	first	- [EBP + 8]
;	second	- [EBP + 12]
;
;Output:
;	EAX - comparison result
.code
CompareComplexByModulus proc
;Prologue
	push EBP
	mov EBP, ESP
	push EBX

	mov EAX, [EBP + 8];Get {first} address
	mov EBX, [EBP + 12];Get {second} address

	finit
;Second number modulus
	fld (TComplexNumber ptr [EBX]).Re	;ST == {second}.Re
	fmul ST, ST							;ST == {second}.Re ^ 2

	fld (TComplexNumber ptr [EBX]).Im	;ST == {second}.Im, ST(1) == {second}.Re ^ 2
	fmul ST, ST							;ST == {second}.Im ^ 2, ST(1) == {second}.Re ^ 2
	
	faddp								;ST == {second}.Im ^ 2 + {second}.Re ^ 2
	fsqrt								;ST == abs({second})

;First number modulus
	fld (TComplexNumber ptr [EAX]).Re	;ST == {first}.Re, ST(1) == abs({second})
	fmul ST, ST							;ST == {first}.Re ^ 2, ST(1) == abs({second})

	fld (TComplexNumber ptr [EAX]).Im	;ST == {first}.Im, ST(1) == {first}.Re ^ 2, ST(2) == abs({second})
	fmul ST, ST							;ST == {first}.Im ^ 2, ST(1) == {first}.Re ^ 2, ST(2) == abs({second})
	
	faddp								;ST == {first}.Im ^ 2 + {first}.Re ^ 2, ST(1) == abs({second})
	fsqrt								;ST == abs({first}), ST(1) == abs({second})


;Compare, put result to EFLAGS
	fcomi ST, ST(1)

	;If {first}.Re > {second}.Re
	ja Greater
	
	;If {first}.Re < {second}.Re
	jb Less

	;Else {first}.Re == {second}.Re
	mov EAX, 0
	jmp Return

Greater:
	mov EAX, 1
	jmp Return

Less:
	mov EAX, -1

Return:
;Epilogue & return
	pop EBX
	pop EBP
	ret 8
CompareComplexByModulus endp


;int FindAddressOfMaxInArray(TComplexNumber* array, int arraySize, int (*comparer)(TComplexNumber* first, TComplexNumber* second))
;
;		Returns address of max element in {array} of {arraySize} complex numbers. 
;	Compares complex numbers using procedure {comparer}, which returns to EAX:
;		-1 if {first} < {second},
;		0 if {first} == {second},
;		1 if {first} > |{second}.
;
;Input:
;	array		- [EBP + 8]
;	arraySize	- [EBP + 12]
;	comparer	- [EBP + 16]
;
;Output:
;	EAX - max element address
.code
FindAddressOfMaxInArray proc
;Prologue
	push EBP
	mov EBP, ESP
	push EBX
	push ECX
	push EDX

	;Init cycle
	mov ECX, [EBP + 8]	;ECX == address of current array element, the first for now
	mov EBX, ECX		;EBX == address of max element, the first for now

	;Calculate address of after-the-last array element.
	mov EAX, sizeOfTComplexNumber	;EAX == size of one element
	mul dword ptr [EBP + 12]		;EAX == array size in bytes
	add EAX, ECX					;EAX == address of after-the-last array element

	mov EDX, EAX					;Now EDX is after-the-last address, as EAX 'll be used as return value for comparer

	Cycle:
		;If no elements left in array, return.
		cmp ECX, EDX
		je Return

		;Else compare current array element and current max element
		push ECX
		push EBX
		call dword ptr [EBP + 16]	;compare(max, current)

		;Check comparison result:
		cmp EAX, 0
		;If EAX >= 0, current max element is greater or equal to current array element
		;And current max remains the same.
		jge Continue
		;Else max < current, so save current as max
		mov EBX, ECX

		Continue:
		;Prepare next iteration
		add ECX, sizeOfTComplexNumber
		jmp Cycle

Return:
;Save result to output register
	mov EAX, EBX

;Epilogue & return
	pop EDX
	pop ECX
	pop EBX
	pop EBP
	ret 12
FindAddressOfMaxInArray endp




.data
	sizeOfTComplexNumber dd 16

	complexArray TComplexNumber <1.0, 2.0>, <-4.5, 1.25>, <0.0, -3.1>, <3.5, -1.5>, <2.0, 3.0>
	complexArraySize dd 5

	arrayMessage db "Array of complex numbers:", 0Dh, 0Ah;\r\n
	arrayMessageLength dd 27
	
	maxRealMessage db "Maximum by real part:", 0Dh, 0Ah;\r\n
	maxRealMessageLength dd 23

	maxModulusMessage db "Maximum by modulus:", 0Dh, 0Ah;\r\n
	maxModulusMessageLength dd 21

.data?
	inputHandle dd ?
	outputHandle dd ?
	
	charsWritten dd ?
	charsRead dd ?

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

;Print array
	push NULL                
	push offset charsWritten
	push arrayMessageLength
	push offset arrayMessage
	push outputHandle
	call WriteConsole

	push complexArraySize
	push offset complexArray
	call PrintComplexNumbersArray

;Find in array & print max element by real part
	push NULL                
	push offset charsWritten
	push maxRealMessageLength
	push offset maxRealMessage
	push outputHandle
	call WriteConsole

	push CompareComplexByRealPart
	push complexArraySize
	push offset complexArray
	call FindAddressOfMaxInArray

	push 1
	push EAX
	call PrintComplexNumbersArray

;Find in array & print max element by modulus
	push NULL                
	push offset charsWritten
	push maxModulusMessageLength
	push offset maxModulusMessage
	push outputHandle
	call WriteConsole

	push CompareComplexByModulus
	push complexArraySize
	push offset complexArray
	call FindAddressOfMaxInArray

	push 1
	push EAX
	call PrintComplexNumbersArray

	ret
Task1 endp
end