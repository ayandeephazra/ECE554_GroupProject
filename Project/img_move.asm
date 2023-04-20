llb R1, 0x08                # R1 holds bmp mmap address
lhb R1, 0xC0

llb R3, 0x50                # R3 holds YLOC (for time being)

llb R10, 0x10               # R10 holds mmap address for mmap_regs
lhb R10, 0xC0

####### Place Ship
llb R2, 0x80                # XLOC <= 10'h0080 (left side of the screen)
lhb R2, 0x00
sw R2, R1, 0                

sw R3, R1, 1                # YLOC <= 8'hF0 (center of the screen)

llb R4, 0x3                 # cntrl <= 3
sw R4, R1, 2

llb R12, 0x00     
lhb R12, 0x40
JAL COUNT                   # Gonna have to figure out how we do delay bc of the branch prediction

b uncond, RUN

b uncond, END

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
    sub R12, R12, R13		# Is KEY[2] being pressed?
    b eq, UP	            # if eq, go to UP
    
    # If KEY[2] pressed:   
    lw R12, R10, 5		    # load down register -> 0xc015
    sub R12, R12, R13		# Is KEY[1] being pressed?
    b eq, DOWN              # if eq, go to DOWN

    # loop back otherwise
    b uncond, RUN

UP:
    B uncond, EDGETOP       # check top edge

    addi R3, R3, 1          # move img down by 1 units
    sw R2, R1, 0            # XLOC <= 10'h0000 (left side of the screen)
    sw R3, R1, 1
    llb R4, 0x3             # cntrl <= 3
    sw R4, R1, 2            # print new location

    llb R12, 0x00     
    lhb R12, 0x40
    JAL COUNT               #### WAIT 1000 cycles 
    b uncond, RUN

DOWN:
    B uncond, EDGEBOTTOM    # check bottom edge

    subi R3, R3, 1          # move img down by 1 units
    sw R2, R1, 0            # XLOC <= 10'h0000 (left side of the screen)
    sw R3, R1, 1
    llb R4, 0x3             # cntrl <= 3
    sw R4, R1, 2            # print new location

    llb R12, 0x00     
    lhb R12, 0x40
    JAL COUNT               #### WAIT 1000 cycles 
    b uncond, RUN

# check this code again
EDGEBOTTOM:
    SUBI R4, R3, 0          # if R3 <= 0, then at bottom edge 
    B LTE, RUN              # can't move anymore, go to RUN

    B uncond, DOWN

# check this code again
EDGETOP:
    llb R4, 0xE0            # R4 holds top bound (480)
    lhb R4, 0x01
    SUB R4, R4, R3          # if R4 >= 0, then at top edge
    B LTE, RUN              # can't move anymore, go to RUN

    B uncond, UP

COUNT:
    SUBI R12, R12, 1
    B NEQ, COUNT
    JR R15

END:
    B uncond, END