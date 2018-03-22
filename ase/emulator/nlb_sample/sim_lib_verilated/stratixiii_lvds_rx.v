// Created by altera_lib_mf.pl from altera_mf.v
// END OF MODULE

//START_MODULE_NAME-------------------------------------------------------------
//
// Module Name     :   stratixiii_lvds_rx
//
// Description     :   Stratix III lvds receiver. Support both the dpa and non-dpa
//                     mode.
//
// Limitation      :   Only available to Stratix III.
//
// Results expected:   Deserialized output data, dpa lock signal, forwarded clock
//                     and status bit indicating whether maximum bitslip has been
//                     reached.
//
//END_MODULE_NAME---------------------------------------------------------------

// BEGINNING OF MODULE
`timescale 1 ps / 1 ps
`define MAX_CHANNEL 132
`define MAX_DESER 44

// MODULE DECLARATION
/*verilator lint_off CASEX*/
/*verilator lint_off COMBDLY*/
/*verilator lint_off INITIALDLY*/
/*verilator lint_off LITENDIAN*/
/*verilator lint_off MULTIDRIVEN*/
/*verilator lint_off UNOPTFLAT*/
/*verilator lint_off BLKANDNBLK*/
module stratixiii_lvds_rx (
    rx_in,
    rx_reset,
    rx_fastclk,
    rx_slowclk,
    rx_enable,
    rx_dpll_reset,
    rx_dpll_hold,
    rx_dpll_enable,
    rx_fifo_reset,
    rx_channel_data_align,
    rx_cda_reset,
    rx_out,
    rx_dpa_locked,
    rx_cda_max,
    rx_divfwdclk,
    rx_locked,
    rx_dpa_lock_reset,
    rx_dpaclock
);

// GLOBAL PARAMETER DECLARATION
    parameter number_of_channels = 1;
    parameter deserialization_factor = 4;
    parameter enable_dpa_mode = "OFF";
    parameter data_align_rollover = deserialization_factor;
    parameter lose_lock_on_one_change = "OFF";
    parameter reset_fifo_at_first_lock = "ON";
    parameter x_on_bitslip = "ON";
    parameter rx_align_data_reg = "RISING_EDGE";
    parameter enable_soft_cdr_mode = "OFF";
    parameter sim_dpa_output_clock_phase_shift = 0;
    parameter sim_dpa_is_negative_ppm_drift = "OFF";
    parameter sim_dpa_net_ppm_variation = 0;
    parameter enable_dpa_align_to_rising_edge_only = "OFF";
    parameter enable_dpa_initial_phase_selection = "OFF";
    parameter dpa_initial_phase_value = 0;
    parameter registered_output = "ON";
    parameter use_external_pll = "OFF";
    parameter use_dpa_calibration = 0;
    parameter enable_clock_pin_mode = "UNUSED";
    parameter ARRIAII_RX_STYLE = 0;
    parameter STRATIXV_RX_STYLE = 0;

// LOCAL PARAMETER DECLARATION

    parameter REGISTER_WIDTH = deserialization_factor*number_of_channels;

// INPUT PORT DECLARATION
    input [number_of_channels -1 :0] rx_in;
    input rx_fastclk;
    input rx_slowclk;
    input rx_enable;
    input rx_dpaclock;
    input [number_of_channels -1 :0] rx_reset;
    input [number_of_channels -1 :0] rx_dpll_reset;
    input [number_of_channels -1 :0] rx_dpll_hold;
    input [number_of_channels -1 :0] rx_dpll_enable;
    input [number_of_channels -1 :0] rx_fifo_reset;
    input [number_of_channels -1 :0] rx_channel_data_align;
    input [number_of_channels -1 :0] rx_cda_reset;
    input rx_locked;
    input [number_of_channels -1 :0] rx_dpa_lock_reset;

// OUTPUT PORT DECLARATION
    output [REGISTER_WIDTH -1: 0] rx_out;
    output [number_of_channels -1: 0] rx_dpa_locked;
    output [number_of_channels -1: 0] rx_cda_max;
    output [number_of_channels -1: 0] rx_divfwdclk;

// INTERNAL WIRE DECLARATION
    wire [`MAX_CHANNEL -1 :0] i_rx_in;
    wire [`MAX_CHANNEL -1 :0] i_rx_fastclk;
    wire [`MAX_CHANNEL -1 :0] i_rx_slowclk;
    wire [`MAX_CHANNEL -1 :0] i_rx_enable;
    wire [`MAX_CHANNEL -1 :0] i_rx_reset;
    wire [`MAX_CHANNEL -1 :0] i_rx_dpll_reset;
    wire [`MAX_CHANNEL -1 :0] i_rx_dpll_hold;
    wire [`MAX_CHANNEL -1 :0] i_rx_dpll_enable;
    wire [`MAX_CHANNEL -1 :0] i_rx_fifo_reset;
    wire [`MAX_CHANNEL -1 :0] i_rx_channel_data_align;
    wire [`MAX_CHANNEL -1 :0] i_rx_cda_reset;
    wire [`MAX_CHANNEL*`MAX_DESER -1: 0] i_rx_dataout;
    wire [`MAX_CHANNEL -1: 0] i_rx_dpa_locked;
    wire [`MAX_CHANNEL -1: 0] i_rx_cda_max;
    wire [`MAX_CHANNEL -1: 0] i_rx_divfwdclk;
    wire [`MAX_CHANNEL -1: 0] i_rx_dpa_lock_reset;
    wire [`MAX_CHANNEL -1: 0] i_rx_dpaclock;

// COMPONENT INSTANTIATIONS

    // Stratix III LVDS RX Channel
    generate
    genvar i;
    for (i=0; i<=number_of_channels-1; i = i +1)
    begin : stratixiii_lvds_rx_channel
    stratixiii_lvds_rx_channel chnl (
        .rx_in(i_rx_in[i]),
        .rx_reset(i_rx_reset[i]),
        .rx_fastclk(i_rx_fastclk[i]),
        .rx_slowclk(i_rx_slowclk[i]),
        .rx_enable(i_rx_enable[i]),
        .rx_dpll_reset(i_rx_dpll_reset[i]),
        .rx_dpll_hold(i_rx_dpll_hold[i]),
        .rx_dpll_enable(i_rx_dpll_enable[i]),
        .rx_fifo_reset(i_rx_fifo_reset[i]),
        .rx_channel_data_align(i_rx_channel_data_align[i]),
        .rx_cda_reset(i_rx_cda_reset[i]),
        .rx_out(i_rx_dataout[(i+1)*deserialization_factor-1:i*deserialization_factor]),
        .rx_dpa_locked(i_rx_dpa_locked[i]),
        .rx_cda_max(i_rx_cda_max[i]),
        .rx_dpa_lock_reset(i_rx_dpa_lock_reset[i]),
        .rx_locked(rx_locked),
        .rx_divfwdclk(i_rx_divfwdclk[i]),
        .rx_dpaclock(i_rx_dpaclock[i]));
    defparam
        chnl.deserialization_factor = deserialization_factor,
        chnl.enable_dpa_mode = enable_dpa_mode,
        chnl.data_align_rollover = data_align_rollover,
        chnl.lose_lock_on_one_change = lose_lock_on_one_change,
        chnl.reset_fifo_at_first_lock = reset_fifo_at_first_lock,
        chnl.x_on_bitslip = x_on_bitslip,
        chnl.rx_align_data_reg = rx_align_data_reg,
        chnl.enable_soft_cdr_mode = enable_soft_cdr_mode,
        chnl.sim_dpa_output_clock_phase_shift = sim_dpa_output_clock_phase_shift,
        chnl.sim_dpa_is_negative_ppm_drift = sim_dpa_is_negative_ppm_drift,
        chnl.sim_dpa_net_ppm_variation = sim_dpa_net_ppm_variation,
        chnl.enable_dpa_align_to_rising_edge_only = enable_dpa_align_to_rising_edge_only,
        chnl.enable_dpa_initial_phase_selection = enable_dpa_initial_phase_selection,
        chnl.dpa_initial_phase_value = dpa_initial_phase_value,
        chnl.use_external_pll = use_external_pll,
        chnl.registered_output = registered_output,
        chnl.use_dpa_calibration = use_dpa_calibration,
        chnl.enable_clock_pin_mode = enable_clock_pin_mode,
        chnl.ARRIAII_RX_STYLE = ARRIAII_RX_STYLE,
        chnl.STRATIXV_RX_STYLE = STRATIXV_RX_STYLE;
    end
    endgenerate

// CONTINOUS ASSIGNMENT

assign i_rx_in [number_of_channels - 1 : 0]      = rx_in[number_of_channels - 1 : 0];
assign i_rx_fastclk [number_of_channels - 1 : 0] = {number_of_channels{rx_fastclk}};
assign i_rx_slowclk [number_of_channels - 1 : 0] = {number_of_channels{rx_slowclk}};
assign i_rx_enable [number_of_channels - 1 : 0]  = {number_of_channels{rx_enable}};
assign i_rx_reset [number_of_channels - 1 : 0]   = rx_reset[number_of_channels - 1 : 0];
assign i_rx_dpll_reset [number_of_channels - 1 : 0] = rx_dpll_reset[number_of_channels - 1 : 0];
assign i_rx_dpll_hold [number_of_channels - 1 : 0]  = rx_dpll_hold[number_of_channels - 1 : 0];
assign i_rx_dpll_enable [number_of_channels - 1 : 0] = rx_dpll_enable[number_of_channels - 1 : 0];
assign i_rx_fifo_reset [number_of_channels - 1 : 0]  = rx_fifo_reset[number_of_channels - 1 : 0];
assign i_rx_channel_data_align [number_of_channels - 1 : 0] = rx_channel_data_align[number_of_channels - 1 : 0];
assign i_rx_cda_reset [number_of_channels - 1 : 0]   = rx_cda_reset[number_of_channels - 1 : 0];
assign rx_out = i_rx_dataout [REGISTER_WIDTH - 1 :0];
assign rx_dpa_locked = i_rx_dpa_locked [number_of_channels-1:0];
assign rx_cda_max = i_rx_cda_max [number_of_channels-1:0];
assign rx_divfwdclk = i_rx_divfwdclk [number_of_channels-1:0];
assign i_rx_dpa_lock_reset[number_of_channels-1:0] = rx_dpa_lock_reset[number_of_channels - 1 : 0];
assign i_rx_dpaclock [number_of_channels - 1 : 0] = {number_of_channels{rx_dpaclock}};

endmodule // stratixiii_lvds_rx

