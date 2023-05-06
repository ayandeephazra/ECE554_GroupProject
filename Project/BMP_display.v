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

	//////////// VGA ////////// ----> PASSED OUT TO TOP LEVEL
	output		          		VGA_BLANK_N,
	output		     [7:0]		VGA_B,
	input		          		  VGA_CLK,
	output		     [7:0]		VGA_G,
	output		          		VGA_HS,
	output		     [7:0]		VGA_R,
	output		          		VGA_SYNC_N,
	output		          		VGA_VS,

  output                  end_clear   // cleared video mem on reset
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
  
  ///////////////////////////////////////
  // Instantiate VGA Timing Generator //
  /////////////////////////////////////
  VGA_timing iVGATM(.clk25MHz(VGA_CLK), .rst_n(rst_n), .VGA_BLANK_N(VGA_BLANK_N),
                    .VGA_HS(VGA_HS),.VGA_SYNC_N(VGA_SYNC_N), .VGA_VS(VGA_VS), 
					.xpix(xpix), .ypix(ypix), .addr_lead(raddr));
					
  /////////////////////////////////////
  // Instantiate 6-bit video memory //
  ///////////////////////////////////
  videoMem6bit ivm(.clk(clk), .rst_n(rst_n), .we(we),.waddr(waddr),.wdata(wdata),.raddr(raddr),.rdata(rdata));
  
  assign VGA_R = {rdata[5:4],6'b000000};
  assign VGA_G = {rdata[3:2],6'b000000}; // (ypix>9'd240) ?  8'h80 : 
  assign VGA_B = {rdata[1:0],6'b000000};
  
  //////////////////////////////////////////////
  // Instantiate Logic that determines pixel //
  // colors based on BMP placement          //
  ///////////////////////////////////////////				
  wire rem_img;	
  PlaceBMP6bit_mm iplace(.clk(clk),.rst_n(rst_n),
	.waddr(waddr),.wdata(wdata),.we(we), .add_fnt(add_fnt),.fnt_indx(fnt_indx),
	  .add_img(add_img),.rem_img(rem_img),.image_indx(image_indx), .xloc(xloc),.yloc(yloc),
        .end_clear(end_clear)); 

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
// assign rem_wr = (addr == 16'hc00b & bmp_sel);

// COMMAND PARSING LOGIC
assign xloc = XLOC;
assign yloc = YLOC;

assign add_img = (cntrl_wr) ? databus[0] : 0;
assign add_fnt = (cntrl_wr) ? ~databus[0] : 0;
assign rem_img = (cntrl_wr) ? databus[15] : 0;
assign fnt_indx = databus[5:1];
assign image_indx = databus[5:1]; // 3 is spaceship, 5 is asteroid, 7 is blackout_asteroid

endmodule