// Created by altera_lib_mf.pl from altera_mf.v
// END OF MODULE ALTCLKLOCK


// START MODULE NAME -----------------------------------------------------------
//
// Module Name      : ALTDDIO_IN
//
// Description      : Double Data Rate (DDR) input behavioural model. Receives
//                    data on both edges of the reference clock.
//
// Limitations      : Not available for MAX device families.
//
// Expected results : Data sampled from the datain port at the rising edge of
//                    the reference clock (dataout_h) and at the falling edge of
//                    the reference clock (dataout_l).
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
module altddio_in (
    datain,    // required port, DDR input data
    inclock,   // required port, input reference clock to sample data by
    inclocken, // enable data clock
    aset,      // asynchronous set
    aclr,      // asynchronous clear
    sset,      // synchronous set
    sclr,      // synchronous clear
    dataout_h, // data sampled at the rising edge of inclock
    dataout_l  // data sampled at the falling edge of inclock
);

// GLOBAL PARAMETER DECLARATION
parameter width = 1;  // required parameter
parameter power_up_high = "OFF";
parameter invert_input_clocks = "OFF";
parameter intended_device_family = "Stratix";
parameter lpm_type = "altddio_in";
parameter lpm_hint = "UNUSED";

// INPUT PORT DECLARATION
input [width-1:0] datain;
input inclock;
input inclocken;
input aset;
input aclr;
input sset;
input sclr;

// OUTPUT PORT DECLARATION
output [width-1:0] dataout_h;
output [width-1:0] dataout_l;

// REGISTER AND VARIABLE DECLARATION
reg [width-1:0] dataout_h_tmp;
reg [width-1:0] dataout_l_tmp;
reg [width-1:0] datain_latched;
reg is_stratix;
reg is_maxii;
reg is_stratixiii;
reg is_inverted_output_ddio;

ALTERA_DEVICE_FAMILIES dev ();

// pulldown/pullup
logic aset; // default aset to 0 // -- converted tristate to logic
logic aclr; // default aclr to 0 // -- converted tristate to logic
logic sset; // default sset to 0 // -- converted tristate to logic
logic sclr; // default sclr to 0 // -- converted tristate to logic
logic inclocken; // default inclocken to 1 // -- converted tristate to logic

// INITIAL BLOCK
initial
begin
    is_stratixiii = dev.FEATURE_FAMILY_STRATIXIII(intended_device_family);
    is_stratix = dev.FEATURE_FAMILY_STRATIX(intended_device_family);
    is_maxii = dev.FEATURE_FAMILY_MAXII(intended_device_family);
    is_inverted_output_ddio = dev.FEATURE_FAMILY_HAS_INVERTED_OUTPUT_DDIO(intended_device_family);

    // Begin of parameter checking
    if (width <= 0)
    begin
        $display("ERROR: The width parameter must be greater than 0");
        $display("Time: %0t  Instance: %m", $time);
        $stop;
    end

    if (dev.IS_VALID_FAMILY(intended_device_family) == 0)
    begin
        $display ("Error! Unknown INTENDED_DEVICE_FAMILY=%s.", intended_device_family);
        $display("Time: %0t  Instance: %m", $time);
        $stop;
    end

    if (!(is_stratix &&
        !(is_maxii)))
    begin
        $display("ERROR: Megafunction altddio_in is not supported in %s.", intended_device_family);
        $display("Time: %0t  Instance: %m", $time);
        $stop;
    end
    // End of parameter checking

    // if power_up_high parameter is turned on, registers power up
    // to '1', otherwise '0'
    dataout_h_tmp = (power_up_high == "ON") ? {width{1'b1}} : {width{1'b0}};
    dataout_l_tmp = (power_up_high == "ON") ? {width{1'b1}} : {width{1'b0}};
    datain_latched = (power_up_high == "ON") ? {width{1'b1}} : {width{1'b0}};
end

// input reference clock, sample data
always @ (posedge inclock or posedge aclr or posedge aset)
begin
    if (aclr)
    begin
        dataout_h_tmp <= {width{1'b0}};
        dataout_l_tmp <= {width{1'b0}};
    end
    else if (aset)
    begin
        dataout_h_tmp <= {width{1'b1}};
        dataout_l_tmp <= {width{1'b1}};
    end
    // if not being set or cleared
    else if (inclocken == 1'b1)
    begin
        if (invert_input_clocks == "ON")
        begin
            if (sclr)
                datain_latched <= {width{1'b0}};
            else if (sset)
                datain_latched <= {width{1'b1}};
            else
                datain_latched <= datain;
        end
        else
        begin
            if (is_stratixiii)
            begin
                if (sclr)
                begin
                    dataout_h_tmp <= {width{1'b0}};
                    dataout_l_tmp <= {width{1'b0}};
                end
                else if (sset)
                begin
                    dataout_h_tmp <= {width{1'b1}};
                    dataout_l_tmp <= {width{1'b1}};
                end
                else
                begin
                    dataout_h_tmp <= datain;
                    dataout_l_tmp <= datain_latched;
                end
            end
            else
            begin
                if (sclr)
                begin
                    dataout_h_tmp <= {width{1'b0}};
                end
                else if (sset)
                begin
                    dataout_h_tmp <= {width{1'b1}};
                end
                else
                begin
                    dataout_h_tmp <= datain;
                end
                dataout_l_tmp <= datain_latched;
            end
        end
    end
end

always @ (negedge inclock or posedge aclr or posedge aset)
begin
    if (aclr)
    begin
        datain_latched <= {width{1'b0}};
    end
    else if (aset)
    begin
        datain_latched <= {width{1'b1}};
    end
    // if not being set or cleared
    else
    begin
        if ((is_stratix &&
        !(is_maxii)))
        begin
            if (inclocken == 1'b1)
            begin
                if (invert_input_clocks == "ON")
                begin
                    if (is_stratixiii)
                    begin
                        if (sclr)
                        begin
                            dataout_h_tmp <= {width{1'b0}};
                            dataout_l_tmp <= {width{1'b0}};
                        end
                        else if (sset)
                        begin
                            dataout_h_tmp <= {width{1'b1}};
                            dataout_l_tmp <= {width{1'b1}};
                        end
                        else
                        begin
                            dataout_h_tmp <= datain;
                            dataout_l_tmp <= datain_latched;
                        end
                    end
                    else
                    begin
                        if (sclr)
                        begin
                            dataout_h_tmp <= {width{1'b0}};
                        end
                        else if (sset)
                        begin
                            dataout_h_tmp <= {width{1'b1}};
                        end
                        else
                        begin
                            dataout_h_tmp <= datain;
                        end
                        dataout_l_tmp <= datain_latched;
                    end
                end
                else
                begin
                    if (sclr)
                    begin
                        datain_latched <= {width{1'b0}};
                    end
                    else if (sset)
                    begin
                        datain_latched <= {width{1'b1}};
                    end
                    else
                    begin
                        datain_latched <= datain;
                    end
                end
            end
        end
        else
        begin
            if (invert_input_clocks == "ON")
            begin
                dataout_h_tmp <= datain;
                dataout_l_tmp <= datain_latched;
            end
            else
                datain_latched <= datain;
        end
    end
end

// assign registers to output ports
assign dataout_l = dataout_l_tmp;
assign dataout_h = dataout_h_tmp;

endmodule // altddio_in

