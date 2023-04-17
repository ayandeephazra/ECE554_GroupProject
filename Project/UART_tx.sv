module UART_tx(clk,rst_n,TX,tx_data,tx_done, databus, iorw_n, iocs_n, ioaddr, 
    tx_num_remaining, tx_queue_full, DBH, DBL);

input clk,rst_n;		// clock and active low reset
input [7:0] tx_data;	// byte to transmit
output TX, tx_done;		// tx_done asserted when transmission complete

// new inputs
input [7:0] databus;
input iorw_n;
input iocs_n;
input [1:0] ioaddr;
input logic [7:0] DBL;
input logic [4:0] DBH;

// new outputs
output [3:0] tx_num_remaining;
output tx_queue_full;

reg [8:0] shift_reg;	// 1-bit wider to store start bit
reg [3:0] bit_cnt;		// bit counter
reg [12:0] baud_cnt;	// baud rate counter (50MHz/19200) = div of 2604
reg tx_done;			// tx_done will be a set/reset flop

reg load, trnsmttng;	// assigned in state machine

logic [7:0] tx_buff_out;
logic tx_queue_empty;

logic trmt;   // trmt tells TX section to transmit tx_data
logic trmt_ff, load_ff, load_ff2, iocs_n_ff;
wire shift;

// new signals to add cqueue functionality

logic [7:0] tx_queue [0:7];
logic [3:0] tx_read_ptr, tx_write_ptr; 

////////////////////////////////
// Define state as enum type //
//////////////////////////////
typedef enum reg {IDLE,TX_STATE} state_t;
state_t state,nxt_state;

////////////////////////////
// Infer state flop next //
//////////////////////////
always @(posedge clk or negedge rst_n)
  if (!rst_n)
    state <= IDLE;
  else
    state <= nxt_state;
    
//////////////////////////////////
//  Flop controlling write ptr  //
////////////////////////////////
always @(posedge clk or negedge rst_n)
  if (!rst_n) begin
    tx_write_ptr <= 4'b0000;
  end
  else if (~tx_queue_full & ioaddr == 2'b00 & ~iorw_n & ~iocs_n) begin
    tx_queue[tx_write_ptr[2:0]] <= databus;
    tx_write_ptr <= tx_write_ptr + 1;
  end
  
  /////////////////////////////////
//  Flop controlling read ptr  //
///////////////////////////////

always_ff @(posedge clk or negedge rst_n)
  if (!rst_n)
    tx_read_ptr <= 4'b0000;
  // condition to allow buffer data to leave buffer 
  // else if (~tx_queue_empty & ~iocs_n_ff & trmt)   ///// REMOVE TRMT_FF ????
  else if (trmt)
    tx_read_ptr <= tx_read_ptr + 1;

assign tx_buff_out = tx_queue[tx_read_ptr[2:0]];

// Delay trmt by 1 cycle to align with low chip select
always_ff @(posedge clk, negedge rst_n)
  if (!rst_n)
    iocs_n_ff <= 0;
  else
    iocs_n_ff <= iocs_n;
  
// Delay load by 2 cycle to align with loading into buff out
always_ff @(posedge clk, negedge rst_n)
  if (!rst_n) begin
    load_ff <= 0;
    load_ff2 <= 0;
  end
  else begin
    load_ff <= load;
    load_ff2 <= load_ff;
  end
  
assign tx_queue_full = (tx_write_ptr - tx_read_ptr == 4'b1000);  
assign tx_queue_empty = (tx_read_ptr - tx_write_ptr == 4'b0000);
assign tx_num_remaining = 4'b1000 - (tx_write_ptr[3:0] - tx_read_ptr[3:0]);

////////////////////////////////////////////////////////////
// State machine to pulse trmt on negedge tx_queue_empty //
//////////////////////////////////////////////////////////

typedef enum logic [1:0] {IDLE2,TRMT,WAIT} state_t2;
state_t2 state2,nxt_state2;

always @(posedge clk or negedge rst_n)
  if (!rst_n)
    state2 <= IDLE2;
  else
    state2 <= nxt_state2;

always_comb begin
  trmt = 0;
  nxt_state2 = state2;
  case (state2)
    IDLE2:
      if (~tx_queue_empty) begin
        trmt = 1;
        nxt_state2 = TRMT;
      end
    TRMT:
      nxt_state2 = WAIT;
    WAIT:
      if (bit_cnt == 4'b1010)
        nxt_state2 = IDLE2;    ///////// USE TX_DONE OR BIT COUNT -- CYCLE LATER?????????
    default:
      nxt_state2 = IDLE2;
  endcase
end

/////////////////////////
// Infer bit_cnt next //
///////////////////////
always @(posedge clk or negedge rst_n)
  if (!rst_n)
    bit_cnt <= 4'b0000;
  else if (load)
    bit_cnt <= 4'b0000;
  else if (shift)
    bit_cnt <= bit_cnt+1;

//////////////////////////
// Infer baud_cnt next //
////////////////////////
always @(posedge clk or negedge rst_n)
  if (!rst_n)
    baud_cnt <= 13'h01b2;       // REMOVE! was 2600 dec or 0A2C hex === baud of 19200 with 50MHz clk
  else if (load || shift)
    baud_cnt <= {DBH, DBL};		// REMOVE! was 2600 dec or 0A2C hex === baud of 19200 with 50MHz clk
  else if (trnsmttng)
    baud_cnt <= baud_cnt-1;		// only burn power incrementing if tranmitting

////////////////////////////////
// Infer shift register next //
//////////////////////////////
always @(posedge clk or negedge rst_n)
  if (!rst_n)
    shift_reg <= 9'h1FF;		// reset to idle state being transmitted
  else if (load) 
    shift_reg <= {tx_buff_out,1'b0};	// start bit is loaded as well as data to T
                                    // which is no longer tx_data, rather output of tx buffer                                
  else if (shift)
    shift_reg <= {1'b1,shift_reg[8:1]};	// LSB shifted out and idle state shifted in 

///////////////////////////////////////////////
// Easiest to make tx_done a set/reset flop //
/////////////////////////////////////////////
always @(posedge clk or negedge rst_n)
  if (!rst_n)
    tx_done <= 1'b0;
  else if (trmt)
    tx_done <= 1'b0;
  else if (bit_cnt==4'b1010)
    tx_done <= 1'b1;

//////////////////////////////////////////////
// Now for hard part...State machine logic //
////////////////////////////////////////////
always_comb
  begin
    //////////////////////////////////////
    // Default assign all output of SM //
    ////////////////////////////////////
    load         = 0;
    trnsmttng = 0;
    nxt_state    = IDLE;	// always a good idea to default to IDLE state
    
    case (state)
      IDLE : begin
        if (trmt)
          begin
            nxt_state = TX_STATE;
            load = 1;
          end
        else nxt_state = IDLE;
      end
      default : begin		// this is TX state
        if (bit_cnt==4'b1010)
          nxt_state = IDLE;
        else
          nxt_state = TX_STATE;
        trnsmttng = 1;
      end
    endcase
  end

////////////////////////////////////
// Continuous assignement follow //
//////////////////////////////////
assign shift = ~|baud_cnt;
assign TX = shift_reg[0];		// LSB of shift register is TX

endmodule

