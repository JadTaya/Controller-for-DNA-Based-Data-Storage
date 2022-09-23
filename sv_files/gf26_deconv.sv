module gf26_deconv(	input	logic	clk,
					input	logic	resetN,
					input	logic	start,
					input	logic [53:0]	divident,
					input	logic [47:0]	divisor,
					output	logic finishFlag,
					output	logic [63:0]	quotient ,
					output	logic [63:0]	remainder
					
					
);
localparam [7:0] size = 6,dividentArray_size = 9,divisorArray_size = 8;
localparam [7:0] divident_size = dividentArray_size * size, divisor_size = divisorArray_size * size;//6*9
logic [7:0] divisor_realSize_in,divisor_realSize_out,index_in,index_out, shift;
int counter_in,counter_out,idx_in,idx_out;
//logic [divisor_size-1:0] zero_array = 0; not used !!!

logic [divisor_size-1:0] diff_in,diff_out,x_in,x_out,y_in,y_out;
logic [63:0] Q_in,Q_out, R_in,R_out;

logic start_mul,flag_mul,start_inv,start_mulArr;
logic flag_in,flag_out,mulArr_flag,mul_flag,inv_flag;
logic [size-1:0] x_inv,invY;
reg [size-1:0]tmp_invY_in,tmp_invY_out;
logic [size-1:0] x1_mul,x2_mul,mul_res,tmp_inv_mul_res_in,tmp_inv_mul_res_out;
logic [divident_size-1:0] x_original_in,x_original_out;
logic [divisor_size-1:0] y_original_in,y_original_out;
logic start_d;
logic [divident_size-1:0] x_mulArr;
logic [divisor_size-1:0] y_mulArr;
logic [53:0] mulArr_res;
logic [divisor_size-1:0]tmp_mulArr_res_in,tmp_mulArr_res_out;
logic clac_inv_flag;
typedef enum logic [4:0] {IDLE,START,UPDATE_SIZE,CALC_DIVSOR_SIZE,CALC_INV_START,CALC_INV,MUL_START,MUL,MUL_ARRAY_START,
								MUL_ARRAY,SUBSTRACT,ADVANCE,FINISH} State;
State currentState, nextState;


gf26_inverse invFun(clk,resetN,start_inv,x_inv, inv_flag,invY);
mul_controller M(clk,resetN,start_mul,x1_mul,x2_mul,mul_flag,mul_res);
gf26_mul_array mulArrFun(clk,resetN,start_mulArr,x_mulArr,y_mulArr,mulArr_flag,mulArr_res);
					
				
		

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
		flag_out <= 0;
		x_original_out <= 0;
		y_original_out <= 0;
		diff_out <= 0;
		Q_out <= 0;
		R_out <= 0;
		idx_out <= 0;
		divisor_realSize_out <= 0;
		counter_out <= 0;
		x_out <= 0;
		y_out <= 0;
		index_out <= 0;
		tmp_mulArr_res_out <= 0;
		tmp_inv_mul_res_out <= 0;
		tmp_invY_out <= 0;
	end
	else begin
		flag_out <= flag_in;
		x_original_out <= x_original_in;
		y_original_out <= y_original_in;
		diff_out <= diff_in;
		Q_out <= Q_in;
		R_out <= R_in;
		idx_out <= idx_in;
		divisor_realSize_out <= divisor_realSize_in;
		counter_out <= counter_in; 
		x_out <= x_in;
		y_out <= y_in;
		index_out <= index_in;
		tmp_mulArr_res_out <= tmp_mulArr_res_in;
		tmp_inv_mul_res_out <= tmp_inv_mul_res_in;
		tmp_invY_out <= tmp_invY_in;
	end
end









always_comb
begin
	flag_in = flag_out;
	x_original_in = x_original_out;
	y_original_in = y_original_out;
	diff_in = diff_out;
	Q_in = Q_out;
	R_in = R_out;
	idx_in = idx_out;
	divisor_realSize_in = divisor_realSize_out;
	counter_in = counter_out; 
	x_in = x_out;
	y_in = y_out;
	index_in = index_out;
	tmp_mulArr_res_in = tmp_mulArr_res_out;
	tmp_inv_mul_res_in = tmp_inv_mul_res_out;
	tmp_invY_in = tmp_invY_out;
	
	start_inv = 0;
	start_mul = 0;
	start_mulArr = 0;
	clac_inv_flag = 0;
	shift = 0;
	x1_mul = x_out[divisor_realSize_out-1 -: size];
	x2_mul = tmp_invY_out;

	x_mulArr = y_out;
	y_mulArr = tmp_inv_mul_res_out;
	x_inv = y_out[divisor_realSize_out-1 -: size];
	case(currentState)  
		IDLE:								if(start & !start_d) begin
												flag_in = 0;
												x_original_in = divident;
												y_original_in = divisor;
												diff_in = 0;
												Q_in = 0;
												R_in = 0;
												idx_in = 0;
												divisor_realSize_in = 0;
												counter_in = dividentArray_size-divisorArray_size+1;// +size instead of 1
												nextState = CALC_DIVSOR_SIZE;
												start_inv = 0;
												start_mul = 0;
												start_mulArr = 0;
												clac_inv_flag = 0;
												shift = 0;
											end
											else begin
												nextState = IDLE;
											end
		CALC_DIVSOR_SIZE: 					begin
												if(divisor >> size * 1 == 0) begin 
													divisor_realSize_in = 1*size;
													index_in = 1;
												end
												else if(divisor >> size * 2	== 0) begin 
													divisor_realSize_in = 2*size;
													index_in = 2;
												end
												else if(divisor >> size * 3 == 0) begin 
													divisor_realSize_in = 3*size;
													index_in = 3;
												end
												else if(divisor >> size * 4 == 0) begin 
													divisor_realSize_in = 4*size;
													index_in = 4;
												end
												else if(divisor >> size * 5 == 0) begin 
													divisor_realSize_in = 5*size;
													index_in = 5;
												end
												else if(divisor >> size * 6 == 0) begin 
													divisor_realSize_in = 6*size;
													index_in = 6;
												end
												else if(divisor >> size * 7 == 0) begin 
													divisor_realSize_in = 7*size;
													index_in = 7;
												end
												else begin 
													divisor_realSize_in = 8*size;
													index_in = 8;
												end
												
												nextState = UPDATE_SIZE;
											end
										
		
		
		UPDATE_SIZE:						begin
												shift = divisor_size - divisor_realSize_out;
												x_in = x_original_out[divident_size-1 -: divisor_size] >> shift;
												//x = x_original[divident_size-1 -: divisor_realSize];
												y_in = y_original_out;
												idx_in = index_out - divisorArray_size;
												counter_in = dividentArray_size-index_out + 1 ;
												nextState = START;
											end
		
		
		
		
		START:								begin 
												//y = y_original;
												if(counter_out != 0 & !flag_out) begin
													Q_in = Q_out << size;
													if(x_out[divisor_realSize_out-1 -: size] != 0) begin
														nextState = CALC_INV_START;
													end
													else begin
														tmp_mulArr_res_in = 0;
														tmp_inv_mul_res_in = 0;
														nextState = SUBSTRACT;
													end
												end
												else begin
													nextState = FINISH;
												end
											end
		CALC_INV_START:						begin
												// inv calc needed only one time it doesnt change
												if(!clac_inv_flag) begin
													start_inv = 1;
													x_inv = y_out[divisor_realSize_out-1 -: size];
													nextState = CALC_INV;
												end
												else begin 
													nextState = MUL_START;
												end
											end
		CALC_INV:							begin
												clac_inv_flag = 1;
												start_inv = 0;
												if(inv_flag) begin
													tmp_invY_in = invY;
													nextState = MUL_START;
												end
												else
													nextState = CALC_INV;
											end
		MUL_START:							begin 
												//if MSB B == MSB A we dont need to calc and we can substract instantly
												if( y_out[divisor_realSize_out-1 -: size] ==  x_out[divisor_realSize_out-1 -: size]) begin
													tmp_inv_mul_res_in = 1;
													tmp_mulArr_res_in = y_out;
													nextState = SUBSTRACT;
												end
												else begin
													start_mul = 1;
													x1_mul = x_out[divisor_realSize_out-1 -: size];
													x2_mul = tmp_invY_out;
													nextState = MUL;
												end
											end
		MUL:								begin
												start_mul = 0;
												if(mul_flag) begin
													tmp_inv_mul_res_in = mul_res;
													nextState = MUL_ARRAY_START;
												end
												else
													nextState = MUL;
											end
		MUL_ARRAY_START:					begin 
												start_mulArr = 1;
												x_mulArr = y_out;
												y_mulArr = tmp_inv_mul_res_out;
												nextState = MUL_ARRAY;
											end
		MUL_ARRAY:							begin
												start_mulArr = 0;
												if(mulArr_flag) begin
													tmp_mulArr_res_in = mulArr_res; //>> size;
													nextState = SUBSTRACT;
												end
												else
													nextState = MUL_ARRAY;
											end
		SUBSTRACT:							begin 
												diff_in = x_out ^ tmp_mulArr_res_out;
												Q_in = Q_out ^ tmp_inv_mul_res_out;
												nextState = ADVANCE;
											end
		ADVANCE:							begin
												x_in = diff_out << size;
												x_in[size-1:0] = x_original_out[divident_size-divisor_realSize_out-idx_out*size-1 -: size];/// need to check
												counter_in = counter_out - 1;
												idx_in = idx_out + 1;
												nextState = START;
											end
		FINISH:								begin
												flag_in = 1;
												R_in = diff_out;
												nextState = IDLE;
											end
		
		default: 							nextState = IDLE;
	endcase
	 
end

assign quotient = Q_in;
assign remainder = R_in;
assign finishFlag = flag_in;
endmodule