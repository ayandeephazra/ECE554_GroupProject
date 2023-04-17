module BMP_ROM_Po(clk,addr,dout);

  input clk;     // 50MHz clock
  input [15:0] addr;
  output reg [8:0] dout;   // 9-bit color pixel out

  reg [8:0] rom[0:6401];

  initial
    $readmemh("Po.hex",rom);

  always @(posedge clk)
    dout <= rom[addr];

endmodule
