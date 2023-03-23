llb R1, 0x08         # R1 holds decimal 8
lhb R1, 0x00
#llb R2, 0xff        # R2 holds decimal 2
#lhb R2, 0xff
llb R3, 0x10
lhb R3, 0x00

SUBI R4, R1, 0x08
#SUB R5, R4, R3
B eq, PASS
B neq, FAIL

PASS:
llb R6, 0x55
lhb R6, 0x9a
b uncond, END

FAIL:
llb R6, 0x17
lhb R6, 0xfa
b uncond, END

END:
llb R9, 0x4d
lhb R9, 0x0e