module PlaceBMP6bit_mm(clk,rst_n, waddr,wdata,we, add_fnt, add_img, rem_img, image_indx, fnt_indx, xloc, yloc, end_clear);

  input add_fnt;
  input add_img;
  input rem_img;
  input image_indx;
  input fnt_indx;               // one of 42 characters
  // 0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ =>,()
  input [9:0] xloc;
  input [8:0] yloc;
  
  input clk,rst_n;
  output reg [18:0] waddr;		// write address to videoMem
  output logic [5:0] wdata;		// write 9-bit pixel to videoMem
  output reg we;
  output logic end_clear;
    
  //////////////////////////////////////////
  // Declare any internal registers next //
  ////////////////////////////////////////
  reg [15:0] bmp_addr;				// address to local ROMs that contain images
  reg [15:0] bmp_addr_end;
  reg [13:0] font_addr;
  reg [3:0] font_x_cnt;
  reg [3:0] font_y_cnt;
  reg [9:0] xwid;					// stores x width of image
  reg [8:0] ywid_upper;				// temp register to hold upper read of ywid
  reg [18:0] waddr_wrap;			// holds when to advance linear address into videoMem
  reg [4:0] indx;					// 
  reg [5:0] font_indx;				// 1 of 42
  reg rem;							// set if removing image
  
  typedef enum reg[3:0] {RST,IDLE,ADV1,ADV2,XRD1,XRD2,YRD1,YRD2,WRT,WRT2} state_t;
  
  state_t state, nxt_state;
  
  ///////////////////////////
  // Outputs of SM follow //
  /////////////////////////  
  logic captureIndx,captureXwid,captureYwid,captureXwid2,captureYwid2;
  logic bmp_addr_inc;
  logic waddr_inc;
  logic fnt_addr_inc;
  
  ///////////////////////////
  // Internal nets follow //
  /////////////////////////
  wire [5:0] bmp_read0;
  wire [5:0] bmp_read1;
  wire [5:0] bmp_read2;			// add more for more images
  wire [5:0] bmp_read3;
  wire [5:0] bmp_read;			// muxed output from BMP ROM
  wire waddr_wrap_en;
  wire fnt_wrap;
 
  ////////////////////////////////////////////////////
  // capture x image width as read from image file //
  //////////////////////////////////////////////////  
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  xwid <= 10'h000;
	else if (captureXwid)
	  xwid <= (bmp_read<<6);
	else if (captureXwid2)
	  xwid <= xwid + bmp_read;
  
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  ywid_upper <= 9'h000;
	else if (captureYwid)
	  ywid_upper <= (bmp_read<<6);
	  
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  bmp_addr_end <= 16'h0000;
	else if (captureXwid2)
	  bmp_addr_end <= xwid + bmp_read;		// bmp_read is currently = xwidth
    else if (captureYwid2)
      bmp_addr_end <= bmp_addr_end*(ywid_upper+bmp_read) + 16'd5;	
	  
  always_ff @(posedge clk, negedge rst_n)
      if (!rst_n)
	    bmp_addr <= 16'h0000;
	  else if (captureIndx)
	    bmp_addr <= 16'h0000;
	  else if (bmp_addr_inc)
	    bmp_addr <= bmp_addr + 1;
		
  always_ff @(posedge clk, negedge rst_n)
      if (!rst_n)
	    font_addr <= 16'h0000;
	  else if (captureIndx)
	    font_addr <= 4'd13*fnt_indx;
	  else if (fnt_wrap)
	    font_addr <= font_addr + 10'd531;	// 544 - 13
	  else if (fnt_addr_inc)
	    font_addr <= font_addr + 1;
		
  always_ff @(posedge clk, negedge rst_n)
      if (!rst_n)
	    font_x_cnt <= 4'h0;
	  else if (fnt_wrap | captureIndx)
	    font_x_cnt <= 4'h0;
	  else if (fnt_addr_inc)
	    font_x_cnt <= font_x_cnt + 1;
	  
  assign fnt_wrap = (font_x_cnt==4'd13) ? 1'b1 : 1'b0;
  
  always_ff @(posedge clk, negedge rst_n)
      if (!rst_n)
	    font_y_cnt <= 4'h0;
	  else if (captureIndx)
	    font_y_cnt <= 4'h0;
	  else if (fnt_wrap)
	    font_y_cnt <= font_y_cnt + 1;
  
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  indx <= 5'h00;
	else if (captureIndx)
	  indx <= image_indx;
	  
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  font_indx <= 6'h00;
	else if (captureIndx)
	  font_indx <= fnt_indx;
	  
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  rem <= 1'b0;
	else if (captureIndx)
	  rem <= rem_img;
		
  always_ff @(posedge clk, negedge rst_n)
      if (!rst_n)
	    waddr <= 18'h00000;
	  else if (end_clear)
		waddr <= 18'h00000;
	  else if (captureIndx)
	    waddr <= yloc*10'd640 + xloc;
	  else if (waddr_wrap_en)
	    waddr <= waddr + (18'd641 - xwid);
	  else if (fnt_wrap)
	    waddr <= waddr + 18'd628;
	  else if (waddr_inc)
	    waddr <= waddr + 1;

  always_ff @(posedge clk, negedge rst_n)
      if (!rst_n)
	    waddr_wrap <= 18'h00000;
	  else if (captureYwid)
	    waddr_wrap <= waddr + (xwid - 9'h001);
	  else if (waddr_wrap_en)
	    waddr_wrap <= waddr_wrap + 18'd640;
		
  assign waddr_wrap_en = (waddr==waddr_wrap) ? 1'b1 : 1'b0;
		
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  state <= RST; //IDLE;
	else
	  state <= nxt_state;
  
  always_comb begin
    nxt_state = state;
    captureIndx = 0;
	captureXwid = 0;
	captureYwid = 0;
	captureXwid2 = 0;
	captureYwid2 = 0;
	bmp_addr_inc = 0;
	waddr_inc = 0;
	fnt_addr_inc = 0;
	we = 0;
	wdata = 9'hxxx;
	end_clear = 0;

	case (state)
	  RST: begin
		wdata =  6'h00;	
		we = 1'b1;
		if (waddr<19'd307199) begin
		  waddr_inc = 1;
		end else begin
		  end_clear = 1;
		  nxt_state = IDLE;
		end
	  end
	  IDLE: begin
	    if (add_img | rem_img) begin
		  captureIndx = 1;
		  nxt_state = ADV1;
		end else if (add_fnt) begin
		  captureIndx = 1;
		  nxt_state = ADV2;
		end
	  end
	  ADV1: begin	// this state is about advancing bmp_address
	    bmp_addr_inc = 1;
		nxt_state = XRD1;
	  end
	  ADV2: begin	// this state is about advancing bmp_address
	    fnt_addr_inc = 1;
		nxt_state = WRT2;
	  end
	  XRD1: begin
	    captureXwid = 1;
		bmp_addr_inc = 1;
		nxt_state = XRD2;
	  end
	  XRD2: begin
	    captureXwid2 = 1;
		bmp_addr_inc = 1;
		nxt_state = YRD1;
	  end
	  YRD1: begin
	    captureYwid = 1;
		bmp_addr_inc = 1;
		nxt_state = YRD2;
	  end
	  YRD2: begin
	    captureYwid2 = 1;
		bmp_addr_inc = 1;
		nxt_state = WRT;
	  end
	  WRT: begin
	    if (bmp_addr<bmp_addr_end) begin
		  bmp_addr_inc = 1;
		  wdata = (rem) ? 6'h00 : bmp_read;
		  we = (bmp_read==6'h024) ? 1'b0 : 1'b1;	// 128,64,32 is treated as transparent
		  waddr_inc = 1;
		end else
		  nxt_state = IDLE;
	  end
	  WRT2: begin
	    if ((font_y_cnt==4'd15) && (fnt_wrap))
		  nxt_state = IDLE;
		else if (fnt_wrap) begin
		  nxt_state = ADV2;
		end else begin
		  fnt_addr_inc = 1;
		  wdata = bmp_read;
		  we = (bmp_read==6'h024) ? 1'b0 : 1'b1;	// 128,64,32 is treated as transparent
		  waddr_inc = 1;
		end
	  end
	  default: nxt_state = IDLE;
	endcase
	  
  end
  
  /////////////////////////////////
  // BMP ROMs and mux are below //
  ///////////////////////////////.. indx = [6:1] = 000001 = spaceship
  //						= 000011 = blackout	=> 7
  //						= meteor, anything else
  BMP_ROM_Font  iROM0(.clk(clk),.addr(font_addr),.dout(bmp_read0));
  BMP_ROM_spaceship iROM1(.clk(clk),.addr(bmp_addr),.dout(bmp_read1));
  BMP_ROM_asteroid iROM2(.clk(clk),.addr(bmp_addr),.dout(bmp_read2));

  assign bmp_read = (fnt_addr_inc) ? bmp_read0 :
	  	    (indx === 5'b00001) ? bmp_read1 :
			//(indx === 5'b00011) ? bmp_read3 :
	
		    			  bmp_read2;
  
endmodule