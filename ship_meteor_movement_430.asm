# Final game code

llb R14, 0x00	# set stack pointer to zero

#LLB R2, 0x00
#LHB R2, 0xC0	# memory map access

llb R1, 0x08                # R1 holds bmp mmap address
lhb R1, 0xC0

llb R3, 0xF0                # R3 holds YLOC (for time being)
lhb R3, 0x00

llb R10, 0x10               # R10 holds mmap address for mmap_regs
lhb R10, 0xC0

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
    # If KEY[1] pressed:   
    llb R13, 0xF0	        # should be 16'hF0F0   
    lhb R13, 0xF0        

    lw R12, R10, 4		    # load up register -> 0xc014
    sub R12, R12, R13		    # Is KEY[2] being pressed?
    b eq, UP	            	    # if eq, go to UP
    
    # If KEY[2] pressed:   
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

	llb R5, 0x50
	lhb R5, 0x00
	sw R5, R1, 1			# write y to mem

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

	sw R7, R1, 0
	sw R5, R1, 1	

	llb R4, 0x00	# cntrl <= 7 for blackout
	lhb R4, 0x80
	sw R4, R1, 2	# remove img

	llb R12, 0x00	# counter value
	lhb R12, 0x40

    REMOVE_IMAGE_COUNT:
    SUBI R12, R12, 1
    B NEQ, REMOVE_IMAGE_COUNT

#	B uncond, END
#	B uncond, RUN
	B uncond, PLACE_METEOR

PLACE_METEOR: # meteor lanes will eventually go here

llb R7, 0x44	# x coord for meteor
lhb R7, 0xFE

sw R7, R1, 0

llb R9, 0x50	#YLOC <= 8'h50
lhb R9, 0x00
sw R9, R1, 1

llb R9, 0x5	# cntrl <= 5
sw R9, R1, 2

llb R12, 0xFF	# 0x8000 limit?
lhb R12, 0x79

PLACE_METEOR_COUNT:
SUBI R12, R12, 1
B NEQ, PLACE_METEOR_COUNT

b uncond, RUN 	# cause of bug

COUNT:
    SUBI R12, R12, 1
    B NEQ, COUNT
    JR R15

END:
    B uncond, END

