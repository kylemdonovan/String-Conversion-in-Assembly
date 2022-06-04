TITLE  String Primitives and Macros       (Proj6Donovaky.asm)

; Author: Kyle Donovan
; Last Modified: 6/1/2022
; OSU email address: donovaky@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6                Due Date: 6/8/2022
; Description:   Im going to use this program to take numbers and calc the average and stuff because why would i have a calculator

INCLUDE Irvine32.inc

;;prompt, input, max char entered, string character count
mGetString MACRO prompt, userInput, maxCharEnt, strCharCount
	
	push		EDX
	push		ECX
	push		EBX ;;this can be removed
	push		EAX

	mdisplayString	prompt

	mov			EDX, userInput   ;; 12?? --> this is the users input
	mov			ECX, maxCharEnt	;; this is the length of the users input

	call		ReadString

	mov			strCharCount, EAX

	pop			EAX
	pop			EBX ;;this can be removed
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
MAX		= 21 ;; this is the max size i will accept from a string unless it needs to be 4x this
TEN		= 10 ;;this is how many numbers i will need to store

.data
welcome_1	BYTE	"String Primitives and Macros! Programmed by Kyle Donovan", 0
purpose_1	BYTE	"Please provide 10 signed decimal integers. Each number needs to be small enough to fit inside a 32 bit register.", 0
purpose_2	BYTE	"After you have finished inputting the raw numbers I will display a list of the integers, their sum, and their average value.", 0
get_prompt	BYTE	"Please enter a signed integer: ", 0
error		BYTE	"ERROR: You did not enter a signed number or your number was too big. ", 0

usrArray	SDWORD	TEN DUP(?) ;;change to byte?
userInput	BYTE	MAX DUP(?)
byteCount	DWORD	?
retry		BYTE	"Please try again. ", 0

goodbye		BYTE	"And so marks our fateful end. Adeiu!", 0
party		BYTE	"woooooo",0
num_count	DWORD	10
negNum		BYTE	"This num is negative", 0
regularNum	BYTE	"This num is NOT negative", 0

AlStorage	DWORD	?
positivity  BYTE	"This has aaa +", 0


; (insert variable definitions here)

.code

; ----------------------------------------------------------------------------------------------------------
; Name: main
;
; Calls Randomize to start, then:
; Calls the procedures in the order of: introduction, fillArray, displayList, displayMedian, countList, and farewell
;
; Preconditions: Proj5_Donovaky.asm is added to our Visual Studio project folder
;
; Postconditions: The program generates a random array, displays array, sorts array, calculates and displays median, displays sorted list, and displays counts of each number above 10
;
; Receives: 
;		introduction	= introduce our program title, name, extra credits, and instructions for our user
;		fillArray		= fills our array with random integers
;		sortList		= orders our list from least to greatest
;		exchangeElements= a subprocedure of sortList which exchanges the values if they are not in order
;		displayMedian	= displays the median of our list
;		displayList		= displays the list, whether sorted or unsorted or as a count measure
;		countList		= counts the number of items that appear in our list
;		farewell		= bids our user adieu
;
; Returns: none
; ----------------------------------------------------------------------------------------------------------

main PROC

	;; calls introduction which posts a welcome message to our user and explains the purpose of the program
	push	OFFSET welcome_1 ;; + x
	push	OFFSET purpose_1 ;; + x
	push	OFFSET purpose_2 ;;+x
	call	introduction

	mov		ECX, TEN
	mov		EDI, OFFSET usrArray

_UserArray:
	
	push	OFFSET retry	;; 28
	push	OFFSET error	;; 24
	push	OFFSET byteCount ;;20
	push	OFFSET SIZEOF userInput ;;16
	push	OFFSET userInput		;;12
	push	OFFSET get_prompt ;;+8
	call	ReadVal
	
	mov		[EDI], EAX
	add		EDI, 4
	loop	_UserArray

	;; we get the number as a string from the user
	;push	OFFSET get_prompt
	;call	mGetString


	;; displays goodbye message
	;push	OFFSET goodbye
	;call	farewell


	Invoke ExitProcess,0	; exit to operating system
main ENDP

; ----------------------------------------------------------------------------------------------------------
; Name: introduction
; 
; ; Introduces the user to our program, explains what our program does
;
; Preconditions: None
;
; Postconditions: changes register EDX
;
; Receives: 
;
; Returns: None
; ----------------------------------------------------------------------------------------------------------

introduction PROC

	push	EBP
	mov		EBP,ESP
	push	EDX
	
	call	CrLf
	;;string which communicates who we are and program title
	mDisplayString [EBP+16]
	call	CrLf
	call	CrLf
	;; welcome user string (1 of 2)
	mDisplayString [EBP+12]
	call	CrLf
	mDisplayString [EBP+8]	;; welcome user string (2 of 2)
	call	CrLf
	call	CrLf
	pop		EDX
	pop		EBP
	ret		12

introduction ENDP

ReadVal PROC
	push	EBP
	mov		EBP, ESP
	push	EAX
	push	EBX
	push	ECX
	push	EDX
	;push	EDI
	push	ESI

_ReadValChkPt:
	;;prompt, input, max char entered, string char count
	mGetString	[EBP+8], [EBP+12], [EBP+16], [EBP+20]

	mov		ESI, [EBP+12]
	mov		EBX, [EBP+20]

	cmp		EBX, 11
	jg		_Error
	jmp		_Checker

_Error:
;; this is the please try again message
	mDisplayString [EBP+24]
	call	CrLf
	mDisplayString [EBP+28]
	jmp		_ReadValChkPt
	;; prompt, input, max char entered, string char count

_Checker:	
	;; i want to use this spot to check EACH value of my string

	cld

	lodsb	
	
	;; need to convert substring to ASCII?

	cmp		AL, 45
	je		_NegativeZone
	cmp		AL, 43
	je		_ExplicitlyPositive
	jne		_TheOtherTestingZone

	;;; check if its a number-  if it is a number its all good code continues
	;;; if its a negative, we need to send it somewhere else - probably also needs one for +
	;;; if its not a number and not negative, send it back to _Error



_TheOtherTestingZone: ;;;this tests the number
	;mov		EDX, OFFSET regularNum
	;call	WriteString
	;;check if first val is a number
	lodsb
	cmp		AL,48
	jl		_Error ;; if below 1 range, error
	cmp		AL, 57
	jg		_Error	;; if above 0 range, error
	
	;;basically this should decrease our false loop as we check each value
	;; so we need to store our value of the size into a var and decrement it


	;dec		EBX we can decrement in the number converter 
	;; this should probbaly jump to the conversion, which should jump back to TheOtherTestingZone
	;;jg		_TheOtherTestingZone

	;;push	ECX
	jg		_TheOtherTestingZone

	jmp		_End

_NegativeZone: 
	;mov		EDX, OFFSET negNum
	;call	WriteString
	mov		EDX, 1
	dec		EBX
	jmp		_TheOtherTestingZone

;;check if second fval is a number

;_TheItIsANumberZone:

_ExplicitlyPositive:
	dec		EBX
	;mov		EDX, OFFSET positivity
	;call	WriteString
	jmp		_TheOtherTestingZone


;_setNeg:
	;; neg ##whatever our number string is
;	jmp		_EndChkPt

_End:
;	cmp		EDX, 1
;	je		_setNeg

_EndChkPt:

	pop		ESI
	;pop		EDI
	pop		EDX
	pop		ECX
	pop		EBX
	pop		EAX
	pop		EBP
	ret		24

ReadVal ENDP


farewell PROC
	push	EBP
	mov		EBP, ESP

	mov		EDX, [EBP+8]
	call	WriteString
	call	CrLf

	pop		EBP
	ret		4

farewell ENDP



END main



	;;this should be user input
;	mov		ESI, [EBP+12]

	;;this should be the size of the user input but it isnt actually its 10 i think
;	mov		EBX, [EBP+16]

;	cmp		EBX, 11
;	jg		_Error

;	jmp		_End


;_Error:
	;; this is the error message
;	mDisplayString [EBP+24]
;	call	CrLf
	;; this is the please try again message
;	mDisplayString [EBP+28]
;	call	CrLf

	;; prompt, input, max char entered, string char count
;	mGetString	[EBP+8], [EBP+12], [EBP+16], [EBP+20]


;_End:
;	mDisplayString [EBP+32]


;_Conversion:
	;;; i have my number is AL = > i want to convert this number into an int because my number is a string
	;;; for how many numbers are in this, i should convert for that many times. 

	;; conversion time!!!
	;; numInt = 10 * numInt + (numChar-48)


	;; push ECX

;	imul	ECX, 10
;	mov		ECX, EAX
	
;	push	EAX

;	sub		AL, 48

	;; the ECX should be the places, the EAX should be the AL sub 48 = INT
;	add		ECX, EAX

	;;;need to get imul 10,ECX to be 0, 1, 10, 100, ETC

;	cmp		ECX, 1
;	jl		_IncECX

;	pop		EAX

;	jmp		_TheOtherTestingZone
	;;if ecx == 1:
	;; jump to inc ecx land

;_IncECX:
	
;	inc		ECX ;;dk bout this
;	jmp		_TheOtherTestingZone