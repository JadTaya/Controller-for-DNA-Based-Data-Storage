module compute_value(	input	logic	clk,
						input	logic	resetN,
						input	logic	start,
						input	logic [53:0] g,
						input	logic [5:0]	x,
			
						output	logic finishFlag,
						output	logic [5:0]	result		
);	

localparam size = 6;
logic start_d;
logic mul_flag,mul_start;
logic [size-1:0] mul_x1,mul_x2,mul_res,acc_in,acc_out;
mul_controller M(clk,resetN,mul_start,mul_x1,mul_x2,mul_flag,mul_res);
typedef enum logic [2:0] {IDLE,CALC_FUN,START_MUL,MUL,FINISH} State;
State currentState, nextState;

logic [5:0] x1_in,x1_out,msg_idx_in,msg_idx_out,tmp_res_in,tmp_res_out;


logic done_flag_in,done_flag_out;


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
		done_flag_out <= 0;
		x1_out <= 0;
		msg_idx_out <= 0;
		tmp_res_out <= 0;
		acc_out <= 0;
	end
	else begin 
		done_flag_out <= done_flag_in;
		x1_out <= x1_in;
		msg_idx_out <= msg_idx_in;
		tmp_res_out <= tmp_res_in;
		acc_out <= acc_in;
	end;
end

always_comb
begin

	done_flag_in = done_flag_out;
	x1_in = x1_out;
	msg_idx_in = msg_idx_out;
	tmp_res_in = tmp_res_out;
	mul_start = 0;
	mul_x1 = g[msg_idx_out-1 -: size] ^ acc_out;
	mul_x2 = x1_out;
	acc_in = acc_out;
	
	case(currentState)  
		IDLE:					if(start & !start_d) begin
									x1_in = x;
									msg_idx_in = 54;
									acc_in = g[53];
									mul_start = 0;
								    done_flag_in = 0;
									mul_start = 0;
									mul_x1 = 0;
									mul_x2 = 0;
									nextState = CALC_FUN;
								end
								else begin
									nextState = IDLE;
								end
		CALC_FUN:				begin 
								
									nextState = START_MUL;
								end
		START_MUL:				begin
									if(msg_idx_out != 6) begin 
										mul_x1 = g[msg_idx_out-1 -: size] ^ acc_out;
										mul_x2 = x1_out;
										mul_start = 1;
										nextState = MUL;
									end
									else begin
										tmp_res_in = acc_out ^ g[msg_idx_out-1 -: size];
										nextState = FINISH;
									end
								end
		
		MUL:				begin
								mul_start = 0;
								if(mul_flag) begin
									msg_idx_in = msg_idx_out - size;
									acc_in = mul_res;
									nextState = CALC_FUN;
								end
								else begin
									nextState = MUL;
								end
							end
								
		FINISH:				begin
								done_flag_in = 1;
								nextState = IDLE;
							end

		default: 			nextState = IDLE;
	endcase
end

assign result = tmp_res_out;
assign finishFlag = done_flag_out;
endmodule