////////////////////////////////////////////////////////////////////////////////////////////////////
// Trans RX Buffer Control Logic
////////////////////////////////////////////////////////////////////////////////////////////////////

module RX_Buf_Ctrl(
	input 				rx_std_clkout,								// clk signal for RX data receiving
	input 				rst_n,										// reset signal, reset on low
	input [1:0]			rx_syncstatus,								// syncstatus connect to transceiver IP
	input	[1:0]			rx_datak,									// signify the control word or data word
	input [15:0]		RX_data,										// data received on RX
	
	// DRAM writing signal
	input 				DRAM_RD_clk,								// DRAM read clk for the buffer
	input					DRAM_RD_req,								// DRAM read request
	output				RX_Buffer_empty,							// Buffer empty
	//input [6:0]			Buffer_RD_Addr,							// Read address for RX buffer
	output [15:0]		Buffer_RD_Data,							// Read out data to DRAM
	output				Buffer_Data_Ready									// Signal to let DRAM know the data is ready			

);

	parameter WAIT_FOR_START =	2'b00;
	parameter BUFFERING 		 =	2'b01;
	parameter END_RECORDING  =	2'b10;
	
	reg [1:0]	State;
	reg [1:0]	Next_State;
	
	reg [6:0]	Buffer_WR_Counter;
	reg			Start_Recording;									// indicate the start of writing RX data to buffer
	reg			WR_Buffer_Select;									// If = 0, write data to Buffer 0; If = 1, write data to Buffer 1
	reg 			RD_Buffer_Select;									// If = 0, read data from Buffer 0; If = 1, read data from Buffer 1
	
	// RX buffer
	//reg [15:0] 	Buffer_0 [0:125];									// 1st RX buffer to store the received data
	//reg [15:0]	Buffer_1 [0:125];									// 2nd RX buffer to store the received data
	//reg			Buffer_0_RD_Ready;								// If set, signify the data is ready to write to DRAM
	//reg			Buffer_1_RD_Ready;
	reg[1:0]		Buffer_RD_Ready;									// 2 bit for 2 buffers each, high signify ready to read
	wire[1:0]	Buffer_empty;	
	wire[1:0]	Buffer_full;
	wire[15:0]	Buffer_0_RD_Data;
	wire[15:0]	Buffer_1_RD_Data;
	reg [15:0]	Buffer_WR_Data;
	
	
	// Assign the output buffer data from 2 buffers
	// Based on the assumption that when the 2nd buffer is full, the previous buffer already finished readout
	// If not, then there's a possibility that while DRAM is reading out from Buffer 0, and Buffer 1 is just finished writing, then DRAM starts to read from Buffer 1 from there, this is wrong
	assign Buffer_RD_Data = (RD_Buffer_Select)? Buffer_1_RD_Data : Buffer_0_RD_Data;
	
	
	// When there's one or more buffer ready to be read, then the Buffer_RD_Ready signal is set
	//assign Buffer_Data_Ready = (Buffer_RD_Ready != 0)? 1 : 0;
	assign Buffer_Data_Ready = (Buffer_RD_Ready & ~RX_Buffer_empty) ? 1 : 0;
	
	/* Assign RX_Buffer_empty to reflect the state of the buffer indicated by RD_Buffer_Select */
	assign RX_Buffer_empty = (RD_Buffer_Select) ? Buffer_empty[1] : Buffer_empty[0];
	
		
	RX_FIFO RX_Buffer_0(
		.rdclk(DRAM_RD_clk),											// RD clk, connect to DRAM_RD_clk
		.rdreq(DRAM_RD_req & !RD_Buffer_Select),				// RD request, start to pop data when set as 1
		.rdempty(Buffer_empty[0]),									// FIFO empty flag
		.q(Buffer_0_RD_Data),											// Read out data
		.wrclk(rx_std_clkout),										// WR clk, connect to rx_std_clkout
		.wrreq(Start_Recording & !WR_Buffer_Select),			// WR request
		.wrfull(Buffer_full[0]),									// FIFO full flag
		.data(Buffer_WR_Data)													// WR data
		);
		
	RX_FIFO RX_Buffer_1(
		.rdclk(DRAM_RD_clk),											// RD clk, connect to DRAM_RD_clk
		.rdreq(DRAM_RD_req & RD_Buffer_Select),				// RD request, start to pop data when set as 1
		.rdempty(Buffer_empty[1]),									// FIFO empty flag
		.q(Buffer_1_RD_Data),											// Read out data
		.wrclk(rx_std_clkout),										// WR clk, connect to rx_std_clkout
		.wrreq(Start_Recording & WR_Buffer_Select),			// WR request
		.wrfull(Buffer_full[1]),									// FIFO full flag
		.data(Buffer_WR_Data)													// WR data
		);
	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////
	// Control logic for writting RX buffer
	////////////////////////////////////////////////////////////////////////////////////////////////////
	always@(posedge rx_std_clkout)
		begin
		if(!rst_n)
			begin
			// Buffer RD & WR
			Buffer_RD_Ready <= 2'b00;
			Start_Recording <= 1'b0;
			WR_Buffer_Select <= 1'b0;
			RD_Buffer_Select <= 1'b1;														// Differs from the WR select
			Buffer_WR_Counter <= 7'd0;
			Buffer_WR_Data <= 16'd0;
			// FSM control
			State <= WAIT_FOR_START;
			end
		else if(rx_syncstatus == 2'b11 & rx_datak == 2'b00)
			Buffer_WR_Data <= RX_data;
			begin
			case(State)
				WAIT_FOR_START:
					begin
					Buffer_RD_Ready <= Buffer_RD_Ready;
					WR_Buffer_Select <= WR_Buffer_Select;
					RD_Buffer_Select <= RD_Buffer_Select;
					Buffer_WR_Counter <= 7'd0;
						if(RX_data == 16'hDEAD) begin 													// Find the starting word
							State <= BUFFERING;
							Start_Recording <= 1'b1;
						end 
						else begin 
							State <= WAIT_FOR_START;
							Start_Recording <= 1'b0;
						end 
					end
					
				BUFFERING:
					begin
					Buffer_RD_Ready <= Buffer_RD_Ready;
					WR_Buffer_Select <= WR_Buffer_Select;
					RD_Buffer_Select <= RD_Buffer_Select;
					Buffer_WR_Counter <= Buffer_WR_Counter + 1'b1;
					if((RX_data == 16'h7FFF)&(Buffer_WR_Counter > 120))		 	// Find the ending word while make sure enough number of data is received
																									// Make sure the ending word is not the same as real data word
						begin
						Start_Recording <= 1'b1;	/* Finish write */
						State <= END_RECORDING;
						end
					else
						begin
						if(!Buffer_full[WR_Buffer_Select])								// If the current writing buffer is still full, then stop writing data to it, (Error out maybe?)
							Start_Recording <= 1'b1;
						else
							Start_Recording <= 1'b0;
							
						State <= BUFFERING;
						end
					end
					
				END_RECORDING:
					begin
					Buffer_RD_Ready[WR_Buffer_Select] <= 1'b1;						// Assign the current writing buffer as ready for read after the writing is finished
					Buffer_RD_Ready[!WR_Buffer_Select] <= Buffer_RD_Ready[!WR_Buffer_Select];	// Keep the staus of the other buffer
					WR_Buffer_Select <= WR_Buffer_Select + 1'b1;						// Point to next WR Buffer
					RD_Buffer_Select <= RD_Buffer_Select + 1'b1;						// Point to next RD Buffer
					Buffer_WR_Counter <= 7'd0;
						if(RX_data == 16'hBEEF) begin 													// Check if the next package is coming immediately after the previous one
							State <= BUFFERING;
							Start_Recording <= 1'b1;
						end 
						else begin 
							State <= WAIT_FOR_START;
							Start_Recording <= 1'b0;
						end 	
					end		
			
			endcase
			end
		end
/*		
	////////////////////////////////////////////////////////////////////////////////////////////////////
	// Writing Data to RX Buffer
	////////////////////////////////////////////////////////////////////////////////////////////////////
	always@(posedge rx_std_clkout)
		begin
		if(!rst_n)
			begin
			Buffer_WR_Counter <= 7'd0;
			end
		else
			begin
			if(Start_Recording)
				begin
				Buffer_WR_Counter <= Buffer_WR_Counter + 1'b1;
				if(!WR_Buffer_Select)														// If WR buffer select buffer 0
					Buffer_0[Buffer_WR_Counter] <= RX_data;
				else
					Buffer_1[Buffer_WR_Counter] <= RX_data;
				end
			else																					// Clear the counter if the Start_Recording signal is cleared
				Buffer_WR_Counter <= 7'd0;
			
			end
		end
*/		
endmodule