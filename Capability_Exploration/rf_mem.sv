// Dual port rf memory block.
// instantiated twice in rf.sv to create 3 port register file
module rf_mem(
    input clk,
    input [3:0] r_addr,
    input [3:0] w_addr,
    input [16:0] wdata,
    input we,
    output logic [16:0] rdata
);

    // 16 wide 16-bit rf memory
    reg [16:0] mem [0:15];

    always_ff @ (negedge clk) begin
        // if write is high and addr is valid, write to address
        if (we && |w_addr)
            mem[w_addr] <= wdata;
        // unconditional read always
        rdata <= mem[r_addr];
    end

endmodule
    
