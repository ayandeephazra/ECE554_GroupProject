# Memory Mapped REGS
llb R1, 0x08                # R1 holds bmp mmap address
lhb R1, 0xC0

llb R10, 0x10               # R10 holds mmap address for mmap_regs
lhb R10, 0xC0

# llb R13, 0x16               # R13 holds mmap address for other mmap_regs
# lhb R13, 0xC0

llb R13, 0xF0                # R3 holds YLOC (for time being)
lhb R13, 0x00

b uncond, START

START: 
    ####### Place Ship
    llb R2, 0x10                # XLOC <= 10'h0080 (left side of the screen)
    lhb R2, 0x00
    sw R2, R1, 0                

    sw R13, R1, 1                # YLOC <= 8'hF0 (center of the screen)

    llb R4, 0x3                 # cntrl <= 3
    sw R4, R1, 2

    llb R12, 0x00     
    lhb R12, 0x40
    JAL COUNT                   # Gonna have to figure out how we do delay bc of the branch prediction


    llb R4, 0x16               # R13 holds mmap address for other mmap_regs
    lhb R4, 0xC0
    lw R2, R4, 0
	llb R12, 0x00
	lhb R12, 0x40
	JAL COUNT
	lw R2, R4, 0

	lw R7, R10, 3		# get timer value
	llb R12, 0xFF
	lhb R12, 0xFF
	SUB R12, R7, R12	# did timer finish?
	B neq, CHECK_VALUE	# if no continue, if yes, go to change seed
	addi R8, R9, 1		# change seed
	sw R8, R4, 0		# load in SEED
	lw R7, R4, 0		# get value from LFSR

    b uncond, GAME_LOOP:

GAME_LOOP:

    # If KEY[1] pressed:   
    llb R4, 0xF0	        # should be 16'hF0F0   
    lhb R4, 0xF0            

    lw R12, R10, 4		    # load up register -> 0xc014
    sub R12, R12, R4		# Is KEY[2] being pressed?
    b eq, UP	            # if eq, go to UP
    
    # If KEY[2] pressed:   
    lw R12, R10, 5		    # load down register -> 0xc015
    sub R12, R12, R4		# Is KEY[1] being pressed?
    b eq, DOWN              # if eq, go to DOWN

DOWN:
    # check bottom of screen
    llb R4, 0x7C            # R4 holds top bound (480)
    lhb R4, 0x01
    SUB R4, R4, R13          # if R4 == R3, then at bottom of screen
    b eq, GAME_LOOP               # can't move anymore, go to RUN

    addi R13, R13, 1          # move img down by 1 units
    sw R2, R1, 0            # XLOC <= 10'h0080 (left side of the screen)
    sw R13, R1, 1
    llb R4, 0x3             # cntrl <= 3
    sw R4, R1, 2            # print new location

    llb R12, 0x00     
    lhb R12, 0x40
    JAL COUNT               #### WAIT 1000 cycles 
    b uncond, CHECK_VALUE

UP:
    # check top of screen
    SUBI R4, R13, 0          # if R3 == 0, then at top of screen
    b eq, GAME_LOOP               # can't move anymore, go to RUN

    subi R13, R13, 1          # move img up by 1 units
    sw R2, R1, 0            # XLOC <= 10'h0080 (left side of the screen)
    sw R13, R1, 1
    llb R4, 0x3             # cntrl <= 3
    sw R4, R1, 2            # print new location

    llb R12, 0x00     
    lhb R12, 0x40
    JAL COUNT               #### WAIT 1000 cycles 
    b uncond, CHECK_VALUE

CHECK_VALUE:
    llb R3, 0xD6	#214
    lhb R3, 0x00
    SUB R3, R7, R3              # if R3 < R2, then go to lane 6
    b gt, LANE6

    llb R3, 0xAB	#171
    lhb R3, 0x00
    SUB R3, R7, R3              # if R3 < R2, then go to lane 5
    b gt, LANE5

    llb R3, 0x80	#128
    lhb R3, 0x00
    SUB R3, R7, R3              # if R3 < R2, then go to lane 4
    b gt, LANE4

    llb R3, 0x55	#85
    lhb R3, 0x00
    SUB R3, R7, R3              # if R3 < R2, then go to lane 3
    b gt, LANE3

    llb R3, 0x2A	#42
    lhb R3, 0x00
    SUB R3, R7, R3              # if R3 < R2, then go to lane 2
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

	llb R4, 0x5			    # 3 =>spaceship, # asteroid => #5, # blackout = 7
	sw R4, R11, 2			# cntrl <= 5

	llb R12, 0x00
	lhb R12, 0x40			# for COUNT
	
	JAL COUNT

	sub R6, R6, R3			# if R3 = FC04
	B neq, LEFT_TO_RIGHT
	
	sw R3, R11, 0	# blackout image
	sw R5, R11, 1	# write y to mem

	llb R4, 0x7	# cntrl <= 7 for blackout
	sw R4, R11, 2	# draw to screen

	llb R12, 0x00
	lhb R12, 0x40

	JAL COUNT	# count

    b uncond, GAME_LOOP


COUNT:
    SUBI R12, R12, 1
    B NEQ, COUNT
    JR R15

END:
    B uncond, END