`timescale 1ns/1ns

module Thresholder_tb;
	reg 			clk;
	reg 			rst_n;
	reg [1:0] 	rx_syncstatus;
	reg [1:0]	rx_datak;
	reg [15:0] 	RX_data;
	reg 			Global_trigger_flag;
	
	wire			set_global_trigger;
	wire [15:0]	time_stamp;
	

	Thresholder Thresholder(
		.rx_std_clkout(clk),
		.rst_n(rst_n),
		.rx_syncstatus(rx_syncstatus),
		.rx_datak(rx_datak),
		.RX_data(RX_data),
		.Global_trigger_flag(Global_trigger_flag),
		.set_global_trigger(set_global_trigger),
		.time_stamp(time_stamp)	
		);
	reg 	[15:0]	TS; /* Time stamp used for test bench */		
	integer ii;
	
	always #1 clk = !clk;
	//always #2 RX_data = RX_data + 1'b1;
	
	initial begin
		clk = 1;
		rst_n = 0;
		Global_trigger_flag <= 1'b0;
		rx_syncstatus = 2'b00;
		rx_datak = 2'b01;
		RX_data = 16'hff00;
		TS <= 16'h45;
	
		#10
		rst_n = 1;
		#20
		rx_syncstatus = 2'b11;
		#20
		rx_datak = 2'b00;
		#20
		for (ii = 0; ii < 512; ii = ii + 1) begin
			#2;
			if (ii%128 == 0) begin RX_data <= 16'hDEAD; end /* Start Word */
			else if (ii%128 == 1) begin RX_data <= TS; TS <= TS + 16'h1; end /* Time Stamp */
			else if (ii%128 == 127) begin RX_data <= 16'h7FFF; end /* End Word */
			else begin RX_data <= RX_data + 16'h1; end /* Test data */
		end 
		#2;
		RX_data <= 16'd0;
		
	end

endmodule
