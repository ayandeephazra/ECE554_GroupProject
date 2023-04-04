module BMP_ROM_Bucky(clk,addr,dout);

  input clk;     // 50MHz clock
  input [15:0] addr;
  output reg [5:0] dout;   // 5-bit color pixel out

  reg [5:0] rom[0:17171];

  initial
    $readmemh("Bucky.hex",rom);

  always @(posedge clk)
    dout <= rom[addr];

endmodule
