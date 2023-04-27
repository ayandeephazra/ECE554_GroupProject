// Dual port rf memory block.
// instantiated twice in rf.sv to create 3 port register file
module rf_mem(
    
    input clk,
    input rst_n,
    input [3:0] r_addr,
    input [3:0] w_addr,
    input [15:0] wdata,
    input we,
    output logic [15:0] rdata
);

    // 16 wide 16-bit rf memory
    reg [15:0] mem [0:15];

    always_ff @ (negedge clk or negedge rst_n) begin
        // For push/pop need to default R14 to 0 for it work normally
        if (!rst_n)
             mem[4'b1110] <= 16'h0000;
            
        // if write is high and addr is valid, write to address
        if (we && |w_addr)
            mem[w_addr] <= wdata;
        // unconditional read always
        rdata <= mem[r_addr];
    end

endmodule
    