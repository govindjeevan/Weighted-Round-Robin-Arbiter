/*
BEHAVIORAL MODEL VERILOG CODE
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
The 8 bits of Request Vector, is traversed from LSB to MSB.
	- If a high is encountered, a Grant Vector with a single high bit corresponding to 
	  the index of the encountered high bit is outputed
	- If a low is encountered, then that bit of the request vector is skipped, to move to the next bit.

If enable is low, no grant occurs, that is, arbiter is inavtive.

*/





module VerilogBM_212_221 ( request, grant, clk, enable );

input clk;					// Clock Pulse
input enable;				// Enable Line
input wire [7:0] request;	// Request Vector, atmost 8 requesters at a time
output reg [7:0] grant;		// Grant Vector with 8 possible grants, atmost one at a time
integer i=0;				// Loop Variable

always @(posedge clk,posedge enable,request)	// The block executes at the positive edge of clock pulse/enable/request
begin
	if(enable==0)	//If circuit is disabled, no request is granted.
		begin
		grant=8'b00000000;
		i=0;
		end
	else if(enable==1)	//Enabled Circuit
		begin
			i=0;	//Loop Varible initiated to first request index
			for(i=0;i<=7;i=i+1)	//Looping through the request vector (in Round Robin Fashion.)
				begin
					if(request[i]==1'b1 && enable==1)	// 	Ignores inactive requests and executes at the first high bit
					begin
						case (i) //Assigns a high bit in the Grant Vector whose position is determined by the index of the High bit
						0 : grant = 8'b00000001;
						1 : grant = 8'b00000010; 
						2 : grant = 8'b00000100; 
						3 : grant = 8'b00001000; 
						4 : grant = 8'b00010000; 
						5 : grant = 8'b00100000; 
						6 : grant = 8'b01000000; 
						7 : grant = 8'b10000000; 
						default : grant = 8'b00000000; //If no high bit is encountered at any index, no request is granted 
						endcase
						#20; // Request is granted for 20s before moving to the next bit
					end
				end	
				
		end
end



endmodule
