module videoMem6bit(clk, rst_n, we,waddr,wdata,raddr,rdata);

  input clk;
  input rst_n;
  input we;
  input [18:0] waddr;
  input [5:0] wdata;
  input [18:0] raddr;
  output reg [5:0] rdata;
  
  // 6 BIT VIDEO MEMORY 307K WIDE
  reg [5:0]mem[0:307199];
  
  always @(posedge clk) begin
   if (we)
	  mem[waddr] <= wdata;
	rdata <= mem[raddr];
  end

endmodule