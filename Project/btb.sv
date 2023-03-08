module btb (
    input clk,
    input rst_n,
    input [13:0] PC,
    output [13:0] target_PC,
    output hit
);

// 512 entries
// <<<   TAG[20:16] || V[15] || S[14] || target_PC[13:0]   >>>
logic [20:0] btb_mem [0:511];

logic [8:0] index;
logic [4:0] tag;
logic [20:0] btb_out;
logic valid_bit;

assign index = PC[8:0];

always_ff @(posedge clk, negedge rst_n)     // RST TO 0 AFTER TESTING
    btb_out <= btb_mem[index];
 

// Determine hit
assign tag = btb_out[20:16];
assign hit = (PC[15:9] == tag) ? 1 : 0;

// output target
assign target_PC = btb_out[13:0];


initial begin
  $readmemh("I:/ece554/ECE554_GroupProject/Project/btb_contents.hex",btb_mem);
end

    
endmodule