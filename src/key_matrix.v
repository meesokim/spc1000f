// SPDX-License-Identifier: MIT

// USB host supports up to 5 simultaneous key inputs (4 keys + 1 modifier).
// Get the key codes handed over from USB HID host, set the right point
// in 8x10 grid which is mapped to I/O port 0x8000 - 0x8009.
module key_matrix(
		  input		    clk,
		  input [7:0]	    key_modifiers,
		  input [7:0]	    key1,
		  input [7:0]	    key2,
		  input [7:0]	    key3,
		  input [7:0]	    key4,
		  output reg [79:0] port);

   // 8000h
   localparam			    _GRAPH = 8'h04; // ALT 
   localparam			    _BREAK = 8'h46; // SYSRQ 
   localparam			    _RCTRL = 8'h10;
   localparam			    _LCTRL = 8'h01;
   localparam			    _RSHIFT = 8'h20;
   localparam			    _LSHIFT = 8'h02;

   // 8001h
   localparam			    _1 = 8'h1e;
   localparam			    _Q = 8'h14;
   localparam			    _A = 8'h04;
   localparam			    _C = 8'h06;
   localparam			    _RETURN = 8'h28;
   localparam			    _SPACE = 8'h2c;
   localparam			    _CLR = 8'h53; // Num Lock for now
   localparam			    _TILDE = 8'h35;

   // 8002h
   localparam			    _2 = 8'h1f;
   localparam			    _W = 8'h1a;
   localparam			    _S = 8'h16;
   localparam			    _V = 8'h19;
   localparam			    _RBRACKET= 8'h30;
   localparam			    _Z = 8'h1d;
   localparam			    _LOCK= 8'h39;
   
   // 8003h
   localparam			    _3 = 8'h20;
   localparam			    _E = 8'h08;
   localparam			    _D = 8'h07;
   localparam			    _B = 8'h05;
   localparam			    _LBRACKET= 8'h2f;
   localparam			    _ESC = 8'h29;
   localparam			    _DEL = 8'h2a;  // h4c
   
   // 8004h
   localparam			    _4 = 8'h21;
   localparam			    _R = 8'h15;
   localparam			    _F = 8'h09;
   localparam			    _N = 8'h11;
   localparam			    _CURRENCY = 8'h31;
   localparam			    _RIGHT = 8'h4f;

   // 8005h
   localparam			    _5 = 8'h22;
   localparam			    _T = 8'h17;
   localparam			    _G = 8'h0a;
   localparam			    _M = 8'h10;
   localparam			    _LEFT = 8'h50;
   localparam			    _F1 = 8'h3a;

   // 8006h
   localparam			    _6 = 8'h23;
   localparam			    _Y = 8'h1c;
   localparam			    _H = 8'h0b;
   localparam			    _COMMA = 8'h36;
   localparam			    _X = 8'h1b;
   localparam			    _ALPHA = 8'h38;  // ?/ for now
   localparam			    _F2 = 8'h3b;

   // 8007h
   localparam			    _7 = 8'h24;
   localparam			    _U = 8'h18;
   localparam			    _J = 8'h0d;
   localparam			    _PERIOD = 8'h37;
   localparam			    _P = 8'h13;
   localparam			    _UP = 8'h52;
   localparam			    _F3 = 8'h3c;

   // 8008h
   localparam			    _8 = 8'h25;
   localparam			    _I = 8'h0c;
   localparam			    _K = 8'h0e;
   localparam			    _SLASH = 8'h38;
   localparam			    _COLON = 8'h33;
   localparam			    _DOWN = 8'h51;
   localparam			    _F4 = 8'h3d;
   
   // 8009h
   localparam			    _9 = 8'h26;
   localparam			    _O = 8'h12;
   localparam			    _L = 8'h0f;
   localparam			    _SEMICOLON = 8'h34; // Quote for now
   localparam			    _0 = 8'h27;
   localparam			    _MINUS = 8'h2d;
   localparam			    _F5 = 8'h3e;
   
   // Set the given key modifier to the right grid point.
   task set_modifier_bits(input [7:0] modifier); begin
      if (modifier == _GRAPH) port[8*0+6] <= 1'b0;
      else if (modifier == _RCTRL || modifier == _LCTRL)  port[8*0+2] <= 1'b0; 
      else if (modifier == _LSHIFT || modifier == _RSHIFT) port[8*0+1] <= 1'b0;
   end
   endtask

   // Set the given key to the right grid point.
   task set_keybits(input [7:0] key); begin
      case (key)
        // 8000h
	_BREAK: port[8*0+4] <= 1'b0;
	
        // 8001h
	_1:      port[8*1+7] <= 1'b0;
	_Q:      port[8*1+6] <= 1'b0;
	_A:      port[8*1+5] <= 1'b0;
	_C:      port[8*1+4] <= 1'b0;
	_RETURN: port[8*1+3] <= 1'b0;
	_SPACE:  port[8*1+2] <= 1'b0;
	_CLR:    port[8*1+1] <= 1'b0;
	_TILDE:  port[8*3+0] <= 1'b0;

        // 8002h
	_2: port[8*2+7] <= 1'b0;
	_W: port[8*2+6] <= 1'b0;
	_S: port[8*2+5] <= 1'b0;
	_V: port[8*2+4] <= 1'b0;
	_RBRACKET: port[8*2+3] <= 1'b0;
	_Z: port[8*2+2] <= 1'b0;
	_LOCK: port[8*2+0] <= 1'b0;

        // 8003h
	_3: port[8*3+7] <= 1'b0;
	_E: port[8*3+6] <= 1'b0;
	_D: port[8*3+5] <= 1'b0;
	_B: port[8*3+4] <= 1'b0;
	_LBRACKET: port[8*3+3] <= 1'b0;
	_ESC: port[8*3+2] <= 1'b0;
	_DEL: port[8*3+0] <= 1'b0;

        // 8004h
	_4: port[8*4+7] <= 1'b0;
	_R: port[8*4+6] <= 1'b0;
	_F: port[8*4+5] <= 1'b0;
	_N: port[8*4+4] <= 1'b0;
	_CURRENCY: port[8*4+3] <= 1'b0;
	_RIGHT: port[8*4+2] <= 1'b0;

        // 8005h
	_5: port[8*5+7] <= 1'b0;
	_T: port[8*5+6] <= 1'b0;
	_G: port[8*5+5] <= 1'b0;
	_M: port[8*5+4] <= 1'b0;
	_LEFT: port[8*5+2] <= 1'b0;
	_F1: port[8*5+1] <= 1'b0;
	
        // 8006h
	_6: port[8*6+7] <= 1'b0;
	_Y: port[8*6+6] <= 1'b0;
	_H: port[8*6+5] <= 1'b0;
	_COMMA: port[8*6+4] <= 1'b0;
	_X: port[8*6+3] <= 1'b0;
	_ALPHA: port[8*6+2] <= 1'b0;
	_F2: port[8*6+1] <= 1'b0;

        // 8007h
	_7: port[8*7+7] <= 1'b0;
	_U: port[8*7+6] <= 1'b0;
	_J: port[8*7+5] <= 1'b0;
	_PERIOD: port[8*7+4] <= 1'b0;
	_P: port[8*7+3] <= 1'b0;
	_UP: port[8*7+2] <= 1'b0;
	_F3: port[8*7+1] <= 1'b0;

        // 8008h
	_8: port[8*8+7] <= 1'b0;
	_I: port[8*8+6] <= 1'b0;
	_K: port[8*8+5] <= 1'b0;
	_SLASH: port[8*8+4] <= 1'b0;
	_COLON: port[8*8+3] <= 1'b0;
	_DOWN: port[8*8+2] <= 1'b0;
	_F4: port[8*8+1] <= 1'b0;

        // 8009h
	_9: port[8*9+7] <= 1'b0;
	_O: port[8*9+6] <= 1'b0;
	_L: port[8*9+5] <= 1'b0;
	_SEMICOLON: port[8*9+4] <= 1'b0;
	_0: port[8*9+3] <= 1'b0;
	_MINUS: port[8*9+2] <= 1'b0;
	_F5: port[8*9+1] <= 1'b0;

	default:;
      endcase
   end
   endtask

   // USB host supports up to 5 simultaneous key inputs (4 keys + 1 modifier)
   always @(posedge clk) begin
      port <= {80{1'b1}};
      if (key_modifiers != 0) set_modifier_bits(key_modifiers);
      if (key1 != 0) set_keybits(key1);
      if (key2 != 0) set_keybits(key2);
      if (key3 != 0) set_keybits(key3);
      if (key4 != 0) set_keybits(key4);
   end
endmodule


