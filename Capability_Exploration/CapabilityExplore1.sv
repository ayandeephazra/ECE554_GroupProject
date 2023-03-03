module CapabilityExplore1 (KEY, CLOCK_50, SW, LEDR, TX, RX, VGA_BLANK_N, VGA_B, VGA_CLK, VGA_G, VGA_HS, VGA_R, VGA_SYNC_N, VGA_VS);
	
	input [3:0] KEY; 		// key/reset
	input CLOCK_50;			// clock
	input [9:0] SW;			// switch
	// Registers for interfacing with peripherals on FPGA
	output [9:0] LEDR;		// debug process
	output TX;				// UART TX line
    input RX; 				// UART TX line

	//////////////// VGA STUFF ///////////////////
	output		          		VGA_BLANK_N;
	output		     [7:0]		VGA_B;
	output		          		VGA_CLK;
	output		     [7:0]		VGA_G;
	output		          		VGA_HS;
	output		     [7:0]		VGA_R;
	output		          		VGA_SYNC_N;
	output		          		VGA_VS;

	
	// internal signals for modified cpu
	logic rst_n;
	logic mm_we, mm_re;
	logic [15:0] wdata, rdata, addr;
	
	reg [9:0] LEDR_reg;
	assign LEDR = LEDR_reg;

	// SPART interface
	wire [15:0] databus;
	logic iorw_n, iocs_n, rx_q_empty, tx_q_full;

	// BMP
	logic bmp_sel;

	// PLL/rst_synch
	logic pll_locked;

	////////////////// REMOVE
	logic [7:0] status;
	
	// FF logic for LEDR ---- DEBUG
	always_ff @ (negedge CLOCK_50) begin
	
		// reset behavior, when KEY0 is pressed it should blank the LED's
		if(!rst_n)
			LEDR_reg <= 10'h000;
		else
			LEDR_reg <= status;		// REPLACE FOR DEBUG
	end
	
	// Memory Mappings
	always_comb begin
		rdata = (mm_re & (addr==16'hc001)) ? {{6{1'b0}},SW} :
				(mm_re & (addr==16'hc004 | addr==16'hc005)) ? databus : 
				16'ha5a5; 

		iocs_n = ~((addr==16'hc004 | addr==16'hc005 | addr==16'hc006 | addr==16'hc007) & (mm_we | mm_re));		// selects C004/5/6/7
		iorw_n = (~iocs_n) & mm_re;

		bmp_sel = ((addr==16'hc008 | addr==16'hc009 | addr==16'hc00A) & mm_we);
	end

	// assign databus = (~iorw_n | bmp_sel) ? wdata[7:0] : 8'hzz;	// infer tri state for driving bus from proc to spart
	assign databus = (mm_we) ? wdata : 8'hzz;	// infer tri state for driving bus from proc to spart

	////////////////////////////////////////////////////////
	// Instantiate PLL to generate clk and 25MHz VGA_CLK //
	//////////////////////////////////////////////////////
	PLL iPLL(.refclk(CLOCK_50), .rst(~KEY[0]),.outclk_0(clk),.outclk_1(VGA_CLK), .locked(pll_locked));

		
	/////////////////////////////////////
	// instantiate rst_n synchronizer //
	///////////////////////////////////
	rst_synch iRST(.clk(clk),.RST_n(KEY[0]), .pll_locked(pll_locked), .rst_n(rst_n));
	
	// /////////////////////////////////////
    // // instantiate rst_n synchronizer //
    // ///////////////////////////////////
	// rst_synch rst_synch1(.RST_n(KEY[0]), .rst_n(rst_n), .clk(CLOCK_50));
	
	/////////////////////////////////////
    // instantiate cpu topl level mod //
    ///////////////////////////////////
	cpu cpu1(.clk(clk), .rst_n(rst_n), .wdata(wdata), .mm_we(mm_we), .addr(addr), .mm_re(mm_re), .rdata(rdata));

	//////////////////////////////////////////////////
  	// Instantiate Logic that includes internal    //
  	// RX -> TX in that particular order          //
  	///////////////////////////////////////////////	
	// spart spart1(.clk(clk), .rst_n(rst_n), .iocs_n(iocs_n), .iorw_n(iorw_n), .tx_q_full(tx_q_full), .rx_q_empty(rx_q_empty),
	// 			 .ioaddr(addr[1:0]), .databus(databus[7:0]), .TX(TX), .RX(RX));

	////////////////////////////////
    // instantiate BMP_display	 //
    //////////////////////////////
	BMP_display iBMP(.clk(clk), .rst_n(rst_n), .pll_locked(pll_locked), .bmp_sel(bmp_sel), .addr(addr), .databus(databus),
					.VGA_BLANK_N(VGA_BLANK_N), .VGA_B(VGA_B), .VGA_CLK(VGA_CLK), .VGA_G(VGA_G), .VGA_HS(VGA_HS), .VGA_R(VGA_R), .VGA_SYNC_N(VGA_SYNC_N), .VGA_VS(VGA_VS));

	

endmodule