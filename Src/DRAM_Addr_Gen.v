///////////////////////////////////////////////////////////////////////////////////////////////////////
// DRAM Write Controller:
//		Perform arbitration based on the Reorder Buffer(RB) status and select from one of the 8 ready RB
//		Read data from selected RB and write to related DRAM address
//		Need to do: Replacement scheme
// By: Chen Yang
// Update: 02/12/2018
//
// Module connect to: DRAM controller, Channel_Data_Reorder_Buffer, Threshold_Global_Coordinator
//
// Data in RB is organized based on sampled channels, each RB contains data from 125 channels
// Each readout data from RB consists of 16 data samples from a single channel
// DRAM address space is 25 bit: {1'b0, BRAM_Sel, channel_sel, in_channel_offset} 0 MSB, 3 bit Board selection, 7 bit channel selection on each board, 14-bit channel offset based on sampling time
//	When data coming in from RB, the fist data is always timestamp, the timestamp is also written into the DRAM, with the address being: {1'b0, 3'BRAM_Sel, 7'd0, in_channel_offset}
// When performing replacement, only consider the first data's sampling time in a single DRAM word
///////////////////////////////////////////////////////////////////////////////////////////////////////

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
	output reg [24:0]  DRAM_Write_Addr,			//{1'b0, BRAM_Sel, channel_sel, in_channel_offset} 0 MSB, 3 bit Board selection, 7 bit channel selection on each board, 14-bit channel offset based on sampling time
	output reg [255:0] DRAM_Write_Data,
	
	// dummy output for address mask
	output reg		    MASK_output
);


	parameter ARBITRATION     = 3'b000;
	parameter READFIRSTDATA   = 3'b001;
	parameter DRAMWRITE       = 3'b010;
	parameter WAIT 			  = 3'b011;

	reg [2:0]  state;

	wire [3:0] board_sel;					// set as 4 bit so it can have extra value represents arbitration invalid(== 8)
	assign BRAM_Sel = board_sel[2:0];
	
	reg [6:0] channel_sel;
	reg [13:0] in_channel_offset;
	reg [13:0] prev_in_channel_offset [0:7];											// buffer the channel offset for each board, used for addressing when write data to DRAM
	
	// assign the in_channel_offset used for generating DRAM write address
	always@(posedge clk)
		begin
		if(!rst_n)
			in_channel_offset <= 14'd0;
		else
			in_channel_offset <= prev_in_channel_offset[BRAM_Sel];
		end
		
	//assign DRAM_Write_Addr = {1'b0, BRAM_Sel, channel_sel, in_channel_offset};		// 0 MSB, 3 bit Board selection, 7 bit channel selection on each board, 14-bit channel offset based on sampling time
	
	wire       arbitor_enable;
	wire [7:0] arbitor;
	
	wire [4:0] MASK_dummy_output;
	
				
	reg [7:0] DRAM_Write_Counter;
	wire DDR_trans_done;
	
	assign DDR_trans_done = (DRAM_Write_Counter == 8'd124)? 1'b1: 1'b0;

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
			DRAM_Write_Counter <= 8'd0;

			// signals for generating DRAM writing address
			channel_sel <= 7'd0;
			prev_in_channel_offset[0] <= 14'd0;
			prev_in_channel_offset[1] <= 14'd0;
			prev_in_channel_offset[2] <= 14'd0;
			prev_in_channel_offset[3] <= 14'd0;
			prev_in_channel_offset[4] <= 14'd0;
			prev_in_channel_offset[5] <= 14'd0;
			prev_in_channel_offset[6] <= 14'd0;
			prev_in_channel_offset[7] <= 14'd0;
			
			waiting_counter <= 3'd0;				// counter used for generating waiting cycles
			
			state <= ARBITRATION;
			end
		else
			begin
	      case(state)
				ARBITRATION:
					begin
					DRAM_Write_Counter <= 8'd0;
					channel_sel <= 7'd0;
					waiting_counter <= 3'd0;				// counter used for generating waiting cycles
					
					//if(board_sel == 4'd8)				// If arbitration gives no results
					if(BRAM_ready_mask == 8'd0)			// If there's no reorder buffer is ready
						begin
						state <= ARBITRATION;
						end
					else											// When there's at least one reorder buffer is ready, then the arbitor will make a selection and move on
						begin
						state <= READFIRSTDATA;
						end
						
					end
				
				// There's one cycle delay for arbitor generating arbitration results
				// At this point, the arbitration result is generated, assign the read request signal to the selected Reorder Buffer
				// There's also one cycle delay for fetching data from reorder buffer
				// At the end of this state, the data has been pre-fetched from Reorder Buffer
				READFIRSTDATA:
					begin
					// Do not write anything to DRAM
					DRAM_Write_Counter <= 8'd0;
					channel_sel <= 7'd0;
					waiting_counter <= 3'd0;				// counter used for generating waiting cycles

					state <= DRAMWRITE;
					end
				
				DRAMWRITE:
					begin
					waiting_counter <= 3'd0;				// counter used for generating waiting cycles
					
					if(DRAM_Wait_Request) 					// If DRAM is ready, then readout one data from BRAM
						begin
						DRAM_Write_Counter <= DRAM_Write_Counter + 1'd1;
						channel_sel <= channel_sel + 1'b1;
						end
					else
						begin
						DRAM_Write_Counter <= DRAM_Write_Counter;
						channel_sel <= channel_sel;
						end
						
					if((DDR_trans_done == 1'b1)&&(DRAM_Wait_Request == 1'b1))
						begin
						//////////////////////////////////////////////////////////////////////////////////////////////
						// ???????????????????????????????????????????????????????????????????????????????????????????
						// increment the channel offset for next interation when this round of writing is finish
						// if considering replacement, need to add more logic here, more than just increment by 1
						//////////////////////////////////////////////////////////////////////////////////////////////
						prev_in_channel_offset[BRAM_Sel] <= prev_in_channel_offset[BRAM_Sel] + 1'b1;
						
						state <= WAIT;
						end
					else
						begin
						prev_in_channel_offset[BRAM_Sel] <= prev_in_channel_offset[BRAM_Sel];
						
						state <= DRAMWRITE;
						end
					end
				
				// Wait several cycles to let the reorder buffer clear the status signal before performing the next arbitration
				WAIT:
					begin
					DRAM_Write_Counter <= 8'd0;
					channel_sel <= 7'd0;
					waiting_counter <= waiting_counter + 1'b1;				// counter used for generating waiting cycles
					if(waiting_counter > 2)
						state <= ARBITRATION;
					else
						state <= WAIT;
					end

			endcase
			end

	// Assign the DRAM control signal based on the status of the FSM
	always@(*)
		begin
		if(!rst_n)
			begin
			BRAM_rd_request <= 8'd0;
			
			DRAM_Write_Enable <= 1'b0;
			DRAM_Write_Burst_Begin <= 1'b0;
			DRAM_Write_Burst_Count <= 5'd0;
			DRAM_Write_Addr <= 25'd0;
			DRAM_Write_Data <= 256'd0;
			end
		else
			begin
			case(state)
			ARBITRATION:
				begin
				BRAM_rd_request <= 8'd0;
				
				DRAM_Write_Enable <= 1'b0;
				DRAM_Write_Burst_Begin <= 1'b0;
				DRAM_Write_Burst_Count <= 5'd0;
				DRAM_Write_Addr <= 25'd0;
				DRAM_Write_Data <= 256'd0;
				end
			READFIRSTDATA:
				begin
				// at this point, arbitration result is generated, thus send out the read request to the selected Reorder Buffer and prefetch the data 
				BRAM_rd_request <= arbitor;
				
				DRAM_Write_Enable <= 1'b0;
				DRAM_Write_Burst_Begin <= 1'b0;
				DRAM_Write_Burst_Count <= 5'd0;
				DRAM_Write_Addr <= 25'd0;
				DRAM_Write_Data <= 256'd0;
				end
			DRAMWRITE:
				begin
				if(DRAM_Wait_Request)
					begin
					// read the next data from BRAM
					// While the previously fetched data from Reorder Buffer is written into DRAM
					BRAM_rd_request <= arbitor;	
					
					DRAM_Write_Enable <= 1'b1;
					DRAM_Write_Burst_Begin <= 1'b1;
					DRAM_Write_Burst_Count <= 5'd1;
					DRAM_Write_Addr = {1'b0, BRAM_Sel, channel_sel, in_channel_offset};
					DRAM_Write_Data <= BRAM_rd_data;
					end
				else
					begin
					// do not read data from Reorder Buffer if DRAM not ready to write
					BRAM_rd_request <= 8'd0;
					
					DRAM_Write_Enable <= 1'b0;
					DRAM_Write_Burst_Begin <= 1'b0;
					DRAM_Write_Burst_Count <= 5'd0;
					DRAM_Write_Addr <= 25'd0;
					DRAM_Write_Data <= 256'd0;
					end
				end
			WAIT:
				begin
				BRAM_rd_request <= 8'd0;
				
				DRAM_Write_Enable <= 1'b0;
				DRAM_Write_Burst_Begin <= 1'b0;
				DRAM_Write_Burst_Count <= 5'd0;
				DRAM_Write_Addr <= 25'd0;
				DRAM_Write_Data <= 256'd0;
				end
			
			endcase
			end
		
		end

endmodule