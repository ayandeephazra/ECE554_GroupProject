`timescale 1ns/10ps
module btb_tb();

logic clk, rst_n;
wire [35:0] GPIO;
logic TX, RX;

// cpu iCPU(.clk(clk), .rst_n(rst_n), .wdata(), .mm_we(), .addr(), .mm_re(), .rdata());
BranchPrediction iTOPLEVEL(.KEY({3'b000, rst_n}), .CLOCK_50(clk), .GPIO(GPIO));

assign TX = GPIO[3];

initial begin
    clk = 0;
    rst_n = 0;
    @ (negedge clk)
    rst_n = 1;
    iTOPLEVEL.cpu1.iBTB.en = 1;   // enable btb

    repeat (100000000) @ (posedge clk);
    $stop;

end

always
    #5 clk = ~clk;

endmodule