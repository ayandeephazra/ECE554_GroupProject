module gp_test();


//////////////////////
// Instantiate G //
////////////////////

// we just leave the output signals at Z because they can viewed from 
// within cpu module
//cpu iCPU(.clk(clk), .rst_n(rst_n), .rdata(rdata), .wdata(), .mm_we(), .addr(), .mm_re());

GroupProject iGP(

	//////////// CLOCK //////////
			          		.CLOCK2_50(),
			          		.CLOCK3_50(),
			          		.CLOCK4_50(),
			          		.CLOCK_50(clk),

	//////////// KEY //////////
	 		     		.RST_n(rst_n),

	//////////// LED //////////
			     	.LEDR(),

	//////////// SW //////////
			     		.SW(),

	//////////// VGA //////////
		          		.VGA_BLANK_N(),
			.VGA_B(),
		          		.VGA_CLK(vga_clk),
		.VGA_G(),
	          		.VGA_HS(),
			     	.VGA_R(),
			          		.VGA_SYNC_N(),
			          		.VGA_VS(),

	//////////// GPIO_1, GPIO_1 connect to GPIO Default //////////
			.GPIO(GPIO)
);

wire [35:0] GPIO;
reg clk,rst_n, vga_clk;
logic [15:0] rdata;


initial begin
  clk = 0;
  rst_n = 0;
  @ (posedge clk);
  rst_n = 1;
  rdata = 16'haaaa;
  repeat (10000000) @ (posedge clk);
  $stop();
  
end
  
always begin
  #5 clk = ~clk;
  #10 vga_clk = ~vga_clk;
 end
  
endmodule
