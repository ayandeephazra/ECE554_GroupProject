llb R1, 0x00                # base mmap address
lhb R1, 0xC0

llb R10, 0x10               # R10 holds mmap address for mmap_regs
lhb R10, 0xC0

llb R11, 0x08
lhb R11, 0xC0

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
llb R9, 0x88		# SEED that will be loaded into LFSR
lhb R9, 0x00	

addi R8, R9, 0		# load R8 with SEED we want to use
sw R8, R13, 0		# whatever in R8 goes to c016 as SEED
##########################################################################
START:

    	lw R2, R13, 0		# R2 contains LFSR output
   # lw R2, R1, 16               # get value of LFSR
   # b uncond, CHECK_VALUE
	llb R12, 0x00
	lhb R12, 0x40
	JAL COUNT
	lw R2, R13, 0

	lw R7, R10, 3		# get timer value
	llb R12, 0xFF
	lhb R12, 0xFF
	SUB R12, R7, R12	# did timer finish?
	B neq, CHECK_VALUE	# if no continue, if yes, go to change seed
	addi R8, R9, 1		# change seed
	sw R8, R13, 0		# load in SEED
	lw R2, R13, 0		# get value from LFSR
	
#CHANGE_SEED:
#lw R2, R13, 0		# get value of LFSR
#lw R7, R10, 3		# get time value
#llb R9, 0xFF		# did timer finish?
#llb R9, 0xFF
#AND R9, R9, R7	# wait a bit for randomization
#B neq, CHANGE_SEED

CHECK_VALUE:
    llb R3, 0xD6	#214
    lhb R3, 0x00
    SUB R3, R2, R3              # if R3 < R2, then go to lane 6
    b gt, LANE6

    llb R3, 0xAB	#171
    lhb R3, 0x00
    SUB R3, R2, R3              # if R3 < R2, then go to lane 5
    b gt, LANE5

    llb R3, 0x80	#128
    lhb R3, 0x00
    SUB R3, R2, R3              # if R3 < R2, then go to lane 4
    b gt, LANE4

    llb R3, 0x55	#85
    lhb R3, 0x00
    SUB R3, R2, R3              # if R3 < R2, then go to lane 3
    b gt, LANE3

    llb R3, 0x2A	#42
    lhb R3, 0x00
    SUB R3, R2, R3              # if R3 < R2, then go to lane 2
    b gt, LANE2

    b uncond, LANE1             # uconditional branch to LANE1 if not others 

LANE1:
    llb R3, 0x44                # XLOC <= 10'h0244 (right side of the screen)
   # lhb R3, 0x02
    lhb R3, 0xFE
    sw R3, R11, 0  

    llb R5, 0x0A                # YLOC <= 10'h000A (right side of the screen)
    lhb R5, 0x00
    sw R5, R11, 1                

    llb R4, 0x5               # cntrl <= 3 (don't know what it is for the meteor, need to ask)
    sw R4, R11, 2

    llb R12, 0x00     
    lhb R12, 0x40
    JAL COUNT                   # Gonna have to figure out how we do delay bc of the branch prediction
    b uncond, LEFT_TO_RIGHT
    b uncond, START

LANE2:
    llb R3, 0x44                # XLOC <= 10'h0244 (right side of the screen)
 #   lhb R3, 0x02
    lhb R3, 0xFE
    sw R3, R11, 0                

    llb R5, 0x5A                # YLOC <= 10'h000A (right side of the screen)
    lhb R5, 0x00
    sw R5, R11, 1                

    llb R4, 0x5                 # cntrl <= 3 (don't know what it is for the meteor, need to ask)
    sw R4, R11, 2

    llb R12, 0x00     
    lhb R12, 0x40
    JAL COUNT                   # Gonna have to figure out how we do delay bc of the branch prediction 
    b uncond, LEFT_TO_RIGHT
    b uncond, START


LANE3:
    llb R3, 0x44                # XLOC <= 10'h0244 (right side of the screen)
#    lhb R3, 0x02
    lhb R3, 0xFE
    sw R3, R11, 0                

    llb R5, 0xAA                # YLOC <= 10'h000A (right side of the screen)
    lhb R5, 0x00
    sw R5, R11, 1                

    llb R4, 0x5                 # cntrl <= 3 (don't know what it is for the meteor, need to ask)
    sw R4, R11, 2

    llb R12, 0x00     
    lhb R12, 0x40
    JAL COUNT                   # Gonna have to figure out how we do delay bc of the branch prediction
    b uncond, LEFT_TO_RIGHT
    b uncond, START


LANE4:
    llb R3, 0x44                # XLOC <= 10'h0244 (right side of the screen)
#    lhb R3, 0x02
    lhb R3, 0xFE
    sw R3, R11, 0                

    llb R5, 0xFA                # YLOC <= 10'h000A (right side of the screen)
    lhb R5, 0x00
    sw R5, R11, 1                

    llb R4, 0x5                 # cntrl <= 3 (don't know what it is for the meteor, need to ask)
    sw R4, R11, 2

    llb R12, 0x00     
    lhb R12, 0x40
    JAL COUNT                   # Gonna have to figure out how we do delay bc of the branch prediction
    b uncond, LEFT_TO_RIGHT
    b uncond, START


LANE5:
    llb R3, 0x44                # XLOC <= 10'h0244 (right side of the screen)
#    lhb R3, 0x02
    lhb R3, 0xFE
    sw R3, R11, 0                

    llb R5, 0x4A                # YLOC <= 10'h000A (right side of the screen)
    lhb R5, 0x01
    sw R5, R11, 1                

    llb R4, 0x5                 # cntrl <= 3 (don't know what it is for the meteor, need to ask)
    sw R4, R11, 2

    llb R12, 0x00     
    lhb R12, 0x40
    JAL COUNT                   # Gonna have to figure out how we do delay bc of the branch prediction
    b uncond, LEFT_TO_RIGHT
    b uncond, START


LANE6:
    llb R3, 0x44                # XLOC <= 10'h0244 (right side of the screen)
#    lhb R3, 0x02
    lhb R3, 0xFE
    sw R3, R11, 0               # R3 => mem[R1 + 8] => mem[R1+8] = C008 

    llb R5, 0x9A                # YLOC <= 10'h000A (right side of the screen)
    lhb R5, 0x01
    sw R5, R11, 1               # R3 => mem[R1 + 9] = coo9 

    llb R4, 0x5                 # cntrl <= 3 (don't know what it is for the meteor, need to ask)
    sw R4, R11, 2		# R3 => mem[R1 + 10] = c00A

    llb R12, 0x00     
    lhb R12, 0x40
    JAL COUNT                   # Gonna have to figure out how we do delay bc of the branch prediction
     b uncond, LEFT_TO_RIGHT
   #B uncond, END
    b uncond, START

LEFT_TO_RIGHT:	# 320 =>

	llb R6, 0x04
	lhb R6, 0xFC 

	subi R3, R3, 1			# move img right by 1 unit
	sw R3, R11, 0			# write x to mem

	sw R5, R11, 1			# write y to mem

	llb R4, 0x5
	sw R4, R11, 2			# cntrl <= 5

	llb R12, 0x00
	lhb R12, 0x40			# for COUNT
	
	JAL COUNT

	sub R6, R6, R3			# if R3 = FC04
	B neq, LEFT_TO_RIGHT
#	llb R2, 0x68
#	lhb R2, 0xFE
#	sw R2, R11, 0
#	sw R5, R11, 1
#	sw R4, R11, 2
#	llb R12, 0x00
#	llb R12, 0x40
#	JAL COUNT
#	B eq, START
	#B uncond, LEFT_TO_RIGHT
#	subi R3, R3, 0
	B eq, START
#	B uncond, LEFT_TO_RIGHT
	
COUNT:
    SUBI R12, R12, 1
    B NEQ, COUNT
    JR R15

END:
 B uncond, END
