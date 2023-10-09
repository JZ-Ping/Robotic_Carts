module AgrB3bit(a, b, cout);

	input [2:0]a, b;
	output cout;

	assign cout = (a[2] & ~b[2]) | ((a[2] ~^ b[2]) & (a[1] & ~b[1])) | ((a[2] ~^ b[2]) & (a[1] ~^ b[1]) & (a[0] & ~b[0]));

endmodule


module AequB3bit(a, b, cout);

	input [2:0]a, b;
	output cout;
	
	assign cout = ((a[2] ~^ b[2]) & (a[1] ~^ b[1])) & (a[0] ~^ b[0]);
	
endmodule

module AzeroB3bit(a, b, cout);

	input [2:0]a, b;
	output cout;
	
	assign cout = ~(a[2] | b[2]) & ~(a[1] | b[1]) & ~(a[0] | b[0]);
	
endmodule


module Renee_Display(Action, SEG);

	input [2:0] Action;
	output [6:0] SEG;
	
	parameter [6:0] F = 7'b0001110; // Forward
	parameter [6:0] r = 7'b1011110; // Reverse
	parameter [6:0] S = 7'b0010010; // Stop
	//my7bit31mux(Action, F, r, S, y);
	assign SEG[6:0] = Action[2] ? r : (Action[1] ? F : S); //3 or 4 way mux
	
	
endmodule


module Renee_Controller(ls, rs, lb, rb,fb, bb, lwa, rwa, LEDR);

	input [2:0]ls, rs;
	input	lb, rb, fb, bb;
	output [2:0]lwa, rwa;
	output [3:0]LEDR;
	
	// turn Left?	
	AgrB3bit tL(ls, rs, tLeft);
	assign LEDR[0] = tLeft;
	
	// turn Right?
	AgrB3bit tR(rs, ls, tRight);
	assign LEDR[1] = tRight;
	// forward?
	AequB3bit fr(ls, rs, eq);
	assign LEDR[2] = eq;
	// stop?
	AzeroB3bit st(ls, rs, stop);
	assign LEDR[3] = stop;
	assign forward = eq & ~stop;
	// is any bumper active?
	assign bump = ~fb | ~bb | ~lb | ~rb;
	
	// if bumpers are off, should Renee turn?
	assign turn = tLeft | tRight;
	
	// bumper overide
	assign Lreverse = (~fb & rb & lb & bb) | (~lb & fb & bb & rb) | (~lb & ~fb & bb & rb);
	assign Lforward = (~bb & fb & lb & rb) | (~lb & ~bb & fb & rb);
	assign Lstop = (~rb &lb & fb & bb)| (~rb & ~fb & lb & bb) | (~rb & ~bb & lb & fb) | (~fb & ~bb) | (~lb & ~rb);
	
	assign Rreverse = (~fb & rb & lb & bb) | (~rb & lb & fb & bb) | (~fb & ~rb & lb & bb);
	assign Rforward = (~bb & fb & lb & rb) | (~bb & ~rb & lb & fb);
	assign Rstop = (~lb & rb & fb & bb) | (~lb & ~fb & bb & rb) | (~lb & ~bb & fb & rb) | (~fb & ~bb) | (~lb & ~rb);
	
	// decision	
	assign lwa[2] = bump ? Lreverse : (turn ? 0 : (forward ? 0 : 0));
	assign lwa[1] = bump ? Lforward : (turn ? tRight : (forward ? forward : 0));
	assign lwa[0] = bump ? Lstop : (turn ? tLeft : (forward ? 0 : stop));
	
	assign rwa[2] = bump ? Rreverse : (turn ? 0 : (forward ? 0 : 0));
	assign rwa[1] = bump ? Rforward : (turn ? tLeft : (forward ? forward : 0));
	assign rwa[0] = bump ? Rstop : (turn ? tRight : (forward ? 0 : stop));
	
	/* turning left or right
	assign lwa[2] = 0;
	assign lwa[1] = tRight;
	assign lwa[0] = tLeft;
	
	assign rwa[2] = 0;
	assign rwa[1] = tLeft;
	assign rwa[0] = tRight;
	
	// going forward
	assign lwa[2] = 0;
	assign lwa[1] = forward;
	assign lwa[0] = 0;
	
	assign rwa[2] = 0;
	assign rwa[1] = forward;
	assign rwa[0] = 0;
	
	// stop
	assign lwa[2] = 0;
	assign lwa[1] = 0;
	assign lwa[0] = stop;
	
	assign rwa[2] = 0;
	assign rwa[1] = 0;
	assign rwa[0] = stop;*/
	
endmodule


module Renee(SW, KEY, HEX1, HEX0);

	input [6:0]SW;
	input [3:0]KEY;
	output [6:0] HEX0, HEX1;
	
	wire [2:0]  lw, rw;
	
	Renee_Controller R1(.ls(SW[6:4]), .rs(SW[2:0]), .lb(KEY[3]), .rb(KEY[2]), .fb(KEY[1]), .bb(KEY[0]), .lwa(lw), .rwa(rw));
	Renee_Display R2(lw, HEX1);
	Renee_Display R3(rw, HEX0);
	
endmodule
