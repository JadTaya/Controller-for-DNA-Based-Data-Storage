module encoder(	input	logic			clk,
				input	logic			resetN,
				input	logic			start,
				input	logic [38:0]	message,
				
				output	logic 			finish_flag,
				output	logic [63:0]	encoded_msg			
);

localparam logic [4:0] poly_size = 25;
localparam logic [poly_size-1:0] genpoly = 25'b1110110110010011101110111;

typedef enum logic [2:0] {IDLE,START_DECONV,DECONV,ADD,FINISH} State;
State currentState, nextState;

logic [63:0] divident_in,divident_out;
logic [poly_size-1:0] divisor_in,divisor_out;
logic [63:0] quotient;
logic [63:0] reminder;
logic flag_in,flag_out, start_deconv, flag_deconv;
logic start_d;
logic [63:0] tmp_msg_in,tmp_msg_out;

gf2_deconv g(.clk(clk),
			 .resetN(resetN),
			 .start(start_deconv),
			 .divident(divident_in),
			 .divisor(divisor_in)
			 ,.finish_flag(flag_deconv),
			 .quotient(quotient),
			 .reminder(reminder)
			 );


always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)  begin
		currentState <= IDLE;	
		start_d <= 0;
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
		flag_out <= 0;
		divident_out <= 0;
		divisor_out <= 0;
	end
	else begin 
		tmp_msg_out <= tmp_msg_in;
		flag_out <= flag_in;
		divident_out <= divident_in;
		divisor_out <= divisor_in;
	end;
end

always_comb
begin
	tmp_msg_in = tmp_msg_out;
	flag_in = flag_out;
	start_deconv = 0;
	divident_in = divident_out;
	divisor_in = divisor_out;
	case(currentState)  
		IDLE:			if(start & !start_d) begin
							tmp_msg_in = message << poly_size-1;
							nextState = START_DECONV;
							flag_in = 0;
							start_deconv = 0;
						end
						else begin
							nextState = IDLE;
						end
		START_DECONV:	begin
							flag_in = 0;
							start_deconv = 1;
							divident_in = tmp_msg_out;
							divisor_in = genpoly;
							nextState = DECONV;
						end
		DECONV: 		begin
							start_deconv = 0;
							if(flag_deconv) begin
								nextState = ADD;
							end
							else begin
								nextState = DECONV;
							end
						end
		ADD:			begin
							tmp_msg_in = tmp_msg_out ^ reminder;
							nextState = FINISH;
						end
		FINISH:    	    begin
							flag_in = 1;
							nextState = IDLE;
						end
		default: 		nextState = IDLE; 
	endcase
end

assign encoded_msg = tmp_msg_out;
assign finish_flag = flag_out;
endmodule