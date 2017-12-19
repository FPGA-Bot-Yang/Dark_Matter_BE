`timescale 1ns/1ns

module Thresholder_top_direct_tb;

	reg 				rst_n;										// reset signal, reset on low

	reg 				rx_std_clkout_0;							// clk signal for RX data receiving
	reg  [1:0]		rx_syncstatus_0;							// syncstatus connect to transceiver IP
	reg  [1:0]		rx_datak_0;									// signify the control word or data word
	reg  [15:0]		RX_data_0;	
	reg 				rx_std_clkout_1;							// clk signal for RX data receiving
	reg  [1:0]		rx_syncstatus_1;							// syncstatus connect to transceiver IP
	reg  [1:0]		rx_datak_1;									// signify the control word or data word
	reg  [15:0]		RX_data_1;	
	reg 				rx_std_clkout_2;							// clk signal for RX data receiving
	reg  [1:0]		rx_syncstatus_2;							// syncstatus connect to transceiver IP
	reg  [1:0]		rx_datak_2;									// signify the control word or data word
	reg  [15:0]		RX_data_2;	
	reg 				rx_std_clkout_3;							// clk signal for RX data receiving
	reg  [1:0]		rx_syncstatus_3;							// syncstatus connect to transceiver IP
	reg  [1:0]		rx_datak_3;									// signify the control word or data word
	reg  [15:0]		RX_data_3;	
	reg 				rx_std_clkout_4;							// clk signal for RX data receiving
	reg  [1:0]		rx_syncstatus_4;							// syncstatus connect to transceiver IP
	reg  [1:0]		rx_datak_4;									// signify the control word or data word
	reg  [15:0]		RX_data_4;	
	reg 				rx_std_clkout_5;							// clk signal for RX data receiving
	reg  [1:0]		rx_syncstatus_5;							// syncstatus connect to transceiver IP
	reg  [1:0]		rx_datak_5;									// signify the control word or data word
	reg  [15:0]		RX_data_5;	
	reg 				rx_std_clkout_6;							// clk signal for RX data receiving
	reg  [1:0]		rx_syncstatus_6;							// syncstatus connect to transceiver IP
	reg  [1:0]		rx_datak_6;									// signify the control word or data word
	reg  [15:0]		RX_data_6;	
	reg  				rx_std_clkout_7;							// clk signal for RX data receiving
	reg  [1:0]		rx_syncstatus_7;							// syncstatus connect to transceiver IP
	reg  [1:0]		rx_datak_7;									// signify the control word or data word
	reg  [15:0]		RX_data_7;
	
	wire [15:0]		triggering_time_stamp;
	wire           threshold_decision_to_DRAM_ctrl;
	
	reg            rx_std_clkout;
	reg [1:0]      rx_syncstatus;
	reg [1:0]      rx_datak;
	reg [15:0]     RX_data;
	
	Thresholder_top_direct Thresholder_top_direct(
		.rst_n(rst_n),										// reset signal, reset on low

		.rx_std_clkout_0(rx_std_clkout_0),							// clk signal for RX data receiving
		.rx_syncstatus_0(rx_syncstatus_0),							// syncstatus connect to transceiver IP
		.rx_datak_0(rx_datak_0),									// signify the control word or data word
		.RX_data_0(RX_data_0),	
		.rx_std_clkout_1(rx_std_clkout_1),							// clk signal for RX data receiving
		.rx_syncstatus_1(rx_syncstatus_1),							// syncstatus connect to transceiver IP
		.rx_datak_1(rx_datak_1),									// signify the control word or data word
		.RX_data_1(RX_data_1),	
		.rx_std_clkout_2(rx_std_clkout_2),							// clk signal for RX data receiving
		.rx_syncstatus_2(rx_syncstatus_2),							// syncstatus connect to transceiver IP
		.rx_datak_2(rx_datak_2),									// signify the control word or data word
		.RX_data_2(RX_data_2),	
		.rx_std_clkout_3(rx_std_clkout_3),							// clk signal for RX data receiving
		.rx_syncstatus_3(rx_syncstatus_3),							// syncstatus connect to transceiver IP
		.rx_datak_3(rx_datak_3),									// signify the control word or data word
		.RX_data_3(RX_data_3),	
		.rx_std_clkout_4(rx_std_clkout_4),							// clk signal for RX data receiving
		.rx_syncstatus_4(rx_syncstatus_4),							// syncstatus connect to transceiver IP
		.rx_datak_4(rx_datak_4),									// signify the control word or data word
		.RX_data_4(RX_data_4),	
		.rx_std_clkout_5(rx_std_clkout_5),							// clk signal for RX data receiving
		.rx_syncstatus_5(rx_syncstatus_5),							// syncstatus connect to transceiver IP
		.rx_datak_5(rx_datak_5),									// signify the control word or data word
		.RX_data_5(RX_data_5),	
		.rx_std_clkout_6(rx_std_clkout_6),							// clk signal for RX data receiving
		.rx_syncstatus_6(rx_syncstatus_6),							// syncstatus connect to transceiver IP
		.rx_datak_6(rx_datak_6),									// signify the control word or data word
		.RX_data_6(RX_data_6),	
		.rx_std_clkout_7(rx_std_clkout_7),							// clk signal for RX data receiving
		.rx_syncstatus_7(rx_syncstatus_7),							// syncstatus connect to transceiver IP
		.rx_datak_7(rx_datak_7),									// signify the control word or data word
		.RX_data_7(RX_data_7),

		.triggering_time_stamp(triggering_time_stamp),
		.threshold_decision_to_DRAM_ctrl(threshold_decision_to_DRAM_ctrl)
		);
		defparam Thresholder_top_direct.POST_TRIGGER_ENDING = 16'd10;
		
		
		always@(*)
			begin
			rx_syncstatus_0 <= rx_syncstatus;
			rx_syncstatus_1 <= rx_syncstatus;
			rx_syncstatus_2 <= rx_syncstatus;
			rx_syncstatus_3 <= rx_syncstatus;
			rx_syncstatus_4 <= rx_syncstatus;
			rx_syncstatus_5 <= rx_syncstatus;
			rx_syncstatus_6 <= rx_syncstatus;
			rx_syncstatus_7 <= rx_syncstatus;
			
			rx_datak_0 <= rx_datak;
			rx_datak_1 <= rx_datak;
			rx_datak_2 <= rx_datak;
			rx_datak_3 <= rx_datak;
			rx_datak_4 <= rx_datak;
			rx_datak_5 <= rx_datak;
			rx_datak_6 <= rx_datak;
			rx_datak_7 <= rx_datak;
/*			
			RX_data_0 <= RX_data;
			RX_data_1 <= RX_data;
			RX_data_2 <= RX_data;
			RX_data_3 <= RX_data;
			RX_data_4 <= RX_data;
			RX_data_5 <= RX_data;
			RX_data_6 <= RX_data;
			RX_data_7 <= RX_data;
*/	
		end
		
		always #1 rx_std_clkout_0 = !rx_std_clkout_0;
		always #1 rx_std_clkout_1 = !rx_std_clkout_1;
		always #1 rx_std_clkout_2 = !rx_std_clkout_2;
		always #1 rx_std_clkout_3 = !rx_std_clkout_3;
		always #1 rx_std_clkout_4 = !rx_std_clkout_4;
		always #1 rx_std_clkout_5 = !rx_std_clkout_5;
		always #1 rx_std_clkout_6 = !rx_std_clkout_6;
		always #1 rx_std_clkout_7 = !rx_std_clkout_7;
/*		
//		always #2 RX_data = RX_data + 1'b1;
		always #2 RX_data_0 = RX_data_0 + 1'b1;
		always #2 RX_data_1 = RX_data_1 + 1'b1;
		always #2 RX_data_2 = RX_data_2 + 1'b1;
		always #2 RX_data_3 = RX_data_3 + 1'b1;
		always #2 RX_data_4 = RX_data_4 + 1'b1;
		always #2 RX_data_5 = RX_data_5 + 1'b1;
		always #2 RX_data_6 = RX_data_6 + 1'b1;
		always #2 RX_data_7 = RX_data_7 + 1'b1;
*/		
		integer ii;
		reg [15:0]	TS; /* Time stamp for testing */
		
		initial begin
			rst_n = 0;
			
			rx_std_clkout_0 <= 1;
			rx_std_clkout_1 <= 1;
			rx_std_clkout_2 <= 1;
			rx_std_clkout_3 <= 1;
			rx_std_clkout_4 <= 1;
			rx_std_clkout_5 <= 1;
			rx_std_clkout_6 <= 1;
			rx_std_clkout_7 <= 1;
			
			rx_syncstatus = 2'b00;
			rx_datak = 2'b11;

			RX_data_0 <= 16'hFFFF;
			RX_data_1 <= 16'hFFFF;
			RX_data_2 <= 16'hFFFF;
			RX_data_3 <= 16'hFFFF;
			RX_data_4 <= 16'hFFFF;
			RX_data_5 <= 16'hFFFF;
			RX_data_6 <= 16'hFFFF;
			RX_data_7 <= 16'hFFFF;
			TS <= 16'hFF00;
			
			
			#10
			rst_n = 1;
			#10
			rx_syncstatus = 2'b11;
			#10
			rx_datak = 2'b00;
			
			#10;
			for (ii = 0; ii < 128 * 25; ii = ii + 1)
				begin 
				#2;
				if (ii%128 == 0)													/* Start Word */
					begin
					RX_data_0 <= 16'hDEAD;
					RX_data_1 <= 16'hDEAD;
					RX_data_2 <= 16'hDEAD;
					RX_data_3 <= 16'hDEAD;
					RX_data_4 <= 16'hDEAD;
					RX_data_5 <= 16'hDEAD;
					RX_data_6 <= 16'hDEAD;
					RX_data_7 <= 16'hDEAD;
					end 											
				else if (ii%128 == 1)											/* Time Stamp */
					begin
					RX_data_0 <= 16'h0;
					RX_data_1 <= 16'h10;
					RX_data_2 <= 16'h100;
					RX_data_3 <= 16'h1000;
					RX_data_4 <= 16'h1010;
					RX_data_5 <= 16'hF0;
					RX_data_6 <= 16'hFF0;
					RX_data_7 <= 16'hFF00;
					
					TS <= TS + 16'h1; 
					end 					
				else if (ii%128 == 127)											/* Ending Word */
					begin
					RX_data_0 <= 16'hBEEF;
					RX_data_1 <= 16'hBEEF;
					RX_data_2 <= 16'hBEEF;
					RX_data_3 <= 16'hBEEF;
					RX_data_4 <= 16'hBEEF;
					RX_data_5 <= 16'hBEEF;
					RX_data_6 <= 16'hBEEF;
					RX_data_7 <= 16'hBEEF;
					end 		
				else																	/* Test data */	
					begin
					RX_data_0 <= RX_data_0;										// for test purpose, keep all data from RX0 to be 0
					RX_data_1 <= RX_data_1 + 16'h1;
					RX_data_2 <= RX_data_2 + 16'h1;
					RX_data_3 <= RX_data_3 + 16'h1;
					RX_data_4 <= RX_data_4 + 16'h1;
					RX_data_5 <= RX_data_5 + 16'h1;
					RX_data_6 <= RX_data_6 + 16'h1;
					RX_data_7 <= RX_data_7 + 16'h1;
					end 														
				end 
			
			#1000;
			$stop;
			
//			#40
//			RX_data_0 = 16'd65500;
//			RX_data_1 = 16'd65510;
//			RX_data_2 = 16'd65535;
//			RX_data_3 = 16'd65530;
//			RX_data_4 = 16'd65540;
//			RX_data_5 = 16'd65550;
//			RX_data_6 = 16'd65551;
//			RX_data_7 = 16'd65554;
//			
//			#2
//			RX_data_0 = 16'd65500;
//			RX_data_1 = 16'd65510;
//			RX_data_2 = 16'd32;
//			RX_data_3 = 16'd65530;
//			RX_data_4 = 16'd65535;
//			RX_data_5 = 16'd65550;
//			RX_data_6 = 16'd65551;
//			RX_data_7 = 16'd65554;
//			
//			#2
//			RX_data_0 = 16'd65500;
//			RX_data_1 = 16'd65510;
//			RX_data_2 = 16'd2;
//			RX_data_3 = 16'd65530;
//			RX_data_4 = 16'd78;
//			RX_data_5 = 16'd65550;
//			RX_data_6 = 16'd65551;
//			RX_data_7 = 16'd65554;
//			
//			#2
//			RX_data_0 = 16'd65500;
//			RX_data_1 = 16'd65510;
//			RX_data_2 = 16'd2;
//			RX_data_3 = 16'd65530;
//			RX_data_4 = 16'd4;
//			RX_data_5 = 16'd65550;
//			RX_data_6 = 16'd65551;
//			RX_data_7 = 16'd65554;
//			
//			#2
//			RX_data_0 = 16'd65500;
//			RX_data_1 = 16'd65510;
//			RX_data_2 = 16'd2;
//			RX_data_3 = 16'd65530;
//			RX_data_4 = 16'd4;
//			RX_data_5 = 16'd65550;
//			RX_data_6 = 16'd65535;
//			RX_data_7 = 16'd65554;
//			
//			#2
//			RX_data_0 = 16'd65500;
//			RX_data_1 = 16'd65510;
//			RX_data_2 = 16'd2;
//			RX_data_3 = 16'd65530;
//			RX_data_4 = 16'd4;
//			RX_data_5 = 16'd65550;
//			RX_data_6 = 16'd117;
//			RX_data_7 = 16'd65554;
//			
//			#2
//			RX_data_0 = 16'd65500;
//			RX_data_1 = 16'd65510;
//			RX_data_2 = 16'd2;
//			RX_data_3 = 16'd65530;
//			RX_data_4 = 16'd4;
//			RX_data_5 = 16'd65550;
//			RX_data_6 = 16'd6;
//			RX_data_7 = 16'd65554;
		
		end
	
endmodule
