LLB R1, 0x08		# R1 holds bmp mmap addr
LHB R1, 0xC0

LLB R3, 0x44		# R3 holds XLOC
lhb R3, 0x02

llb R10, 0x10
lhb R10, 0xC0

llb R4, 0x13		# R4 holds timer
lhb R4, 0xC0

llb R5, 0x16
lhb R5, 0xC0		# R5 holds lfsr_out, or q (the random number)

llb R7, 0x10
lhb R7, 0x00

llb R10, 0xe4		# SEED that will be used
lhb R10, 0x00
# setting the SEED
addi R6, R10, 0		# load R6 w/SEED you want to use...0x88
sw R6, R5, 0		# whatever in R6 goes to c016 as SEED
RNG:
########################################################################
#addi R6, R10, 0		# load R6 w/SEED you want to use... 0x88
#sw R6, R5, 0		# whatever in R6 goes to c016 as SEED
#lw R8, R5, 0		# R8 contains LFSR value
########################################################################

#SUB R11, R10, R8
#B eq, PLACE_METEOR
#B uncond, RNG

################
# place meteor #
################
#PLACE_METEOR:

# but after hitting FFFF it will start again from the beginnning and perform the behavior I want from the meteor.

# fix for this: if we start the x coord of the meteor with upper bits of FF, it performs the correct behavior, FE means its looped back around
# the same problem still arrises: subtract until you get to FC04, then set picture to FE68 to remove from the screen
# starting to believe that its not possible to just draw it off the screen, we will need another picture thats black to paint over it or just ignore it
llb R2, 0x34	# changed
lhb R2, 0x02
#llb R2, 0x44
#lhb R2, 0xFE
#sw R3, R1, 0	# XLOC <= 8'h40
sw R2, R1, 0


llb R2, 0x50	#YLOC <= 8'h50
lhb R2, 0x00
sw R2, R1, 1

llb R2, 0x5	# cntrl <= 5
sw R2, R1, 2

llb R12, 0xFF	# 0x8000 limit?
lhb R12, 0x79
JAL COUNT
B uncond, END
#B uncond, RNG
#B uncond, END
#B uncond, RIGHT_TO_LEFT

#llb R2, 0x70	# changed
#lhb R2, 0xFE
#llb R2, 0x04
#lhb R2, 0xFC	// furthest to the right of the screen is FC04 w/o loop around
#llb R2, 0x68
#lhb R2, 0xFE
#sw R3, R1, 0	# XLOC <= 8'h40
#sw R2, R1, 0


#llb R2, 0x50	#YLOC <= 8'h50
#lhb R2, 0x00
#sw R2, R1, 1

#llb R2, 0x5	# cntrl <= 5
#sw R2, R1, 2

#llb R12, 0x00
#lhb R12, 0x40
#JAL COUNT
#B uncond, RNG
B uncond, END
#B uncond, RIGHT_TO_LEFT


#B uncond, END
llb R3, 0x00
lhb R3, 0x00
# right to left movement
###############################################################
RIGHT_TO_LEFT: # R3 holds x value(01E0), left side of screen is 0080

#sub R4, R3, R7
#B eq, END

subi R3, R3, 1
#subi R3, R3, 1	# move img right by 1 unit
sw R3, R1, 0	# move img on x-axis

llb R2, 0x50
sw R2, R1, 1	# YLOC => 0

llb R2, 0x5	# cntrl <= 5
sw R2, R1, 2

llb R12, 0x00
lhb R12, 0x40
JAL COUNT
#subi R4, R3, 0
#B eq, END
B uncond, RIGHT_TO_LEFT
################################################################

CHECK_PARITY: # will have to change register to whatever LFSR is in

# this function is called when the timer ends...IN GAME LOOP

# y => R3
# int y = R1 ^ (R2 >> 1)
SRL R13, R1, 0x01	# (x >> 1)		# check parity of out signal of LFSR
XOR R3, R1, R13		# x ^ (x >> 1) = y

SRL R13, R3, 0x02	# y >> 2
XOR R3, R13, R3		#y ^ (y >> 2)

SRL R13, R3, 0x04	# y >> 4
XOR R3, R13, R3		# y ^ (y >> 4)

SRL R13, R3, 0x08	# y >> 8
XOR R3, R3, R13		# y ^ (y >> 8)

ANDI R4, R3, 0x01	# (y & 1)
B gt, SEND_LOW_METEOR				# if 1 is returned, parity
B eq, SEND_HIGH_METEOR
#SUB R5, R4, R6		# (y & 1) == 1(R5 == 1)? if 1 is returned, parity is odd
#JR R15			# branch back
#####################################################################################

# six lanes, send meteor 
# multiple meteors on screen, store in data memory
SEND_LOW_METEOR:


SEND_HIGH_METEOR:

# if timer == 0 ? JAL CHECK_PARITY : continue
#sw R2, R1, 0
#sw R3, R1, 1
#llb R8, 0x3
#sw R8, R1, 2

#llb R12, 0x00
#lhb R12, 0x40


#CHECK_PARITY:
#subi R3, R3, 0x01			# After 1000 clk cycles print to screen
#sw R2, R1, 0            # XLOC <= 10'h0000 (left side of the screen)
#sw R3, R1, 1
#llb R8, 0x3             # cntrl <= 3
#sw R8, R1, 2            # print new location

#llb R12, 0x00     
#lhb R12, 0x40

#b uncond, TIMER
COUNT:
	SUBI R12, R12, 1
	B NEQ, COUNT
	JR R15
END:
llb R13, 0xAA
	B uncond, END

