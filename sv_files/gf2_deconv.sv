module gf2_deconv(	input	logic			clk,
					input	logic			resetN,
					input	logic			start,
					input	logic [63:0]	divident,
					input	logic [24:0]	divisor,
					
					output	logic 			finish_flag,
					output	logic [63:0]	quotient ,
					output	logic [63:0]	reminder
					
					
);

localparam [7:0] divisor_size = 25;
localparam [7:0] divident_size = 64;
logic[7:0] counter, idx;
logic [divisor_size-1:0] zero_array;
logic [divisor_size-1:0] diff, x_copy, y_copy;
logic [divident_size-1:0] x_original;
logic [63:0] Q, R;
logic flag;


always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		zero_array = 0;
		flag = 1;
		x_original = 0;
		x_copy = 0;
		y_copy = 0;
		diff = 0;
		Q = 0;
		R = 0;
		counter = 0;
		idx = 0;
	end
	else if (start) begin
		zero_array = 0;
		flag = 0;
		x_original = divident;
		x_copy = divident[divident_size-1 -: divisor_size];
		y_copy = divisor; // {y,64'd0};
		diff = 0;
		Q = 0;
		R = 0;
		idx = 0;
		counter = divident_size-divisor_size+1;
	end
	else 	begin
		if(counter != 0 & !flag) begin
			Q = Q << 1;
			if(x_copy[divisor_size-1] == 1) begin
				diff = x_copy ^ y_copy;
				Q[0] = 1'd1;
			end
			else begin
				diff = x_copy ^ zero_array;
				Q[0] = 1'd0;// not necessary it is just for understanding
			end
			x_copy = diff << 1;
			x_copy[0] = x_original[divident_size-divisor_size-idx-1];
			counter = counter - 1;
			idx = idx + 1;
		end
		else begin
			flag = 1;
			R = diff;
		end
	end
	
end

assign quotient = Q;
assign reminder = R;
assign finish_flag = flag;
endmodule