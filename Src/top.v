module top
(
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// CLOCK AND RESET
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// DRAM Controller clock
	input clkin_125,							// Programmable clk X5 (PIN U31)
													// DRAM controller input reference clock
	// Transciever clock
	input clk_trans,							// Transciever ref clock (R11) Programmable clk X4, set as 125 MHz			
	// BackEnd reset
	input rst_n,								// Pin AK13, Button S3
													// When pressed, rst_n = 0
	// Reset signal to FE Board
	output rst_n_B1_cycloneIV,					// Output reset signal connect to HSMCA-HSM_D3 (K12) 
														// HSMCA PIN 6
	output rst_n_B3_cycloneIV,					// Output reset signal connect to HSMCA-HSM_D2 (F12) 
														// HSMCA PIN 5
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// TRANSCEIVER RX PINs
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	input	SMA_GXB_RX_B0_p,						// HSMCB RX0, P:N2, N:N1
	input SMA_GXB_RX_B1_p,						// HSMCB RX1, P:L2, N:L1
	input SMA_GXB_RX_B2_p,						// HSMCB RX2, P:J2, N:J1
	input SMA_GXB_RX_B3_p,						// HSMCB RX3, P:G2, N:G1
	
	input	SMA_GXB_RX_B4_p,						// HSMCA RX0, P:AA2, N:AA1
	input SMA_GXB_RX_B5_p,						// HSMCA RX1, P:W2, N:W1
	input SMA_GXB_RX_B6_p,						// HSMCA RX2, P:U2, N:U1
	input SMA_GXB_RX_B7_p,						// HSMCA RX3, P:R2, N:R1
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// DRAM PINs
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	output [13:0] ddr3b_a,
	output [2:0] ddr3b_ba,
	output ddr3b_casn,
	output ddr3b_cke,
	output ddr3b_clk_n,
	output ddr3b_clk_p,
	output ddr3b_csn,
	output [7:0] ddr3b_dm,
	inout [63:0] ddr3b_dq,
	inout [7:0] ddr3b_dqs_p, 
	inout [7:0] ddr3b_dqs_n,
	output ddr3b_odt,								// PIN AA32
	output ddr3b_rasn,							// PIN Y32
	output ddr3b_resetn,							// PIN AG31
	output ddr3b_wen,								// PIN AM34
	input rzqin_1_5v,								// PIN AP19
	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// MISC IN/OUT SIGNALS
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	input DRAM_read_address,
	output MASK_output,					      // Stop bit mask being trucated
	// Triggering status
	output triggering_status
);


	////////////////////////////////////////////////////////////////////////////////////////////////////
	// Output Reset Signals
	////////////////////////////////////////////////////////////////////////////////////////////////////
	assign rst_n_B1_cycloneIV = rst_n;
	assign rst_n_B3_cycloneIV = rst_n;

	
	////////////////////////////////////////////////////////////////////////////////////////////////////
	// RX Transceiver Signals
	////////////////////////////////////////////////////////////////////////////////////////////////////
	wire				reconfig_busy;
	wire [69:0]		ch0_0_to_xcvr;
	wire [45:0]		ch0_0_from_xcvr;
	wire [69:0]		ch1_1_to_xcvr;
	wire [45:0]		ch1_1_from_xcvr;
	wire [69:0]		ch2_2_to_xcvr;
	wire [45:0]		ch2_2_from_xcvr;
	wire [69:0]		ch3_3_to_xcvr;
	wire [45:0]		ch3_3_from_xcvr;
	
	wire [69:0]		ch4_4_to_xcvr;
	wire [45:0]		ch4_4_from_xcvr;
	wire [69:0]		ch5_5_to_xcvr;
	wire [45:0]		ch5_5_from_xcvr;
	wire [69:0]		ch6_6_to_xcvr;
	wire [45:0]		ch6_6_from_xcvr;
	wire [69:0]		ch7_7_to_xcvr;
	wire [45:0]		ch7_7_from_xcvr;	
	
	wire 				rx_std_clkout_B0;				// clock recovered from transceiver Board 0
	wire [15:0] 	rx_parallel_data_B0;			// data received from RX Board 0
	wire 				rx_std_clkout_B1;				// clock recovered from transceiver Board 1
	wire [15:0] 	rx_parallel_data_B1;			// data received from RX Board 1
	wire 				rx_std_clkout_B2;				// clock recovered from transceiver Board 2
	wire [15:0] 	rx_parallel_data_B2;			// data received from RX Board 2
	wire 				rx_std_clkout_B3;				// clock recovered from transceiver Board 3
	wire [15:0] 	rx_parallel_data_B3;			// data received from RX Board 3
	wire 				rx_std_clkout_B4;				// clock recovered from transceiver Board 4
	wire [15:0] 	rx_parallel_data_B4;			// data received from RX Board 4
	wire 				rx_std_clkout_B5;				// clock recovered from transceiver Board 5
	wire [15:0] 	rx_parallel_data_B5;			// data received from RX Board 5
	wire 				rx_std_clkout_B6;				// clock recovered from transceiver Board 6
	wire [15:0] 	rx_parallel_data_B6;			// data received from RX Board 6
	wire 				rx_std_clkout_B7;				// clock recovered from transceiver Board 7
	wire [15:0] 	rx_parallel_data_B7;			// data received from RX Board 7
	
	wire [1:0]     rx_syncstatus_0;
	wire [1:0]     rx_syncstatus_1;
	wire [1:0]     rx_syncstatus_2;
	wire [1:0]     rx_syncstatus_3;
	wire [1:0]     rx_syncstatus_4;
	wire [1:0]     rx_syncstatus_5;
	wire [1:0]     rx_syncstatus_6;
	wire [1:0]     rx_syncstatus_7;
	wire [1:0]     rx_datak_0;
	wire [1:0]     rx_datak_1;
	wire [1:0]     rx_datak_2;
	wire [1:0]     rx_datak_3;
	wire [1:0]     rx_datak_4;
	wire [1:0]     rx_datak_5;
	wire [1:0]     rx_datak_6;
	wire [1:0]     rx_datak_7;
	
	////////////////////////////////////////////////////////////////////////////////////////////////////
	// Trigger and DRAM control realted signals
	////////////////////////////////////////////////////////////////////////////////////////////////////	
	wire [15:0]    triggering_time_stamp;
	
	////////////////////////////////////////////////////////////////////////////////////////////////////
	// Triggering Logic
	////////////////////////////////////////////////////////////////////////////////////////////////////
	Thresholder_top_direct Threshold(
		.rst_n(rst_n),										// reset signal, reset on low

		.rx_std_clkout_0(rx_std_clkout_B0),							// clk signal for RX data receiving
		.rx_syncstatus_0(rx_syncstatus_0),							// syncstatus connect to transceiver IP
		.rx_datak_0(rx_datak_0),									// signify the control word or data word
		.RX_data_0(rx_parallel_data_B0),	
		.rx_std_clkout_1(rx_std_clkout_B1),							// clk signal for RX data receiving
		.rx_syncstatus_1(rx_syncstatus_1),							// syncstatus connect to transceiver IP
		.rx_datak_1(rx_datak_1),									// signify the control word or data word
		.RX_data_1(rx_parallel_data_B1),	
		.rx_std_clkout_2(rx_std_clkout_B2),							// clk signal for RX data receiving
		.rx_syncstatus_2(rx_syncstatus_2),							// syncstatus connect to transceiver IP
		.rx_datak_2(rx_datak_2),									// signify the control word or data word
		.RX_data_2(rx_parallel_data_B2),	
		.rx_std_clkout_3(rx_std_clkout_B3),							// clk signal for RX data receiving
		.rx_syncstatus_3(rx_syncstatus_3),							// syncstatus connect to transceiver IP
		.rx_datak_3(rx_datak_3),									// signify the control word or data word
		.RX_data_3(rx_parallel_data_B3),	
		.rx_std_clkout_4(rx_std_clkout_B4),							// clk signal for RX data receiving
		.rx_syncstatus_4(rx_syncstatus_4),							// syncstatus connect to transceiver IP
		.rx_datak_4(rx_datak_4),									// signify the control word or data word
		.RX_data_4(rx_parallel_data_B4),	
		.rx_std_clkout_5(rx_std_clkout_B5),							// clk signal for RX data receiving
		.rx_syncstatus_5(rx_syncstatus_5),							// syncstatus connect to transceiver IP
		.rx_datak_5(rx_datak_5),									// signify the control word or data word
		.RX_data_5(rx_parallel_data_B5),	
		.rx_std_clkout_6(rx_std_clkout_B6),							// clk signal for RX data receiving
		.rx_syncstatus_6(rx_syncstatus_6),							// syncstatus connect to transceiver IP
		.rx_datak_6(rx_datak_6),									// signify the control word or data word
		.RX_data_6(rx_parallel_data_B6),	
		.rx_std_clkout_7(rx_std_clkout_B7),							// clk signal for RX data receiving
		.rx_syncstatus_7(rx_syncstatus_7),							// syncstatus connect to transceiver IP
		.rx_datak_7(rx_datak_7),									// signify the control word or data word
		.RX_data_7(rx_parallel_data_B7),	

		// The first tiggered timestamp, valid only if threshold_decision_to_DRAM_ctrl=1
		// Send to DRAM controller so it can be directly used for mask updating
		////////////////////////////////////////////////////////////////////
		// TODO: Need to implement the related logic in DRAM controller
		////////////////////////////////////////////////////////////////////
		.triggering_time_stamp(triggering_time_stamp),
		.threshold_decision_to_DRAM_ctrl(triggering_status)
	);
	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////
	// DRAM Signals
	////////////////////////////////////////////////////////////////////////////////////////////////////
	wire avalon_clk;
	reg read;
	// DRAM Testing Signals
	wire [255:0] read_data;
	wire read_valid;
	
	// DRAM Controller signal
	wire [7:0] FIFO_ready_mask;
	wire [7:0] BRAM_ready_mask;
	wire [7:0] FIFO_empty;
	wire [7:0] FIFO_rd_request;
	wire [7:0] BRAM_rd_request;
	wire [2:0] BRAM_Sel;
	wire [24:0] DRAM_WR_address;
	wire [255:0] DRAM_Write_Data;
	wire DRAM_Write_Enable;
	wire [4:0] DRAM_Write_Burst_Count;	
	wire DRAM_Write_Burst_Begin;
	wire DRAM_Wait_Request;
	
	// FIFO read out data to DRAM controller
	wire [255:0] Buffer_RD_Data_0;
	wire [255:0] Buffer_RD_Data_1;
	wire [255:0] Buffer_RD_Data_2;
	wire [255:0] Buffer_RD_Data_3;
	wire [255:0] Buffer_RD_Data_4;
	wire [255:0] Buffer_RD_Data_5;
	wire [255:0] Buffer_RD_Data_6;
	wire [255:0] Buffer_RD_Data_7;
	reg [255:0] Selected_Data_to_DRAM;
	
	wire [15:0] FIFO_RD_Data_0;
	wire [15:0] FIFO_RD_Data_1;
	wire [15:0] FIFO_RD_Data_2;
	wire [15:0] FIFO_RD_Data_3;
	wire [15:0] FIFO_RD_Data_4;
	wire [15:0] FIFO_RD_Data_5;
	wire [15:0] FIFO_RD_Data_6;
	wire [15:0] FIFO_RD_Data_7;
	
	// Logic to select read data from 8 FIFOs
	always@(posedge avalon_clk)
		if(!rst_n)
			Selected_Data_to_DRAM <= 256'd0;
		else
			case(BRAM_Sel)
				0: Selected_Data_to_DRAM <= Buffer_RD_Data_0;
				1: Selected_Data_to_DRAM <= Buffer_RD_Data_1;
				2: Selected_Data_to_DRAM <= Buffer_RD_Data_2;
				3: Selected_Data_to_DRAM <= Buffer_RD_Data_3;
				4: Selected_Data_to_DRAM <= Buffer_RD_Data_4;
				5: Selected_Data_to_DRAM <= Buffer_RD_Data_5;
				6: Selected_Data_to_DRAM <= Buffer_RD_Data_6;
				7: Selected_Data_to_DRAM <= Buffer_RD_Data_7;
			endcase
			
	// DRAM controller
	DRAM_Addr_Gen DRAM_Controller(
		.clk(avalon_clk),
		.rst_n(rst_n),
		// signal for address mask
		.triggering_time_stamp(triggering_time_stamp),
		.triggering_status(triggering_status),	   // input from Threshold_Global_Coordinator
		// Signal to buffer
		.BRAM_ready_mask(BRAM_ready_mask),			// bit mask for those ready FIFOs. Each connect to the Channel_Data_Reorder_Buffer module's BRAM_ready_mask pin
		.BRAM_rd_data(Selected_Data_to_DRAM),
		.BRAM_rd_request(BRAM_rd_request),		   // bit mask for rd_request, each bit connect to Channel_Data_Reorder_Buffer module's BRAM_rd_request pin
		.BRAM_Sel(BRAM_Sel),
		// Signal to DRAM controller
		.DRAM_Wait_Request(DRAM_Wait_Request),
		.DRAM_Write_Enable(DRAM_Write_Enable),
		.DRAM_Write_Burst_Begin(DRAM_Write_Burst_Begin),
		.DRAM_Write_Burst_Count(DRAM_Write_Burst_Count),
		.DRAM_Write_Addr(DRAM_WR_address),
		.DRAM_Write_Data(DRAM_Write_Data),
		// dummy output for address mask
		.MASK_output(MASK_output)
	);


	
	////////////////////////////////////////////////////////////////////////////////////////////////////
	// Transceiver Module and Reorder Buffer
	////////////////////////////////////////////////////////////////////////////////////////////////////
	// Transceiver RX for Board 0
	Trans_RX B0_RX(
		.rst_n(rst_n),
		.clk_trans(clk_trans),
		.SMA_GXB_RX_p(SMA_GXB_RX_B0_p),
		.rx_std_clkout(rx_std_clkout_B0),				// output clk for DRAM controller
		.rx_parallel_data(rx_parallel_data_B0),		// output received data
		.rx_syncstatus(rx_syncstatus_0),
		.rx_datak(rx_datak_0),
		.RX_reconfig_to_xcvr(ch0_0_to_xcvr),
		.RX_reconfig_from_xcvr(ch0_0_from_xcvr),
		.DRAM_RD_clk(rx_std_clkout_B0),							// reorder buffer readout clk
		.DRAM_RD_req(FIFO_rd_request[0]),						// reorder buffer read request
		.RX_Buffer_empty(FIFO_empty[0]),							// Buffer empty
		.Buffer_RD_Data(FIFO_RD_Data_0),							// Read out data to DRAM
		.Buffer_Data_Ready(FIFO_ready_mask[0])	
		);
		
	Channel_Data_Reorder_Buffer Channel_Data_Reorder_Buffer_0(
		.inclk(rx_std_clkout_B0),
		.outclk(avalon_clk),
		.rst_n(rst_n),
		
		// Signal to buffer
		.FIFO_ready_mask(FIFO_ready_mask[0]),			// bit mask for those ready FIFOs. Each connect to the RX_buf_ctrl module's Buffer_Data_Ready pin
		.FIFO_rd_data(FIFO_RD_Data_0),
		.FIFO_rd_request(FIFO_rd_request[0]),		   // bit mask for rd_request, each bit connect to RX_buf_ctrl module's DRAM_RD_req pin

		// Signal to DRAM user controller
		.BRAM_ready_mask(BRAM_ready_mask[0]),			// bit mask for those ready Reorder Buffers. Each connect to the DRAM_Addr_Gen module's BRAM_ready_mask pin
		.DRAM_wr_data(Buffer_RD_Data_0),
		.BRAM_rd_request(BRAM_rd_request[0])		   // bit mask for rd_request, each bit connect to DRAM_Addr_Gen module's BRAM_rd_request pin
		);
	
	// Transceiver RX for Board 1
	Trans_RX B1_RX(
		.rst_n(rst_n),
		.clk_trans(clk_trans),
		.SMA_GXB_RX_p(SMA_GXB_RX_B1_p),
		.rx_std_clkout(rx_std_clkout_B1),				// output clk for DRAM controller
		.rx_parallel_data(rx_parallel_data_B1),		// output received data
		.rx_syncstatus(rx_syncstatus_1),
		.rx_datak(rx_datak_1),
		.RX_reconfig_to_xcvr(ch1_1_to_xcvr),
		.RX_reconfig_from_xcvr(ch1_1_from_xcvr),
		.DRAM_RD_clk(rx_std_clkout_B1),							// reorder buffer readout clk
		.DRAM_RD_req(FIFO_rd_request[1]),						// reorder buffer read request
		.RX_Buffer_empty(FIFO_empty[1]),							// Buffer empty
		.Buffer_RD_Data(FIFO_RD_Data_1),							// Read out data to DRAM
		.Buffer_Data_Ready(FIFO_ready_mask[1])	
		);
	
	Channel_Data_Reorder_Buffer Channel_Data_Reorder_Buffer_1(
		.inclk(rx_std_clkout_B1),
		.outclk(avalon_clk),
		.rst_n(rst_n),
		
		// Signal to buffer
		.FIFO_ready_mask(FIFO_ready_mask[1]),			// bit mask for those ready FIFOs. Each connect to the RX_buf_ctrl module's Buffer_Data_Ready pin
		.FIFO_rd_data(FIFO_RD_Data_1),
		.FIFO_rd_request(FIFO_rd_request[1]),		   // bit mask for rd_request, each bit connect to RX_buf_ctrl module's DRAM_RD_req pin

		// Signal to DRAM user controller
		.BRAM_ready_mask(BRAM_ready_mask[1]),			// bit mask for those ready Reorder Buffers. Each connect to the DRAM_Addr_Gen module's BRAM_ready_mask pin
		.DRAM_wr_data(Buffer_RD_Data_1),
		.BRAM_rd_request(BRAM_rd_request[1])		   // bit mask for rd_request, each bit connect to DRAM_Addr_Gen module's BRAM_rd_request pin
		);
	// Transceiver RX for Board 2
	Trans_RX B2_RX(
		.rst_n(rst_n),
		.clk_trans(clk_trans),
		.SMA_GXB_RX_p(SMA_GXB_RX_B2_p),
		.rx_std_clkout(rx_std_clkout_B2),				// output clk for DRAM controller
		.rx_parallel_data(rx_parallel_data_B2),		// output received data
		.rx_syncstatus(rx_syncstatus_2),
		.rx_datak(rx_datak_2),
		.RX_reconfig_to_xcvr(ch2_2_to_xcvr),
		.RX_reconfig_from_xcvr(ch2_2_from_xcvr),
		.DRAM_RD_clk(rx_std_clkout_B2),							// reorder buffer readout clk
		.DRAM_RD_req(FIFO_rd_request[2]),						// reorder buffer read request
		.RX_Buffer_empty(FIFO_empty[2]),							// Buffer empty
		.Buffer_RD_Data(FIFO_RD_Data_2),							// Read out data to DRAM
		.Buffer_Data_Ready(FIFO_ready_mask[2])	
		);
		
	Channel_Data_Reorder_Buffer Channel_Data_Reorder_Buffer_2(
		.inclk(rx_std_clkout_B2),
		.outclk(avalon_clk),
		.rst_n(rst_n),
		
		// Signal to buffer
		.FIFO_ready_mask(FIFO_ready_mask[2]),			// bit mask for those ready FIFOs. Each connect to the RX_buf_ctrl module's Buffer_Data_Ready pin
		.FIFO_rd_data(FIFO_RD_Data_2),
		.FIFO_rd_request(FIFO_rd_request[2]),		   // bit mask for rd_request, each bit connect to RX_buf_ctrl module's DRAM_RD_req pin

		// Signal to DRAM user controller
		.BRAM_ready_mask(BRAM_ready_mask[2]),			// bit mask for those ready Reorder Buffers. Each connect to the DRAM_Addr_Gen module's BRAM_ready_mask pin
		.DRAM_wr_data(Buffer_RD_Data_2),
		.BRAM_rd_request(BRAM_rd_request[2])		   // bit mask for rd_request, each bit connect to DRAM_Addr_Gen module's BRAM_rd_request pin
		);
	
	// Transceiver RX for Board 3
	Trans_RX B3_RX(
		.rst_n(rst_n),
		.clk_trans(clk_trans),
		.SMA_GXB_RX_p(SMA_GXB_RX_B3_p),
		.rx_std_clkout(rx_std_clkout_B3),				// output clk for DRAM controller
		.rx_parallel_data(rx_parallel_data_B3),		// output received data
		.rx_syncstatus(rx_syncstatus_3),
		.rx_datak(rx_datak_3),
		.RX_reconfig_to_xcvr(ch3_3_to_xcvr),
		.RX_reconfig_from_xcvr(ch3_3_from_xcvr),
		.DRAM_RD_clk(rx_std_clkout_B3),							// reorder buffer readout clk
		.DRAM_RD_req(FIFO_rd_request[3]),						// reorder buffer read request
		.RX_Buffer_empty(FIFO_empty[3]),							// Buffer empty
		.Buffer_RD_Data(FIFO_RD_Data_3),							// Read out data to DRAM
		.Buffer_Data_Ready(FIFO_ready_mask[3])	
		);
		
	Channel_Data_Reorder_Buffer Channel_Data_Reorder_Buffer_3(
		.inclk(rx_std_clkout_B3),
		.outclk(avalon_clk),
		.rst_n(rst_n),
		
		// Signal to buffer
		.FIFO_ready_mask(FIFO_ready_mask[3]),			// bit mask for those ready FIFOs. Each connect to the RX_buf_ctrl module's Buffer_Data_Ready pin
		.FIFO_rd_data(FIFO_RD_Data_3),
		.FIFO_rd_request(FIFO_rd_request[3]),		   // bit mask for rd_request, each bit connect to RX_buf_ctrl module's DRAM_RD_req pin

		// Signal to DRAM user controller
		.BRAM_ready_mask(BRAM_ready_mask[3]),			// bit mask for those ready Reorder Buffers. Each connect to the DRAM_Addr_Gen module's BRAM_ready_mask pin
		.DRAM_wr_data(Buffer_RD_Data_3),
		.BRAM_rd_request(BRAM_rd_request[3])		   // bit mask for rd_request, each bit connect to DRAM_Addr_Gen module's BRAM_rd_request pin
		);
		
	// Transceiver RX for Board 4
	Trans_RX B4_RX(
		.rst_n(rst_n),
		.clk_trans(clk_trans),
		.SMA_GXB_RX_p(SMA_GXB_RX_B4_p),
		.rx_std_clkout(rx_std_clkout_B4),				// output clk for DRAM controller
		.rx_parallel_data(rx_parallel_data_B4),		// output received data
		.rx_syncstatus(rx_syncstatus_4),
		.rx_datak(rx_datak_4),
		.RX_reconfig_to_xcvr(ch4_4_to_xcvr),
		.RX_reconfig_from_xcvr(ch4_4_from_xcvr),
		.DRAM_RD_clk(rx_std_clkout_B4),							// reorder buffer readout clk
		.DRAM_RD_req(FIFO_rd_request[4]),						// reorder buffer read request
		.RX_Buffer_empty(FIFO_empty[4]),							// Buffer empty
		.Buffer_RD_Data(FIFO_RD_Data_4),							// Read out data to DRAM
		.Buffer_Data_Ready(FIFO_ready_mask[4])	
		);

	Channel_Data_Reorder_Buffer Channel_Data_Reorder_Buffer_4(
		.inclk(rx_std_clkout_B4),
		.outclk(avalon_clk),
		.rst_n(rst_n),
		
		// Signal to buffer
		.FIFO_ready_mask(FIFO_ready_mask[4]),			// bit mask for those ready FIFOs. Each connect to the RX_buf_ctrl module's Buffer_Data_Ready pin
		.FIFO_rd_data(FIFO_RD_Data_4),
		.FIFO_rd_request(FIFO_rd_request[4]),		   // bit mask for rd_request, each bit connect to RX_buf_ctrl module's DRAM_RD_req pin

		// Signal to DRAM user controller
		.BRAM_ready_mask(BRAM_ready_mask[4]),			// bit mask for those ready Reorder Buffers. Each connect to the DRAM_Addr_Gen module's BRAM_ready_mask pin
		.DRAM_wr_data(Buffer_RD_Data_4),
		.BRAM_rd_request(BRAM_rd_request[4])		   // bit mask for rd_request, each bit connect to DRAM_Addr_Gen module's BRAM_rd_request pin
		);
		
	// Transceiver RX for Board 5
	Trans_RX B5_RX(
		.rst_n(rst_n),
		.clk_trans(clk_trans),
		.SMA_GXB_RX_p(SMA_GXB_RX_B5_p),
		.rx_std_clkout(rx_std_clkout_B5),				// output clk for DRAM controller
		.rx_parallel_data(rx_parallel_data_B5),		// output received data
		.rx_syncstatus(rx_syncstatus_5),
		.rx_datak(rx_datak_5),
		.RX_reconfig_to_xcvr(ch5_5_to_xcvr),
		.RX_reconfig_from_xcvr(ch5_5_from_xcvr),
		.DRAM_RD_clk(rx_std_clkout_B5),							// reorder buffer readout clk
		.DRAM_RD_req(FIFO_rd_request[5]),						// reorder buffer read request
		.RX_Buffer_empty(FIFO_empty[5]),							// Buffer empty
		.Buffer_RD_Data(FIFO_RD_Data_5),							// Read out data to DRAM
		.Buffer_Data_Ready(FIFO_ready_mask[5])	
		);
		
	Channel_Data_Reorder_Buffer Channel_Data_Reorder_Buffer_5(
		.inclk(rx_std_clkout_B5),
		.outclk(avalon_clk),
		.rst_n(rst_n),
	
		// Signal to buffer
		.FIFO_ready_mask(FIFO_ready_mask[5]),			// bit mask for those ready FIFOs. Each connect to the RX_buf_ctrl module's Buffer_Data_Ready pin
		.FIFO_rd_data(FIFO_RD_Data_5),
		.FIFO_rd_request(FIFO_rd_request[5]),		   // bit mask for rd_request, each bit connect to RX_buf_ctrl module's DRAM_RD_req pin

		// Signal to DRAM user controller
		.BRAM_ready_mask(BRAM_ready_mask[5]),			// bit mask for those ready Reorder Buffers. Each connect to the DRAM_Addr_Gen module's BRAM_ready_mask pin
		.DRAM_wr_data(Buffer_RD_Data_5),
		.BRAM_rd_request(BRAM_rd_request[5])		   // bit mask for rd_request, each bit connect to DRAM_Addr_Gen module's BRAM_rd_request pin
		);
		
	// Transceiver RX for Board 6
	Trans_RX B6_RX(
		.rst_n(rst_n),
		.clk_trans(clk_trans),
		.SMA_GXB_RX_p(SMA_GXB_RX_B6_p),
		.rx_std_clkout(rx_std_clkout_B6),				// output clk for DRAM controller
		.rx_parallel_data(rx_parallel_data_B6),		// output received data
		.rx_syncstatus(rx_syncstatus_6),
		.rx_datak(rx_datak_6),
		.RX_reconfig_to_xcvr(ch6_6_to_xcvr),
		.RX_reconfig_from_xcvr(ch6_6_from_xcvr),
		.DRAM_RD_clk(rx_std_clkout_B6),							// reorder buffer readout clk
		.DRAM_RD_req(FIFO_rd_request[6]),						// reorder buffer read request
		.RX_Buffer_empty(FIFO_empty[6]),							// Buffer empty
		.Buffer_RD_Data(FIFO_RD_Data_6),							// Read out data to DRAM
		.Buffer_Data_Ready(FIFO_ready_mask[6])	
		);
		
	Channel_Data_Reorder_Buffer Channel_Data_Reorder_Buffer_6(
		.inclk(rx_std_clkout_B6),
		.outclk(avalon_clk),
		.rst_n(rst_n),
	
		// Signal to buffer
		.FIFO_ready_mask(FIFO_ready_mask[6]),			// bit mask for those ready FIFOs. Each connect to the RX_buf_ctrl module's Buffer_Data_Ready pin
		.FIFO_rd_data(FIFO_RD_Data_6),
		.FIFO_rd_request(FIFO_rd_request[6]),		   // bit mask for rd_request, each bit connect to RX_buf_ctrl module's DRAM_RD_req pin

		// Signal to DRAM user controller
		.BRAM_ready_mask(BRAM_ready_mask[6]),			// bit mask for those ready Reorder Buffers. Each connect to the DRAM_Addr_Gen module's BRAM_ready_mask pin
		.DRAM_wr_data(Buffer_RD_Data_6),
		.BRAM_rd_request(BRAM_rd_request[6])		   // bit mask for rd_request, each bit connect to DRAM_Addr_Gen module's BRAM_rd_request pin
		);
	
	// Transceiver RX for Board 7
	Trans_RX B7_RX(
		.rst_n(rst_n),
		.clk_trans(clk_trans),
		.SMA_GXB_RX_p(SMA_GXB_RX_B7_p),
		.rx_std_clkout(rx_std_clkout_B7),				// output clk for DRAM controller
		.rx_parallel_data(rx_parallel_data_B7),		// output received data
		.rx_syncstatus(rx_syncstatus_7),
		.rx_datak(rx_datak_7),
		.RX_reconfig_to_xcvr(ch7_7_to_xcvr),
		.RX_reconfig_from_xcvr(ch7_7_from_xcvr),
		.DRAM_RD_clk(rx_std_clkout_B7),							// reorder buffer readout clk
		.DRAM_RD_req(FIFO_rd_request[7]),						// reorder buffer read request
		.RX_Buffer_empty(FIFO_empty[7]),							// Buffer empty
		.Buffer_RD_Data(FIFO_RD_Data_7),							// Read out data to DRAM
		.Buffer_Data_Ready(FIFO_ready_mask[7])	
		);
		
	Channel_Data_Reorder_Buffer Channel_Data_Reorder_Buffer_7(
		.inclk(rx_std_clkout_B7),
		.outclk(avalon_clk),
		.rst_n(rst_n),
	
		// Signal to buffer
		.FIFO_ready_mask(FIFO_ready_mask[7]),			// bit mask for those ready FIFOs. Each connect to the RX_buf_ctrl module's Buffer_Data_Ready pin
		.FIFO_rd_data(FIFO_RD_Data_7),
		.FIFO_rd_request(FIFO_rd_request[7]),		   // bit mask for rd_request, each bit connect to RX_buf_ctrl module's DRAM_RD_req pin

		// Signal to DRAM user controller
		.BRAM_ready_mask(BRAM_ready_mask[7]),			// bit mask for those ready Reorder Buffers. Each connect to the DRAM_Addr_Gen module's BRAM_ready_mask pin
		.DRAM_wr_data(Buffer_RD_Data_7),
		.BRAM_rd_request(BRAM_rd_request[7])		   // bit mask for rd_request, each bit connect to DRAM_Addr_Gen module's BRAM_rd_request pin
		);
	
	
//	// Transciever Phy Reconfig Controller HSMCA
//	phy_recon phy_recon_A(
//		.reconfig_busy(reconfig_busy_A),
//		.mgmt_clk_clk(clk_trans),
//		.mgmt_rst_reset(!rst_n),
//		.reconfig_mgmt_address(0),
//		.reconfig_mgmt_read(0),
//		.reconfig_mgmt_readdata(),    //=> open,   					//: out std_logic_vector(31 downto 0);                     // readdata
//		.reconfig_mgmt_waitrequest(), //=> open,   					//: out std_logic;                                         // waitrequest
//		.reconfig_mgmt_write(0),
//		.reconfig_mgmt_writedata(0),
//		.ch0_0_to_xcvr(ch4_4_to_xcvr),
//		.ch0_0_from_xcvr(ch4_4_from_xcvr),
//		.ch1_1_to_xcvr(ch5_5_to_xcvr),
//		.ch1_1_from_xcvr(ch5_5_from_xcvr),
//		.ch2_2_to_xcvr(ch6_6_to_xcvr),
//		.ch2_2_from_xcvr(ch6_6_from_xcvr),
//		.ch3_3_to_xcvr(ch7_7_to_xcvr),
//		.ch3_3_from_xcvr(ch7_7_from_xcvr)
//		);	
//	
	// Transciever Phy Reconfig Controller HSMCB
	phy_recon phy_recon(
		.reconfig_busy(reconfig_busy),
		.mgmt_clk_clk(clk_trans),
		.mgmt_rst_reset(!rst_n),
		.reconfig_mgmt_address(0),
		.reconfig_mgmt_read(0),
		.reconfig_mgmt_readdata(),    //=> open,   					//: out std_logic_vector(31 downto 0);                     // readdata
		.reconfig_mgmt_waitrequest(), //=> open,   					//: out std_logic;                                         // waitrequest
		.reconfig_mgmt_write(0),
		.reconfig_mgmt_writedata(0),
		.ch0_0_to_xcvr(ch0_0_to_xcvr),
		.ch0_0_from_xcvr(ch0_0_from_xcvr),
		.ch1_1_to_xcvr(ch1_1_to_xcvr),
		.ch1_1_from_xcvr(ch1_1_from_xcvr),
		.ch2_2_to_xcvr(ch2_2_to_xcvr),
		.ch2_2_from_xcvr(ch2_2_from_xcvr),
		.ch3_3_to_xcvr(ch3_3_to_xcvr),
		.ch3_3_from_xcvr(ch3_3_from_xcvr),
		.ch4_4_to_xcvr(ch4_4_to_xcvr),
		.ch4_4_from_xcvr(ch4_4_from_xcvr),
		.ch5_5_to_xcvr(ch5_5_to_xcvr),
		.ch5_5_from_xcvr(ch5_5_from_xcvr),
		.ch6_6_to_xcvr(ch6_6_to_xcvr),
		.ch6_6_from_xcvr(ch6_6_from_xcvr),
		.ch7_7_to_xcvr(ch7_7_to_xcvr),
		.ch7_7_from_xcvr(ch7_7_from_xcvr)
		);	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////
	// DRAM Control Module
	////////////////////////////////////////////////////////////////////////////////////////////////////		
	// DRAM Controller
	dma_mem dma_mem_inst(
		.ddr3_top_memory_mem_a		 						(ddr3b_a),
		.ddr3_top_memory_mem_ba             			(ddr3b_ba),
		.ddr3_top_memory_mem_cas_n          			(ddr3b_casn),
		.ddr3_top_memory_mem_cke            			(ddr3b_cke),		
		.ddr3_top_memory_mem_ck_n		 					(ddr3b_clk_n),		
		.ddr3_top_memory_mem_ck		 						(ddr3b_clk_p),
		.ddr3_top_memory_mem_cs_n           			(ddr3b_csn),
		.ddr3_top_memory_mem_dm             			(ddr3b_dm),
		.ddr3_top_memory_mem_dq         					(ddr3b_dq),
		.ddr3_top_memory_mem_dqs        					(ddr3b_dqs_p),		
		.ddr3_top_memory_mem_dqs_n      					(ddr3b_dqs_n),
		.ddr3_top_memory_mem_odt            			(ddr3b_odt),
		.ddr3_top_memory_mem_ras_n          			(ddr3b_rasn),
		.ddr3_top_memory_mem_reset_n        			(ddr3b_resetn),
		.ddr3_top_memory_mem_we_n          			 	(ddr3b_wen),
		.ddr3_top_oct_rzqin									(rzqin_1_5v),
		.ddr3_top_status_local_init_done    			(),
		.ddr3_top_status_local_cal_success  			(),
		.ddr3_top_status_local_cal_fail     			(), 
		
		.clk_125_clk_in_clk                    		(clkin_125),          
		.clk_125_clk_in_reset_reset_n          		(rst_n), 		

		.sdram_pll_sharing_pll_mem_clk               (),
		.sdram_pll_sharing_pll_write_clk             (),
		.sdram_pll_sharing_pll_locked                (),
		.sdram_pll_sharing_pll_write_clk_pre_phy_clk (),
		.sdram_pll_sharing_pll_addr_cmd_clk          (),
		.sdram_pll_sharing_pll_avl_clk               (),
		.sdram_pll_sharing_pll_config_clk            (),
		.sdram_pll_sharing_pll_mem_phy_clk           (),
		.sdram_pll_sharing_afi_phy_clk               (),
		.sdram_pll_sharing_pll_avl_phy_clk           (),

		.sdram_afi_clk_clk									(avalon_clk),
		.sdram_avl_read										(read),										//.read
		.sdram_avl_write										(DRAM_Write_Enable),                //.write
		.sdram_avl_address									(DRAM_WR_address),                  //.address
		.sdram_avl_writedata									(DRAM_Write_Data),                  //.writedata
		.sdram_avl_burstcount								(DRAM_Write_Burst_Count),           //.burstcount
		.sdram_avl_beginbursttransfer						(DRAM_Write_Burst_Begin),           //.beginbursttransfer

		.sdram_avl_waitrequest_n							(DRAM_Wait_Request),                //.sdram_avl.waitrequest_n
		.sdram_avl_readdata									(read_data),                        //.readdata
		.sdram_avl_readdatavalid							(read_valid)                        //.readdatavalid
		);

endmodule
