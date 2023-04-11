module mmap_regs(
    input clk, 
    input rst_n,
    input br_stats_wr,
    input mmap_re,          // read to mmap regs
    input [3:0] mmap_addr,
    inout [15:0] databus,   // input (for en/dis stats count) OR output (mmap_reg data)
    input inc_br_cnt,
    input inc_hit_cnt,
    input inc_mispr_cnt
);

    logic [15:0] br_cnt, mispr_cnt, hit_cnt;
    logic [15:0] timer;
    logic stats_en;     // a write to mem addr 0xc00b sets or clears the stats reg

    assign databus = (mmap_re & mmap_addr == 2'b00) ? br_cnt :
                     (mmap_re & mmap_addr == 2'b01) ? mispr_cnt :
                     (mmap_re & mmap_addr == 2'b10) ? hit_cnt :
                     (mmap_re & mmap_addr == 2'b11) ? timer :
                     16'hzzzz;

    always_ff @ (posedge clk, negedge rst_n)
        if (!rst_n)
            stats_en <= '0;
        else if (br_stats_wr)
            stats_en <= databus[0];
    // LFSR
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
    

endmodule