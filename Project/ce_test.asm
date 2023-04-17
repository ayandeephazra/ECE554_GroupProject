llb R1, 0x08        # R1 holds bmp mmap address
lhb R1, 0xC0

llb R11, 0x01


####### Place B
llb R2, 0x80
lhb R2, 0x00
sw R2, R1, 0        # XLOC <= 

llb R2, 0x20        # YLOC <= 8'h50
sw R2, R1, 1

llb R2, 0x16         # cntrl <= 3 --- 0
sw R2, R1, 2

llb R12, 0x00     
lhb R12, 0x40
JAL COUNT  

####### Place s
llb R2, 0x90
lhb R2, 0x00
sw R2, R1, 0        # XLOC <= 

llb R2, 0x20        # YLOC <= 8'h50
sw R2, R1, 1

llb R2, 0x38         # cntrl <= 3 --- 0
sw R2, R1, 2

llb R12, 0x00     
lhb R12, 0x40
JAL COUNT  

 #######################################

####### Place J
llb R2, 0xD0
lhb R2, 0x00
sw R2, R1, 0        # XLOC <= 

llb R2, 0x20        # YLOC <= 8'h50
sw R2, R1, 1

llb R2, 0x26         # cntrl <= 3 --- 0
sw R2, R1, 2

llb R12, 0x00     
lhb R12, 0x40
JAL COUNT  


####### Place B
llb R2, 0xE0
lhb R2, 0x00
sw R2, R1, 0        # XLOC <= 

llb R2, 0x20        # YLOC <= 8'h50
sw R2, R1, 1

llb R2, 0x16         # cntrl <= 3 --- 0
sw R2, R1, 2

llb R12, 0x00     
lhb R12, 0x40
JAL COUNT 

########################################

####### Place A
llb R2, 0x20
lhb R2, 0x01
sw R2, R1, 0        # XLOC <= 

llb R2, 0x20        # YLOC <= 8'h50
sw R2, R1, 1

llb R2, 0x14         # cntrl <= 3 --- 0
sw R2, R1, 2

llb R12, 0x00     
lhb R12, 0x40
JAL COUNT  


####### Place M
llb R2, 0x30
lhb R2, 0x01
sw R2, R1, 0        # XLOC <= 

llb R2, 0x20        # YLOC <= 8'h50
sw R2, R1, 1

llb R2, 0x2C         # cntrl <= 3 --- 0
sw R2, R1, 2

llb R12, 0x00     
lhb R12, 0x40
JAL COUNT 

########################################

####### Place A
llb R2, 0x70
lhb R2, 0x01
sw R2, R1, 0        # XLOC <= 

llb R2, 0x20        # YLOC <= 8'h50
sw R2, R1, 1

llb R2, 0x14         # cntrl <= 3 --- 0
sw R2, R1, 2

llb R12, 0x00     
lhb R12, 0x40
JAL COUNT  


####### Place H
llb R2, 0x80
lhb R2, 0x01
sw R2, R1, 0        # XLOC <= 

llb R2, 0x20        # YLOC <= 8'h50
sw R2, R1, 1

llb R2, 0x22         # cntrl <= 3 --- 0
sw R2, R1, 2

llb R12, 0x00     
lhb R12, 0x40
JAL COUNT 

##########################################


####### Place Mario
llb R2, 0x80
lhb R2, 0x01
sw R2, R1, 0        # XLOC <= 10'h180

llb R2, 0x50        # YLOC <= 8'h50
sw R2, R1, 1

llb R2, 0x3         # cntrl <= 3
sw R2, R1, 2

llb R12, 0x00     
lhb R12, 0x40
JAL COUNT           #### WAIT 1000 cycles


####### Place Bucky
llb R2, 0x40
lhb R2, 0x00
sw R2, R1, 0        # XLOC <= 8'h40

llb R2, 0x50        # YLOC <= 8'h50
sw R2, R1, 1

llb R2, 0x5         # cntrl <= 1
sw R2, R1, 2


llb R12, 0x00
lhb R12, 0x40
JAL COUNT           #### WAIT 1000 cycles


####### Place Po
llb R2, 0xE0
lhb R2, 0x00
sw R2, R1, 0        # XLOC <= 8'h40

llb R2, 0x00        # YLOC <= 8'h50
lhb R2, 0x01
sw R2, R1, 1

llb R2, 0x7         # cntrl <= 7
sw R2, R1, 2


END:
b uncond, END

################################################


COUNT:
SUB R12, R12, R11
B NEQ, COUNT
JR R15