////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Thresholder coordinator, used to sync the triggering signal from 8 thresholders
// Function:
//		Originally the 8 thresholders just output high when they find the value is larger than threshold, and set back to 0 if the next data is back to below tresholder
//		The fucntion of this module: whichever trigger sets first, will use that time as the starting trigger time. And last the trigger timespan over the triggering window length
//		Once entered the triggering mode, it will stay for post_trigger_window time based on the triggering channels timestamp, during the process, it won't check again
//		Glitch 1:Suppose to use clock from each one of the RX modules directly, but currently just use clk from RX0 for ease of design
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

module Threshold_Global_Coordinator(
	input clk,
	input rst_n,
	
	input [15:0] B0_time_stamp,
	input B0_decision,
	input [15:0] B1_time_stamp,
	input B1_decision,
	input [15:0] B2_time_stamp,
	input B2_decision,
	input [15:0] B3_time_stamp,
	input B3_decision,
	input [15:0] B4_time_stamp,
	input B4_decision,
	input [15:0] B5_time_stamp,
	input B5_decision,
	input [15:0] B6_time_stamp,
	input B6_decision,
	input [15:0] B7_time_stamp,
	input B7_decision,

	output reg [15:0] triggering_time_stamp,			// Outputing the first detected triggering time point, the receving module should based on this to calculate the starting and ending point
																	// This signal will cross clock domain
	output reg threshold_decision_to_DRAM_ctrl		// This signal will keep high from the first triggering point till it reaches ending triggering point
																	// on the receiving side, it should keep on checking this signal and compare with the triggering time stamp, there will be a falling edge each time one triggering event is finish
																	// This signal will cross clock domain
);
	integer ii;
	parameter WAIT_FOR_START =	2'b00;
	parameter TRIGGER_ACTIVE =	2'b01;
	parameter WAIT_FOR_END	 = 2'b10;
	parameter POST_TRIGGER_ENDING = 16'd15000;
	parameter PRE_TRIGGER_ENDING = 16'd5000;
	
	reg [1:0] State;	
	reg [7:0] Status_Mask;

	/* Trigger Recording Logic */
	//reg [15:0] triggering_time_stamp;
	reg [2:0]  triggering_channel_id;
	reg [1:0]  trigger_iter;
	reg [15:0] current_time_stamp;
	reg [1:0]  curIter [0:7];								// use to record how many times the timestamp loop throught 0x0000 to 0xFFFF
	reg [15:0] prevTS [0:7];
	reg [15:0] pre_trigger_starts;	
	wire[15:0] post_trigger_ending;	
	wire [1:0] end_iter;
	wire 		  overflow;				/* Overflow bit end timestamp calculation */
	
	
	
	/* Logic to track iteration count
	 * Synchronization for this is not essential 
	*/
	// use to record how many times the timestamp loop throught 0x0000 to 0xFFFF
	always @ (posedge clk) begin 
		if (!rst_n) begin 
			for (ii = 0; ii < 8; ii = ii + 1) 
				curIter[ii] <= 2'd0;
		end 
		else begin  
			curIter[0] <= (B0_time_stamp == 16'hFFFF && B0_time_stamp != prevTS[0]) ? curIter[0] + 2'd1 : curIter[0];
			curIter[1] <= (B1_time_stamp == 16'hFFFF && B1_time_stamp != prevTS[1]) ? curIter[1] + 2'd1 : curIter[1];
			curIter[2] <= (B2_time_stamp == 16'hFFFF && B2_time_stamp != prevTS[2]) ? curIter[2] + 2'd1 : curIter[2];
			curIter[3] <= (B3_time_stamp == 16'hFFFF && B3_time_stamp != prevTS[3]) ? curIter[3] + 2'd1 : curIter[3];
			curIter[4] <= (B4_time_stamp == 16'hFFFF && B4_time_stamp != prevTS[4]) ? curIter[4] + 2'd1 : curIter[4];
			curIter[5] <= (B5_time_stamp == 16'hFFFF && B5_time_stamp != prevTS[5]) ? curIter[5] + 2'd1 : curIter[5];
			curIter[6] <= (B6_time_stamp == 16'hFFFF && B6_time_stamp != prevTS[6]) ? curIter[6] + 2'd1 : curIter[6];
			curIter[7] <= (B7_time_stamp == 16'hFFFF && B7_time_stamp != prevTS[7]) ? curIter[7] + 2'd1 : curIter[7];			
			
			/* Save previous timestamp to only increment count once */
			prevTS[0] <= B0_time_stamp;
			prevTS[1] <= B1_time_stamp;
			prevTS[2] <= B2_time_stamp;
			prevTS[3] <= B3_time_stamp;
			prevTS[4] <= B4_time_stamp;
			prevTS[5] <= B5_time_stamp;
			prevTS[6] <= B6_time_stamp;
			prevTS[7] <= B7_time_stamp;
		end 
	end 
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// FIXED!!!!!!!!!!!!!!!!!!!!!!!
	//	Potential Problem:
	// The time stamp is too short: 16 bit only range from 0~65535, need an extra counter of method to record real time
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	assign {overflow, post_trigger_ending} = triggering_time_stamp + POST_TRIGGER_ENDING;		// 15ms of post-trigger data at 1Mhz
	assign end_iter = trigger_iter + overflow;
	
	always@(posedge clk)
		begin
			if(!rst_n)
				begin
				Status_Mask <= 8'd0;
				threshold_decision_to_DRAM_ctrl <= 1'b0;
				triggering_time_stamp <= 16'd0;
				triggering_channel_id <= 3'd0;
				current_time_stamp <= 16'd0;
				State <= WAIT_FOR_START;
				end
			else
				begin
				// Collect the triggering status from 8 tiggers
				Status_Mask[0] <= B0_decision;
				Status_Mask[1] <= B1_decision;
				Status_Mask[2] <= B2_decision;
				Status_Mask[3] <= B3_decision;
				Status_Mask[4] <= B4_decision;
				Status_Mask[5] <= B5_decision;
				Status_Mask[6] <= B6_decision;
				Status_Mask[7] <= B7_decision;
				
				case(State)
					// Wait for the first tiggering event from one of the 8 tiggers
					WAIT_FOR_START:
						begin
						if(Status_Mask == 8'd0)
							begin
							State <= WAIT_FOR_START;
							threshold_decision_to_DRAM_ctrl <= 1'b0;
							triggering_time_stamp <= 16'd0;
							current_time_stamp <= 16'd0;
							triggering_channel_id <= 3'd0;
							end
						else
							//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
							// Potential Problem:
							// If 2 triggers are testing data sampled from different cycle, say T1 detecting samples from time=10, while T2 detecting from time=9,
							// then if T1 tiggers first while T2 tiggers later, then the marked first triggering time will be time=10.
							// But this suppose to be fine as 1 or 2 cycles of shift should be fine. There shouldn't be cycle mismatch for more than 1 cycle.
							//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
							begin
							State <= TRIGGER_ACTIVE;
							threshold_decision_to_DRAM_ctrl <= 1'b1;
							current_time_stamp <= 16'd0;
							// Find the triggering stamp by finding the right most 1 bit in mask
							////////////////////////////////////////////////////////////////////////////////////
							// FIXED!!!!!!!!!!!!!!!!!!!!!!!!!!!!
							// Potential Problem: inefficiency?
							//	Can the comparision be finished in 1 cycle??????? Simulate this and verify
							////////////////////////////////////////////////////////////////////////////////////
							if(Status_Mask[0]) begin triggering_time_stamp <= B0_time_stamp; triggering_channel_id <= 3'd0; end
							else if(Status_Mask[1]) begin triggering_time_stamp <= B1_time_stamp; triggering_channel_id <= 3'd1; end
							else if(Status_Mask[2]) begin triggering_time_stamp <= B2_time_stamp; triggering_channel_id <= 3'd2; end
							else if(Status_Mask[3]) begin triggering_time_stamp <= B3_time_stamp; triggering_channel_id <= 3'd3; end
							else if(Status_Mask[4]) begin triggering_time_stamp <= B4_time_stamp; triggering_channel_id <= 3'd4; end
							else if(Status_Mask[5]) begin triggering_time_stamp <= B5_time_stamp; triggering_channel_id <= 3'd5; end
							else if(Status_Mask[6]) begin triggering_time_stamp <= B6_time_stamp; triggering_channel_id <= 3'd6; end
							else begin triggering_time_stamp <= B7_time_stamp; triggering_channel_id <= 3'd7; end
							end
						end
					
					
					///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
					// Better Solution?
					// When first triggered, send that timestamp to the DRAM controller so the DRAM mask can be directly updated.
					// The start and ending time will be calculated in the DRAM controller. Thus all the data will be mapped&locked automatically on the DRAM side.
					///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
					TRIGGER_ACTIVE:
						begin
						case(triggering_channel_id)
							0: begin current_time_stamp <= B0_time_stamp; trigger_iter <= curIter[0]; end 
							1: begin current_time_stamp <= B1_time_stamp; trigger_iter <= curIter[1]; end 
							2: begin current_time_stamp <= B2_time_stamp; trigger_iter <= curIter[2]; end 
							3: begin current_time_stamp <= B3_time_stamp; trigger_iter <= curIter[3]; end 
							4: begin current_time_stamp <= B4_time_stamp; trigger_iter <= curIter[4]; end 
							5: begin current_time_stamp <= B5_time_stamp; trigger_iter <= curIter[5]; end 
							6: begin current_time_stamp <= B6_time_stamp; trigger_iter <= curIter[6]; end 
							7: begin current_time_stamp <= B7_time_stamp; trigger_iter <= curIter[7]; end 
						endcase
						
						////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
						// Potential Problem:
						// The time stamp is too short: 16 bit only range from 0~65535, need an extra counter of method to record real time
						////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
						if(current_time_stamp == post_trigger_ending && trigger_iter == end_iter)		// deal with the overflow on timestamp
							begin
							State <= WAIT_FOR_START;
							threshold_decision_to_DRAM_ctrl <= 1'b0;
							triggering_time_stamp <= 16'd0;
							triggering_channel_id <= 3'd0;
							end
						else
							begin
							State <= TRIGGER_ACTIVE;
							threshold_decision_to_DRAM_ctrl <= 1'b1;
							triggering_time_stamp <= triggering_time_stamp;
							triggering_channel_id <= triggering_channel_id;
							end
						
						end
				
				
				endcase
				end
		end
	
	
	endmodule