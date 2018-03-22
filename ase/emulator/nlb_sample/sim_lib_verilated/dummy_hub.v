// Created by altera_lib_mf.pl from altera_mf.v
// END OF MODULE



//START_MODULE_NAME------------------------------------------------------------
// Module Name         : dummy_hub
//
// Description         : Acts as node and mux between the tap controller and
// user design. Generates hub signals
//
// Limitation          : Assumes only one node. Ignores user input on tdo and ir_out.
//
// Results expected    :
//
//
//END_MODULE_NAME--------------------------------------------------------------

// BEGINNING OF MODULE
`timescale 1 ps / 1 ps

// MODULE DECLARATION

/*verilator lint_off CASEX*/
/*verilator lint_off COMBDLY*/
/*verilator lint_off INITIALDLY*/
/*verilator lint_off LITENDIAN*/
/*verilator lint_off MULTIDRIVEN*/
/*verilator lint_off UNOPTFLAT*/
/*verilator lint_off BLKANDNBLK*/
module dummy_hub (jtag_tck,jtag_tdi,jtag_tms,jtag_usr1,jtag_state_tlr,jtag_state_rti,
                    jtag_state_drs,jtag_state_cdr,jtag_state_sdr,jtag_state_e1dr,
                    jtag_state_pdr,jtag_state_e2dr,jtag_state_udr,jtag_state_irs,
                    jtag_state_cir,jtag_state_sir,jtag_state_e1ir,jtag_state_pir,
                    jtag_state_e2ir,jtag_state_uir,dummy_tdo,virtual_ir_out,
                    jtag_tdo,dummy_tck,dummy_tdi,dummy_tms,dummy_state_tlr,
                    dummy_state_rti,dummy_state_drs,dummy_state_cdr,dummy_state_sdr,
                    dummy_state_e1dr,dummy_state_pdr,dummy_state_e2dr,dummy_state_udr,
                    dummy_state_irs,dummy_state_cir,dummy_state_sir,dummy_state_e1ir,
                    dummy_state_pir,dummy_state_e2ir,dummy_state_uir,virtual_state_cdr,
                    virtual_state_sdr,virtual_state_e1dr,virtual_state_pdr,virtual_state_e2dr,
                    virtual_state_udr,virtual_state_cir,virtual_state_uir,virtual_ir_in);


    // GLOBAL PARAMETER DECLARATION
    parameter sld_node_ir_width = 16;

    // INPUT PORTS

    input   jtag_tck;       // tck signal from tap controller
    input   jtag_tdi;       // tdi signal from tap controller
    input   jtag_tms;       // tms signal from tap controller
    input   jtag_usr1;      // usr1 signal from tap controller
    input   jtag_state_tlr; // tlr state signal from tap controller
    input   jtag_state_rti; // rti state signal from tap controller
    input   jtag_state_drs; // drs state signal from tap controller
    input   jtag_state_cdr; // cdr state signal from tap controller
    input   jtag_state_sdr; // sdr state signal from tap controller
    input   jtag_state_e1dr;// e1dr state signal from tap controller
    input   jtag_state_pdr; // pdr state signal from tap controller
    input   jtag_state_e2dr;// esdr state signal from tap controller
    input   jtag_state_udr; // udr state signal from tap controller
    input   jtag_state_irs; // irs state signal from tap controller
    input   jtag_state_cir; // cir state signals from tap controller
    input   jtag_state_sir; // sir state signal from tap controller
    input   jtag_state_e1ir;// e1ir state signal from tap controller
    input   jtag_state_pir; // pir state signals from tap controller
    input   jtag_state_e2ir;// e2ir state signal from tap controller
    input   jtag_state_uir; // uir state signal from tap controller
    input   dummy_tdo;      // tdo signal from world
    input [sld_node_ir_width - 1 : 0] virtual_ir_out; // captures parallel input from

    // OUTPUT PORTS
    output   jtag_tdo;             // tdo signal to tap controller
    output   dummy_tck;           // tck signal to world
    output   dummy_tdi;           // tdi signal to world
    output   dummy_tms;           // tms signal to world
    output   dummy_state_tlr;     // tlr state signal to world
    output   dummy_state_rti;     // rti state signal to world
    output   dummy_state_drs;     // drs state signal to world
    output   dummy_state_cdr;     // cdr state signal to world
    output   dummy_state_sdr;     // sdr state signal to world
    output   dummy_state_e1dr;    // e1dr state signal to the world
    output   dummy_state_pdr;     // pdr state signal to world
    output   dummy_state_e2dr;    // e2dr state signal to world
    output   dummy_state_udr;     // udr state signal to world
    output   dummy_state_irs;     // irs state signal to world
    output   dummy_state_cir;    // cir state signal to world
    output   dummy_state_sir;    // sir state signal to world
    output   dummy_state_e1ir;   // e1ir state signal to world
    output   dummy_state_pir;    // pir state signal to world
    output   dummy_state_e2ir;   // e2ir state signal to world
    output   dummy_state_uir;    // uir state signal to world
    output   virtual_state_cdr;  // virtual cdr state signal
    output   virtual_state_sdr;  // virtual sdr state signal
    output   virtual_state_e1dr; // virtual e1dr state signal
    output   virtual_state_pdr;  // virtula pdr state signal
    output   virtual_state_e2dr; // virtual e2dr state signal
    output   virtual_state_udr;  // virtual udr state signal
    output   virtual_state_cir;  // virtual cir state signal
    output   virtual_state_uir;  // virtual uir state signal
    output [sld_node_ir_width - 1 : 0] virtual_ir_in;      // parallel output to user design


`define SLD_NODE_IR_WIDTH_I sld_node_ir_width + `NUM_SELECTION_BITS // internal ir width

    // INTERNAL REGISTERS
    reg   capture_ir;    // signals force_ir_capture instruction
    reg   jtag_tdo_reg;  // register for jtag_tdo
    reg   dummy_tdi_reg; // register for dummy_tdi
    reg   dummy_tck_reg; // register for dummy_tck.
    reg  [`SLD_NODE_IR_WIDTH_I - 1 : 0] ir_srl; // ir shift register
    wire [`SLD_NODE_IR_WIDTH_I - 1 : 0] ir_srl_tmp; // ir shift register
    reg  [`SLD_NODE_IR_WIDTH_I - 1 : 0] ir_srl_hold; //hold register for ir shift register

    // OUTPUT REGISTERS
    reg [sld_node_ir_width - 1 : 0]     virtual_ir_in;

    // INITIAL STATEMENTS
    always @ (posedge jtag_tck or posedge jtag_state_tlr)
        begin : simulation_logic
            if (jtag_state_tlr) // asynchronous active high reset
                begin : active_hi_async_reset
                    ir_srl <= 'b0;
                    jtag_tdo_reg <= 1'b0;
                    dummy_tdi_reg <= 1'b0;
                end  // active_hi_async_reset
            else
                begin : rising_edge_jtag_tck
                    // logic for shifting in data and piping data through
                    // logic for muxing inputs to outputs and otherwise
                    if (jtag_usr1 && jtag_state_sdr)
                        begin : shift_in_out_usr1
                            jtag_tdo_reg <= ir_srl_tmp[0];
                            ir_srl <= ir_srl_tmp >> 1;
                            ir_srl[`SLD_NODE_IR_WIDTH_I - 1] <= jtag_tdi;
                        end // shift_in_out_usr1
                    else
                        begin
                            if (capture_ir && jtag_state_cdr)
                                begin : capture_virtual_ir_out
                                    ir_srl[`SLD_NODE_IR_WIDTH_I - 2 : `NUM_SELECTION_BITS - 1] <= virtual_ir_out;
                                end // capture_virtual_ir_out
                            else
                                begin
                                    if (capture_ir && jtag_state_sdr)
                                        begin : shift_in_out_usr0
                                            jtag_tdo_reg <= ir_srl_tmp[0];
                                            ir_srl <= ir_srl_tmp >> 1;
                                            ir_srl[`SLD_NODE_IR_WIDTH_I - 1] <= jtag_tdi;
                                        end // shift_in_out_usr0
                                    else
                                        begin
                                            if (jtag_state_sdr)
                                                begin : pipe_through
                                                    dummy_tdi_reg <= jtag_tdi;
                                                    jtag_tdo_reg <= dummy_tdo;
                                                end // pipe_through
                                        end
                                end
                        end
                end // rising_edge_jtag_tck
        end // simulation_logic

    // always block for writing to capture_ir
    // stops nlint from complaining.
    always @ (posedge jtag_tck or posedge jtag_state_tlr)
        begin : capture_ir_logic
            if (jtag_state_tlr) // asynchronous active high reset
                begin : active_hi_async_reset
                    capture_ir <= 1'b0;
                end  // active_hi_async_reset
            else
                begin : rising_edge_jtag_tck
                    // should check for 011 instruction
                    // but we know that it is the only instruction ever sent to the
                    // hub. So all we have to do is check the selection bit and udr
                    // and usr1 state
                    // logic for capture_ir signal
                    if (jtag_state_udr && (ir_srl[`SLD_NODE_IR_WIDTH_I - 1] == 1'b0))
                        begin
                            capture_ir <= jtag_usr1;
                        end
                    else
                        begin
                            if (jtag_state_e1dr)
                                begin
                                    capture_ir <= 1'b0;
                                end
                        end
                end  // rising_edge_jtag_tck
        end // capture_ir_logic

    // outputs -  rising edge of clock
    always @ (posedge jtag_tck or posedge jtag_state_tlr)
        begin : parallel_ir_out
            if (jtag_state_tlr)
                begin : active_hi_async_reset
                    virtual_ir_in <= 'b0;
                end
            else
                begin : rising_edge_jtag_tck
                    virtual_ir_in <= ir_srl_hold[`SLD_NODE_IR_WIDTH_I - 2 : `NUM_SELECTION_BITS - 1];
                end
        end

    // outputs -  falling edge of clock, separated for clarity
    always @ (negedge jtag_tck or posedge jtag_state_tlr)
        begin : shift_reg_hold
            if (jtag_state_tlr)
                begin : active_hi_async_reset
                    ir_srl_hold <= 'b0;
                end
            else
                begin
                    if (ir_srl[`SLD_NODE_IR_WIDTH_I - 1] && jtag_state_e1dr)
                        begin
                            ir_srl_hold <= ir_srl;
                        end
                end
        end // shift_reg_hold

    // generate tck in sync with tdi
    always @ (posedge jtag_tck or negedge jtag_tck)
        begin : gen_tck
            dummy_tck_reg <= jtag_tck;
        end // gen_tck
    // temporary signals
    assign ir_srl_tmp = ir_srl;

    // Pipe through signals
    assign dummy_state_tlr    = jtag_state_tlr;
    assign dummy_state_rti    = jtag_state_rti;
    assign dummy_state_drs    = jtag_state_drs;
    assign dummy_state_cdr    = jtag_state_cdr;
    assign dummy_state_sdr    = jtag_state_sdr;
    assign dummy_state_e1dr   = jtag_state_e1dr;
    assign dummy_state_pdr    = jtag_state_pdr;
    assign dummy_state_e2dr   = jtag_state_e2dr;
    assign dummy_state_udr    = jtag_state_udr;
    assign dummy_state_irs    = jtag_state_irs;
    assign dummy_state_cir    = jtag_state_cir;
    assign dummy_state_sir    = jtag_state_sir;
    assign dummy_state_e1ir   = jtag_state_e1ir;
    assign dummy_state_pir    = jtag_state_pir;
    assign dummy_state_e2ir   = jtag_state_e2ir;
    assign dummy_state_uir    = jtag_state_uir;
    assign dummy_tms          = jtag_tms;


    // Virtual signals
    assign virtual_state_uir  = jtag_usr1 && jtag_state_udr && ir_srl_hold[`SLD_NODE_IR_WIDTH_I - 1];
    assign virtual_state_cir  = jtag_usr1 && jtag_state_cdr && ir_srl_hold[`SLD_NODE_IR_WIDTH_I - 1];
    assign virtual_state_udr  = (! jtag_usr1) && jtag_state_udr && ir_srl_hold[`SLD_NODE_IR_WIDTH_I - 1];
    assign virtual_state_e2dr = (! jtag_usr1) && jtag_state_e2dr && ir_srl_hold[`SLD_NODE_IR_WIDTH_I - 1];
    assign virtual_state_pdr  = (! jtag_usr1) && jtag_state_pdr && ir_srl_hold[`SLD_NODE_IR_WIDTH_I - 1];
    assign virtual_state_e1dr = (! jtag_usr1) && jtag_state_e1dr && ir_srl_hold[`SLD_NODE_IR_WIDTH_I - 1];
    assign virtual_state_sdr  = (! jtag_usr1) && jtag_state_sdr && ir_srl_hold[`SLD_NODE_IR_WIDTH_I - 1];
    assign virtual_state_cdr  = (! jtag_usr1) && jtag_state_cdr && ir_srl_hold[`SLD_NODE_IR_WIDTH_I - 1];

    // registered output
    assign jtag_tdo = jtag_tdo_reg;
    assign dummy_tdi = dummy_tdi_reg;
    assign dummy_tck = dummy_tck_reg;

endmodule

