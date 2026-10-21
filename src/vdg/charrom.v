// SPDX-License-Identifier: MIT

// Internal character pattern data used for MC6847 (key code 0x20 ~ 0x5F).
module charrom ( output reg [7:0] dout, input[8:0] address, input clk);

   parameter MEM_INIT_FILE = "./charrom.mem";

   // 64 characters x 8 bytes per character
   reg [7:0] rom [0:511];

   initial begin
     $readmemh(MEM_INIT_FILE, rom);
   end
	
   always @(posedge clk)
     dout <= rom[address];

endmodule
