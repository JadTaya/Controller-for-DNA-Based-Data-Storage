localparam  MESSAGE_SIZE_ = 39; //The size of the message according to BCH(63,39).
localparam  ENCODED_SIZE_ = 64; //The size of the encoded message according to BCH(63,39).
localparam  NUM_OF_NUCLEOTIDES_ = 40;	//Need a NUM_OF_NUCLEOTIDES_*ASCII_SIZE size array to represent the DNA strand 
localparam  ASCII_SIZE_ = 8;			//that resembles 64 binary bits.
localparam  NUM_OF_TESTS_ = 2000;


module test_bench(	input	logic			clk,
					input	logic			resetN,	
					input	logic			start,	
					//write_in - expected_write_out - read_in				
					input	logic [MESSAGE_SIZE_+2*NUM_OF_NUCLEOTIDES_*ASCII_SIZE_:0] test_vector[NUM_OF_TESTS_-1:0],
					
					output logic finish_flag
);



logic [1:0] mode_out, mode_in;
logic finish_flag_top;
logic [MESSAGE_SIZE_-1:0] write_in_prev, write_in_next, read_out, tmp_read_out;
logic [NUM_OF_NUCLEOTIDES_*ASCII_SIZE_-1:0] write_out, read_in_prev, read_in_next, expected_write_out_prev, expected_write_out_next; //read_in will have 2 nucleotide swap errors - up to 4 bit errors

int num_of_errors_out, num_of_errors_in;;
int i_in,i_out;
typedef enum logic [2:0] {IDLE, TEST_ENCODER_BIN, TEST_DNA_DECODER, INTERMISSION, UPDATE_VARIABLES} State;
State currentState, nextState;

logic finish_flag_tmp_out, finish_flag_tmp_in;

top tp(.clk(clk),
		.resetN(resetN),
		.mode(mode_in),
		.write_in(write_in_next),		
		.read_in(read_in_next), 
		.write_out(write_out), 
		.read_out(tmp_read_out),
		.finish_flag(finish_flag_top));

		   




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
		finish_flag_tmp_out <= 0;	
		i_out <= 0;
		mode_out <= 0;
		num_of_errors_out <= 0;
		write_in_prev <= 0;
		expected_write_out_prev <= 0;
		read_in_prev <= 0;
	end
	else begin
		finish_flag_tmp_out <= finish_flag_tmp_in;
		i_out <= i_in;
		mode_out <= mode_in;
		num_of_errors_out <= num_of_errors_in;
		write_in_prev <= write_in_next;
		expected_write_out_prev <= expected_write_out_next;
		read_in_prev <= read_in_next;
	end
end



always_comb begin
	
	case(currentState)  
		IDLE: begin
					finish_flag_tmp_in = 0;
					if(start == 1) begin
						i_in = 0;
						num_of_errors_in = 0;
						mode_in = 0;
						nextState = UPDATE_VARIABLES;
					end
					else begin
						nextState = IDLE;
					end
		end				
		UPDATE_VARIABLES: begin
							if(i_out < NUM_OF_TESTS_) begin
								{write_in_next, expected_write_out_next, read_in_next} = test_vector[i_out];
								mode_in = 1; 
								nextState = TEST_ENCODER_BIN;
							end
							else begin
								$display("Testing complete, total number of errors found: %d",num_of_errors_out);
								finish_flag_tmp_in = 1;
								nextState = UPDATE_VARIABLES;
							end
		end
		TEST_ENCODER_BIN:	 begin
								
								if((finish_flag_top == 1)) begin
									mode_in = 2;
									if(write_out != expected_write_out_prev) begin
										$display("Test number %d | error: {Out: %s}, {Expected: %s}", i_out, write_out, expected_write_out_prev);
										num_of_errors_in = num_of_errors_out + 1;
									end
									nextState = INTERMISSION;
								end
								else begin
									nextState = TEST_ENCODER_BIN;
								end
							end		
		INTERMISSION:		begin
								nextState = TEST_DNA_DECODER;
							end
		TEST_DNA_DECODER:	begin
								if((finish_flag_top == 1)) begin
									mode_in = 0;
									if(write_in_prev != tmp_read_out) begin
										$display("Test number %d | error: {Out: %b}, {Expected: %b}", i_out, tmp_read_out, write_in_prev);
										num_of_errors_in = num_of_errors_out + 1;
									end
									read_out = tmp_read_out;
									i_in = i_out + 1;
									nextState = UPDATE_VARIABLES;
								end
								else begin
									nextState = TEST_DNA_DECODER;
								end
		end				

	endcase
end
assign finish_flag = finish_flag_tmp_in;

endmodule