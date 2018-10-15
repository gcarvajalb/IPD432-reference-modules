`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// testbenches requires a module without inputs or outputs
// It's only a "virtual" module. We cannot implement hardware with this!!!
module testbench();
  
    // We need to give values at the inputs, so we define them as registers  
	reg clock;
	reg reset;
	reg PB;
	
	//The outputs are wires. We don't connect them to anything, but we need to 
	// declare them to visualize them in the output timing diagram
	wire       pulse; 
	
	// an instance of the Device Under Test
	top DUT(
        .clock (clock),
        .reset (reset),
        .PB (PB),
        .pulse (pulse)
        );
            
	// generate a clock signal that inverts its value every five time units
	always  #2 clock=~clock;
	
	//here we assign values to the inputs
	initial begin
		clock = 1'b0;
		reset = 1'b0;
		#60 reset = 1'b1;
        #30 reset = 1'b0;
		#50 PB = 1'b1;
		#100 PB = 1'b0;
		#50 PB = 1'b1;
		#3  PB = 1'b0;
	end

endmodule
