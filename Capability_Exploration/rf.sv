module rf(clk,p0_addr,p1_addr,p0,p1,re0,re1,dst_addr,dst,we);
//////////////////////////////////////////////////////////////////
// Triple ported register file.  Two read ports (p0 & p1), and //
// one write port (dst).  Data is written on clock high, and  //
// read on clock low //////////////////////////////////////////
//////////////////////

input clk;
input [3:0] p0_addr, p1_addr;			// two read port addresses
input re0,re1;							// read enables (power not functionality)
input [3:0] dst_addr;					// write address
input [16:0] dst;						// dst bus
input we;								// write enable

output reg [16:0] p0, p1;  				//output read ports
logic [16:0] p0_internal, p1_internal; 
integer indx;

reg we_ff;
reg [16:0] dst_addr_ff, dst_ff;

// RF0 instantiation
rf_mem RF0(.clk(clk), .r_addr(p0_addr), .w_addr(dst_addr), .wdata(dst), .we(we), .rdata(p0_internal));

// RF1 instantiation
rf_mem RF1(.clk(clk), .r_addr(p1_addr), .w_addr(dst_addr), .wdata(dst), .we(we), .rdata(p1_internal));

// Flop that stores data from one clock cycle so that comb block can use it
// in that cycle to make a decision on data forwarding
always_ff @ (negedge clk) begin
	we_ff <= we;
	dst_addr_ff <= dst_addr;
	dst_ff <= dst;
end

always_comb begin

	// if we wrote on pre cycle and the current read addr == prev write addr
	// then pass thru prev data
	// Reasoning is data would not be ready in the next clock cycle for 
	// a read, so bypass it!
	
	// RF1 handling
	if (p0_addr == 17'h00000) 
		p0 = 17'h00000;
	else if (we_ff & p0_addr==dst_addr_ff)
		p0 = dst_ff;
	else
		p0 = p0_internal;
		
	// RF2 handling
	if (p1_addr == 17'h00000) 
		p1 = 17'h00000;
	else if (we_ff & p1_addr==dst_addr_ff)
		p1 = dst_ff;
	else
		p1 = p1_internal;
end

endmodule
  

