# test strong bit

llb R1, 0x1
llb R2, 0x4     # decrements with each loop
llb R3, 0x3

REPEAT:
sub R5, R2, R3
b gte, FIRST        ## 1st. branch taken & not predicted -- PC: 4 -> PC: 9 (alloc) --- R5 = 1
                    ## 2nd. branch taken & predicted (SETS STRONG BIT) ---- R5 = 0
                    ## 3rd. branch not taken & predicted (CLR STRONG BIT)   --- R5 = -1
                    ## 4th. branch not taken & predicted (line invalidate)  --- R5 = -2

llb R4, 0x0
llb R4, 0x1
llb R4, 0x2
llb R4, 0x3

FIRST:
llb R4, 0x8
llb R4, 0x9
llb R4, 0xa
llb R4, 0xb

sub R2, R2, R1
b eq, END           ## 1st/2nd/3rd. branch not taken & not predicted
                    ## 4th. branch taken & not predicted (alloc)
b gte, REPEAT       ## REPEAT FOUR TIMES ----- PC: 15 -> PC: 3
                    ## 1st. branch taken & not predicted (alloc)
                    ## 2nd. branch taken & predicted (SET STRONG BIT)
                    ## 3rd. .......

END:
b uncond, END