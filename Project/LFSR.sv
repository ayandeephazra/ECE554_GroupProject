module LFSR(clk, rst_n, load, SEED, q);

input               clk;            // 50MHz clk
input               rst_n;          // reset for setting seed
input               load;           // load the SEED into the LFSR
input [7:0]         SEED;           // preset for the LSFR
output logic [7:0]  q;              // output of the LFSR

// flip-flops used in the LFSR
logic ff8, ff7, ff6, ff5, ff4, ff3, ff2, ff1;


always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin               // set all ffs to 0 on rst_n low
        ff8 <= 0;
        ff7 <= 0;
        ff6 <= 0;
        ff5 <= 0;
        ff4 <= 0;
        ff3 <= 0;
        ff2 <= 0;
        ff1 <= 0;
    end
    else if (load) begin            // load seed into each ff
        ff8 <= SEED[7];
        ff7 <= SEED[6];
        ff6 <= SEED[5];
        ff5 <= SEED[4];
        ff4 <= SEED[3];
        ff3 <= SEED[2];
        ff2 <= SEED[1];
        ff1 <= SEED[0];
    end
    else begin                      // shift each bit one ff forward
        ff8 <= ff1;
        ff7 <= ff8;
        ff6 <= ff7;
        ff5 <= ff6;
        ff4 <= ff5 ^ ff1;           // XOR ff5 and ff1 to add "randomness"    
        ff3 <= ff4 ^ ff1;           // XOR ff4 and ff1 to add "randomness"
        ff2 <= ff3 ^ ff1;           // XOR ff3 and ff1 to add "randomness"
        ff1 <= ff2;
        
        // output
        q <= {ff8, ff7, ff6, ff5, ff4, ff3, ff2, ff1};
    end
end

endmodule