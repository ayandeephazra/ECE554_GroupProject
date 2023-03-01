module spart_tb ();

     logic clk, rst_n;

    // utx signals
    logic trmt, tx_done, iorw_n;
    logic tx_q_full;
    logic [7:0] tx_data;
    logic [7:0] databus_tx;

    // urx signals
    logic rdy, clr_rdy, rx_q_empty;
    logic [7:0] rx_data;

    // SPART
    logic utx_spart, spart_urx;    
    logic iocs_n;
    logic [1:0] ioaddr;
    wire [7:0] databus;
    logic [7:0] DBL;
    logic [4:0] DBH;

    // other signals
    logic tb_drive_databus;
    
    
    UART_tx_nq ext_utx(.clk(clk), .rst_n(rst_n), .TX(utx_spart), .trmt(trmt), .tx_data(tx_data),
                .tx_done(tx_done), .DBH(DBH), .DBL(DBL));

    spart iDUT(.clk(clk), .rst_n(rst_n), .iocs_n(iocs_n), .iorw_n(iorw_n),
                .tx_q_full(tx_q_full), .rx_q_empty(rx_q_empty), .ioaddr(ioaddr),
                .databus(databus), .TX(spart_urx), .RX(utx_spart));

    UART_rx_nq ext_urx(.clk(clk), .rst_n(rst_n), .RX(spart_urx), .rdy(rdy), .rx_data(rx_data),
                .clr_rdy(clr_rdy), .DBH(DBH), .DBL(DBL));

    localparam logic [7:0] tx_data_array [0:15] = {8'h11, 8'h22, 8'h33, 8'h44, 8'h55, 8'h66, 8'h77, 8'h88,
		8'h36, 8'h00, 8'hb2, 8'h01, 8'h2c, 8'h0a, 8'h58, 8'h14};
    
    integer  i;

    assign databus = (tb_drive_databus) ? tx_data_array[i] : 8'hzz;
    
    initial begin
    
		///////////////////////////////////////////////////////////////////////
		// 13'h01b2 default baud rate to check TX->SPART->RX functionality  //
		/////////////////////////////////////////////////////////////////////
		
        clk = 0;
        rst_n = 0;
        clr_rdy = 0;
        @ (posedge clk);
        rst_n = 1;
        trmt = 0;
        DBL = 8'hb2;
        DBH = 5'b01;
		$display("test for default Baud 13'h01b2");
        ////////////////////// UTX --> SPART ////////////////////

        tb_drive_databus = 0;
        ioaddr = 2'b00;
        iocs_n = 0;
        iorw_n = 1;

        for (i = 0; i < 8; i = i + 1) begin
            // send 8 bytes and fill up rx circular buffer
            tx_data = tx_data_array[i];

            trmt = 1;
            @ (posedge clk);
            trmt = 0;
            
            @ (posedge tx_done);

            /////// CHECK DATABUS
        end
		
		assert (iDUT.SPART_status == 8'h80) $display("PASS: SPART_status fills up correctly for default Baud 13'h01b2");
            else $error("SPART_status fills up incorrectly for default Baud 13'h01b2");

        repeat (5000) @ (posedge clk);      // Catch breath

        ////////////////////// SPART --> URX ////////////////////

        ioaddr = 2'b00;     // TX/RX Mode
        iorw_n = 0;         // Output data from spart --> ext_urx
        tb_drive_databus = 1;
        // set iocs_n high in order to fill up the internal TX buffer (so spart yields databus)
        // once the buffer is full. Set iocs_n back low and begin transferring
        for (i = 0; i < 8; i = i + 1) begin

            @ (posedge clk);
            iocs_n = 1;
            @ (posedge clk);
            iocs_n = 0;
        end
        
        // start transmitting
        iorw_n = 1;
  
        for (i = 0; i < 8; i = i + 1) begin
            @ (posedge rdy);
            assert (rx_data == tx_data_array[i]) $display(i, ": rx_data PASS for default Baud 13'h01b2");
            else $error(i, ": rx_data FAIL for default Baud 13'h01b2");
        end
        
        repeat (100000) @ (posedge clk);
        
        ///////////////////////////////////////////////////////////////
		// 13'h0036 baud rate to check TX->SPART->RX functionality  //
		/////////////////////////////////////////////////////////////
        
		$display("test for variable Baud 13'h0036");
        DBL = 8'h36;
        DBH = 5'b00;
  
		//rst_n = 0;
        //clr_rdy = 0;
        tb_drive_databus = 1;
        i = 8;                  // low value 0x36
        ioaddr = 2'b10;
        iorw_n = 0;     
        
        @ (posedge clk);
        tb_drive_databus = 0;
        iorw_n = 1;
        @ (posedge clk);
        tb_drive_databus = 1;
        i = 9;                  // high value 0x00
        ioaddr = 2'b11;
        iorw_n = 0;

        repeat(5000) @ (posedge clk);
        //rst_n = 1;
        trmt = 0;
		
		tb_drive_databus = 0;
        ioaddr = 2'b00;
        iocs_n = 0;
        iorw_n = 1;
        

        for (i = 0; i < 8; i = i + 1) begin
            // send 8 bytes and fill up rx circular buffer
            tx_data = tx_data_array[i];

            trmt = 1;
            @ (posedge clk);
            trmt = 0;
            @ (posedge tx_done);

            /////// CHECK DATABUS
        end
		
		assert (iDUT.SPART_status == 8'h80) $display("PASS: SPART_status fills up correctly for default Baud 13'h0036");
            else $error("SPART_status fills up incorrectly for default Baud 13'h0036");

        repeat (5000) @ (posedge clk);      // Catch breath

        ////////////////////// SPART --> URX ////////////////////

        // send the same 8 bytes from spart to urx
        ioaddr = 2'b00;     	// TX/RX Mode
        iorw_n = 0;        	 	// Output data from spart --> ext_urx
        tb_drive_databus = 1;
        iocs_n = 0;

        for (i = 0; i < 8; i = i + 1) begin

            @ (posedge clk);
            iocs_n = 1;
            @ (posedge clk);
            iocs_n = 0;
        
            // set iocs_n high in order to fill up the internal TX buffer (so spart yields databus)
            // once the buffer is full. Set iocs_n back low and begin transferring
        end
        
        // start transmitting
        iorw_n = 1;
        for (i = 0; i < 8; i = i + 1) begin
            @ (posedge rdy);
            assert (rx_data == tx_data_array[i]) $display(i, ": rx_data PASS for variable Baud 13'h0036");
            else $error(i, ": rx_data FAIL for variable Baud 13'h0036");
        end
        
        repeat (100000) @ (posedge clk);
        
        ///////////////////////////////////////////////////////////////
		// 13'h0a2c baud rate to check TX->SPART->RX functionality  //
		/////////////////////////////////////////////////////////////
        
		$display("test for variable Baud 13'h0a2c");
        DBL = 8'h2c;
        DBH = 5'h0a;
  
		//rst_n = 0;
        //clr_rdy = 0;
        tb_drive_databus = 1;
        i = 12;                  // low value 0x58
        ioaddr = 2'b10;
        iorw_n = 0;     
        
        @ (posedge clk);
        tb_drive_databus = 0;
        iorw_n = 1;
        @ (posedge clk);
        tb_drive_databus = 1;
        i = 13;                  // high value 0x14
        ioaddr = 2'b11;
        iorw_n = 0;

        repeat(5000) @ (posedge clk);
        trmt = 0;
		
		tb_drive_databus = 0;
        ioaddr = 2'b00;
        iocs_n = 0;
        iorw_n = 1;
        

        for (i = 0; i < 8; i = i + 1) begin
            // send 8 bytes and fill up rx circular buffer
            tx_data = tx_data_array[i];

            trmt = 1;
            @ (posedge clk);
            trmt = 0;
            @ (posedge tx_done);

            /////// CHECK DATABUS
        end

		assert (iDUT.SPART_status == 8'h80) $display("PASS: SPART_status fills up correctly for default Baud 13'h0a2c");
            else $error("SPART_status fills up incorrectly for default Baud 13'h0a2c");

        repeat (5000) @ (posedge clk);      // Catch breath

        ////////////////////// SPART --> URX ////////////////////

        // send the same 8 bytes from spart to urx
        ioaddr = 2'b00;     	// TX/RX Mode
        iorw_n = 0;        	 	// Output data from spart --> ext_urx
        tb_drive_databus = 1;
        iocs_n = 0;

        for (i = 0; i < 8; i = i + 1) begin

            @ (posedge clk);
            iocs_n = 1;
            @ (posedge clk);
            iocs_n = 0;
        
            // set iocs_n high in order to fill up the internal TX buffer (so spart yields databus)
            // once the buffer is full. Set iocs_n back low and begin transferring
        end
        
        // start transmitting
        iorw_n = 1;
        for (i = 0; i < 8; i = i + 1) begin
            @ (posedge rdy);
            assert (rx_data == tx_data_array[i]) $display(i, ": rx_data PASS for variable Baud 13'h0036");
            else $error(i, ": rx_data FAIL for variable Baud 13'h0036");
        end
    
        ///////////////////////////////////////////////////////////////
		// Interleaved Reads and Writes to check functionality      //
		/////////////////////////////////////////////////////////////
        repeat (100000) @ (posedge clk);
        
        // Cannot reset, must set default baud rate using tb driven databus
        DBL = 8'hb2;
        DBH = 5'h01;
  
        tb_drive_databus = 1;
        i = 10;                  // low value 0x36
        ioaddr = 2'b10;
        iorw_n = 0;     
        
        @ (posedge clk);
        tb_drive_databus = 0;
        iorw_n = 1;
        @ (posedge clk);
        tb_drive_databus = 1;
        i = 11;                  // high value 0x00
        ioaddr = 2'b11;
        iorw_n = 0;

        repeat(5000) @ (posedge clk);
        //rst_n = 1;
        trmt = 0;
        tb_drive_databus = 1;
        clr_rdy = 0;
        @ (posedge clk);
        trmt = 0;
        DBL = 8'hb2;
        DBH = 5'b01;
        @ (posedge clk);

        ////////////////////// UTX --> SPART ////////////////////

        tb_drive_databus = 0;
         ioaddr = 2'b00;
         iocs_n = 0;
         // fill up iRX queue
         iorw_n = 0;
         for (i = 0; i < 3; i = i + 1) begin
             // send 4 bytes and fill up rx circular buffer
            tx_data = tx_data_array[i];
             trmt = 1;
            @ (posedge clk);
            trmt = 0;
            @ (posedge tx_done);
            $display("tx done");
         end
         // INTERLEAVE READS/WRITES
		 assert (iDUT.SPART_status == 8'h40) $display("PASS: SPART_status fills up correctly for default Baud 13'h01b2");
            else $error("SPART_status fills up incorrectly for default Baud 13'h01b2");

        @ (posedge clk);
        iocs_n = 0; 
		iorw_n = 1;
        @ (posedge clk);
         // @ (posedge rx_q_empty)
        for (i = 0; i<3; i = i + 1) begin
            // Read 4x from RX Queue --- CHECK DATABUS
            
            @ (posedge rdy);
                
            assert (rx_data == tx_data_array[i]) $display(i, ": rx_data PASS for Interleaved Case");
            else $error(i, ": rx_data FAIL for  Interleaved Case");
        end
         repeat (2) @ (posedge clk);
         iocs_n = 1; iorw_n = 0;

         repeat (20000) @ (posedge clk); 

         // 4 Writes
        tb_drive_databus = 1;
        iorw_n = 0;
        for (i = 0; i < 4; i = i + 1) begin
             @ (posedge clk);
             iocs_n = 1;         // in order to drive the databus (because iorw_n is low)
             @ (posedge clk);
             iocs_n = 0;         // allow the spart to begin transmitting the queued data
        end
        
        for (i = 0; i<4; i = i + 1) begin
        @ (posedge rdy);
        $display("tx done");
        end

        ////////////////////// SPART --> URX ////////////////////

        // send the same 8 bytes from spart to urx
        ioaddr = 2'b00;     	// TX/RX Mode
        iorw_n = 0;        	 	// Output data from spart --> ext_urx
        tb_drive_databus = 1;
        iocs_n = 0;

        for (i = 0; i < 8; i = i + 1) begin

            @ (posedge clk);
            iocs_n = 1;
            @ (posedge clk);
            iocs_n = 0;
        
            // set iocs_n high in order to fill up the internal TX buffer (so spart yields databus)
            // once the buffer is full. Set iocs_n back low and begin transferring
        end
        
        // start transmitting
        iorw_n = 1;
        repeat (8) @ (posedge rdy);

        // loop around in tx queue
        iorw_n = 0;
        for (i = 8; i < 10; i = i + 1) begin
            @ (posedge clk);
            iocs_n = 1;
            @ (posedge clk);
            iocs_n = 0;
        end

        // start transmitting
        iorw_n = 1;
        for (i = 0; i < 2; i = i + 1) begin
            @ (posedge rdy);
            assert (rx_data == tx_data_array[i]) $display(i, ": rx_data PASS for interleaved case");
            else $error(i, ": rx_data FAIL for interleaved case");
        end


        $stop;
    end


    always
        #5 clk = ~clk;


endmodule