localparam int MESSAGE_SIZE = 39; //The size of the message according to BCH(63,39).
localparam int ENCODED_SIZE = 64; //The size of the encoded message according to BCH(63,39).
localparam int NUM_OF_NUCLEOTIDES = 40;	//Need a NUM_OF_NUCLEOTIDES*ASCII_SIZE size array to represent the DNA strand 
localparam int ASCII_SIZE = 8;			//that resembles 64 binary bits.


module DNA_Controller (	input	logic											clk,
				input	logic											resetN,
				input	logic 	[1:0]									mode, // 0 - Idle 1 - start Encoding + bin2Dna 2 - start dna2Bin + Decoding  
				input	logic  	[MESSAGE_SIZE-1:0] 						write_in,		// bin message to write to memory
				input	logic  	[NUM_OF_NUCLEOTIDES*ASCII_SIZE-1:0] 	read_in, //  DNA message to read from memory
				
				output 	logic	[NUM_OF_NUCLEOTIDES*ASCII_SIZE-1:0] 	write_out, // DNA written to memory 
				output 	logic	[MESSAGE_SIZE-1:0] 						read_out, // bin recoverd from memory					
				output 	logic 											finish_flag
);


logic start_encoder, start_bin_to_dna, start_dna_to_bin, start_decoder;
logic finish_flag_encoder, finish_flag_bin, finish_flag_dna, finish_flag_decoder;

logic [ENCODED_SIZE-1:0] encoded_msg, msg_to_decode;


typedef enum logic [2:0] {IDLE, ENCODER, START_ENCODER, BIN, START_DNA, DNA, DECODER} State;
State currentState, nextState;

logic finish_flag_in,finish_flag_out;

encoder en(.clk(clk),
		   .resetN(resetN),
		   .start(start_encoder),
		   .message(write_in),
		   .finish_flag(finish_flag_encoder),
		   .encoded_msg(encoded_msg)
		   );

bin_to_dna bin2dna(.clk(clk),
				   .resetN(resetN),
				   .start(start_bin_to_dna),
				   .binary_message(encoded_msg),
				   .finish_flag(finish_flag_bin),
				   .dna(write_out)
				   );

dna_to_bin dna2bin(.clk(clk),
				   .resetN(resetN),
				   .start(start_dna_to_bin),
				   .dna(read_in),
				   .finish_flag(finish_flag_dna),
				   .binary_msg(msg_to_decode)
				   );
				   
decoder de(.clk(clk),
		   .resetN(resetN),
		   .start(start_decoder),
		   .recieved_message(msg_to_decode),
		   .finish_flag(finish_flag_decoder),
		   .decoded_msg(read_out)
		   );
		   




always_ff@(posedge clk or negedge resetN) begin	
	if(!resetN) begin
		currentState <= IDLE;
	end
	else begin
		currentState <= nextState;
	end
end

always_ff@(posedge clk or negedge resetN) begin	
	if(!resetN) begin
		finish_flag_out <= 0;
	end
	else begin
		finish_flag_out <= finish_flag_in;
		
	end
end

always_comb 
begin
	finish_flag_in = finish_flag_out;
	start_encoder = 0;
	start_bin_to_dna = 0;
	start_dna_to_bin = 0;
	start_decoder = 0;
	case(currentState)  
			
		IDLE: 			begin
								if (mode == 1) begin
									finish_flag_in = 0;
									nextState = START_ENCODER;
								end
								else if (mode == 2) begin
									finish_flag_in = 0;
									nextState = START_DNA;
								end
								else begin
									nextState = IDLE;
								end
						end
									
		START_ENCODER: 	begin
							start_encoder = 1;
							nextState = ENCODER;
						end
		ENCODER:		begin
							start_encoder = 0;
							if((finish_flag_encoder == 1)) begin
								start_bin_to_dna = 1;
								nextState = BIN;
							end
							else begin
								nextState = ENCODER;
							end
						end		
		BIN: 			begin	
							start_bin_to_dna = 0;
							if((finish_flag_bin == 1)) begin
								finish_flag_in = 1;
								nextState = IDLE;
							end
							else begin
								nextState = BIN;
							end
						end	
		START_DNA:		begin
							start_dna_to_bin = 1;
							nextState = DNA;
						end
						
		DNA: 			begin	
							start_dna_to_bin = 0;
							if((finish_flag_dna == 1)) begin
								start_decoder = 1;
								nextState = DECODER;
							end
							else begin
								nextState = DNA;
							end
						end				

		DECODER:		begin
							start_decoder = 0;
							if((finish_flag_decoder == 1)) begin
								finish_flag_in = 1;
								nextState = IDLE;
							end
							else begin
								nextState = DECODER;
							end
						end	
		default:		nextState = IDLE; 
		

	endcase
end
assign finish_flag = finish_flag_in;

endmodule






