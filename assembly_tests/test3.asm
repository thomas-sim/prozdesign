; test pour les opérations add, sub, dec, inc

	ldi r16, $07
boucle:	dec r16
	brbc 2, boucle

