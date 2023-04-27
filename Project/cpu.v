module cpu(clk,rst_n, wdata, mm_we, addr, mm_re, rdata, inc_br_cnt, inc_hit_cnt, inc_mispr_cnt, btb_en);
 //inc_br_cnt, inc_hit_cnt, inc_mispr_cnt, btb_en
//rdata added to original input signals
input clk,rst_n;
input [15:0] rdata;
input btb_en;					// **ADDED** enable branch prediction using SW[0]
// all new signals to modified cpu outputs
output [15:0] wdata;
output [15:0] addr;
output mm_we, mm_re;
// branch prediciton stats collection
output inc_br_cnt;
output inc_hit_cnt;
output inc_mispr_cnt;

wire [16:0] instr;				// instruction from IM
wire [11:0] instr_ID_EX;		// immediate bus
wire [15:0] src0,src1;			// operand busses into ALU
wire [15:0] dst_EX_DM;			// result from ALU
wire [15:0] dst_ID_EX;			// result from ALU for branch destination
wire [15:0] pc_ID_EX;			// nxt_pc to source mux for JR
wire [15:0] pc_EX_DM;			// nxt_pc to store in reg15 for JAL
wire [15:0] iaddr;				// instruction address
wire [15:0] pc_pre_mux;			// **ADDED** pre movc mux to index into BTB
wire [15:0] dm_rd_data_EX_DM;	// data memory read data
wire [15:0] rf_w_data_DM_WB;	// register file write data
wire [15:0] p0,p1;				// read ports from RF
wire [3:0] rf_p0_addr;			// address for port 0 reads
wire [3:0] rf_p1_addr;			// address for port 1 reads
wire [3:0] rf_dst_addr_DM_WB;	// address for RF write port
wire [3:0] alu_func_ID_EX;		// specifies operation ALU should perform
wire [2:0] src0sel_ID_EX;		// select for src0 bus
wire [1:0] src1sel_ID_EX;		// select for src1 bus
wire [2:0] cc_ID_EX;			// condition code pipeline from instr[11:9]
wire [15:0] p0_EX_DM;			// data to be stored for SW

///////////////////////////////////////////////////////////////////////////////
wire mm_re, mm_we;              // external read and write
wire DM_we;                     // internal data memory write
wire [15:0] read_mux_select;    // choosing which signal is read 
wire [15:0] btb_nxt_pc;			// Branch predicted target PC
wire btb_hit;					// F stage btb_hit
wire btb_hit_ID_EX;				// Required in EX to decide if flow change is necessary

//////////////////////////////////
// Instantiate program counter //
////////////////////////////////
pc iPC(.clk(clk), .rst_n(rst_n), .stall_IM_ID(stall_IM_ID), .pc(iaddr), .dst_ID_EX(dst_ID_EX),
		.pc_ID_EX(pc_ID_EX), .pc_EX_DM(pc_EX_DM), .flow_change_ID_EX(flow_change_ID_EX), 
		.LWI_instr_EX_DM(LWI_instr_EX_DM), .dst_EX_DM(dst_EX_DM), .pc_pre_mux(pc_pre_mux), 
	   .btb_hit(btb_hit), .btb_nxt_pc(btb_nxt_pc), .btb_hit_ID_EX(btb_hit_ID_EX));
	   
///////////////////////////////////////
// Instantiate Branch Target Buffer //
/////////////////////////////////////
btb iBTB(.clk(clk), .rst_n(rst_n), .PC(pc_pre_mux), .target_PC(btb_nxt_pc), .hit(btb_hit), .btb_hit_ID_EX(btb_hit_ID_EX),
		.flow_change_ID_EX(flow_change_ID_EX), .br_instr_ID_EX(br_instr_ID_EX), .pc_ID_EX(pc_ID_EX), .stall_IM_ID(stall_IM_ID),
		.dst_ID_EX(dst_ID_EX), .inc_br_cnt(inc_br_cnt), .inc_hit_cnt(inc_hit_cnt), .inc_mispr_cnt(inc_mispr_cnt),
		.en(btb_en));

/////////////////////////////////////
// Instantiate instruction memory //
///////////////////////////////////
IM iIM(.clk(clk), .addr(iaddr), .rd_en(1'b1), .instr(instr));

//////////////////////////////////////////////
// Instantiate register instruction decode //
////////////////////////////////////////////
id	iID(.clk(clk), .rst_n(rst_n), .instr(instr), .zr_EX_DM(zr_EX_DM), .br_instr_ID_EX(br_instr_ID_EX),
        .jmp_imm_ID_EX(jmp_imm_ID_EX), .jmp_reg_ID_EX(jmp_reg_ID_EX), .jmp_imm_EX_DM(jmp_imm_EX_DM), .rf_re0(rf_re0),
		.rf_re1(rf_re1), .rf_we_DM_WB(rf_we_DM_WB), .rf_p0_addr(rf_p0_addr), .rf_p1_addr(rf_p1_addr),
		.rf_dst_addr_DM_WB(rf_dst_addr_DM_WB), .alu_func_ID_EX(alu_func_ID_EX),
		.src0sel_ID_EX(src0sel_ID_EX), .src1sel_ID_EX(src1sel_ID_EX), .dm_re_EX_DM(dm_re_EX_DM),
		.dm_we_EX_DM(dm_we_EX_DM), .clk_z_ID_EX(clk_z_ID_EX), .clk_nv_ID_EX(clk_nv_ID_EX),
		.instr_ID_EX(instr_ID_EX), .cc_ID_EX(cc_ID_EX), .stall_IM_ID(stall_IM_ID),
		.stall_ID_EX(stall_ID_EX), .stall_EX_DM(stall_EX_DM), .hlt_DM_WB(hlt_DM_WB),
		.byp0_EX(byp0_EX), .byp0_DM(byp0_DM), .byp1_EX(byp1_EX), .byp1_DM(byp1_DM),
		.flow_change_ID_EX(flow_change_ID_EX), .LWI_instr_EX_DM(LWI_instr_EX_DM)); //NEW
	   
////////////////////////////////
// Instantiate register file //
//////////////////////////////
rf iRF(.clk(clk), .rst_n(rst_n), .p0_addr(rf_p0_addr), .p1_addr(rf_p1_addr), .p0(p0), .p1(p1),
       .re0(rf_re0), .re1(rf_re1), .dst_addr(rf_dst_addr_DM_WB), .dst(rf_w_data_DM_WB),
 	   .we(rf_we_DM_WB));
	   
///////////////////////////////////
// Instantiate register src mux //
/////////////////////////////////
src_mux ISRCMUX(.clk(clk), .stall_ID_EX(stall_ID_EX), .stall_EX_DM(stall_EX_DM),
                .src0sel_ID_EX(src0sel_ID_EX), .src1sel_ID_EX(src1sel_ID_EX), .p0(p0), .p1(p1),
                .imm_ID_EX(instr_ID_EX), .pc_ID_EX(pc_ID_EX), .p0_EX_DM(p0_EX_DM),
				.src0(src0), .src1(src1), .dst_EX_DM(dst_EX_DM), .dst_DM_WB(rf_w_data_DM_WB),
			    .byp0_EX(byp0_EX), .byp0_DM(byp0_DM), .byp1_EX(byp1_EX), .byp1_DM(byp1_DM),
				.instr(instr), .LWI_instr_EX_DM(LWI_instr_EX_DM));
	   
//////////////////////
// Instantiate ALU //
////////////////////
alu iALU(.clk(clk), .src0(src0), .src1(src1), .shamt(instr_ID_EX[3:0]), .func(alu_func_ID_EX),
         .dst(dst_ID_EX), .dst_EX_DM(dst_EX_DM), .ov(ov), .zr(zr), .neg(neg));	
		 
	
//////////////////////////////
// Instantiate data memory //
////////////////////////////
DM iDM(.clk(clk),.addr(dst_EX_DM), .re(dm_re_EX_DM), .we(dm_we_EX_DM), .wrt_data(p0_EX_DM),
       .rd_data(dm_rd_data_EX_DM));
	   
assign mm_re = |dst_EX_DM[15:13] & dm_re_EX_DM;      // External and a read
assign mm_we = |dst_EX_DM[15:13] & dm_we_EX_DM;      // External and a write
assign DM_we = ~|dst_EX_DM[15:13] & dm_we_EX_DM;     // qualified internal DM we
assign addr = dst_EX_DM; 							 // Address that needs to be used in MiniLab0 module
												     // for setting rdata and LEDR signal

// dm_re_EX_DM is mux select for rdata and p0_EX_DM or dm_rd_data_EX_DM figure out which 
// dm_we_EX_DM does not need to select as use p0_EX_DM as the wdata signal

// wdata from DM is directly used as wdata for external memory
assign wdata = p0_EX_DM; 
// mm_re is the select signal to choose between Internal or External Read
assign read_mux_select = (mm_re)? rdata: dm_rd_data_EX_DM; 

//////////////////////////
// Instantiate dst mux //
////////////////////////
dst_mux iDSTMUX(.clk(clk), .dm_re_EX_DM(dm_re_EX_DM), .dm_rd_data_EX_DM(read_mux_select),
                .dst_EX_DM(dst_EX_DM), .pc_EX_DM(pc_EX_DM), .rf_w_data_DM_WB(rf_w_data_DM_WB),
				.jmp_imm_EX_DM(jmp_imm_EX_DM), .instr(instr), .LWI_instr_EX_DM(LWI_instr_EX_DM));
	
/////////////////////////////////////////////
// Instantiate branch determination logic //
///////////////////////////////////////////
br_bool iBRL(.clk(clk), .rst_n(rst_n), .clk_z_ID_EX(clk_z_ID_EX), .clk_nv_ID_EX(clk_nv_ID_EX),
             .br_instr_ID_EX(br_instr_ID_EX), .jmp_imm_ID_EX(jmp_imm_ID_EX),
			 .jmp_reg_ID_EX(jmp_reg_ID_EX), .cc_ID_EX(cc_ID_EX), .zr(zr), .ov(ov),
			 .zr_EX_DM(zr_EX_DM), .neg(neg), .flow_change_ID_EX(flow_change_ID_EX), .btb_hit_ID_EX(btb_hit_ID_EX));	
	   
endmodule
