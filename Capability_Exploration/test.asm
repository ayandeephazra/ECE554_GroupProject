llb R1, 0xff        # R1 holds decimal 8
lhb R1, 0x00
llb R3, 0xff         # R1 holds decimal 16
lhb R3, 0x00
llb R4, 0x00
lhb R4, 0xe1

SMUL R2, R1, R3
SUB R5, R2, R4
B eq, PASS_1
B neq, FAIL_1

PASS_1:
llb R6, 0x55
lhb R6, 0x9a
b uncond, END

FAIL_1:
llb R6, 0x17
lhb R6, 0xfa
b uncond, END

END:
llb R9, 0x4d
lhb R9, 0x0e