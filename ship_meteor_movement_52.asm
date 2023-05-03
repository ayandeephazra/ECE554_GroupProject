# Final game code

llb R14, 0x00	# set stack pointer to zero

llb R1, 0x08                # R1 holds bmp mmap address
lhb R1, 0xC0

llb R3, 0xF0                # R3 holds YLOC (for time being)
lhb R3, 0x00

llb R10, 0x10               # R10 holds mmap address for mmap_regs
lhb R10, 0xC0

####### set up LFSR

llb R11, 0x88		# SEED that will be loaded into LFSR
lhb R11, 0x00
addi R8, R11, 0		# load R8 with SEED we want to use
sw R8, R10, 6 		# store c016 w/ SEED

####### Place Ship
llb R2, 0x10                # XLOC <= 10'h0080 (left side of the screen)
lhb R2, 0x00
sw R2, R1, 0                

sw R3, R1, 1                # YLOC <= 8'hF0 (center of the screen)

llb R4, 0x3                 # cntrl <= 3
sw R4, R1, 2

llb R12, 0x00     
lhb R12, 0x40

PLACE_SHIP_COUNT:
SUBI R12, R12, 1
B NEQ, PLACE_SHIP_COUNT

GAME_LOOP:
# place meteor here:

	b uncond, PLACE_METEOR
	
# B uncond, RUN

#B uncond, GAME_LOOP	# end of game loop

################################################
# REGS IN USE #
# R1 - bmp mmap address
# R3 - YLOC (temp)
# R10 - mmap address for mmap_regs

RUN:

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
	llb R4, 0x40       # dimensions of spaceship 6*16+4=100 + 16'h10 for the x coord
	lhb R4, 0xFC
	SUB R4, R7, R4      
	B lte, ASTEROID_LOWER_RIGHT		# X condition is met, check y now
	B uncond, KEY_PRESS # if not met continue loop in RTL
    
    ASTEROID_LOWER_RIGHT:
    LLB R4, 0x64       # dimensions of spaceship 6*16+4=100
	ADD R4, R3, R4     # lower y coord of spaceship
    SUB R4, R4, R9     # comparing between lower y coord and top of asteroid
    #B gte, CONT
    B lt, ASTEROID_UPPER_RIGHT # fail, next condition
    SUB R5, R9, R3     
    B gte, COLLISION_HANDLING  # pass as in collision, else next condition
        
    ASTEROID_UPPER_RIGHT:
    LLB R5, 0x3C       # dimensions of asteroid 3*16+12=60
	ADD R5, R9, R5     # lower y coordinate of asteroid
    SUB R5, R5, R3     # comparing between lower y coord and top of spaceship
    B lt, X_PASS       # fail, next condition
    LLB R4, 0x64       # dimensions of spaceship 6*16+4=100
    ADD R4, R4, R3     # lower y coord of spaceship
    LLB R5, 0x3C       # dimensions of meteor 3*16+12=60
	ADD R5, R9, R5     # lower y coord of asteroid
    SUB R4, R4, R5     # comparing both lower coordinates
    B gte, COLLISION_HANDLING # if spaceshup is greater, its a collision, else next condition
    
	X_PASS:
	SUB R4, R3, R9      
	B lte, Y_PASS 		# one of y conditions is met, check other
	B uncond, KEY_PRESS # if not met continue loop in RTL
	
	Y_PASS:
	LLB R4, 0x64       # dimensions of spaceship 6*16+4=100
	ADD R4, R3, R4
	LLB R5, 0x3C       # dimensions of meteor 3*16+12=60
	ADD R5, R9, R5
	SUB R4, R4, R5
	B gte, COLLISION_HANDLING
	b uncond, KEY_PRESS

	COLLISION_HANDLING:	# if collision, handle here
	b uncond, END

	###################################################################################################
	###################################################################################################
    
    KEY_PRESS:
    
    # If KEY[1] pressed:   
    llb R13, 0xF0	        # should be 16'hF0F0   
    lhb R13, 0xF0        

#     lw R12, R1, 12
    lw R12, R10, 4		    # load up register -> 0xc014
    sub R12, R12, R13		    # Is KEY[2] being pressed?
    b eq, UP	            	    # if eq, go to UP
    
    # If KEY[2] pressed:  
#     lw R12, R1, 13
    lw R12, R10, 5		    # load down register -> 0xc015
    sub R12, R12, R13		    # Is KEY[1] being pressed?
    b eq, DOWN                      # if eq, go to DOWN

    # loop back otherwise
   b uncond, RIGHT_TO_LEFT

DOWN:
    # check bottom of screen
    llb R4, 0x7C            # R4 holds top bound (480)
    lhb R4, 0x01

    SUB R4, R4, R3          # if R4 == R3, then at bottom of screen
    b neq, MOVING_DOWN

   b uncond, RIGHT_TO_LEFT

MOVING_DOWN:
    addi R3, R3, 1          # move img down by 1 units
    sw R2, R1, 0            # XLOC <= 10'h0080 (left side of the screen)
    sw R3, R1, 1
    llb R4, 0x3             # cntrl <= 3
    sw R4, R1, 2            # print new location

    llb R12, 0x00     
    lhb R12, 0x40

    MOVING_DOWN_COUNT:
    SUBI R12, R12, 1
    B NEQ, MOVING_DOWN_COUNT

b uncond, RIGHT_TO_LEFT

UP:
    # check top of screen
    SUBI R4, R3, 0          # if R3 == 0, then at top of screen
    b neq, MOVING_UP
    b eq, RIGHT_TO_LEFT

MOVING_UP:

    subi R3, R3, 1          # move img up by 1 units
    sw R2, R1, 0            # XLOC <= 10'h0080 (left side of the screen)
    sw R3, R1, 1
    llb R4, 0x3             # cntrl <= 3
    sw R4, R1, 2            # print new location

    llb R12, 0x00     
    lhb R12, 0x40

    MOVING_UP_COUNT:
    SUBI R12, R12, 1
    B NEQ, MOVING_UP_COUNT

   b uncond, RIGHT_TO_LEFT

RIGHT_TO_LEFT:

	llb R6, 0x04
	lhb R6, 0xFC 

	subi R7, R7, 1			# move img right by 1 unit
	sw R7, R1, 0			# write x to mem

#	llb R5, 0x50
#	lhb R5, 0x00
#	sw R5, R1, 1			# write y to mem
	sw R9, R1, 1

	llb R4, 0x5			# 3 =>spaceship, # asteroid => #5, # blackout = 7
	sw R4, R1, 2			# cntrl <= 5

	llb R12, 0x00
	lhb R12, 0x40			# for COUNT

    RIGHT_TO_LEFT_COUNT:
    SUBI R12, R12, 1
    B NEQ, RIGHT_TO_LEFT_COUNT

	sub R6, R6, R7			# if R3 = FC04
	B eq, REMOVE_IMAGE		# remove the image
	b neq, RUN

REMOVE_IMAGE:

	sw R7, R1, 0	# need the x-axis to remove image	
        sw R9, R1, 1	# need the y-axis to remove image

	llb R4, 0x00	# cntrl <= 7 for blackout
	lhb R4, 0x80
	sw R4, R1, 2	# remove img

	llb R12, 0x00	# counter value
	lhb R12, 0x40

    REMOVE_IMAGE_COUNT:
    SUBI R12, R12, 1
    B NEQ, REMOVE_IMAGE_COUNT

	B uncond, PLACE_METEOR

PLACE_METEOR: # meteor lanes will eventually go here

##############################################################################
# GETTING LFSR 
##############################################################################

	lw R8, R10, 6		# get LFSR output
	llb R12, 0x00
	lhb R12, 0x40

	LFSR_TIMER:		# timer for LFSR...wait for RN
	subi R12, R12, 1
	B neq, LFSR_TIMER

	lw R8, R10, 6		# get LFSR output again

#	lw R7, R10, 3		# get timer value
#	llb R12, 0xFF
#	llb R12, 0xFF
#	SUB  R12, R7, R12	# did timer finish?
#	B neq, CHECK_VALUE	# if no continue, if yes, go to change seed
#	addi R8, R9, 1		# change SEED
#	sw R8, R10, 6		# load in SEED
#	lw R8, R10,  6		# get value from LFSR


############################################################################

CHECK_VALUE:

    llb R7, 0xD6	#214
    lhb R7, 0x00
    SUB R7, R8, R7              # if R3 < R2, then go to lane 6
    b gt, LANE6

    llb R7, 0xAB	#171
    lhb R7, 0x00
    SUB R7, R8, R7              # if R3 < R2, then go to lane 5
    b gt, LANE5

    llb R7, 0x80	#128
    lhb R7, 0x00
    SUB R7, R8, R7              # if R3 < R2, then go to lane 4
    b gt, LANE4

    llb R7, 0x55	#85
    lhb R7, 0x00
    SUB R7, R8, R7              # if R3 < R2, then go to lane 3
    b gt, LANE3

    llb R7, 0x2A	#42
    lhb R7, 0x00
    SUB R7, R8, R7              # if R3 < R2, then go to lane 2
    b gt, LANE2

    b uncond, LANE1             # uconditional branch to LANE1 if not others


LANE1:
    llb R7, 0x44                # XLOC <= 10'h0244 (right side of the screen)
    lhb R7, 0xFE
    sw R7, R1, 0  

    llb R9, 0x0A                # YLOC <= 10'h000A (right side of the screen)
    lhb R9, 0x00
    sw R9, R1, 1                

    llb R4, 0x5               # cntrl <= 3 (don't know what it is for the meteor, need to ask)
    sw R4, R1, 2

    llb R12, 0x00     
    lhb R12, 0x40
    LANE1_COUNT:
    subi R12, R12, 1
    b neq, LANE1_COUNT

    b uncond, RUN

LANE2:
    llb R7, 0x44                # XLOC <= 10'h0244 (right side of the screen)
    lhb R7, 0xFE
    sw R7, R1, 0                

    llb R9, 0x5A                # YLOC <= 10'h000A (right side of the screen)
    lhb R9, 0x00
    sw R9, R1, 1                

    llb R4, 0x5                 # cntrl <= 3 (don't know what it is for the meteor, need to ask)
    sw R4, R1, 2

    llb R12, 0x00     
    lhb R12, 0x40

    LANE2_COUNT:
    subi R12, R12, 1
    b neq, LANE2_COUNT
   
    b uncond, RUN

LANE3:
    llb R7, 0x44                # XLOC <= 10'h0244 (right side of the screen)
    lhb R7, 0xFE
    sw R7, R1, 0                

    llb R9, 0xAA                # YLOC <= 10'h000A (right side of the screen)
    lhb R9, 0x00
    sw R9, R1, 1                

    llb R4, 0x5                 # cntrl <= 3 (don't know what it is for the meteor, need to ask)
    sw R4, R1, 2

    llb R12, 0x00     
    lhb R12, 0x40

    LANE3_COUNT:
    subi R12, R12, 1
    b neq, LANE3_COUNT

    b uncond, RUN


LANE4:
    llb R7, 0x44                # XLOC <= 10'h0244 (right side of the screen)
    lhb R7, 0xFE
    sw R7, R1, 0                

    llb R9, 0xFA                # YLOC <= 10'h000A (right side of the screen)
    lhb R9, 0x00
    sw R9, R1, 1                

    llb R4, 0x5                 # cntrl <= 3 (don't know what it is for the meteor, need to ask)
    sw R4, R1, 2

    llb R12, 0x00
    lhb R12, 0x40

    LANE4_COUNT:
    subi R12, R12, 1
    b neq, LANE4_COUNT

    b uncond, RUN

LANE5:
    llb R7, 0x44                # XLOC <= 10'h0244 (right side of the screen)
    lhb R7, 0xFE
    sw R7, R1, 0                

    llb R9, 0x4A                # YLOC <= 10'h000A (right side of the screen)
    lhb R9, 0x01
    sw R9, R1, 1                

    llb R4, 0x5                 # cntrl <= 3 (don't know what it is for the meteor, need to ask)
    sw R4, R1, 2

    llb R12, 0x00     
    lhb R12, 0x40

    LANE5_COUNT:
    subi R12, R12, 1
    b neq, LANE5_COUNT
   
    b uncond, RUN

LANE6:
    llb R7, 0x44                # XLOC <= 10'h0244 (right side of the screen)
    lhb R7, 0xFE
    sw R7, R1, 0               # R3 => mem[R1 + 8] => mem[R1+8] = C008 

    llb R9, 0x9A                # YLOC <= 10'h000A (right side of the screen)
    lhb R9, 0x01
    sw R9, R1, 1               # R3 => mem[R1 + 9] = coo9 

    llb R4, 0x5                 # cntrl <= 3 (don't know what it is for the meteor, need to ask)
    sw R4, R1, 2		# R3 => mem[R1 + 10] = c00A

    llb R12, 0x00     
    lhb R12, 0x40

    LANE6_COUNT:
    subi R12, R12, 1
    b neq, LANE6_COUNT

    b uncond, RUN


#llb R7, 0x44	# x coord for meteor
#lhb R7, 0xFE

#sw R7, R1, 0

#llb R9, 0x50	#YLOC <= 8'h50
#lhb R9, 0x00
#sw R9, R1, 1

#llb R9, 0x5	# cntrl <= 5
#sw R9, R1, 2

#llb R12, 0xFF	# 0x8000 limit?
#lhb R12, 0x79

#PLACE_METEOR_COUNT:
#SUBI R12, R12, 1
#B NEQ, PLACE_METEOR_COUNT

#b uncond, RUN 	# cause of bug

COUNT:
    SUBI R12, R12, 1
    B NEQ, COUNT
    JR R15

END:
    B uncond, END

