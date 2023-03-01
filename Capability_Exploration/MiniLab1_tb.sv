// task automatic enter_name (input ref logic clk, input ref logic tx_done, output ref logic [7:0] tx_data, output ref logic trmt);
// 	// Send in 'Ani<CR>' as RX input for the ML
// 	tx_data = 8'h41;
// 	trmt = 1;
// 	@ (posedge clk);
// 	trmt = 0;
// 	@ (posedge tx_done);
// 	tx_data = 8'h6e;
// 	trmt = 1;
// 	@ (posedge clk);
// 	trmt = 0;
// 	@ (posedge tx_done);
// 	tx_data = 8'h69;
// 	trmt = 1;
// 	@ (posedge clk);
// 	trmt = 0;
// 	@ (posedge tx_done);
// 	tx_data = 8'h0d;		// ENTER --> END USER INPUT 
// 	trmt = 1;
// 	@ (posedge clk);
// 	trmt = 0;
// 	@ (posedge tx_done);
// endtask


//// OLD TESTBENCH MINILAB0
module MiniLab1_tb();
	
	logic rst_n, clk;
	logic [9:0]  SW;
	logic [9:0] LEDR;
	logic TX, RX;
	//testbench uart_tx signals
	logic trmt, tx_done;
	logic [7:0] DBL, tx_data;
	logic [4:0] DBH;

	MiniLab1 ML1(.KEY({3'b00, rst_n}), .CLOCK_50(clk), .SW(SW), .LEDR(LEDR), .TX(TX),
					 .RX(RX));
	
	
	UART_tx_nq tx_tb(.clk(clk), .rst_n(rst_n), .TX(RX), .trmt(trmt), .tx_data(tx_data), 
					 .tx_done(tx_done), .DBL(DBL), .DBH(DBH));

	initial begin
		clk = 0;
		rst_n = 0;
		DBL = 8'hb2;
		DBH = 5'h1;
		trmt = 0;
		@ (negedge clk);
		rst_n = 1;

		repeat (100000) @ (posedge clk);	// Print Hello World
		
		// enter_name (clk, tx_done, tx_data, trmt);
		// Send in 'Anish<CR>' as RX input for the ML
		tx_data = 8'h41;
		trmt = 1;
		@ (posedge clk);
		trmt = 0;
		@ (posedge tx_done);
		tx_data = 8'h6e;
		trmt = 1;
		@ (posedge clk);
		trmt = 0;
		@ (posedge tx_done);
		tx_data = 8'h69;
		trmt = 1;
		@ (posedge clk);
		trmt = 0;
		@ (posedge tx_done);
		tx_data = 8'h73;
		trmt = 1;
		@ (posedge clk);
		trmt = 0;
		@ (posedge tx_done);
		tx_data = 8'h68;
		trmt = 1;
		@ (posedge clk);
		trmt = 0;
		@ (posedge tx_done);
		tx_data = 8'h0d;		// ENTER --> END USER INPUT 
		trmt = 1;
		@ (posedge clk);
		trmt = 0;
		@ (posedge tx_done);

		repeat (100000) @ (posedge clk);
		$stop();
	
	end
	
	always 
		#5 clk = ~clk;
endmodule