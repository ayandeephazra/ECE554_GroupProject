llb R1, 0x08                # R1 holds bmp mmap address
lhb R1, 0xC0

llb R2, 0x80                # R2 holds XLOC (for time being)
lhb R2, 0x00

llb R3, 0x50                # R3 holds YLOC (for time being)

llb R10, 0x10               # R10 holds up mmap address
lhb R10, 0xC0

llb R11, 0x11               # R11 holds down mmap address
lhb R11, 0xC0

####### Place Ship
sw R2, R1, 0                # XLOC <= 10'h0000 (left side of the screen)

sw R3, R1, 1                # YLOC <= 8'hF0 (center of the screen)

llb R4, 0x3                 # cntrl <= 3
sw R4, R1, 2

JAL COUNT                   # Gonna have to figure out how we do delay bc of the branch prediction

B uncond, END

################################################
# REGS IN USE #
# R1 - bmp mmap address
# R2 - XLOC (temp)
# R3 - YLOC (temp)
# currently there's no register that saves xloc & yloc, so need to be mmaped

# RUN:
#     # If KEY[2] pressed:   
#     LW R12, R10, 0		    # load up register
#     ANDI R12, R12, 1		# Is KEY[2] being pressed?
#     B EQ, UP	            # if yes, go to UP
    
#     # If KEY[1] pressed:
#     LW R12, R11, 0		    # load down register
#     AND R11, R11, R12		# Is KEY[1] being pressed?
#     B EQ, DOWN              # if yes, go to DOWN

#     # loop back
#     B uncond, RUN


# UP:
#     B uncond, EDGETOP       # check top edge

#     ADDI R3, R3, 1          # move img down by 1 units
#     sw R3, R1, 0
#     llb R4, 0x3             # cntrl <= 3
#     sw R4, R1, 2            # print new location

#     JAL COUNT               #### WAIT 1000 cycles 
#     B uncond, RUN:

# DOWN:
#     B uncond, EDGEBOTTOM    # check bottom edge

#     SUBI R3, R3, 1          # move img down by 1 units
#     sw R3, R1, 0
#     llb R4, 0x3             # cntrl <= 3
#     sw R4, R1, 2            # print new location

#     JAL COUNT               #### WAIT 1000 cycles 
#     B uncond, RUN

# EDGEBOTTOM:
#     SUBI R4, R3, 0          # if R3 <= 0, then at bottom edge 
#     B LTE, RUN              # can't move anymore, go to RUN

#     B uncond, DOWN

# EDGETOP:
#     llb R4, 0xE0            # R4 holds top bound (480)
#     lhb R4, 0x01
#     SUB R4, R4, R3          # if R4 >= 0, then at top edge
#     B LTE, RUN              # can't move anymore, go to RUN

#     B uncond, UP

COUNT:
    llb R12, 0x00     
    lhb R12, 0x40
    SUBI R12, R12, 1
    B NEQ, COUNT
    JR R15

END:
    B uncond, END