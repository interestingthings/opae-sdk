// Created by altera_lib_mf.pl from altera_mf.v

/*verilator lint_off CASEX*/
/*verilator lint_off COMBDLY*/
/*verilator lint_off INITIALDLY*/
/*verilator lint_off LITENDIAN*/
/*verilator lint_off MULTIDRIVEN*/
/*verilator lint_off UNOPTFLAT*/
/*verilator lint_off BLKANDNBLK*/
module    altserial_flash_loader    (
    data_in,
    noe,
    asmi_access_granted,
    data_out,
    data_oe,
    sdoin,
    asmi_access_request,
    data0out,
    scein,
    dclkin);

    parameter    lpm_hint    =    "UNUSED";
    parameter    enhanced_mode    =    0;
    parameter    intended_device_family    =    "Cyclone";
    parameter    enable_shared_access    =    "OFF";
    parameter    enable_quad_spi_support    =    0;
    parameter    ncso_width    =    1;
    parameter    lpm_type    =    "ALTSERIAL_FLASH_LOADER";


    input    [3:0]    data_in;
    input    noe;
    input    asmi_access_granted;
    output    [3:0]    data_out;
    input    [3:0]    data_oe;
    input    sdoin;
    output    asmi_access_request;
    output    data0out;
    input    [ncso_width-1:0]    scein;
    input    dclkin;

endmodule //altserial_flash_loader

