/*************************************************
*--- Jad Taya & Aslan Showgan
*--- June 2020
**************************************************/

/* 
* Module 'gf26_mul_array'
* Galois Field multipication for GF[2^6],
* We perform the initial multipication, once it's done
* (it's finish_flag is raised) we access the table to find the 
* number represented by the result of the multipication.
*/

module gf26_mul_array(	input	logic			clk,
						input	logic			resetN,
						input	logic			start,
						input	logic [53:0]	x, 
						input	logic [47:0]	y,
						output	logic 			ready_flag,
						output	logic [53:0]	z
					
					
);

localparam [7:0] size = 6;
localparam [7:0] arrayX_size = 9;
localparam [7:0] arrayY_size = 8;
localparam [7:0] x_size = arrayX_size * size;//6*9
localparam [7:0] y_size = arrayY_size * size;//6*8
localparam [7:0] res_size = x_size;
logic start_Mul,flag_Mul,flag_in, flag_out;
logic [size-1:0] x1,x2,res;
logic [x_size-1:0] buff1_in,buff1_out;
logic [res_size-1:0] buff2_in,buff2_out;
logic [4:0] counterX_in,counterX_out, counterY_in,counterY_out;
logic [x_size-1:0] x_original_in,x_original_out;
logic [y_size:0] y_original_in,y_original_out;
logic start_d;
typedef enum logic [2:0] {IDLE,START,MUL2NUM,ADVANCE_X,ADVANCE_Y,SET_NEW_X,SET_NEW_Y,FINISH} State;
State currentState, nextState;

mul_controller M(clk,resetN,start_Mul,x1,x2,flag_Mul,res);

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
		x_original_out <= 0;
		y_original_out <= 0;
		counterX_out <= 0;
		counterY_out <= 0;
		buff2_out <= 0;
		buff1_out <= 0;	
		flag_out <= 0;
	end
	else begin
	
		x_original_out <= x_original_in;
		y_original_out <= y_original_in;
		counterX_out <= counterX_in;
		counterY_out <= counterY_in;
		buff2_out <= buff2_in;
		buff1_out <= buff1_in;
		flag_out <= flag_in;
	end
end

always_comb
begin

	flag_in = flag_out;
	x1 = x_original_out[(counterX_out*size-1) -: size];
	x2 = y_original_out[(counterY_out*size-1) -: size];
	start_Mul = 0;
	
	x_original_in = x_original_out;
	y_original_in = y_original_out;
	counterX_in = counterX_out;
	counterY_in = counterY_out;
	buff2_in = buff2_out;
	buff1_in = buff1_out;
	
	
	case(currentState)  
		IDLE:			begin 
							if(start & !start_d) begin
								x_original_in = x;
								y_original_in = y;
								counterX_in = arrayX_size;
								counterY_in = arrayY_size;
								flag_in = 0;
								buff2_in = 0;
								buff1_in = 0;
								start_Mul = 0;
								nextState = START;
							end
							else begin
								nextState = IDLE;
							end
						end
		
		START:			begin 
							start_Mul = 1;
							x1 = x_original_out[(counterX_out*size-1) -: size];
							x2 = y_original_out[(counterY_out*size-1) -: size];
							nextState = MUL2NUM;
						end
		MUL2NUM:		begin 
							start_Mul = 0;
							if(flag_Mul) begin
								nextState = ADVANCE_X;
							end
							else begin
								nextState = MUL2NUM;
							end
						end
		ADVANCE_X:		begin
							buff1_in = buff1_out ^ res;
							if(counterX_out != 1) begin
								nextState = SET_NEW_X;
							end
							else begin
								nextState = ADVANCE_Y;
							end
						end
		ADVANCE_Y:		begin 
							buff2_in = buff2_out ^ buff1_out;
							if(counterY_out != 1) begin
								counterX_in = arrayX_size;
								nextState = SET_NEW_Y;
							end
							else begin
								nextState = FINISH;
							end
						end
		SET_NEW_X:		begin
							buff1_in = buff1_out << size;
							counterX_in = counterX_out - 1;
							nextState = START;
						end
		SET_NEW_Y:		begin 
							buff2_in = buff2_out << size;
							buff1_in = 0;
							counterY_in = counterY_out - 1;
							nextState = START;
						end
		FINISH:			begin
							flag_in = 1;
							buff2_in = buff2_out ;//<< size;
							nextState = IDLE;
						end
	endcase
	
end

assign z = buff2_out;
assign ready_flag = flag_out;

endmodule