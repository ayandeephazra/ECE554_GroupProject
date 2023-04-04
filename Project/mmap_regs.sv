module mmap_regs(
    input clk, 
    input rst_n,
    input br_stats_wr,
    input [15:0] databus,
    input inc_br_cnt,
    input inc_hit_cnt,
    input inc_mispr_cnt
);

    logic [15:0] br_cnt, mispr_cnt, hit_cnt;
    logic [15:0] timer;
    logic stats_en;     // a write to mem addr 0xc00b sets or clears the stats reg

    always_ff @ (posedge clk, negedge rst_n)
        if (!rst_n)
            stats_en <= '0;
        else if (br_stats_wr)
            stats_en <= databus[0];
    // LFSR
    // Branch count
    always_ff @(posedge clk, negedge rst_n)
        if (!rst_n)
            br_cnt <= '0;
        else if (inc_br_cnt & stats_en)
            br_cnt <= br_cnt + 1;

    // Misprediction count
    always_ff @(posedge clk, negedge rst_n)
        if (!rst_n)
            mispr_cnt <= '0;
        else if (inc_mispr_cnt & stats_en)
            mispr_cnt <= mispr_cnt + 1;

    // Branch HIT count
    always_ff @(posedge clk, negedge rst_n)
        if (!rst_n)
            hit_cnt <= '0;
        else if (inc_hit_cnt & stats_en)
            hit_cnt <= hit_cnt + 1;
    
    // Timer
    always_ff @(posedge clk, negedge rst_n)
        if (!rst_n)
            timer <= '0;
        else
            timer <= timer + 1;
    

endmodule