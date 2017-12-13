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

	output reg [15:0] triggering_time_stamp,			// This signal will cross clock domain
	output reg threshold_decision_to_DRAM_ctrl		// This signal will cross clock domain
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
	reg [1:0]  curIter [0:7];
	reg [15:0] prevTS [0:7];
	reg [15:0] pre_trigger_starts;	
	wire[15:0] post_trigger_ending;	
	wire [1:0] end_iter;
	wire 		  overflow;				/* Overflow bit end timestamp calculation */
	
	
	
	/* Logic to track iteration count
	 * Synchronization for this is not essential 

	*/
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
	// Potential Problem:
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
						if(current_time_stamp == post_trigger_ending && trigger_iter == end_iter)
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