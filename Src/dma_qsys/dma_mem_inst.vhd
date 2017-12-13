	component dma_mem is
		port (
			clk_125_clk_in_clk           : in    std_logic                      := 'X';             -- clk
			clk_125_clk_in_reset_reset_n : in    std_logic                      := 'X';             -- reset_n
			ddr3_top_memory_mem_a        : out   std_logic_vector(13 downto 0);                     -- mem_a
			ddr3_top_memory_mem_ba       : out   std_logic_vector(2 downto 0);                      -- mem_ba
			ddr3_top_memory_mem_ck       : out   std_logic_vector(0 downto 0);                      -- mem_ck
			ddr3_top_memory_mem_ck_n     : out   std_logic_vector(0 downto 0);                      -- mem_ck_n
			ddr3_top_memory_mem_cke      : out   std_logic_vector(0 downto 0);                      -- mem_cke
			ddr3_top_memory_mem_cs_n     : out   std_logic_vector(0 downto 0);                      -- mem_cs_n
			ddr3_top_memory_mem_dm       : out   std_logic_vector(7 downto 0);                      -- mem_dm
			ddr3_top_memory_mem_ras_n    : out   std_logic_vector(0 downto 0);                      -- mem_ras_n
			ddr3_top_memory_mem_cas_n    : out   std_logic_vector(0 downto 0);                      -- mem_cas_n
			ddr3_top_memory_mem_we_n     : out   std_logic_vector(0 downto 0);                      -- mem_we_n
			ddr3_top_memory_mem_reset_n  : out   std_logic;                                         -- mem_reset_n
			ddr3_top_memory_mem_dq       : inout std_logic_vector(63 downto 0)  := (others => 'X'); -- mem_dq
			ddr3_top_memory_mem_dqs      : inout std_logic_vector(7 downto 0)   := (others => 'X'); -- mem_dqs
			ddr3_top_memory_mem_dqs_n    : inout std_logic_vector(7 downto 0)   := (others => 'X'); -- mem_dqs_n
			ddr3_top_memory_mem_odt      : out   std_logic_vector(0 downto 0);                      -- mem_odt
			ddr3_top_oct_rzqin           : in    std_logic                      := 'X';             -- rzqin
			sdram_afi_clk_clk            : out   std_logic;                                         -- clk
			sdram_avl_waitrequest_n      : out   std_logic;                                         -- waitrequest_n
			sdram_avl_beginbursttransfer : in    std_logic                      := 'X';             -- beginbursttransfer
			sdram_avl_address            : in    std_logic_vector(24 downto 0)  := (others => 'X'); -- address
			sdram_avl_readdatavalid      : out   std_logic;                                         -- readdatavalid
			sdram_avl_readdata           : out   std_logic_vector(255 downto 0);                    -- readdata
			sdram_avl_writedata          : in    std_logic_vector(255 downto 0) := (others => 'X'); -- writedata
			sdram_avl_read               : in    std_logic                      := 'X';             -- read
			sdram_avl_write              : in    std_logic                      := 'X';             -- write
			sdram_avl_burstcount         : in    std_logic_vector(8 downto 0)   := (others => 'X')  -- burstcount
		);
	end component dma_mem;

	u0 : component dma_mem
		port map (
			clk_125_clk_in_clk           => CONNECTED_TO_clk_125_clk_in_clk,           --       clk_125_clk_in.clk
			clk_125_clk_in_reset_reset_n => CONNECTED_TO_clk_125_clk_in_reset_reset_n, -- clk_125_clk_in_reset.reset_n
			ddr3_top_memory_mem_a        => CONNECTED_TO_ddr3_top_memory_mem_a,        --      ddr3_top_memory.mem_a
			ddr3_top_memory_mem_ba       => CONNECTED_TO_ddr3_top_memory_mem_ba,       --                     .mem_ba
			ddr3_top_memory_mem_ck       => CONNECTED_TO_ddr3_top_memory_mem_ck,       --                     .mem_ck
			ddr3_top_memory_mem_ck_n     => CONNECTED_TO_ddr3_top_memory_mem_ck_n,     --                     .mem_ck_n
			ddr3_top_memory_mem_cke      => CONNECTED_TO_ddr3_top_memory_mem_cke,      --                     .mem_cke
			ddr3_top_memory_mem_cs_n     => CONNECTED_TO_ddr3_top_memory_mem_cs_n,     --                     .mem_cs_n
			ddr3_top_memory_mem_dm       => CONNECTED_TO_ddr3_top_memory_mem_dm,       --                     .mem_dm
			ddr3_top_memory_mem_ras_n    => CONNECTED_TO_ddr3_top_memory_mem_ras_n,    --                     .mem_ras_n
			ddr3_top_memory_mem_cas_n    => CONNECTED_TO_ddr3_top_memory_mem_cas_n,    --                     .mem_cas_n
			ddr3_top_memory_mem_we_n     => CONNECTED_TO_ddr3_top_memory_mem_we_n,     --                     .mem_we_n
			ddr3_top_memory_mem_reset_n  => CONNECTED_TO_ddr3_top_memory_mem_reset_n,  --                     .mem_reset_n
			ddr3_top_memory_mem_dq       => CONNECTED_TO_ddr3_top_memory_mem_dq,       --                     .mem_dq
			ddr3_top_memory_mem_dqs      => CONNECTED_TO_ddr3_top_memory_mem_dqs,      --                     .mem_dqs
			ddr3_top_memory_mem_dqs_n    => CONNECTED_TO_ddr3_top_memory_mem_dqs_n,    --                     .mem_dqs_n
			ddr3_top_memory_mem_odt      => CONNECTED_TO_ddr3_top_memory_mem_odt,      --                     .mem_odt
			ddr3_top_oct_rzqin           => CONNECTED_TO_ddr3_top_oct_rzqin,           --         ddr3_top_oct.rzqin
			sdram_afi_clk_clk            => CONNECTED_TO_sdram_afi_clk_clk,            --        sdram_afi_clk.clk
			sdram_avl_waitrequest_n      => CONNECTED_TO_sdram_avl_waitrequest_n,      --            sdram_avl.waitrequest_n
			sdram_avl_beginbursttransfer => CONNECTED_TO_sdram_avl_beginbursttransfer, --                     .beginbursttransfer
			sdram_avl_address            => CONNECTED_TO_sdram_avl_address,            --                     .address
			sdram_avl_readdatavalid      => CONNECTED_TO_sdram_avl_readdatavalid,      --                     .readdatavalid
			sdram_avl_readdata           => CONNECTED_TO_sdram_avl_readdata,           --                     .readdata
			sdram_avl_writedata          => CONNECTED_TO_sdram_avl_writedata,          --                     .writedata
			sdram_avl_read               => CONNECTED_TO_sdram_avl_read,               --                     .read
			sdram_avl_write              => CONNECTED_TO_sdram_avl_write,              --                     .write
			sdram_avl_burstcount         => CONNECTED_TO_sdram_avl_burstcount          --                     .burstcount
		);

