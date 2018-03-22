// Created by altera_lib_mf.pl from altera_mf.v

//START_MODULE_NAME------------------------------------------------------------
//
// Module Name     :  altaccumulate
//
// Description     :  Parameterized accumulator megafunction. The accumulator
// performs an add function or a subtract function based on the add_sub
// parameter. The input data can be signed or unsigned.
//
// Limitation      : n/a
//
// Results expected:  result - The results of add or subtract operation. Output
//                             port [width_out-1 .. 0] wide.
//                    cout   - The cout port has a physical interpretation as
//                             the carry-out (borrow-in) of the MSB. The cout
//                             port is most meaningful for detecting overflow
//                             in unsigned operations. The cout port operates
//                             in the same manner for signed and unsigned
//                             operations.
//                    overflow - Indicates the accumulator is overflow.
//
//END_MODULE_NAME--------------------------------------------------------------

// BEGINNING OF MODULE

`timescale 1 ps / 1 ps

/*verilator lint_off CASEX*/
/*verilator lint_off COMBDLY*/
/*verilator lint_off INITIALDLY*/
/*verilator lint_off LITENDIAN*/
/*verilator lint_off MULTIDRIVEN*/
/*verilator lint_off UNOPTFLAT*/
/*verilator lint_off BLKANDNBLK*/
module altaccumulate (cin, data, add_sub, clock, sload, clken, sign_data, aclr,
                        result, cout, overflow);

    parameter width_in = 4;     // Required
    parameter width_out = 8;    // Required
    parameter lpm_representation = "UNSIGNED";
    parameter extra_latency = 0;
    parameter use_wys = "ON";
    parameter lpm_hint = "UNUSED";
    parameter lpm_type = "altaccumulate";

    // INPUT PORT DECLARATION
    input cin;
    input [width_in-1:0] data;  // Required port
    input add_sub;              // Default = 1
    input clock;                // Required port
    input sload;                // Default = 0
    input clken;                // Default = 1
    input sign_data;            // Default = 0
    input aclr;                 // Default = 0

    // OUTPUT PORT DECLARATION
    output [width_out-1:0] result;  //Required port
    output cout;
    output overflow;

    // INTERNAL REGISTERS DECLARATION
    reg [width_out:0] temp_sum;
    reg overflow_int;
    reg cout_int;


    reg [width_out+1:0] result_int;
    reg [(width_out - width_in) : 0] zeropad;

    reg borrow;
    reg cin_int;

    reg [width_out-1:0] fb_int;
    reg [width_out -1:0] data_int;

    reg [width_out+1:0] result_pipe [extra_latency:0];
    reg [width_out+1:0] result_full;
    reg [width_out+1:0] result_full2;

    reg a;

    // INTERNAL WIRE DECLARATION
    wire [width_out:0] temp_sum_wire;
    wire cout;
    wire cout_int_wire;
    wire cout_delayed_wire;
    wire overflow_int_wire;
    wire [width_out+1:0] result_int_wire;

    // INTERNAL TRI DECLARATION

    logic aclr_int; // -- converted tristate to logic
    logic sign_data_int; // -- converted tristate to logic
    logic sload_int; // -- converted tristate to logic

    logic clken_int; // -- converted tristate to logic
    logic add_sub_int; // -- converted tristate to logic

    // LOCAL INTEGER DECLARATION
    integer head;
    integer i;

    // INITIAL CONSTRUCT BLOCK
    initial
    begin

        // Checking for invalid parameters
        if( width_in <= 0 )
        begin
            $display("Error! Value of width_in parameter must be greater than 0.");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if( width_out <= 0 )
        begin
            $display("Error! Value of width_out parameter must be greater than 0.");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if( extra_latency > width_out )
        begin
            $display("Info: Value of extra_latency parameter should be lower than width_out parameter for better performance/utilization.");
        end

        if( width_in > width_out )
        begin
            $display("Error! Value of width_in parameter should be lower than or equal to width_out.");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        result_full = 0;
        head = 0;
        result_int = 0;
        for (i = 0; i <= extra_latency; i = i +1)
        begin
            result_pipe [i] = 0;
        end
    end

    // ALWAYS CONSTRUCT BLOCK
    always @(posedge clock or posedge aclr_int)
    begin

        if (aclr_int == 1)
        begin
            result_int <= 0;
            result_full <= 0;
            head <= 0;
            for (i = 0; i <= extra_latency; i = i +1)
            begin
                result_pipe [i] <= 0;
            end

        end
        else
        begin
            if (clken_int == 1)
            begin
                //get result from output register
                if (extra_latency > 0)
                begin
                    result_pipe [head] <= {
                                            result_int [width_out+1],
                                            {cout_int_wire, result_int [width_out-1:0]}
                                        };

                    head <= (head + 1) % (extra_latency);

                end
                else
                begin
                    result_full <= {overflow_int_wire, {cout_int_wire, temp_sum_wire [width_out-1:0]}};

                end

                result_int <= {overflow_int_wire, {cout_int_wire, temp_sum_wire [width_out-1:0]}};
            end
        end
    end

    always @ (result_pipe[head] or head)
    begin
        if (extra_latency > 0)
                result_full = result_pipe [head];

    end

    always @ (data or cin or add_sub_int or sign_data_int or
                result_int_wire [width_out -1:0] or sload_int)
    begin

        if ((lpm_representation == "SIGNED") || (sign_data_int == 1))
        begin
            zeropad = (data [width_in-1] ==0) ? 0 : -1;
        end
        else
        begin
            zeropad = 0;
        end

        fb_int = (sload_int == 1'b1) ? 0 : result_int_wire [width_out-1:0];
        data_int = {zeropad, data};

        if ((add_sub_int == 1) || (sload_int == 1))
        begin
            cin_int = ((sload_int == 1'b1) ? 0 : ((cin === 1'b0 /* converted x or z to 1'b0 */) ? 0 : cin));
            temp_sum = fb_int + data_int + cin_int;
            cout_int = temp_sum [width_out];
        end
        else
        begin
            cin_int = (cin === 1'b0 /* converted x or z to 1'b0 */) ? 1 : cin;
            borrow = ~cin_int;

            temp_sum = fb_int - data_int - borrow;

            result_full2 = data_int + borrow;
            cout_int = (fb_int >= result_full2) ? 1 : 0;
        end

        if ((lpm_representation == "SIGNED") || (sign_data_int == 1))
        begin
            a = (data [width_in-1] ~^ fb_int [width_out-1]) ^ (~add_sub_int);
            overflow_int = a & (fb_int [width_out-1] ^ temp_sum[width_out-1]);
        end
        else
        begin
            overflow_int = (add_sub_int == 1) ? cout_int : ~cout_int;
        end

        if (sload_int == 1)
        begin
            cout_int = !add_sub_int;
            overflow_int = 0;
        end

    end

    // CONTINOUS ASSIGNMENT

    // Get the input data and control signals.
    assign sign_data_int = sign_data;
    assign sload_int =  sload;
    assign add_sub_int = add_sub;

    assign clken_int = clken;
    assign aclr_int = aclr;
    assign result_int_wire = result_int;
    assign temp_sum_wire = temp_sum;
    assign cout_int_wire = cout_int;
    assign overflow_int_wire = overflow_int;
    assign cout = (extra_latency == 0) ? cout_int_wire : cout_delayed_wire;
    assign cout_delayed_wire = result_full[width_out];
    assign result = result_full [width_out-1:0];
    assign overflow = result_full [width_out+1];

endmodule   // End of altaccumulate

