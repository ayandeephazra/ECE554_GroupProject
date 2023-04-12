# starting the game code here

# Memory Map isn't done, will be changed

LLB R2, 0x00	# R2 contains addr for key[1] (0xC000)... (move up)
LHB R2, 0xC0	

LLB R3, 0x01	# R3 contains addr for key[2] (0xC001)... (move down)
LHB R3, 0xC0	

LLB R4, 0x05	# R4 contains status register (0xC005)
LHB R4, 0xC0

LLB R5, 0x04	# R5 contains TX/RX buffer (0xC004)
LHB R5, 0xC0

LLB R9, 0x00    # R9 stores the x-coordinates of the lower left corner of the meteor

LLB R10, 0x00	# R10 stores the y-coordinates of the lower left corner of the meteor

# Implement movement of spaceships
# determine when to send meteor
# determine when a collision between spaceship and meteors happen
# display statistics of BTB

# currently occupied registers: R0, R2, R3, R4, R5, R6, R7, R13, R14, R15, R9, R10
# temp occupied registers: R6, R7, R8,
# free registers: R11, R12

GAME_LOOP:

# sending pictures will begin here:

# picture movement begins here:
LW R6, R2, 0		# read data (key_press[1]) located in C000 into R6
LW R7, R3, 0		# read data (key_press[2]) located in C001 into R7

SUBI R8, R6, 0x01 	# check if key[1] (up) is pressed
B eq, SPACE_SHIP_MOVEMENT

SUBI R8, R7, 0x01	# check if key[2] (down) is pressed
B eq, SPACE_SHIP_MOVEMENT 

# Game stats updated and sent to display here:

# Game end condition here:
COLLISION_CHECK:	# check if collision after a move
LLB R11, 0x50       # dimensions of spaceship 5*16+0=80
PUSH R11
PUSH R11
# branch to handling iff 1, 2 amd 3 hold simultaneously 
# 1. x coordinate of lower left of spaceship + decimal 100 >= lower left x coordinate of meteor (R9)
# 2. y coordinate of lower left of spaceship <= lower left y coordinate of meteor (R10)
# 3. y coordinate of lower left of spaceship + decimal 100 >= lower left y coordinate of meteor (R10) + decimal 80
#   \---- 
#    \-------\            /\
#    /-------/            \/
#   /----


COLLISION_HANDLING:	# if collision, handle here

B eq, END	# if the spaceship position and meteor position are touching, end game

# Generate random number from LFSR for picture display here:



B uncond, GAME_LOOP	# end of loop. Game loop only ends when game ends


SPACE_SHIP_MOVEMENT:
# determine if spaceship is moved up or down
SUBI R8, R7, 0x01		# determine if spaceship moves down
B eq, DOWNWARDS_MOVEMENT	# branch to downwards_movement if equal
				# else, goto upwards movement

	UPWARDS_MOVEMENT:
		# 
		# determine if a meteor needs to be sent
		# determine if a collision happens


	DOWNWARDS_MOVEMENT:
# determine if a meteor needs to be sent
# determine if a collision happens

JR R15		# jump back to correct spot of game_loop

END:			# end of game


