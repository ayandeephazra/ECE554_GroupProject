llb R1, 0x00                # base mmap address
lhb R1, 0xC0

llb R10, 0x10               # R10 holds mmap address for mmap_regs
lhb R10, 0xC0

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

START:
    lw R2, R1, 16               # get value of LFSR
    b uncond, CHECK_VALUE

CHECK_VALUE:
    llb R3, 0xD6
    lhb R3, 0x00
    SUB R3, R3, R2              # if R3 < R2, then go to lane 6
    b gt, LANE6

    llb R3, 0xAB
    lhb R3, 0x00
    SUB R3, R3, R2              # if R3 < R2, then go to lane 5
    b gt, LANE5

    llb R3, 0x80
    lhb R3, 0x00
    SUB R3, R3, R2              # if R3 < R2, then go to lane 4
    b gt, LANE4

    llb R3, 0x55
    lhb R3, 0x00
    SUB R3, R3, R2              # if R3 < R2, then go to lane 3
    b gt, LANE3

    llb R3, 0x2A
    lhb R3, 0x00
    SUB R3, R3, R2              # if R3 < R2, then go to lane 2
    b gt, LANE2

    b uncond, LANE1             # uconditional branch to LANE1 if not others 

LANE1:
    llb R3, 0x44                # XLOC <= 10'h0244 (right side of the screen)
    lhb R3, 0x02
    sw R3, R1, 8                

    llb R3, 0x0A                # YLOC <= 10'h000A (right side of the screen)
    lhb R3, 0x00
    sw R3, R1, 9                

    llb R4, 0x3                 # cntrl <= 3 (don't know what it is for the meteor, need to ask)
    sw R4, R1, 10

    llb R12, 0x00     
    lhb R12, 0x40
    JAL COUNT                   # Gonna have to figure out how we do delay bc of the branch prediction
    b uncond, START

LANE2:
    llb R3, 0x44                # XLOC <= 10'h0244 (right side of the screen)
    lhb R3, 0x02
    sw R3, R1, 8                

    llb R3, 0x5A                # YLOC <= 10'h000A (right side of the screen)
    lhb R3, 0x00
    sw R3, R1, 9                

    llb R4, 0x3                 # cntrl <= 3 (don't know what it is for the meteor, need to ask)
    sw R4, R1, 10

    llb R12, 0x00     
    lhb R12, 0x40
    JAL COUNT                   # Gonna have to figure out how we do delay bc of the branch prediction
    b uncond, START


LANE3:
    llb R3, 0x44                # XLOC <= 10'h0244 (right side of the screen)
    lhb R3, 0x02
    sw R3, R1, 8                

    llb R3, 0xAA                # YLOC <= 10'h000A (right side of the screen)
    lhb R3, 0x00
    sw R3, R1, 9                

    llb R4, 0x3                 # cntrl <= 3 (don't know what it is for the meteor, need to ask)
    sw R4, R1, 10

    llb R12, 0x00     
    lhb R12, 0x40
    JAL COUNT                   # Gonna have to figure out how we do delay bc of the branch prediction
    b uncond, START


LANE4:
    llb R3, 0x44                # XLOC <= 10'h0244 (right side of the screen)
    lhb R3, 0x02
    sw R3, R1, 8                

    llb R3, 0xFA                # YLOC <= 10'h000A (right side of the screen)
    lhb R3, 0x00
    sw R3, R1, 9                

    llb R4, 0x3                 # cntrl <= 3 (don't know what it is for the meteor, need to ask)
    sw R4, R1, 10

    llb R12, 0x00     
    lhb R12, 0x40
    JAL COUNT                   # Gonna have to figure out how we do delay bc of the branch prediction
    b uncond, START


LANE5:
    llb R3, 0x44                # XLOC <= 10'h0244 (right side of the screen)
    lhb R3, 0x02
    sw R3, R1, 8                

    llb R3, 0x4A                # YLOC <= 10'h000A (right side of the screen)
    lhb R3, 0x01
    sw R3, R1, 9                

    llb R4, 0x3                 # cntrl <= 3 (don't know what it is for the meteor, need to ask)
    sw R4, R1, 10

    llb R12, 0x00     
    lhb R12, 0x40
    JAL COUNT                   # Gonna have to figure out how we do delay bc of the branch prediction
    b uncond, START


LANE6:
    llb R3, 0x44                # XLOC <= 10'h0244 (right side of the screen)
    lhb R3, 0x02
    sw R3, R1, 8                

    llb R3, 0x9A                # YLOC <= 10'h000A (right side of the screen)
    lhb R3, 0x01
    sw R3, R1, 9                

    llb R4, 0x3                 # cntrl <= 3 (don't know what it is for the meteor, need to ask)
    sw R4, R1, 10

    llb R12, 0x00     
    lhb R12, 0x40
    JAL COUNT                   # Gonna have to figure out how we do delay bc of the branch prediction
    b uncond, START


COUNT:
    SUBI R12, R12, 1
    B NEQ, COUNT
    JR R15