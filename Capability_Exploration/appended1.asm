#llb R1, 0x08         # R1 holds decimal 8
#lhb R1, 0x00
#llb R2, 0xff        # R2 holds decimal 2
#lhb R2, 0xff
#llb R3, 0x09
#lhb R3, 0x00

# 8 + -1 = 7

####################################
# TEST 1, ADDI simple operations   #
####################################

# Test a, 08 + 01 = 09

#ADDI R4, R1, 0x01	# ADD 08 to reg 1 (08)
#SUB R5, R4, R3		# check if correct
#B eq, PASS
#B neq, FAIL

# Test b, 08 + 08 = 10

#llb R1, 0x08
#llb R3, 0x10

#ADDI R4, R1, 0x08
#SUB R5, R4, R3
#B eq, PASS
#B neq, FAIL

# Test c, 00 + 00 = 00

#llb R1, 0x00
#llb R3, 0x00

#ADDI R4, R1, 0x00
#SUB R5, R4, R3
#B eq, PASS
#B neq, FAIL


# note: this isn't implemented, so commented out for removal or later use

##############################################
# TEST 2, ADDI featuring negitive values     #
##############################################

# Test a, 0A + FF = 0B

#llb R1, 0xFF
#llb R3, 0x0B

#ADDI R4, R1, 0x0A
#SUB R5, R4, R3
#B eq, PASS
#B neq, FAIL

# Test b, FE + 02

#llb R1, 0xFE
#llb R3, 0x00

#ADDI R4, R1, 0x02
#SUB R5, R4, R3
#B eq, PASS
#B neq, FAIL

# Test c, C0 + 0F = -25 = (E7)

#llb R1, 0x40
#llb R3, 0xE7

#ADDI R4, R1, 0x0F
#SUB R5, R4, R3
#B eq, PASS
#B neq, FAIL

###############################
# TEST 3, Edge cases for ADDI #
###############################

# Test a, largest possible values added, 0xFF + 0x0F

#llb R1, 0xFF
#llb R3, 0x0E
#lhb R3, 0x01

#ADDI R4, R1, 0x0F
#SUB R5, R4, R3
#B eq, PASS
#B neq, FAIL

# Test b, setting z flag with ADDI, 0xFF + 0x01

#llb R1, 0xFF

#ADDI R4, R1, 0x01
#B eq, PASS
#B neq, FAIL

#################################
# TEST 1, SUBI basic operations #
#################################

# Test a, 0x05 - 0x02 = 0x03

#llb R1, 0x05
#llb R3, 0x03

#SUBI R4, R1, 0x02
#SUB R5, R4, R3
#B eq, PASS
#B neq, FAIL

# Test b, 0x0A - 0x05 = 0x05

#llb R1, 0x0A
#llb R3, 0x05

#SUBI R4, R1, 0x05
#SUB R5, R4, R3
#B eq, PASS
#B neq, FAIL

# Test c, 0xFF - 0x02 = 0xFd

#llb R1, 0x0FF
#llb R3, 0xFD

#SUBI R4, R1, 0x02
#SUB R5, R4, R3
#B eq, PASS
#B neq, FAIL

#################################
# TEST 1, XORI basic operations #
#################################

# Test a, 0x00 ^ 0x00 = 0

#llb R1, 0x00
#llb R3, 0x00

#XORI R4, R1, 0x00
#SUB R5, R4, R3
#B eq, PASS
#B neq, FAIL

# Test b, 0xFF ^ 0x01 = FE
#llb R1, 0xFF
#llb R3, 0xFE

#XORI R4, R1, 0x01
#SUB R5, R4, R3
#B eq, PASS
#B neq, FAIL

# Test c, 0xFF ^ 0x00 = FF
#llb R1, 0xFF
#llb R3, 0xFF

#XORI R4, R1, 0x00
#SUB R5, R4, R3
#B eq, PASS
#B neq, FAIL

#################################
# TEST 1, ANDI basic operations #
#################################

# Test a, 0x00 & 0xFF = 0x00
#llb R1, 0xFF
#llb R3, 0x00

#ANDI R4, R1, 0x00
#SUB R5, R4, R3
#B eq, PASS
#B neq, FAIL

# Test b, 0xFC & 0A = 0x08 -- FAILS, problem with the sign extension
#llb R1, 0xFC
#llb R3, 0x08

#ANDI R4, R1, 0x0A
#SUB R5, R4, R3
#B eq, PASS
#B neq, FAIL

# Test c, DA & 07 = 0x02
#llb R1, 0xDA
#llb R3, 0x02

#ANDI R4, R1, 0x07
#SUB R5, R4, R3
#B eq, PASS
#B neq, FAIL

################################
# TEST 1, ORI basic operations #
################################

# Test a, 07 | 07 = 07
#llb R1, 0x07
#llb R3, 0x07

#ORI R4, R1, 0x07
#SUB R5, R4, R3
#B eq, PASS
#B neq, FAIL

# Test b, 00AB | 000F = 00AF  FAILS, sign extension
#llb R1, 0xAB
#lhb R1, 0x00
#llb R3, 0xAF
#lhb R3, 0x00

#ORI R4, R1, 0x0F
#SUB R5, R4, R3
#B eq, PASS
#B neq, FAIL

# Test c, 0012 | 0008 = 001A, ff1A
llb R1, 0x12
lhb R1, 0x00
llb R3, 0x1A
llb R3, 0x00

ORI R4, R1, 0x08
SUB R5, R4, R3
B eq, PASS
B neq, FAIL

################################
# TEST 1, MUL basic operations #
################################

# Test 1, 0xFF * 03 = 2FD
#llb R1, 0xFF
#llb R3, 0xFD
#lhb R3, 0x02

#MUL R4, R1, 0x03
#SUB R5, R4, R3
#B eq, PASS
#B neq, FAIL

# Test 2, 0x08 * 0x08 = 40
#llb R1, 0x08
#llb R3, 0x40

#MUL R4, R1, 0x08
#SUB R5, R4, R3
#B eq, PASS
#B neq, FAIL

# Test 3, 0xAB * 0x00 = 0x00
#llb R1, 0xAB
#llb R3, 0x00

#MUL R4, R1, 0x00
#SUB R5, R4, R3
#B eq, PASS
#B neq, FAIL

##################################
# TEST 1, ANDNI basic operations #
##################################

# test a ~(0x00 & 0xFF) = FF
llb R1, 0xFF
llb R3, 0xFF

ANDNI R4, R1, 0x00
SUB R5, R4, R3
B eq, PASS
B neq, FAIL

# test b ~(0xFC & 0A) = F7
llb R1, 0xFC
llb R3, 0xF7

ANDNI R4, R1, 0x0A
SUB R5, R4, R3
B eq, PASS
B neq, FAIL

# test c = ~(0xDA & 07) = FD
llb R1, 0xDA
llb R3, 0xFD

ANDNI R4, R1, 0x07
SUB R5, R4, R3
B eq, PASS
B neq, FAIL

##################################
# TEST 1, XORNI basic operations #
##################################

# test a ~(0x00 ^ 0x00) = FF
llb R1, 0x00
llb R3, 0xFF

XORNI R4, R1, 0x00
SUB R5, R4, R3
B eq, PASS
B neq, FAIL

# test b ~(0xFF ^ 0x01) = 01
llb R1, 0xFF
llb R3, 0x01

XORNI R4, R1, 0x01
SUB R5, R4, R3
B eq, PASS
B neq, FAIL

# test c ~(0xFF ^ 0x00) = 00
llb R1, 0xFF
llb R3, 0x00

XORNI R4, R1, 0x00
SUB R5, R4, R3
B eq, PASS
B neq, FAIL

############################################################################################
# 				END OF IMMEDIATE TESTING				   #
############################################################################################


#SUBI R4, R1, 0x08
#SUB R5, R4, R3
#B eq, PASS
#B neq, FAIL

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
