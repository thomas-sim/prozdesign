; Adress-Deklarationen
	
	; Adresse von Schalter-GPIO 
	.equ SWH = 0x33 ; SW 15 .. SW 8
	.equ SWL = 0x36 ; SW 7  .. SW 0

	; Adresse von LEDs: 
	.equ LEDH = 0x35 ; LED 15 .. LED 8
	.equ LEDL = 0x38 ; LED 7  .. LED 0

	; Adresse 7-Segment Anzeige
	.equ SEG_ER = 0x40 ; Segment Enable Register
	.equ SEG0 = 0x41 ; SEG0_N
	.equ SEG1 = 0x42 ; SEG1_N
	.equ SEG2 = 0x43 ; SEG2_N
	.equ SEG3 = 0x44 ; SEG3_N

	; Adresse von Tastern: 
	.equ PB = 0x30

	; Definition ZL und ZH
	.def ZL = R30
	.def ZH = R31

	;-- NOP, EOR, LDI
	nop					;#0:
	nop					;#1:
	nop					;#2:
	nop					;#3:	


;;; initialization
	eor ZH, ZH

boucle:	ldi ZL, SWH		; R16 <- pinc
	ld R16, Z

	ldi ZL, SWL		; R17 <- pinb
	ld R17, Z	

	ldi ZL, 0x35		; portc <- R16
	st Z, R16

	ldi ZL, 0x38		; portb <- R16
	st Z, R17

	rjmp boucle
	
