// Created by altera_lib_mf.pl from altera_mf.v

///////////////////////////////////////////////////////////////////////////////
//
// Module Name : stx_n_cntr
//
// Description : Simulation model for the N counter. This is the
//               input clock divide counter for the Stratix PLL.
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
module stx_n_cntr  (clk,
                        reset,
                        cout,
                        modulus,
                        time_delay);

    // INPUT PORTS
    input clk;
    input reset;
    input [31:0] modulus;
    input [31:0] time_delay;

    // OUTPUT PORTS
    output cout;

    // INTERNAL VARIABLES AND NETS
    integer count;
    reg tmp_cout;
    reg first_rising_edge;
    reg clk_last_value;
    reg clk_last_valid_value;
    reg cout_tmp;

    initial
    begin
        count = 1;
        first_rising_edge = 1;
        clk_last_value = 0;
    end

    always @(reset or clk)
    begin
        if (reset)
        begin
            count = 1;
            tmp_cout = 0;
            first_rising_edge = 1;
        end
        else begin
            if (clk_last_value !== clk)
            begin
                if (clk === 1'b0 /* converted x or z to 1'b0 */)
                begin
                    $display("Warning : Invalid transition to 'X' detected on PLL input clk. This edge will be ignored.");
                    $display("Time: %0t  Instance: %m", $time);
                end
                else if ((clk === 1'b1) && first_rising_edge)
                begin
                    first_rising_edge = 0;
                    tmp_cout = clk;
                end
                else if ((first_rising_edge == 0) && (clk_last_valid_value !== clk))
                begin
                    if (count < modulus)
                        count = count + 1;
                    else
                    begin
                        count = 1;
                        tmp_cout = ~tmp_cout;
                    end
                end
            end
        end
        clk_last_value = clk;
        if (clk !== 1'b0 /* converted x or z to 1'b0 */)
            clk_last_valid_value = clk;

        cout_tmp <= #(time_delay) tmp_cout;
    end

    and (cout, cout_tmp, 1'b1);

endmodule // stx_n_cntr

