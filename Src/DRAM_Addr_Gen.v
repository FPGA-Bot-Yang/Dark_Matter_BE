// Module connect to: DRAM controller, RX_buf_ctrl, Threshold_Global_Coordinator

// 1 FE packet = 128 * 16bit => 8 256bit DRAM words
// 8 FE packet sampled at the same time = 64 DRAM words
// Thus 6 LSB in address for in Sample Time Packet index
// 25bit DRAM address space, but actually this should be 24bit, divide into: 1 MSB = 0 | 2 bit iteration counter of time stamp | 16 bit sample time | 3 bit board # index | 3 bit in FE pack index
// 2 bit iteration counter of time stamp | 16 bit sample time will form the index to address dram address mask, dram addr mask size is 2^18
// 4 BRAM modules stores the 2^18 bit address mask, write logic has not been implement yet

module DRAM_Addr_Gen(
	input				clk,
	input 			    rst_n,
	
	// signal for address mask
	////////////////////////////////////////////////////////////////////////////
	// Potential Problem: Related logic for this one need to be implemented
	////////////////////////////////////////////////////////////////////////////
	input [15:0]       triggering_time_stamp, // input from Threshold_Global_Coordinator, signify the first tigger timestamp, valid only triggering_status=1
	input 			    triggering_status,	   // input from Threshold_Global_Coordinator
	
	// Signal to buffer
	input	 [7:0]	    BRAM_ready_mask,			// bit mask for those ready BRAMs. Each connect to the RX_buf_ctrl module's Buffer_Data_Ready pin
	input  [255:0]     BRAM_rd_data,
	output reg [7:0]	 BRAM_rd_request,		   // bit mask for rd_request, each bit connect to RX_buf_ctrl module's DRAM_RD_req pin
	output [2:0]		 BRAM_Sel,

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

	
	reg [1:0]  state;

	/*
	// counters for concatennating DRAM WR address
	reg		  addr_MSB;
	reg [1:0]  addr_timestamp_iteration;
	reg [15:0] addr_timestamp;
	reg [2:0]  addr_board_index;
	reg [2:0]  addr_inpacket_index;
	
	assign DRAM_Write_Addr = {addr_MSB, addr_timestamp_iteration, addr_timestamp, addr_board_index, addr_inpacket_index};///////////////////PROBLEMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM
	*/
	
	/*
	// DRAM address bit mask
	wire [17:0] mask_index;
	assign mask_index = {addr_timestamp_iteration, addr_timestamp};
	*/
	
	wire [3:0] board_sel;					// set as 4 bit so it can have extra value represents arbitration invalid(== 8)
	assign BRAM_Sel = board_sel[2:0];
	
	reg [6:0] channel_sel;
	reg [13:0] channel_offset;
	assign DRAM_Write_Addr = {1'b0, BRAM_Sel, channel_sel, channel_offset};		// 0 MSB, 3 bit Board selection, 7 bit channel selection on each board, 14-bit channel offset based on sampling time
	reg [13:0] prev_channel_offset [0:7];											// buffer the channel offset for each board, used for addressing when write data to DRAM
	
	reg        arbitor_enable;
	wire [7:0] arbitor;
	
	wire [4:0] MASK_dummy_output;
	
				
	reg [7:0] DRAM_Write_Counter;
	wire DDR_trans_done;
	
	assign DDR_trans_done = (DRAM_Write_Counter == 8'd124)?1:0;

	/*	
	// Dummy logic to keep the RAM module
	always@(posedge clk)
		if(!rst_n)
			MASK_output <= 1'b0;
		else
			case(addr_timestamp_iteration)
				0: MASK_output = MASK_dummy_output[0];
				1: MASK_output = MASK_dummy_output[1];
				2: MASK_output = MASK_dummy_output[2];
				3: MASK_output = MASK_dummy_output[3];
			endcase
	*/
	
	Arbitor Arbitor(
		.clk(clk),
		.rst_n(rst_n),
		.enable(arbitor_enable),
		.input_mask(BRAM_ready_mask),
		.output_mask(arbitor),
		.board_sel(board_sel)
	);
/*	
	BitMaskRAM BitMaskRAM_0(
		.address(addr_timestamp),
		.clock(clk),
		.data(),
		.wren(),
		.q(MASK_dummy_output[0])
	);
	
	BitMaskRAM BitMaskRAM_1(
		.address(addr_timestamp),
		.clock(clk),
		.data(),
		.wren(),
		.q(MASK_dummy_output[1])
	);
	
	BitMaskRAM BitMaskRAM_2(
		.address(addr_timestamp),
		.clock(clk),
		.data(),
		.wren(),
		.q(MASK_dummy_output[2])
	);
	
	BitMaskRAM BitMaskRAM_3(
		.address(addr_timestamp),
		.clock(clk),
		.data(),
		.wren(),
		.q(MASK_dummy_output[3])
	);
*/	
	
	
	
	
	always@(posedge clk)
		if(!rst_n)
			begin
			arbitor_enable <= 1'b0;
			
			BRAM_rd_request <= 8'd0;
			
			DRAM_Write_Enable <= 1'b0;
			DRAM_Write_Burst_Begin <= 1'b0;
			DRAM_Write_Burst_Count <= 5'd0;
			DRAM_Write_Data <= 256'd0;
			DRAM_Write_Counter <= 8'd0;
			/*
			addr_MSB <= 1'b0;
			addr_timestamp_iteration <= 2'd0;
			addr_timestamp <= 16'd0;
			addr_board_index <= 3'd0;
			addr_inpacket_index <= 3'd0;
			*/
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
			
			state <= ARBITRATION;
			end
		else
			begin
	      case(state)
				ARBITRATION:
					begin
					arbitor_enable <= 1'b1;
					
					BRAM_rd_request <= 8'd0;
			
					DRAM_Write_Enable <= 1'b0;
					DRAM_Write_Burst_Begin <= 1'b0;
					DRAM_Write_Burst_Count <= 5'd0;
					DRAM_Write_Data <= BRAM_rd_data;
					DRAM_Write_Counter <= 8'd0;
					/*
					addr_MSB <= 1'b0;
					addr_timestamp_iteration <= addr_timestamp_iteration;
					addr_timestamp <= 16'd0;
					addr_board_index <= 3'd0;
					addr_inpacket_index <= 3'd0;
					*/
					channel_sel <= 7'd0;
					
					if(board_sel == 4'd8)				// If arbitration gives no results
						state <= ARBITRATION;
					else
						state <= READFIRSTDATA;
						
					end
	/////////////////PROMBLEMMMMMMMMMMMMMMMMMMMMMM delay between BRAM_rd_request triggered to data come. different from fifo, may need some register to delay DRAM related signals to wait data. MUX in top also need delay
				READFIRSTDATA:
					begin
					arbitor_enable <= 1'b0;
					/*
					addr_MSB <= 1'b0;
					addr_board_index <= board_sel;
					addr_inpacket_index <= 3'd0;
					*/
					channel_sel <= 7'd0;		// start from 0 for channel addressing
					
					if(DRAM_Wait_Request) 				// If DRAM is ready, then readout one data from BRAM
						begin
						BRAM_rd_request <= arbitor;		// read one data from BRAM
						
						DRAM_Write_Enable <= 1'b1;
						DRAM_Write_Burst_Begin <= 1'b1;
						DRAM_Write_Burst_Count <= 5'd1;
						DRAM_Write_Data <= BRAM_rd_data;
						DRAM_Write_Counter <= DRAM_Write_Counter + 1'd1;
						/*
						addr_timestamp <= BRAM_rd_data[239:224];			// The 2nd 16bit word from the first DRAM words in the FE packet is the time stamp
						if(addr_timestamp == 65535)
							addr_timestamp_iteration <= addr_timestamp_iteration + 1'b1;
						else
							addr_timestamp_iteration <= addr_timestamp_iteration;
						*/
						
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
						/*
						addr_timestamp_iteration <= addr_timestamp_iteration;
						addr_timestamp <= 16'd0;			// The 2nd 16bit word from the first DRAM words in the FE packet is the time stamp
						*/
						state <= READFIRSTDATA;
						end
					end
					
				DRAMWRITE:
					begin
					arbitor_enable <= 1'b0;
					/*
					addr_MSB <= 1'b0;
					addr_timestamp_iteration <= addr_timestamp_iteration;
					addr_board_index <= board_sel;
					*/
					
					if(DRAM_Wait_Request) 				// If DRAM is ready, then readout one data from BRAM
						begin
						BRAM_rd_request <= arbitor;		// read one data from BRAM
						
						DRAM_Write_Enable <= 1'b1;
						DRAM_Write_Burst_Begin <= 1'b1;
						DRAM_Write_Burst_Count <= 5'd1;
						DRAM_Write_Data <= BRAM_rd_data;
						DRAM_Write_Counter <= DRAM_Write_Counter + 1'd1;
						/*
						addr_timestamp <= addr_timestamp;			// The 2nd 16bit word from the first DRAM words in the FE packet is the time stamp
						addr_inpacket_index <= addr_inpacket_index + 1'b1;
						*/
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
						/*
						addr_timestamp <= addr_timestamp;
						addr_inpacket_index <= addr_inpacket_index;
						*/
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
						
						state <= ARBITRATION;
						end
					else
						begin
						prev_channel_offset[BRAM_Sel] <= prev_channel_offset[BRAM_Sel];
						
						state <= DRAMWRITE;
						end
					end
					
			endcase
			end


endmodule