llb R1, 0x00	    # R1 holds string init addr
lhb R1, 0x01
llb R2, 0x04        # R2 holds spart addr 
lhb R2, 0xc0
llb R4, 0x80        # R4 holds bitmask for polling tx_queue
lhb R4, 0x00

LOOP:
movc R3, R1, 0      # R3: holds char to print
addi R1, R1, 1

and R5, R3, R3      # R5: junk reg
b eq, END           # found \0 -- end of string

sw R3, R2, 0        # send char

TX_WAIT:
lw R3, R2, 1        # R3: holds status reg (0xc005)
and R3, R3, R4      # ***load use dependency here, stall cycle**
b eq, TX_WAIT
b uncond, LOOP



END:
b uncond, END



MEM 0x0100
STRING print stats 