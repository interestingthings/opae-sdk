// Created by altera_lib_mf.pl from altera_mf.v
// END OF MODULE


// START_FILE_HEADER ----------------------------------------------------------
//
// Filename    : altera_std_synchronizer_bundle.v
//
// Description : Contains the simulation model for the altera_std_synchronizer_bundle
//
// Owner       :
//
// Copyright (C) Altera Corporation 2008, All Rights Reserved
//
// END_FILE_HEADER ------------------------------------------------------------

// START_MODULE_NAME-----------------------------------------------------------
//
// Module Name : altera_std_synchronizer_bundle
//
// Description : Bundle of bit synchronizers.
//               WARNING: only use this to synchronize a bundle of
//               *independent* single bit signals or a Gray encoded
//               bus of signals. Also remember that pulses entering
//               the synchronizer will be swallowed upon a metastable
//               condition if the pulse width is shorter than twice
//               the synchronizing clock period.
//
// END_MODULE_NAME-------------------------------------------------------------

/*verilator lint_off CASEX*/
/*verilator lint_off COMBDLY*/
/*verilator lint_off INITIALDLY*/
/*verilator lint_off LITENDIAN*/
/*verilator lint_off MULTIDRIVEN*/
/*verilator lint_off UNOPTFLAT*/
/*verilator lint_off BLKANDNBLK*/
module altera_std_synchronizer_bundle  (
                                        clk,
                                        reset_n,
                                        din,
                                        dout
                                        );
    // GLOBAL PARAMETER DECLARATION
    parameter width = 1;
    parameter depth = 3;

    // INPUT PORT DECLARATION
    input clk;
    input reset_n;
    input [width-1:0] din;

    // OUTPUT PORT DECLARATION
    output [width-1:0] dout;

    generate
        genvar i;
        for (i=0; i<width; i=i+1)
        begin : sync
            altera_std_synchronizer #(.depth(depth))
                                    u  (
                                        .clk(clk),
                                        .reset_n(reset_n),
                                        .din(din[i]),
                                        .dout(dout[i])
                                        );
        end
    endgenerate

endmodule // altera_std_synchronizer_bundle

