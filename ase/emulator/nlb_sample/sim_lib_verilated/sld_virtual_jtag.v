// Created by altera_lib_mf.pl from altera_mf.v
// END OF MODULE


//START_MODULE_NAME------------------------------------------------------------
// Module Name         : sld_virtual_jtag
//
// Description         : Simulation model for SLD_VIRTUAL_JTAG megafunction
//
// Limitation          : None
//
// Results expected    :
//
//
//END_MODULE_NAME--------------------------------------------------------------

// BEGINNING OF MODULE
`timescale 1 ps / 1 ps
`define IR_REGISTER_WIDTH 10;


// MODULE DECLARATION
/*verilator lint_off CASEX*/
/*verilator lint_off COMBDLY*/
/*verilator lint_off INITIALDLY*/
/*verilator lint_off LITENDIAN*/
/*verilator lint_off MULTIDRIVEN*/
/*verilator lint_off UNOPTFLAT*/
/*verilator lint_off BLKANDNBLK*/
module sld_virtual_jtag (tdo,ir_out,tck,tdi,ir_in,virtual_state_cdr,virtual_state_sdr,
                        virtual_state_e1dr,virtual_state_pdr,virtual_state_e2dr,
                        virtual_state_udr,virtual_state_cir,virtual_state_uir,
                        jtag_state_tlr,jtag_state_rti,jtag_state_sdrs,jtag_state_cdr,
                        jtag_state_sdr,jtag_state_e1dr,jtag_state_pdr,jtag_state_e2dr,
                        jtag_state_udr,jtag_state_sirs,jtag_state_cir,jtag_state_sir,
                        jtag_state_e1ir,jtag_state_pir,jtag_state_e2ir,jtag_state_uir,
                        tms);


    // GLOBAL PARAMETER DECLARATION
    parameter lpm_type = "SLD_VIRTUAL_JTAG"; // required by coding standard
    parameter lpm_hint = "SLD_VIRTUAL_JTAG"; // required by coding standard
    parameter sld_auto_instance_index = "NO"; //Yes if auto index is desired and no otherwise
    parameter sld_instance_index = 0; // index to be used if SLD_AUTO_INDEX is no
    parameter sld_ir_width = 1; //the width of the IR register
    parameter sld_sim_n_scan = 0; // the number of scans in the simulatiom parameters
    parameter sld_sim_total_length = 0; // The total bit width of all scan values
    parameter sld_sim_action = ""; // the actions to be simulated

    // local parameter declaration
    defparam  user_input.sld_node_ir_width = sld_ir_width;
    defparam  user_input.sld_node_n_scan = sld_sim_n_scan;
    defparam  user_input.sld_node_total_length = sld_sim_total_length;
    defparam  user_input.sld_node_sim_action = sld_sim_action;
    defparam  jtag.ir_register_width = 10 ;  // compilation fails if defined constant is used
    defparam  hub.sld_node_ir_width = sld_ir_width;


    // INPUT PORTS DECLARATION
    input   tdo;  // tdo signal into megafunction
    input [sld_ir_width - 1 : 0] ir_out;// parallel ir data into megafunction

    // OUTPUT PORTS DECLARATION
    output   tck;  // tck signal from megafunction
    output   tdi;  // tdi signal from megafunction
    output   virtual_state_cdr; // cdr state signal of megafunction
    output   virtual_state_sdr; // sdr state signal of megafunction
    output   virtual_state_e1dr;//  e1dr state signal of megafunction
    output   virtual_state_pdr; // pdr state signal of megafunction
    output   virtual_state_e2dr;// e2dr state signal of megafunction
    output   virtual_state_udr; // udr state signal of megafunction
    output   virtual_state_cir; // cir state signal of megafunction
    output   virtual_state_uir; // uir state signal of megafunction
    output   jtag_state_tlr;    // Test, Logic, Reset state
    output   jtag_state_rti;    // Run, Test, Idle state
    output   jtag_state_sdrs;   // Select DR scan state
    output   jtag_state_cdr;    // capture DR state
    output   jtag_state_sdr;    // Shift DR state
    output   jtag_state_e1dr;   // exit 1 dr state
    output   jtag_state_pdr;    // pause dr state
    output   jtag_state_e2dr;   // exit 2 dr state
    output   jtag_state_udr;    // update dr state
    output   jtag_state_sirs;   // Select IR scan state
    output   jtag_state_cir;    // capture IR state
    output   jtag_state_sir;    // shift IR state
    output   jtag_state_e1ir;   // exit 1 IR state
    output   jtag_state_pir;    // pause IR state
    output   jtag_state_e2ir;   // exit 2 IR state
    output   jtag_state_uir;    // update IR state
    output   tms;               // tms signal
    output [sld_ir_width - 1 : 0] ir_in; // paraller ir data from megafunction

    // connecting wires
    wire   tck_i;
    wire   tms_i;
    wire   tdi_i;
    wire   jtag_usr1_i;
    wire   tdo_i;
    wire   jtag_tdo_i;
    wire   jtag_tck_i;
    wire   jtag_tms_i;
    wire   jtag_tdi_i;
    wire   jtag_state_tlr_i;
    wire   jtag_state_rti_i;
    wire   jtag_state_drs_i;
    wire   jtag_state_cdr_i;
    wire   jtag_state_sdr_i;
    wire   jtag_state_e1dr_i;
    wire   jtag_state_pdr_i;
    wire   jtag_state_e2dr_i;
    wire   jtag_state_udr_i;
    wire   jtag_state_irs_i;
    wire   jtag_state_cir_i;
    wire   jtag_state_sir_i;
    wire   jtag_state_e1ir_i;
    wire   jtag_state_pir_i;
    wire   jtag_state_e2ir_i;
    wire   jtag_state_uir_i;


    // COMPONENT INSTANTIATIONS
    // generates input to jtag controller
    signal_gen user_input (tck_i,tms_i,tdi_i,jtag_usr1_i,tdo_i);

    // the JTAG TAP controller
    jtag_tap_controller jtag (tck_i,tms_i,tdi_i,jtag_tdo_i,
                                tdo_i,jtag_tck_i,jtag_tms_i,jtag_tdi_i,
                                jtag_state_tlr_i,jtag_state_rti_i,
                                jtag_state_drs_i,jtag_state_cdr_i,
                                jtag_state_sdr_i,jtag_state_e1dr_i,
                                jtag_state_pdr_i,jtag_state_e2dr_i,
                                jtag_state_udr_i,jtag_state_irs_i,
                                jtag_state_cir_i,jtag_state_sir_i,
                                jtag_state_e1ir_i,jtag_state_pir_i,
                                jtag_state_e2ir_i,jtag_state_uir_i,
                                jtag_usr1_i);

    // the HUB
    dummy_hub hub (jtag_tck_i,jtag_tdi_i,jtag_tms_i,jtag_usr1_i,
                    jtag_state_tlr_i,jtag_state_rti_i,jtag_state_drs_i,
                    jtag_state_cdr_i,jtag_state_sdr_i,jtag_state_e1dr_i,
                    jtag_state_pdr_i,jtag_state_e2dr_i,jtag_state_udr_i,
                    jtag_state_irs_i,jtag_state_cir_i,jtag_state_sir_i,
                    jtag_state_e1ir_i,jtag_state_pir_i,jtag_state_e2ir_i,
                    jtag_state_uir_i,tdo,ir_out,jtag_tdo_i,tck,tdi,tms,
                    jtag_state_tlr,jtag_state_rti,jtag_state_sdrs,jtag_state_cdr,
                    jtag_state_sdr,jtag_state_e1dr,jtag_state_pdr,jtag_state_e2dr,
                    jtag_state_udr,jtag_state_sirs,jtag_state_cir,jtag_state_sir,
                    jtag_state_e1ir,jtag_state_pir,jtag_state_e2ir,jtag_state_uir,
                    virtual_state_cdr,virtual_state_sdr,virtual_state_e1dr,
                    virtual_state_pdr,virtual_state_e2dr,virtual_state_udr,
                    virtual_state_cir,virtual_state_uir,ir_in);

endmodule

