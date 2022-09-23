module bin_to_dna(	input	logic			clk,
					input	logic			resetN,
					input	logic			start,
					input	logic [63:0]	binary_message,
					
					output	logic 			finish_flag,
					output	logic [319:0]	dna			
);


parameter ASCII_SIZE = 8;
parameter BYTE_SIZE = 8;

typedef enum logic [2:0] {IDLE, PRE, TABLE1, TABLE2, UPDATE_INDEX} State;
State currentState, nextState;

localparam [ASCII_SIZE-1:0] A = "A";
localparam [ASCII_SIZE-1:0] C = "C";
localparam [ASCII_SIZE-1:0] G = "G";
localparam [ASCII_SIZE-1:0] T = "T";
localparam [0:3][ASCII_SIZE-1:0] nucleotides = {"A", "C", "G", "T"};
logic done_flag_in, done_flag_out;
logic [BYTE_SIZE-1:0] tmp_byte_in,tmp_byte_out;
logic [2:0] byte_index_in,byte_index_out;
logic start_d;
logic [319:0] tmp_dna_in,tmp_dna_out;
logic [39:0] letters_in,letters_out;
logic [1:0] i_in,i_out;


always_ff@(posedge clk or negedge resetN) begin
	if(!resetN)  begin
		currentState <= IDLE;	
		start_d <= 0;
	end
	else begin 
		currentState <= nextState;
		start_d <= start;
	end;
end

always_ff@(posedge clk or negedge resetN) begin
	if(!resetN)  begin
		byte_index_out <= 0;
		tmp_dna_out <= 0;
		i_out <= 0;
		done_flag_out <= 0;
		letters_out <= 0;
		tmp_byte_out <= 0;
	end
	else begin 
		byte_index_out <= byte_index_in;
		tmp_dna_out <= tmp_dna_in;
		i_out <= i_in;
		done_flag_out <= done_flag_in;
		letters_out <= letters_in;
		tmp_byte_out <= tmp_byte_in;
	end;
end

always_comb 
begin	
	letters_in = letters_out;
	byte_index_in = byte_index_out;
	tmp_dna_in = tmp_dna_out;
	done_flag_in = done_flag_out;
	tmp_byte_in = tmp_byte_out;
	i_in = i_out;
	case(currentState)  
		IDLE:			begin
							if(start & !start_d) begin
								byte_index_in = BYTE_SIZE-1;
								done_flag_in = 0;
								tmp_dna_in = 0;
								i_in = 0;
								nextState = PRE;
							end
							else begin
								nextState = IDLE;
							end
						end				
		PRE:			begin
							tmp_byte_in = binary_message[(byte_index_out+1)*BYTE_SIZE-1 -:BYTE_SIZE];
							nextState = TABLE1;
						end
		TABLE1: 		begin
							//tmp_byte = binary_message[(byte_index_out+1)*BYTE_SIZE-1 -:BYTE_SIZE];
							case(tmp_byte_out[BYTE_SIZE-1-:2])
								2'b00: letters_in[5*ASCII_SIZE-1-:ASCII_SIZE] = A;
								2'b01: letters_in[5*ASCII_SIZE-1-:ASCII_SIZE] = C;
								2'b10: letters_in[5*ASCII_SIZE-1-:ASCII_SIZE] = G;
								2'b11: letters_in[5*ASCII_SIZE-1-:ASCII_SIZE] = T;
							endcase
							case(tmp_byte_out[BYTE_SIZE-3-:2])
								2'b00: letters_in[4*ASCII_SIZE-1-:ASCII_SIZE] = A;
								2'b01: letters_in[4*ASCII_SIZE-1-:ASCII_SIZE] = C;
								2'b10: letters_in[4*ASCII_SIZE-1-:ASCII_SIZE] = G;
								2'b11: letters_in[4*ASCII_SIZE-1-:ASCII_SIZE] = T;
							endcase
							case(tmp_byte_out[BYTE_SIZE-5-:2])
								2'b00: letters_in[2*ASCII_SIZE-1-:ASCII_SIZE] = A;
								2'b01: letters_in[2*ASCII_SIZE-1-:ASCII_SIZE] = C;
								2'b10: letters_in[2*ASCII_SIZE-1-:ASCII_SIZE] = G;
								2'b11: letters_in[2*ASCII_SIZE-1-:ASCII_SIZE] = T;
							endcase
								nextState = TABLE2;
						end				

		TABLE2:			begin
							letters_in[3*ASCII_SIZE-1-:ASCII_SIZE] = nucleotides[i_out];
							case(tmp_byte_out[BYTE_SIZE-7-:2])
								2'b00: letters_in[ASCII_SIZE-1-:ASCII_SIZE] = nucleotides[i_out];
								2'b01: letters_in[ASCII_SIZE-1-:ASCII_SIZE] = nucleotides[(i_out+1)%4];
								2'b10: letters_in[ASCII_SIZE-1-:ASCII_SIZE] = nucleotides[(i_out+2)%4];
								2'b11: letters_in[ASCII_SIZE-1-:ASCII_SIZE] = nucleotides[(i_out+3)%4];
							endcase				
							
							nextState = UPDATE_INDEX;
						end
		
		UPDATE_INDEX: 	begin
							tmp_dna_in[((byte_index_out+1)*5)*ASCII_SIZE-1-:40] = letters_out;
							if(((letters_out[5*ASCII_SIZE-1-:ASCII_SIZE] == letters_out[3*ASCII_SIZE-1-:ASCII_SIZE]) 
								&& (letters_out[4*ASCII_SIZE-1-:ASCII_SIZE] == letters_out[3*ASCII_SIZE-1-:ASCII_SIZE])) 
									|| (letters_out[2*ASCII_SIZE-1-:ASCII_SIZE] == letters_out[ASCII_SIZE-1-:ASCII_SIZE])) begin
								i_in = i_out + 1;
								nextState = TABLE2;
							end
							else begin
								if(byte_index_out!=0) begin
									byte_index_in = byte_index_out - 1;
									i_in = 0;
									nextState = PRE;
								end
								else begin
									done_flag_in = 1;
									nextState = IDLE;
								end
							end
						end
		 default: 		nextState = IDLE;
	endcase
end

assign dna = tmp_dna_out;
assign finish_flag = done_flag_out;
endmodule