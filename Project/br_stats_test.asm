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
llb R1, 0x10        # R1 contains mmap_reg base (br_cnt)
lhb R1, 0xc0        
llb R2, 0x04        # R2 contains spart addr
lhb R2, 0xC0	    
llb R4, 0x80        # R4 holds bit mask to poll tx q
lhb R4, 0x00

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
lw R3, R2, 1        # read from 0xc005 (status reg) --> R3
and R3, R3, R4      # look for R3 == 1XXX_XXXX (tx_queue is empty)
b eq, L_WAIT_EMP    # if result is zero => MSB of status_reg is not 1 => not empty keep waiting

llb R3, 0x30        # 0
sw R3, R2, 0
llb R3, 0x78        # x
sw R3, R2, 0


llb R14, 0xff       # DEBUG

##########################################
#   HEX --> CHAR CONVERSION
##########################################

    llb R12, 9          # R12 contains 9 for comparing
    llb R4, 0x0f        # R4 contains bit mask to select each 4 bits after shifting

    #####################
    # NIBBLE 4
    #####################

    srl R13, R5, 12      # R13 contains R5[15:12]
    and R13, R13, R4

    sub R14, R13, R12   # R14 is junk reg for comparison subtraction
    b gt, LETTER_4      # value > 9 -- needs letter char
    llb R9, 0x30        # R9 contains addition offset
    b uncond, CONVERT_4

    LETTER_4:
    llb R9, 0x57        # R9 -- offset to ascii lowercase chars

    CONVERT_4:
    add R13, R13, R9    # R13 contains converted value

    sw R13, R2, 0       # PRINT

    #####################
    # NIBBLE 3
    #####################

    srl R13, R5, 8      # R13 contains R5[11:8]
    and R13, R13, R4

    sub R14, R13, R12   # R14 is junk reg for comparison subtraction
    b gt, LETTER_3      # value > 9 -- needs letter char
    llb R9, 0x30        # R9 contains addition offset
    b uncond, CONVERT_3

    LETTER_3:
    llb R9, 0x57        # R9 -- offset to ascii lowercase chars

    CONVERT_3:
    add R13, R13, R9    # R13 contains converted value

    sw R13, R2, 0       # PRINT

    #####################
    # NIBBLE 2
    #####################

    srl R13, R5, 4      # R13 contains R5[7:4]
    and R13, R13, R4

    sub R14, R13, R12   # R14 is junk reg for comparison subtraction
    b gt, LETTER_2      # value > 9 -- needs letter char
    llb R9, 0x30        # R9 contains addition offset
    b uncond, CONVERT_2

    LETTER_2:
    llb R9, 0x57        # R9 -- offset to ascii lowercase chars

    CONVERT_2:
    add R13, R13, R9    # R13 contains converted value

    sw R13, R2, 0       # PRINT

    #####################
    # NIBBLE 1
    #####################

    and R13, R4, R5    # R13 contains R5[3:0]

    sub R14, R13, R12   # R14 is junk reg for comparison subtraction
    b gt, LETTER_1      # value > 9 -- needs letter char
    llb R9, 0x30       # R9 contains addition offset
    b uncond, CONVERT_1

    LETTER_1:
    llb R9, 0x57       # R9 -- offset to ascii lowercase chars

    CONVERT_1:
    add R13, R13, R9   # R13 contains converted value

    sw R13, R2, 0      # PRINT



jr R15