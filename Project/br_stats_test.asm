# test strong bit
llb R1, 0x1
llb R2, 0x0b
lhb R2, 0xc0
sw R1, R2, 0    # start stats -- set mem[0xc00b]

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
b eq, END_STATS     ## 1st/2nd/3rd. branch not taken & not predicted
                    ## 4th. branch taken & not predicted (alloc)
b gte, REPEAT       ## REPEAT FOUR TIMES ----- PC: 15 -> PC: 3
                    ## 1st. branch taken & not predicted (alloc)
                    ## 2nd. branch taken & predicted (SET STRONG BIT)
                    ## 3rd. .......

END_STATS:
llb R1, 0x0
llb R2, 0x0b
lhb R2, 0xc0
sw R1, R2, 0        # stop stats -- clear mem[0xc00b]
jal PRINT_STATS

END:
b uncond, END


###############################
# Print stats
###############################

PRINT_STATS:
llb R1, 0x10
lhb R1, 0xc0        # R1 contains mmap_reg base (br_cnt)
llb R2, 0x04
lhb R2, 0xC0	    # R2 contains spart addr

lw R5, R1, 0        # R5 holds stats

llb R3, 0x53        # S
sw R3, R2, 0
llb R3, 0x74        # t
sw R3, R2, 0
llb R3, 0x61        # a
sw R3, R2, 0
llb R3, 0x74        # t
sw R3, R2, 0
llb R3, 0x73        # s
sw R3, R2, 0
llb R3, 0x3a        # :
sw R3, R2, 0
llb R3, 0x20        # ' '
sw R3, R2, 0

L_WAIT_EMP:         # wait for TX q to empty
lw R3, R1, 1        # read from 0xc005 (status reg) --> R3
and R3, R3, R4      # look for R3 == 1XXX_XXXX (tx_queue is empty)
b eq, L_WAIT_EMP    # if result is zero => MSB of status_reg is not 1 => not empty keep waiting

llb R3, 0x30        # 0
sw R3, R2, 0
llb R3, 0x78        # x
sw R3, R2, 0


llb R14, 0xff       # DEBUG

sw R5, R2, 0        # ******** OUTPUT STATS ********
jr R15