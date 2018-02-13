////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Top wrapper for simulation the entire system
// Function:
//		Removed the RX controller
//		Removed DRAM controller
//		Removed Transceiver reconfiguration controller
//		Use RX_Buf_Ctrl to mimic the Trans_RX module's output
//
// By: Chen Yang
// Rev0: 02/05/2018
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


module simulation_top
(
	// Clock and reset		
	input rst_n,									// global reset, reset when low
	
	input clk_trans,								// mimic the transceiver output clock
	input avalon_clk,								// mimic the DRAM controller clock

	input DRAM_read_address,					// DRAM read address for verification
	output MASK_output,					      // Stop bit mask being trucated
	
	// Triggering status
	output triggering_status,					// Status showing whether the current system is under triggering status
	
	// simulation input synthetic data
	input [1:0]	 rx_syncstatus,				// manual set the rx_syncstatus as 2'b11
	input [1:0]	 rx_datak,						// manual set as 2'b00
	input [15:0] rx_parallel_data_B0,		// mimic the RX received parallel data
	input [15:0] rx_parallel_data_B1,		// mimic the RX received parallel data		
	input [15:0] rx_parallel_data_B2,		// mimic the RX received parallel data		
	input [15:0] rx_parallel_data_B3,		// mimic the RX received parallel data		
	input [15:0] rx_parallel_data_B4,		// mimic the RX received parallel data		
	input [15:0] rx_parallel_data_B5,		// mimic the RX received parallel data		
	input [15:0] rx_parallel_data_B6,		// mimic the RX received parallel data		
	input [15:0] rx_parallel_data_B7,		// mimic the RX received parallel data		
	
	// DRAM interface
	input DRAM_Wait_Request,
	output [24:0] DRAM_WR_address,
	output [255:0] DRAM_Write_Data,
	output DRAM_Write_Enable,
	output [4:0] DRAM_Write_Burst_Count,	
	output DRAM_Write_Burst_Begin
);
	
	////////////////////////////////////////////////////////////////////////////////////////////////////
	// RX Signals
	////////////////////////////////////////////////////////////////////////////////////////////////////
	wire 				rx_std_clkout_B0;				// clock recovered from transceiver Board 0
	wire 				rx_std_clkout_B1;				// clock recovered from transceiver Board 1
	wire 				rx_std_clkout_B2;				// clock recovered from transceiver Board 2
	wire 				rx_std_clkout_B3;				// clock recovered from transceiver Board 3
	wire 				rx_std_clkout_B4;				// clock recovered from transceiver Board 4
	wire 				rx_std_clkout_B5;				// clock recovered from transceiver Board 5
	wire 				rx_std_clkout_B6;				// clock recovered from transceiver Board 6
	wire 				rx_std_clkout_B7;				// clock recovered from transceiver Board 7
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
	
	// Hardwire the trans_rx related signals
	assign rx_std_clkout_B0 = clk_trans;
	assign rx_std_clkout_B1 = clk_trans;
	assign rx_std_clkout_B2 = clk_trans;
	assign rx_std_clkout_B3 = clk_trans;
	assign rx_std_clkout_B4 = clk_trans;
	assign rx_std_clkout_B5 = clk_trans;
	assign rx_std_clkout_B6 = clk_trans;
	assign rx_std_clkout_B7 = clk_trans;
	assign rx_syncstatus_0 = rx_syncstatus;
	assign rx_syncstatus_1 = rx_syncstatus;
	assign rx_syncstatus_2 = rx_syncstatus;
	assign rx_syncstatus_3 = rx_syncstatus;
	assign rx_syncstatus_4 = rx_syncstatus;
	assign rx_syncstatus_5 = rx_syncstatus;
	assign rx_syncstatus_6 = rx_syncstatus;
	assign rx_syncstatus_7 = rx_syncstatus;
	assign rx_datak_0 = rx_datak;
	assign rx_datak_1 = rx_datak;
	assign rx_datak_2 = rx_datak;
	assign rx_datak_3 = rx_datak;
	assign rx_datak_4 = rx_datak;
	assign rx_datak_5 = rx_datak;
	assign rx_datak_6 = rx_datak;
	assign rx_datak_7 = rx_datak;
	
	////////////////////////////////////////////////////////////////////////////////////////////////////
	// Trigger and DRAM control realted signals
	////////////////////////////////////////////////////////////////////////////////////////////////////	
	wire [15:0]    triggering_time_stamp;
	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////
	// Trigger 
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
	
	// Combination logic to select read data from 8 FIFOs
	always@(*)
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
		// Signal to reorder buffer
		.BRAM_ready_mask(BRAM_ready_mask),			// bit mask for those ready FIFOs. Each connect to the Channel_Data_Reorder_Buffer module's BRAM_ready_mask pin				// connect to RX_buf_ctrl module's RX_Buffer_empty pin
		.BRAM_rd_data(Selected_Data_to_DRAM),
		.BRAM_rd_request(BRAM_rd_request),		   // bit mask for rd_request, each bit connect to Channel_Data_Reorder_Buffer module's BRAM_RD_req pin
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
	// Transceiver and Buffer module
	////////////////////////////////////////////////////////////////////////////////////////////////////
	// Mimic received parallel data from Trans_RX
	RX_Buf_Ctrl RX_Buf_Ctrl_0(
		.rx_std_clkout(rx_std_clkout_B0),
		.rst_n(rst_n),
		.rx_syncstatus(rx_syncstatus_0),
		.rx_datak(rx_datak_0),
		.RX_data(rx_parallel_data_B0),
	
		.DRAM_RD_clk(rx_std_clkout_B0),					// reorder buffer readout clk
		.DRAM_RD_req(FIFO_rd_request[0]),				// reorder buffer read request
		.RX_Buffer_empty(FIFO_empty[0]),					// currently unused
		.Buffer_RD_Data(FIFO_RD_Data_0),					// output date for reorder buffer
		.Buffer_Data_Ready(FIFO_ready_mask[0])			// RX buffer ready to send to reorder buffer
	);
	
	// Mimic received parallel data from Trans_RX
	RX_Buf_Ctrl RX_Buf_Ctrl_1(
		.rx_std_clkout(rx_std_clkout_B1),
		.rst_n(rst_n),
		.rx_syncstatus(rx_syncstatus_1),
		.rx_datak(rx_datak_1),
		.RX_data(rx_parallel_data_B1),
	
		.DRAM_RD_clk(rx_std_clkout_B1),					// reorder buffer readout clk
		.DRAM_RD_req(FIFO_rd_request[1]),				// reorder buffer read request
		.RX_Buffer_empty(FIFO_empty[1]),					// currently unused
		.Buffer_RD_Data(FIFO_RD_Data_1),					// output date for reorder buffer
		.Buffer_Data_Ready(FIFO_ready_mask[1])			// RX buffer ready to send to reorder buffer
	);
	
	// Mimic received parallel data from Trans_RX
	RX_Buf_Ctrl RX_Buf_Ctrl_2(
		.rx_std_clkout(rx_std_clkout_B2),
		.rst_n(rst_n),
		.rx_syncstatus(rx_syncstatus_2),
		.rx_datak(rx_datak_2),
		.RX_data(rx_parallel_data_B2),
	
		.DRAM_RD_clk(rx_std_clkout_B2),					// reorder buffer readout clk
		.DRAM_RD_req(FIFO_rd_request[2]),				// reorder buffer read request
		.RX_Buffer_empty(FIFO_empty[2]),					// currently unused
		.Buffer_RD_Data(FIFO_RD_Data_2),					// output date for reorder buffer
		.Buffer_Data_Ready(FIFO_ready_mask[2])			// RX buffer ready to send to reorder buffer
	);
	
	// Mimic received parallel data from Trans_RX
	RX_Buf_Ctrl RX_Buf_Ctrl_3(
		.rx_std_clkout(rx_std_clkout_B3),
		.rst_n(rst_n),
		.rx_syncstatus(rx_syncstatus_3),
		.rx_datak(rx_datak_3),
		.RX_data(rx_parallel_data_B3),
	
		.DRAM_RD_clk(rx_std_clkout_B3),					// reorder buffer readout clk
		.DRAM_RD_req(FIFO_rd_request[3]),				// reorder buffer read request
		.RX_Buffer_empty(FIFO_empty[3]),					// currently unused
		.Buffer_RD_Data(FIFO_RD_Data_3),					// output date for reorder buffer
		.Buffer_Data_Ready(FIFO_ready_mask[3])			// RX buffer ready to send to reorder buffer
	);
	
	// Mimic received parallel data from Trans_RX
	RX_Buf_Ctrl RX_Buf_Ctrl_4(
		.rx_std_clkout(rx_std_clkout_B4),
		.rst_n(rst_n),
		.rx_syncstatus(rx_syncstatus_4),
		.rx_datak(rx_datak_4),
		.RX_data(rx_parallel_data_B4),
	
		.DRAM_RD_clk(rx_std_clkout_B4),					// reorder buffer readout clk
		.DRAM_RD_req(FIFO_rd_request[4]),				// reorder buffer read request
		.RX_Buffer_empty(FIFO_empty[4]),					// currently unused
		.Buffer_RD_Data(FIFO_RD_Data_4),					// output date for reorder buffer
		.Buffer_Data_Ready(FIFO_ready_mask[4])			// RX buffer ready to send to reorder buffer
	);
	
	// Mimic received parallel data from Trans_RX
	RX_Buf_Ctrl RX_Buf_Ctrl_5(
		.rx_std_clkout(rx_std_clkout_B5),
		.rst_n(rst_n),
		.rx_syncstatus(rx_syncstatus_5),
		.rx_datak(rx_datak_5),
		.RX_data(rx_parallel_data_B5),
	
		.DRAM_RD_clk(rx_std_clkout_B5),					// reorder buffer readout clk
		.DRAM_RD_req(FIFO_rd_request[5]),				// reorder buffer read request
		.RX_Buffer_empty(FIFO_empty[5]),					// currently unused
		.Buffer_RD_Data(FIFO_RD_Data_5),					// output date for reorder buffer
		.Buffer_Data_Ready(FIFO_ready_mask[5])			// RX buffer ready to send to reorder buffer
	);
	
	// Mimic received parallel data from Trans_RX
	RX_Buf_Ctrl RX_Buf_Ctrl_6(
		.rx_std_clkout(rx_std_clkout_B6),
		.rst_n(rst_n),
		.rx_syncstatus(rx_syncstatus_6),
		.rx_datak(rx_datak_6),
		.RX_data(rx_parallel_data_B6),
	
		.DRAM_RD_clk(rx_std_clkout_B6),					// reorder buffer readout clk
		.DRAM_RD_req(FIFO_rd_request[6]),				// reorder buffer read request
		.RX_Buffer_empty(FIFO_empty[6]),					// currently unused
		.Buffer_RD_Data(FIFO_RD_Data_6),					// output date for reorder buffer
		.Buffer_Data_Ready(FIFO_ready_mask[6])			// RX buffer ready to send to reorder buffer
	);
	
	// Mimic received parallel data from Trans_RX
	RX_Buf_Ctrl RX_Buf_Ctrl_7(
		.rx_std_clkout(rx_std_clkout_B7),
		.rst_n(rst_n),
		.rx_syncstatus(rx_syncstatus_7),
		.rx_datak(rx_datak_7),
		.RX_data(rx_parallel_data_B7),
	
		.DRAM_RD_clk(rx_std_clkout_B7),					// reorder buffer readout clk
		.DRAM_RD_req(FIFO_rd_request[7]),				// reorder buffer read request
		.RX_Buffer_empty(FIFO_empty[7]),					// currently unused
		.Buffer_RD_Data(FIFO_RD_Data_7),					// output date for reorder buffer
		.Buffer_Data_Ready(FIFO_ready_mask[7])			// RX buffer ready to send to reorder buffer
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
		
endmodule
