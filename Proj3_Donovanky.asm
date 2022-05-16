TITLE Proj 3     (Project3_Donovaky.asm)

; Author: 	Kyle Donovan
; Last Modified:	4/28/2022
; Course number/section:   CS271 Section 400
; Description: Requests user to input numbers infinitely and calculates the average, max, min, sum, and the .01 average.

NEG_TWO_HUN = -200
NEG_ONE_HUN = -100
NEG_FIFTY = -50
NEG_ONE = -1
ZERO = 0
ONE = 1
NEG_ONE_K = -1000
ONE_K = 1000

INCLUDE Irvine32.inc

.data
welcome				BYTE	"--Welcome to the Integer Accumulator by Kyle Donovan--", 0
request_username	BYTE	"What is your name? ", 0
instructions		BYTE	"Please enter a number between [-200, -100]  or [-50, -1]!", 0
instructions_2		BYTE	"Enter a non-negative number when you are finished to see results.", 0
userName			BYTE	33 DUP(0)
addressing_user		BYTE	"Hello there, ", 0  
exclamation_point	BYTE	"!", 0
goodbye				BYTE	"And so ends our fun. Adieu!", 0
ask_number			BYTE	"Enter number: ", 0
count				DWORD	0
entered_num			SDWORD	?
sum 				SDWORD	?
out_of_range		BYTE	"This number is negative but it is outside of the requested range.", 0
max					SDWORD	-200
min					SDWORD	-1
you_entered			BYTE	"You entered ", 0
valid_numbers		BYTE	" valid numbers", 0
max_preface			BYTE	"The maximum valid number is ", 0
min_preface			BYTE	"The minimum valid number is ", 0
sum_preface			BYTE	"The sum of your numbers is ", 0
avg					SDWORD	?
avg_preface			BYTE	"The average of your valid numbers is ", 0
rounded_avg			SDWORD	?
round_avg_preface	BYTE	"The rounded average is ", 0
avg_remainder		SDWORD	?	
new_remainder		SDWORD	?
extra_credit_1		BYTE	"**EC: Number the lines during user input. Increment the line number only for valid number entries", 0
extra_credit_2		BYTE	"**EC: Calculate to the nearest .01 average", 0

no_number			BYTE	"No valid number was entered."

one_k_sum			SDWORD	?
one_k_avg			SDWORD	?
one_k_val			SDWORD	?
one_k_remain		SDWORD	?
one_k_preface		BYTE	"The .01 average is .", 0

.code
main PROC

;------------------------------------------------------------------------
;Introduce ourselves and our program to our user. Instructs user on how to use program (Introduction)
;------------------------------------------------------------------------
_Introduction:
	mov		EDX, OFFSET welcome
	call	WriteString
	call	CrLf
	mov		EDX, OFFSET extra_credit_1
	call	WriteString
	call	CrLf
	mov		EDX, OFFSET extra_credit_2
	call	WriteString
	call	CrLf


;------------------------------------------------------------------------
;Gets the user's name
;------------------------------------------------------------------------
_Get_Username:
	mov		EDX, OFFSET request_username
	call	WriteString
	mov		EDX, OFFSET userName
	mov		ECX, 32
	call	ReadString

;------------------------------------------------------------------------
;Greets our user
;------------------------------------------------------------------------
_Greet_User:
	mov		EDX, OFFSET addressing_user
	call	WriteString
	mov		EDX, OFFSET userName
	call	WriteString
	mov		EDX, OFFSET exclamation_point
	call	WriteString
	call	CrLf

;------------------------------------------------------------------------
;Gives our user instructions on how to use our program
;------------------------------------------------------------------------
_Give_Instructions:
	mov		EDX, OFFSET instructions
	call	WriteString
	call	CrLf
	mov		EDX, OFFSET instructions_2
	call	WriteString
	call	CrLf

;------------------------------------------------------------------------
;This is the loop that prompts the user to enter a number and displays count. 
;------------------------------------------------------------------------
_Number_Processor:
	mov		EAX, count
	call	WriteDec
	mov		EDX, OFFSET ask_number
	call	WriteString
	call	ReadInt
	mov		entered_num, EAX
	cmp		EAX, 0
	jns		_No_Number

	cmp		EAX, NEG_FIFTY
	jge		_Accumulator

	mov		entered_num, EAX
	cmp		EAX, NEG_TWO_HUN
	jb		_Not_In_Range

	mov		entered_num, EAX
	cmp		EAX, NEG_ONE_HUN
	jg		_Not_In_Range
	jbe		_Accumulator
	loop	_Number_Processor

;------------------------------------------------------------------------
;Prints the average
;------------------------------------------------------------------------
_Accumulator:
	mov		EDX, entered_num
	mov		EDX, entered_num
	cmp		EDX, min
	jb		_Set_New_Min
	cmp		EDX, max
	jg		_Set_New_Max

	add		sum, EDX
	inc		count
	jmp		_Number_Processor

;------------------------------------------------------------------------
;Sets new min
;------------------------------------------------------------------------
_Set_New_Min:
	mov		EDX, entered_num
	mov		min, EDX
	jmp		_Accumulator

;------------------------------------------------------------------------
;Sets new max
;------------------------------------------------------------------------
_Set_New_Max:
	mov		EDX, entered_num
	mov		max, EDX
	jmp		_Accumulator

;------------------------------------------------------------------------
;Calculates the average and sends to the rounder if needed, otherwise sends to display, may also display 
;------------------------------------------------------------------------
_Calculations:
	mov		EAX, sum
	cdq
	mov		EBX, count
	idiv	EBX
	mov		avg, EAX
	mov		EAX, avg
	mov		avg_remainder, EDX

	mov		EAX, avg_remainder
	mov		EBX, -1000
	imul	EBX
	mov		avg_remainder, EAX
	cdq
	mov		EBX, count
	idiv	EBX
	mov		new_remainder, EAX

	mov		EAX, new_remainder
	cmp		EAX, 500
	jg		_Round_Up_Avg
	jmp		_Results

	
;------------------------------------------------------------------------
;Calculates the .01 average
;------------------------------------------------------------------------
_Super_Avg:
	mov		EAX, sum       
	mov		EBX, 1000
	imul	EBX
	mov     EBX, count
	cdq
	idiv    EBX            
	mov     EBX, 10
    cdq
    idiv    EBX
    mov     one_k_avg, EAX      
    mov     EAX, EDX
    mov     one_k_remain, EDX   
    mov     EAX, one_k_remain
    mov     EBX, -1           
    imul    EBX
    mov     one_k_remain, EAX    ;to determine if rounding is needed
    cmp     one_k_remain, 6
    jge     _Second_Calc

    ;tests if current remainder is 6
    mov		EAX, one_k_avg
    mov		EBX, 100
    cdq
    idiv	EBX					 ;divs 100
    mov		one_k_avg, EAX
    mov		one_k_remain, EDX
    mov		EAX, one_k_remain    ;must be positive
    mov		EBX, -1
    imul	EBX
    mov     one_k_remain, EAX
    jmp     _The_Second_Print


;------------------------------------------------------------------------
;Rounds the super decimal average if needed
;------------------------------------------------------------------------
_Second_Calc:
	mov		EAX, one_k_avg
	mov		EBX, 1
	sub		EAX,EBX
	mov		EBX, 100
	cdq
	idiv	EBX
	mov     one_k_avg, EAX
    mov     one_k_remain, EDX    
    mov     EAX, one_k_remain
    mov     EBX, -1            
    imul    EBX
    mov     one_k_remain, EAX
    jmp     _The_Second_Print

;------------------------------------------------------------------------
;Rounds up the number if necessary
;------------------------------------------------------------------------
_Round_Up_Avg:
	mov		EAX, avg
	add		EAX, ONE
	mov		avg, EAX
	jmp		_Results
	
;------------------------------------------------------------------------
;Displays our results
;------------------------------------------------------------------------
_Results:
;this portion sends the program to end if it received zero valid inputs
	mov		EDX, count
	cmp		count, 0
	jle		_Goodbye
	
;display number of valid number entries
	mov		EDX, OFFSET you_entered
	call	WriteString
	mov		EAX, count
	call	WriteDec
	mov		EDX, OFFSET valid_numbers
	call	WriteString
	call	CrLf

;displays min
	mov		EAX, min
	mov		EDX, OFFSET min_preface
	call	WriteString
	call	WriteInt
	call	CrLf

;displays max
	mov		EAX, max
	mov		EDX, OFFSET max_preface
	call	WriteString
	CALL	WriteInt
	call	CrLf

;prints the sum of valid numbers
	mov		EAX, sum
	mov		EDX, OFFSET sum_preface
	call	WriteString
	call	WriteInt
	call	CrLf

;Prints the average
	mov		EDX, OFFSET avg_preface
	call	WriteString
	mov		EAX, avg
	call	WriteInt
	call	CrLf

	jmp		_Super_Avg

;------------------------------------------------------------------------
;Displays the .01 EC 
;------------------------------------------------------------------------
_The_Second_Print:
	mov		EDX, OFFSET one_k_preface
	call	WriteString
	mov		ECX, one_k_avg
	call	WriteDec
	call	CrLf

;------------------------------------------------------------------------
;Bids our user adeiu
;------------------------------------------------------------------------
_Goodbye:
	call	CrLf
	mov		EDX, OFFSET goodbye
	call	WriteString
	jmp		_Exit


;------------------------------------------------------------------------
;Gets the user's name
;------------------------------------------------------------------------
_No_Number:	
	call	CrLf
	mov		EDX, OFFSET no_number
	call	WriteString
	jmp		_Goodbye

;------------------------------------------------------------------------
;Gets the user's name
;------------------------------------------------------------------------
_Not_In_Range:
	mov		EDX, OFFSET out_of_range
	call	WriteString
	call	CrLf
	jmp		_Number_Processor

;------------------------------------------------------------------------
;Exits the program
;------------------------------------------------------------------------
_Exit:
	Invoke ExitProcess, 0	; exit to operating system

main ENDP

END main