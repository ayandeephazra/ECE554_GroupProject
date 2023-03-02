LLB R1, 0x05
LHB R1, 0xC0	# R1 contains status register(0xc005)

LLB R2, 0x04
LHB R2, 0xC0	# R2 contains TX/RX buffer

PRINT_HELLO_WORLD:

	LLB R3, 0x1B	# moves <Esc> into R3
	SW R3, R2, 0	

	LLB R3, 0x5B	# [
	SW R3, R2, 0

	LLB R3, 0x32	# 2
	SW R3, R2, 0

	LLB R3, 0x4A
	SW R3, R2, 0

JAL STAT_POLLING

	LLB R3, 0x1B	#<Esc>
	SW R3, R2, 0
	
	LLB R3, 0x5B	#[
	SW R3, R2, 0

	#LLB R3, 0x3C   #<
	#SW R3, R2, 0

	LLB R3, 0x39 #9
	SW R3, R2, 0

	#LLB R3, 0x3E	#>
	#SW R3, R2, 0

	LLB R3, 0x42	#B
	SW R3, R2, 0
	
JAL STAT_POLLING

	LLB R3, 0x1B	#<Esc>
	SW R3, R2, 0

	LLB R3, 0x5B	#[
	SW R3, R2, 0

	LLB R3, 0x39	#9
	SW R3, R2, 0

	LLB R3, 0x43
	SW R3, R2, 0

JAL STAT_POLLING

	LLB R3, 0x1B
	SW R3, R2, 0

	LLB R3, 0x5B
	SW R3, R2, 0

	LLB R3, 0x39
	SW R3, R2, 0

	LLB R3, 0x43
	SW R3, R2, 0

JAL STAT_POLLING

	LLB R3, 0x1B
	SW R3, R2, 0

	LLB R3, 0x5B
	SW R3, R2, 0

	LLB R3, 0x39
	SW R3, R2, 0

	LLB R3, 0x43
	SW R3, R2, 0

JAL STAT_POLLING

	LLB R3, 0x1B
	SW R3, R2, 0

	LLB R3, 0x5B
	SW R3, R2, 0

	LLB R3, 0x36
	SW R3, R2, 0

	LLB R3, 0x43
	SW R3, R2, 0

JAL STAT_POLLING

	LLB R3, 0x48	# moves H into R3
	SW R3, R2, 0	# writing 0x48 into TX buffer

	LLB R3, 0x65	# moves e into r3
	SW R3, R2, 0	# writing 0x65 into TX buffer

	LLB R3, 0x6C	# moves l into R3
	SW R3, R2, 0

	LLB R3, 0x6C	# moves l into R3
	SW R3, R2, 0

	LLB R3, 0x6F	# moves o into R3
	SW R3, R2, 0

	LLB R3, 0x20	# moves space into R3
	SW R3, R2, 0

	LLB R3, 0x57	# moves W into R3
	SW R3, R2, 0

	LLB R3, 0x6f	# moves o into R3
	SW R3, R2, 0

JAL STAT_POLLING

	LLB R3, 0x72	# moves r into R3
	SW R3, R2, 0

	LLB R3, 0x6c	# moves l into R3
	SW R3, R2, 0

	LLB R3, 0x64	# moves d into R3
	SW R3, R2, 0

	LLB R3, 0x0a	# moves '\n' into R3
	SW R3, R2, 0

	LLB R3, 0x0D
	SW R3, R2, 0

# Outer loop reading till 0x0D


	LLB R3, 0x1B	#<Esc>
	SW R3, R2, 0

	LLB R3, 0x5B	#[
	SW R3, R2, 0

	LLB R3, 0x39	#9
	SW R3, R2, 0

	LLB R3, 0x43
	SW R3, R2, 0

JAL STAT_POLLING


	LLB R3, 0x1B	#<Esc>
	SW R3, R2, 0

	LLB R3, 0x5B	#[
	SW R3, R2, 0

	LLB R3, 0x39	#9
	SW R3, R2, 0

	LLB R3, 0x43
	SW R3, R2, 0

JAL STAT_POLLING


	LLB R3, 0x1B	#<Esc>
	SW R3, R2, 0

	LLB R3, 0x5B	#[
	SW R3, R2, 0

	LLB R3, 0x39	#9
	SW R3, R2, 0

	LLB R3, 0x43
	SW R3, R2, 0

JAL STAT_POLLING


	LLB R3, 0x1B	#<Esc>
	SW R3, R2, 0

	LLB R3, 0x5B	#[
	SW R3, R2, 0

	LLB R3, 0x39	#9
	SW R3, R2, 0

	LLB R3, 0x43
	SW R3, R2, 0

JAL STAT_POLLING

	LLB R3, 0x1B	#<Esc>
	SW R3, R2, 0

	LLB R3, 0x5B	#[
	SW R3, R2, 0

	LLB R3, 0x39	#9
	SW R3, R2, 0

	LLB R3, 0x43
	SW R3, R2, 0

JAL STAT_POLLING

LLB R7, 0x0D	# store 'enter' into R7
LLB R8, 0x01	# Used for comparing status reg (rx_queue) -> lower 4 bits[3:0] of R8 == 1111
LLB R5, 0x00	# char ptr
LLB R6, 0x01	# R6 is incrementor

STAT_POLLING_AGAIN:
LW R9, R1, 0			# get status reg value into R9
AND R9, R9, R8			# checks if queue is full, is R8(1111) == rx_queue(1111)?
B EQ, STAT_POLLING_AGAIN	# if queue is full, keep branching until its not

# if passed here, we can send chars again

LW R3, R2, 0			# read new char(rx = read)
SUB R10, R3, R7			# is char 'enter'?
B EQ, PRINT_HELLO_NAME		# if 'enter,' jump to new subroutine and print name
SW R3, R2, 0			# echo to screen
SW R3, R5, 0			# not enter, store it away in dmem
ADD R5, R5, R6			# increment ptr
B UNCOND, STAT_POLLING_AGAIN	# Goto start of the loop

PRINT_HELLO_NAME:

JAL STAT_POLLING

LLB R3, 0x0A
SW R3, R2, 0

LLB R3, 0x0D
SW R3, R2, 0

	LLB R3, 0x1B	#<Esc>
	SW R3, R2, 0

	LLB R3, 0x5B	#[
	SW R3, R2, 0

	LLB R3, 0x39	#9
	SW R3, R2, 0

	LLB R3, 0x43
	SW R3, R2, 0

JAL STAT_POLLING


	LLB R3, 0x1B	#<Esc>
	SW R3, R2, 0

	LLB R3, 0x5B	#[
	SW R3, R2, 0

	LLB R3, 0x39	#9
	SW R3, R2, 0

	LLB R3, 0x43
	SW R3, R2, 0

JAL STAT_POLLING


	LLB R3, 0x1B	#<Esc>
	SW R3, R2, 0

	LLB R3, 0x5B	#[
	SW R3, R2, 0

	LLB R3, 0x39	#9
	SW R3, R2, 0

	LLB R3, 0x43
	SW R3, R2, 0

JAL STAT_POLLING


	LLB R3, 0x1B	#<Esc>
	SW R3, R2, 0

	LLB R3, 0x5B	#[
	SW R3, R2, 0

	LLB R3, 0x36	#3
	SW R3, R2, 0

	LLB R3, 0x43
	SW R3, R2, 0

JAL STAT_POLLING

LLB R3, 0x48		# move H into r3
SW R3, R2, 0		# write into TX buffer

LLB R3, 0x65		# move e into r3
SW R3, R2, 0		

LLB R3, 0x6c		# move l into r3 twice
SW R3, R2, 0		
SW R3, R2, 0

LLB R3, 0x6f		# move o into r3
SW R3, R2, 0

LLB R3, 0x20		# move 'space into R3'
SW R3, R2, 0

JAL STAT_POLLING

LLB R8, 0x00		# char ptr
LLB R6, 0x01		# used to increment ptr

PRINTING_NAME:

LW R3, R8, 0		# read char ptr
SW R3, R2, 0		# echo to screen
JAL STAT_POLLING	# make sure queue is still not full
ADD R8, R8, R6		# increment ptr to next spot
SUB R10, R5, R8		
B NEQ, PRINTING_NAME	# not at enter, continue with next char

# at enter, finish

END:
B UNCOND, END

#In a loop polling spart status register for is there a character ready.
#Answer is 0 or 1, can't be more than 1.  Read new character.  Is it 0x0D
#If 0x0D break out of loop.  If character is not 0x0D we do 2 things
#1.) store it away in dmem SW char, ptr, 0
#2.) Echo back to screen
#Then increment ptr
#Goto start of loop

#Print "hello: "
#Now a loop reading from data mem and writing to Spart

STAT_POLLING:
LLB R12, 0x80		# load 1000 into upper 4 bits for TX queue
LW R11, R1, 0		# load status register
AND R11, R11, R12		# is tx queue full?(1000 == TX queue(1000))
B EQ, STAT_POLLING	# if full, continue until not full
JR R15			# branch back to PC + 1 stored in R15
