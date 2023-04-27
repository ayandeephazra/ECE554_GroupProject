llb R2, 0x10               # R2 holds mmap address for mmap_regs
lhb R2, 0xC0               # WAS R10

llb R1, 0x08
lhb R1, 0xC0

llb R13, 0x16
lhb R13, 0xC0
# 6 lanes -> 0-79, 80-159, 160-239, 240-319, 320-399, 400-479
# meteors are 60x60, so the placement for each lane needs to be +10 to be put at middle of lane
# -> 10, 90, 170, 250, 330, 410 for starting position of each lane (for YLOC)
# when one meteor gets to the middle of the screen (XLOC = 320), can send a new meteor
# LANE 1 - 0-42 0x002A
# LANE 2 - 43-85 0x0055
# LANE 3 - 86-128 0x0080
# LANE 4 - 129-171 0x00AB
# LANE 5 - 172-214 0x00D6
# LANE 6 - 215-255 0x00FF
# need to get output from LFSR and then check the value with these, then place based on this value

# LFSR mmap addr -> 0xC016
# new code added between comments
#########################################################################
llb R4, 0x88		# SEED that will be loaded into LFSR
lhb R4, 0x00		# WAS R9

addi R5, R4, 0		# load R5 (WAS R8) with SEED we want to use
sw R5, R13, 0		# whatever in R5 (WAS R8) goes to c016 as SEED
##########################################################################
START:

    lw R6, R13, 0		# R6 contains LFSR output

	llb R12, 0x00
	lhb R12, 0x40
	JAL COUNT
	lw R6, R13, 0

    # DONT CHANGE R2
	lw R7, R2, 3		# get timer value
	
    llb R12, 0xFF
	lhb R12, 0xFF
	SUB R12, R7, R12	# did timer finish?
	B neq, CHECK_VALUE	# if no continue, if yes, go to change seed
	addi R5, R4, 1		# change seed
	sw R5, R13, 0		# load in SEED
	lw R6, R13, 0		# get value from LFSR

CHECK_VALUE:
    llb R4, 0xD6	#214
    lhb R4, 0x00
    SUB R4, R6, R4              # if R4 < R6, then go to lane 6
    b gt, LANE6

    llb R4, 0xAB	#171
    lhb R4, 0x00
    SUB R4, R6, R4              # if R4 < R6, then go to lane 5
    b gt, LANE5

    llb R4, 0x80	#128
    lhb R4, 0x00
    SUB R4, R6, R4              # if R4 < R6, then go to lane 4
    b gt, LANE4

    llb R4, 0x55	#85
    lhb R4, 0x00
    SUB R4, R6, R4              # if R4 < R6, then go to lane 3
    b gt, LANE3

    llb R4, 0x2A	#42
    lhb R4, 0x00
    SUB R4, R6, R4              # if R4 < R6, then go to lane 2
    b gt, LANE2

    b uncond, LANE1             # uconditional branch to LANE1 if not others 

LANE1:
    llb R4, 0x44                # XLOC <= 10'h0244 (right side of the screen)
    lhb R4, 0xFE
    sw R4, R1, 0  

    llb R5, 0x0A                # YLOC <= 10'h000A (right side of the screen)
    lhb R5, 0x00
    sw R5, R1, 1                

    llb R4, 0x5               # cntrl <= 3 (don't know what it is for the meteor, need to ask)
    sw R4, R1, 2

    llb R12, 0x00     
    lhb R12, 0x40
    JAL COUNT                   # Gonna have to figure out how we do delay bc of the branch prediction
    b uncond, LEFT_TO_RIGHT
    b uncond, START

LANE2:
    llb R4, 0x44                # XLOC <= 10'h0244 (right side of the screen)
    lhb R4, 0xFE
    sw R4, R1, 0                

    llb R5, 0x5A                # YLOC <= 10'h000A (right side of the screen)
    lhb R5, 0x00
    sw R5, R1, 1                

    llb R4, 0x5                 # cntrl <= 3 (don't know what it is for the meteor, need to ask)
    sw R4, R1, 2

    llb R12, 0x00     
    lhb R12, 0x40
    JAL COUNT                   # Gonna have to figure out how we do delay bc of the branch prediction 
    b uncond, LEFT_TO_RIGHT
    b uncond, START


LANE3:
    llb R4, 0x44                # XLOC <= 10'h0244 (right side of the screen)
    lhb R4, 0xFE
    sw R4, R1, 0                

    llb R5, 0xAA                # YLOC <= 10'h000A (right side of the screen)
    lhb R5, 0x00
    sw R5, R1, 1                

    llb R4, 0x5                 # cntrl <= 3 (don't know what it is for the meteor, need to ask)
    sw R4, R1, 2

    llb R12, 0x00     
    lhb R12, 0x40
    JAL COUNT                   # Gonna have to figure out how we do delay bc of the branch prediction
    b uncond, LEFT_TO_RIGHT
    b uncond, START


LANE4:
    llb R4, 0x44                # XLOC <= 10'h0244 (right side of the screen)
    lhb R4, 0xFE
    sw R4, R1, 0                

    llb R5, 0xFA                # YLOC <= 10'h000A (right side of the screen)
    lhb R5, 0x00
    sw R5, R1, 1                

    llb R4, 0x5                 # cntrl <= 3 (don't know what it is for the meteor, need to ask)
    sw R4, R1, 2

    llb R12, 0x00     
    lhb R12, 0x40
    JAL COUNT                   # Gonna have to figure out how we do delay bc of the branch prediction
    b uncond, LEFT_TO_RIGHT
    b uncond, START


LANE5:
    llb R4, 0x44                # XLOC <= 10'h0244 (right side of the screen)
    lhb R4, 0xFE
    sw R4, R1, 0                

    llb R5, 0x4A                # YLOC <= 10'h000A (right side of the screen)
    lhb R5, 0x01
    sw R5, R1, 1                

    llb R4, 0x5                 # cntrl <= 3 (don't know what it is for the meteor, need to ask)
    sw R4, R1, 2

    llb R12, 0x00     
    lhb R12, 0x40
    JAL COUNT                   # Gonna have to figure out how we do delay bc of the branch prediction
    b uncond, LEFT_TO_RIGHT
    b uncond, START


LANE6:
    llb R4, 0x44                # XLOC <= 10'h0244 (right side of the screen)
    lhb R4, 0xFE
    sw R4, R1, 0               # R4 => mem[R1 + 8] => mem[R1+8] = C008 

    llb R5, 0x9A                # YLOC <= 10'h000A (right side of the screen)
    lhb R5, 0x01
    sw R5, R1, 1               # R4 => mem[R1 + 9] = coo9 

    llb R4, 0x5                 # cntrl <= 3 (don't know what it is for the meteor, need to ask)
    sw R4, R1, 2		# R4 => mem[R1 + 10] = c00A

    llb R12, 0x00     
    lhb R12, 0x40
    JAL COUNT                   # Gonna have to figure out how we do delay bc of the branch prediction
    b uncond, LEFT_TO_RIGHT
    b uncond, START

LEFT_TO_RIGHT:	# 320 =>

	llb R7, 0x04
	lhb R7, 0xFC 

	subi R4, R4, 1			# move img right by 1 unit
	sw R4, R1, 0			# write x to mem

	sw R5, R1, 1			# write y to mem

	llb R4, 0x5			# 3 =>spaceship, # asteroid => #5, # blackout = 7
	sw R4, R1, 2			# cntrl <= 5

	llb R12, 0x00
	lhb R12, 0x40			# for COUNT
	
	JAL COUNT

	sub R7, R7, R4			# if R4 = FC04
	B neq, LEFT_TO_RIGHT
	
	sw R4, R1, 0	# blackout image
	sw R5, R1, 1	# write y to mem

	llb R4, 0x7	# cntrl <= 7 for blackout
	sw R4, R1, 2	# draw to screen

	llb R12, 0x00
	lhb R12, 0x40

	JAL COUNT	# count
	B eq, START	# might have to change to uncond
	
COUNT:
    SUBI R12, R12, 1
    B NEQ, COUNT
    JR R15

END:
 B uncond, END
