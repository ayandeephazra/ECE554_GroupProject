llb R1, 0x1
llb R2, 0x3

add R3, R1, R2
b neq, FIRST         ## branch taken & predicted -- PC: 3 -> PC: e

CONT1:
llb R4, 0x1
llb R4, 0x2
llb R4, 0x3
llb R4, 0x4

sub R5, R4, R3
b eq, SECOND         ## branch taken & predicted -- PC: 9 -> PC: 0x10

llb R4, 0x5
llb R4, 0x6
llb R4, 0x7
llb R4, 0x8

FIRST:
llb R14, 0xff
b uncond, CONT1     ## branch taken & not predicted -- PC: f -> PC: 4

SECOND:
llb R14, 0x00

llb R4, 0x9
llb R4, 0xa
b lt, FIRST         ## branch not taken & predicted -- PC: 0x13
llb R4, 0xb
llb R4, 0xc
b gt, SECOND        ## branch not taken & not predicted -- PC: 0x16
llb R4, 0xd
llb R4, 0xe
llb R4, 0xf




END:
b uncond, END
