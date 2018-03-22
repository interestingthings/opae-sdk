// Created by altera_lib_mf.pl from altera_mf.v

/*verilator lint_off CASEX*/
/*verilator lint_off COMBDLY*/
/*verilator lint_off INITIALDLY*/
/*verilator lint_off LITENDIAN*/
/*verilator lint_off MULTIDRIVEN*/
/*verilator lint_off UNOPTFLAT*/
/*verilator lint_off BLKANDNBLK*/
module    sld_virtual_jtag_basic    (
    jtag_state_sdr,
    jtag_state_sirs,
    ir_out,
    jtag_state_sir,
    jtag_state_cdr,
    jtag_state_e2dr,
    tms,
    jtag_state_sdrs,
    jtag_state_tlr,
    ir_in,
    virtual_state_sdr,
    tdi,
    jtag_state_uir,
    jtag_state_cir,
    virtual_state_cdr,
    virtual_state_uir,
    virtual_state_e2dr,
    jtag_state_e2ir,
    virtual_state_cir,
    jtag_state_pir,
    jtag_state_udr,
    virtual_state_udr,
    tdo,
    jtag_state_e1dr,
    jtag_state_rti,
    virtual_state_pdr,
    virtual_state_e1dr,
    jtag_state_e1ir,
    jtag_state_pdr,
    tck);

    parameter    lpm_hint    =    "UNUSED";
    parameter    sld_sim_action    =    "UNUSED";
    parameter    sld_instance_index    =    0;
    parameter    sld_ir_width    =    1;
    parameter    sld_sim_n_scan    =    0;
    parameter    sld_mfg_id    =    0;
    parameter    sld_version    =    0;
    parameter    sld_type_id    =    0;
    parameter    lpm_type    =    "sld_virtual_jtag_basic";
    parameter    sld_auto_instance_index    =    "NO";
    parameter    sld_sim_total_length    =    0;


    output    jtag_state_sdr;
    output    jtag_state_sirs;
    input    [sld_ir_width-1:0]    ir_out;
    output    jtag_state_sir;
    output    jtag_state_cdr;
    output    jtag_state_e2dr;
    output    tms;
    output    jtag_state_sdrs;
    output    jtag_state_tlr;
    output    [sld_ir_width-1:0]    ir_in;
    output    virtual_state_sdr;
    output    tdi;
    output    jtag_state_uir;
    output    jtag_state_cir;
    output    virtual_state_cdr;
    output    virtual_state_uir;
    output    virtual_state_e2dr;
    output    jtag_state_e2ir;
    output    virtual_state_cir;
    output    jtag_state_pir;
    output    jtag_state_udr;
    output    virtual_state_udr;
    input    tdo;
    output    jtag_state_e1dr;
    output    jtag_state_rti;
    output    virtual_state_pdr;
    output    virtual_state_e1dr;
    output    jtag_state_e1ir;
    output    jtag_state_pdr;
    output    tck;

endmodule //sld_virtual_jtag_basic

