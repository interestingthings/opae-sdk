// Created by altera_lib_mf.pl from altera_mf.v

/*verilator lint_off CASEX*/
/*verilator lint_off COMBDLY*/
/*verilator lint_off INITIALDLY*/
/*verilator lint_off LITENDIAN*/
/*verilator lint_off MULTIDRIVEN*/
/*verilator lint_off UNOPTFLAT*/
/*verilator lint_off BLKANDNBLK*/
module    alt_fault_injection    (
    system_error,
    pr_ready,
    system_reset,
    pr_request,
    emr_data,
    error_scrubbed,
    user_intosc,
    pr_ext_request,
    pr_error,
    emr_valid,
    crc_error,
    error_injected,
    pr_data,
    pr_clk,
    pr_done);

    parameter    CRC_OSC_DIVIDER    =    8;
    parameter    ENABLE_EMR_SHARE    =    "NO";
    parameter    INTENDED_DEVICE_FAMILY    =    "Stratix V";
    parameter    TEST_LOGIC_TYPE    =    "OR";
    parameter    ENABLE_INTOSC_SHARE    =    "NO";
    parameter    EMR_WIDTH    =    67;
    parameter    INIT_EMR    =    "NO";
    parameter    LPM_TYPE    =    "ALT_FAULT_INJECTION";
    parameter    EMR_ARRAY_SIZE    =    128;
    parameter    INSTANTIATE_PR_BLOCK    =    1;
    parameter    DATA_REG_WIDTH    =    16;


    input    system_error;
    input    pr_ready;
    output    system_reset;
    output    pr_request;
    input    [EMR_WIDTH-1:0]    emr_data;
    output    error_scrubbed;
    output    user_intosc;
    input    pr_ext_request;
    input    pr_error;
    input    emr_valid;
    input    crc_error;
    output    error_injected;
    output    [DATA_REG_WIDTH-1:0]    pr_data;
    output    pr_clk;
    input    pr_done;

endmodule //alt_fault_injection

