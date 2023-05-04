 ###################################################################################################
	###################################################################################################
	
	# Game end condition here:
	COLLISION_CHECK:	# check if collision after a move
	# branch to handling iff 1, 2 amd 3 hold simultaneously 
    # 1. y coordinate of TOP left of spaceship (R3) <= TOP left y coordinate of meteor (R9) 
	# 2. y coordinate of TOP left of spaceship (R3) + 100  >= TOP left y coordinate of meteor (R9)  
	# 3. x coordinate of top left of spaceship (16'h0010) + decimal 100 >= TOP left x coordinate of meteor (R7)
	# (R9) + 60 
	#   \---- 
	#    \-------\            /\
	#    /-------/            \/
	#   /----
    ADDI R12, R3, 0
    ADDI R13, R7, 0
    ADDI R4, R9, 0
    
    PUSH R4
    PUSH R12
    PUSH R4
    PUSH R12
    PUSH R4
    PUSH R12
    PUSH R13
    
    # if x condition is not met, then there is no collision
    X_PASS:
    POP R13
	llb R12, 0x40       # dimensions of spaceship 6*16+4=100 + 16'h10 for the x coord
	lhb R12, 0xFC
	SUB R12, R12, R13     
	B gte, Y_PASS1	    # X condition is met, check y now
	B uncond, KEY_PRESS # if not met continue loop 
    
	Y_PASS1:
    POP R12             #R3
    POP R13             #R9
    
    llb R4, 0x64
    ADD R12, R12, R4
    
	SUB R12, R12, R13     
	B gte, COLLISION_HANDLING 		# one of y conditions is met, check other
    B lte, Y_PASS_1_RESERVE
	B uncond, KEY_PRESS # if not met continue loop in RTL
    
    Y_PASS_1_RESERVE:
    POP R12             #R3
    POP R13             #R9
    
    LLB R5, 0x3C       # dimensions of meteor 3*16+12=60
    ADD R13, R13, R5
	SUB R12, R13, R12  
    #b uncond, KEY_PRESS
    B gte, COLLISION_HANDLING     
	
	Y_PASS2:
    POP R12  #R3        # R12 top of spaceship
    POP R13  #R9        # R13 top of asteroid
	LLB R4, 0x64        # dimensions of spaceship 6*16+4=100
	ADD R4, R12, R4     # bottom of spaceship
	LLB R5, 0x3C        # dimensions of meteor 3*16+12=60
	ADD R5, R13, R5    # bottom of ASTEROID
	SUB R13, R13, R12
    B gte, CONTINUE_DOUBLE
    B uncond, KEY_PRESS
    
    CONTINUE_DOUBLE:
    SUB R4, R4, R5
    B gte, COLLISION_HANDLING
    B uncond, KEY_PRESS
	#B gte, X_PASS
    #B lte, 
	#b uncond, KEY_PRESS   

	COLLISION_HANDLING:	# if collision, handle here
	b uncond, END

	###################################################################################################
	###################################################################################################