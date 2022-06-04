TITLE Program Template     (template.asm)

; Author: Kyle Donovan
; Last Modified: 5/23/2022
; OSU email address: donovaky@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 5                Due Date: 5/22/2022 (Grace Day 1x)
; Description: This file is provided as a template from which you may work
;              when developing assembly projects in CS271.

INCLUDE Irvine32.inc

; (insert macro definitions here)

; (insert constant definitions here)
ARRAYSIZE	= 200
LO			= 15
HI			= 50

.data
Welcome_1	BYTE	"Generating, Sorting, and Counting Random integers! Programmed by Kyle Donovan", 0
Purpose_1	BYTE	"This program generates 200 random numbers in the range [10 ... 29], displays the original list, sorts the list, displays the median value of the list, ", 0
Purpose_2	BYTE	"displays the list sorted in ascending order, then displays the number of instances of each generated value, starting with the number of 10s.", 0


goodbye		BYTE	"Later yo", 0
; (insert variable definitions here)

.code
main PROC

; (insert executable instructions here)
	call	Randomize
	call	RandomRange

	push	OFFSET Welcome_1
	call	introduction
	
	call	farewell


	Invoke ExitProcess,0	; exit to operating system
main ENDP

; (insert additional procedures here)




introduction PROC
	;strings and arrays must be passed by reference so this needs to be changed
	push	EBP
	mov		EBP,ESP
	
	mov		EDX, [EBP+20]
	call	WriteString



	pop		EBP
	ret

introduction ENDP


farewell PROC
	push	EBP
	mov		EBP, ESP



	pop		EBP
	ret

farewell ENDP


END main

;fillArray PROC
; fillArray {parameters: someArray (reference, output)}  NOTE: LO, HI, ARRAYSIZE will be used as globals within this procedure.
;fillArray ENDP

;sortList PROC
;sortList ENDP

;exchangeElements PROC
;exchangeElements ENDP

;displayMedian PROC
;displayMedian ENDP

;displayList PROC
;displayList ENDP

;countList PROC
;countList ENDP

