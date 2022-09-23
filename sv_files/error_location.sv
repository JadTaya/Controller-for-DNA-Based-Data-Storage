module error_location(		input	logic	clk,
							input	logic			resetN,
							input	logic			start,
							input	logic [53:0]	g,
											
							output	logic 			finishFlag,
							output	logic [63:0]	errorPosition		
);





localparam [3:0] size = 6;
logic [63:0] position_out,position_in, tmp_out,tmp_in;

logic flag_out,flag_in;

logic done_flag, start_d;
logic computeValue_start ,computeValue_flag;
logic [53:0] fun_out,fun_in;
logic [5:0]	x_out,x_in,computeValue_res, counter_out,counter_in;
compute_value cv(clk,resetN,computeValue_start,fun_in,x_in,computeValue_flag,computeValue_res);	
logic mul_flag,mul_start;
logic [size-1:0] mul_x1_out,mul_x1_in,mul_x2_out,mul_x2_in,mul_res,acc_out,acc_in;
mul_controller M2(clk,resetN,mul_start,mul_x1_in,mul_x2_in,mul_flag,mul_res);




typedef enum logic [4:0] {IDLE,START_EXP,EXP,CALC_FUN,MUL,ADVANCE_EXP,FINISH} State;
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
		position_out <= 0;
		tmp_out <= 0;
		flag_out <= 0;
		mul_x1_out <= 0;
		mul_x2_out <= 0;
		acc_out <= 0;
		fun_out <= 0;
		x_out <= 0;
		counter_out <= 0;
	end
	else begin 
		position_out <= position_in;
		tmp_out <= tmp_in;
		flag_out <= flag_in;
		mul_x1_out <= mul_x1_in;
		mul_x2_out <= mul_x2_in;
		acc_out <= acc_in;
		fun_out <= fun_in;
		x_out <= x_in;
		counter_out <= counter_in;
	end;
end

always_comb
begin
	position_in = position_out;
	tmp_in = tmp_out;
	flag_in = flag_out;
	mul_x1_in = mul_x1_out;
	mul_x2_in = mul_x2_out;
	acc_in = acc_out;
	fun_in = fun_out;
	x_in = x_out;
	counter_in = counter_out;
	computeValue_start = 0;
	mul_start = 0;
	case(currentState)  
		IDLE:					if(start & !start_d) begin
									position_in = 0;
									counter_in = 1;
									fun_in = g;
									mul_start = 0;
									computeValue_start = 0;
									nextState = START_EXP;
									acc_in = 1;
									tmp_in = 0;
									flag_in = 0;
								end
								else begin
									nextState = IDLE;
								end
		START_EXP:				begin
									if(counter_out == 1) begin
										x_in = 1;
										computeValue_start = 1;
										nextState = CALC_FUN;
									end
									else if(counter_out != 0) begin
										mul_x1_in = acc_out;
										mul_x2_in = 2;
										mul_start = 1;
										nextState = EXP;
									end
									else begin
										tmp_in = position_out;
										nextState = FINISH;
									end
								end
		EXP: 					begin
									mul_start = 0;
									if(mul_flag) begin
										x_in = mul_res;
										computeValue_start = 1;
										nextState = CALC_FUN;
									end
									else begin
										nextState = EXP;
									end
								end
		CALC_FUN:				begin 
									computeValue_start = 0;
									if(computeValue_flag) begin
										if(computeValue_res == 0) begin
											position_in = position_out ^ 64'b1000000000000000000000000000000000000000000000000000000000000000; 
										end
										nextState = ADVANCE_EXP;
									end
									else begin
										nextState = CALC_FUN;
									end
								end
		
		ADVANCE_EXP:			begin
									counter_in = counter_out + 1;
									acc_in = x_out;
									position_in = position_out >> 1;
									nextState = START_EXP;
								end
								
								
		FINISH:					begin
									flag_in = 1;
									nextState = IDLE;
								end

		default: 				nextState = IDLE;

	endcase
end

assign errorPosition = tmp_in;
assign finishFlag = flag_in;
endmodule