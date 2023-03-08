llb R1, 0x1
llb R2, 0x3

add R3, R1, R2
b eq, FIRST         ## branch not taken -- PC: 3

llb R4, 0x1
llb R4, 0x2
llb R4, 0x3
llb R4, 0x4

sub R5, R4, R3
b eq, FIRST        ## branch taken     -- PC: 9

llb R4, 0x5
llb R4, 0x6
llb R4, 0x7
llb R4, 0x8

FIRST:
llb R14, 0xff


END:
b uncond, END
