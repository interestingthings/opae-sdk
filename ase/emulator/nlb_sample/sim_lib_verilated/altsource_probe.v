// Created by altera_lib_mf.pl from altera_mf.v

/*verilator lint_off CASEX*/
/*verilator lint_off COMBDLY*/
/*verilator lint_off INITIALDLY*/
/*verilator lint_off LITENDIAN*/
/*verilator lint_off MULTIDRIVEN*/
/*verilator lint_off UNOPTFLAT*/
/*verilator lint_off BLKANDNBLK*/
module    altsource_probe    (
    jtag_state_sdr,
    ir_in,
    jtag_state_cir,
    jtag_state_udr,
    jtag_state_e1dr,
    source_clk,
    clr,
    probe,
    source,
    ir_out,
    jtag_state_cdr,
    jtag_state_tlr,
    tdi,
    jtag_state_uir,
    source_ena,
    tdo,
    raw_tck,
    usr1,
    ena);

    parameter    lpm_hint    =    "UNUSED";
    parameter    sld_instance_index    =    0;
    parameter    source_initial_value    =    "0";
    parameter    sld_ir_width    =    4;
    parameter    probe_width    =    1;
    parameter    source_width    =    1;
    parameter    instance_id    =    "UNUSED";
    parameter    lpm_type    =    "altsource_probe";
    parameter    sld_auto_instance_index    =    "YES";
    parameter    SLD_NODE_INFO    =    4746752;
    parameter    enable_metastability    =    "NO";


    input    jtag_state_sdr;
    input    [sld_ir_width-1:0]    ir_in;
    input    jtag_state_cir;
    input    jtag_state_udr;
    input    jtag_state_e1dr;
    input    source_clk;
    input    clr;
    input    [probe_width-1:0]    probe;
    output    [source_width-1:0]    source;
    output    [sld_ir_width-1:0]    ir_out;
    input    jtag_state_cdr;
    input    jtag_state_tlr;
    input    tdi;
    input    jtag_state_uir;
    input    source_ena;
    output    tdo;
    input    raw_tck;
    input    usr1;
    input    ena;

endmodule //altsource_probe

