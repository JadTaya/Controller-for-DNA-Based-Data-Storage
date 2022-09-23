module key_equation_solver(		input	logic			clk,
								input	logic			resetN,
								input	logic			start,
								input	logic [53:0]	syndrome,
								
								output	logic 			finishFlag,
								output	logic [53:0]	g		
);


localparam[2:0] max_errors = 4;
localparam [2:0] size = 6;
localparam [53:0] ex = 54'b000001000000000000000000000000000000000000000000000000;
localparam [4:0] shift = max_errors*size;
logic flag_in, flag_out,initialized_flag;

logic [53:0] syn, g_buff, tmp_g;
logic start_d;
////////////////////////////////////////////////////////////////////

logic [53:0] syn_in, syn_out, g_buff_in, tmp_g_in, g_buff_out, tmp_g_out;
//reg [53:0] tmp_r0,tmp_r1,tmp_g0,tmp_g1;







/////////////////////////////////////////////////////////////////////
reg [53:0] 	r0_in,r0_out,r1_in,r1_out,g0_in,g0_out,g1_in,g1_out,R_in,R_out,Q_in,Q_out,r_check_in,r_check_out;
logic [53:0]	divident;
logic [47:0]	divisor;
logic [63:0]	quotient,remainder;
logic 			deconv_flag,deconv_start;
gf26_deconv dec(clk,resetN,deconv_start,divident,divisor,deconv_flag,quotient,remainder);
/////////////////////////////////////////////////////////////////////


logic start_mulArr,mulArr_flag;
logic [53:0] x_mulArr;
logic [47:0] y_mulArr;
logic [53:0] mulArr_res;
logic [53:0] tmp_mulArr_res_in,tmp_mulArr_res_out;
gf26_mul_array mulArrFun(clk,resetN,start_mulArr,x_mulArr,y_mulArr,mulArr_flag,mulArr_res);
////////////////////////////////////////////////////////////////////



typedef enum logic [4:0] {IDLE,START_DECONV,DECONV,MUL_ARRAY_START,MUL_ARRAY,SUBSTRACT,CHECK_STATE,ADVANCE,FINISH} State;
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
		
		syn_out <= 0;
		r0_out <= 0;
		r1_out <= 0;
		g0_out <= 0;
		g1_out <= 0;
		R_out <= 0;
		Q_out <= 0;
		g_buff_out <= 0;
		tmp_g_out <= 0; 
		flag_out <= 0;
		r_check_out <= 0;
		tmp_mulArr_res_out <=0;
		
		
		
		
	end
	else begin 
		syn_out <= syn_in;
		r0_out <= r0_in;
		r1_out <= r1_in;
		g0_out <= g0_in;
		g1_out <= g1_in;
		R_out <= R_in;
		Q_out <= Q_in;
		g_buff_out <= g_buff_in;
		tmp_g_out <= tmp_g_in;
		flag_out <= flag_in;
		r_check_out <= r_check_in;
		tmp_mulArr_res_out <= tmp_mulArr_res_in;
	end;
end


always_comb
begin
	

		syn_in = syn_out;
		r0_in = r0_out;
		r1_in = r1_out;
		g0_in = g0_out;
		g1_in = g1_out;
		R_in = R_out;
		Q_in = Q_out;
		g_buff_in = g_buff_out;
		tmp_g_in = tmp_g_out;
		flag_in = flag_out;
		r_check_in = r_check_out;
		tmp_mulArr_res_in = tmp_mulArr_res_out;
		
		initialized_flag = 0;
		deconv_start = 0;
		start_mulArr = 0;
		divident = r0_out;
		divisor = r1_out[47:0];
		x_mulArr = Q_out;
		y_mulArr = g1_out;
		
	case(currentState)  
		IDLE:					if(start & !start_d) begin
									initialized_flag = 0;
									syn_in = syndrome;
									r0_in = ex;
									r1_in = syndrome;
									g0_in = 0;
									g1_in = 1;
									R_in = 0;
									Q_in = 0;
									g_buff_in = 0;
									tmp_g_in = 0;
									flag_in = 0;
									deconv_start = 0;
									start_mulArr = 0;
									r_check_in = 0;
									nextState = START_DECONV;
								end
								else begin
									nextState = IDLE;
								end
		START_DECONV:			begin
									deconv_start = 1;
									divident = r0_out;
									divisor = r1_out[47:0];
									nextState = DECONV;
								end
		DECONV: 				begin
									deconv_start = 0;
									if(deconv_flag) begin
										R_in = remainder;
										r_check_in = remainder >> shift;
										Q_in = quotient;
										nextState = MUL_ARRAY_START;
									end
									else begin
										nextState = DECONV;
									end
								end
		MUL_ARRAY_START:		begin 
									start_mulArr = 1;
									x_mulArr = Q_out;
									y_mulArr = g1_out;
									nextState = MUL_ARRAY;
								end
		MUL_ARRAY:				begin
									start_mulArr = 0;
									if(mulArr_flag) begin
										tmp_mulArr_res_in = mulArr_res;
										nextState = SUBSTRACT;
									end
									else
										nextState = MUL_ARRAY;
								end
		SUBSTRACT:				begin 
									g_buff_in = tmp_mulArr_res_out ^ g0_out;
									initialized_flag = 1;
									nextState = CHECK_STATE;
								end
		CHECK_STATE:			if(r_check_out == 0) begin
									nextState = FINISH;
								end
								else begin
									nextState = ADVANCE;
								end
		ADVANCE:				begin
										r0_in = r1_out;
										r1_in = R_out;
										g0_in = g1_out;
										g1_in = g_buff_out;
										nextState = START_DECONV;
										
								end
		//AD:						begin 
					//					r0 =tmp_r0;
					//					r1 =tmp_r1;
					//					g0 =tmp_g0;
					//					g1 =tmp_g1;
					//					nextState = START_DECONV;
					//			end
		FINISH:					begin
									flag_in = 1;
									tmp_g_in = g_buff_out;
									nextState = IDLE;
								end

		default: 				nextState = IDLE;

	endcase
end

assign g = tmp_g_in;
assign finishFlag = flag_in;
endmodule