// Created by altera_lib_mf.pl from altera_mf.v
// Created by altera_lib_mf.pl from altera_mf.v
// Copyright (C) 2016 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions
// and other software and tools, and its AMPP partner logic
// functions, and any output files from any of the foregoing
// (including device programming or simulation files), and any
// associated documentation or information are expressly subject
// to the terms and conditions of the Intel Program License
// Subscription Agreement, the Intel Quartus Prime License Agreement,
// the Intel MegaCore Function License Agreement, or other
// applicable license agreement, including, without limitation,
// that your use is for the sole purpose of programming logic
// devices manufactured by Intel and sold by Intel or its
// authorized distributors.  Please refer to the applicable
// agreement for further details.
// Quartus Prime 16.1.0 Build 196 10/24/2016

//START_MODULE_NAME------------------------------------------------------------
//
// Module Name     :  ALTERA_MF_MEMORY_INITIALIZATION
//
// Description     :  Common function to read intel-hex format data file with
//                    extension .hex and creates the equivalent verilog format
//                    data file with extension .ver.
//
// Limitation      :  Supports only record type '00'(data record), '01'(end of
//                     file record) and '02'(extended segment address record).
//
// Results expected:  Creates the verilog format data file with extension .ver
//                     and return the name of the file.
//
//END_MODULE_NAME--------------------------------------------------------------


`timescale 1 ps / 1 ps
/*verilator lint_off CASEX*/
/*verilator lint_off COMBDLY*/
/*verilator lint_off INITIALDLY*/
/*verilator lint_off LITENDIAN*/
/*verilator lint_off MULTIDRIVEN*/
/*verilator lint_off UNOPTFLAT*/
/*verilator lint_off BLKANDNBLK*/
module lcell (in, out);
    input in;
    output out;

    assign out = in;
endmodule

