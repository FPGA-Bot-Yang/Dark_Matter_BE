
# (C) 2001-2017 Altera Corporation. All rights reserved.
# Your use of Altera Corporation's design tools, logic functions and 
# other software and tools, and its AMPP partner logic functions, and 
# any output files any of the foregoing (including device programming 
# or simulation files), and any associated documentation or information 
# are expressly subject to the terms and conditions of the Altera 
# Program License Subscription Agreement, Altera MegaCore Function 
# License Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Altera and sold by Altera 
# or its authorized distributors. Please refer to the applicable 
# agreement for further details.

# ACDS 14.1 186 win32 2017.06.06.18:08:06

# ----------------------------------------
# vcs - auto-generated simulation script

# ----------------------------------------
# initialize variables
TOP_LEVEL_NAME="dma_mem_tb"
QSYS_SIMDIR="./../../"
QUARTUS_INSTALL_DIR="D:\Program_Files\altera\14.1\quartus/"
SKIP_FILE_COPY=0
SKIP_ELAB=0
SKIP_SIM=0
USER_DEFINED_ELAB_OPTIONS=""
USER_DEFINED_SIM_OPTIONS="+vcs+finish+100"
# ----------------------------------------
# overwrite variables - DO NOT MODIFY!
# This block evaluates each command line argument, typically used for 
# overwriting variables. An example usage:
#   sh <simulator>_setup.sh SKIP_ELAB=1 SKIP_SIM=1
for expression in "$@"; do
  eval $expression
  if [ $? -ne 0 ]; then
    echo "Error: This command line argument, \"$expression\", is/has an invalid expression." >&2
    exit $?
  fi
done

# ----------------------------------------
# initialize simulation properties - DO NOT MODIFY!
ELAB_OPTIONS=""
SIM_OPTIONS=""
if [[ `vcs -platform` != *"amd64"* ]]; then
  :
else
  :
fi

# ----------------------------------------
# copy RAM/ROM files to simulation directory
if [ $SKIP_FILE_COPY -eq 0 ]; then
  cp -f $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/dma_mem_sdram_s0_sequencer_mem.hex ./
  cp -f $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/dma_mem_sdram_s0_AC_ROM.hex ./
  cp -f $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/dma_mem_sdram_s0_inst_ROM.hex ./
fi

vcs -lca -timescale=1ps/1ps -sverilog +verilog2001ext+.v -ntb_opts dtm $ELAB_OPTIONS $USER_DEFINED_ELAB_OPTIONS \
  -v $QUARTUS_INSTALL_DIR/../../../../program_files/altera/14.1/quartus/eda/sim_lib/altera_primitives.v \
  -v $QUARTUS_INSTALL_DIR/../../../../program_files/altera/14.1/quartus/eda/sim_lib/220model.v \
  -v $QUARTUS_INSTALL_DIR/../../../../program_files/altera/14.1/quartus/eda/sim_lib/sgate.v \
  -v $QUARTUS_INSTALL_DIR/../../../../program_files/altera/14.1/quartus/eda/sim_lib/altera_mf.v \
  $QUARTUS_INSTALL_DIR/../../../../program_files/altera/14.1/quartus/eda/sim_lib/altera_lnsim.sv \
  -v $QUARTUS_INSTALL_DIR/../../../../program_files/altera/14.1/quartus/eda/sim_lib/synopsys/cyclonev_atoms_ncrypt.v \
  -v $QUARTUS_INSTALL_DIR/../../../../program_files/altera/14.1/quartus/eda/sim_lib/synopsys/cyclonev_hmi_atoms_ncrypt.v \
  -v $QUARTUS_INSTALL_DIR/../../../../program_files/altera/14.1/quartus/eda/sim_lib/cyclonev_atoms.v \
  -v $QUARTUS_INSTALL_DIR/../../../../program_files/altera/14.1/quartus/eda/sim_lib/synopsys/cyclonev_hssi_atoms_ncrypt.v \
  -v $QUARTUS_INSTALL_DIR/../../../../program_files/altera/14.1/quartus/eda/sim_lib/cyclonev_hssi_atoms.v \
  -v $QUARTUS_INSTALL_DIR/../../../../program_files/altera/14.1/quartus/eda/sim_lib/synopsys/cyclonev_pcie_hip_atoms_ncrypt.v \
  -v $QUARTUS_INSTALL_DIR/../../../../program_files/altera/14.1/quartus/eda/sim_lib/cyclonev_pcie_hip_atoms.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/verbosity_pkg.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/avalon_mm_pkg.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/avalon_utilities_pkg.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/alt_mem_ddrx_mm_st_converter.v \
  \"+incdir+$QSYS_SIMDIR/dma_mem_tb/simulation/submodules/\" $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/alt_mem_ddrx_addr_cmd.v \
  \"+incdir+$QSYS_SIMDIR/dma_mem_tb/simulation/submodules/\" $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/alt_mem_ddrx_addr_cmd_wrap.v \
  \"+incdir+$QSYS_SIMDIR/dma_mem_tb/simulation/submodules/\" $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/alt_mem_ddrx_ddr2_odt_gen.v \
  \"+incdir+$QSYS_SIMDIR/dma_mem_tb/simulation/submodules/\" $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/alt_mem_ddrx_ddr3_odt_gen.v \
  \"+incdir+$QSYS_SIMDIR/dma_mem_tb/simulation/submodules/\" $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/alt_mem_ddrx_lpddr2_addr_cmd.v \
  \"+incdir+$QSYS_SIMDIR/dma_mem_tb/simulation/submodules/\" $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/alt_mem_ddrx_odt_gen.v \
  \"+incdir+$QSYS_SIMDIR/dma_mem_tb/simulation/submodules/\" $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/alt_mem_ddrx_rdwr_data_tmg.v \
  \"+incdir+$QSYS_SIMDIR/dma_mem_tb/simulation/submodules/\" $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/alt_mem_ddrx_arbiter.v \
  \"+incdir+$QSYS_SIMDIR/dma_mem_tb/simulation/submodules/\" $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/alt_mem_ddrx_burst_gen.v \
  \"+incdir+$QSYS_SIMDIR/dma_mem_tb/simulation/submodules/\" $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/alt_mem_ddrx_cmd_gen.v \
  \"+incdir+$QSYS_SIMDIR/dma_mem_tb/simulation/submodules/\" $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/alt_mem_ddrx_csr.v \
  \"+incdir+$QSYS_SIMDIR/dma_mem_tb/simulation/submodules/\" $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/alt_mem_ddrx_buffer.v \
  \"+incdir+$QSYS_SIMDIR/dma_mem_tb/simulation/submodules/\" $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/alt_mem_ddrx_buffer_manager.v \
  \"+incdir+$QSYS_SIMDIR/dma_mem_tb/simulation/submodules/\" $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/alt_mem_ddrx_burst_tracking.v \
  \"+incdir+$QSYS_SIMDIR/dma_mem_tb/simulation/submodules/\" $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/alt_mem_ddrx_dataid_manager.v \
  \"+incdir+$QSYS_SIMDIR/dma_mem_tb/simulation/submodules/\" $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/alt_mem_ddrx_fifo.v \
  \"+incdir+$QSYS_SIMDIR/dma_mem_tb/simulation/submodules/\" $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/alt_mem_ddrx_list.v \
  \"+incdir+$QSYS_SIMDIR/dma_mem_tb/simulation/submodules/\" $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/alt_mem_ddrx_rdata_path.v \
  \"+incdir+$QSYS_SIMDIR/dma_mem_tb/simulation/submodules/\" $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/alt_mem_ddrx_wdata_path.v \
  \"+incdir+$QSYS_SIMDIR/dma_mem_tb/simulation/submodules/\" $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/alt_mem_ddrx_ecc_decoder.v \
  \"+incdir+$QSYS_SIMDIR/dma_mem_tb/simulation/submodules/\" $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/alt_mem_ddrx_ecc_decoder_32_syn.v \
  \"+incdir+$QSYS_SIMDIR/dma_mem_tb/simulation/submodules/\" $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/alt_mem_ddrx_ecc_decoder_64_syn.v \
  \"+incdir+$QSYS_SIMDIR/dma_mem_tb/simulation/submodules/\" $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/alt_mem_ddrx_ecc_encoder.v \
  \"+incdir+$QSYS_SIMDIR/dma_mem_tb/simulation/submodules/\" $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/alt_mem_ddrx_ecc_encoder_32_syn.v \
  \"+incdir+$QSYS_SIMDIR/dma_mem_tb/simulation/submodules/\" $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/alt_mem_ddrx_ecc_encoder_64_syn.v \
  \"+incdir+$QSYS_SIMDIR/dma_mem_tb/simulation/submodules/\" $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/alt_mem_ddrx_ecc_encoder_decoder_wrapper.v \
  \"+incdir+$QSYS_SIMDIR/dma_mem_tb/simulation/submodules/\" $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/alt_mem_ddrx_axi_st_converter.v \
  \"+incdir+$QSYS_SIMDIR/dma_mem_tb/simulation/submodules/\" $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/alt_mem_ddrx_input_if.v \
  \"+incdir+$QSYS_SIMDIR/dma_mem_tb/simulation/submodules/\" $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/alt_mem_ddrx_rank_timer.v \
  \"+incdir+$QSYS_SIMDIR/dma_mem_tb/simulation/submodules/\" $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/alt_mem_ddrx_sideband.v \
  \"+incdir+$QSYS_SIMDIR/dma_mem_tb/simulation/submodules/\" $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/alt_mem_ddrx_tbp.v \
  \"+incdir+$QSYS_SIMDIR/dma_mem_tb/simulation/submodules/\" $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/alt_mem_ddrx_timing_param.v \
  \"+incdir+$QSYS_SIMDIR/dma_mem_tb/simulation/submodules/\" $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/alt_mem_ddrx_controller.v \
  \"+incdir+$QSYS_SIMDIR/dma_mem_tb/simulation/submodules/\" $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/alt_mem_ddrx_controller_st_top.v \
  \"+incdir+$QSYS_SIMDIR/dma_mem_tb/simulation/submodules/\" $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/alt_mem_if_nextgen_ddr3_controller_core.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/altera_mem_if_dll_cyclonev.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/altera_mem_if_oct_cyclonev.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/dma_mem_sdram_c0.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/dma_mem_sdram_s0.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/altera_avalon_sc_fifo.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/altera_mem_if_sequencer_cpu_cv_sim_cpu_inst.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/altera_mem_if_sequencer_cpu_cv_sim_cpu_inst_test_bench.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/altera_mem_if_sequencer_mem_no_ifdef_params.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/altera_mem_if_sequencer_rst.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/altera_merlin_arbitrator.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/altera_merlin_burst_uncompressor.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/altera_merlin_master_agent.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/altera_merlin_master_translator.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/altera_merlin_slave_agent.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/altera_merlin_slave_translator.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/dma_mem_sdram_s0_irq_mapper.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/dma_mem_sdram_s0_mm_interconnect_0.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/dma_mem_sdram_s0_mm_interconnect_0_cmd_demux.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/dma_mem_sdram_s0_mm_interconnect_0_cmd_demux_001.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/dma_mem_sdram_s0_mm_interconnect_0_cmd_mux.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/dma_mem_sdram_s0_mm_interconnect_0_cmd_mux_003.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/dma_mem_sdram_s0_mm_interconnect_0_router.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/dma_mem_sdram_s0_mm_interconnect_0_router_001.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/dma_mem_sdram_s0_mm_interconnect_0_router_002.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/dma_mem_sdram_s0_mm_interconnect_0_router_005.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/dma_mem_sdram_s0_mm_interconnect_0_rsp_demux_003.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/dma_mem_sdram_s0_mm_interconnect_0_rsp_mux.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/dma_mem_sdram_s0_mm_interconnect_0_rsp_mux_001.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/rw_manager_ac_ROM_no_ifdef_params.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/rw_manager_ac_ROM_reg.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/rw_manager_bitcheck.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/rw_manager_core.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/rw_manager_datamux.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/rw_manager_data_broadcast.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/rw_manager_data_decoder.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/rw_manager_ddr3.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/rw_manager_di_buffer.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/rw_manager_di_buffer_wrap.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/rw_manager_dm_decoder.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/rw_manager_generic.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/rw_manager_inst_ROM_no_ifdef_params.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/rw_manager_inst_ROM_reg.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/rw_manager_jumplogic.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/rw_manager_lfsr12.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/rw_manager_lfsr36.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/rw_manager_lfsr72.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/rw_manager_pattern_fifo.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/rw_manager_ram.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/rw_manager_ram_csr.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/rw_manager_read_datapath.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/rw_manager_write_decoder.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/sequencer_data_mgr.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/sequencer_phy_mgr.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/sequencer_reg_file.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/sequencer_scc_acv_phase_decode.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/sequencer_scc_acv_wrapper.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/sequencer_scc_mgr.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/sequencer_scc_reg_file.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/sequencer_scc_siii_phase_decode.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/sequencer_scc_siii_wrapper.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/sequencer_scc_sv_phase_decode.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/sequencer_scc_sv_wrapper.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/afi_mux_ddr3_ddrx.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/dma_mem_sdram_p0_clock_pair_generator.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/dma_mem_sdram_p0_read_valid_selector.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/dma_mem_sdram_p0_addr_cmd_datapath.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/dma_mem_sdram_p0_reset.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/dma_mem_sdram_p0_acv_ldc.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/dma_mem_sdram_p0_memphy.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/dma_mem_sdram_p0_reset_sync.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/dma_mem_sdram_p0_new_io_pads.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/dma_mem_sdram_p0_fr_cycle_shifter.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/dma_mem_sdram_p0_fr_cycle_extender.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/dma_mem_sdram_p0_read_datapath.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/dma_mem_sdram_p0_write_datapath.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/dma_mem_sdram_p0_core_shadow_registers.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/dma_mem_sdram_p0_simple_ddio_out.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/dma_mem_sdram_p0_phy_csr.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/dma_mem_sdram_p0_iss_probe.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/dma_mem_sdram_p0_addr_cmd_pads.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/dma_mem_sdram_p0_flop_mem.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/dma_mem_sdram_p0.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/dma_mem_sdram_p0_altdqdqs.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/altdq_dqs2_acv_cyclonev.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/dma_mem_sdram_pll0.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/dma_mem_sdram.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/altera_reset_controller.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/altera_reset_synchronizer.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/alt_mem_if_ddr3_mem_model_top_ddr3_mem_if_dm_pins_en_mem_if_dqsn_en.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/alt_mem_if_common_ddr_mem_model_ddr3_mem_if_dm_pins_en_mem_if_dqsn_en.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/altera_avalon_mm_master_bfm.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/altera_conduit_bfm.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/altera_avalon_reset_source.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/altera_avalon_clock_source.sv \
  $QSYS_SIMDIR/dma_mem_tb/simulation/submodules/dma_mem.v \
  $QSYS_SIMDIR/dma_mem_tb/simulation/dma_mem_tb.v \
  -top $TOP_LEVEL_NAME
# ----------------------------------------
# simulate
if [ $SKIP_SIM -eq 0 ]; then
  ./simv $SIM_OPTIONS $USER_DEFINED_SIM_OPTIONS
fi
