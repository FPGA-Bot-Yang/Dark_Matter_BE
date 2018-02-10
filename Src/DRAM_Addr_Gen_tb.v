///////////////////////////////////////////////////////////////////////////////////////////////////////
// Testbench evaluate the DRAM controller
// By: Chen Yang
// 02/08/2018
///////////////////////////////////////////////////////////////////////////////////////////////////////


`timescale 1ns/1ns

module DRAM_Addr_Gen_tb;
	reg clk;								
	reg rst_n;								


	reg DRAM_Wait_Request;
	wire [255:0] DRAM_Write_Data;
	wire DRAM_Write_Enable;
	wire [4:0] DRAM_Write_Burst_Count;	
	wire DRAM_Write_Burst_Begin;
	wire [24:0] DRAM_Write_Addr;
	
	reg [7:0] BRAM_ready_mask;
	reg [255:0] BRAM_rd_data;
	wire [7:0] BRAM_rd_request;
	wire [2:0] BRAM_Sel;

	DRAM_Addr_Gen UUT(
		.clk(clk),
		.rst_n(rst_n),
		
		// signal for address mask
		////////////////////////////////////////////////////////////////////////////
		// Potential Problem: Related logic for this one need to be implemented
		////////////////////////////////////////////////////////////////////////////
		.triggering_time_stamp(), 						// In[15:0], input from Threshold_Global_Coordinator, signify the first tigger timestamp, valid only triggering_status=1
		.triggering_status(),	   					// In, input from Threshold_Global_Coordinator
		
		// Signal to buffer
		.BRAM_ready_mask(BRAM_ready_mask),			// In[7:0], bit mask for those ready reorder buffers. Each connect to the Channel_Data_Reorder_Buffer module's BRAM_ready_mask pin
		.BRAM_rd_data(BRAM_rd_data),					// In[255:0], The readin data from reorder buffer
		.BRAM_rd_request(BRAM_rd_request),		   // Out[7:0], bit mask for rd_request, each bit connect to Channel_Data_Reorder_Buffer module's BRAM_rd_request pin
		.BRAM_Sel(BRAM_Sel),								// Out[2:0], output the arbitration results to select from 1 of the 8 reorder buffers

		// Signal to DRAM controller
		.DRAM_Wait_Request(DRAM_Wait_Request),							// In
		.DRAM_Write_Enable(DRAM_Write_Enable),							// Out
		.DRAM_Write_Burst_Begin(DRAM_Write_Burst_Begin),			// Out
		.DRAM_Write_Burst_Count(DRAM_Write_Burst_Count),			// Out[4:0]
		.DRAM_Write_Addr(DRAM_Write_Addr),								// Out[24:0]
		.DRAM_Write_Data(DRAM_Write_Data),								// Out[255:0]
		
		// dummy output for address mask
		.MASK_output()										// Out, not used for now
	);

	// clock
	always begin
		#2 clk <= ~clk;
	end 
	
	
	reg START; // start the generation process
	
	reg[2:0] state;
	reg[7:0] write_counter;
	
	parameter INITIAL = 3'd0;
	parameter READY = 3'd1;
	parameter WRITE_TO_DRAM = 3'd2;
	parameter DONE = 3'd3;
	
	always@(posedge clk)
		if(!rst_n)
			begin
			BRAM_rd_data <= 256'd0;
			BRAM_ready_mask <= 8'b00000000;
			write_counter <= 8'd0;
			
			state <= INITIAL;
			end
		else if (START)
			begin
			case(state)
				INITIAL:
					begin
					BRAM_ready_mask <= 8'b11111111;
					BRAM_rd_data <= 256'd0;
					write_counter <= 8'd0;
					
					state <= READY;
					end
				READY:
					begin
					BRAM_ready_mask <= BRAM_ready_mask;
					BRAM_rd_data <= 256'd0;
					write_counter <= 8'd0;
					
					if(BRAM_rd_request[BRAM_Sel])
						state <= WRITE_TO_DRAM;
					else
						state <= READY;
					end
				WRITE_TO_DRAM:
					begin
					BRAM_ready_mask <= BRAM_ready_mask & ~BRAM_rd_request;
					
					if(BRAM_rd_request[BRAM_Sel])
						begin
						BRAM_rd_data <= BRAM_rd_data + 1'b1;
						write_counter <= write_counter + 1'b1;
						end
					else
						begin
						BRAM_rd_data <= BRAM_rd_data;
						write_counter <= write_counter;
						end
					
					if(write_counter < 125)
						state <= WRITE_TO_DRAM;
					else
						state <= DONE;
		
					end
					
				DONE:
					begin
					BRAM_ready_mask <= BRAM_ready_mask;
					
					BRAM_rd_data <= 256'd0;
					write_counter <= 8'd0;
					
					state <= READY;
					end
				
			endcase
			end


	
	// Assign the DRAM wait request signal
	always@(posedge clk)
		begin
		DRAM_Wait_Request <= ~DRAM_Write_Burst_Begin;
		end
	
	initial begin     
		
		clk <= 1'b1;   
		rst_n <= 1'b0;
		
		START <= 1'b0;
		
		// Turn off Reset
		#12
		rst_n <= 1'b1;  

		#20
		START <= 1'b1;

		
		#10001
		$stop;
			
	end 

endmodule 