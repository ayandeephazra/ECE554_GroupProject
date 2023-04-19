module pc(clk,rst_n,stall_IM_ID,dst_ID_EX,
          LWI_instr_EX_DM, dst_EX_DM,
          pc,pc_ID_EX,flow_change_ID_EX,pc_EX_DM,
          btb_hit, btb_nxt_pc, btb_hit_ID_EX, pc_pre_mux);
////////////////////////////////////////////////////////////////////////////\
// This module implements the program counter logic. It normally increments \\
// the PC by 1, but when a branch is taken will add the 9-bit immediate      \\
// field to the PC+1.  In case of a jmp_imm it will add the 12-bit immediate //
// field to the PC+1.  In the case of a jmp_reg it will use the register    //
// port zero (p0) register access as the new value of the PC.  It also     //
// provides PC+1 as nxt_pc for JAL instructions.                          //
///////////////////////////////////////////////////////////////////////////
input clk,rst_n;
input flow_change_ID_EX;			// asserted from branch boolean on jump or taken branch
input stall_IM_ID;					// asserted if we need to stall the pipe
input [15:0] dst_ID_EX;				// branch target address comes in on this bus
input btb_hit;                // Fetch target PC predicted by Branch Predictor
input [15:0] btb_nxt_pc;      // target pc from btb
input btb_hit_ID_EX;

///////////////////////////////////////////////////////////////////////////////////////////////////////
input LWI_instr_EX_DM; 				// pipelined movc select signal
input [15:0] dst_EX_DM;
///////////////////////////////////////////////////////////////////////////////////////////////////////

output [15:0] pc;				// the PC, forms address to instruction memory, muxed with movc control
output reg [15:0] pc_ID_EX;			// needed in EX stage for Branch instruction
output reg [15:0] pc_EX_DM;			// needed in dst_mux for JAL instruction
output reg [15:0] pc_pre_mux;   // used to index into BTB

reg [15:0] pc_IM_ID;

wire [15:0] nxt_pc;

/////////////////////////////////////
// implement incrementer for PC+1 //
///////////////////////////////////

assign nxt_pc = pc + 1;

/*
always @(posedge clk, negedge rst_n)
  if (!rst_n) begin
    pc_pre_movc_mux <= 16'h0000;
	pc <= 16'h0000;
  end
  else if (!stall_IM_ID)	// all stalls stall the PC
    if (flow_change_ID_EX) begin
      pc_pre_movc_mux <= dst_ID_EX;
	  pc <= dst_ID_EX;
	end
    else begin
	  pc_pre_movc_mux <= nxt_pc;
	  pc <= pc_pre_movc_mux;
	end
  else if (LWI_instr_EX_DM)
    pc <= dst_EX_DM;
*/

////////////////////////////////
// Implement the PC register //
//////////////////////////////

always @(posedge clk, negedge rst_n)
  if (!rst_n) begin
    pc_pre_mux <= 16'h0000;
	//pc <= 16'h0000;
  end
  else if (!stall_IM_ID)	// all stalls stall the PC

    // MOVC TAKES HIGHER PRIORITY
    if (flow_change_ID_EX)
      if (btb_hit_ID_EX)
        pc_pre_mux <= pc_ID_EX;   // branch misprediction :( -- flush back to og pc
      else
        pc_pre_mux <= dst_ID_EX;  // standard jump flow
    else if (btb_hit)
      pc_pre_mux <= btb_nxt_pc;   // branch prediction
    else
	    pc_pre_mux <= nxt_pc;

    // MERGE CONFLICT !!!!!!!!!
    // BRANCH PREDICTION HIGHER PRIORITY
//     if (flow_change_ID_EX) begin
// <<<<<<< HEAD
//       pc_pre_mux <= dst_ID_EX;
//     else
// 	  pc_pre_mux <= nxt_pc;
// =======
//       if (btb_hit_ID_EX)
//         pc <= pc_ID_EX;   // branch misprediction :( -- flush back to og pc
//       else
//         pc <= dst_ID_EX;
//     else if (btb_hit)
//       pc <= btb_nxt_pc;
//     else
// 	    pc <= nxt_pc;

// >>>>>>> branch_predictor
    // end




/////////////////////////////////////////////////
// Implement the mux that selects the movc pc //
///////////////////////////////////////////////
assign pc = (LWI_instr_EX_DM)? dst_EX_DM: pc_pre_mux;

////////////////////////////////////////////////
// Implement the PC pipelined register IM_ID //
//////////////////////////////////////////////
always @(posedge clk)
  if (!stall_IM_ID)
    pc_IM_ID <= nxt_pc;		// pipeline PC points to next instruction
	
////////////////////////////////////////////////
// Implement the PC pipelined register ID_EX //
//////////////////////////////////////////////
always @(posedge clk)
  pc_ID_EX <= pc_IM_ID;	// pipeline it down to EX stage for jumps
	
////////////////////////////////////////////////
// Implement the PC pipelined register EX_DM //
//////////////////////////////////////////////
always @(posedge clk)
  pc_EX_DM <= pc_ID_EX;	// pipeline it down to DM stage for saved register for JAL

endmodule