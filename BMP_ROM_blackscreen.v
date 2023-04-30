module BMP_ROM_blackscreen(clk,addr,dout);

  input clk;     // 50MHz clock
  input [15:0] addr;
  output reg [5:0] dout;   // 5-bit color pixel out

  reg [5:0] rom[0:70003];

  initial
    $readmemh("blackscreen.hex",rom);

  always @(posedge clk)
    dout <= rom[addr];

endmodule
