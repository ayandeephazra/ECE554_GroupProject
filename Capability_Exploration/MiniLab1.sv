module MiniLab1 (KEY, CLOCK_50, SW, LEDR, TX, RX);
	
	input [3:0] KEY; 		// key/reset
	input CLOCK_50;			// clock
	input [9:0] SW;			// switch
	// Registers for interfacing with peripherals on FPGA
	output [9:0] LEDR;		// debug process
	output TX;				// UART TX line
    input RX; 				// UART TX line
	
	// internal signals for modified cpu
	logic rst_n;
	logic mm_we, mm_re;
	logic [15:0] wdata, rdata, addr;
	
	reg [9:0] LEDR_reg;
	assign LEDR = LEDR_reg;

	// SPART interface
	wire [7:0] databus;
	logic iorw_n, iocs_n, rx_q_empty, tx_q_full;

	////////////////// REMOVE
	logic [7:0] status;
	
	// FF logic for LEDR ---- DEBUG
	always_ff @ (negedge CLOCK_50) begin
	
		// reset behavior, when KEY0 is pressed it should blank the LED's
		if(!rst_n)
			LEDR_reg <= 10'h000;
			
		// if addr is of write and a memory read is enabled, load into LEDR
		// if (mm_we & addr==16'hc000) begin
		// 	// just take low 10 bits for LEDR
		// 	LEDR_reg <= wdata[9:0];
			
		// end
		else
			LEDR_reg <= status;
	end
	
	// combinational logic for SW
	always_comb begin
		// If you have to use SW, then zero extend to meet rdata's bitwidth
		// 16'ha5a5 is a junk value for debug, should not affect remaining program
		rdata = (mm_re & (addr==16'hc001)) ? {{6{1'b0}},SW} :
				(mm_re & (addr==16'hc004 | addr==16'hc005)) ? databus : 
				16'ha5a5; 

		iocs_n = ~((addr==16'hc004 | addr==16'hc005 | addr==16'hc006 | addr==16'hc007) & (mm_we | mm_re));		// selects C004/5/6/7
		iorw_n = (~iocs_n) & mm_re;

		bmp_sel = ((addr==16'hc008 | addr==16'hc009 | addr==16'hc00A) & mm_we)
		// bmp_enable ---> BMP_display wil read from databus. do stuff
	end
	
	//rst_synch instantiation
	rst_synch rst_synch1(.RST_n(KEY[0]), .rst_n(rst_n), .clk(CLOCK_50));
	
	// modified cpu instantiation
	cpu cpu1(.clk(CLOCK_50), .rst_n(rst_n), .wdata(wdata), .mm_we(mm_we), .addr(addr), .mm_re(mm_re), .rdata(rdata));

	assign databus = (~iorw_n) ? wdata[7:0] : 8'hzz;	// infer tri state for driving bus from proc to spart

	spart spart1(.clk(CLOCK_50), .rst_n(rst_n), .iocs_n(iocs_n), .iorw_n(iorw_n), .tx_q_full(tx_q_full), .rx_q_empty(rx_q_empty),
				 .ioaddr(addr[1:0]), .databus(databus), .TX(TX), .RX(RX));
	
	BMP_display iBMP();


endmodule