module btb (
    input clk,
    input rst_n,
    input en,         // enable btb default high
    input [15:0] PC,
    input flow_change_ID_EX,
    input stall_IM_ID,
    input br_instr_ID_EX,
    input [15:0] pc_ID_EX,
    input [15:0] dst_ID_EX,
    output [15:0] target_PC,
    output hit,
    output logic btb_hit_ID_EX,
    
    // stat collection signals
    output inc_br_cnt,
    output inc_hit_cnt,
    output inc_mispr_cnt
);

// 512 entries deep
// <<<   TAG[24:18] || S[17] || V[16] || target_PC[15:0]   >>>
logic [24:0] btb_mem [0:511];

logic [8:0] index;
logic [6:0] tag;
logic [24:0] btb_out;
logic valid_bit, strong_bit;
logic sbit_IF_ID, sbit_ID_EX;
logic [15:0] target_PC_IF_ID, target_PC_ID_EX;
// logic en;    
logic btb_hit_IF_ID;

logic write, alloc, evict, set_strong, clr_strong;
logic [8:0] wr_index;
logic [25:0] btb_wr_data;

assign index = PC[8:0];

always_ff @(negedge clk) begin
  btb_out <= btb_mem[index];
  if (write)
    btb_mem[wr_index] <= btb_wr_data;
end

assign strong_bit = btb_out[17];

// Determine hit
assign valid_bit = btb_out[16];
assign tag = btb_out[24:18];
assign hit = (valid_bit & ~stall_IM_ID & en & (PC[15:9] == tag)) ? 1 : 0;

// output target
assign target_PC = btb_out[13:0];

/////////////////////////
// BTB Write logic
/////////////////////
always_comb begin
  alloc = (~btb_hit_ID_EX & br_instr_ID_EX & flow_change_ID_EX);  // taken and not predicted
  evict = (btb_hit_ID_EX & flow_change_ID_EX & ~sbit_ID_EX);      // misprediction & no strong bit
  set_strong = (btb_hit_ID_EX & ~flow_change_ID_EX);              // correct prediction
  clr_strong = (btb_hit_ID_EX & flow_change_ID_EX & sbit_ID_EX);  // misprediiction & strong bit
  write = alloc | evict | set_strong | clr_strong;

  wr_index = pc_ID_EX[8:0] - 1;   // pre-incremented PC
  btb_wr_data = (alloc) ? {pc_ID_EX[15:9], 1'b0, 1'b1, dst_ID_EX} :
                (set_strong) ? {pc_ID_EX[15:9], 1'b1, 1'b1, dst_ID_EX} :
                (clr_strong) ? {pc_ID_EX[15:9], 1'b0, 1'b1, target_PC_ID_EX} :    // retain old prediction
                {8'h0, 1'b0, 16'h0};    // invalidate line
end


/////////////////////////
// Pipeline reg IF_ID //
///////////////////////
always @(posedge clk) begin
  btb_hit_IF_ID <= hit;
  sbit_IF_ID <= strong_bit;
  target_PC_IF_ID <= target_PC;
end

	
/////////////////////////
// Pipeline reg ID_EX //
///////////////////////
always @(posedge clk) begin
  btb_hit_ID_EX <= btb_hit_IF_ID;   // Pipeline to EX to decide if flow change is necessary
  sbit_ID_EX <= sbit_IF_ID;
  target_PC_ID_EX <= target_PC_IF_ID;
end


////////////////////////////////////
// Branch stats collection logic //
//////////////////////////////////
assign inc_br_cnt = br_instr_ID_EX;   // count branches that make it to EX
assign inc_hit_cnt = hit;             // count btb hits immediately
assign inc_mispr_cnt = btb_hit_ID_EX & flow_change_ID_EX;   // misprediction




// use initial readmemh to reset all valid bits to 0. This will synthesize on the FPGA.
// not possible to connect an async reset to the entire btb_mem on FPGA
initial
  $readmemh("C:/Users/Ayan Deep Hazra/Desktop/Semesters/SPRING 2023/ECE554/GroupProject_003/btb_contents_reset.hex",btb_mem);

    
endmodule