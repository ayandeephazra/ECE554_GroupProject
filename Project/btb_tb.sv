module btb_tb();

logic clk, rst_n;

cpu iCPU(.clk(clk), .rst_n(rst_n), .wdata(), .mm_we(), .addr(), .mm_re(), .rdata());

initial begin
    clk = 0;
    rst_n = 0;
    @ (negedge clk)
    rst_n = 1;
    iCPU.iBTB.en = 1;   // enable btb


    repeat (100) @ (posedge clk);
    $stop;

end


always
    #5 clk = ~clk;

endmodule