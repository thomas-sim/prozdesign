	NOP
	NOP
	NOP
	NOP

	ldi r16, $09
	ldi r31, $00 		; clear Z high byte
	ldi r30, $61		; deuxième case mémoire
	st Z, r16		; [2] <- 09
	ld r1, Z		; normalement r1 vaut 9 inch'allah !
