// Created by altera_lib_mf.pl from altera_mf.v

//START_MODULE_NAME------------------------------------------------------------
//
// Module Name     :  a_graycounter
//
// Description     :  Gray counter with Count-enable, Up/Down, aclr and sclr
//
// Limitation      :  Sync sigal priority: clk_en (higher),sclr,cnt_en (lower)
//
// Results expected:  q is graycounter output and qbin is normal counter
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
module a_graycounter (clock, cnt_en, clk_en, updown, aclr, sclr,
                        q, qbin);
// GLOBAL PARAMETER DECLARATION
    parameter width  = 3;
    parameter pvalue = 0;
    parameter lpm_hint = "UNUSED";
    parameter lpm_type = "a_graycounter";

// INPUT PORT DECLARATION
    input  clock;
    input  cnt_en;
    input  clk_en;
    input  updown;
    input  aclr;
    input  sclr;

// OUTPUT PORT DECLARATION
    output [width-1:0] q;
    output [width-1:0] qbin;

// INTERNAL REGISTERS DECLARATION
    reg [width-1:0] cnt;

// INTERNAL TRI DECLARATION
    logic clk_en; // -- converted tristate to logic
    logic cnt_en; // -- converted tristate to logic
    logic updown; // -- converted tristate to logic
    logic aclr; // -- converted tristate to logic
    logic sclr; // -- converted tristate to logic

// LOCAL INTEGER DECLARATION

// COMPONENT INSTANTIATIONS

// INITIAL CONSTRUCT BLOCK
    initial
    begin
        if (width <= 0)
        begin
            $display ("Error! WIDTH of a_greycounter must be greater than 0.");
            $display ("Time: %0t  Instance: %m", $time);
        end
        cnt = pvalue;
    end

// ALWAYS CONSTRUCT BLOCK
    always @(posedge aclr or posedge clock)
    begin
        if (aclr)
            cnt <= pvalue;
        else
        begin
            if (clk_en)
            begin
                if (sclr)
                    cnt <= pvalue;
                else if (cnt_en)
                begin
                    if (updown == 1)
                        cnt <= cnt + 1;
                    else
                        cnt <= cnt - 1;
                end
            end
        end
    end

// CONTINOUS ASSIGNMENT
    assign qbin = cnt;
    assign q    = cnt ^ (cnt >>1);

endmodule // a_graycounter

