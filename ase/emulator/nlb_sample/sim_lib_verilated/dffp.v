// Created by altera_lib_mf.pl from altera_mf.v

///////////////////////////////////////////////////////////////////////////////
//
//                             STRATIX_PLL and STRATIXII_PLL
//
///////////////////////////////////////////////////////////////////////////////

// DFFP
`timescale 1ps / 1ps
/*verilator lint_off CASEX*/
/*verilator lint_off COMBDLY*/
/*verilator lint_off INITIALDLY*/
/*verilator lint_off LITENDIAN*/
/*verilator lint_off MULTIDRIVEN*/
/*verilator lint_off UNOPTFLAT*/
/*verilator lint_off BLKANDNBLK*/
module dffp (
    q,
    clk,
    ena,
    d,
    clrn,
    prn );

    input d;
    input clk;
    input clrn;
    input prn;
    input ena;
    output q;


    logic prn, clrn, ena; // -- converted tristate to logic
    reg q;

    always @ (posedge clk or negedge clrn or negedge prn )
        if (prn == 1'b0)
            q <= 1;
        else if (clrn == 1'b0)
            q <= 0;
        else
        begin
            if (ena == 1'b1)
                q <= d;
        end
    endmodule

