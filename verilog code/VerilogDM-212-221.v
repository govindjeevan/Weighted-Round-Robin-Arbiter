/*
STRUCTURAL MODEL VERILOG CODE
------------------------------------
											
WEIGHTED ROUND ROBIN ARBITER 
												
-----------------------------------------------
Mini-Project: CO202 - Design Of Digital Systems
-----------------------------------------------
Reg:       	
GOVIND JEEVAN       16CO221
BIDYADHAR MOHANTY   16CO212
-----------------------------------------------

ABSTRACT:
---------
An arbiter is a device that determines how a common resource is shared amongst mutiple requesters.
The common resource may be a shared memory, a networking switch fabric, or a complex computational element. 

The Weighted Round-Robin (WRR) CPU Scheduling algorithm is based on the round-robin and priority scheduling algorithms.
The WRR allocates the resource for each of the enabled requests for a specific period of time, in order, going back to the 
first served request when all the requests have been granted once.

FUNCTIONALITIES:
----------------
• Accepts request vectors as input. The active requesters are denoted by 1s and inactive requesters by 0s.

• Produces a grant vector as output. Each grant vector has only a single 1, in one clock cycle denoting the granted request.

• Vector Order Arbitration. The arbiter follows 0th to 7th order, granting active requests as it moves.

• Wrap around, At the end of the requests vector, WRR it will return to the requestors at the beginning without losing cycles.

• Work Efficient. WRR skips 0 weighted requesters to serve the next requester with wieight 1. 
  Thus no time slot is wasted on inactive requestors.

BRIEF CODE DESCRIPTION:
----------------

Index Service:
The 8 bits of Request Vector, acts as select lines for 8, 2-1 MUXs with the high input line as the correspoding 3 bit index.
The MUXs corresponding to inactive requests, outputs the value of the preceeding active index.

Grant Service:
An 8-1 Main MUX selects from the 8 different MUX outputs with index values, based on the select line provided by a full adder.
The Full Adder, increments the last granted Index Value by one, and directs the MUX to select the next active index line.

A 2-1 MUX, selects between the output of the Main MUX and the value stored in the register (from previous cycle) depending on
whether any request is active or not.
The Register value is feedbacked to the register itself by the MUX, if no requests are active.

A 3-8 Decoder, decodes the 3 bit index line, to a Grant Vector of 8 bits, that denotes the granted index by a high bit.
*/


module VerilogDM_212_221(request,grant,clk,enable);

	input clk;					// Clock Pulse for sequential elements
	input enable;				// Enable line
	input [7:0] request;		// Request Vector, atmost 8 requesters at a time
	output [7:0] grant; 		// Grant Vector, with 8 possible grants, atmost one at a time

	wire [7:0] out;

	// 3 Bit Index Wires ( 0 -> 7 )
	wire [2:0] ind0;
	wire [2:0] ind1;
	wire [2:0] ind2;
	wire [2:0] ind3;
	wire [2:0] ind4;
	wire [2:0] ind5;
	wire [2:0] ind6;
	wire [2:0] ind7;

	wire [2:0] main_mux_out; // 3 Bit Index Wire selected by MUX in WRR Fashion
	wire [2:0] reg_out;		 // Register Wire with stored index
	wire [2:0] last_mux_out; // 3 Bit Final Granted Index Wire
	wire  [2:0] sel_main;	 // Last Granted Index + 1
	wire any_r;				 // Any Active Requests

	// High, if any one request is active
	assign any_r=request[0]|request[1]|request[2]|request[3]|request[4]|request[5]|request[6]|request[7];

/* 
--------------------------------------------------------------------------------------------------
 INDEX SERVICE
--------------------------------------------------------------------------------------------------
A combinational circuit of 8, 2-1 MUXs.

Data_in_1: 		3 Bit number, denoting the index of the mux. eg ( 010, for Index 2 MUX ) 
Data_in_0: 		Output from the preceeding MUX (in descending order) 
	       		or the output from last MUX in case of first MUX. ( Thus implementing ROUND ROBIN Algorithm )
sel:			Select Line, The bit corresponding to the Index of the MUX in the request vector.
Data_out:		If corresponding request is active, MUX output is the 3 bit INDEX of the MUX. If inactive, it outputs the
				preceeding active request index.

*/


mux2to1 i7(					//2-1 MUX with INDEX 7
	.Data_in_0(ind0),
	.Data_in_1(3'b111),
	.sel(request[7]),
	.Data_out(ind7)
);
mux2to1 i6(					//2-1 MUX with INDEX 6
	.Data_in_0(ind7),
	.Data_in_1(3'b110),
	.sel(request[6]),
	.Data_out(ind6)
);

mux2to1 i5(					//2-1 MUX with INDEX 5
	.Data_in_0(ind6),
	.Data_in_1(3'b101),
	.sel(request[5]),
	.Data_out(ind5)
);

mux2to1 i4(					//2-1 MUX with INDEX 4
	.Data_in_0(ind5),
	.Data_in_1(3'b100),
	.sel(request[4]),
	.Data_out(ind4)
);

mux2to1 i3(					//2-1 MUX with INDEX 3
	.Data_in_0(ind4),
	.Data_in_1(3'b011),
	.sel(request[3]),
	.Data_out(ind3)
);

mux2to1 i2(					//2-1 MUX with INDEX 2
	.Data_in_0(ind3),
	.Data_in_1(3'b010),
	.sel(request[2]),
	.Data_out(ind2)
);

mux2to1 i1(					//2-1 MUX with INDEX 1
	.Data_in_0(ind2),
	.Data_in_1(3'b001),
	.sel(request[1]),
	.Data_out(ind1)
);
mux2to1 i0(					//2-1 MUX with INDEX 0
	.Data_in_0(ind1),
	.Data_in_1(3'b000),
	.sel(request[0]),
	.Data_out(ind0)
);



/* 
--------------------------------------------------------------------------------------------------
 GRANT SERVICE
--------------------------------------------------------------------------------------------------
Implements the round robin arbitration scheme on the 8, 3 bit data lines representing each requester.
A full adder provides the selection line to the main mux, which selects the next input representing
a requester with weight 1.

The output of the Main Mux is feedbacked to the full adder, so that in the event that a line was skipped,
the adder would output the active index succeeding the last selected line, rather than just incrementing by one
which might result in the recently selected line being selected again.

The MUX output is stored in a 3 Bit PIPO register, such that the value is retained until the next clock cycle.

*/


/*
 Main MUX
 --------
 Selects an indexed data line depending on the full adder output
 8, 3 bit lines from the Index servie as 8 Inputs
*/
mux8to1 main_mux1(
	.Data_in_0(ind0),	
	.Data_in_1(ind1),
	.Data_in_2(ind2),
	.Data_in_3(ind3),
	.Data_in_4(ind4),
	.Data_in_5(ind5),
	.Data_in_6(ind6),
	.Data_in_7(ind7),
	.sel(sel_main),		// FULL Adder output
	.clk(clk),
	.Data_out(main_mux_out)
);



/*
 Last MUX (Final Granted Index Line)
 -----------------------------------
 Data_in_0:		If no request is active, it outputs the last granted request, whose value is 
 				stored in the register, from the preceeding clock cycle.
 Data_in_1:		If any of the requests is active, it outputs the currently granted request 
*/
mux2to1 lastmux(
	.Data_in_0(reg_out), 		// Output of the Register
	.Data_in_1(main_mux_out),   // Output of the Main MUX
	.sel(any_r),				// If any request is active
	.Data_out(last_mux_out)		
);



/*
 3-BIT REGISTER
 --------------
 Stores the currently granted request value, as outputed by the lastmux.
 If no requests are active, the register gives the stored value as input to the lastmux, which transfers
 the same into the register in the next clock cycle.

 Retains the last granted request over clock cycles through feedback mechanism.
*/
register bitshiftreg(
	.D(last_mux_out),
	.clk(clk),
	.enable(enable),
	.Q(reg_out)			// Given as feedback to the lastmux and as input to the decoder.
	
);



/*
 FULL ADDER
 ----------
 Increments the last granted request index by one.
 Skips counting the numbers correspnding to the Indexes that was skipped by the Grant MUX.
 Three bit output, Overflow bit is ignored. Cycles from 000 -> 111. 
*/
adder add(
	.inp1(reg_out),		// Value of the last granted request stored by the register
	.inp2(3'b001),		// Incrementing by 1
	.sum(sel_main)		// Selection line to the Main MUX in Grant service
);



/*
 3-8 DECODER
 -----------
 Decodes the three bit index line that was selected by the Grant service, to give an 8 bit number
 The 8 bit output is treated as the GRANT Vector, with a single 1, that corresponds to the index that was granted.
*/
decoder d1(
	
	.x(last_mux_out[2]),
	.y(last_mux_out[1]),
	.z(last_mux_out[0]),
	.d(grant)
);

endmodule

//_______________________________________________________________________________________________________________________

/*
 -----------------
 COMPONENT MODULES 
 -----------------
*/

// FULL ADDER [3 bit]
module adder( inp1 ,inp2 ,sum  );
	output reg [2:0] sum ;
	input [2:0] inp1 ;
	input [2:0] inp2 ; 
	wire [2:0] s;
	wire carry;
	always@(*)
		begin 
			if(inp1!=3'b111)
				
				sum=inp1+inp2;
			else
				sum=3'b000;
		end
endmodule

// 3-BIT PIPO Register
module register(input [2:0] D, input clk, input enable, output reg [2:0] Q); 
   always @(posedge clk) 
	begin 
		if (enable) 
		begin 
			Q <= D; 
		end 
		else Q <= 3'b000;
	end
endmodule


// 2-1 MUX [3 bit]
module mux2to1(
	Data_in_0,
	Data_in_1,
	sel,
	Data_out
	);
	input [2:0] Data_in_0;
	input [2:0] Data_in_1;
	input sel;
	output [2:0] Data_out;
	reg Data_out;
	always @(Data_in_0,Data_in_1,sel)
		begin
			if(sel == 0) 
				Data_out = Data_in_0;   
			else
				Data_out = Data_in_1;   
		end
endmodule

// 3-8 DECODER
module decoder(x,y,z,d);
	output [7:0]d;
	input x,y,z;
	assign d[0] = ~x & ~y & ~z;
	assign d[1] = ~x & ~y & z;
	assign d[2] = ~x & y & ~z;
	assign d[3] = ~x & y & z;
	assign d[4] =  x & ~y & ~z;
	assign d[5] =  x & ~y & z;
	assign d[6] =  x & y & ~z;
	assign d[7] =  x & y & z;
endmodule

// 8-1 MUX [3 bit]
module mux8to1(
		Data_in_0,
		Data_in_1,
		Data_in_2,
		Data_in_3,
		Data_in_4,
		Data_in_5,
		Data_in_6,
		Data_in_7,
		sel,
		clk,
		Data_out
		);
	input [2:0] Data_in_0;
	input [2:0] Data_in_1;
	input [2:0] Data_in_2;
	input [2:0] Data_in_3;
	input [2:0] Data_in_4;
	input [2:0] Data_in_5;
	input [2:0] Data_in_6;
	input [2:0] Data_in_7;
	input [2:0] sel;
	input clk;
	output [2:0] Data_out;
	reg Data_out;
	always @(sel)
		begin
			case (sel) 
				3'b000 : Data_out = Data_in_0; 
				3'b001 : Data_out = Data_in_1; 
				3'b010 : Data_out = Data_in_2; 
				3'b011 : Data_out = Data_in_3; 
				3'b100 : Data_out = Data_in_4; 
				3'b101 : Data_out = Data_in_5; 
				3'b110 : Data_out = Data_in_6; 
				3'b111 : Data_out = Data_in_7; 

				default : Data_out = 8'b00000000; 
			endcase  
		end
		
endmodule

//***************************************************************************************************
