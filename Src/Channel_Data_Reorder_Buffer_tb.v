///////////////////////////////////////////////////////////////////////////////////////////////////////
// Testbench evaluate the Channel_Data_Reorder_Buffer
// By: Tong Geng
// Modified by: Chen Yang (Normalize the generation of RX packets with gaps in between)
// 12/11/2017
///////////////////////////////////////////////////////////////////////////////////////////////////////


`timescale 1ns/1ns

module Channel_Data_Reorder_Buffer_tb;
	reg inclk; 
	reg outclk;								
	reg rst_n;	
	reg FIFO_ready_mask;								
	reg [15:0]     FIFO_rd_data;  
	wire FIFO_rd_request;	  
	wire BRAM_ready_mask;
	wire [255:0] DRAM_wr_data;					
	reg BRAM_rd_request;									

	/* Loop Variables */
	reg [255:0] ii;

	
	Channel_Data_Reorder_Buffer UUT(
		.inclk(inclk),										// input
		.outclk(outclk),									// input
		.rst_n(rst_n),										// input
		
		// Signal to buffer
		.FIFO_ready_mask(FIFO_ready_mask),			// input, bit mask for those ready FIFOs. Each connect to the RX_buf_ctrl module's Buffer_Data_Ready pin
		.FIFO_rd_data(FIFO_rd_data),					// input
		.FIFO_rd_request(FIFO_rd_request),		   // output, bit mask for rd_request, each bit connect to RX_buf_ctrl module's DRAM_RD_req pin

		// Signal to DRAM user controller
		.BRAM_ready_mask(BRAM_ready_mask),			// output, bit mask for those ready FIFOs. Each connect to the RX_buf_ctrl module's Buffer_Data_Ready pin
		.DRAM_wr_data(DRAM_wr_data),					// output
		.BRAM_rd_request(BRAM_rd_request)		   // input, bit mask for rd_request, each bit connect to RX_buf_ctrl module's DRAM_RD_req pin
	);

	always begin
		#2 inclk <= ~inclk;
	end 
	
	always begin 
		#4 outclk <= ~outclk;
	end      

	reg[2:0] state;
	reg[7:0] input_iteration;
	reg[7:0] packet_counter;
	
	parameter HEADER = 3'd0;
	parameter TIMESTAMP = 3'd1;
	parameter PACKET_PAYLOAD = 3'd2;
	parameter ENDER = 3'd3;
	parameter WAITING_GAP = 3'd4;
	
	always@(posedge inclk)
		if(!rst_n || !FIFO_ready_mask)
			begin
			FIFO_rd_data <= 16'h0000;
			input_iteration <= 8'd0;
			packet_counter <= 8'd0;
			state <= HEADER;
			end
		else if(FIFO_ready_mask)
			begin
			case(state)
				HEADER:
					begin
					FIFO_rd_data <= 16'hDEAD;
					input_iteration <= input_iteration;
					packet_counter <= 8'd0;
					state <= TIMESTAMP;
					end
				TIMESTAMP:
					begin
					FIFO_rd_data <= 16'hAAAA;
					input_iteration <= input_iteration;
					packet_counter <= 8'd0;
					state <= PACKET_PAYLOAD;
					end
				PACKET_PAYLOAD:
					begin
					FIFO_rd_data <= {input_iteration, packet_counter};
					input_iteration <= input_iteration;
					packet_counter <= packet_counter + 1'b1;
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
					state <= WAITING_GAP;
					end
				WAITING_GAP:
					begin
					FIFO_rd_data <= 16'h0000;
					input_iteration <= input_iteration;
					packet_counter <= packet_counter + 1'b1;		// reuse packet_counter here to generate a gap 
					if(packet_counter <= 20)
						state <= WAITING_GAP;
					else
						state <= HEADER;
					end
				
			endcase
			end


	// generate the BRAM_rd_request based on the current buffer status
	always@(posedge outclk) begin
		if(BRAM_ready_mask)
			BRAM_rd_request <= 1'b1;
		else
			BRAM_rd_request <= 1'b0;
		end	

	initial begin     
		
		inclk <= 1'b1;   
		outclk <= 1'b1;
		rst_n <= 1'b0;
		FIFO_rd_data <= 16'd0;
	   FIFO_ready_mask <= 1'b0; 
	   BRAM_rd_request <= 1'b0;

	    
		// Turn off Reset
		#12
		rst_n <= 1'b1;          
		#12
		FIFO_ready_mask <= 1'b1;
		
		#22000
		$stop;
			
	end 

endmodule 