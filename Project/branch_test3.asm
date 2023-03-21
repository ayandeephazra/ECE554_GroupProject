# testing writes/reads

llb R1, 0x1
llb R2, 0x3

REPEAT:
b neq, FIRST        ## 1st. branch taken & not predicted -- PC: 2 -> PC: 7
                    ## 2nd. branch taken & predicted

llb R4, 0x0
llb R4, 0x1
llb R4, 0x2
llb R4, 0x3

FIRST:
llb R4, 0x4
llb R4, 0x5
llb R4, 0x6
llb R4, 0x7
sub R5, R2, R1
sub R5, R5, R1
b gt, SECOND        ## 1st. branch taken & not predicted -- PC: 13 -> PC: 18
                    ## 2nd. branch not taken & predicted (verify line is invalidated)

llb R4, 0x8
llb R4, 0x9
llb R4, 0xa
llb R4, 0xb

SECOND:
llb R4, 0xc
llb R4, 0xd
llb R4, 0xe
llb R4, 0xf

sub R2, R2, R1      
sub R5, R2, R1
b eq, END           ## 1st. branch first not taken - not written
                    ## 2nd. branch taken & not predicted ---- PC: 24 -> PC: 26
b gte, REPEAT       ## REPEAT ONCE ----- PC: 25 -> PC: 2

END:
b uncond, END