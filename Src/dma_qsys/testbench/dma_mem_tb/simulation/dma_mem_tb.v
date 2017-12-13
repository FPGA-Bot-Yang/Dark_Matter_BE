// dma_mem_tb.v

// Generated using ACDS version 14.1 186 at 2017.06.06.18:00:16

`timescale 1 ps / 1 ps
module dma_mem_tb (
	);

	wire          dma_mem_inst_sdram_avl_bfm_m0_beginbursttransfer;  // dma_mem_inst_sdram_avl_bfm:avm_beginbursttransfer -> dma_mem_inst:sdram_avl_beginbursttransfer
	wire  [255:0] dma_mem_inst_sdram_avl_bfm_m0_readdata;            // dma_mem_inst:sdram_avl_readdata -> dma_mem_inst_sdram_avl_bfm:avm_readdata
	wire          dma_mem_inst_sdram_avl_bfm_m0_waitrequest;         // dma_mem_inst:sdram_avl_waitrequest_n -> dma_mem_inst_sdram_avl_bfm:avm_waitrequest
	wire   [24:0] dma_mem_inst_sdram_avl_bfm_m0_address;             // dma_mem_inst_sdram_avl_bfm:avm_address -> dma_mem_inst:sdram_avl_address
	wire          dma_mem_inst_sdram_avl_bfm_m0_read;                // dma_mem_inst_sdram_avl_bfm:avm_read -> dma_mem_inst:sdram_avl_read
	wire          dma_mem_inst_sdram_avl_bfm_m0_readdatavalid;       // dma_mem_inst:sdram_avl_readdatavalid -> dma_mem_inst_sdram_avl_bfm:avm_readdatavalid
	wire  [255:0] dma_mem_inst_sdram_avl_bfm_m0_writedata;           // dma_mem_inst_sdram_avl_bfm:avm_writedata -> dma_mem_inst:sdram_avl_writedata
	wire          dma_mem_inst_sdram_avl_bfm_m0_write;               // dma_mem_inst_sdram_avl_bfm:avm_write -> dma_mem_inst:sdram_avl_write
	wire    [8:0] dma_mem_inst_sdram_avl_bfm_m0_burstcount;          // dma_mem_inst_sdram_avl_bfm:avm_burstcount -> dma_mem_inst:sdram_avl_burstcount
	wire          dma_mem_inst_clk_125_clk_in_bfm_clk_clk;           // dma_mem_inst_clk_125_clk_in_bfm:clk -> [dma_mem_inst:clk_125_clk_in_clk, dma_mem_inst_clk_125_clk_in_reset_bfm:clk]
	wire          dma_mem_inst_sdram_afi_clk_clk;                    // dma_mem_inst:sdram_afi_clk_clk -> [dma_mem_inst_sdram_avl_bfm:clk, rst_controller:clk]
	wire    [0:0] dma_mem_inst_ddr3_top_oct_bfm_conduit_rzqin;       // dma_mem_inst_ddr3_top_oct_bfm:sig_rzqin -> dma_mem_inst:ddr3_top_oct_rzqin
	wire    [0:0] dma_mem_inst_ddr3_top_memory_mem_cas_n;            // dma_mem_inst:ddr3_top_memory_mem_cas_n -> sdram_mem_model:mem_cas_n
	wire          dma_mem_inst_ddr3_top_memory_mem_reset_n;          // dma_mem_inst:ddr3_top_memory_mem_reset_n -> sdram_mem_model:mem_reset_n
	wire    [2:0] dma_mem_inst_ddr3_top_memory_mem_ba;               // dma_mem_inst:ddr3_top_memory_mem_ba -> sdram_mem_model:mem_ba
	wire    [0:0] dma_mem_inst_ddr3_top_memory_mem_we_n;             // dma_mem_inst:ddr3_top_memory_mem_we_n -> sdram_mem_model:mem_we_n
	wire    [0:0] dma_mem_inst_ddr3_top_memory_mem_ck;               // dma_mem_inst:ddr3_top_memory_mem_ck -> sdram_mem_model:mem_ck
	wire    [7:0] dma_mem_inst_ddr3_top_memory_mem_dm;               // dma_mem_inst:ddr3_top_memory_mem_dm -> sdram_mem_model:mem_dm
	wire    [7:0] dma_mem_inst_ddr3_top_memory_mem_dqs;              // [] -> [dma_mem_inst:ddr3_top_memory_mem_dqs, sdram_mem_model:mem_dqs]
	wire   [63:0] dma_mem_inst_ddr3_top_memory_mem_dq;               // [] -> [dma_mem_inst:ddr3_top_memory_mem_dq, sdram_mem_model:mem_dq]
	wire    [0:0] dma_mem_inst_ddr3_top_memory_mem_cs_n;             // dma_mem_inst:ddr3_top_memory_mem_cs_n -> sdram_mem_model:mem_cs_n
	wire   [13:0] dma_mem_inst_ddr3_top_memory_mem_a;                // dma_mem_inst:ddr3_top_memory_mem_a -> sdram_mem_model:mem_a
	wire    [0:0] dma_mem_inst_ddr3_top_memory_mem_ras_n;            // dma_mem_inst:ddr3_top_memory_mem_ras_n -> sdram_mem_model:mem_ras_n
	wire    [7:0] dma_mem_inst_ddr3_top_memory_mem_dqs_n;            // [] -> [dma_mem_inst:ddr3_top_memory_mem_dqs_n, sdram_mem_model:mem_dqs_n]
	wire    [0:0] dma_mem_inst_ddr3_top_memory_mem_odt;              // dma_mem_inst:ddr3_top_memory_mem_odt -> sdram_mem_model:mem_odt
	wire    [0:0] dma_mem_inst_ddr3_top_memory_mem_ck_n;             // dma_mem_inst:ddr3_top_memory_mem_ck_n -> sdram_mem_model:mem_ck_n
	wire    [0:0] dma_mem_inst_ddr3_top_memory_mem_cke;              // dma_mem_inst:ddr3_top_memory_mem_cke -> sdram_mem_model:mem_cke
	wire          dma_mem_inst_clk_125_clk_in_reset_bfm_reset_reset; // dma_mem_inst_clk_125_clk_in_reset_bfm:reset -> [dma_mem_inst:clk_125_clk_in_reset_reset_n, rst_controller:reset_in0]
	wire          rst_controller_reset_out_reset;                    // rst_controller:reset_out -> dma_mem_inst_sdram_avl_bfm:reset

	dma_mem dma_mem_inst (
		.clk_125_clk_in_clk           (dma_mem_inst_clk_125_clk_in_bfm_clk_clk),           //       clk_125_clk_in.clk
		.clk_125_clk_in_reset_reset_n (dma_mem_inst_clk_125_clk_in_reset_bfm_reset_reset), // clk_125_clk_in_reset.reset_n
		.ddr3_top_memory_mem_a        (dma_mem_inst_ddr3_top_memory_mem_a),                //      ddr3_top_memory.mem_a
		.ddr3_top_memory_mem_ba       (dma_mem_inst_ddr3_top_memory_mem_ba),               //                     .mem_ba
		.ddr3_top_memory_mem_ck       (dma_mem_inst_ddr3_top_memory_mem_ck),               //                     .mem_ck
		.ddr3_top_memory_mem_ck_n     (dma_mem_inst_ddr3_top_memory_mem_ck_n),             //                     .mem_ck_n
		.ddr3_top_memory_mem_cke      (dma_mem_inst_ddr3_top_memory_mem_cke),              //                     .mem_cke
		.ddr3_top_memory_mem_cs_n     (dma_mem_inst_ddr3_top_memory_mem_cs_n),             //                     .mem_cs_n
		.ddr3_top_memory_mem_dm       (dma_mem_inst_ddr3_top_memory_mem_dm),               //                     .mem_dm
		.ddr3_top_memory_mem_ras_n    (dma_mem_inst_ddr3_top_memory_mem_ras_n),            //                     .mem_ras_n
		.ddr3_top_memory_mem_cas_n    (dma_mem_inst_ddr3_top_memory_mem_cas_n),            //                     .mem_cas_n
		.ddr3_top_memory_mem_we_n     (dma_mem_inst_ddr3_top_memory_mem_we_n),             //                     .mem_we_n
		.ddr3_top_memory_mem_reset_n  (dma_mem_inst_ddr3_top_memory_mem_reset_n),          //                     .mem_reset_n
		.ddr3_top_memory_mem_dq       (dma_mem_inst_ddr3_top_memory_mem_dq),               //                     .mem_dq
		.ddr3_top_memory_mem_dqs      (dma_mem_inst_ddr3_top_memory_mem_dqs),              //                     .mem_dqs
		.ddr3_top_memory_mem_dqs_n    (dma_mem_inst_ddr3_top_memory_mem_dqs_n),            //                     .mem_dqs_n
		.ddr3_top_memory_mem_odt      (dma_mem_inst_ddr3_top_memory_mem_odt),              //                     .mem_odt
		.ddr3_top_oct_rzqin           (dma_mem_inst_ddr3_top_oct_bfm_conduit_rzqin),       //         ddr3_top_oct.rzqin
		.sdram_afi_clk_clk            (dma_mem_inst_sdram_afi_clk_clk),                    //        sdram_afi_clk.clk
		.sdram_avl_waitrequest_n      (dma_mem_inst_sdram_avl_bfm_m0_waitrequest),         //            sdram_avl.waitrequest_n
		.sdram_avl_beginbursttransfer (dma_mem_inst_sdram_avl_bfm_m0_beginbursttransfer),  //                     .beginbursttransfer
		.sdram_avl_address            (dma_mem_inst_sdram_avl_bfm_m0_address),             //                     .address
		.sdram_avl_readdatavalid      (dma_mem_inst_sdram_avl_bfm_m0_readdatavalid),       //                     .readdatavalid
		.sdram_avl_readdata           (dma_mem_inst_sdram_avl_bfm_m0_readdata),            //                     .readdata
		.sdram_avl_writedata          (dma_mem_inst_sdram_avl_bfm_m0_writedata),           //                     .writedata
		.sdram_avl_read               (dma_mem_inst_sdram_avl_bfm_m0_read),                //                     .read
		.sdram_avl_write              (dma_mem_inst_sdram_avl_bfm_m0_write),               //                     .write
		.sdram_avl_burstcount         (dma_mem_inst_sdram_avl_bfm_m0_burstcount)           //                     .burstcount
	);

	altera_avalon_clock_source #(
		.CLOCK_RATE (125000000),
		.CLOCK_UNIT (1)
	) dma_mem_inst_clk_125_clk_in_bfm (
		.clk (dma_mem_inst_clk_125_clk_in_bfm_clk_clk)  // clk.clk
	);

	altera_avalon_reset_source #(
		.ASSERT_HIGH_RESET    (0),
		.INITIAL_RESET_CYCLES (50)
	) dma_mem_inst_clk_125_clk_in_reset_bfm (
		.reset (dma_mem_inst_clk_125_clk_in_reset_bfm_reset_reset), // reset.reset_n
		.clk   (dma_mem_inst_clk_125_clk_in_bfm_clk_clk)            //   clk.clk
	);

	altera_conduit_bfm dma_mem_inst_ddr3_top_oct_bfm (
		.sig_rzqin (dma_mem_inst_ddr3_top_oct_bfm_conduit_rzqin)  // conduit.rzqin
	);

	altera_avalon_mm_master_bfm #(
		.AV_ADDRESS_W               (25),
		.AV_SYMBOL_W                (8),
		.AV_NUMSYMBOLS              (32),
		.AV_BURSTCOUNT_W            (9),
		.AV_READRESPONSE_W          (1),
		.AV_WRITERESPONSE_W         (1),
		.USE_READ                   (1),
		.USE_WRITE                  (1),
		.USE_ADDRESS                (1),
		.USE_BYTE_ENABLE            (0),
		.USE_BURSTCOUNT             (1),
		.USE_READ_DATA              (1),
		.USE_READ_DATA_VALID        (1),
		.USE_WRITE_DATA             (1),
		.USE_BEGIN_TRANSFER         (0),
		.USE_BEGIN_BURST_TRANSFER   (1),
		.USE_WAIT_REQUEST           (1),
		.USE_TRANSACTIONID          (0),
		.USE_WRITERESPONSE          (0),
		.USE_READRESPONSE           (0),
		.USE_CLKEN                  (0),
		.AV_CONSTANT_BURST_BEHAVIOR (1),
		.AV_BURST_LINEWRAP          (0),
		.AV_BURST_BNDR_ONLY         (0),
		.AV_MAX_PENDING_READS       (32),
		.AV_MAX_PENDING_WRITES      (0),
		.AV_FIX_READ_LATENCY        (0),
		.AV_READ_WAIT_TIME          (1),
		.AV_WRITE_WAIT_TIME         (0),
		.REGISTER_WAITREQUEST       (0),
		.AV_REGISTERINCOMINGSIGNALS (0),
		.VHDL_ID                    (0)
	) dma_mem_inst_sdram_avl_bfm (
		.clk                    (dma_mem_inst_sdram_afi_clk_clk),                   //       clk.clk
		.reset                  (rst_controller_reset_out_reset),                   // clk_reset.reset
		.avm_address            (dma_mem_inst_sdram_avl_bfm_m0_address),            //        m0.address
		.avm_burstcount         (dma_mem_inst_sdram_avl_bfm_m0_burstcount),         //          .burstcount
		.avm_readdata           (dma_mem_inst_sdram_avl_bfm_m0_readdata),           //          .readdata
		.avm_writedata          (dma_mem_inst_sdram_avl_bfm_m0_writedata),          //          .writedata
		.avm_beginbursttransfer (dma_mem_inst_sdram_avl_bfm_m0_beginbursttransfer), //          .beginbursttransfer
		.avm_waitrequest        (~dma_mem_inst_sdram_avl_bfm_m0_waitrequest),       //          .waitrequest
		.avm_write              (dma_mem_inst_sdram_avl_bfm_m0_write),              //          .write
		.avm_read               (dma_mem_inst_sdram_avl_bfm_m0_read),               //          .read
		.avm_readdatavalid      (dma_mem_inst_sdram_avl_bfm_m0_readdatavalid),      //          .readdatavalid
		.avm_begintransfer      (),                                                 // (terminated)
		.avm_byteenable         (),                                                 // (terminated)
		.avm_arbiterlock        (),                                                 // (terminated)
		.avm_lock               (),                                                 // (terminated)
		.avm_debugaccess        (),                                                 // (terminated)
		.avm_transactionid      (),                                                 // (terminated)
		.avm_readid             (8'b00000000),                                      // (terminated)
		.avm_writeid            (8'b00000000),                                      // (terminated)
		.avm_clken              (),                                                 // (terminated)
		.avm_response           (2'b00),                                            // (terminated)
		.avm_writeresponsevalid (1'b0),                                             // (terminated)
		.avm_readresponse       (1'b0),                                             // (terminated)
		.avm_writeresponse      (1'b0)                                              // (terminated)
	);

	alt_mem_if_ddr3_mem_model_top_ddr3_mem_if_dm_pins_en_mem_if_dqsn_en #(
		.MEM_IF_ADDR_WIDTH            (14),
		.MEM_IF_ROW_ADDR_WIDTH        (14),
		.MEM_IF_COL_ADDR_WIDTH        (10),
		.MEM_IF_CONTROL_WIDTH         (1),
		.MEM_IF_DQS_WIDTH             (8),
		.MEM_IF_CS_WIDTH              (1),
		.MEM_IF_BANKADDR_WIDTH        (3),
		.MEM_IF_DQ_WIDTH              (64),
		.MEM_IF_CK_WIDTH              (1),
		.MEM_IF_CLK_EN_WIDTH          (1),
		.MEM_TRCD                     (5),
		.MEM_TRTP                     (3),
		.MEM_DQS_TO_CLK_CAPTURE_DELAY (450),
		.MEM_CLK_TO_DQS_CAPTURE_DELAY (100000),
		.MEM_IF_ODT_WIDTH             (1),
		.MEM_IF_LRDIMM_RM             (0),
		.MEM_MIRROR_ADDRESSING_DEC    (0),
		.MEM_REGDIMM_ENABLED          (0),
		.MEM_LRDIMM_ENABLED           (0),
		.DEVICE_DEPTH                 (1),
		.MEM_NUMBER_OF_DIMMS          (1),
		.MEM_NUMBER_OF_RANKS_PER_DIMM (1),
		.MEM_GUARANTEED_WRITE_INIT    (0),
		.MEM_VERBOSE                  (1),
		.REFRESH_BURST_VALIDATION     (0),
		.AP_MODE_EN                   (2'b00),
		.MEM_INIT_EN                  (0),
		.MEM_INIT_FILE                (""),
		.DAT_DATA_WIDTH               (32)
	) sdram_mem_model (
		.mem_a       (dma_mem_inst_ddr3_top_memory_mem_a),       // memory.mem_a
		.mem_ba      (dma_mem_inst_ddr3_top_memory_mem_ba),      //       .mem_ba
		.mem_ck      (dma_mem_inst_ddr3_top_memory_mem_ck),      //       .mem_ck
		.mem_ck_n    (dma_mem_inst_ddr3_top_memory_mem_ck_n),    //       .mem_ck_n
		.mem_cke     (dma_mem_inst_ddr3_top_memory_mem_cke),     //       .mem_cke
		.mem_cs_n    (dma_mem_inst_ddr3_top_memory_mem_cs_n),    //       .mem_cs_n
		.mem_dm      (dma_mem_inst_ddr3_top_memory_mem_dm),      //       .mem_dm
		.mem_ras_n   (dma_mem_inst_ddr3_top_memory_mem_ras_n),   //       .mem_ras_n
		.mem_cas_n   (dma_mem_inst_ddr3_top_memory_mem_cas_n),   //       .mem_cas_n
		.mem_we_n    (dma_mem_inst_ddr3_top_memory_mem_we_n),    //       .mem_we_n
		.mem_reset_n (dma_mem_inst_ddr3_top_memory_mem_reset_n), //       .mem_reset_n
		.mem_dq      (dma_mem_inst_ddr3_top_memory_mem_dq),      //       .mem_dq
		.mem_dqs     (dma_mem_inst_ddr3_top_memory_mem_dqs),     //       .mem_dqs
		.mem_dqs_n   (dma_mem_inst_ddr3_top_memory_mem_dqs_n),   //       .mem_dqs_n
		.mem_odt     (dma_mem_inst_ddr3_top_memory_mem_odt)      //       .mem_odt
	);

	altera_reset_controller #(
		.NUM_RESET_INPUTS          (1),
		.OUTPUT_RESET_SYNC_EDGES   ("deassert"),
		.SYNC_DEPTH                (2),
		.RESET_REQUEST_PRESENT     (0),
		.RESET_REQ_WAIT_TIME       (1),
		.MIN_RST_ASSERTION_TIME    (3),
		.RESET_REQ_EARLY_DSRT_TIME (1),
		.USE_RESET_REQUEST_IN0     (0),
		.USE_RESET_REQUEST_IN1     (0),
		.USE_RESET_REQUEST_IN2     (0),
		.USE_RESET_REQUEST_IN3     (0),
		.USE_RESET_REQUEST_IN4     (0),
		.USE_RESET_REQUEST_IN5     (0),
		.USE_RESET_REQUEST_IN6     (0),
		.USE_RESET_REQUEST_IN7     (0),
		.USE_RESET_REQUEST_IN8     (0),
		.USE_RESET_REQUEST_IN9     (0),
		.USE_RESET_REQUEST_IN10    (0),
		.USE_RESET_REQUEST_IN11    (0),
		.USE_RESET_REQUEST_IN12    (0),
		.USE_RESET_REQUEST_IN13    (0),
		.USE_RESET_REQUEST_IN14    (0),
		.USE_RESET_REQUEST_IN15    (0),
		.ADAPT_RESET_REQUEST       (0)
	) rst_controller (
		.reset_in0      (~dma_mem_inst_clk_125_clk_in_reset_bfm_reset_reset), // reset_in0.reset
		.clk            (dma_mem_inst_sdram_afi_clk_clk),                     //       clk.clk
		.reset_out      (rst_controller_reset_out_reset),                     // reset_out.reset
		.reset_req      (),                                                   // (terminated)
		.reset_req_in0  (1'b0),                                               // (terminated)
		.reset_in1      (1'b0),                                               // (terminated)
		.reset_req_in1  (1'b0),                                               // (terminated)
		.reset_in2      (1'b0),                                               // (terminated)
		.reset_req_in2  (1'b0),                                               // (terminated)
		.reset_in3      (1'b0),                                               // (terminated)
		.reset_req_in3  (1'b0),                                               // (terminated)
		.reset_in4      (1'b0),                                               // (terminated)
		.reset_req_in4  (1'b0),                                               // (terminated)
		.reset_in5      (1'b0),                                               // (terminated)
		.reset_req_in5  (1'b0),                                               // (terminated)
		.reset_in6      (1'b0),                                               // (terminated)
		.reset_req_in6  (1'b0),                                               // (terminated)
		.reset_in7      (1'b0),                                               // (terminated)
		.reset_req_in7  (1'b0),                                               // (terminated)
		.reset_in8      (1'b0),                                               // (terminated)
		.reset_req_in8  (1'b0),                                               // (terminated)
		.reset_in9      (1'b0),                                               // (terminated)
		.reset_req_in9  (1'b0),                                               // (terminated)
		.reset_in10     (1'b0),                                               // (terminated)
		.reset_req_in10 (1'b0),                                               // (terminated)
		.reset_in11     (1'b0),                                               // (terminated)
		.reset_req_in11 (1'b0),                                               // (terminated)
		.reset_in12     (1'b0),                                               // (terminated)
		.reset_req_in12 (1'b0),                                               // (terminated)
		.reset_in13     (1'b0),                                               // (terminated)
		.reset_req_in13 (1'b0),                                               // (terminated)
		.reset_in14     (1'b0),                                               // (terminated)
		.reset_req_in14 (1'b0),                                               // (terminated)
		.reset_in15     (1'b0),                                               // (terminated)
		.reset_req_in15 (1'b0)                                                // (terminated)
	);

endmodule
