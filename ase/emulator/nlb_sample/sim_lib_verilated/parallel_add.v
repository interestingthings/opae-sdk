// Created by altera_lib_mf.pl from altera_mf.v

//START_MODULE_NAME------------------------------------------------------------
//
// Module Name     :  parallel_add
//
// Description     :  Parameterized parallel adder megafunction. The data input
//                    is a concatenated group of input words.  The size
//                    parameter indicates the number of 'width'-bit words.
//
//                    Each word is added together to generate the result output.
//                    Each word is left shifted according to the shift
//                    parameter.  The shift amount is multiplied by the word
//                    index, with the least significant word being word 0.
//                    The shift for word I is (shift * I).
//
//                    The most significant word can be subtracted from the total
//                    by setting the msw_subtract parameter to 1.
//                    If the result width is less than is required to show the
//                    full result, the result output can be aligned to the MSB
//                    or the LSB of the internal result.  When aligning to the
//                    MSB, the internally calculated best_result_width is used
//                    to find the true MSB.
//                    The input data can be signed or unsigned, and the output
//                    can be pipelined.
//
// Limitations     :  Minimum data width is 1, and at least 2 words are required.
//
// Results expected:  result - The sum of all inputs.
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
module parallel_add (
    data,
    clock,
    aclr,
    clken,
    result);

    parameter width = 4;        // Required
    parameter size = 2;         // Required
    parameter widthr = 4;       // Required
    parameter shift = 0;
    parameter msw_subtract = "NO";  // or "YES"
    parameter representation = "UNSIGNED";
    parameter pipeline = 0;
    parameter result_alignment = "LSB"; // or "MSB"
    parameter lpm_type = "parallel_add";
    parameter lpm_hint = "UNUSED";

    // Maximum precision required for internal calculations.
    // This is a pessimistic estimate, but it is guaranteed to be sufficient.
    // The +30 is there only to simplify the test generator, which occasionally asks
    // for output widths far in excess of what is needed.  The excess is always less than 30.
    `define max_precision (width+size+shift*(size-1)+30)    // Result will not overflow this size

    // INPUT PORT DECLARATION
    input [width*size-1:0] data;  // Required port
    input clock;                // Required port
    input aclr;                 // Default = 0
    input clken;                // Default = 1

    // OUTPUT PORT DECLARATION
    output [widthr-1:0] result;  //Required port

    // INTERNAL REGISTER DECLARATION
    reg imsb_align;
    reg [width-1:0] idata_word;
    reg [`max_precision-1:0] idata_extended;
    reg [`max_precision-1:0] tmp_result;
    reg [widthr-1:0] resultpipe [(pipeline +1):0];

    // INTERNAL TRI DECLARATION
    logic clken_int; // -- converted tristate to logic

    // INTERNAL WIRE DECLARATION
    wire [widthr-1:0] aligned_result;
    wire [`max_precision-1:0] msb_aligned_result;

    // LOCAL INTEGER DECLARATION
    integer ni;
    integer best_result_width;
    integer pipe_ptr;

    // Note: The recommended value for WIDTHR parameter,
    //       the width of addition result, for full
    //       precision is:
    //                                                          --
    //                     ((2^WIDTH)-1) * (2^(SIZE*SHIFT)-1)
    // WIDTHR = CEIL(LOG2(-----------------------------------))
    //                                (2^SHIFT)-1
    //
    // Use CALC_PADD_WIDTHR(WIDTH, SIZE, SHIFT):
    // DEFINE CALC_PADD_WIDTHR(w, z, s) = (s == 0) ? CEIL(LOG2(z*((2^w)-1))) :
    //                                                  CEIL(LOG2(((2^w)-1) * (2^(z*s)-1) / ((2^s)-1)));
    function integer ceil_log2;
        input [`max_precision-1:0] input_num;
        integer i;
        reg [`max_precision-1:0] try_result;
        begin
            i = 0;
            try_result = 1;
            while ((try_result << i) < input_num && i < `max_precision)
                i = i + 1;
            ceil_log2 = i;
        end
    endfunction

    // INITIALIZATION
    initial
    begin
        if (widthr > `max_precision)
            $display ("Error! WIDTHR must not exceed WIDTH+SIZE+SHIFT*(SIZE-1).");
        if (size < 2)
            $display ("Error! SIZE must be greater than 1.");

        if (shift == 0)
        begin
            best_result_width = width;
            if (size > 1)
                best_result_width = best_result_width + ceil_log2(size);
        end
        else
            best_result_width = ceil_log2( ((1<<width)-1) * ((1 << (size*shift))-1)
                                            / ((1 << shift)-1));

        imsb_align = (result_alignment == "MSB" && widthr < best_result_width) ? 1 : 0;

        // Clear the pipeline array
        for (ni=0; ni< pipeline +1; ni=ni+1)
            resultpipe[ni] = 0;
        pipe_ptr = 0;
    end

    // MODEL
    always @(data)
    begin
        tmp_result = 0;
        // Loop over each input data word, and add to the total
        for (ni=0; ni<size; ni=ni+1)
        begin
            // Get input word to add to total
            idata_word = (data >> (ni * width));

            // If signed and negative, pad MSB with ones to sign extend the input data
            if ((representation != "UNSIGNED") && (idata_word[width-1] == 1'b1))
                idata_extended = ({{(`max_precision-width-2){1'b1}}, idata_word} << (shift*ni));
            else
                idata_extended = (idata_word << (shift*ni));    // zero padding is automatic

            // Add to total
            if ((msw_subtract == "YES") && (ni == (size-1)))
                tmp_result = tmp_result - idata_extended;
            else
                tmp_result = tmp_result + idata_extended;
        end
    end

    // Pipeline model
    always @(posedge clock or posedge aclr)
    begin
        if (aclr == 1'b1)
        begin
            // Clear the pipeline array
            for (ni=0; ni< (pipeline +1); ni=ni+1)
                resultpipe[ni] <= 0;
            pipe_ptr <= 0;
        end
        else if (clken_int == 1'b1)
        begin
            resultpipe[pipe_ptr] <= aligned_result;
            if (pipeline > 1)
                pipe_ptr <= (pipe_ptr + 1) % pipeline;
        end
    end

    // Check if output needs MSB alignment
    assign msb_aligned_result = (tmp_result >> (best_result_width-widthr));
    assign aligned_result = (imsb_align == 1)
                            ? msb_aligned_result[widthr-1:0]
                            : tmp_result[widthr-1:0];
    assign clken_int = clken;
    assign result = (pipeline > 0) ? resultpipe[pipe_ptr] : aligned_result;
endmodule  // end of PARALLEL_ADD

