/*************************************************
*--- Jad Taya & Aslan Showgan
*--- June 2020
**************************************************/

/* 
* Module 'gf26_exp'
* Exponentation in GF(2^6)
*/

module gf26_exp(input	logic		clk,
				input	logic		resetN,
				input	logic		start,
				input	logic [5:0]	base, 
				input	logic [5:0]	power,
				output	logic [5:0]	ex,
				output	logic		ready_flag
					
);
logic start_Mul;
logic flag_Mul;
logic flag;
logic [5:0] b;
logic [5:0] x;
logic [5:0] p;
logic [5:0] z;
logic [5:0] res;
mul_controller MC(clk,resetN,start_Mul,b,x,flag_Mul,z);
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		b <= 0;
		p <= 0;
		x <= 0;
		start_Mul <= 0;
		flag <= 0;
	end
	else if (start) begin
		start_Mul <= 1;
		b <= base;
		x <= 1;
		p <= power;
		flag <= 0;
	end
	else 	begin
		if(p == 1 & flag_Mul) begin 
			flag <= 1;
			res <= z;
			start_Mul <= 0;
		end
		else if(start_Mul)
			start_Mul <= 0;
		else if(flag_Mul) begin
			x <= z;
			p <= p - 1;
			start_Mul <= 1;
		end
		
	end
end

assign ex = res;
assign ready_flag = flag;
endmodule