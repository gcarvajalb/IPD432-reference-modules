module top #(
    parameter DELAY=5
    )
(
	input  logic   clock,
	input  logic   reset,
	input  logic   PB,      // inicio para comenzar a leer las direcciones
	output logic   pulse       // indica si hay una operacion en proceso
    );
    
    logic [2:0]   state_next, state; //para almacenar estados
    logic [7:0]   hold_state_delay;  //timer para retener la maquina de estados en un estado
                                   //por cierta cantidad de ciclos
    logic         hold_state_reset;  // resetear el timer para retener estado
                                     
    //state encoding
    localparam S0      = 3'd0;  // Modo espera
    localparam S1      = 3'd1;  // setea una direccion y espera
    localparam S2      = 3'd2;  // setea una direccion y espera
    localparam S3      = 3'd3;  // setea una direccion y espera
    localparam S4      = 3'd4;
   
    // Combo logic for FSM
    // Calcula hacia donde me debo mover en el siguiente ciclo de reloj basado en las entradas
    always@(*) begin
        //default assignments
        state_next = state;
	    pulse = 1'b0;
	    hold_state_reset= 1'b0;
		    	
    	case (state)
    		S0: 	begin
						
						if(PB) begin   // si se inicia una operacion, empieza lectura de datos
							state_next= S1;
							hold_state_reset = 1'b1;
						end
					end

			S1:  begin
			            // Verifica si el timer alcanzo el valor predeterminado para este estado
			            //  Si el timer no ha llegado a su maximo, se mantiene el estado actual
				        if ((PB && (hold_state_delay >= DELAY-1))) begin
                                state_next = S2;
                                hold_state_reset = 1'b1;
                         end 
                         else if (~PB)
                                state_next = S4;
                       
                   end

			S2:  begin
			 pulse=1'b1;
				        if (PB)
                            state_next = S3;
                        else
                            state_next = S0;
                        end

			S3:  begin
                        if ((PB && (hold_state_delay >= DELAY-1))) begin
                            state_next = S2;
                            hold_state_reset = 1'b1;
                        end
                        else if (~PB)
                            state_next = S0;
                        end
                        
			S4:  begin
                         pulse=1'b1;
                                    if (PB)
                                        state_next = S1;
                                    else
                                        state_next = S0;
                                    end                                
    	endcase
    end	

    //when clock ticks, update the state
    
    // bloque secuencial para la maquina de estados
    always@(posedge clock) begin
    	if(reset) 
    		state <= S0;
    	else 
    		state <= state_next;
	end
	
	
	// este contador se activa dependiendo del estado en que se encuentra la maquina principal
	// notar que tecnicamente es una maquina de estados, por lo que deberia tener logica combinacional y secuencia separada.
	// Sin embargo, la estructura de un contador es tan comun que se define esta macro base que sera reconocida por la herramienta.
	// En cierta forma, las estructuras estandarizadas permiten "violar las convenciones"
	always@(posedge clock) begin
	   if (reset || hold_state_reset) begin
	       hold_state_delay <= 8'd0;
	   end
	   else begin
	       if(state == S1 || state == S2 || state == S3)
	           hold_state_delay <= hold_state_delay + 8'd1;
	       else
	           hold_state_delay <= 8'd0;
	   end        
	end

endmodule