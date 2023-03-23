##############################################################################
# This test will check the validity of each new instruction added to the ISA #
##############################################################################

# I would do a visual glance of these tests before running it to make sure it looks good
# R13 is just incremented to know the general part where the tests failed (if it does)

		LLB R13, 0x11
		LLB R1, 0x55
		ADDI R3, R2, 33		# (should be 0x88)
		B NEQ, CONT1		# NEQ taken branch
		B UNCOND, FAIL
CONT1:	LLB R13, 0x22
		SUBI R0, R2, 88		# will result in zero
		B EQ, FAIL			# NEQ not taken branch
		B NEQ, CONT2		# taken EQ branch
		B UNCOND, FAIL

# Doing all of the XOR additions
CONT2:  LLB R13, 0x33
		LLB R3, 0x0			# load 0 into R3
		XOR R0, R0, R3		# shold be 33
		B LTE, FAIL
		LLB R1, 0x0
		XORI R0, R1, 1 		# should be 1
		B NEQ, FAIL
		XORNI R0, R0, 0		# should be 1
		B NEQ, FAIL
		B UNCOND, CONT3

# Doing all of the AND additions
CONT3:	LLB R13, 0x44
		LLB R1, 0x55
		ANDI R0, R1, 55 	# should be 1
		B NEQ, FAIL
		ANDNI R0, R1, 42	# should be 1
		B NEQ, FAIL
		LLB R2, 0x42
		ANDN R0, R1, R2		# should be 1
		B NEQ, FAIL
		B UNCOND, CONT4

# ORI, NOT, MUL
CONT4: 	LLB R13, 0x55
		LLB R1, 0x01
		ORI R2, R1, 0 		# should be 1
		B NEQ, FAIL
		LLB R1, 0x00
		ORI R2, R1, 1		# should be 1
		B NEQ, FAIL
		ORI R2, R1, 0		# should be 0
		B EQ, FAIL
		LLB R1, 0x01
		NOT R2, R1			# should be a very negative number
		B GTE, FAIL
		LLB R1, 0xFF
		NOT R2, R1			# should result in a positive number
		B LTE, FAIL
		LLB R1, 0x05
		LLB R2, 0x04
		MUL R3, R2, R1
		ANDI R0, R3, 20
		B NEQ, FAIL
		LLB R1, 0x00
		MUL R3, R2, R1
		NOT R0, R3
		B NEQ, FAIL
		B UNCOND, CONT6

# MOVC (I don't really get what MOVC should do, so someone else should add a test for this)
# CONT5: LLB R13, 0x66

# PUSH and POP
CONT6: 	LLB R13, 0x77
		LLB R1, 0x05
		LLB R2, 0x10
		PUSH R2
		ANDI R0, R14, 1		# R14 should be one bc of PUSH
		B NEQ, FAIL
		PUSH R1
		ANDI R0, R14, 2		# R14 should be two bc of PUSH
		POP R0
		ANDI R3, R0, 16 	# 0x10 should've come out from stack
		B NEQ, FAIL
		ANDI R3, R14, 1		# R14 should now be 1 bc of POP
		B NEQ, FAIL
		POP R0
		ANDI R3, R0, 5 		# 0x05 should've come out from stack
		B NEQ, FAIL
		ANDI R3, R14, 0		# R14 should now be 0 bc of POP
		B NEQ, FAIL
		B UNCOND, PASS

PASS:	LLB R1, 0xAA		# R1 will contain 0xFFAA
		LHB R1, 0xAA		# R1 will contain 0xAAAA (indicated pass)
		HLT
		ADD R0, R0, R0		# Nop in case their halt instruction does not stop in time
	
FAIL:	LLB R1, 0xFF		# R1 will contain 0xFFFF (indicates failure)
		HLT			

