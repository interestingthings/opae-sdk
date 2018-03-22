// Created by altera_lib_mf.pl from altera_mf.v

// END OF MODULE



//START_MODULE_NAME------------------------------------------------------------
// Module Name         : jtag_tap_controller
//
// Description         : Behavioral model of JTAG tap controller with state signals
//
// Limitation          :  Can only decode USER1 and USER0 instructions
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
module jtag_tap_controller (tck,tms,tdi,jtag_tdo,tdo,jtag_tck,jtag_tms,jtag_tdi,
                            jtag_state_tlr,jtag_state_rti,jtag_state_drs,jtag_state_cdr,
                            jtag_state_sdr,jtag_state_e1dr,jtag_state_pdr,jtag_state_e2dr,
                            jtag_state_udr,jtag_state_irs,jtag_state_cir,jtag_state_sir,
                            jtag_state_e1ir,jtag_state_pir,jtag_state_e2ir,jtag_state_uir,
                            jtag_usr1);


    // GLOBAL PARAMETER DECLARATION
    parameter ir_register_width = 16;

    // INPUT PORTS
    input     tck;  // tck signal from signal_gen
    input     tms;  // tms signal from signal_gen
    input     tdi;  // tdi signal from signal_gen
    input     jtag_tdo; // tdo signal from hub

    // OUTPUT PORTS
    output    tdo;  // tdo signal to signal_gen
    output    jtag_tck;  // tck signal from jtag
    output    jtag_tms;  // tms signal from jtag
    output    jtag_tdi;  // tdi signal from jtag
    output    jtag_state_tlr;   // tlr state
    output    jtag_state_rti;   // rti state
    output    jtag_state_drs;   // select dr scan state
    output    jtag_state_cdr;   // capture dr state
    output    jtag_state_sdr;   // shift dr state
    output    jtag_state_e1dr;  // exit1 dr state
    output    jtag_state_pdr;   // pause dr state
    output    jtag_state_e2dr;  // exit2 dr state
    output    jtag_state_udr;   // update dr state
    output    jtag_state_irs;   // select ir scan state
    output    jtag_state_cir;   // capture ir state
    output    jtag_state_sir;   // shift ir state
    output    jtag_state_e1ir;  // exit1 ir state
    output    jtag_state_pir;   // pause ir state
    output    jtag_state_e2ir;  // exit2 ir state
    output    jtag_state_uir;   // update ir state
    output    jtag_usr1;        // jtag has usr1 instruction

    // INTERNAL REGISTERS

    reg       tdo_reg;
    // temporary tdo output register
    reg       tdo_rom_reg;
    // temporary register used to generate 0101... during SIR_ST
    reg       jtag_usr1_reg;
    // temporary jtag_usr1 register
    reg       jtag_reset_i;
    // internal reset
    reg [ 4 : 0 ] cState;
    // register for current state
    reg [ 4 : 0 ] nState;
    // register for the next state signal
    reg [ ir_register_width - 1 : 0] ir_srl;
    // the ir shift register
    reg [ ir_register_width - 1 : 0] ir_srl_hold;
    // the ir shift register

    // INTERNAL WIRES
    wire [ 4 : 0 ] cState_tmp;
    wire [ ir_register_width - 1 : 0] ir_srl_tmp;


    // OUTPUT REGISTERS
    reg   jtag_state_tlr;   // tlr state
    reg   jtag_state_rti;   // rti state
    reg   jtag_state_drs;   // select dr scan state
    reg   jtag_state_cdr;   // capture dr state
    reg   jtag_state_sdr;   // shift dr state
    reg   jtag_state_e1dr;  // exit1 dr state
    reg   jtag_state_pdr;   // pause dr state
    reg   jtag_state_e2dr;  // exit2 dr state
    reg   jtag_state_udr;   // update dr state
    reg   jtag_state_irs;   // select ir scan state
    reg   jtag_state_cir;   // capture ir state
    reg   jtag_state_sir;   // shift ir state
    reg   jtag_state_e1ir;  // exit1 ir state
    reg   jtag_state_pir;   // pause ir state
    reg   jtag_state_e2ir;  // exit2 ir state
    reg   jtag_state_uir;   // update ir state


    // INITIAL STATEMENTS
    initial
        begin
            // initialize state registers
            cState = `INIT_ST;
            nState = `TLR_ST;
        end

    // State Register block
    always @ (posedge tck or posedge jtag_reset_i)
        begin : stateReg
            if (jtag_reset_i)
                begin
                    cState <= `TLR_ST;
                    ir_srl <= 'b0;
                    tdo_reg <= 1'b0;
                    tdo_rom_reg <= 1'b0;
                    jtag_usr1_reg <= 1'b0;
                end
            else
                begin
                    // in capture ir, set-up tdo_rom_reg
                    // to generate 010101...
                    if(cState_tmp == `CIR_ST)
                        begin
                            tdo_rom_reg <= 1'b0;
                        end
                    else
                        begin
                            // write to shift register else pipe
                            if (cState_tmp == `SIR_ST)
                                begin
                                    tdo_rom_reg <= ~tdo_rom_reg;
                                    tdo_reg <= tdo_rom_reg;
                                    ir_srl <= ir_srl_tmp >> 1;
                                    ir_srl[ir_register_width - 1] <= tdi;
                                end
                            else
                                begin
                                    tdo_reg <= jtag_tdo;
                                end
                        end
                    // check if in usr1 state
                    if (cState_tmp == `UIR_ST)
                        begin
                            if (ir_srl_hold == `JTAG_USR1_INSTR)
                                begin
                                    jtag_usr1_reg <= 1'b1;
                                end
                            else
                                begin
                                    jtag_usr1_reg <= 1'b0;
                                end
                        end
                    cState <= nState;
                end
        end // stateReg

    // hold register
    always @ (negedge tck or posedge jtag_reset_i)
        begin : holdReg
            if (jtag_reset_i)
                begin
                    ir_srl_hold <= 'b0;
                end
            else
                begin
                    if (cState == `E1IR_ST)
                        begin
                            ir_srl_hold <= ir_srl;
                        end
                end
        end // holdReg

    // next state logic
    always @(cState or tms)
        begin : stateTrans
            nState = cState;
            case (cState)
                `TLR_ST :
                    begin
                        if (tms == 1'b0)
                            begin
                                nState = `RTI_ST;
                                jtag_reset_i = 1'b0;
                            end
                        else
                            begin
                                jtag_reset_i = 1'b1;
                            end
                    end
                `RTI_ST :
                    begin
                        if (tms)
                            begin
                                nState = `DRS_ST;
                            end
                    end
                `DRS_ST :
                    begin
                        if (tms)
                            begin
                                nState = `IRS_ST;
                            end
                        else
                            begin
                                nState = `CDR_ST;
                            end
                    end
                `CDR_ST :
                    begin
                        if (tms)
                            begin
                                nState = `E1DR_ST;
                            end
                        else
                            begin
                                nState = `SDR_ST;
                            end
                    end
                `SDR_ST :
                    begin
                        if (tms)
                            begin
                                nState = `E1DR_ST;
                            end
                    end
                `E1DR_ST :
                    begin
                        if (tms)
                            begin
                                nState = `UDR_ST;
                            end
                        else
                            begin
                                nState = `PDR_ST;
                            end
                    end
                `PDR_ST :
                    begin
                        if (tms)
                            begin
                                nState = `E2DR_ST;
                            end
                    end
                `E2DR_ST :
                    begin
                        if (tms)
                            begin
                                nState = `UDR_ST;
                            end
                        else
                            begin
                                nState = `SDR_ST;
                            end
                    end
                `UDR_ST :
                    begin
                        if (tms)
                            begin
                                nState = `DRS_ST;
                            end
                        else
                            begin
                                nState = `RTI_ST;
                            end
                    end
                `IRS_ST :
                    begin
                        if (tms)
                            begin
                                nState = `TLR_ST;
                            end
                        else
                            begin
                                nState = `CIR_ST;
                            end
                    end
                `CIR_ST :
                    begin
                        if (tms)
                            begin
                                nState = `E1IR_ST;
                            end
                        else
                            begin
                                nState = `SIR_ST;
                            end
                    end
                `SIR_ST :
                    begin
                        if (tms)
                            begin
                                nState = `E1IR_ST;
                            end
                    end
                `E1IR_ST :
                    begin
                        if (tms)
                            begin
                                nState = `UIR_ST;
                            end
                        else
                            begin
                                nState = `PIR_ST;
                            end
                    end
                `PIR_ST :
                    begin
                        if (tms)
                            begin
                                nState = `E2IR_ST;
                            end
                    end
                `E2IR_ST :
                    begin
                        if (tms)
                            begin
                                nState = `UIR_ST;
                            end
                        else
                            begin
                                nState = `SIR_ST;
                            end
                    end
                `UIR_ST :
                    begin
                        if (tms)
                            begin
                                nState = `DRS_ST;
                            end
                        else
                            begin
                                nState = `RTI_ST;
                            end
                    end
                `INIT_ST :
                    begin
                        nState = `TLR_ST;
                    end
                default :
                    begin
                        $display("Tap Controller State machine error");
                        $display ("Time: %0t  Instance: %m", $time);
                        nState = `TLR_ST;
                    end
            endcase
        end // stateTrans

    // Output logic
    always @ (cState)
        begin : output_logic
            jtag_state_tlr <= 1'b0;
            jtag_state_rti <= 1'b0;
            jtag_state_drs <= 1'b0;
            jtag_state_cdr <= 1'b0;
            jtag_state_sdr <= 1'b0;
            jtag_state_e1dr <= 1'b0;
            jtag_state_pdr <= 1'b0;
            jtag_state_e2dr <= 1'b0;
            jtag_state_udr <= 1'b0;
            jtag_state_irs <= 1'b0;
            jtag_state_cir <= 1'b0;
            jtag_state_sir <= 1'b0;
            jtag_state_e1ir <= 1'b0;
            jtag_state_pir <= 1'b0;
            jtag_state_e2ir <= 1'b0;
            jtag_state_uir <= 1'b0;
            case (cState)
                `TLR_ST :
                    begin
                        jtag_state_tlr <= 1'b1;
                    end
                `RTI_ST :
                    begin
                        jtag_state_rti <= 1'b1;
                    end
                `DRS_ST :
                    begin
                        jtag_state_drs <= 1'b1;
                    end
                `CDR_ST :
                    begin
                        jtag_state_cdr <= 1'b1;
                    end
                `SDR_ST :
                    begin
                        jtag_state_sdr <= 1'b1;
                    end
                `E1DR_ST :
                    begin
                        jtag_state_e1dr <= 1'b1;
                    end
                `PDR_ST :
                    begin
                        jtag_state_pdr <= 1'b1;
                    end
                `E2DR_ST :
                    begin
                        jtag_state_e2dr <= 1'b1;
                    end
                `UDR_ST :
                    begin
                        jtag_state_udr <= 1'b1;
                    end
                `IRS_ST :
                    begin
                        jtag_state_irs <= 1'b1;
                    end
                `CIR_ST :
                    begin
                        jtag_state_cir <= 1'b1;
                    end
                `SIR_ST :
                    begin
                        jtag_state_sir <= 1'b1;
                    end
                `E1IR_ST :
                    begin
                        jtag_state_e1ir <= 1'b1;
                    end
                `PIR_ST :
                    begin
                        jtag_state_pir <= 1'b1;
                    end
                `E2IR_ST :
                    begin
                        jtag_state_e2ir <= 1'b1;
                    end
                `UIR_ST :
                    begin
                        jtag_state_uir <= 1'b1;
                    end
                default :
                    begin
                        $display("Tap Controller State machine output error");
                        $display ("Time: %0t  Instance: %m", $time);
                    end
            endcase
        end // output_logic
    // temporary values
    assign ir_srl_tmp = ir_srl;
    assign cState_tmp = cState;

    // Pipe through signals
    assign tdo = tdo_reg;
    assign jtag_tck = tck;
    assign jtag_tdi = tdi;
    assign jtag_tms = tms;
    assign jtag_usr1 = jtag_usr1_reg;

endmodule

