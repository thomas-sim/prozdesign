
;;; testa -> Counts # of one's in the 8 bit number in R16.
;;;  result should be 4 in r1


	NOP
	NOP
	NOP
	NOP

	ldi  R16, 0x5A
	
	mov  R2, R16
	eor  R1, R1	; put zeros in R1
	ldi  R17, 8
label1: 
	LSL  R2
	brcc label2
	inc  R1
label2: 
	dec R17
	brne label1
label3:
	rjmp label3
