/*************************************************
*--- Jad Taya & Aslan Showgan
*--- June 2020
**************************************************/

/* 
* Module 'gf26_inverse'
* Returns the inverse of x. Because
* x is a GF(2^6) member, it's inverse 
* is x^(2^6 - 2).
*/


module gf26_inverse(input	logic		clk,
					input	logic		resetN,
					input	logic		start,
					input	logic [5:0]	x, 
					output	logic 		finish_flag,
					output	logic [5:0]	z
								
);

parameter m = 6;
logic start_d;
logic start_exp, exp_flag, flag_in,flag_out;
logic [5:0] power, base, ex;
logic [5:0]	x1_in,x1_out, tmp_in,tmp_out;

gf26_exp e( .clk(clk),
			.resetN(resetN),
			.start(start_exp),
			.base(base),
			.power(power),
			.ex(ex),
			.ready_flag(exp_flag)
			);	

typedef enum logic [1:0] {IDLE,START,POWER_CALC} State;
State currentState, nextState;

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)  begin
		currentState <= IDLE;	
	end
	else begin
		currentState <= nextState;
		start_d <= start;
	end
end

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)  begin
		x1_out <= 0;
		flag_out <= 0;
		tmp_out <= 0;
	end
	else begin
		x1_out <= x1_in;
		flag_out <= flag_in;
		tmp_out <= tmp_in;
	end
end



always_comb
begin
	x1_in = x1_out;
	flag_in = flag_out;
	tmp_in = tmp_out;
	start_exp = 0;
	base = x1_out;
	power = 2**m-2;
	case(currentState) 
		IDLE:  			if(start & !start_d) begin
							x1_in = x;
							flag_in = 0;
							start_exp = 0;
							nextState = START;
						end
						else begin
							nextState = IDLE;
						end
		START: 				begin
							start_exp = 1;
							base = x1_out;
							power = 2**m-2;
							nextState = POWER_CALC;
						end
		POWER_CALC:		begin
							start_exp = 0;
							if(exp_flag) begin
								tmp_in = ex;
								flag_in = 1;
								nextState = IDLE;
							end
							else
								nextState = POWER_CALC;
						end			
		default: 		nextState = IDLE;
	endcase
	
end
assign z = tmp_out;
assign finish_flag = flag_out;
endmodule