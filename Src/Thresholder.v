////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Thresholder based on input amplitude
// Function:
//		Examine the input data and compare with the preset threshold for each channel
//		Read directly from the MGT RX port, but first detect the packet header and record the timestamp for the current packet
//		One thresholder module for each RX port, a Global coordinator module that handles triggering signals from 8 threholders
//
//	Output Definition:
//		set_global_trigger: if one data is triggered, it will set, but the next cycle is may fall back to 0
//		time_stamp: signify the timestamp for the current data that being checked, will remain the same for data from the same FE packets
//
// By: Chen Yang, Jack Abernathy
// Rev0: 05/01/2017
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


module Thresholder(
	input 				rx_std_clkout,								// clk signal for RX data receiving
	input 				rst_n,										// reset signal, reset on low
	input [1:0]			rx_syncstatus,								// syncstatus connect to transceiver IP
	input	[1:0]			rx_datak,									// signify the control word or data word
	input [15:0]		RX_data,										// data received on RX
	
	// Output signal to address generator
	input					Global_trigger_flag,						// May not be useful
	output reg			set_global_trigger,
	output reg [15:0] time_stamp
);


	parameter WAIT_FOR_START =	2'b00;
	parameter GET_TIME_STAMP =	2'b01;
	parameter CHECKING		 = 2'b10;
	
	reg [1:0] State;
	//reg [11:0] Threshold [0:124];			// Recording the threshold value for the 125 channels
	reg [6:0] in_packet_counter;
	wire [11:0] Threshold;

	/* Threshold Controller Registers */
	reg 	[6:0]		tAddr;	/* Address for threshold ROM, controlled by clocked logic */
	reg 	[1:0] 	tState; 	/* State variable to calculate inAddr for threshold ROM */
	
	/* Threshold Controller States */
	localparam COUNT = 2'd1;
	
	
	Threshold_MEM_0 Threshold_MEM_inst(
		.address(tAddr),
		.clock(rx_std_clkout),
		.q(Threshold)
	);
	
	
	/*********************************************************
	 * Control Logic to handle ROM read delay 
	 *********************************************************/
	always @ (posedge rx_std_clkout) begin
		if (!rst_n) begin 
			tAddr <= 7'd0;
			tState <= WAIT_FOR_START;
		end 
		else begin 
			case (tState) 
				WAIT_FOR_START: begin 
					if (RX_data == 16'hDEAD) begin 
						tState <= COUNT;
						tAddr <= 7'd1;
					end 
					else begin 
						tState <= WAIT_FOR_START;
						tAddr <= 7'd0;
					end 
				end 
				
				COUNT: begin 
					if (tAddr <= 7'd124) begin 
						tState <= COUNT;
						tAddr <= tAddr + 7'd1;
					end 
					else begin 
						tState <= WAIT_FOR_START;
						tAddr <= 7'd0;
					end 
				end 
				
				default: begin 
					tState <= WAIT_FOR_START;
					tAddr <= 7'd0;
				end 

			endcase 
		end 
	end 
	
	
	always@(posedge rx_std_clkout)
		begin
		if(!rst_n)
			begin
			set_global_trigger <= 1'b0;
			time_stamp <= 16'd0;
			in_packet_counter <= 7'd0;
			// FSM ctrl
			State <= 2'b00;
			end
		else if(rx_syncstatus == 2'b11 & rx_datak == 2'b00)	// Only start to check when transceiver channel is sync and the incoming data is data word
			begin
			case(State)
				WAIT_FOR_START:					// Wait for arrival of the data packet
					begin
					set_global_trigger <= 1'b0;
					time_stamp <= time_stamp;		// maintain the old time_stamp value to stop the coincidence that time_stamp = 0 is the end of the triggering window
					in_packet_counter <= 7'd0;
					if(RX_data == 16'hDEAD)			// Wait for the start of the packet, previously 16'hFFFF, now 16'hDEAD to reflect new start word 
						State <= GET_TIME_STAMP;
					else
						State <= WAIT_FOR_START;
					end
				
				GET_TIME_STAMP:					// Fetch the time stamp from the second word in the packet
					begin
					set_global_trigger <= 1'b0;
					time_stamp <= RX_data;
					in_packet_counter <= 7'd0;
					State <= CHECKING;
					end
				
				CHECKING:							// Thresholding
					begin	
					time_stamp <= time_stamp;
					in_packet_counter = in_packet_counter + 1'b1;
					// Thresholding
					//if(RX_data[11:0] > Threshold[in_packet_counter])
					if(RX_data[11:0] > Threshold) 
						begin
						set_global_trigger <= 1'b1;
						end
					else
						begin
						set_global_trigger <= 1'b0;
						end
						
					// Checking if 125 data payload have been checked
					if(in_packet_counter < 125)
						State <= CHECKING;
					else
						State <= WAIT_FOR_START;
					
					end
			endcase
			end
		
		end
	

	
endmodule