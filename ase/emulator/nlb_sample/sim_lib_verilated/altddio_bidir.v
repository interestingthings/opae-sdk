// Created by altera_lib_mf.pl from altera_mf.v
// END MODULE ALTDDIO_OUT

// START MODULE NAME -----------------------------------------------------------
//
// Module Name      : ALTDDIO_BIDIR
//
// Description      : Double Data Rate (DDR) bi-directional behavioural model.
//                    Transmits and receives data on both edges of the reference
//                    clock.
//
// Limitations      : Not available for MAX device families.
//
// Expected results : Data output sampled from padio port on rising edge of
//                    inclock signal (dataout_h) and falling edge of inclock
//                    signal (dataout_l). Combinatorial output fed by padio
//                    directly (combout).
//
//END MODULE NAME --------------------------------------------------------------

`timescale 1 ps / 1 ps

// MODULE DECLARATION
/*verilator lint_off CASEX*/
/*verilator lint_off COMBDLY*/
/*verilator lint_off INITIALDLY*/
/*verilator lint_off LITENDIAN*/
/*verilator lint_off MULTIDRIVEN*/
/*verilator lint_off UNOPTFLAT*/
/*verilator lint_off BLKANDNBLK*/
module altddio_bidir (
    datain_h,   // required port, input data to be output of padio port at the
                // rising edge of outclock
    datain_l,   // required port, input data to be output of padio port at the
                // falling edge of outclock
    inclock,    // required port, input reference clock to sample data by
    inclocken,  // inclock enable
    outclock,   // required port, input reference clock to register data output
    outclocken, // outclock enable
    aset,       // asynchronour set
    aclr,       // asynchronous clear
    sset,       // ssynchronour set
    sclr,       // ssynchronous clear
    oe,         // output enable for padio port
    dataout_h,  // data sampled from the padio port at the rising edge of inclock
    dataout_l,  // data sampled from the padio port at the falling edge of
                // inclock
    combout,    // combinatorial output directly fed by padio
    oe_out,     // DDR OE output
    dqsundelayedout, // undelayed DQS signal to the PLD core
    padio     // bidirectional DDR port
);

// GLOBAL PARAMETER DECLARATION
parameter width = 1; // required parameter
parameter power_up_high = "OFF";
parameter oe_reg = "UNUSED";
parameter extend_oe_disable = "UNUSED";
parameter implement_input_in_lcell = "UNUSED";
parameter invert_output = "OFF";
parameter intended_device_family = "Stratix";
parameter lpm_type = "altddio_bidir";
parameter lpm_hint = "UNUSED";

// INPUT PORT DECLARATION
input [width-1:0] datain_h;
input [width-1:0] datain_l;
input inclock;
input inclocken;
input outclock;
input outclocken;
input aset;
input aclr;
input sset;
input sclr;
input oe;

// OUTPUT PORT DECLARATION
output [width-1:0] dataout_h;
output [width-1:0] dataout_l;
output [width-1:0] combout;
output [width-1:0] oe_out;
output [width-1:0] dqsundelayedout;
// BIDIRECTIONAL PORT DECLARATION
inout  [width-1:0] padio;

// pulldown/pullup
logic inclock; // -- converted tristate to logic
logic aset; // -- converted tristate to logic
logic aclr; // -- converted tristate to logic
logic sset; // -- converted tristate to logic
logic sclr; // -- converted tristate to logic
logic outclocken; // -- converted tristate to logic
logic inclocken; // -- converted tristate to logic
logic oe; // -- converted tristate to logic

// INITIAL BLOCK
initial
begin
    // Begin of parameter checking
    if (width <= 0)
    begin
        $display("ERROR: The width parameter must be greater than 0");
        $display("Time: %0t  Instance: %m", $time);
        $stop;
    end
    // End of parameter checking
end

// COMPONENT INSTANTIATION
// ALTDDIO_IN
altddio_in u1 (
    .datain(padio),
    .inclock(inclock),
    .inclocken(inclocken),
    .aset(aset),
    .aclr(aclr),
    .sset(sset),
    .sclr(sclr),
    .dataout_h(dataout_h),
    .dataout_l(dataout_l)
);
defparam    u1.width = width,
            u1.intended_device_family = intended_device_family,
            u1.power_up_high = power_up_high;

// ALTDDIO_OUT
altddio_out u2 (
    .datain_h(datain_h),
    .datain_l(datain_l),
    .outclock(outclock),
    .oe(oe),
    .outclocken(outclocken),
    .aset(aset),
    .aclr(aclr),
    .sset(sset),
    .sclr(sclr),
    .dataout(padio),
    .oe_out(oe_out)
);
defparam    u2.width = width,
            u2.power_up_high = power_up_high,
            u2.intended_device_family = intended_device_family,
            u2.oe_reg = oe_reg,
            u2.extend_oe_disable = extend_oe_disable,
            u2.invert_output = invert_output;

// padio feeds combout port directly
assign combout = padio;
assign dqsundelayedout = padio;
endmodule // altddio_bidir

