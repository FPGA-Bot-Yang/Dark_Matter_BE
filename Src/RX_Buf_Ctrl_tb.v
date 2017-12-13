`timescale 1ns/1ns
module RX_Buf_Ctrl_tb;
	reg 				rx_std_clkout;								// clk signal for RX data receiving
	reg 				rst_n;										// reset signal, reset on low
	reg [1:0]		rx_syncstatus;								// syncstatus connect to transceiver IP
	reg [1:0]		rx_datak;									// signify the control word or data word
	reg [15:0]		RX_data;										// data received on RX
	
	// DRAM writing signal
	reg 				DRAM_RD_clk;								// DRAM read clk for the buffer
	reg				DRAM_RD_req;								// DRAM read request
	wire				RX_Buffer_empty;							// Buffer empty
	wire [15:0]		Buffer_RD_Data;							// Read out data to DRAM
	wire				Buffer_Data_Ready;							// Signal to let DRAM know the data is ready			

	/* Loop Variables */
	integer ii, jj;
	reg [3:0]		count0;
	reg [6:0]		count1;
	reg [15:0]		TS;
	RX_Buf_Ctrl UUT (
		.rx_std_clkout(rx_std_clkout),
		.rst_n(rst_n),
		.rx_syncstatus(rx_syncstatus),
		.rx_datak(rx_datak),
		.RX_data(RX_data),
		
		// DRAM Writing Signal 
		.DRAM_RD_clk(DRAM_RD_clk),
		.DRAM_RD_req(DRAM_RD_req),
		.RX_Buffer_empty(RX_Buffer_empty),
		.Buffer_RD_Data(Buffer_RD_Data),
		.Buffer_Data_Ready(Buffer_Data_Ready)
	);
	
	/* Generate Clocks
	 * rx_std_clkout = 125 MHz
    * DRAM_RD_clk = 160 MHz 
	 */
	always begin
		#6 rx_std_clkout <= ~rx_std_clkout;
	end 
	
	always begin 
		#5 DRAM_RD_clk <= ~DRAM_RD_clk;
	end 
	
	/* Control Buffer RD Requests */
	always@(posedge DRAM_RD_clk)	begin 
		if (Buffer_Data_Ready)
			DRAM_RD_req <= 1'b1;
		else 
			DRAM_RD_req <= 1'b0;
	end 


	initial begin 
		rx_std_clkout <= 1'b0;
		rst_n <= 1'b0;
		rx_syncstatus <= 2'b11;
		rx_datak <= 2'b00;
		RX_data <= 16'HFFFF;
		
		DRAM_RD_clk <= 1'b0;	
		count0 <= 4'd0;
		count1 <= 7'd0;
		TS <= 16'd5;
		
		/* Turn off Reset */
		#12;
		rst_n <= 1'b1;
		
		/* Begin data transmission */
		#6;
		for (ii = 0; ii < 16; ii = ii + 1) begin 
			if (ii % 4 == 0) begin 
				#36 RX_data <= 16'hFFFF; // Do not go directly to buffer
				#12 RX_data <= 16'hDEAD;
			end 
			else 
				#12 RX_data <= 16'hBEEF;
			count0 <= count0 + 1'b1;
			for (jj = 0; jj < 127; jj = jj + 1) begin 
				#12;
				if (jj == 0) begin 
					RX_data <= TS;
					TS <= TS + 1'd1;
				end 
				else if (jj == 126) begin 
					RX_data <= 16'h7FFF;
					count1 <= 7'd0;				
				end 
				else begin  
					RX_data <= {4'd0, count0, count1};				
					count1 <= count1 + 1'b1;
				end 
			end 
		end 
			
	end 

endmodule 