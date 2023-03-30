module mmap_regs(
    input clk, 
    input rst_n,
    input inc_br_cnt,
    input inc_hit_cnt,
    input inc_mispr_cnt
);

    logic [15:0] br_cnt, mispr_cnt, hit_cnt;
    logic [15:0] timer;
    // LFSR
    // Branch count
    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n)
            br_cnt <= '0;
        else if (inc_br_cnt)
            br_cnt <= br_cnt + 1;
    end
    // Misprediction count
    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n)
            mispr_cnt <= '0;
        else if (inc_mispr_cnt)
            mispr_cnt <= mispr_cnt + 1;
    end
    // Branch HIT count
    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n)
            hit_cnt <= '0;
        else if (inc_hit_cnt)
            hit_cnt <= hit_cnt + 1;
    end
    // Timer

endmodule