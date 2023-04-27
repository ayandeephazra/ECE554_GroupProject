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