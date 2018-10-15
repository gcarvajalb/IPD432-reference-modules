module PB_Debouncer_counter#(
 parameter DELAY=15,
 parameter DELAY_WIDTH = $clog2(DELAY)
 )
(
	input 	logic clk,
	input 	logic rst,
	input 	logic PB,
	output 	logic PB_pressed_status,
	output  logic PB_pressed_pulse,
	output  logic PB_released_pulse
 );
	
	logic PB_sync_aux, PB_sync;

///// Double flopping stage for synchronization
    always_ff @(posedge clk) begin
        if (rst) begin
            PB_sync_aux <= 1'b0;
            PB_sync     <= 1'b0;
        end
        else begin
            PB_sync_aux <= PB;
            PB_sync     <= PB_sync_aux;
        end
    end
/////////////////

    logic [DELAY_WIDTH-1:0] PB_cnt;
    logic PB_IDLE;
    logic PB_COUNT_MAX;
// When the push-button is pushed or released, increment the counter
// The counter has to be maxed out before we decide that the push-button state has changed

    assign PB_IDLE      = (PB_pressed_status==PB_sync);
    assign PB_COUNT_MAX = &PB_cnt;	// true when all bits of PB_cnt are 1's

    always_ff @(posedge clk) begin
        if (rst) begin
            PB_pressed_status <= 1'b0;
        end
        else
            if(PB_IDLE)
                PB_cnt <= 0;  // nothing's going on
            else begin
                PB_cnt <= PB_cnt + 'd1;  // something's going on, increment the counter
                if(PB_COUNT_MAX) PB_pressed_status <= ~PB_pressed_status;  // if the counter is maxed out, PB changed!
            end
     end

assign PB_pressed_pulse  = ~PB_IDLE & PB_COUNT_MAX & ~PB_pressed_status;
assign PB_released_pulse = ~PB_IDLE & PB_COUNT_MAX &  PB_pressed_status;

endmodule