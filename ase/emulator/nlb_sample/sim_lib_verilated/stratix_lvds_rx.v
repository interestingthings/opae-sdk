// Created by altera_lib_mf.pl from altera_mf.v
// END OF MODULE

//START_MODULE_NAME----------------------------------------------------
//
// Module Name     :   stratix_lvds_rx
//
// Description     :   Stratix lvds receiver
//
// Limitation      :   Only available to Stratix and stratix GX (NON DPA mode)
//                     families.
//
// Results expected:   Deserialized output data.
//
//END_MODULE_NAME----------------------------------------------------

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
module stratix_lvds_rx (
    rx_in,          // input serial data
    rx_fastclk,     // fast clock from pll
    rx_enable0,
    rx_enable1,
    rx_out          // deserialized output data
);

// GLOBAL PARAMETER DECLARATION
    parameter number_of_channels = 1;
    parameter deserialization_factor = 4;

// LOCAL PARAMETER DECLARATION
    parameter REGISTER_WIDTH = deserialization_factor*number_of_channels;

// INPUT PORT DECLARATION
    input [number_of_channels -1 :0] rx_in;
    input rx_fastclk;
    input rx_enable0;
    input rx_enable1;

// OUTPUT PORT DECLARATION
    output [REGISTER_WIDTH -1: 0] rx_out;

// INTERNAL REGISTERS DECLARATION
    reg [REGISTER_WIDTH -1 : 0] rx_shift_reg;
    reg [REGISTER_WIDTH -1 : 0] rx_parallel_load_reg;
    reg [REGISTER_WIDTH -1 : 0] rx_out_hold;
    reg enable0_reg;
    reg enable0_reg1;
    reg enable0_neg;
    reg enable1_reg;

// INTERNAL WIRE DECLARATION
    wire rx_hold_clk;

// LOCAL INTEGER DECLARATION
    integer i1;
    integer x;

// INITIAL CONSTRUCT BLOCK
    initial
    begin : INITIALIZATION
        rx_shift_reg = {REGISTER_WIDTH{1'b0}};
        rx_parallel_load_reg = {REGISTER_WIDTH{1'b0}};
        rx_out_hold = {REGISTER_WIDTH{1'b0}};
    end //INITIALIZATION

// ALWAYS CONSTRUCT BLOCK

    // registering load enable signal
    always @ (posedge rx_fastclk)
    begin : LOAD_ENABLE
        enable0_reg1 <= enable0_reg;
        enable0_reg <= rx_enable0;
        enable1_reg <= rx_enable1;
    end // LOAD_ENABLE

    // Fast clock (on falling edge)
    always @ (negedge rx_fastclk)
    begin  : NEGEDGE_FAST_CLOCK

        // load data when the registered load enable signal is high
        if (enable0_neg == 1)
            rx_parallel_load_reg <= rx_shift_reg;

        // Loading input data to shift register
        for (i1= 0; i1 < number_of_channels; i1 = i1+1)
        begin
            for (x=deserialization_factor-1; x >0; x=x-1)
                rx_shift_reg[x + (i1 * deserialization_factor)] <=  rx_shift_reg [x-1 + (i1 * deserialization_factor)];
            rx_shift_reg[i1 * deserialization_factor] <= rx_in[i1];
        end

        enable0_neg <= enable0_reg1;

    end // NEGEDGE_FAST_CLOCK

    // Holding register
    always @ (posedge rx_hold_clk)
    begin : HOLD_REGISTER
        rx_out_hold <= rx_parallel_load_reg;
    end // HOLD_REGISTER

// CONTINOUS ASSIGNMENT
    assign rx_out = rx_out_hold;
    assign rx_hold_clk = enable1_reg;


endmodule // stratix_lvds_rx

