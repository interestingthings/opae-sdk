// Created by altera_lib_mf.pl from altera_mf.v

// pll_iobuf
`timescale 1 ps / 1 ps
/*verilator lint_off CASEX*/
/*verilator lint_off COMBDLY*/
/*verilator lint_off INITIALDLY*/
/*verilator lint_off LITENDIAN*/
/*verilator lint_off MULTIDRIVEN*/
/*verilator lint_off UNOPTFLAT*/
/*verilator lint_off BLKANDNBLK*/
module pll_iobuf (i, oe, io, o);
    input i;
    input oe;
    inout io;
    output o;
    reg    o;

    always @(io)
    begin
        o = io;
    end

    assign io = (oe == 1) ? i : 1'b0 /* converted x or z to 1'b0 */;
endmodule

