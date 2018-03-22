// Created by altera_lib_mf.pl from altera_mf.v
// END OF MODULE

/*verilator lint_off CASEX*/
/*verilator lint_off COMBDLY*/
/*verilator lint_off INITIALDLY*/
/*verilator lint_off LITENDIAN*/
/*verilator lint_off MULTIDRIVEN*/
/*verilator lint_off UNOPTFLAT*/
/*verilator lint_off BLKANDNBLK*/
module    sld_signaltap    (
    jtag_state_sdr,
    ir_in,
    acq_trigger_out,
    gnd,
    jtag_state_cir,
    jtag_state_e2ir,
    jtag_state_pir,
    jtag_state_udr,
    vcc,
    jtag_state_e1dr,
    jtag_state_rti,
    jtag_state_e1ir,
    jtag_state_pdr,
    acq_clk,
    clr,
    trigger_in,
    ir_out,
    jtag_state_sirs,
    jtag_state_cdr,
    jtag_state_sir,
    jtag_state_e2dr,
    tms,
    jtag_state_tlr,
    jtag_state_sdrs,
    tdi,
    jtag_state_uir,
    acq_trigger_in,
    trigger_out,
    storage_enable,
    acq_data_out,
    acq_storage_qualifier_in,
    acq_data_in,
    vir_tdi,
    tdo,
    crc,
    clrn,
    raw_tck,
    irq,
    usr1,
    ena);

    parameter    SLD_USE_JTAG_SIGNAL_ADAPTER    =    1;
    parameter    SLD_CURRENT_RESOURCE_WIDTH    =    0;
    parameter    SLD_INVERSION_MASK    =    "0";
    parameter    SLD_POWER_UP_TRIGGER    =    0;
    parameter    SLD_ADVANCED_TRIGGER_6    =    "NONE";
    parameter    SLD_ADVANCED_TRIGGER_9    =    "NONE";
    parameter    SLD_RAM_PIPELINE    =    0;
    parameter    SLD_ADVANCED_TRIGGER_7    =    "NONE";
    parameter    SLD_HPS_EVENT_ENABLED    =    0;
    parameter    SLD_STORAGE_QUALIFIER_ADVANCED_CONDITION_ENTITY    =    "basic";
    parameter    SLD_STORAGE_QUALIFIER_GAP_RECORD    =    0;
    parameter    SLD_SECTION_ID    =    "hdl_signaltap_0";
    parameter    SLD_INCREMENTAL_ROUTING    =    0;
    parameter    SLD_STORAGE_QUALIFIER_PIPELINE    =    0;
    parameter    SLD_TRIGGER_IN_ENABLED    =    0;
    parameter    SLD_STATE_BITS    =    11;
    parameter    SLD_HPS_EVENT_ID    =    0;
    parameter    SLD_CREATE_MONITOR_INTERFACE    =    0;
    parameter    SLD_STATE_FLOW_USE_GENERATED    =    0;
    parameter    SLD_INVERSION_MASK_LENGTH    =    1;
    parameter    SLD_DATA_BITS    =    1;
    parameter    SLD_COUNTER_PIPELINE    =    0;
    parameter    SLD_BUFFER_FULL_STOP    =    1;
    parameter    SLD_STORAGE_QUALIFIER_INVERSION_MASK_LENGTH    =    0;
    parameter    SLD_ATTRIBUTE_MEM_MODE    =    "OFF";
    parameter    SLD_STORAGE_QUALIFIER_MODE    =    "OFF";
    parameter    SLD_STATE_FLOW_MGR_ENTITY    =    "state_flow_mgr_entity.vhd";
    parameter    SLD_HPS_TRIGGER_IN_ENABLED    =    0;
    parameter    SLD_ADVANCED_TRIGGER_5    =    "NONE";
    parameter    SLD_NODE_CRC_LOWORD    =    50132;
    parameter    SLD_TRIGGER_BITS    =    1;
    parameter    SLD_STORAGE_QUALIFIER_BITS    =    1;
    parameter    SLD_TRIGGER_PIPELINE    =    0;
    parameter    SLD_HPS_TRIGGER_OUT_ENABLED    =    0;
    parameter    SLD_ADVANCED_TRIGGER_10    =    "NONE";
    parameter    SLD_MEM_ADDRESS_BITS    =    7;
    parameter    SLD_ADVANCED_TRIGGER_ENTITY    =    "basic";
    parameter    SLD_ADVANCED_TRIGGER_4    =    "NONE";
    parameter    SLD_ADVANCED_TRIGGER_8    =    "NONE";
    parameter    SLD_TRIGGER_LEVEL    =    10;
    parameter    SLD_RAM_BLOCK_TYPE    =    "AUTO";
    parameter    SLD_ADVANCED_TRIGGER_2    =    "NONE";
    parameter    SLD_ADVANCED_TRIGGER_1    =    "NONE";
    parameter    SLD_DATA_BIT_CNTR_BITS    =    4;
    parameter    SLD_SAMPLE_DEPTH    =    16;
    parameter    lpm_type    =    "sld_signaltap";
    parameter    SLD_NODE_CRC_BITS    =    32;
    parameter    SLD_ENABLE_ADVANCED_TRIGGER    =    0;
    parameter    SLD_SEGMENT_SIZE    =    0;
    parameter    SLD_NODE_INFO    =    0;
    parameter    SLD_STORAGE_QUALIFIER_ENABLE_ADVANCED_CONDITION    =    0;
    parameter    SLD_NODE_CRC_HIWORD    =    41394;
    parameter    SLD_TRIGGER_LEVEL_PIPELINE    =    1;
    parameter    SLD_ADVANCED_TRIGGER_3    =    "NONE";

    parameter    SLD_IR_BITS    =    10;

    input    jtag_state_sdr;
    input    [SLD_IR_BITS-1:0]    ir_in;
    output    [SLD_TRIGGER_BITS-1:0]    acq_trigger_out;
    output    gnd;
    input    jtag_state_cir;
    input    jtag_state_e2ir;
    input    jtag_state_pir;
    input    jtag_state_udr;
    output    vcc;
    input    jtag_state_e1dr;
    input    jtag_state_rti;
    input    jtag_state_e1ir;
    input    jtag_state_pdr;
    input    acq_clk;
    input    clr;
    input    trigger_in;
    output    [SLD_IR_BITS-1:0]    ir_out;
    input    jtag_state_sirs;
    input    jtag_state_cdr;
    input    jtag_state_sir;
    input    jtag_state_e2dr;
    input    tms;
    input    jtag_state_tlr;
    input    jtag_state_sdrs;
    input    tdi;
    input    jtag_state_uir;
    input    [SLD_TRIGGER_BITS-1:0]    acq_trigger_in;
    output    trigger_out;
    input    storage_enable;
    output    [SLD_DATA_BITS-1:0]    acq_data_out;
    input    [SLD_STORAGE_QUALIFIER_BITS-1:0]    acq_storage_qualifier_in;
    input    [SLD_DATA_BITS-1:0]    acq_data_in;
    input    vir_tdi;
    output    tdo;
    input    [SLD_NODE_CRC_BITS-1:0]    crc;
    input    clrn;
    input    raw_tck;
    output    irq;
    input    usr1;
    input    ena;

endmodule //sld_signaltap

