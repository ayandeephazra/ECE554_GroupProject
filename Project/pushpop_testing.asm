llb R1, 0x00
llb R2, 0xFF

PUSH R1
PUSH R2

POP R4
POP R3

END:
llb R7, 0x4d
lhb R7, 0xe4
b uncond, END