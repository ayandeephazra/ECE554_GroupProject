# testing writes
# missing case: 
#   taken not predicted
#   and then mispredict @ same PC

llb R1, 0x1
llb R2, 0x3

REPEAT:
b neq, FIRST         ## branch taken & not predicted -- PC: 2 -> PC: 7

llb R4, 0x0
llb R4, 0x1
llb R4, 0x2
llb R4, 0x3

FIRST:
llb R4, 0x4
llb R4, 0x5
llb R4, 0x6
llb R4, 0x7
b gte, SECOND       ## branch taken & not predicted -- PC: 11 -> PC: 16

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
b eq, END           ## branch first not taken - not written, then taken, written
b gte, REPEAT       ## REPEAT ONCE ----- PC: 23 -> PC: 2

END:
b uncond, END