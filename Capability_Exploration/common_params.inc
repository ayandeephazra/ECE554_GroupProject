
///////////////////////////////////////
// Create defines for ALU functions //
/////////////////////////////////////
localparam ADD	= 4'b0000;
localparam SUB 	= 4'b0001;
localparam AND	= 4'b0010;
localparam NOR	= 4'b0011; 
localparam SLL	= 4'b0100;
localparam SRL	= 4'b0101;
localparam SRA	= 4'b0110;
localparam LHB  = 4'b0111;

// appended - wip
localparam ANDN = 4'b1000;
localparam NOT  = 4'b1001;
localparam MUL  = 4'b1010;
localparam XOR  = 4'b1011;
localparam OR   = 4'b1100;

//////////////////////////////////////////
// Create defines for Opcode encodings //
////////////////////////////////////////
localparam ADDi 	= 5'b00000;
localparam ADDZi 	= 5'b00001;
localparam SUBi 	= 5'b00010;
localparam ANDi		= 5'b00011;
localparam NORi		= 5'b00100;
localparam SLLi		= 5'b00101;
localparam SRLi		= 5'b00110;
localparam SRAi		= 5'b00111;
localparam LWi		= 5'b01000;
localparam SWi		= 5'b01001;
localparam LHBi		= 5'b01010;
localparam LLBi		= 5'b01011;
localparam BRi		= 5'b01100;
localparam JALi		= 5'b01101;
localparam JRi		= 5'b01110;
localparam HLTi		= 5'b01111;


//////////////////////////////////////////
// Appended Instructions - wip         //
////////////////////////////////////////
localparam ADDIi 	= 5'b10000;
localparam SUBIi 	= 5'b10001;
localparam XORIi 	= 5'b10010;
localparam ANDNIi	= 5'b10011;
localparam ANDIi	= 5'b10100;
localparam XORNIi 	= 5'b10101;
localparam ORIi 	= 5'b10110;
localparam ANDNi 	= 5'b10111;
localparam NOTi 	= 5'b11100;
localparam MOVCi 	= 5'b11000;
localparam MULi 	= 5'b11001;
localparam PUSHi 	= 5'b11010;
localparam POPi 	= 5'b11011;

////////////////////////////////
// Encodings for src0 select //
//////////////////////////////
localparam RF2SRC0 	= 2'b00;
localparam IMM_BR2SRC0 = 2'b01;			// 7-bit SE for branch target
localparam IMM_JMP2SRC0 = 2'b10;		// 12-bit SE for jump target
localparam IMM2SRC0 = 2'b11;			// 4-bit SE Address immediate for LW/SW

////////////////////////////////
// Encodings for src1 select //
//////////////////////////////
localparam RF2SRC1	= 2'b00;
localparam IMM2SRC1 = 2'b01;			// 8-bit data immediate for LLB/LHB
localparam NPC2SRC1 = 2'b10;			// nxt_pc to src1 for JAL instruction
//
localparam IMM2SRC1_4BZE = 2'b11;       // 4-bit zero extended immediate 



