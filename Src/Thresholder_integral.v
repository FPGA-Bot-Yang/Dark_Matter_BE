module Thresholder_integral(
	input 				rx_std_clkout,								// clk signal for RX data receiving
	input 				rst_n,										// reset signal, reset on low
	input [1:0]			rx_syncstatus,								// syncstatus connect to transceiver IP
	input	[1:0]			rx_datak,									// signify the control word or data word
	input [15:0]		RX_data,										// data received on RX
	
	// Output signal to address generator
	input					Global_trigger_flag,						// May not be useful
	output				set_global_trigger,
	output reg [15:0] time_stamp
);


	parameter WAIT_FOR_START =	2'b00;
	parameter GET_TIME_STAMP =	2'b01;
	parameter CHECKING		 = 2'b10;
	
	integer i;
	
	reg [1:0] State;
	//reg [11:0] Threshold [0:124];			// Recording the threshold value for the 125 channels
	reg [6:0] in_packet_counter;
	wire [11:0] Threshold;
	reg Threshold_read_en;

	// Decision making
	integral_comparator integral_comparator(
		.clk(rx_std_clkout),
		.rst_n(rst_n),
		.enable(Threshold_read_en),				// Write history data ram only when this signal is set
		.new_data(RX_data[11:0]),			// the new incoming data
		.rd_addr(in_packet_counter),				// index for finding the threshold and history data
		.decision(set_global_trigger)				// Threshold decision output
	);
	
	
	always@(posedge rx_std_clkout)
		begin
		if(!rst_n)
			begin
			time_stamp <= 16'd0;
			in_packet_counter <= 7'd0;
			Threshold_read_en <= 1'b0;
			// FSM ctrl
			State <= 2'b00;
			end
		else if(rx_syncstatus == 2'b11 & rx_datak == 2'b00)	// Only start to check when transceiver channel is sync and the incoming data is data word
			begin
			case(State)
				WAIT_FOR_START:					// Wait for arrival of the data packet
					begin
					time_stamp <= 16'd0;
					in_packet_counter <= 7'd0;
					Threshold_read_en <= 1'b0;
					if(RX_data == 16'hFFFF)					// Wait for the start of the packet
						State <= GET_TIME_STAMP;
					else
						State <= WAIT_FOR_START;
					end
				
				GET_TIME_STAMP:					// Fetch the time stamp from the second word in the packet
					begin
					time_stamp <= RX_data;
					in_packet_counter <= 7'd0;
					Threshold_read_en <= 1'b0;
					State <= CHECKING;
					end
				
				CHECKING:							// Thresholding
					begin	
					time_stamp <= time_stamp;
					in_packet_counter = in_packet_counter + 1'b1;
					// Enable pipeline to make decision
					Threshold_read_en <= 1'b1;
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