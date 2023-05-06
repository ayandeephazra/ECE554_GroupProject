`timescale 1ns/10ps
module btb_tb();

logic clk, rst_n;
wire [35:0] GPIO;
logic TX, RX;
logic [9:0] SW;

// cpu iCPU(.clk(clk), .rst_n(rst_n), .wdata(), .mm_we(), .addr(), .mm_re(), .rdata());
GroupProject iTOPLEVEL(.KEY({3'h0, rst_n}), .CLOCK_50(clk), .GPIO(GPIO), .SW(SW));

assign TX = GPIO[3];

initial begin
    clk = 0;
    rst_n = 0;
    SW[0] = 1;      // enables btb
    @ (negedge clk)
    rst_n = 1;
    // iTOPLEVEL.cpu1.iBTB.en = 1;   // enable btb

    // repeat (100000) @ (posedge clk);
    // $stop;

end

always
    #5 clk = ~clk;

endmodule