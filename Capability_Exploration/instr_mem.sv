module IM(clk,addr,rd_en,instr);

input clk;
input [10:0] addr; 
input rd_en;			// asserted when instruction read desired

output reg [16:0] instr;	//output of insturction memory

// 4k 17-bit instruction memory
reg [16:0]instr_mem[0:2047];

// /////////////////////////////////////////////////////////////
// // Instruction is loaded on clock low when read is enabled//
// ///////////////////////////////////////////////////////////

always_ff @ (negedge clk)
  if (rd_en)
    instr <= instr_mem[addr];

//////////////////////////////////////
// Testing own instr mem sequences //
////////////////////////////////////

initial begin
  $readmemh("I:/ece554/ECE554_GroupProject/Capability_Exploration/test.hex",instr_mem);
end

endmodule
