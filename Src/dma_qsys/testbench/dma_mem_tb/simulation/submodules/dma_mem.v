// dma_mem.v

// Generated using ACDS version 14.1 186 at 2017.06.06.18:01:10

`timescale 1 ps / 1 ps
module dma_mem (
		input  wire         clk_125_clk_in_clk,           //       clk_125_clk_in.clk
		input  wire         clk_125_clk_in_reset_reset_n, // clk_125_clk_in_reset.reset_n
		output wire [13:0]  ddr3_top_memory_mem_a,        //      ddr3_top_memory.mem_a
		output wire [2:0]   ddr3_top_memory_mem_ba,       //                     .mem_ba
		output wire [0:0]   ddr3_top_memory_mem_ck,       //                     .mem_ck
		output wire [0:0]   ddr3_top_memory_mem_ck_n,     //                     .mem_ck_n
		output wire [0:0]   ddr3_top_memory_mem_cke,      //                     .mem_cke
		output wire [0:0]   ddr3_top_memory_mem_cs_n,     //                     .mem_cs_n
		output wire [7:0]   ddr3_top_memory_mem_dm,       //                     .mem_dm
		output wire [0:0]   ddr3_top_memory_mem_ras_n,    //                     .mem_ras_n
		output wire [0:0]   ddr3_top_memory_mem_cas_n,    //                     .mem_cas_n
		output wire [0:0]   ddr3_top_memory_mem_we_n,     //                     .mem_we_n
		output wire         ddr3_top_memory_mem_reset_n,  //                     .mem_reset_n
		inout  wire [63:0]  ddr3_top_memory_mem_dq,       //                     .mem_dq
		inout  wire [7:0]   ddr3_top_memory_mem_dqs,      //                     .mem_dqs
		inout  wire [7:0]   ddr3_top_memory_mem_dqs_n,    //                     .mem_dqs_n
		output wire [0:0]   ddr3_top_memory_mem_odt,      //                     .mem_odt
		input  wire         ddr3_top_oct_rzqin,           //         ddr3_top_oct.rzqin
		output wire         sdram_afi_clk_clk,            //        sdram_afi_clk.clk
		output wire         sdram_avl_waitrequest_n,      //            sdram_avl.waitrequest_n
		input  wire         sdram_avl_beginbursttransfer, //                     .beginbursttransfer
		input  wire [24:0]  sdram_avl_address,            //                     .address
		output wire         sdram_avl_readdatavalid,      //                     .readdatavalid
		output wire [255:0] sdram_avl_readdata,           //                     .readdata
		input  wire [255:0] sdram_avl_writedata,          //                     .writedata
		input  wire         sdram_avl_read,               //                     .read
		input  wire         sdram_avl_write,              //                     .write
		input  wire [8:0]   sdram_avl_burstcount          //                     .burstcount
	);

	dma_mem_sdram sdram (
		.pll_ref_clk               (clk_125_clk_in_clk),           //      pll_ref_clk.clk
		.global_reset_n            (clk_125_clk_in_reset_reset_n), //     global_reset.reset_n
		.soft_reset_n              (clk_125_clk_in_reset_reset_n), //       soft_reset.reset_n
		.afi_clk                   (sdram_afi_clk_clk),            //          afi_clk.clk
		.afi_half_clk              (),                             //     afi_half_clk.clk
		.afi_reset_n               (),                             //        afi_reset.reset_n
		.afi_reset_export_n        (),                             // afi_reset_export.reset_n
		.mem_a                     (ddr3_top_memory_mem_a),        //           memory.mem_a
		.mem_ba                    (ddr3_top_memory_mem_ba),       //                 .mem_ba
		.mem_ck                    (ddr3_top_memory_mem_ck),       //                 .mem_ck
		.mem_ck_n                  (ddr3_top_memory_mem_ck_n),     //                 .mem_ck_n
		.mem_cke                   (ddr3_top_memory_mem_cke),      //                 .mem_cke
		.mem_cs_n                  (ddr3_top_memory_mem_cs_n),     //                 .mem_cs_n
		.mem_dm                    (ddr3_top_memory_mem_dm),       //                 .mem_dm
		.mem_ras_n                 (ddr3_top_memory_mem_ras_n),    //                 .mem_ras_n
		.mem_cas_n                 (ddr3_top_memory_mem_cas_n),    //                 .mem_cas_n
		.mem_we_n                  (ddr3_top_memory_mem_we_n),     //                 .mem_we_n
		.mem_reset_n               (ddr3_top_memory_mem_reset_n),  //                 .mem_reset_n
		.mem_dq                    (ddr3_top_memory_mem_dq),       //                 .mem_dq
		.mem_dqs                   (ddr3_top_memory_mem_dqs),      //                 .mem_dqs
		.mem_dqs_n                 (ddr3_top_memory_mem_dqs_n),    //                 .mem_dqs_n
		.mem_odt                   (ddr3_top_memory_mem_odt),      //                 .mem_odt
		.avl_ready                 (sdram_avl_waitrequest_n),      //              avl.waitrequest_n
		.avl_burstbegin            (sdram_avl_beginbursttransfer), //                 .beginbursttransfer
		.avl_addr                  (sdram_avl_address),            //                 .address
		.avl_rdata_valid           (sdram_avl_readdatavalid),      //                 .readdatavalid
		.avl_rdata                 (sdram_avl_readdata),           //                 .readdata
		.avl_wdata                 (sdram_avl_writedata),          //                 .writedata
		.avl_read_req              (sdram_avl_read),               //                 .read
		.avl_write_req             (sdram_avl_write),              //                 .write
		.avl_size                  (sdram_avl_burstcount),         //                 .burstcount
		.local_init_done           (),                             //           status.local_init_done
		.local_cal_success         (),                             //                 .local_cal_success
		.local_cal_fail            (),                             //                 .local_cal_fail
		.oct_rzqin                 (ddr3_top_oct_rzqin),           //              oct.rzqin
		.pll_mem_clk               (),                             //      pll_sharing.pll_mem_clk
		.pll_write_clk             (),                             //                 .pll_write_clk
		.pll_locked                (),                             //                 .pll_locked
		.pll_write_clk_pre_phy_clk (),                             //                 .pll_write_clk_pre_phy_clk
		.pll_addr_cmd_clk          (),                             //                 .pll_addr_cmd_clk
		.pll_avl_clk               (),                             //                 .pll_avl_clk
		.pll_config_clk            (),                             //                 .pll_config_clk
		.pll_mem_phy_clk           (),                             //                 .pll_mem_phy_clk
		.afi_phy_clk               (),                             //                 .afi_phy_clk
		.pll_avl_phy_clk           ()                              //                 .pll_avl_phy_clk
	);

endmodule
