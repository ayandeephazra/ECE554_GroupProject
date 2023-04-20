module LFSR_tb();

reg clk;
reg rst_n;
reg [7:0] SEED, q;

LFSR iDUT(.clk(clk), .rst_n(rst_n), .SEED(SEED), .q(q));

initial begin
    clk = 0;
    rst_n = 0;
    SEED = 8'h88;
    repeat(5)@(posedge clk);
    rst_n = 1;
    
    repeat(50)@(posedge clk);
    rst_n = 0;
    SEED = 8'h12;
    repeat(5)@(posedge clk);
    rst_n = 1;

    repeat(50)@(posedge clk);
    rst_n = 0;
    SEED = 8'hE4;
    repeat(5)@(posedge clk);
    rst_n = 1;

    repeat(50)@(posedge clk);
    rst_n = 0;
    SEED = 8'hFF;
    repeat(5)@(posedge clk);
    rst_n = 1;

    repeat(50)@(posedge clk);
    rst_n = 0;
    SEED = 8'h00;
    repeat(5)@(posedge clk);
    rst_n = 1;

    repeat(50)@(posedge clk);
    $stop;

end

always
  #1 clk = ~clk;

endmodule
