// using find the right most 1 bit method to do round-robin

module Arbitor(
	input					clk,
	input 				rst_n,
	input             enable,
	input  [7:0]		input_mask,
	output [7:0]		output_mask,
	output reg [3:0]	board_sel
);

	wire [7:0]		update_priority_list;
	
	reg [7:0] 		arbitor;
	
	assign update_priority_list = (~arbitor) & input_mask;		// Remove the previous selected from the priority list
	
	// Assign output
	assign output_mask = arbitor;				
	
	always@(posedge clk)
		begin
		if(!rst_n) arbitor <= 8'd0;
		else if (enable) arbitor <= (~update_priority_list + 1'b1) & update_priority_list;
		else arbitor <= arbitor;
		end
	
	always@(*)
		begin
		if(!rst_n)
			board_sel <= 8;
		else
			begin
			case(arbitor)
				8'b00000000: board_sel <= 8;		// means invalid
				8'b00000001: board_sel <= 0;
				8'b00000010: board_sel <= 1;
				8'b00000100: board_sel <= 2;
				8'b00001000: board_sel <= 3;
				8'b00010000: board_sel <= 4;
				8'b00100000: board_sel <= 5;
				8'b01000000: board_sel <= 6;
				8'b10000000: board_sel <= 7;
				default: board_sel <= 8;		// means invalid
			endcase
			end
		end

endmodule
	