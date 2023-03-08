module btb (
    input clk,
    input rst_n,
    // input en,         // enable btb default high
    input [15:0] PC,
    output [15:0] target_PC,
    output hit,
    output logic btb_hit_ID_EX
);

// 512 entries deep
// <<<   TAG[24:18] || S[17] || V[16] || target_PC[15:0]   >>>
logic [25:0] btb_mem [0:511];

logic [8:0] index;
logic [6:0] tag;
logic [25:0] btb_out;
logic valid_bit, strong_bit;
logic en, btb_hit_IF_ID;

assign index = PC[8:0];

always_ff @(negedge clk, negedge rst_n)     // RST TO 0 AFTER TESTING
    btb_out <= btb_mem[index];
 

// Determine hit
assign valid_bit = btb_out[16];
assign tag = btb_out[24:18];
assign hit = (valid_bit & en & (PC[15:9] == tag)) ? 1 : 0;

// output target
assign target_PC = btb_out[13:0];


	  
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




initial begin
  $readmemh("I:/ece554/ECE554_GroupProject/Project/btb_contents.hex",btb_mem);
end

    
endmodule