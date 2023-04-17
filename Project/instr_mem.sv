module IM(clk,addr,rd_en,instr);

input clk;
input [15:0] addr; 
input rd_en;			// asserted when instruction read desired
//input LWI_instr_EX_DM;

output reg [16:0] instr;	//output of insturction memory

// 4k 17-bit instruction memory
reg [16:0]instr_mem[0:8192];

////////////////////////////////////////////////////////////////
//// Instruction is loaded on clock low when read is enabled //
//////////////////////////////////////////////////////////////

always_ff @ (negedge clk)
  if (rd_en)
    instr <= instr_mem[addr];

//////////////////////////////////////
// Testing own instr mem sequences //
////////////////////////////////////

initial begin
  $readmemh("C:/Users/Ayan Deep Hazra/Desktop/Semesters/SPRING 2023/ECE554/Group Project/ce_test.hex",instr_mem);
end

endmodule