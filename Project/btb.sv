module btb (
    input clk,
    input rst_n,
    // input en,         // enable btb default high
    input [15:0] PC,
    input flow_change_ID_EX,
    input br_instr_ID_EX,
    input [15:0] pc_ID_EX,
    input [15:0] dst_ID_EX,
    output [15:0] target_PC,
    output hit,
    output logic btb_hit_ID_EX
);

// 512 entries deep
// <<<   TAG[24:18] || S[17] || V[16] || target_PC[15:0]   >>>
logic [24:0] btb_mem [0:511];

logic [8:0] index;
logic [6:0] tag;
logic [24:0] btb_out;
logic valid_bit, strong_bit;
logic en, btb_hit_IF_ID;

logic write, alloc, evict;
logic [8:0] wr_index;
logic [25:0] btb_wr_data;

assign index = PC[8:0];

always_ff @(negedge clk) begin
  btb_out <= btb_mem[index];
  if (write)
    btb_mem[wr_index] <= btb_wr_data;
end

// Determine hit
assign valid_bit = btb_out[16];
assign tag = btb_out[24:18];
assign hit = (valid_bit & en & (PC[15:9] == tag)) ? 1 : 0;

// output target
assign target_PC = btb_out[13:0];

/////////////////////////
// BTB Write logic
/////////////////////
always_comb begin
  alloc = (~btb_hit_ID_EX & br_instr_ID_EX & flow_change_ID_EX);
  evict = (btb_hit_ID_EX & flow_change_ID_EX);   // misprediction
  write = alloc | evict;

  wr_index = pc_ID_EX[8:0] - 1;   // pre-incremented PC
  btb_wr_data = (alloc) ? {pc_ID_EX[15:9], 1'b0, 1'b1, dst_ID_EX} : {8'h0, 1'b0, 16'h0};
end

	  
/////////////////////////
// Pipeline reg IF_ID //
///////////////////////
always @(posedge clk)
  btb_hit_IF_ID <= hit;
	
/////////////////////////
// Pipeline reg ID_EX //
///////////////////////
always @(posedge clk)
  btb_hit_ID_EX <= btb_hit_IF_ID;   // Pipeline to EX to decide if flow change is necessary



// use initial readmemh to reset all valid bits to 0. This will ysnthesize on the FPGA.
// not possible to connect an async reset to the entire btb_mem on FPGA
initial begin
  $readmemh("I:/ece554/ECE554_GroupProject/Project/btb_contents_reset.hex",btb_mem);
end

    
endmodule