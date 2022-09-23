/*************************************************
*--- Jad Taya & Aslan Showgan
*--- May 2020
**************************************************/

/* 
* Module 'mul'
* Galois Field multiplier for GF[2^6],
* x and y are galoies field members (6 bit binary numbers).
* z, the result of multiplying x by y, but using bit-wise xor instead
* of normal addition, is not a GF[2^6] member by it self, but it represents
* a galois field member that we can find using gf_table (with the help of mul_controller).
*/


module mul(	input	logic		clk,
			input	logic		resetN,
			input	logic		start,
			input	logic [5:0]	x, 
			input	logic [5:0]	y,
			output	logic 		finish_flag,
			output	logic [10:0]z				
);

logic [10:0] tmp_z;
logic [10:0] tmp_x;
logic [5:0] tmp_y;
logic en;
logic flag;

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		tmp_x = 0;
		tmp_y = 0;
		en = 0;
		flag = 1;
		tmp_z = 0;
	end
	else if (start) begin
		tmp_x = x;
		tmp_y = y;
		en = 0;
		flag = 0;
		tmp_z = 0;
	end
	else begin
		if (tmp_y != 0) begin
			en = tmp_y % 2;
			if (en == 1) begin
				tmp_z = tmp_x ^ tmp_z;
			end
			tmp_x = tmp_x << 1;
			tmp_y = tmp_y >> 1;
		end
		else	begin
			flag = 1;
		end
	end
end

assign z = tmp_z;
assign finish_flag = flag;
endmodule