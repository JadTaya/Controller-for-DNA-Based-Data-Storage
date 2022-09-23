module decoder(	    input	logic			clk,
					input	logic			resetN,
					input	logic			start,
					input	logic [63:0]	recieved_message,
					
					output	logic 			finish_flag,
					output	logic [38:0]	decoded_msg			
);

typedef enum logic [2:0] {IDLE, SYNDROME_CALCULATION, KEY_EQUATION_SOLVER, ERROR_LOCATION, FINISH} State;
State currentState, nextState;

logic done_flag_in,done_flag_out;
logic [63:0] tmp_msg_in,tmp_msg_out;
logic start_d;
logic sc_start_in, sc_start_out, kes_start_in, kes_start_out, el_start_in, el_start_out;
logic [63:0] message_in,message_out;

logic sc_finishFlag, kes_finishFlag, el_finishFlag;
logic [53:0] syndrome;
logic [53:0] g;	
logic [63:0] errorPosition;

syndrome_calculation sc(clk, resetN, sc_start_out, message_out, sc_finishFlag, syndrome);
key_equation_solver kes(clk, resetN, kes_start_out, syndrome, kes_finishFlag, g);
error_location el(clk, resetN, el_start_out, g, el_finishFlag, errorPosition);


always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)  begin
		currentState <= IDLE;	
		start_d <= 1'b0;
	end
	else begin 
		currentState <= nextState;
		start_d <= start;
	end;
end

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)  begin
		tmp_msg_out <= 0;
		message_out <= 0;
		done_flag_out <= 0;
		sc_start_out <= 0;
		kes_start_out <= 0;
		el_start_out <= 0;
	end
	else begin 
		tmp_msg_out <= tmp_msg_in;
		message_out <= message_in;
		done_flag_out <= done_flag_in;
		sc_start_out <= sc_start_in;
		kes_start_out <= kes_start_in;
		el_start_out <= el_start_in;
	end;
end

always_comb
begin

	tmp_msg_in = tmp_msg_out;
	message_in = message_out;
	done_flag_in = done_flag_out;
	sc_start_in = sc_start_out;
	kes_start_in = kes_start_out;
	el_start_in = el_start_out;
	case(currentState)  
		IDLE:			 		if(start & !start_d) begin
									tmp_msg_in = recieved_message;
									message_in = recieved_message;
									done_flag_in = 1'b0;
									sc_start_in = 1'b1;
									kes_start_in = 1'b0;
									el_start_in = 1'b0;		
									nextState = SYNDROME_CALCULATION;
								end
								else begin
									sc_start_in = 1'b0;
									kes_start_in = 1'b0;
									el_start_in = 1'b0;
									nextState = IDLE;
								end
								
		SYNDROME_CALCULATION:	begin
									//sc_start = 1'b0;
									if(sc_finishFlag) begin
									    if(syndrome == 0) begin
											done_flag_in = 1'b1;
											nextState = IDLE;
										end
										else begin
											kes_start_in = 1'b1;
											nextState = KEY_EQUATION_SOLVER;
										end
									end
									else begin
										nextState = SYNDROME_CALCULATION;
									end
								end
								
		KEY_EQUATION_SOLVER: 	begin
									//kes_start = 1'b0;
									if(kes_finishFlag) begin
									    if(g == 0) begin
											done_flag_in = 1'b1;
											nextState = IDLE;
										end
										else begin
											el_start_in = 1'b1;
											nextState = ERROR_LOCATION;
										end
									end
									else begin
										nextState = KEY_EQUATION_SOLVER;
									end
								end
								
		ERROR_LOCATION:			begin
									//el_start = 1'b0;
									if(el_finishFlag) begin
										tmp_msg_in = tmp_msg_out ^ errorPosition;
										nextState = FINISH;
									end
									else begin
										nextState = ERROR_LOCATION;
									end
								end
		FINISH: 	begin
						done_flag_in = 1'b1;
						nextState = IDLE;
					end
		default: 	nextState = IDLE;
		
	endcase
end

assign decoded_msg = tmp_msg_out[63:24];
assign finish_flag = done_flag_out;
endmodule