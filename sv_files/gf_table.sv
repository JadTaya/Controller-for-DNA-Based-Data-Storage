/*************************************************
*--- Jad Taya & Aslan Showgan
*--- May 2020
**************************************************/

/* 
* Module 'gf_table'
* A Galois Field table for GF[2^6],
* It is used in multipication in GF[2^6],
* by mapping the result of the multipication into a
* 6 bit nuumber using the table.
*/

module gf_table (	input	logic		 clk,
					input	logic		 resetN,
					input	logic		 start,
					input	logic [10:0] x, 
					
					output	logic [5:0]	 z,
					output	logic 		 finish_flag
);


localparam [0:64][5:0]gf_2_6_table =
						{6'b000001,6'b000010,6'b000100,6'b001000,6'b010000,6'b100000,6'b000011,6'b000110,6'b001100,
						6'b011000,6'b110000,6'b100011,6'b000101,6'b001010,6'b010100,6'b101000,6'b010011,6'b100110,
						6'b001111,6'b011110,6'b111100,6'b111011,6'b110101,6'b101001,6'b010001,6'b100010,6'b000111,
						6'b001110,6'b011100,6'b111000,6'b110011,6'b100101,6'b001001,6'b010010,6'b100100,6'b001011,
						6'b010110,6'b101100,6'b011011,6'b110110,6'b101111,6'b011101,6'b111010,6'b110111,6'b101101,
						6'b011001,6'b110010,6'b100111,6'b001101,6'b011010,6'b110100,6'b101011,6'b010101,6'b101010,
						6'b010111,6'b101110,6'b011111,6'b111110,6'b111111,6'b111101,6'b111001,6'b110001,6'b100001,
						6'b000001,6'b000000};	
logic [10:0] tmp_x;	
logic [5:0] index;	
logic [5:0] tmp_z;
logic flag;

always_ff@(posedge clk or negedge resetN)
begin	
	if (!resetN) begin
		tmp_x <= 0;
		flag <= 1;
		tmp_z <= 0;
		index <= 0;
	end
	else if (start) begin
		tmp_x <= x;
		flag <= 0;
		tmp_z <= 0;
		index <= 0; 	
	end
	else 	begin
		if (tmp_x != 0)
		begin
			if(tmp_x % 2 != 0) begin
				tmp_z <= gf_2_6_table[index] ^ tmp_z;
			end 
			tmp_x <= tmp_x >> 1;
			index <= index + 1; 
		end 
		else begin 
			flag <= 1;
		end
	end
end

assign z = tmp_z;
assign finish_flag = flag;

endmodule