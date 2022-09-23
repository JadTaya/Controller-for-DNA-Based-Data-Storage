module syndrome_calculation(		input	logic	clk,
								input	logic			resetN,
								input	logic			start,
								input	logic [63:0]	message,
								
								
								output	logic 			finishFlag,
								output	logic [53:0]	syndrome		
);
logic [47:0] syn_in,syn_out;
localparam max_error = 4,size = 6;
logic [3:0] counter_in,counter_out;
logic start_d;
logic [6:0] msg_idx_in,msg_idx_out;
logic [63:0] msg_in,msg_out;
logic [size-1:0] sum_in,sum_out;
logic flag_in,flag_out;
logic [53:0] tmp_msg_in,tmp_msg_out;
logic done_flag_in,done_flag_out;
//logic	exp_start=0;
//logic exp_flag;
//logic [5:0]	base = 0;
logic [5:0]	alpha_in,alpha_out;
localparam [0:7] [5:0]	 ex = {6'b000010, 6'b000100, 6'b001000, 6'b010000, 6'b100000, 6'b000011,  6'b000110, 6'b001100};
//gf26_exp eex(clk,resetN,exp_start,base,power,ex,exp_flag);


logic mul_flag,mul_start;
logic [size-1:0] mul_x1,mul_x2,mul_res;
mul_controller synMul(clk,resetN,mul_start,mul_x1,mul_x2,mul_flag,mul_res);
typedef enum logic [2:0] {IDLE,START_EXP,EXP,CALC_FUN,START_MUL,MUL,ADVANCE_EXP,FINISH} State;
State currentState, nextState;

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
		msg_out <= 0;
		counter_out <= 0;
		msg_idx_out <= 0;
		flag_out <= 0;
		sum_out <= 0;
		tmp_msg_out <= 0;
		syn_out <= 0;
		done_flag_out <= 0;
		alpha_out <= 0;
	end
	else begin 
		msg_out <= msg_in;
		counter_out <= counter_in;
		msg_idx_out <= msg_idx_in;
		flag_out <= flag_in;
		sum_out <= sum_in;
		tmp_msg_out <= tmp_msg_in;
		syn_out <= syn_in;
		done_flag_out <= done_flag_in;
		alpha_out <= alpha_in;
	end;
end

always_comb
begin

	msg_in = msg_out;
    counter_in = counter_out;
    msg_idx_in = msg_idx_out;
	flag_in = flag_out;
	sum_in = sum_out;
	tmp_msg_in = tmp_msg_out;
	syn_in = syn_out;
	done_flag_in = done_flag_out;
	alpha_in = alpha_out;
	mul_start = 0;
	mul_x1 = sum_out;
	mul_x2 = alpha_out;
	case(currentState)  
		IDLE:					if(start & !start_d) begin
									msg_in = message;
									counter_in = 0;
									msg_idx_in = 63;
									//exp_start = 0;
									mul_start = 0;
									flag_in = 0;
									sum_in = 0;
									tmp_msg_in = 0;
									syn_in = 0;
									nextState = START_EXP;
									done_flag_in = 0;
								end
								else begin
									nextState = IDLE;
								end
		START_EXP:				begin
									msg_idx_in = 63;
									alpha_in = ex[counter_out];
									nextState = EXP;
									done_flag_in = 0;
								end
		EXP: 					begin
									sum_in = msg_out[msg_idx_out];
									nextState = CALC_FUN;
								end
		CALC_FUN:				begin 
									if(msg_idx_out == 0) begin
                                        done_flag_in = 1;
									end
									msg_idx_in = msg_idx_out - 1;
									nextState = START_MUL;
								end
		
		START_MUL:				begin
									if(!done_flag_out) begin 
									mul_x1 = sum_out;
									mul_x2 = alpha_out;
									mul_start = 1;
									nextState = MUL;
									end
									else begin
										syn_in = syn_out ^ sum_out;
										nextState = ADVANCE_EXP;
									end
								end
		
		MUL:				begin
								mul_start = 0;
								if(mul_flag) begin
									sum_in = msg_out[msg_idx_out] ^ mul_res;
									nextState = CALC_FUN;
								end
								else begin
									nextState = MUL;
								end
							end
								
		ADVANCE_EXP:		begin
								if(counter_out < 2*max_error-1) begin
									syn_in = syn_out << size;
									counter_in = counter_out + 1;
									nextState = START_EXP;
								end
								else begin
									tmp_msg_in = syn_out;
									nextState = FINISH;
								end
							end
		FINISH:				begin
								flag_in = 1;
								nextState = IDLE;
							end


	endcase
end

assign syndrome = tmp_msg_out;
assign finishFlag = flag_in;
endmodule