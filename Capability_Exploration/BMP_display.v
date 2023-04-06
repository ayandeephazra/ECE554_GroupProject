module BMP_display(
  input clk,
  input rst_n,
  input pll_locked,

  input bmp_sel,
  input [15:0] addr,
  input [15:0] databus,
  
  input [15:0] mm_addr,
  input mm_we,
  input [15:0] mm_wdata,
  
  //output reg [18:0] waddr,		// write address to videoMem
  //output logic [5:0] wdata,		// write 9-bit pixel to videoMem
  //output reg we,

	//////////// VGA ////////// ----> PASSED OUT TO TOP LEVEL
	output		          		VGA_BLANK_N,
	output		     [7:0]		VGA_B,
	input		          		  VGA_CLK,
	output		     [7:0]		VGA_G,
	output		          		VGA_HS,
	output		     [7:0]		VGA_R,
	output		          		VGA_SYNC_N,
	output		          		VGA_VS
);

  ////////////////////////////////////
  // internal nets for connections //
  //////////////////////////////////
  // wire rst_n;						// synchronized global reset signal
  // wire clk;							// 50MHz clock from PLL
  // wire pll_locked;					// PLL is locked on reference clock
  wire [9:0] xpix;					// current X coordinate of VGA
  wire [8:0] ypix;					// current Y coordinate of VGA
  wire [18:0] raddr;				// address into videoMem for reads
  wire [5:0] rdata;					// 6-bit color
  wire [18:0] waddr;				// write address to videoMem
  wire [5:0] wdata;					// write data to videoMem
  wire [4:0] image_indx;
  wire [9:0] xloc;
  wire [8:0] yloc;
  wire we;
  wire add_img,add_fnt;
  wire [5:0] fnt_indx;
  
  reg [18:0] count;					// generate a pulse on add_img
  
  // ////////////////////////////////////////////////////////
  // // Instantiate PLL to generate clk and 25MHz VGA_CLK //
  // //////////////////////////////////////////////////////
  // PLL iPLL(.refclk(REF_CLK), .rst(~RST_n),.outclk_0(clk),.outclk_1(VGA_CLK),
  //          .locked(pll_locked));
 
  // /////////////////////////////////////
  // // instantiate rst_n synchronizer //
  // ///////////////////////////////////
  // rst_synch iRST(.clk(clk),.RST_n(RST_n), .pll_locked(pll_locked), .rst_n(rst_n));


  // //assign LEDR = 10'h3FF;
 
  ///////////////////////////////////////
  // Instantiate VGA Timing Generator //
  /////////////////////////////////////
  VGA_timing iVGATM(.clk25MHz(VGA_CLK), .rst_n(rst_n), .VGA_BLANK_N(VGA_BLANK_N),
                    .VGA_HS(VGA_HS),.VGA_SYNC_N(VGA_SYNC_N), .VGA_VS(VGA_VS), 
					.xpix(xpix), .ypix(ypix), .addr_lead(raddr));
					
  /////////////////////////////////////
  // Instantiate 6-bit video memory //
  ///////////////////////////////////
  videoMem6bit ivm(.clk(clk),.we(we),.waddr(waddr),.wdata(wdata),.raddr(raddr),.rdata(rdata));
  
  assign VGA_R = {rdata[5:4],6'b000000};
  assign VGA_G = {rdata[3:2],6'b000000}; //(ypix>9'd240) ?  8'h80 : 
  assign VGA_B = {rdata[1:0],6'b000000};
  
  //////////////////////////////////////////////
  // Instantiate Logic that determines pixel //
  // colors based on BMP placement          //
  ///////////////////////////////////////////					
  PlaceBMP6bit_mm iplace(.clk(clk),.rst_n(rst_n),.mm_addr(mm_addr),.mm_we(mm_we),.mm_wdata(mm_wdata),
	.waddr(waddr),.wdata(wdata),.we(we));
  
  //,.add_fnt(add_fnt),.fnt_indx(fnt_indx),
  //         .add_img(add_img),.rem_img(1'b0),.image_indx(image_indx),
  //         .xloc(xloc),.yloc(yloc),.waddr(waddr),.wdata(wdata),.we(we));

  ///////////////////////////////////////////////
  // What follows is a super cheese ball method
  // of writing a few characters and images
  // using the signals to PlaceBMP.  This would
  // best be done through memory mapping PlaceBMP
  // to the databus of your processor and using
  // your processor code to write images and characters
  ///////////////////////////////////////////////
  // always @(posedge clk, negedge rst_n)
  //   if (!rst_n)
	//   count <= 19'h00000;
	// else if (~&count)
	//   count <= count + 1;
	  
  // assign add_fnt = (count==19'h00005) ? 1'b1 : 
  //                  (count==19'h01005) ? 1'b1 :
	// 			   (count==19'h02005) ? 1'b1 :
	// 			   (count==19'h03005) ? 1'b1 :
	// 			   (count==19'h04005) ? 1'b1 :
	// 			   (count==19'h05005) ? 1'b1 :
	// 			   1'b0;
				   
  // assign fnt_indx = (count==19'h00005) ? 6'd22 : // M
  //                  (count==19'h01005) ? 6'd36 :  // ' '
	// 			   (count==19'h02005) ? 6'd31 :	 // V
	// 			   (count==19'h03005) ? 6'd28 :	 // S
	// 			   (count==19'h04005) ? 6'd36 :  // ' '
	// 			   (count==19'h05005) ? 6'd11 :  // B 
	// 			   1'b0;
				   
  // assign add_img = ((count==19'h07000) || (count==19'h7FFFE)) ? 1'b1 : 1'b0;
  // assign image_indx = (count[18]) ? 5'h02 : 5'h01;
  // assign xloc = (count==19'h00005) ? 10'd321 :
  //               (count==19'h01005) ? 10'd269 :
	// 			(count==19'h02005) ? 10'd282 :
	// 			(count==19'h03005) ? 10'd295 :
	// 			(count==19'h04005) ? 10'd308 :
	// 			(count==19'h05005) ? 10'd256 :
  //               (count[18]) ? 10'h180 : 10'h40;

reg [9:0] XLOC;
reg [8:0] YLOC;
wire cntrl_wr;

always @ (posedge clk, negedge rst_n) begin
  if (!rst_n) begin
    XLOC <= 10'h0;
    YLOC <= 9'h0;
  end
  else if (addr == 16'hc008 & bmp_sel)
    XLOC <= databus[9:0];
  else if (addr == 16'hc009 & bmp_sel)
    YLOC <= databus[8:0];    
end


assign cntrl_wr = (addr == 16'hc00a & bmp_sel);


// COMMAND PARSING LOGIC
assign xloc = XLOC;
assign yloc = YLOC;

assign add_img = (cntrl_wr) ? databus[0] : 0;
assign add_fnt = (cntrl_wr) ? ~databus[0] : 0;
assign fnt_indx = databus[6:1];
assign image_indx = databus[6:1];

endmodule
