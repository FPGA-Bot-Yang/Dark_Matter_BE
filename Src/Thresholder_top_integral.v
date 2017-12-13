module Thresholder_top_integral(
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

	output [15:0]		triggering_time_stamp,
	output            threshold_decision_to_DRAM_ctrl
);


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

		.threshold_decision_to_DRAM_ctrl(threshold_decision_to_DRAM_ctrl)

);


	Thresholder_integral Thresholder_0(
		.rx_std_clkout(rx_std_clkout_0),
		.rst_n(rst_n),	
		.rx_syncstatus(rx_syncstatus_0),
		.rx_datak(rx_datak_0),
		.RX_data(RX_data_0),
		.Global_trigger_flag(),
		.set_global_trigger(B0_decision),
		.time_stamp(B0_time_stamp)
	);
	
	Thresholder_integral Thresholder_1(
		.rx_std_clkout(rx_std_clkout_1),
		.rst_n(rst_n),	
		.rx_syncstatus(rx_syncstatus_1),
		.rx_datak(rx_datak_1),
		.RX_data(RX_data_1),
		.Global_trigger_flag(),
		.set_global_trigger(B1_decision),
		.time_stamp(B1_time_stamp)
	);
	
	Thresholder_integral Thresholder_2(
		.rx_std_clkout(rx_std_clkout_2),
		.rst_n(rst_n),	
		.rx_syncstatus(rx_syncstatus_2),
		.rx_datak(rx_datak_2),
		.RX_data(RX_data_2),
		.Global_trigger_flag(),
		.set_global_trigger(B2_decision),
		.time_stamp(B2_time_stamp)
	);
	
	Thresholder_integral Thresholder_3(
		.rx_std_clkout(rx_std_clkout_3),
		.rst_n(rst_n),	
		.rx_syncstatus(rx_syncstatus_3),
		.rx_datak(rx_datak_3),
		.RX_data(RX_data_3),
		.Global_trigger_flag(),
		.set_global_trigger(B3_decision),
		.time_stamp(B3_time_stamp)
	);
	
	Thresholder_integral Thresholder_4(
		.rx_std_clkout(rx_std_clkout_4),
		.rst_n(rst_n),	
		.rx_syncstatus(rx_syncstatus_4),
		.rx_datak(rx_datak_4),
		.RX_data(RX_data_4),
		.Global_trigger_flag(),
		.set_global_trigger(B4_decision),
		.time_stamp(B4_time_stamp)
	);
	
	Thresholder_integral Thresholder_5(
		.rx_std_clkout(rx_std_clkout_5),
		.rst_n(rst_n),	
		.rx_syncstatus(rx_syncstatus_5),
		.rx_datak(rx_datak_5),
		.RX_data(RX_data_5),
		.Global_trigger_flag(),
		.set_global_trigger(B5_decision),
		.time_stamp(B5_time_stamp)
	);
	
	Thresholder_integral Thresholder_6(
		.rx_std_clkout(rx_std_clkout_6),
		.rst_n(rst_n),	
		.rx_syncstatus(rx_syncstatus_6),
		.rx_datak(rx_datak_6),
		.RX_data(RX_data_6),
		.Global_trigger_flag(),
		.set_global_trigger(B6_decision),
		.time_stamp(B6_time_stamp)
	);
	
	Thresholder_integral Thresholder_7(
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