// Created by altera_lib_mf.pl from altera_mf.v

///////////////////////////////////////////////////////////////////////////////
//
// Module Name : arm_m_cntr
//
// Description : Simulation model for the M counter. This is the
//               loop feedback counter for the StratixII PLL.
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
module arm_m_cntr   ( clk,
                            reset,
                            cout,
                            initial_value,
                            modulus,
                            time_delay);

    // INPUT PORTS
    input clk;
    input reset;
    input [31:0] initial_value;
    input [31:0] modulus;
    input [31:0] time_delay;

    // OUTPUT PORTS
    output cout;

    // INTERNAL VARIABLES AND NETS
    integer count;
    reg tmp_cout;
    reg first_rising_edge;
    reg clk_last_value;
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
            cout_tmp <= tmp_cout;
        end
        else begin
            if (clk_last_value !== clk)
            begin
                if (clk === 1'b1 && first_rising_edge)
                begin
                    first_rising_edge = 0;
                    tmp_cout = clk;
                    cout_tmp <= #(time_delay) tmp_cout;
                end
                else if (first_rising_edge == 0)
                begin
                    if (count < modulus)
                        count = count + 1;
                    else
                    begin
                        count = 1;
                        tmp_cout = ~tmp_cout;
                        cout_tmp <= #(time_delay) tmp_cout;
                    end
                end
            end
        end
        clk_last_value = clk;

    end

    and (cout, cout_tmp, 1'b1);

endmodule // arm_m_cntr

