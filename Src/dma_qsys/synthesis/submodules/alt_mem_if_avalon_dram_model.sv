// (C) 2001-2014 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


//******************************************************************************************************************************** 
// File name: alt_mem_if_avalon_dram_model.sv
// This is the abstract RAM model used to abstract the Avalon-MM interface from
// a controller. This model has no external memory interface timing, and is only
// intended for simulation of an abstract memory interface
//******************************************************************************************************************************** 

`timescale 1 ps / 1 ps

module alt_mem_if_avalon_dram_model (
	avl_clock,
	avl_reset_n,
	
	avs_waitrequest_n,
	avs_read,
	avs_write,
	avs_burstbegin,
	avs_address,
	avs_byteenable,
	avs_writedata,
	avs_burstcount,
	avs_readdata,
	avs_readdatavalid,

	avm_waitrequest_n,
	avm_write,
	avm_read,
	avm_burstbegin,
	avm_address,
	avm_byteenable,
	avm_burstcount,
	avm_writedata,
	avm_readdata,
	avm_readdatavalid
);
//******************************************************************************************************************************** 
//BEGIN PARAMETER SECTION

parameter AV_ADDRESS_W               = 32;   // address width
parameter AV_SYMBOL_W                = 8;    // default symbol is byte
parameter AV_NUMSYMBOLS              = 4;    // number of symbols per word
parameter AV_BURSTCOUNT_W            = 3;    // burst port width

parameter USE_BYTE_ENABLE            = 1;    // use byteenable port

parameter MEM_INIT_FILE              = "";   // Memory initialization file   

parameter USE_MEM_VERBOSE            = 1;    // enable verbose output


//******************************************************************************************************************************** 
//BEGIN LOCALPARAMS SECTION

// The data width of the interface
localparam AV_DATA_W = AV_SYMBOL_W * AV_NUMSYMBOLS;

// The master and slave address widths
localparam AV_MASTER_ADDRESS_W = (AV_ADDRESS_W + log2(AV_NUMSYMBOLS));
localparam AV_SLAVE_ADDRESS_W = AV_ADDRESS_W;

//END LOCALPARAMS SECTION
//******************************************************************************************************************************** 
//******************************************************************************************************************************** 

//BEGIN PORT SECTION

   input                                           avl_clock;
   input                                           avl_reset_n;
   
   // Avalon Master Interface
   input                                           avm_waitrequest_n;
   input                                           avm_readdatavalid;
   input  [AV_DATA_W-1:0]                            avm_readdata;
   output logic                                    avm_write;
   output logic                                    avm_read;
   output logic [AV_MASTER_ADDRESS_W-1:0]            avm_address;
   output logic [AV_NUMSYMBOLS-1:0]                  avm_byteenable;
   output logic [AV_BURSTCOUNT_W-1:0]                avm_burstcount;
   output logic [AV_DATA_W-1:0]                      avm_writedata;
   output logic                                    avm_burstbegin;

   // Avalon Slave Interface
   output logic                                    avs_waitrequest_n;
   output logic                                    avs_readdatavalid;
   output logic [AV_DATA_W-1:0]                      avs_readdata;
   input                                           avs_write;
   input                                           avs_read;
   input  [AV_SLAVE_ADDRESS_W-1:0]                   avs_address;
   input  [AV_NUMSYMBOLS-1:0]                        avs_byteenable;
   input  [AV_BURSTCOUNT_W-1:0]                      avs_burstcount;
   input  [AV_DATA_W-1:0]                            avs_writedata;
   input                                           avs_burstbegin;

//END PORT SECTION
//******************************************************************************************************************************** 

	// Set up the Avalon-MM releater for the specific signals
	always @ (*) begin
	
		avs_waitrequest_n               <= avm_waitrequest_n;
	 
		avs_readdatavalid             <= avm_readdatavalid;

		avm_write                     <= avs_write;
		avm_read                      <= avs_read;
		avm_address                   <= {avs_address,{log2(AV_NUMSYMBOLS){1'b0}}};
		avm_burstbegin                <= avs_burstbegin;
	
		avm_byteenable                <= avs_byteenable;
		avm_burstcount                <= avs_burstcount;
		avm_writedata                 <= avs_writedata;
	end	

	function integer log2(
		input int value
		);
		value = value-1;
		for (log2=0; value>0; log2=log2+1) begin
		   value = value>>1;
		end
	
	endfunction: log2


// synthesis translate_off

	//The actual memory. Modeled as an associative array.
	typedef bit [AV_SLAVE_ADDRESS_W-1:0] mem_address;
	bit [AV_DATA_W-1:0] mem_data[mem_address];

	//The address of the memory array (mem_data). We make this
	//a packed struct so that it can be used directly as the
	//index to mem_data. 
	typedef struct packed {
		mem_address address;
		bit [AV_BURSTCOUNT_W-1:0] burst;
		bit [AV_DATA_W-1:0] data;
	} address_burst_type;

	//Create a variable for the current active write/read commands
	address_burst_type active_write_command;
	address_burst_type active_read_command;

	address_burst_type active_read_queue[$];

	bit [AV_DATA_W-1:0] active_write_data;

	integer active_read_burst_count = 0;
	integer active_write_burst_count = 0;
	
	integer i;
	integer rmax;
	integer rmin;

	// Write into the local abstract memory. This is done in addition to pasing
	// on the writes into the real memory interface
	always @ (posedge avl_clock or negedge avl_reset_n) begin
		if (~avl_reset_n) begin
			active_read_queue.delete();
			active_write_command.burst = 0;
		end
		else begin
			if (avm_waitrequest_n) begin
				if (avs_write) begin
					// Write data into local memory
					if (active_write_command.burst == 0) begin
						// This is a new burst
						active_write_command.burst = avs_burstcount-1;
						active_write_command.address = avs_address;
						active_write_command.data = avs_writedata;
					end
					else begin
						// Update the address/burst for the write
						active_write_command.burst = active_write_command.burst-1;
						active_write_command.address = active_write_command.address+1;
						active_write_command.data = avs_writedata;
					end
					
					// Write the data into memory. Ignore any symbols not enabled
					if (mem_data.exists(active_write_command.address))
						active_write_data = mem_data[active_write_command.address];
					else
						active_write_data = 0;
					for (i = 0; i < AV_NUMSYMBOLS; i++) begin
						if ((avs_byteenable[i] & USE_BYTE_ENABLE) || (USE_BYTE_ENABLE == 0))
							active_write_data[(i+1)*AV_SYMBOL_W-1-:AV_SYMBOL_W] = active_write_command.data[(i+1)*AV_SYMBOL_W-1-:AV_SYMBOL_W];
					end
					mem_data[active_write_command.address] = active_write_data;
					if (USE_MEM_VERBOSE == 1) begin
						$display("[%0t] %m: INFO: Writing to memory. addr = %h, mem_data = %h (%h/%h)", $time, active_write_command.address, active_write_data, avs_writedata, active_write_data);
					end
				end
				if (avs_read) begin
					// Perform the enture read now and push it in the queue

					for (i = 0; i < avs_burstcount; i++) begin
						active_read_command.address = avs_address+i;
						active_read_command.burst = i;
						if (mem_data.exists(active_read_command.address) == 0 && (USE_MEM_VERBOSE == 1))
							$display("[%0t] %m: ERROR: Attempting to read from uninitialized data location %h", $time, active_read_command.address);

						active_read_command.data = mem_data[active_read_command.address];
						if (USE_MEM_VERBOSE == 1) begin
							$display("[%0t] %m: INFO: Reading from memory. addr = %h, mem_data = %h", $time, active_read_command.address, active_read_command.data);
						end
						active_read_queue.push_back(active_read_command);
					end
					
				end
			end
			if (avm_readdatavalid) begin				
				// Read from the local memory and return the data when
				// readdatavalid is asserted
				if (active_read_queue.size() > 0)
					active_read_queue.pop_front();
			end
			
			avs_readdata <= (active_read_queue.size() > 0) ? active_read_queue[0] : 0;
		end
	end

// Initialize the memory

integer file, r;
reg [AV_DATA_W - 1:0] init_data;
reg [AV_DATA_W - 1:0] readback_data;
reg [AV_SLAVE_ADDRESS_W - 1:0] init_addr;

initial
    begin : file_block

		//assert(MEM_INIT_FILE != "") else
		//	$error("%m No memory initialization file specified");

		if 	(MEM_INIT_FILE != "") begin
	
			file = $fopen(MEM_INIT_FILE, "r");
			if (!file) begin
				$display("[%0t] %m: ERROR: Can't find %s", $time, MEM_INIT_FILE);
				disable file_block;
			end
			
			while (!$feof(file)) begin
				r = $fscanf(file, "@%h %h \n", init_addr, init_data);
				mem_data[init_addr] = init_data;
				if (USE_MEM_VERBOSE == 1) begin
					$display("[%0t] %m: INFO: Initializing the memory. addr = %h, mem_data = %h", $time, init_addr, mem_data[init_addr]);
				end
			end
			
			$fclose(file);
		end
    end 
     


// synthesis translate_on

// synthesis read_comments_as_HDL on
//	always_comb begin
//		avs_readdata <= avm_readdata;
//	end
// synthesis read_comments_as_HDL off

endmodule
