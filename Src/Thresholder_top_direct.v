////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Top wrapper for thresholders based on amplitudes
// Function:
//		Connect 8 thresholder modules with the thresholder coordinator
//		Output the first tirggering timestamp from the 8 boards and last for triggering window time
//		Attention!!!: Currently how to use the trigger output is not defined. The initial thoughts is: Use the first trigger timestamp as the base, then get the start and ending trigger timestamp in different module(DRAM_Ctrl?) and mark those triggered parts in DRAM
//		Glitch 1: The coordinator originally should take 8 input clocks, but currently just use clk from RX0
//		Glitch 2: Ex. Sometime, trigger 0 might trigger on T10, while trigger 6 might trigger on T9. However, Trigger 0 set the trigger earlier than Trigger 6, then in that case, we will use T10 as the first trigger time, but this shouldn't be a big problem as the time offset won't be very large, supposing to be within 4 cycles
//
//	Output Definition:
//		triggering_time_stamp: the first triggering timestamp, the receiving side should use this to calculate the starting and ending points. It will remain the same during a single triggering event
//		threshold_decision_to_DRAM_ctrl: This signal will keep high from the first triggering point till it reaches ending triggering point. 
//													On the receiving side, it should keep on checking this signal and compare with the triggering time stamp, there will be a falling edge each time one triggering event is finish
//
// By: Chen Yang
// Rev0: 05/01/2017
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


module Thresholder_top_direct(
	input 				rst_n,										// reset signal, reset on low

	input 				rx_std_clkout_0,							// clk signal for RX data receiving
	input [1:0]			rx_syncstatus_0,							// syncstatus connect to transceiver IP
	input	[1:0]			rx_datak_0,									// signify the control word or data word
	input [15:0]		RX_data_0,	
	input 				rx_std_clkout_1,							// clk signal for RX data receiving
	input [1:0]			rx_syncstatus_1,							// syncstatus connect to transceiver IP
	input	[1:0]			rx_datak_1,									// signify the control word or data word
	input [15:0]		RX_data_1,	
	input 				rx_std_clkout_2,							// clk signal for RX data receiving
	input [1:0]			rx_syncstatus_2,							// syncstatus connect to transceiver IP
	input	[1:0]			rx_datak_2,									// signify the control word or data word
	input [15:0]		RX_data_2,	
	input 				rx_std_clkout_3,							// clk signal for RX data receiving
	input [1:0]			rx_syncstatus_3,							// syncstatus connect to transceiver IP
	input	[1:0]			rx_datak_3,									// signify the control word or data word
	input [15:0]		RX_data_3,	
	input 				rx_std_clkout_4,							// clk signal for RX data receiving
	input [1:0]			rx_syncstatus_4,							// syncstatus connect to transceiver IP
	input	[1:0]			rx_datak_4,									// signify the control word or data word
	input [15:0]		RX_data_4,	
	input 				rx_std_clkout_5,							// clk signal for RX data receiving
	input [1:0]			rx_syncstatus_5,							// syncstatus connect to transceiver IP
	input	[1:0]			rx_datak_5,									// signify the control word or data word
	input [15:0]		RX_data_5,	
	input 				rx_std_clkout_6,							// clk signal for RX data receiving
	input [1:0]			rx_syncstatus_6,							// syncstatus connect to transceiver IP
	input	[1:0]			rx_datak_6,									// signify the control word or data word
	input [15:0]		RX_data_6,	
	input 				rx_std_clkout_7,							// clk signal for RX data receiving
	input [1:0]			rx_syncstatus_7,							// syncstatus connect to transceiver IP
	input	[1:0]			rx_datak_7,									// signify the control word or data word
	input [15:0]		RX_data_7,
	
	// The first tiggered timestamp, valid only if threshold_decision_to_DRAM_ctrl=1
	// Send to DRAM controller so it can be directly used for mask updating
	output [15:0]		triggering_time_stamp,
	output            threshold_decision_to_DRAM_ctrl	// This signal will keep high from the first triggering point till it reaches ending triggering point
																		// on the receiving side, it should keep on checking this signal and compare with the triggering time stamp, there will be a falling edge each time one triggering event is finish
);
	parameter POST_TRIGGER_ENDING = 16'd15000;

	wire [15:0] B0_time_stamp;
	wire B0_decision;
	wire [15:0] B1_time_stamp;
	wire B1_decision;
	wire [15:0] B2_time_stamp;
	wire B2_decision;
	wire [15:0] B3_time_stamp;
	wire B3_decision;
	wire [15:0] B4_time_stamp;
	wire B4_decision;
	wire [15:0] B5_time_stamp;
	wire B5_decision;
	wire [15:0] B6_time_stamp;
	wire B6_decision;
	wire [15:0] B7_time_stamp;
	wire B7_decision;

	Threshold_Global_Coordinator Threshold_Global_Coordinator(
		
		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Potential Problem:
		// The Coordinator clock is currently using clkout from RX0, but it will read out from 8 thresholders that using different clocks
		// Solution: Use fifo here!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		// Temp solution: use clkout0 for now, put on board and check if this works
		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		.clk(rx_std_clkout_0),
		.rst_n(rst_n),
	
		.B0_time_stamp(B0_time_stamp),
		.B0_decision(B0_decision),
		.B1_time_stamp(B1_time_stamp),
		.B1_decision(B1_decision),
		.B2_time_stamp(B2_time_stamp),
		.B2_decision(B2_decision),
		.B3_time_stamp(B3_time_stamp),
		.B3_decision(B3_decision),
		.B4_time_stamp(B4_time_stamp),
		.B4_decision(B4_decision),
		.B5_time_stamp(B5_time_stamp),
		.B5_decision(B5_decision),
		.B6_time_stamp(B6_time_stamp),
		.B6_decision(B6_decision),
		.B7_time_stamp(B7_time_stamp),
		.B7_decision(B7_decision),

		.triggering_time_stamp(triggering_time_stamp),
		.threshold_decision_to_DRAM_ctrl(threshold_decision_to_DRAM_ctrl)

);
	defparam Threshold_Global_Coordinator.POST_TRIGGER_ENDING = POST_TRIGGER_ENDING;

	Thresholder Thresholder_0(
		.rx_std_clkout(rx_std_clkout_0),
		.rst_n(rst_n),	
		.rx_syncstatus(rx_syncstatus_0),
		.rx_datak(rx_datak_0),
		.RX_data(RX_data_0),
		.Global_trigger_flag(),
		.set_global_trigger(B0_decision),
		.time_stamp(B0_time_stamp)
	);
	
	Thresholder Thresholder_1(
		.rx_std_clkout(rx_std_clkout_1),
		.rst_n(rst_n),	
		.rx_syncstatus(rx_syncstatus_1),
		.rx_datak(rx_datak_1),
		.RX_data(RX_data_1),
		.Global_trigger_flag(),
		.set_global_trigger(B1_decision),
		.time_stamp(B1_time_stamp)
	);
	
	Thresholder Thresholder_2(
		.rx_std_clkout(rx_std_clkout_2),
		.rst_n(rst_n),	
		.rx_syncstatus(rx_syncstatus_2),
		.rx_datak(rx_datak_2),
		.RX_data(RX_data_2),
		.Global_trigger_flag(),
		.set_global_trigger(B2_decision),
		.time_stamp(B2_time_stamp)
	);
	
	Thresholder Thresholder_3(
		.rx_std_clkout(rx_std_clkout_3),
		.rst_n(rst_n),	
		.rx_syncstatus(rx_syncstatus_3),
		.rx_datak(rx_datak_3),
		.RX_data(RX_data_3),
		.Global_trigger_flag(),
		.set_global_trigger(B3_decision),
		.time_stamp(B3_time_stamp)
	);
	
	Thresholder Thresholder_4(
		.rx_std_clkout(rx_std_clkout_4),
		.rst_n(rst_n),	
		.rx_syncstatus(rx_syncstatus_4),
		.rx_datak(rx_datak_4),
		.RX_data(RX_data_4),
		.Global_trigger_flag(),
		.set_global_trigger(B4_decision),
		.time_stamp(B4_time_stamp)
	);
	
	Thresholder Thresholder_5(
		.rx_std_clkout(rx_std_clkout_5),
		.rst_n(rst_n),	
		.rx_syncstatus(rx_syncstatus_5),
		.rx_datak(rx_datak_5),
		.RX_data(RX_data_5),
		.Global_trigger_flag(),
		.set_global_trigger(B5_decision),
		.time_stamp(B5_time_stamp)
	);
	
	Thresholder Thresholder_6(
		.rx_std_clkout(rx_std_clkout_6),
		.rst_n(rst_n),	
		.rx_syncstatus(rx_syncstatus_6),
		.rx_datak(rx_datak_6),
		.RX_data(RX_data_6),
		.Global_trigger_flag(),
		.set_global_trigger(B6_decision),
		.time_stamp(B6_time_stamp)
	);
	
	Thresholder Thresholder_7(
		.rx_std_clkout(rx_std_clkout_7),
		.rst_n(rst_n),	
		.rx_syncstatus(rx_syncstatus_7),
		.rx_datak(rx_datak_7),
		.RX_data(RX_data_7),
		.Global_trigger_flag(),
		.set_global_trigger(B7_decision),
		.time_stamp(B7_time_stamp)
	);
	
	
endmodule