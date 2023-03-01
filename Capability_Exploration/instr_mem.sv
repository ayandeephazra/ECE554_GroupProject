module IM(clk,addr,rd_en,instr);

input clk;
input [15:0] addr; 
input rd_en;			// asserted when instruction read desired

output reg [15:0] instr;	//output of insturction memory

// 4k 16-bit instruction memory
reg [15:0]instr_mem[0:1023];

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
