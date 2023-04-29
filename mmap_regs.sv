module mmap_regs(
    input clk, 
    input rst_n,
    input br_stats_wr,      // enable banch prediction stats recording
    input lfsr_load,        // write SEED to lfsr
    input mm_re,            // external read
    input [15:0] addr,
    inout [15:0] databus,   // input (for en/dis stats count || lfsr seed) OR output (mmap_reg data)
    input inc_br_cnt,
    input inc_hit_cnt,
    input inc_mispr_cnt,
    input KEY_UP,
    input KEY_DOWN
);

    logic [15:0] br_cnt, mispr_cnt, hit_cnt;
    logic [15:0] timer;
    logic stats_en;     // a write to mem addr 0xc00b sets or clears the stats reg
    logic [15:0] button_up, button_down;
    logic [7:0] lfsr_out, lfsr_SEED;

    // mmap_addr needs to check all 4 bits -> switched to hex to make it easier
    assign databus = (mm_re & addr == 16'hc010) ? br_cnt :
                     (mm_re & addr == 16'hc011) ? mispr_cnt :
                     (mm_re & addr == 16'hc012) ? hit_cnt :
                     (mm_re & addr == 16'hc013) ? timer :
                     (mm_re & addr == 16'hc014) ? button_up :       
                     (mm_re & addr == 16'hc015) ? button_down :
                     (mm_re & addr == 16'hc016) ? lfsr_out :
                     16'hzzzz;

    // enable branch prediction stats count -- addr 0xc00b
    always_ff @ (posedge clk, negedge rst_n)
        if (!rst_n)
            stats_en <= '0;
        else if (br_stats_wr)
            stats_en <= databus[0];

    // Branch count -- addr 0xc010
    always_ff @(posedge clk, negedge rst_n)
        if (!rst_n)
            br_cnt <= '0;
        else if (inc_br_cnt & stats_en)
            br_cnt <= br_cnt + 1;

    // Misprediction count -- addr 0xc011
    always_ff @(posedge clk, negedge rst_n)
        if (!rst_n)
            mispr_cnt <= '0;
        else if (inc_mispr_cnt & stats_en)
            mispr_cnt <= mispr_cnt + 1;

    // Branch HIT count -- addr 0xc012
    always_ff @(posedge clk, negedge rst_n)
        if (!rst_n)
            hit_cnt <= '0;
        else if (inc_hit_cnt & stats_en)
            hit_cnt <= hit_cnt + 1;
    
    // Timer -- addr 0xc013
    always_ff @(posedge clk, negedge rst_n)
        if (!rst_n)
            timer <= '0;
        else
            timer <= timer + 1;

    // KEY[1] -- addr 0xc014
    always_ff @(posedge clk, negedge rst_n)
        if (!rst_n)
            button_up <= 16'h0000;
        else if (KEY_UP)
            button_up <= 16'hF0F0;
        else
            button_up <= 16'h0000;

    // KEY[2] -- addr 0xc015
    always_ff @(posedge clk, negedge rst_n)
        if (!rst_n)
            button_down <= 16'h0000;
        else if (KEY_DOWN)
            button_down <= 16'hF0F0;
        else
            button_down <= 16'h0000;

    assign lfsr_SEED = (lfsr_load) ? databus[7:0] : 8'h0;

    ////////////////////////
	// Instantiate LFSR  //
	//////////////////////
	LFSR iLFSR(.clk(clk), .rst_n(rst_n), .load(lfsr_load), .SEED(lfsr_SEED), .q(lfsr_out));

    

endmodule
