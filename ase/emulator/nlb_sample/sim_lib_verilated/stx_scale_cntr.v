// Created by altera_lib_mf.pl from altera_mf.v

///////////////////////////////////////////////////////////////////////////////
//
// Module Name : stx_scale_cntr
//
// Description : Simulation model for the output scale-down counters.
//               This is a common model for the L0, L1, G0, G1, G2, G3, E0,
//               E1, E2 and E3 output counters of the Stratix PLL.
//
///////////////////////////////////////////////////////////////////////////////

`timescale 1 ps / 1 ps
/*verilator lint_off CASEX*/
/*verilator lint_off COMBDLY*/
/*verilator lint_off INITIALDLY*/
/*verilator lint_off LITENDIAN*/
/*verilator lint_off MULTIDRIVEN*/
/*verilator lint_off UNOPTFLAT*/
/*verilator lint_off BLKANDNBLK*/
module stx_scale_cntr  (clk,
                            reset,
                            cout,
                            high,
                            low,
                            initial_value,
                            mode,
                            time_delay,
                            ph_tap);

    // INPUT PORTS
    input clk;
    input reset;
    input [31:0] high;
    input [31:0] low;
    input [31:0] initial_value;
    input [8*6:1] mode;
    input [31:0] time_delay;
    input [31:0] ph_tap;

    // OUTPUT PORTS
    output cout;

    // INTERNAL VARIABLES AND NETS
    reg tmp_cout;
    reg first_rising_edge;
    reg clk_last_value;
    reg init;
    integer count;
    integer output_shift_count;
    reg cout_tmp;
    reg [31:0] high_reg;
    reg [31:0] low_reg;
    reg high_cnt_xfer_done;

    initial
    begin
        count = 1;
        first_rising_edge = 0;
        tmp_cout = 0;
        output_shift_count = 0;
        high_cnt_xfer_done = 0;
    end

    always @(clk or reset)
    begin
        if (init !== 1'b1)
        begin
            high_reg = high;
            low_reg = low;
            clk_last_value = 0;
            init = 1'b1;
        end
        if (reset)
        begin
            count = 1;
            output_shift_count = 0;
            tmp_cout = 0;
            first_rising_edge = 0;
        end
        else if (clk_last_value !== clk)
        begin
            if (mode == "off")
                tmp_cout = 0;
            else if (mode == "bypass")
                tmp_cout = clk;
            else if (first_rising_edge == 0)
            begin
                if (clk == 1)
                begin
                    output_shift_count = output_shift_count + 1;
                    if (output_shift_count == initial_value)
                    begin
                        tmp_cout = clk;
                        first_rising_edge = 1;
                    end
                end
            end
            else if (output_shift_count < initial_value)
            begin
                if (clk == 1)
                    output_shift_count = output_shift_count + 1;
            end
            else
            begin
                count = count + 1;
                if (mode == "even" && (count == (high_reg*2) + 1))
                begin
                    tmp_cout = 0;
                    if (high_cnt_xfer_done === 1'b1)
                    begin
                        low_reg = low;
                        high_cnt_xfer_done = 0;
                    end
                end
                else if (mode == "odd" && (count == (high_reg*2)))
                begin
                    tmp_cout = 0;
                    if (high_cnt_xfer_done === 1'b1)
                    begin
                        low_reg = low;
                        high_cnt_xfer_done = 0;
                    end
                end
                else if (count == (high_reg + low_reg)*2 + 1)
                begin
                    tmp_cout = 1;
                    count = 1;        // reset count
                    if (high_reg != high)
                    begin
                        high_reg = high;
                        high_cnt_xfer_done = 1;
                    end
                end
            end
        end
        clk_last_value = clk;
        cout_tmp <= #(time_delay) tmp_cout;
    end

    and (cout, cout_tmp, 1'b1);

endmodule // stx_scale_cntr

