module DRAM_test_top
(
	// clock and reset		
	input clkin_125,							// Programmable clk X5 (PIN U31)
													// DRAM controller input reference clock
	input rst_n,								// Pin AK13, Button S3
													// When pressed, rst_n = 0
	output avalon_clk_out,

	// LED signal output
	output reg LED,							// 0 on, 1 off 
													// Connected to PIN AH27, on Board is D8 green LED	
	
	// the_ddr3a_top
	output [13:0] ddr3b_a,
	output [2:0] ddr3b_ba,
	output ddr3b_casn,
	output ddr3b_cke,
	output ddr3b_clk_n,
	output ddr3b_clk_p,
	output ddr3b_csn,
	output [7:0] ddr3b_dm,

	inout [63:0] ddr3b_dq,
	inout [7:0] ddr3b_dqs_p,
	inout [7:0] ddr3b_dqs_n,
	output ddr3b_odt,
	output ddr3b_rasn,
	output ddr3b_resetn,
	output ddr3b_wen,
	input rzqin_1_5v
);
	
	
	reg read;
	reg write;
	reg [24:0] address;
	reg [255:0] write_data;
	reg [4:0] burst_count;	
	reg burst_begin;
	reg [3:0] next;
	reg [3:0] state;


	wire [255:0] read_data;
	wire wait_request;
	wire read_valid;
	wire avalon_clk;
	
	// Generate the data and address that write to the DRAM, the data write to the dram is equal to the address
	reg [24:0] address_counter;											
	// Cycle counter to record how many cycles has elapsed
	(* noprune *)reg [100:0] cycle_counter;
	// Global counter that record how many rounds elapsed to fill the DRAM
	reg [7:0] global_counter;
	
	assign avalon_clk_out = avalon_clk;									// assign the output port of avalon clock
	
	
	
	// Band width test
	always@(posedge avalon_clk)
		begin
		state <= next;
		if (!rst_n)
			begin
			address_counter <= 25'h0;
			cycle_counter <= 0;
			global_counter <= 0;												// Keep global_counter
			end
		else
			begin
			// recording how many cycles has elapsed before the data write finish
			if (state < 4 && state >0)
				cycle_counter <= cycle_counter + 1'b1;
			else
				cycle_counter <= cycle_counter;
			
			// control logic for write and read
			case(next)
				// Wait for DRAM reset done
				0:
					begin
					address_counter <= address_counter;
					global_counter <= global_counter;					// Keep global_counter
					end
				
				//Write data
				1:
					begin
					global_counter <= global_counter;					// Keep global_counter
					if(wait_request)
						begin
						address_counter <= address_counter + 1'b1;	// increase counter
						end
					else
						begin
						address_counter <= address_counter;
						end
					end
				
				// Determine if multiple rounds of write has finished
				2:
					begin
						address_counter <= 0;								// reset address_counter
						if (global_counter <= 130)							// Write DRAM 130 times
							global_counter <= global_counter + 1'b1;	// increase global_counter after 1 round of write finish
						else
							global_counter <= global_counter;
					end
					
				// Read
				3:
					begin
					address_counter <= address_counter;
					global_counter <= global_counter;
					end
				
				// Wait
				4:
					begin
					address_counter <= address_counter;
					global_counter <= global_counter;
					end
			endcase;
			end
		end
		
	// Control signal assignment is combinational logic
	always@(*)
		begin
		if (!rst_n)
			begin
			read <= 0;
			write <= 0;
			address <= 0;
			write_data <= 0;
			burst_count <= 0;
			burst_begin <= 0;
			next <= 0;
			LED <= 0;															// LED on when reset
			end
		else
			begin
			// control logic for write and read
			case(state)
				// Wait for DRAM reset done
				0:
					begin
					LED <= 0;													// LED on when DRAM reset
					read <= 0;
					write <= 0;
					address <= 0;
					write_data <= 0;
					burst_count <= 0;
					burst_begin <= 0;
					if(wait_request)
						next <= 1;
					else
						next <= 0;					
					end
					
				//Write data
				1:
					begin
					LED <= 1;													// LED off when write data to DRAM
					if(wait_request)
						begin
						read <= 0;
						write <= 1;
						address <= address_counter;
						write_data <= {230'h0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0, address_counter};;
						burst_count <= 1;
						burst_begin <= 1;

						if (address_counter <= 25'h1FFFFFE)				// Determine if reach the DRAM bottom, if not, keep writing new data
							next <= 1;
						else														// If reached, then read out the last data and compare if the data is correct
							next <= 2;
						end
					else
						begin
						read <= 0;
						write <= 0;
						address <= 0;
						write_data <= 0;
						burst_count <= 0;
						burst_begin <= 0;
						next <= 1;
						end
					end

				// Determine if multiple rounds of write has finished
				2:
					begin
					LED <= 1;													// LED off when write data to DRAM
					read <= 0;
					write <= 0;
					address <= 0;
					write_data <= 0;
					burst_count <= 0;
					burst_begin <= 0;
					
					//if (global_counter <= 130)								// Write DRAM 130 times
					if (global_counter <= 2)								// Write DRAM 130 times
						begin
						next <= 1;
						end
					else
						begin
						next <= 3;
						end
					end
					
					
				// Read
				3:
					begin
					LED <= 1;													// LED off when read data from DRAM
					if(wait_request)
						begin
						read <= 1;
						write <= 0;
						address <= 25'h1FFFFF1;
						write_data <= 0;
						burst_count <= 11;
						burst_begin <= 1;
						next <= 4;
						end
					else
						begin
						read <= 0;
						write <= 0;
						address <= 0;
						write_data <= 0;
						burst_count <= 0;
						burst_begin <= 0;
						next <= 3;
						end
					end

				// Wait
				4:
					begin
					LED <= 0;													// LED on when read and write finished
					read <= 0;
					write <= 0;
					address <= 0;
					write_data <= 0;
					burst_count <= 0;
					burst_begin <= 0;
					next <= 4;
					end
			endcase
			end
	end
		
		
	
//	// Read and Write test
//	always@(posedge avalon_clk)
//		begin
//		if (!rst_n)
//			begin
//			read <= 0;
//			write <= 0;
//			address <= 0;
//			write_data <= 0;
//			burst_count <= 0;
//			burst_begin <= 0;
//			state <= 0;
//			next <= 0;
//			end
//		else
//			begin
//			state <= next;
//			case(state)
//				0:													//Write 1st data
//					begin
//					if(wait_request)
//						begin
//						read <= 0;
//						write <= 1;
//						address <= 25'h1FFFE;
//						write_data <= 256'hABCD;
//						burst_count <= 1;
//						burst_begin <= 1;
//						next <= 1;
//						end
//					else
//						begin
//						read <= 0;
//						write <= 0;
//						address <= 0;
//						write_data <= 0;
//						burst_count <= 0;
//						burst_begin <= 0;
//						next <= 0;
//						end
//					end
//					
//				1:												// Finish Writing
//					begin
//					read <= 0;
//					write <= 0;
//					address <= 0;
//					write_data <= 0;
//					burst_count <= 0;
//					burst_begin <= 0;
//					next <= 2;
//					end
//					
//				
//				2:												// Write 2nd data
//					begin
//					if(wait_request)
//						begin
//						read <= 0;
//						write <= 1;
//						address <= 25'h1FFFF;
//						write_data <= 256'h1234;
//						burst_count <= 1;
//						burst_begin <= 1;
//						next <= 3;
//						end
//					else
//						begin
//						read <= 0;
//						write <= 0;
//						address <= 0;
//						write_data <= 0;
//						burst_count <= 0;
//						burst_begin <= 0;
//						next <= 2;
//						end
//					end
//					
//				3:
//					begin
//					read <= 0;
//					write <= 0;
//					address <= 0;
//					write_data <= 0;
//					burst_count <= 0;
//					burst_begin <= 0;
//					next <= 4;
//					end
//				
//				
//				4:												// Read
//					begin
//					if(wait_request)
//						begin
//						read <= 1;
//						write <= 0;
//						address <= 25'h1FFFE;
//						write_data <= 0;
//						burst_count <= 2;
//						burst_begin <= 1;
//						next <= 5;
//						end
//					else
//						begin
//						read <= 0;
//						write <= 0;
//						address <= 0;
//						write_data <= 0;
//						burst_count <= 0;
//						burst_begin <= 0;
//						next <= 4;
//						end
//					end
//				
//				5:												// Finish Read
//					begin
//					read <= 0;
//					write <= 0;
//					address <= 0;
//					write_data <= 0;
//					burst_count <= 0;
//					burst_begin <= 0;
//					next <= 6;
//					end
//				
//				6:												// Wait
//					begin
//					read <= 0;
//					write <= 0;
//					address <= 0;
//					write_data <= 0;
//					burst_count <= 0;
//					burst_begin <= 0;
//					next <= 6;
//					end
//			endcase;
//			end
//		end
//	


	dma_mem dma_mem_inst(
	.ddr3_top_memory_mem_a		 		(ddr3b_a),
	.ddr3_top_memory_mem_ba             (ddr3b_ba),
	.ddr3_top_memory_mem_cas_n          (ddr3b_casn),
	.ddr3_top_memory_mem_cke            (ddr3b_cke),		
	.ddr3_top_memory_mem_ck_n		 	(ddr3b_clk_n),		
	.ddr3_top_memory_mem_ck		 		(ddr3b_clk_p),
	.ddr3_top_memory_mem_cs_n           (ddr3b_csn),
	.ddr3_top_memory_mem_dm             (ddr3b_dm),
	.ddr3_top_memory_mem_dq         	(ddr3b_dq),
	.ddr3_top_memory_mem_dqs        	(ddr3b_dqs_p),		
	.ddr3_top_memory_mem_dqs_n      	(ddr3b_dqs_n),
	.ddr3_top_memory_mem_odt            (ddr3b_odt),
	.ddr3_top_memory_mem_ras_n          (ddr3b_rasn),
	.ddr3_top_memory_mem_reset_n        (ddr3b_resetn),
	.ddr3_top_memory_mem_we_n           (ddr3b_wen),
	.ddr3_top_oct_rzqin					(rzqin_1_5v),
	.ddr3_top_status_local_init_done    (),
	.ddr3_top_status_local_cal_success  (),
	.ddr3_top_status_local_cal_fail     (), 
				     
	.clk_125_clk_in_clk                    (clkin_125),          
	.clk_125_clk_in_reset_reset_n          (rst_n), 		

	.sdram_pll_sharing_pll_mem_clk               (),
	.sdram_pll_sharing_pll_write_clk             (),
	.sdram_pll_sharing_pll_locked                (),
	.sdram_pll_sharing_pll_write_clk_pre_phy_clk (),
	.sdram_pll_sharing_pll_addr_cmd_clk          (),
	.sdram_pll_sharing_pll_avl_clk               (),
	.sdram_pll_sharing_pll_config_clk            (),
	.sdram_pll_sharing_pll_mem_phy_clk           (),
	.sdram_pll_sharing_afi_phy_clk               (),
	.sdram_pll_sharing_pll_avl_phy_clk           (),

	.sdram_afi_clk_clk									(avalon_clk),
	.sdram_avl_read										(read),                    //                     .read
	.sdram_avl_write										(write),                    //                     .write
	.sdram_avl_address									(address),                    //                     .address
	.sdram_avl_writedata									(write_data),                    //                     .writedata
	.sdram_avl_burstcount								(burst_count),                    //                     .burstcount
	.sdram_avl_beginbursttransfer						(burst_begin),                	  //                     .beginbursttransfer

	.sdram_avl_waitrequest_n							(wait_request),                    //            sdram_avl.waitrequest_n
	.sdram_avl_readdata									(read_data),                    //                     .readdata
	.sdram_avl_readdatavalid							(read_valid),                    //                     .readdatavalid
	);

endmodule
