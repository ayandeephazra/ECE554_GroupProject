//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:   
// Design Name: 
// Module Name:    spart 
// Project Name: 
// Target Devices: DE1_SOC board
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module spart(
    input clk,				// 50MHz clk
    input rst_n,			// asynch active low reset
    input iocs_n,			// active low chip select (decode address range)
    input iorw_n,			// high for read, low for write
    output tx_q_full,		// indicates transmit queue is full
    output rx_q_empty,		// indicates receive queue is empty
    input [1:0] ioaddr,		// Read/write 1 of 4 internal 8-bit registers
    inout [7:0] databus,	// bi-directional data bus
    output TX,				// UART TX line
    input RX  				// UART RX line
    );
    
    // SPART specific signals
    reg [7:0] SPART_status;
    logic [3:0] tx_num_remaining, rx_num_filled; 
    reg [7:0] DBL;
    reg [4:0] DBH;
    
    // UART specific signals
    
    logic clr_rx_rdy;		    // rx_rdy can be cleared by this or new start bit
    logic [7:0] tx_data;	    // byte to transmit
    logic trmt, rx_rdy,tx_done; // rx_rdy asserted when byte received,
                                // tx_done asserted when tranmission complete
    logic [7:0] rx_data;	    // output of the rx module's non buffered data
    logic [7:0] rx_buff_out;    // output of the rx module's 8 deep buffer
    
    // UART additional signals
    
    logic [7:0] spart_tristate_input;         // result of 4-mux within spart
    logic [7:0] low_div_buf;                  // low div buffer 
    logic [7:0] high_div_buf;                 // high div buffer 
    
    /////////////////////////////
    // Submodule Declarations //
    ///////////////////////////

    UART_tx iTX(.clk(clk), .rst_n(rst_n), .TX(TX), .tx_data(tx_data), .tx_done(tx_done),
        .databus(databus), .iorw_n(iorw_n), .iocs_n(iocs_n), .ioaddr(ioaddr), .tx_num_remaining(tx_num_remaining), 
        .tx_queue_full(tx_q_full), .DBH(DBH), .DBL(DBL));
		
    UART_rx iRX(.clk(clk), .rst_n(rst_n), .RX(RX), .rdy(rx_rdy), .clr_rdy(clr_rx_rdy), .rx_data(rx_data),
        .DBH(DBH), .DBL(DBL), .ioaddr(ioaddr), .iorw_n(iorw_n), .iocs_n(iocs_n), .rx_num_filled(rx_num_filled), 
        .rx_queue_empty(rx_q_empty), .rx_queue_full(), .rx_buff_out(rx_buff_out));
    
    // 4 way mux + tristate functionality
    assign databus = ((ioaddr==2'b00) & iorw_n & ~iocs_n) ? rx_buff_out :
                     ((ioaddr==2'b01) & iorw_n & ~iocs_n) ? SPART_status :
                     8'hzz;

        
    always_ff @ (posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            DBL <= 8'hB2;
            DBH <= 5'h01;
        end
        else if (ioaddr == 2'b10 & ~iorw_n & ~iocs_n) 
            DBL <= databus;
        else if (ioaddr == 2'b11 & ~iorw_n & ~iocs_n) 
            DBH <= databus[4:0];
    end

    assign SPART_status = {tx_num_remaining, rx_num_filled};
        		   
endmodule
