module LFSR_tb();

reg             clk;            // 50MHz clock 
reg             rst_n, load;    // reset low, load signal for LFSR
reg [7:0]       SEED, q;        // 8-bit value to go into LFSR, 8-bit output

///////////////////////
// Instantiate LFSR //
/////////////////////
LFSR iDUT(.clk(clk), .rst_n(rst_n), .load(load), .SEED(SEED), .q(q));

initial begin
    // start clk at 0 and rst low
    clk = 0;
    rst_n = 0;
    SEED = 8'h88;
    repeat(5)@(posedge clk);
    // load seed and rst high
    rst_n = 1;
    load = 1;
    repeat(5)@(posedge clk);
    // start LFSR
    load = 0;
    rst_n = 1;
    
    repeat(50)@(posedge clk);
    rst_n = 0;
    SEED = 8'h12;
    repeat(5)@(posedge clk);
    // load seed and rst high
    load = 1;
    rst_n = 1;
    repeat(5)@(posedge clk);
    // start LFSR
    rst_n = 1;
    load = 0;

    repeat(50)@(posedge clk);
    rst_n = 0;
    SEED = 8'hE4;
    repeat(5)@(posedge clk);
    // load seed and rst high
    load = 1;
    rst_n = 1;
    repeat(5)@(posedge clk);
    // start LFSR
    rst_n = 1;
    load = 0;

    repeat(50)@(posedge clk);
    rst_n = 0;
    SEED = 8'hFF;
    repeat(5)@(posedge clk);
    // load seed and rst high
    load = 1;
    rst_n = 1;
    repeat(5)@(posedge clk);
    // start LFSR
    rst_n = 1;
    load = 0;

    repeat(50)@(posedge clk);
    rst_n = 0;
    SEED = 8'h00;
    repeat(5)@(posedge clk);
    // load seed and rst high
    load = 1;
    rst_n = 1;
    repeat(5)@(posedge clk);
    // start LFSR
    rst_n = 1;
    load = 0;

    repeat(50)@(posedge clk);
    $stop;

end

always
  #1 clk = ~clk;

endmodule
