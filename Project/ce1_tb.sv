module ce1_tb();

logic clk, rst_n;

ce1 ice1(.CLOCK_50(clk), .KEY({3'b0, rst_n}));

initial begin
    clk = 0;
    rst_n = 0;

    @ (negedge clk);
    rst_n = 1;

    repeat (100000) @ (posedge clk);

    $stop();
end

always
    #5 clk = ~clk;


endmodule