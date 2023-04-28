module cpu_tb();

reg clk,rst_n;

logic [15:0] rdata;

//////////////////////
// Instantiate CPU //
////////////////////

// we just leave the output signals at Z because they can viewed from 
// within cpu module
cpu iCPU(.clk(clk), .rst_n(rst_n), .rdata(rdata), .wdata(), .mm_we(), .addr(), .mm_re());

initial begin
  iCPU.iBTB.en = 1;
  clk = 0;
  rst_n = 0;
  @ (posedge clk);
  rst_n = 1;
  rdata = 16'haaaa;
  repeat (100000000) @ (posedge clk);
  $stop();
  
end
  
always
  #5 clk = ~clk;
  
endmodule
