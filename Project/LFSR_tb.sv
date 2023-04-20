module LFSR_tb();

reg clk;
reg rst_n, load;
reg [7:0] SEED, q;

LFSR iDUT(.clk(clk), .rst_n(rst_n), .load(load), .SEED(SEED), .q(q));

initial begin
    clk = 0;
    rst_n = 0;
    SEED = 8'h88;
    load = 1;
    repeat(5)@(posedge clk);
    load = 0;
    rst_n = 1;
    
    repeat(50)@(posedge clk);
    rst_n = 0;
    SEED = 8'h12;
    load = 1;
    repeat(5)@(posedge clk);
    rst_n = 1;
    load = 0;

    repeat(50)@(posedge clk);
    rst_n = 0;
    SEED = 8'hE4;
    load = 1;
    repeat(5)@(posedge clk);
    rst_n = 1;
    load = 0;

    repeat(50)@(posedge clk);
    rst_n = 0;
    SEED = 8'hFF;
    load = 1;
    repeat(5)@(posedge clk);
    rst_n = 1;
    load = 0;

    repeat(50)@(posedge clk);
    rst_n = 0;
    SEED = 8'h00;
    load = 1;
    repeat(5)@(posedge clk);
    rst_n = 1;
    load = 0;

    repeat(50)@(posedge clk);
    $stop;

end

always
  #1 clk = ~clk;

endmodule
