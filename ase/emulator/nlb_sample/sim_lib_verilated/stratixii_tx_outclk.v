// Created by altera_lib_mf.pl from altera_mf.v
// END OF MODULE


//START_MODULE_NAME--------------------------------------------------------------
//
// Module Name     :  stratixii_tx_outclk

// Description     :  This module is used to generate the tx_outclock for StratixII
//                    family.

// Limitation      :  Only available STRATIX II family.
//
// Results expected:  Output clock.
//
//END_MODULE_NAME----------------------------------------------------------------

// BEGINNING OF MODULE
`timescale 1 ps / 1 ps

/*verilator lint_off CASEX*/
/*verilator lint_off COMBDLY*/
/*verilator lint_off INITIALDLY*/
/*verilator lint_off LITENDIAN*/
/*verilator lint_off MULTIDRIVEN*/
/*verilator lint_off UNOPTFLAT*/
/*verilator lint_off BLKANDNBLK*/
module stratixii_tx_outclk (
    tx_in,
    tx_fastclk,
    tx_enable,
    tx_out
);

// GLOBAL PARAMETER DECLARATION
    // No. of bits per channel (required)
    parameter deserialization_factor = 4;
    parameter bypass_serializer = "FALSE";
    parameter invert_clock = "FALSE";
    parameter use_falling_clock_edge = "FALSE";

// INPUT PORT DECLARATION
    // Input data (required)
    input  [9 : 0] tx_in;
    // Input clock (required)
    input tx_fastclk;
    input tx_enable;

// OUTPUT PORT DECLARATION
    // Serialized data signal(required)
    output tx_out;

// INTERNAL REGISTERS DECLARATION
    reg [deserialization_factor -1 : 0] tx_shift_reg;
    reg [deserialization_factor -1 : 0] tx_parallel_load_reg;
    reg tx_out_reg;
    reg tx_out_neg;
    reg enable1_reg;

// INTERNAL TRI DECLARATION
    logic tx_enable; // -- converted tristate to logic

// LOCAL INTEGER DECLARATION
    integer i1;
    integer i2;
    integer x;

// INITIAL CONSTRUCT BLOCK

    initial
    begin : INITIALIZATION
        tx_parallel_load_reg = {deserialization_factor{1'b0}};
        tx_shift_reg = {deserialization_factor{1'b0}};

        enable1_reg = 0;

    end // INITIALIZATION

// ALWAYS CONSTRUCT BLOCK

    // Fast Clock
    always @ (posedge tx_fastclk)
    begin : POSEDGE_FAST_CLOCK
        // registering enable1 signal
        enable1_reg <= tx_enable;

        if (enable1_reg == 1'b1)
            tx_shift_reg <= tx_parallel_load_reg;
        else// Shift data from shift register to tx_out
        begin
            for (x=deserialization_factor-1; x >0; x=x-1)
                tx_shift_reg[x] <= tx_shift_reg [x-1];
        end

        tx_parallel_load_reg <= tx_in[deserialization_factor-1 : 0];
    end // POSEDGE_FAST_CLOCK

    always @ (negedge tx_fastclk)
    begin : NEGEDGE_FAST_CLOCK
        tx_out_neg <= tx_shift_reg[deserialization_factor-1];
    end // NEGEDGE_FAST_CLOCK

// CONTINUOUS ASSIGNMENT
    assign tx_out = (bypass_serializer == "TRUE")      ? ((invert_clock == "FALSE") ? tx_fastclk : ~tx_fastclk) :
                    (use_falling_clock_edge == "TRUE") ? tx_out_neg :
                                                        tx_shift_reg[deserialization_factor-1];

endmodule // stratixii_tx_outclk

