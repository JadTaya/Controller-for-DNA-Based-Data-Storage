/*************************************************
*--- Jad Taya & Aslan Showgan
*--- May 2020
**************************************************/

/* 
* Module 'mul_controller'
* A controller for Galois Field multipication for GF[2^6],
* We perform the initial multipication, once it's done
* (it's finish_flag is raised) we access the table to find the 
* number represented by the result of the multipication.
*/

module mul_controller(	input	logic		clk,
						input	logic		resetN,
						input	logic		start,
						input	logic [5:0]	x, 
						input	logic [5:0]	y,
						output	logic 		ready_flag,
						output	logic [5:0]	z			
);
logic start_mul;
logic start_gf_table;
logic flag_mul;
logic flag_gf_table;
logic flag_in,flag_out, flag;
logic [5:0] x1,x1_in,x1_out;
logic [5:0] x2,x2_in,x2_out;
logic [10:0] x_gf_table,z_in,z_out;
logic [10:0] z_mul;
logic [5:0] z_gf_table ;

mul m(	.clk(clk),
		.resetN(resetN),
		.start(start_mul),
		.x(x1),
		.y(x2),
		.finish_flag(flag_mul),
		.z(z_mul)
		);

gf_table cal_result (.clk(clk),
					.resetN(resetN),
					.start(start_gf_table),
					.x(x_gf_table),
					.z(z_gf_table),
					.finish_flag(flag_gf_table)
					);
					
logic start_d;
typedef enum logic [1:0] {IDLE,MUL,GF_TABLE} State;
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
		x2_out <= 0;
		flag_out <= 0;
		z_out <= 0;
	end
	else begin
		x1_out <= x1_in;
		x2_out <= x2_in;
		flag_out <= flag_in;
		z_out <= z_in;
	end
end

always_comb
begin

	x1_in = x1_out;
	x2_in = x2_out;
	z_in = z_out;
	
	start_mul = 0;
	start_gf_table = 0;
	x1 = x1_out;
	x2 = x2_out;
	x_gf_table = z_out;
	flag_in = flag_out;
	case(currentState) 
		IDLE:		if(start & !start_d) begin
						x1 = x;
						x2 = y;
						x1_in = x;
						x2_in = y;
						start_mul = 1;
						start_gf_table = 0;
						flag_in = 0;
						flag = 0;
						nextState = MUL;
					end
					else begin
						nextState = IDLE;
					end
		MUL:		if(flag_mul) begin
						start_gf_table = 1;
						x_gf_table = z_mul;
						z_in = z_mul;
						nextState = GF_TABLE;
					end
					else begin
						nextState = MUL;
					end
		GF_TABLE:	
					if(flag_gf_table) begin	
						flag_in = 1;
						flag = 1;
						nextState = IDLE;
					end
					else begin 
						nextState = GF_TABLE;
					end
		default: 	nextState = IDLE;
	endcase
	
end

assign z = z_gf_table;
assign ready_flag = flag_in;

endmodule