 module Trans_RX(
	input 			rst_n,								// Connect to system rst_n
	input 			clk_trans,							// Connect to top level transceiver clk port, 125MHz
																// Used as transceiver input reference clock
	
	input 			SMA_GXB_RX_p,						// RX seriel receiving PIN
	
	output			rx_std_clkout,						// RX output clock signal for DRAM controller
	output [15:0]	rx_parallel_data,					// RX received data output for DRAM write
	output [1:0]   rx_syncstatus,
	output [1:0]   rx_datak,

	// Reconfig ctrl input
	input [69:0]	RX_reconfig_to_xcvr,
	output [45:0]	RX_reconfig_from_xcvr,
	
	// DRAM signal
	input 				DRAM_RD_clk,								// DRAM read clk for the buffer
	input					DRAM_RD_req,								// DRAM read request
	output				RX_Buffer_empty,							// Buffer empty
	output [15:0]		Buffer_RD_Data,							// Read out data to DRAM
	output				Buffer_Data_Ready							// Signal to let DRAM know the data is ready			
	);

	
	//RX
	wire	Transceiver_Clk_125MHz;		// Transceiver clk to RX
	assign Transceiver_Clk_125MHz = clk_trans;
	
	wire	rx_pma_clkout;					// rx_pma_clkout
	wire	rx_is_lockedtoref;			// rx_is_lockedtoref
	wire[1:0]	rx_errdetect;					// rx_errdetect
	wire[1:0]	rx_disperr;						// rx_disperr
	wire[1:0]	rx_runningdisp;					// rx_runningdisp
	wire[35:0]	unused_rx_parallel_data;		// unused_rx_parallel_data
	wire			reconfig_busy;
	wire[1:0]	rx_patterndetect;				// rx_patterndetect	

	
	// PHY_reset
	wire	rx_analogreset;
	wire	rx_digitalreset;
	wire	rx_ready;
	wire	rx_is_lockedtodata;
	wire	rx_cal_busy;
	reg	tx_datak;
	
	wire	rx_std_pcfifo_full;
	wire	rx_std_pcfifo_empty;
	reg	rx_std_byteorder_ena;
	wire	rx_std_byteorder_flag;    
	reg	rx_std_wa_patternalign;


	// RX controller module by Ethan
	// To detect if RX is starting to receive data and send signal to DRAM
	
	
	RX_Buf_Ctrl RX_Buf_Ctrl(
		.rx_std_clkout(rx_std_clkout),
		.rst_n(rst_n),
		.rx_syncstatus(rx_syncstatus),
		.rx_datak(rx_datak),
		.RX_data(rx_parallel_data),
	
		.DRAM_RD_clk(DRAM_RD_clk),
		.DRAM_RD_req(DRAM_RD_req),
		.RX_Buffer_empty(RX_Buffer_empty),							
		.Buffer_RD_Data(Buffer_RD_Data),
		.Buffer_Data_Ready(Buffer_Data_Ready)
	);

	
	// Transciever Reset Controller
	PHY_reset PHY_reset(
		.clock(clk_trans),
		.reset(!rst_n),
		.rx_analogreset(rx_analogreset),
		.rx_digitalreset(rx_digitalreset),
		.rx_ready(rx_ready),
		.rx_is_lockedtodata(rx_is_lockedtodata),
		.rx_cal_busy(rx_cal_busy)
		);
	
	// RX
	// Running at 125 MHz, data rate 1Gbps (eventually this should be at least 2Gbps)
	GXB_RX GXB_RX(
		.rx_serial_data(SMA_GXB_RX_p),	
		.rx_analogreset(rx_analogreset),
		.rx_digitalreset(rx_digitalreset),
		.rx_cdr_refclk(Transceiver_Clk_125MHz),
		.rx_std_coreclkin(Transceiver_Clk_125MHz),
		.rx_pma_clkout(rx_pma_clkout),
		.rx_is_lockedtoref(rx_is_lockedtoref),
		.rx_is_lockedtodata(rx_is_lockedtodata),
		.rx_std_clkout(rx_std_clkout),
		.rx_std_pcfifo_full(rx_std_pcfifo_full),
		.rx_std_pcfifo_empty(rx_std_pcfifo_empty),
		.rx_std_byteorder_ena(rx_std_byteorder_ena),
		.rx_std_byteorder_flag(rx_std_byteorder_flag),
		.rx_std_wa_patternalign(rx_std_wa_patternalign),
		.rx_cal_busy(rx_cal_busy),
		.reconfig_to_xcvr(RX_reconfig_to_xcvr),
		.reconfig_from_xcvr(RX_reconfig_from_xcvr),
		.rx_parallel_data(rx_parallel_data),
		.rx_datak(rx_datak),
		.rx_errdetect(rx_errdetect),
		.rx_disperr(rx_disperr),
		.rx_runningdisp(rx_runningdisp),
		.rx_patterndetect(rx_patterndetect),
		.rx_syncstatus(rx_syncstatus),
		.unused_rx_parallel_data(unused_rx_parallel_data)
		);	
		
endmodule