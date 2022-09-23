`timescale 1ns/1ns
module test_bench_top;

localparam MESSAGE_SIZE = 39; //The size of the message according to BCH(63,39).
localparam NUM_OF_NUCLEOTIDES = 40;	//Need a NUM_OF_NUCLEOTIDES*ASCII_SIZE size array to represent the DNA strand 
localparam ASCII_SIZE = 8;			//that resembles 64 binary bits.
localparam NUM_OF_TESTS = 2000;

logic clk;
logic start;
logic [MESSAGE_SIZE+2*NUM_OF_NUCLEOTIDES*ASCII_SIZE:0] test_vector[NUM_OF_TESTS -1 : 0];//write_in - expected_write_out - read_in	
logic finish_flag;
logic resetN;

test_bench tb(.clk(clk),
			  .start(start),
			  .resetN(resetN),
			  .test_vector(test_vector),
			  .finish_flag(finish_flag)
			  );

always begin 
#2  clk = ~clk; 
end

initial begin
	clk = 1;
	start = 0;
#20 resetN = 1;	
#20 resetN = 0;	
#20 resetN = 1;	
	$readmemb("test_vector.txt", test_vector); 
	//test_vector={679'b1101100111011010011110111110101000011010100001101000111010000010101010001000001010101000100011101000001010101000100001101000001010101000100000101010100010000110101010001010100010000110100001101000111010000010100000101000011010101000100011101000001010000010100001101010100010000110100011101000011010000010100001101000001010001110100011101000001010101000100001101000011010000110100000101010100010000010101010001000111010000010101010001000011010000010101010001000001010101000100001101010100010101000101010001000011010001110100000101000001010000110101010001000111010000010100000101000011010101000100001101000111010000110100000101000011010000010100011101000111010000010101010001000011};
#20 start = 1;
#20 start = 0;
end


always_ff@(posedge clk) begin	
	if(finish_flag == 1) begin
		$display("Number of bits written and read: {%d}", MESSAGE_SIZE*NUM_OF_TESTS);
		$stop;
	end
end

/*

always_ff@(posedge clk) begin	
		currentState <= nextState;
		resetN_out <= resetN_in;
		start_out  <= start_in;
end




typedef enum logic [2:0] {IDLE, RESET, TEST,FINISH,DEAD} State;
State currentState, nextState;

always_ff@(posedge clk) begin	
		currentState <= nextState;
		resetN_out <= resetN_in;
		start_out  <= start_in;
end
always_comb 
begin
	resetN_in = resetN_out;
	start_in = start_out;
	case(currentState)
	IDLE: 	begin 
				resetN_in = 0;
				nextState = TEST;
			end
	TEST:	begin
				start_in = 1;
				resetN_in = 1;
				nextState = FINISH;
			end
	FINISH:	begin
				if(finish_flag == 1) begin
					$display("Number of bits written and read: {%d}", MESSAGE_SIZE*NUM_OF_TESTS);
					nextState = DEAD;
				end
				else begin
					nextState = FINISH;
				end
			end
	DEAD: 	begin
					nextState = DEAD;
			end
	default: nextState = DEAD;
end
*/
endmodule
