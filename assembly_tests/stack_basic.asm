	NOP
	NOP
	NOP
	NOP

	ldi r16, $03
	push r16                ; pushing 3
	inc r16
	push r16                ; pushing 4
        inc r16
        push r16                ; pushing 5
        
	pop r17                 ; r17 = 5
	pop r18                 ; r18 = 4
        pop r19                 ; r19 = 3

        NOP
        NOP
        NOP
