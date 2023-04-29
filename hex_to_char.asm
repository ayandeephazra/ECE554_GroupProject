# Output hex values to PuTTY
# first look at second digit value (bits 7:4)
# if value is <= 9 then add 0x30 (offset to number chars) and Print
# if value is > 9 then add 0x57 (offset to lowercase letter chars) and print



llb R11, 0x04       # R11 holds spart addr
lhb R11, 0xC0
llb R10, 0x9f       # R10 holds VALUE
lhb R10, 0x00
llb R12, 9          # R12 contains 9 for comparing

#####################
# UPPER NIBBLE
#####################

srl R13, R10, 4     # R13 contains upper nibble

sub R14, R13, R12   # R14 is junk reg for comparison subtraction
b gt, LETTER_1      # value > 9 -- needs letter char
llb R15, 0x30       # R15 contains addition offset
b uncond, CONVERT_1

LETTER_1:
llb R15, 0x57       # R15 -- offset to ascii lowercase chars

CONVERT_1:
add R13, R13, R15   # R13 contains converted value

sw R13, R11, 0      # PRINT

#####################
# LOWER NIBBLE
#####################

llb R14, 0x0f
and R13, R14, R10   # R13 now conatians lower nibble

sub R14, R13, R12   # R14 is junk reg for comparison subtraction
b gt, LETTER_2      # value > 9 -- needs letter char
llb R15, 0x30       # R15 contains addition offset
b uncond, CONVERT_2

LETTER_2:
llb R15, 0x57       # R15 -- offset to ascii lowercase chars

CONVERT_2:
add R13, R13, R15   # R13 contains converted value

sw R13, R11, 0      # PRINT


END:
b uncond, END