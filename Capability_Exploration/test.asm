llb R1, 0x08        # R1 holds RX/TX mmap address
lhb R1, 0xC0

####### BMP cmds ########

####### Place Bucky
llb R2, 0x80
lhb R2, 0x00
sw R2, R1, 0        # XLOC <= 8'h80

llb R2, 0x50        # YLOC <= 8'h50
sw R2, R1, 1

llb R2, 0x3         # cntrl <= 3
sw R2, R1, 2



END:
b uncond, END



