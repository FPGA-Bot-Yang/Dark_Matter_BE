module integral_comparator(
	input				clk,
	input 			rst_n,
	input 			enable,				// Write history data ram only when this signal is set

	input [11:0]	new_data,			// the new incoming data
	input [6:0]		rd_addr,				// index for finding the threshold and history data
	
	// Threshold decision
	output reg		decision				// Threshold decision output
);

	wire [59:0]	history_data;		// history data of 5 * 12bits
	wire [11:0]	threshold;			// read in threshold value

	// Stage 1 regs
	reg [63:0] S1_New_History_data;	// the new data will be write back in the next cycle
	reg 		  S1_enable;
	reg [6:0]  S1_rd_addr;
	reg [11:0] S1_threshold;
	reg [11:0] S1_adder1_out;
	reg [11:0] S1_adder2_out;
	reg [11:0] S1_new_data;
	
	// Stage 2 regs
	reg 		  S2_enable;
	reg [11:0] S2_threshold;
	reg [11:0] S2_new_data;
	reg [11:0] S2_adder_out;
	
	// Stage 3 regs
	reg 		  S3_enable;
	reg [11:0] S3_threshold;
	reg [11:0] S3_integral;
	
	// Stage 4 regs
	reg 		  S4_decision;

	

	History_RAM History_RAM(
		.clock(clk),
		.data(S1_New_History_data),
		.rdaddress(rd_addr),
		.wraddress(S1_rd_addr),
		.wren(S1_enable),
		.q(history_data)
	);
	
	Threshold_MEM_0 Threshold_MEM(
		.address(rd_addr),
		.clock(clk),
		.q(threshold)
	);
	
	
	always@(posedge clk)
		begin
		if(!rst_n)
			begin
			
			
			end
		else
			begin
			// Write new history data back to RAM
			S1_New_History_data <= {{4'd0}, new_data, history_data[59:12]};		// Shift out the 12LSB as that's the oldest data
			S1_enable <= enable;
			S1_rd_addr <= rd_addr;
			S1_threshold <= threshold;
			S1_adder1_out <= history_data[59:48] + history_data[47:36];
			S1_adder2_out <= history_data[35:24] + history_data[23:12];
			S1_new_data <= new_data;
			
			S2_enable <= S1_enable;
			S2_threshold <= S1_threshold;
			S2_new_data <= S1_new_data;
			S2_adder_out <= S1_adder1_out + S1_adder2_out;
			
			S3_enable <= S2_enable;
			S3_threshold <= S2_threshold;
			S3_integral <= S2_adder_out + S2_new_data;
			
			
			// Only make the decison when enabled, and enable signal is passed down the pipeline
			// Make decision here so the FSM of the thresholder don't need to wait for the piepline delay
			if(S3_enable && S3_integral > S3_threshold)
				decision <= 1'b1;
			else
				decision <= 1'b0;
			
			end
		end




endmodule