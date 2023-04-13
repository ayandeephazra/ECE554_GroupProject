###########################################
##               ADDI                    ##
###########################################

llb R1, 0x00         # R1 holds decimal 8
lhb R1, 0x00
llb R3, 0x02         # R1 holds decimal 16
lhb R3, 0x00

ADDI R2, R1, 0x01
ADDI R2, R2, 0x01
SUB R4, R2, R3
B eq, PASS_1
B neq, FAIL_2

PASS_1:
llb R6, 0x55
lhb R6, 0x9a
b uncond, TEST_2

FAIL_1:
llb R6, 0x17
lhb R6, 0xfa
b uncond, TEST_2

###########################################
##               SUBI                    ##
###########################################

TEST_2:
llb R6, 0x00
lhb R6, 0x00
llb R1, 0x08         # R1 holds decimal 8
lhb R1, 0x00

SUBI R2, R1, 0x08
B eq, PASS_2
B neq, FAIL_2

PASS_2:
llb R6, 0x55
lhb R6, 0x9a
b uncond, TEST_3

FAIL_2:
llb R6, 0x17
lhb R6, 0xfa
b uncond, TEST_3

###########################################
##               XORNI                   ##
###########################################

TEST_3:
llb R6, 0x00
lhb R6, 0x00
llb R1, 0xff         # R1 holds decimal 8
lhb R1, 0xff

XORNI R2, R1, 0x00
B eq, PASS_3
B neq, FAIL_3

PASS_3:
llb R6, 0x55
lhb R6, 0x9a
b uncond, TEST_4

FAIL_3:
llb R6, 0x17
lhb R6, 0xfa
b uncond, TEST_4

###########################################
##               SMUL                    ##
###########################################

TEST_4:
llb R1, 0xff        # R1 holds decimal 255
lhb R1, 0x00
llb R3, 0xff        # R1 holds decimal 255
lhb R3, 0x00
llb R4, 0x01
lhb R4, 0x00

SMUL R2, R1, R3
SUB R5, R2, R4
B eq, PASS_4
B neq, FAIL_4

PASS_4:
llb R8, 0x55
lhb R8, 0x9a
b uncond, END

FAIL_4:
llb R8, 0x17
lhb R8, 0xfa
b uncond, END

END:
llb R9, 0x4d
lhb R9, 0x0e