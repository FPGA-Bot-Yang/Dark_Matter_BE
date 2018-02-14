///////////////////////////////////////////////////////////////////////////////////////////////////////
// Testbench evaluate the Channel_Data_Reorder_Buffer
// By: Chen Yang
// 02/06/2018
///////////////////////////////////////////////////////////////////////////////////////////////////////


`timescale 1ns/1ns

module simulation_top_tb;
	reg inclk; 
	reg outclk;								
	reg rst_n;								

	reg [15:0] rx_parallel_data_B0;
	reg [15:0] rx_parallel_data_B1;
	reg [15:0] rx_parallel_data_B2;
	reg [15:0] rx_parallel_data_B3;
	reg [15:0] rx_parallel_data_B4;
	reg [15:0] rx_parallel_data_B5;
	reg [15:0] rx_parallel_data_B6;
	reg [15:0] rx_parallel_data_B7;
	
	wire triggering_status;

	reg DRAM_Wait_Request;
	wire [24:0] DRAM_WR_address;
	wire [255:0] DRAM_Write_Data;
	wire DRAM_Write_Enable;
	wire [4:0] DRAM_Write_Burst_Count;	
	wire DRAM_Write_Burst_Begin;

	simulation_top simulation_top_UUT(
		// Clock and reset		
		.rst_n(rst_n),										// Input: global reset, reset when low
	
		.clk_trans(inclk),								// Input: mimic the transceiver output clock
		.avalon_clk(outclk),								// Input: mimic the DRAM controller clock

		.DRAM_read_address(),							// Input: DRAM read address for verification  //unuse
		.MASK_output(),					      		// Output: Stop bit mask being trucated  // unuse
	
		// Triggering status
		.triggering_status(triggering_status),		// Output: Status showing whether the current system is under triggering status
	
		// simulation input synthetic data
		.rx_syncstatus(2'b11),									// Input[1:0]: manual set the rx_syncstatus as 2'b11
		.rx_datak(2'b00),											// Input[1:0]: manual set as 2'b00
		.rx_parallel_data_B0(rx_parallel_data_B0),		// Input[15:0]: mimic the RX received parallel data
		.rx_parallel_data_B1(rx_parallel_data_B1),		// Input[15:0]: mimic the RX received parallel data		
		.rx_parallel_data_B2(rx_parallel_data_B2),		// Input[15:0]: mimic the RX received parallel data		
		.rx_parallel_data_B3(rx_parallel_data_B3),		// Input[15:0]: mimic the RX received parallel data		
		.rx_parallel_data_B4(rx_parallel_data_B4),		// Input[15:0]: mimic the RX received parallel data		
		.rx_parallel_data_B5(rx_parallel_data_B5),		// Input[15:0]: mimic the RX received parallel data		
		.rx_parallel_data_B6(rx_parallel_data_B6),		// Input[15:0]: mimic the RX received parallel data		
		.rx_parallel_data_B7(rx_parallel_data_B7),		// Input[15:0]: mimic the RX received parallel data	
	
		// DRAM interface
		.DRAM_Wait_Request(DRAM_Wait_Request),				// Input
		.DRAM_WR_address(DRAM_WR_address),					// Output[24:0]
		.DRAM_Write_Data(DRAM_Write_Data),					// Output[255:0]
		.DRAM_Write_Enable(DRAM_Write_Enable),				// Output
		.DRAM_Write_Burst_Count(DRAM_Write_Burst_Count),// Output[4:0]	
		.DRAM_Write_Burst_Begin(DRAM_Write_Burst_Begin)	// Output
		);


	// input data clock
	always begin
		#2 inclk <= ~inclk;
	end 
	
	// DRAM write in clock
	always begin 
		#4 outclk <= ~outclk;
	end
	
	// Generated RX data from transceivers
	reg [15:0] FIFO_rd_data;
	
	reg START; // start the generation process
	
	reg[2:0] state;
	reg[7:0] input_iteration;
	reg[7:0] packet_counter;
	reg [15:0] time_stamp;
	
	reg[19:0] gap_counter;
	
	parameter HEADER = 3'd0;
	parameter TIMESTAMP = 3'd1;
	parameter PACKET_PAYLOAD = 3'd2;
	parameter ENDER = 3'd3;
	parameter WAITING_GAP = 3'd4;
	
	always@(posedge inclk)
		if(!rst_n)
			begin
			FIFO_rd_data <= 16'h0000;
			input_iteration <= 8'd0;
			packet_counter <= 8'd0;
			gap_counter <= 20'd0;
			time_stamp <= 16'd10;
			
			state <= HEADER;
			end
		else if (START)
			begin
			case(state)
				HEADER:
					begin
					FIFO_rd_data <= 16'hDEAD;
					input_iteration <= input_iteration;
					packet_counter <= 8'd0;
					gap_counter <= 20'd0;
					time_stamp <= time_stamp;
					
					state <= TIMESTAMP;
					end
				TIMESTAMP:
					begin
					FIFO_rd_data <= time_stamp;
					input_iteration <= input_iteration;
					packet_counter <= 8'd0;
					gap_counter <= 20'd0;
					time_stamp <= time_stamp + 1'b1;
					
					state <= PACKET_PAYLOAD;
					end
				PACKET_PAYLOAD:
					begin
					FIFO_rd_data <= {input_iteration, packet_counter};
					input_iteration <= input_iteration;
					packet_counter <= packet_counter + 1'b1;
					gap_counter <= 20'd0;
					time_stamp <= time_stamp;
					if(packet_counter < 8'd124)
						state <= PACKET_PAYLOAD;
					else
						state <= ENDER;
					end
				ENDER:
					begin
					FIFO_rd_data <= 16'hBEEF;
					input_iteration <= input_iteration + 1'b1;
					packet_counter <= 8'd0;
					gap_counter <= 20'd0;
					time_stamp <= time_stamp;
					state <= WAITING_GAP;
					end
				WAITING_GAP:
					begin
					FIFO_rd_data <= 16'h0000;
					input_iteration <= input_iteration;
					packet_counter <= 8'd0;
					gap_counter <= gap_counter + 1'b1;
					time_stamp <= time_stamp;
					if((input_iteration <= 16'h0F && gap_counter <= 20) || (input_iteration > 16'h0F && gap_counter <= 2000))		// generate a longer gap when the first set of data has filled the Reorder Buffer
						state <= WAITING_GAP;
					else
						state <= HEADER;
					end
				
			endcase
			end


	// Assign the input data
	always@(posedge inclk)
		begin
		rx_parallel_data_B0 <= FIFO_rd_data;
		rx_parallel_data_B1 <= FIFO_rd_data;
		rx_parallel_data_B2 <= FIFO_rd_data;
		rx_parallel_data_B3 <= FIFO_rd_data;
		rx_parallel_data_B4 <= FIFO_rd_data;
		rx_parallel_data_B5 <= FIFO_rd_data;
		rx_parallel_data_B6 <= FIFO_rd_data;
		rx_parallel_data_B7 <= FIFO_rd_data;
		end
			
	// Assign the DRAM wait request signal
	always@(posedge outclk)
		begin
		DRAM_Wait_Request <= ~DRAM_Write_Burst_Begin;
		end
	
	initial begin     
		
		inclk <= 1'b1;   
		outclk <= 1'b1;
		rst_n <= 1'b0;
		FIFO_rd_data <= 16'd0;
		
		START <= 1'b0;
		
		// Turn off Reset
		#12
		rst_n <= 1'b1;  

		#20
		START <= 1'b1;

		
		#32000
		$stop;
			
	end 

endmodule 