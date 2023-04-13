llb R1, 0x55
lhb R1, 0x55
llb R2, 0x00
lhb R2, 0x01
llb R3, 0x49
lhb R3, 0x00

MOVC R4, R2, 0x00
SUB R5, R4, R3
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
b uncond, END

MEM 0x0100
STRING I am Here!
