llb R1, 0x55
lhb R1, 0x55
llb R2, 0x00
lhb R2, 0x01
llb R3, 0x48
lhb R3, 0x00
llb R7, 0x49
lhb R7, 0x00

# first MOVC instruction
MOVC R4, R2, 0x00
SUB R5, R4, R7
#NOOP
#MOVC R4, R2, 0x05
#SUB R5, R4, R3

B eq, PASS_1
B neq, FAIL

PASS_1:
llb R6, 0x55
lhb R6, 0x9a
# arithmetic to see if they function normally
ADDI R3, R3, 0x01
SUB  R8, R3, R7
SUBI R3, R3, 0x01

llb R6, 0x00
llb R5, 0x00
llb R8, 0xff

llb R1, 0x55
lhb R1, 0x55
llb R2, 0x00
lhb R2, 0x01
llb R3, 0x48
lhb R3, 0x00
llb R7, 0x49
lhb R7, 0x00
# second MOVC instruction
MOVC R4, R2, 0x05
#NOOP
#NOOP
#NOOP
#NOOP
#MOVC R4, R2, 0x05
MOVC R4, R2, 0x05
SUB R5, R4, R3
B eq, PASS_2
B neq, FAIL

PASS_2:
llb R6, 0x55
lhb R6, 0x9a
# arithmetic to see if they function normally
ADDI R3, R3, 0x01
SUB  R8, R3, R7
SUBI R3, R3, 0x01
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
STRING I am Hereg