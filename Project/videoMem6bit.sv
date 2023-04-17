module videoMem6bit(clk,we,waddr,wdata,raddr,rdata);

  input clk;
  input we;
  input [18:0] waddr;
  input [5:0] wdata;
  input [18:0] raddr;
  output reg [5:0] rdata;
  
  reg [5:0]mem[0:307199];
  
  always @(posedge clk) begin
    if (we)
	  mem[waddr] <= wdata;
	rdata <= mem[raddr];
  end

endmodule