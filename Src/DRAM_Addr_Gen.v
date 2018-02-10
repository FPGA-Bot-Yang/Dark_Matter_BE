// Module connect to: DRAM controller, RX_buf_ctrl, Threshold_Global_Coordinator

// 1 FE packet = 128 * 16bit => 8 256bit DRAM words
// 8 FE packet sampled at the same time = 64 DRAM words
// Thus 6 LSB in address for in Sample Time Packet index
// 25bit DRAM address space, but actually this should be 24bit, divide into: 1 MSB = 0 | 2 bit iteration counter of time stamp | 16 bit sample time | 3 bit board # index | 3 bit in FE pack index
// 2 bit iteration counter of time stamp | 16 bit sample time will form the index to address dram address mask, dram addr mask size is 2^18
// 4 BRAM modules stores the 2^18 bit address mask, write logic has not been implement yet

module DRAM_Addr_Gen(
	input					 clk,
	input 			    rst_n,
	
	// signal for address mask
	////////////////////////////////////////////////////////////////////////////
	// Potential Problem: Related logic for this one need to be implemented
	////////////////////////////////////////////////////////////////////////////
	input [15:0]       triggering_time_stamp, // input from Threshold_Global_Coordinator, signify the first tigger timestamp, valid only triggering_status=1
	input 			    triggering_status,	   // input from Threshold_Global_Coordinator
	
	// Signal to buffer
	input	 [7:0]	    BRAM_ready_mask,			// bit mask for those ready reorder buffers. Each connect to the Channel_Data_Reorder_Buffer module's BRAM_ready_mask pin
	input  [255:0]     BRAM_rd_data,				// The readin data from reorder buffer
	output reg [7:0]	 BRAM_rd_request,		   // bit mask for rd_request, each bit connect to Channel_Data_Reorder_Buffer module's BRAM_rd_request pin
	output [2:0]		 BRAM_Sel,					// output the arbitration results to select from 1 of the 8 reorder buffers

	// Signal to DRAM controller
	input              DRAM_Wait_Request,
	output reg         DRAM_Write_Enable,
	output reg         DRAM_Write_Burst_Begin,
	output reg [4:0]   DRAM_Write_Burst_Count,
	output     [24:0]  DRAM_Write_Addr,
	output reg [255:0] DRAM_Write_Data,
	
	// dummy output for address mask
	output reg		    MASK_output
);


	parameter ARBITRATION    = 2'b00;
	parameter READFIRSTDATA  = 2'b01;
	parameter DRAMWRITE      = 2'b10;
	parameter WAIT 			 = 2'b11;

	reg [1:0]  state;

	wire [3:0] board_sel;					// set as 4 bit so it can have extra value represents arbitration invalid(== 8)
	assign BRAM_Sel = board_sel[2:0];
	
	reg [6:0] channel_sel;
	reg [13:0] channel_offset;
	reg [13:0] prev_channel_offset [0:7];											// buffer the channel offset for each board, used for addressing when write data to DRAM
	
	// assign the channel_offset used for generating DRAM write address
	always@(posedge clk)
		begin
		if(!rst_n)
			channel_offset <= 14'd0;
		else
			channel_offset <= prev_channel_offset[BRAM_Sel];
		end
		
	assign DRAM_Write_Addr = {1'b0, BRAM_Sel, channel_sel, channel_offset};		// 0 MSB, 3 bit Board selection, 7 bit channel selection on each board, 14-bit channel offset based on sampling time
	
	wire       arbitor_enable;
	wire [7:0] arbitor;
	
	wire [4:0] MASK_dummy_output;
	
				
	reg [7:0] DRAM_Write_Counter;
	wire DDR_trans_done;
	
	assign DDR_trans_done = (DRAM_Write_Counter == 8'd124)?1:0;

	reg [2:0] waiting_counter;			// counter used for generating waiting cycles

	
	Arbitor Arbitor(
		.clk(clk),
		.rst_n(rst_n),
		.enable(arbitor_enable),
		.input_mask(BRAM_ready_mask),
		.output_mask(arbitor),
		.board_sel(board_sel)
	);
	
	// enable arbitration only when state is ARBITRATION and the previous arbitration is a failure
	// take this out of the statement machine: if in the state machine, there will be an extra cycle delay when deasserting the enable signal as the arbitor also take one cycle to generate result
	assign arbitor_enable = (state == ARBITRATION) ? 1'b1 : 1'b0;
	
	always@(posedge clk)
		if(!rst_n)
			begin
			BRAM_rd_request <= 8'd0;
			
			DRAM_Write_Enable <= 1'b0;
			DRAM_Write_Burst_Begin <= 1'b0;
			DRAM_Write_Burst_Count <= 5'd0;
			DRAM_Write_Data <= 256'd0;
			DRAM_Write_Counter <= 8'd0;

			// signals for generating DRAM writing address
			channel_sel <= 7'd0;
			prev_channel_offset[0] <= 14'd0;
			prev_channel_offset[1] <= 14'd0;
			prev_channel_offset[2] <= 14'd0;
			prev_channel_offset[3] <= 14'd0;
			prev_channel_offset[4] <= 14'd0;
			prev_channel_offset[5] <= 14'd0;
			prev_channel_offset[6] <= 14'd0;
			prev_channel_offset[7] <= 14'd0;
			
			waiting_counter <= 3'd0;				// counter used for generating waiting cycles
			
			state <= ARBITRATION;
			end
		else
			begin
	      case(state)
				ARBITRATION:
					begin
					DRAM_Write_Enable <= 1'b0;
					DRAM_Write_Burst_Begin <= 1'b0;
					DRAM_Write_Burst_Count <= 5'd0;
					DRAM_Write_Data <= 256'd0;
					DRAM_Write_Counter <= 8'd0;

					channel_sel <= 7'd0;
					
					waiting_counter <= 3'd0;				// counter used for generating waiting cycles
					
					if(board_sel == 4'd8)				// If arbitration gives no results
						begin
						BRAM_rd_request <= 8'd0;
						
						state <= ARBITRATION;
						end
					else
						begin
						BRAM_rd_request <= arbitor;		// send out the request to reoder buffer one cycle early to make sure the data arrive in time
						
						state <= READFIRSTDATA;
						end
						
					end
	/////////////////PROMBLEMMMMMMMMMMMMMMMMMMMMMM delay between BRAM_rd_request triggered to data come. different from fifo, may need some register to delay DRAM related signals to wait data. MUX in top also need delay
				READFIRSTDATA:
					begin
					channel_sel <= 7'd0;		// start from 0 for channel addressing
					
					waiting_counter <= 3'd0;				// counter used for generating waiting cycles
					
					if(DRAM_Wait_Request) 				// If DRAM is ready, then readout one data from BRAM
						begin
						BRAM_rd_request <= arbitor;		// read one data from BRAM
						
						DRAM_Write_Enable <= 1'b1;
						DRAM_Write_Burst_Begin <= 1'b1;
						DRAM_Write_Burst_Count <= 5'd1;
						DRAM_Write_Data <= BRAM_rd_data;
						DRAM_Write_Counter <= DRAM_Write_Counter + 1'd1;

						state <= DRAMWRITE;
						end
					else
						begin
						BRAM_rd_request <= 8'd0;		// do not read data from BRAM if DRAM not ready to write
						
						DRAM_Write_Enable <= 1'b0;
						DRAM_Write_Burst_Begin <= 1'b0;
						DRAM_Write_Burst_Count <= 5'd0;
						DRAM_Write_Data <= BRAM_rd_data;
						DRAM_Write_Counter <= DRAM_Write_Counter;

						state <= READFIRSTDATA;
						end
					end
					
				DRAMWRITE:
					begin
					waiting_counter <= 3'd0;				// counter used for generating waiting cycles
					
					if(DRAM_Wait_Request) 				// If DRAM is ready, then readout one data from BRAM
						begin
						BRAM_rd_request <= arbitor;		// read one data from BRAM
						
						DRAM_Write_Enable <= 1'b1;
						DRAM_Write_Burst_Begin <= 1'b1;
						DRAM_Write_Burst_Count <= 5'd1;
						DRAM_Write_Data <= BRAM_rd_data;
						DRAM_Write_Counter <= DRAM_Write_Counter + 1'd1;
						
						channel_sel <= channel_sel + 1'b1;
						end
					else
						begin
						BRAM_rd_request <= 8'd0;		// do not read data from BRAM if DRAM not ready to write
						
						DRAM_Write_Enable <= 1'b0;
						DRAM_Write_Burst_Begin <= 1'b0;
						DRAM_Write_Burst_Count <= 5'd0;
						DRAM_Write_Data <= BRAM_rd_data;
						DRAM_Write_Counter <= DRAM_Write_Counter;
	
						channel_sel <= channel_sel;
						end
						
					if((DDR_trans_done == 1)&&(DRAM_Wait_Request == 1))
						begin
						//////////////////////////////////////////////////////////////////////////////////////////////
						// ???????????????????????????????????????????????????????????????????????????????????????????
						// increment the channel offset for next interation when this round of writing is finish
						// if considering replacement, need to add more logic here, more than just increment by 1
						//////////////////////////////////////////////////////////////////////////////////////////////
						prev_channel_offset[BRAM_Sel] <= prev_channel_offset[BRAM_Sel] + 1'b1;
						
						state <= WAIT;
						end
					else
						begin
						prev_channel_offset[BRAM_Sel] <= prev_channel_offset[BRAM_Sel];
						
						state <= DRAMWRITE;
						end
					end
				
				// Wait several cycles to let the reorder buffer clear the status signal before performing the next arbitration
				WAIT:
					begin
					DRAM_Write_Enable <= 1'b0;
					DRAM_Write_Burst_Begin <= 1'b0;
					DRAM_Write_Burst_Count <= 5'd0;
					DRAM_Write_Data <= 256'd0;
					DRAM_Write_Counter <= 8'd0;

					channel_sel <= 7'd0;
					
					BRAM_rd_request <= 8'd0;
				
					waiting_counter <= waiting_counter + 1'b1;				// counter used for generating waiting cycles
					if(waiting_counter > 2)
						state <= ARBITRATION;
					else
						state <= WAIT;
						
					end
					
			endcase
			end


endmodule