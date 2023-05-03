# collision handling GLL
	###################################################################################################
	###################################################################################################
	
	# Game end condition here:
	COLLISION_CHECK:	# check if collision after a move
	# branch to handling iff 1, 2 amd 3 hold simultaneously 
	# 1. x coordinate of top left of spaceship (R11->16'h0010) + decimal 100 >= TOP left x coordinate of meteor (R7)
	# 2. y coordinate of TOP left of spaceship (R3) <= TOP left y coordinate of meteor (R9) 
	# 3. y coordinate of TOP left of spaceship (R3) + 100  >= TOP left y coordinate of meteor (R9) + 60 
	#   \---- 
	#    \-------\            /\
	#    /-------/            \/
	#   /----
	llb R2, 0x74       # dimensions of spaceship 6*16+4=100 + 16'h10 for the x coord
	lhb R2, 0x00
	SUB R2, R7, R2      
	B lte, X_PASS		# X condition is met, check y now
	B uncond, RIGHT_TO_LEFT # if not met continue loop in RTL
	
	X_PASS:
	SUB R2, R3, R9      
	B lte, Y_PASS 		# one of y conditions is met, check other
	B uncond, RIGHT_TO_LEFT # if not met continue loop in RTL
	
	Y_PASS:
	LLB R2, 0x64       # dimensions of spaceship 6*16+4=100
	ADD R2, R3, R2
	LLB R6, 0x3C       # dimensions of meteor 3*16+12=60
	ADD R6, R9, R6
	SUB R2, R2, R6
	B gte, COLLISION_HANDLING
	b uncond, RIGHT_TO_LEFT

	COLLISION_HANDLING:	# if collision, handle here
	b uncond, END

	###################################################################################################
	###################################################################################################