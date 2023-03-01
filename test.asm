llb R1, 0x04        # R1 holds RX/TX mmap address
lhb R1, 0xC0
llb R4, 0x80        # R4 holds bit mask to poll tx q
lhb R4, 0x00

#################### DEBUG
llb R10, 0x00


####################
# send 'Hello Wo'
####################

llb R2, 0x1b        # <Esc>
sw R2, R1, 0
llb R2, 0x5b        # [
sw R2, R1, 0
llb R2, 0x32        # 2
sw R2, R1, 0
llb R2, 0x4a        # J
sw R2, R1, 0
llb R2, 0x1b        # <Esc>
sw R2, R1, 0
llb R2, 0x5b        # [
sw R2, R1, 0
llb R2, 0x48        # H
sw R2, R1, 0

JAL L_WAIT_EMP

llb R2, 0x0a        # LF
sw R2, R1, 0
llb R2, 0x0a        # LF
sw R2, R1, 0
llb R2, 0x0a        # LF
sw R2, R1, 0
llb R2, 0x09        # TAB
sw R2, R1, 0
llb R2, 0x09        # TAB
sw R2, R1, 0

JAL L_WAIT_EMP

llb R2, 0x48        # H
sw R2, R1, 0
llb R2, 0x65        # e
sw R2, R1, 0
llb R2, 0x6c        # l
sw R2, R1, 0
llb R2, 0x6c        # l
sw R2, R1, 0
llb R2, 0x6f        # o
sw R2, R1, 0
llb R2, 0x20        # ' '
sw R2, R1, 0
llb R2, 0x57        # W
sw R2, R1, 0
llb R2, 0x6f        # o
sw R2, R1, 0

JAL L_WAIT_EMP

llb R2, 0x72        # r
sw R2, R1, 0
llb R2, 0x6c        # l
sw R2, R1, 0
llb R2, 0x64        # d
sw R2, R1, 0
llb R2, 0x21        # !
sw R2, R1, 0
llb R2, 0x0A        # \n
sw R2, R1, 0
llb R2, 0x0d        # <CR>
sw R2, R1, 0
llb R2, 0x00        # \0
sw R2, R1, 0

JAL L_WAIT_EMP


###################
# Read name from user
###################

# check if RX is ready
llb R9, 0x0f        # R9 holds bit mask to poll rx q
llb R2, 0x0D        # R2 holds <CR> --> 0x0D
llb R6, 0x00        # R6 is mem ptr
llb R7, 0x01        # R7 = 1 ---- for incrementing
                    
WAIT_RX:            # look for chars to process
lw R3, R1, 1        # R3 holds status_reg -- from 0xc005
and R3, R3, R9
b eq, WAIT_RX
                    # rx rdy
lw R5, R1, 0        # R5 holds RX char
SW R5, R1, 0        # echo R5 to spart
SW R5, R6, 0        # store char to memory
ADD R6, R6, R7      # increment mem ptr
sub R5, R5, R2      # compare R5 with 0x0d
b eq, PRINT_NAME    # user pressed ENTER
b uncond, WAIT_RX


#####################
# Print user name from memory
#####################


PRINT_NAME:
llb R14, 0xA5       # DEBUG ##################
llb R2, 0x0a        # '\n'
sw R2, R1, 0
llb R2, 0x0d        # <CR>
sw R2, R1, 0
llb R2, 0x48        # H
sw R2, R1, 0
llb R2, 0x65        # e
sw R2, R1, 0
llb R2, 0x6c        # l
sw R2, R1, 0
llb R2, 0x6c        # l
sw R2, R1, 0
llb R2, 0x6f        # o
sw R2, R1, 0
llb R2, 0x20        # ' '
sw R2, R1, 0

JAL L_WAIT_EMP

llb R8, 0x00        # R8 -- new read mem ptr -- set to 0
sub R6, R6, R7      # decrement R6 to exclude <CR> print
TX:
lw R5, R8, 0        # R5 holds TX char
sw R5, R1, 0        # echo char to SPART
JAL L_WAIT_EMP
add R8, R8, R7      # increment read ptr
sub R2, R6, R8      # R2 -- (for comparing) | check if read ptr == old write ptr
b neq, TX

lhb R14, 0x00
END:
b uncond, END



L_WAIT_EMP:         # wait for TX q to empty
lw R3, R1, 1        # read from 0xc005 (status reg) --> R3
and R3, R3, R4      # look for R3 == 1XXX_XXXX (tx_queue is empty)
b eq, L_WAIT_EMP    # if result is zero => MSB of status_reg is not 1 => not empty keep waiting
JR R15