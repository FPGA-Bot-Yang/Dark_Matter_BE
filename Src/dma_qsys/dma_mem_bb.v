
module dma_mem (
	clk_125_clk_in_clk,
	clk_125_clk_in_reset_reset_n,
	ddr3_top_memory_mem_a,
	ddr3_top_memory_mem_ba,
	ddr3_top_memory_mem_ck,
	ddr3_top_memory_mem_ck_n,
	ddr3_top_memory_mem_cke,
	ddr3_top_memory_mem_cs_n,
	ddr3_top_memory_mem_dm,
	ddr3_top_memory_mem_ras_n,
	ddr3_top_memory_mem_cas_n,
	ddr3_top_memory_mem_we_n,
	ddr3_top_memory_mem_reset_n,
	ddr3_top_memory_mem_dq,
	ddr3_top_memory_mem_dqs,
	ddr3_top_memory_mem_dqs_n,
	ddr3_top_memory_mem_odt,
	ddr3_top_oct_rzqin,
	sdram_afi_clk_clk,
	sdram_avl_waitrequest_n,
	sdram_avl_beginbursttransfer,
	sdram_avl_address,
	sdram_avl_readdatavalid,
	sdram_avl_readdata,
	sdram_avl_writedata,
	sdram_avl_read,
	sdram_avl_write,
	sdram_avl_burstcount);	

	input		clk_125_clk_in_clk;
	input		clk_125_clk_in_reset_reset_n;
	output	[13:0]	ddr3_top_memory_mem_a;
	output	[2:0]	ddr3_top_memory_mem_ba;
	output	[0:0]	ddr3_top_memory_mem_ck;
	output	[0:0]	ddr3_top_memory_mem_ck_n;
	output	[0:0]	ddr3_top_memory_mem_cke;
	output	[0:0]	ddr3_top_memory_mem_cs_n;
	output	[7:0]	ddr3_top_memory_mem_dm;
	output	[0:0]	ddr3_top_memory_mem_ras_n;
	output	[0:0]	ddr3_top_memory_mem_cas_n;
	output	[0:0]	ddr3_top_memory_mem_we_n;
	output		ddr3_top_memory_mem_reset_n;
	inout	[63:0]	ddr3_top_memory_mem_dq;
	inout	[7:0]	ddr3_top_memory_mem_dqs;
	inout	[7:0]	ddr3_top_memory_mem_dqs_n;
	output	[0:0]	ddr3_top_memory_mem_odt;
	input		ddr3_top_oct_rzqin;
	output		sdram_afi_clk_clk;
	output		sdram_avl_waitrequest_n;
	input		sdram_avl_beginbursttransfer;
	input	[24:0]	sdram_avl_address;
	output		sdram_avl_readdatavalid;
	output	[255:0]	sdram_avl_readdata;
	input	[255:0]	sdram_avl_writedata;
	input		sdram_avl_read;
	input		sdram_avl_write;
	input	[8:0]	sdram_avl_burstcount;
endmodule
