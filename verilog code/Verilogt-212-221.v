/*
TESTBENCH
----------------------------------
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
-----------------------
	Common test bench for both behavioral and dataflow modelled arbiter modules. Outputs are displated into the terminal and also
	can be observed by opening the dumpfiles in gtkwave.
*/

module Verilog_212_221();	//TEST MODULE
	reg [7:0] request;		// REQUEST VECTOR. HIGHs INDICATE ACTIVE REQUESTS
	reg enable,clk;			// GRANT VECTOR. HIGH INDICATE THE GRANTED VECTOR
	wire [7:0] grant;

	//VerilogBM_212_221 Verilog_212_221(request,grant,clk,enable);			//UNCOMMENT FOR BEHAVIORAL TESTING
	VerilogDM_212_221 Verilog_212_221(request,grant,clk,enable);			//UNCOMMENT FOR DATAFLOW TESTING
	initial
		begin
			$dumpfile("project.vcd");
			$dumpvars(0,Verilog_212_221);
			clk = 1'b1;			//CLOCK IS INITIALLY HIG
			repeat (100)		//CLOCK PULSE IS CHANGED 100 TIMES AT AN INTERVAL OF 10s
			#10 clk = ~clk;
			
		end
	initial
		begin
			enable=0;
			
			// CIRCUIT IS ENABLED.
			#20;
			enable=1;
			
			// ACTIVE REQUESTS BY 1 and 5
			request=8'b10001000;
			#200;

			// CHANGING THE REQUESTERS
			enable=0;
			#20;
			enable=1;
			request=8'b11100111;
			#200;

			// CHANGING THE REQUESTERS
			enable=0;
			#20;
			enable=1;
			request=8'b00001000;
			#200;

			// CHANGING THE REQUESTERS
			enable=0;
			#20;
			enable=1;
			request=8'b00100010;
			#200;
		end
	initial
		#1000	//TESTBENCH RUNS FOR 1000s
		$finish;

	always@(request)
		$monitor("\n\tREQUEST VECTOR: %b\tGRANT VECTOR: %b\n",request,grant );	//DISPLAYING THE ARBITRATION RESULT FOR EACH NEW GRANT
endmodule
