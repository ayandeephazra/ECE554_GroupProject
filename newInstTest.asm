##############################################################################
# This test will check the validity of each new instruction added to the ISA #
##############################################################################
		LLB R1, 0x55
		ADDI R3, R2, 33		# (should be 0x88)
		B NEQ, CONT1		# NEQ taken branch
		B UNCOND, FAIL
CONT1:	SUBI R0, R2, R2		# will result in zero
		B NEQ, FAIL			# NEQ not taken branch
		B EQ, CONT2			# taken EQ branch
		B UNCOND, FAIL
CONT2:  


PASS:	LLB R1, 0xAA		# R1 will contain 0xFFAA
		LHB R1, 0xAA		# R1 will contain 0xAAAA (indicated pass)
		HLT
		ADD R0, R0, R0		# Nop in case their halt instruction does not stop in time
	
FAIL:	LLB R1, 0xFF		# R1 will contain 0xFFFF (indicates failure)
		HLT			

