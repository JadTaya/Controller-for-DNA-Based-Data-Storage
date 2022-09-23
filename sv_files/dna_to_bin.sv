module dna_to_bin(	input	logic			clk,
					input	logic			resetN,
					input	logic			start,
					input	logic [319:0]	dna	,
					
					output	logic 			finish_flag,
					output	logic [63:0]	binary_msg
);

typedef enum logic [2:0] {IDLE, TABLE1, TABLE2, UPDATE_INDEX} State;
State currentState, nextState;

localparam [7:0] A = "A";
localparam [7:0] C = "C";
localparam [7:0] G = "G";
localparam [7:0] T = "T";
logic done_flag_in, done_flag_out;
logic [7:0] tmp_byte_in,tmp_byte_out;
logic [2:0] byte_index_in, byte_index_out;
logic start_d;
logic [39:0] letters;
logic [63:0] tmp_msg_in, tmp_msg_out;

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
		done_flag_out <= 0;
		byte_index_out <= 0;
		tmp_byte_out <= 0;
	end
	else begin 
		done_flag_out <=  done_flag_in;
		byte_index_out <= byte_index_in;
		tmp_msg_out <= tmp_msg_in;
		tmp_byte_out <= tmp_byte_in;
	end
end

always_comb
begin
	
	done_flag_in = done_flag_out;
	byte_index_in = byte_index_out;
	tmp_msg_in = tmp_msg_out;
	tmp_byte_in = tmp_byte_out;
	letters = dna[((byte_index_out+1)*5*8)-1-:5*8];
	case(currentState)  
		IDLE:
					if(start & !start_d) begin
						byte_index_in = 7;
						done_flag_in = 0;
						tmp_msg_in = 0;
						tmp_byte_in = 0;
						nextState = TABLE1;
					end
					else begin
						nextState = IDLE;
					end
		TABLE1: begin
					
					case(letters[39-:8])
						A: tmp_byte_in[7-:2] = 2'b00;
						C: tmp_byte_in[7-:2] = 2'b01;
						G: tmp_byte_in[7-:2] = 2'b10;
						T: tmp_byte_in[7-:2] = 2'b11;
					endcase
					case(letters[31-:8])
						A: tmp_byte_in[5-:2] = 2'b00;
						C: tmp_byte_in[5-:2] = 2'b01;
						G: tmp_byte_in[5-:2] = 2'b10;
						T: tmp_byte_in[5-:2] = 2'b11;
					endcase
					case(letters[15-:8])
						A: tmp_byte_in[3-:2] = 2'b00;
						C: tmp_byte_in[3-:2] = 2'b01;
						G: tmp_byte_in[3-:2] = 2'b10;
						T: tmp_byte_in[3-:2] = 2'b11;
					endcase
					nextState = TABLE2;
				end
								
		TABLE2:	begin
					case(letters[23-:8])
						A:  begin
								case(letters[7-:8])
									A: tmp_byte_in[1-:2] = 2'b00;
									C: tmp_byte_in[1-:2] = 2'b01;
									G: tmp_byte_in[1-:2] = 2'b10;
									T: tmp_byte_in[1-:2] = 2'b11;
								endcase	
							end
						C:  begin
								case(letters[7-:8])
									A: tmp_byte_in[1-:2] = 2'b11;
									C: tmp_byte_in[1-:2] = 2'b00;
									G: tmp_byte_in[1-:2] = 2'b01;
									T: tmp_byte_in[1-:2] = 2'b10;
								endcase	
							end
						G:  begin
								case(letters[7-:8])
									A: tmp_byte_in[1-:2] = 2'b10;
									C: tmp_byte_in[1-:2] = 2'b11;
									G: tmp_byte_in[1-:2] = 2'b00;
									T: tmp_byte_in[1-:2] = 2'b01;
								endcase	
							end
						T:  begin
								case(letters[7-:8])
									A: tmp_byte_in[1-:2] = 2'b01;
									C: tmp_byte_in[1-:2] = 2'b10;
									G: tmp_byte_in[1-:2] = 2'b11;
									T: tmp_byte_in[1-:2] = 2'b00;
								endcase	
							end
					endcase
					tmp_msg_in[(byte_index_out+1)*8-1 -:8] = tmp_byte_in; 
					nextState = UPDATE_INDEX;
				end
	UPDATE_INDEX: begin
					if(byte_index_out!=0) begin
						byte_index_in = byte_index_out - 1;
						nextState = TABLE1;
					end
					else begin
						done_flag_in = 1;
						nextState = IDLE;
					end
				end
				
	default: 	nextState = IDLE;
	endcase
end

assign binary_msg = tmp_msg_out;
assign finish_flag = done_flag_out;
endmodule