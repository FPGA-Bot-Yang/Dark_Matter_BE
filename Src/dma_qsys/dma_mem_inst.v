	dma_mem u0 (
		.clk_125_clk_in_clk           (<connected-to-clk_125_clk_in_clk>),           //       clk_125_clk_in.clk
		.clk_125_clk_in_reset_reset_n (<connected-to-clk_125_clk_in_reset_reset_n>), // clk_125_clk_in_reset.reset_n
		.ddr3_top_memory_mem_a        (<connected-to-ddr3_top_memory_mem_a>),        //      ddr3_top_memory.mem_a
		.ddr3_top_memory_mem_ba       (<connected-to-ddr3_top_memory_mem_ba>),       //                     .mem_ba
		.ddr3_top_memory_mem_ck       (<connected-to-ddr3_top_memory_mem_ck>),       //                     .mem_ck
		.ddr3_top_memory_mem_ck_n     (<connected-to-ddr3_top_memory_mem_ck_n>),     //                     .mem_ck_n
		.ddr3_top_memory_mem_cke      (<connected-to-ddr3_top_memory_mem_cke>),      //                     .mem_cke
		.ddr3_top_memory_mem_cs_n     (<connected-to-ddr3_top_memory_mem_cs_n>),     //                     .mem_cs_n
		.ddr3_top_memory_mem_dm       (<connected-to-ddr3_top_memory_mem_dm>),       //                     .mem_dm
		.ddr3_top_memory_mem_ras_n    (<connected-to-ddr3_top_memory_mem_ras_n>),    //                     .mem_ras_n
		.ddr3_top_memory_mem_cas_n    (<connected-to-ddr3_top_memory_mem_cas_n>),    //                     .mem_cas_n
		.ddr3_top_memory_mem_we_n     (<connected-to-ddr3_top_memory_mem_we_n>),     //                     .mem_we_n
		.ddr3_top_memory_mem_reset_n  (<connected-to-ddr3_top_memory_mem_reset_n>),  //                     .mem_reset_n
		.ddr3_top_memory_mem_dq       (<connected-to-ddr3_top_memory_mem_dq>),       //                     .mem_dq
		.ddr3_top_memory_mem_dqs      (<connected-to-ddr3_top_memory_mem_dqs>),      //                     .mem_dqs
		.ddr3_top_memory_mem_dqs_n    (<connected-to-ddr3_top_memory_mem_dqs_n>),    //                     .mem_dqs_n
		.ddr3_top_memory_mem_odt      (<connected-to-ddr3_top_memory_mem_odt>),      //                     .mem_odt
		.ddr3_top_oct_rzqin           (<connected-to-ddr3_top_oct_rzqin>),           //         ddr3_top_oct.rzqin
		.sdram_afi_clk_clk            (<connected-to-sdram_afi_clk_clk>),            //        sdram_afi_clk.clk
		.sdram_avl_waitrequest_n      (<connected-to-sdram_avl_waitrequest_n>),      //            sdram_avl.waitrequest_n
		.sdram_avl_beginbursttransfer (<connected-to-sdram_avl_beginbursttransfer>), //                     .beginbursttransfer
		.sdram_avl_address            (<connected-to-sdram_avl_address>),            //                     .address
		.sdram_avl_readdatavalid      (<connected-to-sdram_avl_readdatavalid>),      //                     .readdatavalid
		.sdram_avl_readdata           (<connected-to-sdram_avl_readdata>),           //                     .readdata
		.sdram_avl_writedata          (<connected-to-sdram_avl_writedata>),          //                     .writedata
		.sdram_avl_read               (<connected-to-sdram_avl_read>),               //                     .read
		.sdram_avl_write              (<connected-to-sdram_avl_write>),              //                     .write
		.sdram_avl_burstcount         (<connected-to-sdram_avl_burstcount>)          //                     .burstcount
	);

