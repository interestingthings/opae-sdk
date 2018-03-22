// Created by altera_lib_mf.pl from altera_mf.v


//START_MODULE_NAME-------------------------------------------------------------
//
// Module Name     :   altfp_mult
//
// Description     :   Parameterized floating point multiplier megafunction.
//                     This module implements IEEE-754 Compliant Floating Poing
//                     Multiplier.It supports Single Precision, Single Extended
//                     Precision and Double Precision floating point
//                     multiplication.
//
// Limitation      :   Fixed clock latency with 4 clock cycle delay.
//
// Results expected:   result of multiplication and the result's status bits
//
//END_MODULE_NAME---------------------------------------------------------------

// BEGINNING OF MODULE
`timescale 1 ps / 1 ps

/*verilator lint_off CASEX*/
/*verilator lint_off COMBDLY*/
/*verilator lint_off INITIALDLY*/
/*verilator lint_off LITENDIAN*/
/*verilator lint_off MULTIDRIVEN*/
/*verilator lint_off UNOPTFLAT*/
/*verilator lint_off BLKANDNBLK*/
module altfp_mult (
    clock,      // Clock input to the multiplier.(Required)
    clk_en,     // Clock enable for the multiplier.
    aclr,       // Asynchronous clear for the multiplier.
    dataa,      // Data input to the multiplier.(Required)
    datab,      // Data input to the multiplier.(Required)
    result,     // Multiplier output port.(Required)
    overflow,   // Overflow port for the multiplier.
    underflow,  // Underflow port for the multiplier.
    zero,       // Zero port for the multiplier.
    denormal,   // Denormal port for the multiplier.
    indefinite, // Indefinite port for the multiplier.
    nan         // Nan port for the multiplier.
);

// GLOBAL PARAMETER DECLARATION
    // Specifies the value of the exponent, Minimum = 8, Maximum = 31
    parameter width_exp = 8;
    // Specifies the value of the mantissa, Minimum = 23, Maximum = 52
    parameter width_man = 23;
    // Specifies whether to use dedicated multiplier circuitry.
    parameter dedicated_multiplier_circuitry = "AUTO";
    parameter reduced_functionality = "NO";
    parameter pipeline = 5;
    parameter denormal_support = "YES";
    parameter exception_handling = "YES";
    parameter lpm_hint = "UNUSED";
    parameter lpm_type = "altfp_mult";

// LOCAL_PARAMETERS_BEGIN

    //clock latency
    parameter LATENCY = pipeline -1;
    // Sum of mantissa's width and exponent's width
    parameter WIDTH_MAN_EXP = width_exp + width_man;

// LOCAL_PARAMETERS_END

// INPUT PORT DECLARATION
    input [WIDTH_MAN_EXP : 0] dataa;
    input [WIDTH_MAN_EXP : 0] datab;
    input clock;
    input clk_en;
    input aclr;

// OUTPUT PORT DECLARATION
    output [WIDTH_MAN_EXP : 0] result;
    output overflow;
    output underflow;
    output zero;
    output denormal;
    output indefinite;
    output nan;

// INTERNAL REGISTERS DECLARATION
    reg[width_man : 0] mant_dataa;
    reg[width_man : 0] mant_datab;
    reg[(2 * width_man) + 1 : 0] mant_result;
    reg cout;
    reg zero_mant_dataa;
    reg zero_mant_datab;
    reg zero_dataa;
    reg zero_datab;
    reg inf_dataa;
    reg inf_datab;
    reg nan_dataa;
    reg nan_datab;
    reg den_dataa;
    reg den_datab;
    reg no_multiply;
    reg mant_result_msb;
    reg no_rounding;
    reg sticky_bit;
    reg round_bit;
    reg guard_bit;
    reg carry;
    reg[WIDTH_MAN_EXP : 0] result_pipe[LATENCY : 0];
    reg[LATENCY : 0] overflow_pipe;
    reg[LATENCY : 0] underflow_pipe;
    reg[LATENCY : 0] zero_pipe;
    reg[LATENCY : 0] denormal_pipe;
    reg[LATENCY : 0] indefinite_pipe;
    reg[LATENCY : 0] nan_pipe;
    reg[WIDTH_MAN_EXP : 0] temp_result;
    reg overflow_bit;
    reg underflow_bit;
    reg zero_bit;
    reg denormal_bit;
    reg indefinite_bit;
    reg nan_bit;

// INTERNAL TRI DECLARATION
    logic clk_en; // -- converted tristate to logic
    logic aclr; // -- converted tristate to logic

// LOCAL INTEGER DECLARATION
    integer exp_dataa;
    integer exp_datab;
    integer exp_result;

    // loop counter
    integer i0;
    integer i1;
    integer i2;
    integer i3;
    integer i4;
    integer i5;

// TASK DECLARATION

    // Add up two bits to get the result(<mantissa of datab> + <temporary result
    // of mantissa's multiplication>)
    //Also output the carry bit.
    task add_bits;
        // Value to be added to the temporary result of mantissa's multiplication.
        input  [width_man : 0] val1;
        // temporary result of mantissa's multiplication.
        inout  [(2 * width_man) + 1 : 0] temp_mant_result;
        output cout; // carry out bit

        reg co; // temporary storage to store the carry out bit

        integer i0_tmp;

        begin
            co = 1'b0;
            for(i0 = 0; i0 <= width_man; i0 = i0 + 1)
            begin
            i0_tmp = i0 + width_man + 1;

                // if the carry out bit from the previous bit addition is 1'b0
                if (co == 1'b0)
                begin
                    if (val1[i0] != temp_mant_result[i0_tmp])
                    begin
                        temp_mant_result[i0_tmp] = 1'b1;
                    end
                    else
                    begin
                        co = val1[i0] & temp_mant_result[i0_tmp];
                        temp_mant_result[i0_tmp] = 1'b0;
                    end
                end
                else // if (co == 1'b1)
                begin
                    co = val1[i0] | temp_mant_result[i0_tmp];
                    if (val1[i0] != temp_mant_result[i0_tmp])
                    begin
                        temp_mant_result[i0_tmp] = 1'b0;
                    end
                    else
                    begin
                        temp_mant_result[i0_tmp] = 1'b1;
                    end
                end
            end // end of for loop
            cout = co;
        end
    endtask // add_bits

// FUNCTON DECLARATION

    // Check whether the all the bits from index <index1> to <index2> is 1'b1
    // Return 1'b1 if true, otherwise return 1'b0
    function bit_all_0;
        input [(2 * width_man) + 1: 0] val;
        input index1;
        integer index1;
        input index2;
        integer index2;

        reg all_0;  //temporary storage to indicate whether all the currently
                    // checked bits are 1'b0
        begin
            begin : LOOP_1
                all_0 = 1'b1;
                for (i1 = index1; i1 <= index2; i1 = i1 + 1)
                begin
                    if ((val[i1]) == 1'b1)
                    begin
                        all_0 = 1'b0;
                        disable LOOP_1;  //break the loop to stop checking
                    end
                end
            end
            bit_all_0 = all_0;
        end
    endfunction // bit_all_0

    // Calculate the exponential value (<base_number> power of <exponent_number>)
    function integer exponential_value;
        input base_number;
        input exponent_number;
        integer base_number;
        integer exponent_number;
        integer value; // temporary storage to store the exponential value

        begin
            value = 1;
            for (i2 = 0; i2 < exponent_number; i2 = i2 + 1)
            begin
                value = base_number * value;
            end
            exponential_value = value;
        end
    endfunction // exponential_value

// INITIAL CONSTRUCT BLOCK
    initial
    begin : INITIALIZATION
        for(i3 = LATENCY; i3 >= 0; i3 = i3 - 1)
        begin
            result_pipe[i3] = 0;
            overflow_pipe[i3] = 1'b0;
            underflow_pipe[i3] = 1'b0;
            zero_pipe[i3] = 1'b0;
            denormal_pipe[i3] = 1'b0;
            indefinite_pipe[i3] = 1'b0;
            nan_pipe[i3] = 1'b0;
        end

        // Check for illegal mode setting
        if (WIDTH_MAN_EXP >= 64)
        begin
            $display("ERROR: The sum of width_exp(%d) and width_man(%d) must be less 64!", width_exp, width_man);
            $finish;
        end
        if (width_exp < 8)
        begin
            $display("ERROR: width_exp(%d) must be at least 8!", width_exp);
            $finish;
        end
        if (width_man < 23)
        begin
            $display("ERROR: width_man(%d) must be at least 23!", width_man);
            $finish;
        end
        if (~((width_exp >= 11) || ((width_exp == 8) && (width_man == 23))))
        begin
            $display("ERROR: Found width_exp(%d) inside the range of Single Precision. width_exp must be 8 and width_man must be 23 for Single Presicion!", width_exp);
            $finish;
        end
        if (~((width_man >= 31) || ((width_exp == 8) && (width_man == 23))))
        begin
            $display("ERROR: Found width_man(%d) inside the range of Single Precision. width_exp must be 8 and width_man must be 23 for Single Presicion!", width_man);
            $finish;
        end
        if (width_exp >= width_man)
        begin
            $display("ERROR: width_exp(%d) must be less than width_man(%d)!", width_exp, width_man);
            $finish;
        end
        if ((pipeline != 5) && (pipeline != 6) && (pipeline != 10) && (pipeline != 11))
        begin
            $display("ERROR: The legal value for PIPELINE is 5, 6, 10 or 11!");
            $finish;
        end

        if ((reduced_functionality != "NO") && (reduced_functionality != "YES"))
        begin
            $display("ERROR: reduced_functionality value must be \"YES\" or \"NO\"!");
            $finish;
        end

        if ((denormal_support != "NO") && (denormal_support != "YES"))
        begin
            $display("ERROR: denormal_support value must be \"YES\" or \"NO\"!");
            $finish;
        end

        if (reduced_functionality != "NO")
        begin
            $display("Info: The Clearbox support is available for reduced functionality Floating Point Multiplier.");
        end
    end // INITIALIZATION

// ALWAYS CONSTRUCT BLOCK

    // multiplication
    always @(dataa or datab)
    begin : MULTIPLY_FP
        temp_result = {(WIDTH_MAN_EXP + 1){1'b0}};
        overflow_bit = 1'b0;
        underflow_bit = 1'b0;
        zero_bit = 1'b0;
        denormal_bit = 1'b0;
        indefinite_bit = 1'b0;
        nan_bit = 1'b0;
        mant_result = {((2 * width_man) + 2){1'b0}};
        exp_dataa = 0;
        exp_datab = 0;
        // Set the exponential value
        exp_dataa = dataa[width_exp + width_man -1:width_man];
        exp_datab = datab[width_exp + width_man -1:width_man];

        zero_mant_dataa = 1'b1;
        // Check whether the mantissa for dataa is zero
        begin : LOOP_3
            for (i4 = 0; i4 <= width_man - 1; i4 = i4 + 1)
            begin
                if ((dataa[i4]) == 1'b1)
                begin
                    zero_mant_dataa = 1'b0;
                    disable LOOP_3;
                end
            end
        end // LOOP_3
        zero_mant_datab = 1'b1;
        // Check whether the mantissa for datab is zero
        begin : LOOP_4
            for (i4 = 0; i4 <= width_man -1; i4 = i4 + 1)
            begin
                if ((datab[i4]) == 1'b1)
                begin
                    zero_mant_datab = 1'b0;
                    disable LOOP_4;
                end
            end
        end // LOOP_4
        zero_dataa = 1'b0;
        den_dataa = 1'b0;
        inf_dataa = 1'b0;
        nan_dataa = 1'b0;
        // Check whether dataa is special input
        if (exp_dataa == 0)
        begin
            if ((zero_mant_dataa == 1'b1)
                || (reduced_functionality != "NO"))
            begin
                zero_dataa = 1'b1;  // dataa is zero
            end
            else
            begin
                if (denormal_support == "YES")
                    den_dataa = 1'b1; // dataa is denormalized
                else
                    zero_dataa = 1'b1; // dataa is zero
            end
        end
        else if (exp_dataa == (exponential_value(2, width_exp) - 1))
        begin
            if (zero_mant_dataa == 1'b1)
            begin
                inf_dataa = 1'b1;  // dataa is infinity
            end
            else
            begin
                nan_dataa = 1'b1; // dataa is Nan
            end
        end
        zero_datab = 1'b0;
        den_datab = 1'b0;
        inf_datab = 1'b0;
        nan_datab = 1'b0;
        // Check whether datab is special input
        if (exp_datab == 0)
        begin
            if ((zero_mant_datab == 1'b1)
                || (reduced_functionality != "NO"))
            begin
                zero_datab = 1'b1; // datab is zero
            end
            else
            begin
                if (denormal_support == "YES")
                    den_datab = 1'b1; // datab is denormalized
                else
                    zero_datab = 1'b1; // datab is zero
            end
        end
        else if (exp_datab == (exponential_value(2, width_exp) - 1))
        begin
            if (zero_mant_datab == 1'b1)
            begin
                inf_datab = 1'b1; // datab is infinity
            end
            else
            begin
                nan_datab = 1'b1; // datab is Nan
            end
        end
        no_multiply = 1'b0;
        // Set status flag if special input exists
        if (nan_dataa || nan_datab || (inf_dataa && zero_datab) ||
            (inf_datab && zero_dataa))
        begin
            nan_bit = 1'b1; // NaN
            for (i4 = width_man - 1; i4 <= WIDTH_MAN_EXP - 1; i4 = i4 + 1)
            begin
                temp_result[i4] = 1'b1;
            end
            no_multiply = 1'b1; // no multiplication is needed.
        end
        else if (zero_dataa)
        begin
            zero_bit = 1'b1; // Zero
            temp_result[WIDTH_MAN_EXP : 0] = 0;
            no_multiply = 1'b1;
        end
        else if (zero_datab)
        begin
            zero_bit = 1'b1; // Zero
            temp_result[WIDTH_MAN_EXP : 0] = 0;
            no_multiply = 1'b1;
        end
        else if (inf_dataa)
        begin
            overflow_bit = 1'b1; // Overflow
            temp_result[WIDTH_MAN_EXP : 0] = dataa;
            no_multiply = 1'b1;
        end
        else if (inf_datab)
        begin
            overflow_bit = 1'b1; // Overflow
            temp_result[WIDTH_MAN_EXP : 0] = datab;
            no_multiply = 1'b1;
        end
        // if multiplication needed
        if (no_multiply == 1'b0)
        begin
            // Perform exponent operation
            exp_result = exp_dataa + exp_datab - (exponential_value(2, width_exp -1) -1);
            // First operand for multiplication
            mant_dataa[width_man : 0] = {1'b1, dataa[width_man -1 : 0]};
            // Second operand for multiplication
            mant_datab[width_man : 0] = {1'b1, datab[width_man -1 : 0]};
            // Multiply the mantissas using add and shift algorithm
            for (i4 = 0; i4 <= width_man; i4 = i4 + 1)
            begin
                cout = 1'b0;
                if ((mant_dataa[i4]) == 1'b1)
                begin
                    add_bits(mant_datab, mant_result, cout);
                end
                mant_result = mant_result >> 1;
                mant_result[2*width_man + 1] = cout;
            end
            sticky_bit = 1'b0;
            mant_result_msb = mant_result[2*width_man + 1];
            // Normalize the Result
            if (mant_result_msb == 1'b1)
            begin
                sticky_bit = mant_result[0]; // Needed for rounding operation.
                mant_result = mant_result >> 1;
                exp_result = exp_result + 1;
            end
            round_bit = mant_result[width_man - 1];
            guard_bit = mant_result[width_man];
            no_rounding = 1'b0;
            // Check whether should perform rounding or not
            if (round_bit == 1'b0)
            begin
                no_rounding = 1'b1; // No rounding is needed
            end
            else
            begin
                if (reduced_functionality == "NO")
                begin
                    for(i4 = 0; i4 <= width_man - 2; i4 = i4 + 1)
                    begin
                        sticky_bit = sticky_bit | mant_result[i4];
                    end
                end
                else
                begin
                    sticky_bit = (mant_result[width_man - 2] &
                                    mant_result_msb);
                end
                if ((sticky_bit == 1'b0) && (guard_bit == 1'b0))
                begin
                    no_rounding = 1'b1;
                end
            end
            // Perform rounding
            if (no_rounding == 1'b0)
            begin
                carry = 1'b1;
                for(i4 = width_man; i4 <= 2 * width_man + 1; i4 = i4 + 1)
                begin
                    if (carry == 1'b1)
                    begin
                        if (mant_result[i4] == 1'b0)
                        begin
                            mant_result[i4] = 1'b1;
                            carry = 1'b0;
                        end
                        else
                        begin
                            mant_result[i4] = 1'b0;
                        end
                    end
                end
                // If the mantissa of the result is 10.00.. after rounding, right shift the
                // mantissa of the result by 1 bit and increase the exponent of the result by 1.
                if (mant_result[(2 * width_man) + 1] == 1'b1)
                begin
                    mant_result = mant_result >> 1;
                    exp_result = exp_result + 1;
                end
            end
            // Normalize the Result
            if ((!bit_all_0(mant_result, 0, (2 * width_man) + 1)) &&
                (mant_result[2 * width_man] == 1'b0))
            begin
                while ((mant_result[2 * width_man] == 1'b0) &&
                        (exp_result != 0))
                begin
                    mant_result = mant_result << 1;
                    exp_result = exp_result - 1;
                end
            end
            else if ((exp_result < 0) && (exp_result >= -(2*width_man)))
            begin
                while(exp_result != 0)
                begin
                    mant_result = mant_result >> 1;
                    exp_result = exp_result + 1;
                end
            end
            // Set status flag "indefinite" if normal * denormal
            // (ignore other status port since we dont care the output
            if (den_dataa || den_datab)
            begin
                indefinite_bit = 1'b1; // Indefinite
            end
            else if (exp_result >= (exponential_value(2, width_exp) -1))
            begin
                overflow_bit = 1'b1; // Overflow
            end
            else if (exp_result < 0)
            begin
                underflow_bit = 1'b1; // Underflow
                zero_bit = 1'b1; // Zero
            end
            else if (exp_result == 0)
            begin
                underflow_bit = 1'b1; // Underflow

                if (bit_all_0(mant_result, width_man + 1, 2 * width_man))
                begin
                    zero_bit = 1'b1; // Zero
                end
                else
                begin
                    denormal_bit = 1'b1; // Denormal
                end
            end
            // Get result's mantissa
            if (exp_result < 0) // Result underflow
            begin
                for(i4 = 0; i4 <= width_man - 1; i4 = i4 + 1)
                begin
                    temp_result[i4] = 1'b0;
                end
            end
            else if (exp_result == 0) // Denormalized result
            begin
                if ((reduced_functionality == "NO") && (denormal_support == "YES"))
                begin
                    temp_result[width_man - 1 : 0] = mant_result[2 * width_man : width_man + 1];
                end
                else
                begin
                    temp_result[width_man - 1 : 0] = 0;
                    zero_bit = 1'b1;
                end
            end
            // Result overflow
            else if (exp_result >= exponential_value(2, width_exp) -1)
            begin
                temp_result[width_man - 1 : 0] = {width_man{1'b0}};
            end
            else // Normalized result
            begin
                temp_result[width_man - 1 : 0] = mant_result[(2 * width_man - 1) : width_man];
            end
            // Get result's exponent
            if (exp_result == 0)
            begin
                for(i4 = width_man; i4 <= WIDTH_MAN_EXP - 1; i4 = i4 + 1)
                begin
                    temp_result[i4] = 1'b0;
                end
            end
            else if (exp_result >= (exponential_value(2, width_exp) -1))
            begin
                for(i4 = width_man; i4 <= WIDTH_MAN_EXP - 1; i4 = i4 + 1)
                begin
                    temp_result[i4] = 1'b1;
                end
            end
            else
            begin
                // Convert integer to binary bits
                for(i4 = width_man; i4 <= WIDTH_MAN_EXP - 1; i4 = i4 + 1)
                begin
                    if ((exp_result % 2) == 1)
                    begin
                        temp_result[i4] = 1'b1;
                    end
                    else
                    begin
                        temp_result[i4] = 1'b0;
                    end
                    exp_result = exp_result / 2;
                end
            end
        end // end of if (no_multiply == 1'b0)
        // Get result's sign bit
        temp_result[WIDTH_MAN_EXP] = dataa[WIDTH_MAN_EXP] ^ datab[WIDTH_MAN_EXP];

    end // MULTIPLY_FP

    // Pipelining registers.
    always @(posedge clock or posedge aclr)
    begin : PIPELINE_REGS
        if (aclr == 1'b1)
        begin
            for (i5 = LATENCY; i5 >= 0; i5 = i5 - 1)
            begin
                result_pipe[i5] <= {WIDTH_MAN_EXP{1'b0}};
                overflow_pipe[i5] <= 1'b0;
                underflow_pipe[i5] <= 1'b0;
                zero_pipe[i5] <= 1'b1;
                denormal_pipe[i5] <= 1'b0;
                indefinite_pipe[i5] <= 1'b0;
                nan_pipe[i5] <= 1'b0;
            end
            // clear all the output ports to 1'b0
        end
        else if (clk_en == 1'b1)
        begin
            result_pipe[0] <= temp_result;
            overflow_pipe[0] <= overflow_bit;
            underflow_pipe[0] <= underflow_bit;
            zero_pipe[0] <= zero_bit;
            denormal_pipe[0] <= denormal_bit;
            indefinite_pipe[0] <= indefinite_bit;
            nan_pipe[0] <= nan_bit;

            // Create latency for the output result
            for(i5=LATENCY; i5 >= 1; i5 = i5 - 1)
            begin
                result_pipe[i5] <= result_pipe[i5 - 1];
                overflow_pipe[i5] <= overflow_pipe[i5 - 1];
                underflow_pipe[i5] <= underflow_pipe[i5 - 1];
                zero_pipe[i5] <= zero_pipe[i5 - 1];
                denormal_pipe[i5] <= denormal_pipe[i5 - 1];
                indefinite_pipe[i5] <= indefinite_pipe[i5 - 1];
                nan_pipe[i5] <= nan_pipe[i5 - 1];
            end
        end
    end // PIPELINE_REGS

assign result = result_pipe[LATENCY];
assign overflow = overflow_pipe[LATENCY];
assign underflow = ((reduced_functionality == "YES") || (denormal_support == "YES")) ? underflow_pipe[LATENCY] : 1'b0;
assign zero = (reduced_functionality == "NO") ? zero_pipe[LATENCY] : 1'b0;
assign denormal = ((reduced_functionality == "NO") && (denormal_support == "YES")) ? denormal_pipe[LATENCY] : 1'b0;
assign indefinite = ((reduced_functionality == "NO") && (denormal_support == "YES")) ? indefinite_pipe[LATENCY] : 1'b0;
assign nan = nan_pipe[LATENCY];

endmodule //altfp_mult

