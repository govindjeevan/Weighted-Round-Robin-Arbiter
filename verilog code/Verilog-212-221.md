-----------------------------------------------
											
WEIGHTED ROUND ROBIN ARBITER 
												
-----------------------------------------------
Mini-Project: CO202 - Design Of Digital Systems
-----------------------------------------------
Reg:       	
GOVIND JEEVAN       16CO221
BIDYADHAR MOHANTY   16CO212
-----------------------------------------------
_____________
_____________

INSTRUCTIONS
_____________
_____________

1. The testbench instantiates the Behavioral model by default. DataFlow Model can be instantiated by uncommenting it's instantiation and commenting that of Behavioral.

2. The .vcd dumpfile will contain the waveforms of Enable, Clock, Request, Grant. Summon these into the display window of gtkwave in this order to view the arbitration process.

3. CHANGE THE DATATYPE of Request and Grant waveforms to Binary.

4. If the request vector is 10001000, the grant vector will start as 00001000, granting request four first, then change to 10000000, granting request 8, and then changes again
   to 00001000, granting request 4 again, thus moving in round robin fashion, skipping any inactive request. 
   
   
	To execture verilog-code
	Open terminal in the source folder.
	
	Behavioral:
		
		iverilog VerilogBM-212-221.v Verilogt-212-221.v
		vvp a.out
	
	Dataflow:
		iverilog VerilogDM-212-221.v Verilogt-212-221.v
		vvp a.out
