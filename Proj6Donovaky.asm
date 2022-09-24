TITLE  String Primitives and Macros       (Proj6Donovaky.asm)

; Author: Kyle Donovan
; Last Modified: 6/5/2022
; OSU email address: donovaky@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6                Due Date: 6/5/2022
; Description:   Program which converts strings to integers 
;	via ASCII and then returns them to a string and displays them
;	and calculates and returns the sum of the numbers and the truncated average
;	also includes the running sum from extra credit


INCLUDE Irvine32.inc

;;prompt, input, max char entered, string character count
mGetString MACRO prompt, userInput, maxCharEnt, strCharCount
	
	push		EDX
	push		ECX
	push		EBX				 
	push		EAX

	mdisplayString	prompt

	mov			EDX, userInput   ;; 12 --> this is the users input
	mov			ECX, maxCharEnt	 ;; this is the length of the users input

	call		ReadString

	mov			strCharCount, EAX

	pop			EAX
	pop			EBX				
	pop			ECX
	pop			EDX


ENDM


mDisplayString MACRO string
	push	EDX					;;saves our EDX register
	mov		EDX, string
	call	WriteString
	pop		EDX					;; restores our EDX register
ENDM


LO		= -2147483648
HI		= 2147483647
MAX		= 21					
TEN		= 10					;;this is how many numbers needed to be stored

.data
welcome_1	BYTE	"String Primitives and Macros! Programmed by Kyle Donovan", 0
purpose_1	BYTE	"Please provide 10 signed decimal integers. Each number needs to be small enough to fit inside a 32 bit register.", 0
purpose_2	BYTE	"After you have finished inputting the raw numbers I will display a list of the integers, their sum, and their average value.", 0
get_prompt	BYTE	"Please enter a signed integer: ", 0
error		BYTE	"ERROR: You did not enter a signed number or your number was too big. ", 0
extra1		BYTE	"Extra Credit: 1 - I print the numbers the user inputted as a running sum. "

usrArray	SDWORD	TEN DUP(?) 
userInput	BYTE	MAX DUP(0)

addNum		SDWORD	1 DUP(?)

byteCount	DWORD	?
retry		BYTE	"Please try again. ", 0


goodbye		BYTE	"And so marks our fateful end. Adeiu!", 0
strDisplay	BYTE	"Here are your numbers: ", 0
truncAvg	BYTE	"Your truncated average is: ", 0
summa		BYTE	"The sum is: ", 0
runningSum	SDWORD	0
currentSum	BYTE	"Your running sum is: ", 0

num_count	DWORD	10

stringHold  BYTE	11 DUP(?)	

AlStorage	DWORD	?

spaceComma	BYTE	", ", 0
numStore	SDWORD	?

theSum		SDWORD	?
trunc8dAvg	SDWORD	?

counterino	DWORD	?


.code

; ----------------------------------------------------------------------------------------------------------
; Name: main
;
; Calls the procedures in the order of: introduction, readVal, writeVal, 
;
; Preconditions: Proj6_Donovaky.asm is added to our Visual Studio project folder
;
; Postconditions: Converts, displays some numbers that the user put in
;
; Receives: 
;		
;		readVal			= reads the input from our user 
;		writeVal		= writes the values after conversion
;
; Returns: a converted integer
; ----------------------------------------------------------------------------------------------------------

main PROC
	
	;; calls introduction which posts a welcome message 
	;;to our user and explains the purpose of the program
	mDisplayString OFFSET welcome_1
	call	CrLf
	mDisplayString OFFSET purpose_1
	call	CrLf
	mDisplayString OFFSET purpose_2
	call	CrLf
	mDisplayString OFFSET extra1
	call	CrLf

	mov		ECX, TEN
	mov		EDI, OFFSET usrArray

_UserArray:
	
	push	OFFSET numStore			;; 32
	push	OFFSET retry			;; 28
	push	OFFSET error			;; 24
	push	OFFSET byteCount		;; 20
	push	SIZEOF userInput		;; 16
	push	OFFSET userInput		;; 12
	push	OFFSET get_prompt		;; +8
	call	ReadVal
	

	mDisplayString	OFFSET currentSum

	mov		EDX, numStore
	mov		[EDI], EDX
	add		runningSum, EDX
	push	runningSum
	call	WriteVal

	call	CrLf
	
	add		EDI, 4
	loop	_UserArray


	;; we get the number as a string from the user
	;push	OFFSET get_prompt
	;call	mGetString
	call	CrLf
	mDisplayString OFFSET strDisplay

	mov		ECX, TEN ;;restore my loop value
	mov		EBX, 0
	mov		ESI, OFFSET usrArray

	
_Writing:
	
	mov		EAX, [ESI]
	add		EBX, EAX	


	push	OFFSET stringHold ;;12
	push	EAX				  ;;8

	call	WriteVal

	add		ESI, 4
	cmp		ECX, 1
	je		_ImGonnaJump
	mDisplayString OFFSET spaceComma

_ImGonnaJump:
	loop	_Writing


_SummaMain:	
	;; sums the nums
	mov		EAX, EBX

	call	CrLF
	call	CrLF

	mov		theSum, EBX
	push	OFFSET summa
	mDisplayString OFFSET summa
	push	theSum
	call	WriteVal


	mov		EBX, TEN
	cdq
	idiv	EBX

	mov		trunc8dAvg, EAX		;;trun8dAvg stores my truncated average but more efficiently

	call	CrLf
	call	CrLf


	push	OFFSET truncAvg
	mDisplayString OFFSET truncAvg
	push	trunc8dAvg
	call	WriteVal


	call	CrLf
	call	CrLf
	mDisplayString OFFSET goodbye

	Invoke ExitProcess,0	; exit to operating system
main ENDP


; ----------------------------------------------------------------------------------------------------------
; Name: readVal PROC
; 
; readVal converts our users inputted string into an int
;
; Pre-Condtions: User must enter a number (it does not necessarily need to be valid, but to be converted it does)
;
; Post-Conditions:  returns a converted int 
;
; Receives: [EBP+32]		= numStore, a variable to store the number so we can place it in our array later
;			[EBP+28]		= retry, an encouraging message for our user to try again
;			[EBP+24]		= error, an error message string which is displayed if our user violates our number bounds
;			[EBP+20]		= byteCount, a count of our user's bytes
;			[EBP+16]		= SIZEOF userInput, the size of our user's input in bytes
;			[EBP+12]		= user_input, a string we receive from our user's input value
;			[EBP+8]			= get_prompt, a string which displays a request for our user to enter a number
;
; Returns: returns a converted int in the bounds of our defined parameters
; ----------------------------------------------------------------------------------------------------------

ReadVal PROC
	LOCAL negativeTrue: DWORD
	LOCAL storeVar: DWORD

	push	EDI
	pushad

	push	ESI
	mov		EAX, 0 ;;our numInt is set to zero

	mov		negativeTrue, 0

_ReadValChkPt:
	;;prompt, input, max char entered, string char count
	mGetString	[EBP+8], [EBP+12], [EBP+16], [EBP+20]
	mov		ESI, [EBP+12]
	mov		EBX, 0
	mov		ECX, 0
	mov		EDX, 0
	mov		EBX, [EBP+20]
	cld
	cmp		EBX, 11
	jg		_Error
	mov		EBX,[EBP+12]

	mov		EBX, [EBP+20]
	jmp		_SignChecker

_Error:
;; this is the please try again message
	mDisplayString [EBP+24]
	call	CrLf
	mDisplayString [EBP+28]
	jmp		_ReadValChkPt
	;; prompt, input, max char entered, string char count

_SignChecker:	
	;; i want to use this spot to check EACH value of my string
	
	;; need to convert substring to ASCII?
	lodsb
	cmp		AL, 45
	je		_NegativeZone
	cmp		AL, 43
	je		_ExplicitlyPositive


	cmp		EBX, 0
	jne		_NumberChecker

_NumberChecker:
	cmp		AL,48
	jl		_Error ;; if below 1 range, error
	cmp		AL, 57
	jg		_Error	;; if above 0 range, error
	

	sub		AL, 48 ;;this is needed for accuracy/conversion

	dec		EBX
	cmp		EBX, 0

	jmp		_Conversion
	jmp		_End

_ReloadCheckpoint:
	lodsb
	cmp		EBX, 0
	jne		_NumberChecker
	jmp		_End
	;;; check if its a number-  if it is a number its all good code continues
	;;; if its a negative, we need to send it somewhere else - probably also needs one for +
	;;; if its not a number and not negative, send it back to _Error

_Conversion:
	imul	EDX, 10 ;;this is the 10 * EAX part

	jo		_Error


	movzx	ECX, AL
	add		EDX, ECX

	jo		_Error
	jmp		_ReloadCheckPoint

_NegativeZone: 

	lodsb
	mov		negativeTrue, 1

	dec		EBX
	jmp		_NumberChecker


_ExplicitlyPositive:
	dec		EBX
	lodsb
	;mov		EDX, OFFSET positivity
	;call	WriteString
	jmp		_NumberChecker


_setNeg:
	neg		EDX
	cmp		EDX, LO
	jl		_Error
	mov		EAX,[EBP+32]
	mov		[EAX], EDX

	jmp		_NegativeEnd

_End: ;;this basically checks if user input was negative
	cmp		negativeTrue, 1
	je		_setNeg

_EndChkPt:
	;;;this is where we push the eDX value into our array

	mov		EAX, [EBP+32]
	mov		[EAX], EDX

_NegativeEnd:
	;;pop stack
	pop		ESI
	popad
	pop		EDI
	ret		24

ReadVal ENDP


; ----------------------------------------------------------------------------------------------------------
; Name: writeVal PROC
; 
; writeVal procedure to turn our converted integers into hexadecimal/ASCII
;
; Pre-Condtions: Only works if the user has entered 10 acceptable values.
;
; Post-Conditions: Nothing is changed
;	Don't read the following line if you don't have a sense of humor, (its just a pun for fun) 
;	I'm pushing and I'm popping a cap in your class.  
;
; Receives: [EBP+12]	= strinHold - a way to store the string
;			[EBP+8]     = my converted value from my usrArray - its an individual value
;
; Returns: displays an ASCIII'd value (the 3 Is are not a typo, its how we ASCIII the final value)
; ----------------------------------------------------------------------------------------------------------

WriteVal PROC
	LOCAL	negativeTrue: DWORD
	pushad	
	mov		negativeTrue, 0
	mov		ECX, 0
	
	mov		EDI, [EBP+12]		;; string holder
	mov		EAX, [EBP+8]		;; converted value
	cmp		EAX, 0
	jl		_negativeMaker		;;checks if our number is negative
	jmp		_divisionLoop

_negativeMaker:
	neg		EAX
	mov		negativeTrue, 1
							

_divisionLoop:
	mov		EDX, 0
	mov		EBX, 10
	div		EBX					;;;switched from idiv to div so no cdq
	
	cmp		EAX, 0
	je		_Asciiinator
	add		EDX, 48
	push	EDX					;;preserves our register
	inc		ECX
	jmp		_divisionLoop

_Asciiinator:

	add		EDX, 48					;;this converts our final value of the number
	push	EDX
	inc		ECX

	cmp		negativeTrue, 0
	
	jg		_Negator
	je		_pushString

_Negator:
	mov AL, 45
	call	WriteChar

_pushString:
									;;adds the ascii values into the string
	pop		EAX
	stosb

	loop	_pushString


_FirstEnd:
	xor		EAX, EAX				;;i've been told xor is a valuable tool in exploits
	stosb

	mDisplayString [EBP+12]

_SecondEnd:
	
	mov		negativeTrue, 0
	popad

	ret		8


WriteVal ENDP

END main
