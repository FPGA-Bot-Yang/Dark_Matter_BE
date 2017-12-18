////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Module: Channel_Data_Reorder_Buffer
// By: Tong Geng, Chen Yang 
// Rev1: 12/10/2017
//
// Function:
// 	Reordering the input data from each front end board that sampled at the same time and regroup them based on the channel ID
// 	Write the reordered data into DRAM
//		When the packet arrives, the packet header is used to align, but then discarded and won't be written into the reorder buffer
//		The received data from RX_FIFO suppose to include all the FE packets, including STARTING WORD, TIMESTAMP, 125*PAYLOAD, and ENDING WORD
//		The data written into the reorder buffer only including: TIMESTAMP, 125*PAYLOAD
//
// Module connect to: DRAM controller, RX_buf_ctrl, Threshold_Global_Coordinator
//
// 1 FE packet = 128 * 16bit => 8 256bit DRAM words
// 8 FE packet sampled at the same time = 64 DRAM words
// Thus 6 LSB in address for in Sample Time Packet index
// 25bit DRAM address space, but actually this should be 24bit, divide into: 1 MSB = 0 | 2 bit iteration counter of time stamp | 16 bit sample time | 3 bit board # index | 3 bit in FE pack index
// 2 bit iteration counter of time stamp | 16 bit sample time will form the index to address dram address mask, dram addr mask size is 2^18
// 4 BRAM modules stores the 2^18 bit address mask, write logic has not been implement yet
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////PROBLEMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM:Double buffer and timestamp buffer
module Channel_Data_Reorder_Buffer(
	input				    inclk,
	input 				 outclk,
	input 			    rst_n,
	
	// Signal to buffer
	input	 FIFO_ready_mask,			// bit mask for those ready FIFOs. Each connect to the RX_buf_ctrl module's Buffer_Data_Ready pin
	input  [15:0] FIFO_rd_data,
	output FIFO_rd_request,		   // bit mask for rd_request, each bit connect to RX_buf_ctrl module's DRAM_RD_req pin

	// Signal to DRAM user controller
	output BRAM_ready_mask,			// bit mask for those ready FIFOs. Each connect to the RX_buf_ctrl module's Buffer_Data_Ready pin
	output [255:0] DRAM_wr_data,
	input BRAM_rd_request		   // bit mask for rd_request, each bit connect to RX_buf_ctrl module's DRAM_RD_req pin
);

	//states for fifo-bram transfer
	parameter SWITCH_BUFFER = 2'b00;
	parameter CHECK_FIFO = 2'b01;
	parameter FIRST_DATA_ITERATION = 2'b10;
	parameter WRITE_BRAM = 2'b11;
	
	//states for bram-dram-user-controller transfer
	parameter WAIT_DRAM_BRAM = 2'b00;
	parameter WRITE_DRAM = 2'b01;
	parameter FIRST_CHANNEL = 2'b10;
	parameter WAIT_DRAM_READY = 2'b11;
	
	reg [1:0]  state;
	reg [1:0]  state2;
	//port for read from fifo
	reg [10:0] BRAM_WRADDR;
	reg BRAM_WREN;
	//port for write to Dram
	reg [6:0] DRAM_WRADDR;
	reg BRAM_RDEN;
	
	reg FIFO_rd_request_r;
	reg BRAM_ready_mask_r;

	reg BRAM_FULL;
	reg BRAM_FULL_x;
	reg BRAM_FULL_x_d;
	wire DDR_trans_done;
	reg [11:0] counter2048;
	reg [7:0] counter128;
	reg [7:0] counter_DDR;
	reg [10:0] counter16;
	reg [1:0] FULL_NUM;
	
	
			
	assign FIFO_rd_request = FIFO_rd_request_r;
	assign BRAM_ready_mask = BRAM_ready_mask_r;
	
	reg BRAM_out_sel;
	reg BRAM_out_sel_d;
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Switching mechanism between 2 buffers
	// Switching is initialized when the current writing buffer is finished writing
	// Bug assumption: the data from the current readout buffer will always finished write to DRAM before the current writing buffer is finished writing
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	wire [255:0] DRAM_wr_data_0;
	wire [255:0] DRAM_wr_data_1;
	assign DRAM_wr_data = (BRAM_out_sel_d)? DRAM_wr_data_1 : DRAM_wr_data_0;
	
	wire [15:0] BRAM_DATAIN_0;
	wire [15:0] BRAM_DATAIN_1;
	assign BRAM_DATAIN_0 = (BRAM_out_sel_d)? FIFO_rd_data : 16'd0;
	assign BRAM_DATAIN_1 = (BRAM_out_sel_d)? 16'd0 : FIFO_rd_data;
	
	wire [10:0] BRAM_WRADDR_0;
	wire [10:0] BRAM_WRADDR_1;
	assign BRAM_WRADDR_0 = (BRAM_out_sel_d)? BRAM_WRADDR : 1'b0;
	assign BRAM_WRADDR_1 = (BRAM_out_sel_d)? 1'b0: BRAM_WRADDR;
	
	wire BRAM_WREN_0;
	wire BRAM_WREN_1;
	reg BRAM_WREN_d;
	assign BRAM_WREN_0 = (BRAM_out_sel_d)? BRAM_WREN : 1'b0;
	assign BRAM_WREN_1 = (BRAM_out_sel_d)? 1'b0 : BRAM_WREN;
	
	wire [6:0] DRAM_WRADDR_0;
	wire [6:0] DRAM_WRADDR_1;
	assign DRAM_WRADDR_0 = (BRAM_out_sel_d)? 7'd0 : DRAM_WRADDR;
	assign DRAM_WRADDR_1 = (BRAM_out_sel_d)? DRAM_WRADDR : 7'd0;
	
	wire BRAM_RDEN_0;
	wire BRAM_RDEN_1;
	assign BRAM_RDEN_0 = (BRAM_out_sel_d)? 1'b0 : BRAM_RDEN;
	assign BRAM_RDEN_1 = (BRAM_out_sel_d)? BRAM_RDEN : 1'b0;      
	
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Reordering buffer implemented in BRAM, the input is 16-bit data from each channel that read in from MGT FIFO
	// The output is 256-bit, which is data sampled from the same channel in 16 consequective cycles, the output sequence is 16 sample data from consequective channels (exp. CH0, CH1, ....)
	// When write to this buffer, the write address should add a bias of 16 so that the data sampled from same channle will be allocated to the same output data
	// Double buffer is implemented here, when one buffer is full, then the next input is send to the other buffer, while the current buffer is pouring the data inside to DRAM
	// Assumption: the Buffer output will always be faster than data incoming, thus no data will be replaced before write into DRAM
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	Channel_Buffer_BRAM	Channel_Buffer_BRAM_0 (
		.inclock ( inclk ),
		.outclock ( outclk ),
		.data ( BRAM_DATAIN_0 ),
		.wraddress ( BRAM_WRADDR_0 ),
		.wren ( BRAM_WREN_0 ),
		.rdaddress ( DRAM_WRADDR_0 ),
		.rden ( BRAM_RDEN_0 ),
		.q ( DRAM_wr_data_0 )
	);
	
	Channel_Buffer_BRAM	Channel_Buffer_BRAM_1 (
		.inclock ( inclk ),
		.outclock (outclk),
		.data ( BRAM_DATAIN_1 ),
		.wraddress ( BRAM_WRADDR_1 ),
		.wren ( BRAM_WREN_1 ),
		.rdaddress ( DRAM_WRADDR_1 ),
		.rden ( BRAM_RDEN_1 ),
		.q ( DRAM_wr_data_1 )
	);
	
	// The number of buffers that is currently full and ready to write to DRAM, ranging from 0~2
	// Only write to DRAM when is number is larger than 0
	always@(posedge inclk)
		if(!rst_n)
			begin
			FULL_NUM <= 0;
			end
		else if ((BRAM_FULL_x == 1'd1) && (BRAM_FULL_x_d == 1'd0))
			begin
			FULL_NUM <= FULL_NUM + 1'd1;
			end
		else if (counter_DDR == 8'd125)
			FULL_NUM <= FULL_NUM - 1'd1;
		else	
			FULL_NUM <= FULL_NUM;
	
	always@(posedge inclk)
		if(!rst_n)
			begin
			BRAM_FULL <= 1'd0;
			end
		else if(counter2048 == 12'd2046)  //2046
			begin
			BRAM_FULL <= 1'd1;
			end
		else 
			BRAM_FULL <= 1'd0;
			
	always@(posedge inclk)
		if(!rst_n)
			begin
			BRAM_FULL_x <= 1'd0;
			end
		else if(counter2048 == 12'd2048)  //2046
			begin
			BRAM_FULL_x <= 1'd1;
			end
		else 
			BRAM_FULL_x <= 1'd0;
		
	always@(posedge inclk)
		if(!rst_n)
			begin
			BRAM_out_sel_d <= 1'd0;
			BRAM_FULL_x_d <= 1'd0;
			end
		else
			begin
			BRAM_FULL_x_d <= BRAM_FULL_x;
			BRAM_out_sel_d <= BRAM_out_sel;
			end

	// counting the number of incoming package
	// signify the offset for each 256-bit buffer output word 
	always@(posedge inclk)
		if(!rst_n)
			begin
			counter16 <= 11'd0;
			end
		else if(counter2048 == 12'd2047)
			begin
			counter16 <= 11'd0;
			end
			else if(counter128 == 8'd126)  //127
			begin
			counter16 <= counter16 + 1'd1;
			end
		else 
			counter16 <= counter16;
			
	assign DDR_trans_done = (counter_DDR == 8'd124)? 1'b1:1'b0;
	
	
			
	//FSM for Writing into reorder buffer
	always@(posedge inclk)
		if(!rst_n)
			begin
			BRAM_WRADDR <= 11'd0;
			BRAM_WREN <= 1'b0;
			FIFO_rd_request_r <= 1'b0;
			
			counter2048 <= 12'd0;
			counter128 <= 8'd0;
			//counter_DDR <= 8'd0;
			
			BRAM_out_sel <= 1'd0;
			state <= CHECK_FIFO;
			end
		else
			begin
	      case(state)
				// Switching read and write buffer
				SWITCH_BUFFER:
					begin
					BRAM_WRADDR <= 11'd0;
					BRAM_WREN <= 1'b0;
					FIFO_rd_request_r <= 1'b0;
			
					counter2048 <= 12'd0;
					counter128 <= 8'd0;
					//counter_DDR <= 8'd0;
			
					BRAM_out_sel <= ~BRAM_out_sel;
					state <= CHECK_FIFO;
					end
					
				CHECK_FIFO:
					begin
					BRAM_WRADDR <= counter16;
					BRAM_WREN <= 1'b0;
					FIFO_rd_request_r <= 1'b0;
					
					//counter_DDR <= 8'd0;
					counter2048 <= counter2048;
					counter128 <= 1'd0;
					
					BRAM_out_sel <= BRAM_out_sel;
					
					if(FIFO_ready_mask == 1'd1)// && BRAM_FULL == 1'd0)				
						state <= FIRST_DATA_ITERATION;
					else
						state <= CHECK_FIFO;
						
					end
					
				// readout the starting word from the package?
				FIRST_DATA_ITERATION:
					begin
					BRAM_WRADDR <= BRAM_WRADDR;
					FIFO_rd_request_r <= 1'b1;
					BRAM_out_sel <= BRAM_out_sel;
					BRAM_WREN <= 1'b1;
					counter128 <= 1'd0;
					if(FIFO_rd_data == 16'hDEAD)			// if detecting the packet header, then move on to keep writing
						begin
						counter2048 <= counter2048 + 1'd1;
						state <= WRITE_BRAM;
						end
					else											// if this is not the packet header, then wait for the header (this shouldn't happening, but just in case)
						begin
						counter2048 <= counter2048;
						state <= FIRST_DATA_ITERATION;
						end
					end
				
				WRITE_BRAM:
					begin
//					BRAM_DATAIN <= FIFO_rd_data;               
					BRAM_WRADDR <= BRAM_WRADDR + 11'd16;
					
					if(counter128 < 8'd126)
						begin
						BRAM_WREN <= 1'b1;
						FIFO_rd_request_r <= 1'b1;
						end
					else
						begin
						BRAM_WREN <= 1'b0;
						FIFO_rd_request_r <= 1'b0;
						end
					
					
					counter2048 <= counter2048 + 1'd1;		// total number of 16-bit data write into the current buffer, when equals to 2048, this one is full
					counter128 <= counter128 + 1'd1;			// in packet data counter
					
					BRAM_out_sel <= BRAM_out_sel;
					
					if(BRAM_FULL == 1'd1)		
						state <= SWITCH_BUFFER;
					else if(counter128 == 8'd126)
						state <= CHECK_FIFO;
					else
						state <= WRITE_BRAM;
					end
				endcase
				end
				
				
	//FSM for write to DRAM	
	always@(posedge outclk)
		if(!rst_n)
			begin		
			DRAM_WRADDR <= 7'b0;
			BRAM_RDEN <= 1'd0;
			BRAM_ready_mask_r <= 1'd0;
			
			counter_DDR <= 8'd0;
			
			state2 <= WAIT_DRAM_BRAM;
			end
		else
			begin
	      case(state2)		
				WAIT_DRAM_BRAM:
					begin			
					DRAM_WRADDR <= 7'd0;
					BRAM_RDEN <= 1'd0;
					if(FULL_NUM > 0)
						begin
						BRAM_ready_mask_r <= 1'd1;
						end

					counter_DDR <= 8'd0;
					
					if((BRAM_rd_request == 1'd1)&&(FULL_NUM > 0))	// is FULL_NUM necessary? Since BRAM_ready_mask won't be set if not, and BRAM_rd_request won't be received the previous one is not set		
						state2 <= FIRST_CHANNEL;
					else
						state2 <= WAIT_DRAM_BRAM;
					end
				FIRST_CHANNEL:
					begin
					DRAM_WRADDR <= 7'd1;										// Starting from address 1, so the starting word and timestamp won't be written into DRAM
					BRAM_RDEN <= 1'd1;
					BRAM_ready_mask_r <= 1'd1;

					
					counter_DDR <= counter_DDR + 1'd1;
					
					if(BRAM_rd_request == 1'd1)			
						state2 <= WRITE_DRAM;
					else
						state2 <= WAIT_DRAM_READY;
					end
				WAIT_DRAM_READY:
					begin
					DRAM_WRADDR <= DRAM_WRADDR;
					BRAM_RDEN <= 1'd0;
					BRAM_ready_mask_r <= 1'd1;

					counter_DDR <= counter_DDR;
					
					if(BRAM_rd_request == 1'd1)			
						state2 <= WRITE_DRAM;
					else
						state2 <= WAIT_DRAM_READY;
					end
				WRITE_DRAM:
					begin	
					DRAM_WRADDR <= DRAM_WRADDR + 1'd1;
					BRAM_RDEN <= 1'd1;
					if(DDR_trans_done == 1'd1)
						BRAM_ready_mask_r <= 1'd0;
					else
						BRAM_ready_mask_r <= 1'd1;

					counter_DDR <= counter_DDR + 1'd1;
					
					if(DDR_trans_done == 1'd1)
						state2 <= WAIT_DRAM_BRAM;
					else if(BRAM_rd_request == 1'd1)			
						state2 <= WRITE_DRAM;
					else
						state2 <= WAIT_DRAM_READY;
					end
					
			endcase
			end
	
	
endmodule