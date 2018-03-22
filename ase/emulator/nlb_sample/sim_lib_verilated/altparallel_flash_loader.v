// Created by altera_lib_mf.pl from altera_mf.v

/*verilator lint_off CASEX*/
/*verilator lint_off COMBDLY*/
/*verilator lint_off INITIALDLY*/
/*verilator lint_off LITENDIAN*/
/*verilator lint_off MULTIDRIVEN*/
/*verilator lint_off UNOPTFLAT*/
/*verilator lint_off BLKANDNBLK*/
module    altparallel_flash_loader    (
    flash_nce,
    fpga_data,
    fpga_dclk,
    fpga_nstatus,
    flash_ale,
    pfl_clk,
    fpga_nconfig,
    flash_io2,
    flash_sck,
    flash_noe,
    flash_nwe,
    pfl_watchdog_error,
    pfl_reset_watchdog,
    fpga_conf_done,
    flash_rdy,
    pfl_flash_access_granted,
    pfl_nreconfigure,
    flash_cle,
    flash_nreset,
    flash_io0,
    pfl_nreset,
    flash_data,
    flash_io1,
    flash_nadv,
    flash_clk,
    flash_io3,
    flash_io,
    flash_addr,
    pfl_flash_access_request,
    flash_ncs,
    fpga_pgm);

    parameter    FLASH_STATIC_WAIT_WIDTH    =    15;
    parameter    EXTRA_ADDR_BYTE    =    0;
    parameter    FEATURES_CFG    =    1;
    parameter    PAGE_CLK_DIVISOR    =    1;
    parameter    BURST_MODE_SPANSION    =    0;
    parameter    ENHANCED_FLASH_PROGRAMMING    =    0;
    parameter    FLASH_ECC_CHECKBOX    =    0;
    parameter    FLASH_NRESET_COUNTER    =    1;
    parameter    PAGE_MODE    =    0;
    parameter    NRB_ADDR    =    65667072;
    parameter    BURST_MODE    =    0;
    parameter    SAFE_MODE_REVERT_ADDR    =    0;
    parameter    US_UNIT_COUNTER    =    1;
    parameter    FIFO_SIZE    =    16;
    parameter    CONF_DATA_WIDTH    =    1;
    parameter    CONF_WAIT_TIMER_WIDTH    =    16;
    parameter    NFLASH_MFC    =    "NUMONYX";
    parameter    OPTION_BITS_START_ADDRESS    =    0;
    parameter    SAFE_MODE_RETRY    =    1;
    parameter    DCLK_DIVISOR    =    1;
    parameter    FLASH_TYPE    =    "CFI_FLASH";
    parameter    N_FLASH    =    1;
    parameter    BURST_MODE_LATENCY_COUNT    =    4;
    parameter    QSPI_DATA_DELAY    =    0;
    parameter    FLASH_BURST_EXTRA_CYCLE    =    0;
    parameter    TRISTATE_CHECKBOX    =    0;
    parameter    QFLASH_MFC    =    "ALTERA";
    parameter    FEATURES_PGM    =    1;
    parameter    QFLASH_FAST_SPEED    =    0;
    parameter    DISABLE_CRC_CHECKBOX    =    0;
    parameter    FLASH_DATA_WIDTH    =    16;
    parameter    RSU_WATCHDOG_COUNTER    =    100000000;
    parameter    PFL_RSU_WATCHDOG_ENABLED    =    0;
    parameter    SAFE_MODE_HALT    =    0;
    parameter    ADDR_WIDTH    =    20;
    parameter    NAND_SIZE    =    67108864;
    parameter    NORMAL_MODE    =    1;
    parameter    FLASH_NRESET_CHECKBOX    =    0;
    parameter    SAFE_MODE_REVERT    =    0;
    parameter    LPM_TYPE    =    "ALTPARALLEL_FLASH_LOADER";
    parameter    AUTO_RESTART    =    "OFF";
    parameter    DCLK_CREATE_DELAY    =    0;
    parameter    CLK_DIVISOR    =    1;
    parameter    BURST_MODE_INTEL    =    0;
    parameter    BURST_MODE_NUMONYX    =    0;
    parameter    DECOMPRESSOR_MODE    =    "NONE";
    parameter    QSPI_DATA_DELAY_COUNT    =    1;

    parameter    PFL_QUAD_IO_FLASH_IR_BITS    =    8;
    parameter    PFL_CFI_FLASH_IR_BITS    =    5;
    parameter    PFL_NAND_FLASH_IR_BITS    =    4;
    parameter    N_FLASH_BITS    =    4;

    output    [N_FLASH-1:0]    flash_nce;
    output    [CONF_DATA_WIDTH-1:0]    fpga_data;
    output    fpga_dclk;
    input    fpga_nstatus;
    output    flash_ale;
    input    pfl_clk;
    output    fpga_nconfig;
    inout    [N_FLASH-1:0]    flash_io2;
    output    [N_FLASH-1:0]    flash_sck;
    output    flash_noe;
    output    flash_nwe;
    output    pfl_watchdog_error;
    input    pfl_reset_watchdog;
    input    fpga_conf_done;
    input    flash_rdy;
    input    pfl_flash_access_granted;
    input    pfl_nreconfigure;
    output    flash_cle;
    output    flash_nreset;
    inout    [N_FLASH-1:0]    flash_io0;
    input    pfl_nreset;
    inout    [FLASH_DATA_WIDTH-1:0]    flash_data;
    inout    [N_FLASH-1:0]    flash_io1;
    output    flash_nadv;
    output    flash_clk;
    inout    [N_FLASH-1:0]    flash_io3;
    inout    [7:0]    flash_io;
    output    [ADDR_WIDTH-1:0]    flash_addr;
    output    pfl_flash_access_request;
    output    [N_FLASH-1:0]    flash_ncs;
    input    [2:0]    fpga_pgm;

endmodule //altparallel_flash_loader

