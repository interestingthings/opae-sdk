// Created by altera_lib_mf.pl from altera_mf.v
// END MODULE ALTDDIO_IN

// START MODULE NAME -----------------------------------------------------------
//
// Module Name      : ALTDDIO_OUT
//
// Description      : Double Data Rate (DDR) output behavioural model.
//                    Transmits data on both edges of the reference clock.
//
// Limitations      : Not available for MAX device families.
//
// Expected results : Double data rate output on dataout.
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
module altddio_out (
    datain_h,   // required port, data input for the rising edge of outclock
    datain_l,   // required port, data input for the falling edge of outclock
    outclock,   // required port, input reference clock to output data by
    outclocken, // clock enable signal for outclock
    aset,       // asynchronous set
    aclr,       // asynchronous clear
    sset,       // synchronous set
    sclr,       // synchronous clear
    oe,         // output enable for dataout
    dataout,    // DDR data output,
    oe_out      // DDR OE output,
);

// GLOBAL PARAMETER DECLARATION
parameter width = 1; // required parameter
parameter power_up_high = "OFF";
parameter oe_reg = "UNUSED";
parameter extend_oe_disable = "UNUSED";
parameter intended_device_family = "Stratix";
parameter invert_output = "OFF";
parameter lpm_type = "altddio_out";
parameter lpm_hint = "UNUSED";

// INPUT PORT DECLARATION
input [width-1:0] datain_h;
input [width-1:0] datain_l;
input outclock;
input outclocken;
input aset;
input aclr;
input sset;
input sclr;
input oe;

// OUTPUT PORT DECLARATION
output [width-1:0] dataout;
output [width-1:0] oe_out;

// REGISTER, NET AND VARIABLE DECLARATION
wire stratix_oe;
wire output_enable;
reg  oe_rgd;
reg  oe_reg_ext;
reg  [width-1:0] dataout;
reg  [width-1:0] dataout_h;
reg  [width-1:0] dataout_l;
reg  [width-1:0] dataout_tmp;
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
logic outclocken; // default outclocken to 1 // -- converted tristate to logic
logic oe;   // default oe to 1 // -- converted tristate to logic

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
        $display("ERROR: Megafunction altddio_out is not supported in %s.", intended_device_family);
        $display("Time: %0t  Instance: %m", $time);
        $stop;
    end

    // End of parameter checking

    // if power_up_high parameter is turned on, registers power up to '1'
    // else to '0'
    dataout_h = (power_up_high == "ON") ? {width{1'b1}} : {width{1'b0}};
    dataout_l = (power_up_high == "ON") ? {width{1'b1}} : {width{1'b0}};
    dataout_tmp = (power_up_high == "ON") ? {width{1'b1}} : {width{1'b0}};

    if (power_up_high == "ON")
    begin
        oe_rgd = 1'b1;
        oe_reg_ext = 1'b1;
    end
    else
    begin
        oe_rgd = 1'b0;
        oe_reg_ext = 1'b0;
    end
end


// input reference clock
always @ (posedge outclock or posedge aclr or posedge aset)
begin
    if (aclr)
    begin
        dataout_h <= {width{1'b0}};
        dataout_l <= {width{1'b0}};
        dataout_tmp <= {width{1'b0}};

        oe_rgd <= 1'b0;
    end
    else if (aset)
    begin
        dataout_h <= {width{1'b1}};
        dataout_l <= {width{1'b1}};
        dataout_tmp <= {width{1'b1}};

        oe_rgd <= 1'b1;
    end
    // if clock is enabled
    else if (outclocken == 1'b1)
    begin
        if (sclr)
        begin
            dataout_h <= {width{1'b0}};
            dataout_l <= {width{1'b0}};
            dataout_tmp <= {width{1'b0}};
            oe_reg_ext <= 1'b0;
            oe_rgd <= 1'b0;
        end
        else if (sset)
        begin
            dataout_h <= {width{1'b1}};
            dataout_l <= {width{1'b1}};
            dataout_tmp <= {width{1'b1}};
            oe_reg_ext <= 1'b1;
            oe_rgd <= 1'b1;
        end
        else
        begin
			if (is_inverted_output_ddio &&
            (invert_output == "ON"))
			begin
				dataout_h <= ~datain_h;
				dataout_l <= ~datain_l;
				dataout_tmp <= ~datain_h;
			end
			else
			begin
				dataout_h <= datain_h;
				dataout_l <= datain_l;
				dataout_tmp <= datain_h;
			end

            // register the output enable signal
            oe_rgd <= oe;
        end
    end
    else
        dataout_tmp <= dataout_h;

end

// input reference clock
always @ (negedge outclock or posedge aclr or posedge aset)
begin
    if (aclr)
    begin
        oe_reg_ext <= 1'b0;
    end
    else if (aset)
    begin
        oe_reg_ext <= 1'b1;
    end
    else
    begin
        // if clock is enabled
        if (outclocken == 1'b1)
        begin
            // additional register for output enable signal
            oe_reg_ext <= oe_rgd;
        end

		dataout_tmp <= dataout_l;
    end
end

// data output
always @(dataout_tmp or output_enable)
begin
    // if output is enabled
    if (output_enable == 1'b1)
    begin
        dataout = dataout_tmp;
    end
    else // output is disabled
        dataout = {width{1'bZ}};
end

// output enable signal
assign output_enable = ((is_stratix &&
                        !(is_maxii)))
                        ? stratix_oe
                        : oe;

assign stratix_oe = (extend_oe_disable == "ON")
                    ? (oe_reg_ext & oe_rgd)
                    : ((oe_reg == "REGISTERED") && (extend_oe_disable != "ON"))
                    ? oe_rgd
                    : oe;

assign oe_out = {width{output_enable}};

endmodule // altddio_out

