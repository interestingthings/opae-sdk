// Created by altera_lib_mf.pl from altera_mf.v
//VALID FILE


//-------------------------------------------------------------------
// Filename    : alt_aeq_s4.v
//
// Description : Simulation model for Stratix IV ADCE
//
// Limitation  : Currently, only apllies for Stratix IV
//
// Copyright (c) Altera Corporation 1997-2009
// All rights reserved
//
//-------------------------------------------------------------------
/*verilator lint_off CASEX*/
/*verilator lint_off COMBDLY*/
/*verilator lint_off INITIALDLY*/
/*verilator lint_off LITENDIAN*/
/*verilator lint_off MULTIDRIVEN*/
/*verilator lint_off UNOPTFLAT*/
/*verilator lint_off BLKANDNBLK*/
module alt_aeq_s4
#(
  parameter show_errors = "NO",  // "YES" = show errors; anything else = do not show errors
  parameter radce_hflck = 15'h0000, // settings for RADCE_HFLCK CRAM settings - get values from ICD
  parameter radce_lflck = 15'h0000, // settings for RADCE_LFLCK CRAM settings - get values from ICD
  parameter use_hw_conv_det = 1'b0, // use hardware convergence detect macro if set to 1'b1 - else, default to soft ip.

  parameter number_of_channels = 5,
  parameter channel_address_width = 3,
  parameter lpm_type = "alt_aeq_s4",
  parameter lpm_hint = "UNUSED"
)
(
  input                             reconfig_clk,
  input                             aclr,
  input                             calibrate, // 'start'
  input                             shutdown, // shut down (put channel(s) in standby)
  input                             all_channels,
  input [channel_address_width-1:0] logical_channel_address,
  input                      [11:0] remap_address,
  output                      [8:0] quad_address,
  input    [number_of_channels-1:0] adce_done,
  output                            busy,
  output reg [number_of_channels-1:0] adce_standby, // put channels into standby - to RX PMA
  input                             adce_continuous,
  output                            adce_cal_busy,

// multiplexed signals for interfacing with DPRIO
  input                             dprio_busy,
  input [15:0]                      dprio_in,
  output                            dprio_wren,
  output                            dprio_rden,
  output [15:0]                     dprio_addr, // increase to 16 bits
  output [15:0]                     dprio_data,

  output [3:0]                      eqout,
  output                            timeout,
  input [7*number_of_channels-1:0]  testbuses,
  output [4*number_of_channels-1:0] testbus_sels,

// SHOW_ERRORS option
  output [number_of_channels-1:0]   conv_error,
  output [number_of_channels-1:0]   error
// end SHOW_ERRORS option
 );

//********************************************************************************
// DECLARATIONS
//********************************************************************************

  reg [7:0] busy_counter; // 256 cycles

  assign
    dprio_addr = {16{1'b0}},
    dprio_data = {16{1'b0}},
    dprio_rden = 1'b0,
    dprio_wren = 1'b0,
    quad_address =  {9{1'b0}},
    busy = |busy_counter,
    adce_cal_busy = |busy_counter[7:4], // only for the first half of the timer
    eqout = {4{1'b0}},
    error = {number_of_channels{1'b0}},
    conv_error = {number_of_channels{1'b0}},
    timeout    = 1'b0,
    testbus_sels = {4*number_of_channels{1'b0}};

  always @ (posedge reconfig_clk) begin
    if (aclr) begin
      busy_counter <= 8'h0;
      adce_standby[logical_channel_address] <= 1'b0;
    end else if (calibrate) begin
      busy_counter <= 8'hff;
      adce_standby <= {number_of_channels{1'b0}};
    end else if (shutdown) begin
      busy_counter <= 8'hf;
      adce_standby[logical_channel_address] <= 1'b1;
    end else if (busy) begin // if not 0, keep decrementing
      busy_counter <= busy_counter - 1'b1;
    end
  end


endmodule

