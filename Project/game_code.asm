# starting the game code here

# Memory Map isn't done, will be changed

LLB R2, 0x00	# R2 contains addr for key[1] (0xC000)... (move up)
LHB R2, 0xC0	

# can all be done by immediate addition to R2
	#LLB R3, 0x01	# R3 contains addr for key[2] (0xC001)... (move down)
	#LHB R3, 0xC0	

	#LLB R4, 0x05	# R4 contains status register (0xC005)
	#LHB R4, 0xC0

	#LLB R5, 0x04	# R5 contains TX/RX buffer (0xC004)
	#LHB R5, 0xC0

LLB R9, 0x00    # R9 stores the x-coordinates of the lower left corner of the 
				# meteor at any one instance of the gameloop

LLB R10, 0x00	# R10 stores the y-coordinates of the lower left corner of the 
				# meteor at any one instance of the gameloop
				
LLB R11, 0x00	# R11 stores the x-coordinates of the lower left corner of the 
				# spaceship at any one instance of the gameloop
				
LLB R12, 0x00	# R11 stores the y-coordinates of the lower left corner of the 
				# spaceship at any one instance of the gameloop

# Implement movement of spaceships
# determine when to send meteor
# determine when a collision between spaceship and meteors happen
# display statistics of BTB

# currently occupied registers: R0, R2, R3, R4, R5, R6, R7, R13, R14, R15, R9, R10, R11, R12
# temp occupied registers: R6, R7, R8,
# free registers: 

GAME_LOOP:

# sending pictures will begin here:
JAL CHECK_PARITY

# picture movement begins here:
LW R6, R2, 0		# read data (key_press[1]) located in C000 into R6
LW R7, R2, 1		# read data (key_press[2]) located in C001 into R7

SUBI R8, R6, 0x01 	# check if key[1] (up) is pressed
B eq, SPACE_SHIP_MOVEMENT

SUBI R8, R7, 0x01	# check if key[2] (down) is pressed
B eq, SPACE_SHIP_MOVEMENT 

# Game stats updated and sent to display here:

# Game end condition here:
COLLISION_CHECK:	# check if collision after a move
# branch to handling iff 1, 2 amd 3 hold simultaneously 
# 1. x coordinate of lower left of spaceship (R11) + decimal 100 >= lower left x coordinate of meteor (R9)
# 2. y coordinate of lower left of spaceship (R12) <= lower left y coordinate of meteor (R10)
# 3. y coordinate of lower left of spaceship (R12) + decimal 100 >= lower left y coordinate of meteor (R10) + decimal 60
#   \---- 
#    \-------\            /\
#    /-------/            \/
#   /----
LLB R1, 0x64       # dimensions of spaceship 6*16+4=100
ADD R1, R11, R1
SUB R1, R9, R1
B lte, COLLISION_HANDLING
SUB R1, R12, R10
B lte, COLLISION_HANDLING
LLB R1, 0x64       # dimensions of spaceship 6*16+4=100
ADD R6, R11, R1
LLB R1, 0x3C       # dimensions of meteor 3*16+12=60
ADD R7, R10, R1
SUB R1, R7, R6
B lte, COLLISION_HANDLING

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

CHECK_PARITY: # will have to change registers
# int x = 7
#LLB R1, 0xDC	# x
#LHB R1, 0xCC
#LLB R6, 0x01	# check for odd parity

# changed XOR opcode in asmbl.pl, added XOR to common_params.inc and id.v
# use R13, R3, R1
# y => R3
# int y = R1 ^ (R2 >> 1)
SRL R13, R1, 0x01	# (x >> 1)
XOR R3, R1, R13		# x ^ (x >> 1) = y

SRL R13, R3, 0x02	# y >> 2
XOR R3, R13, R3		#y ^ (y >> 2)

SRL R13, R3, 0x04	# y >> 4
XOR R3, R13, R3		# y ^ (y >> 4)

SRL R13, R3, 0x08	# y >> 8
XOR R3, R3, R13		# y ^ (y >> 8)

ANDI R4, R3, 0x01	# (y & 1)
SUB R5, R4, R6		# (y & 1) == 1(R5 == 1)? if 1 is returned, parity is odd
JR R15			# branch back

END:			# end of game


