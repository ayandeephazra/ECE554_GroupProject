
###########################################
##        UMUL basic zero property       ##
###########################################

TEST_1:
llb R1, 0x69        # R1 holds decimal 105
lhb R1, 0x00
llb R2, 0x00        # R1 holds decimal 0
lhb R2, 0x00
llb R4, 0x00
lhb R4, 0x00

UMUL R3, R1, R2    	# product is whatever*0 = 0
SUB R5, R3, R4
B eq, PASS_1
B neq, FAIL_1

PASS_1:
llb R8, 0x55
lhb R8, 0x9a
b uncond, TEST_2

FAIL_1:
llb R8, 0x17
lhb R8, 0xfa
b uncond, TEST_2

###########################################
##       UMUL basic multiplication       ##
###########################################

TEST_2:
llb R5, 0xff        # to break monotonity in waves
llb R1, 0x02        # R1 holds decimal 2
lhb R1, 0x00
llb R2, 0x02        # R1 holds decimal 2
lhb R2, 0x00
llb R4, 0x04
lhb R4, 0x00

UMUL R3, R1, R2    	# product is 2*2 = 4
SUB R5, R3, R4
B eq, PASS_2
B neq, FAIL_2

PASS_2:
llb R8, 0x55
lhb R8, 0x9a
b uncond, TEST_3

FAIL_2:
llb R8, 0x17
lhb R8, 0xfa
b uncond, TEST_3


###########################################
##               UMUL complx             ##
###########################################

TEST_3:
llb R5, 0xff        # to break monotonity in waves
llb R8, 0x00        # default to 0 prior to start
llb R1, 0xff        # R1 holds decimal 255
lhb R1, 0x00
llb R2, 0xff        # R1 holds decimal 255
lhb R2, 0x00
llb R4, 0x01
lhb R4, 0xfe

UMUL R3, R1, R2    	# product is 255*255 = 65025 === FE01
SUB R5, R3, R4
B eq, PASS_3
B neq, FAIL_3

PASS_3:
llb R8, 0x55
lhb R8, 0x9a
b uncond, TEST_4

FAIL_3:
llb R8, 0x17
lhb R8, 0xfa
b uncond, TEST_4

###########################################
##               UMUL overflow           ##
###########################################
# IN CASE OF OVERFLOW, CUT OFF THE HIGH TOP

TEST_4:
llb R5, 0xff        # to break monotonity in waves
llb R8, 0x00        # default to 0 prior to start
llb R1, 0x66        # R1 holds 66
lhb R1, 0x66
llb R2, 0x66        # R2 holds 66
lhb R2, 0x66
llb R4, 0xA4
lhb R4, 0x70

UMUL R3, R1, R2    	# product is 0x6666*0x6666 = 0x28F570A4‬ === 70A4 discard top 2 bytes
SUB R5, R3, R4
B eq, PASS_4
B neq, FAIL_4

PASS_4:
llb R8, 0x55
lhb R8, 0x9a
b uncond, TEST_5

FAIL_4:
llb R8, 0x17
lhb R8, 0xfa
b uncond, TEST_5

###########################################
##          UMUL rand overflow           ##
###########################################
# IN CASE OF OVERFLOW, CUT OFF THE HIGH TOP

TEST_5:
llb R5, 0xff        # to break monotonity in waves
llb R8, 0x00        # default to 0 prior to start
llb R1, 0x58        # R1 holds 0x4758
lhb R1, 0x47
llb R2, 0x96        # R2 holds 0x1296
lhb R2, 0x12
llb R4, 0x90
lhb R4, 0xFD

UMUL R3, R1, R2    	# product is 0x4758*0x1296= 0x052DFD90‬ === FD90 discard top 2 bytes
SUB R5, R3, R4
B eq, PASS_5
B neq, FAIL_5

PASS_5:
llb R8, 0x55
lhb R8, 0x9a
b uncond, TEST_6

FAIL_5:
llb R8, 0x17
lhb R8, 0xfa
b uncond, TEST_6

###########################################
##        UMUL integer overflow          ##
###########################################
# IN CASE OF OVERFLOW, CUT OFF THE HIGH TOP

TEST_6:
llb R5, 0xff        # to break monotonity in waves
llb R8, 0x00        # default to 0 prior to start
llb R1, 0xff        # R1 holds 0xffff
lhb R1, 0xff
llb R2, 0xff        # R2 holds 0xffff
lhb R2, 0xff
llb R4, 0x01
lhb R4, 0x00

UMUL R3, R1, R2    	# product is 0xffff*0xffff= 0xfffe0001‬ === 0001 discard top 2 bytes
SUB R5, R3, R4
B eq, PASS_6
B neq, FAIL_6

PASS_6:
llb R8, 0x55
lhb R8, 0x9a
b uncond, TEST_7

FAIL_6:
llb R8, 0x17
lhb R8, 0xfa
b uncond, TEST_7

###########################################
##        UMUL just not overflow         ##
###########################################
# IN CASE OF OVERFLOW, CUT OFF THE HIGH TOP

TEST_7:
llb R5, 0xff        # to break monotonity in waves
llb R8, 0x00        # default to 0 prior to start
llb R1, 0xff        # R1 holds 0xffff
lhb R1, 0xff
llb R2, 0x01        # R2 holds 0x1
lhb R2, 0x00
llb R4, 0xff
lhb R4, 0xff

UMUL R3, R1, R2    	# product is 0xffff*0x1= 0xffff‬ === ffff discard top 2 bytes
SUB R5, R3, R4
B eq, PASS_7
B neq, FAIL_7

PASS_7:
llb R8, 0x55
lhb R8, 0x9a
b uncond, TEST_11

FAIL_7:
llb R8, 0x17
lhb R8, 0xfa
b uncond, TEST_11

###########################################
##            SMUL basic 0*0=0           ##
###########################################

TEST_11:
llb R5, 0xff        # to break monotonity in waves
llb R8, 0x00        # default to 0 prior to start
llb R1, 0x00        # R1 holds decimal 0
lhb R1, 0x00
llb R3, 0x00        # R1 holds decimal 0
lhb R3, 0x00
llb R4, 0x00
lhb R4, 0x00

SMUL R2, R1, R3     # product is 0*0 = 0
SUB R5, R2, R4
B eq, PASS_11
B neq, FAIL_11

PASS_11:
llb R8, 0x55
lhb R8, 0x9a
b uncond, TEST_12

FAIL_11:
llb R8, 0x17
lhb R8, 0xfa
b uncond, TEST_12

###########################################
##            SMUL basic 1*1=1           ##
###########################################

TEST_12:
llb R5, 0xff        # to break monotonity in waves
llb R8, 0x00        # default to 0 prior to start
llb R1, 0x01        # R1 holds decimal 1
lhb R1, 0x00
llb R3, 0x01        # R1 holds decimal 1
lhb R3, 0x00
llb R4, 0x01
lhb R4, 0x00

SMUL R2, R1, R3     # product is 1*1 = 1
SUB R5, R2, R4
B eq, PASS_12
B neq, FAIL_12

PASS_12:
llb R8, 0x55
lhb R8, 0x9a
b uncond, TEST_13

FAIL_12:
llb R8, 0x17
lhb R8, 0xfa
b uncond, TEST_13

###########################################
##          SMUL basic 0x4*0x8=0x20      ##
###########################################

TEST_13:
llb R5, 0xff        # to break monotonity in waves
llb R8, 0x00        # default to 0 prior to start
llb R1, 0x04        # R1 holds decimal 4
lhb R1, 0x00
llb R3, 0x08        # R1 holds decimal 4
lhb R3, 0x00
llb R4, 0x20
lhb R4, 0x00

SMUL R2, R1, R3     # product is 0x4*0x8=0x20 
SUB R5, R2, R4
B eq, PASS_13
B neq, FAIL_13

PASS_13:
llb R8, 0x55
lhb R8, 0x9a
b uncond, TEST_14

FAIL_13:
llb R8, 0x17
lhb R8, 0xfa
b uncond, TEST_14

###########################################
##          SMUL neg*pos=neg             ##
###########################################

TEST_14:
llb R5, 0xff        # to break monotonity in waves
llb R8, 0x00        # default to 0 prior to start
llb R1, 0x80        # R1 holds decimal 4
lhb R1, 0x00
llb R3, 0x01        # R1 holds decimal 4
lhb R3, 0x00
llb R4, 0x80
lhb R4, 0xff

SMUL R2, R1, R3     # product is 0x80*0x01=0xff80
SUB R5, R2, R4
B eq, PASS_14
B neq, FAIL_14

PASS_14:
llb R8, 0x55
lhb R8, 0x9a
b uncond, TEST_15

FAIL_14:
llb R8, 0x17
lhb R8, 0xfa
b uncond, TEST_15


###########################################
##          SMUL neg*neg=pos             ##
###########################################

TEST_15:
llb R5, 0xff        # to break monotonity in waves
llb R8, 0x00        # default to 0 prior to start
llb R1, 0x80        # R1 holds decimal 4
lhb R1, 0x00
llb R3, 0x80        # R1 holds decimal 4
lhb R3, 0x00
llb R4, 0x00
lhb R4, 0x40

SMUL R2, R1, R3     # product is 0x80*0x80=0x4000
SUB R5, R2, R4
B eq, PASS_15
B neq, FAIL_15

PASS_15:
llb R8, 0x55
lhb R8, 0x9a
b uncond, TEST_19

FAIL_15:
llb R8, 0x17
lhb R8, 0xfa
b uncond, TEST_19


###########################################
##               SMUL                    ##
###########################################

TEST_19:
llb R5, 0xff        # to break monotonity in wavesgithub
llb R8, 0x00        # default to 0 prior to start
llb R1, 0xff        # R1 holds decimal 255
lhb R1, 0x00
llb R3, 0xff        # R1 holds decimal 255
lhb R3, 0x00
llb R4, 0x01
lhb R4, 0x00

SMUL R2, R1, R3     # product is ffff*ffff = fffe 0001 out of which only the last 2 bytes are kept 
					# product is 0x0001
SUB R5, R2, R4
B eq, PASS_19
B neq, FAIL_19

PASS_19:
llb R8, 0x55
lhb R8, 0x9a
b uncond, END

FAIL_19:
llb R8, 0x17
lhb R8, 0xfa
b uncond, END

END:
llb R9, 0x4d
lhb R9, 0x0e
b uncond, END