// Created by altera_lib_mf.pl from altera_mf.v


//////////////////////////////////////////////////////////////////////////////
//
// Module Name : MF_stratixii_pll
//
// Description : Behavioral model for StratixII pll.
//
// Limitations : Does not support Spread Spectrum and Bandwidth.
//
// Outputs     : Up to 6 output clocks, each defined by its own set of
//               parameters. Locked output (active high) indicates when the
//               PLL locks. clkbad, clkloss and activeclock are used for
//               clock switchover to indicate which input clock has gone
//               bad, when the clock switchover initiates and which input
//               clock is being used as the reference, respectively.
//               scandataout is the data output of the serial scan chain.
//
//////////////////////////////////////////////////////////////////////////////

`timescale 1 ps/1 ps
`define STXII_PLL_WORD_LENGTH 18

/*verilator lint_off CASEX*/
/*verilator lint_off COMBDLY*/
/*verilator lint_off INITIALDLY*/
/*verilator lint_off LITENDIAN*/
/*verilator lint_off MULTIDRIVEN*/
/*verilator lint_off UNOPTFLAT*/
/*verilator lint_off BLKANDNBLK*/
module MF_stratixii_pll (inclk,
                    fbin,
                    ena,
                    clkswitch,
                    areset,
                    pfdena,
                    scanclk,
                    scanread,
                    scanwrite,
                    scandata,
                    testin,
                    clk,
                    clkbad,
                    activeclock,
                    locked,
                    clkloss,
                    scandataout,
                    scandone,
                    enable0,
                    enable1,
                    testupout,
                    testdownout,
                    sclkout
                    );

    parameter operation_mode                       = "normal";
    parameter pll_type                             = "auto";
    parameter compensate_clock                     = "clk0";
    parameter feedback_source                      = "clk0";
    parameter qualify_conf_done                    = "off";

    parameter test_input_comp_delay_chain_bits     = 0;
    parameter test_feedback_comp_delay_chain_bits  = 0;

    parameter inclk0_input_frequency               = 10000;
    parameter inclk1_input_frequency               = 10000;

    parameter gate_lock_signal                     = "no";
    parameter gate_lock_counter                    = 1;
    parameter self_reset_on_gated_loss_lock        = "off";
    parameter valid_lock_multiplier                = 1;
    parameter invalid_lock_multiplier              = 5;

    parameter switch_over_type                     = "auto";
    parameter switch_over_on_lossclk               = "off";
    parameter switch_over_on_gated_lock            = "off";
    parameter switch_over_counter                  = 1;
    parameter enable_switch_over_counter           = "on";

    parameter bandwidth                            = 0;
    parameter bandwidth_type                       = "auto";
    parameter spread_frequency                     = 0;
    parameter common_rx_tx                         = "off";
    parameter use_dc_coupling                      = "false";

    parameter clk0_output_frequency                = 0;
    parameter clk0_multiply_by                     = 1;
    parameter clk0_divide_by                       = 1;
    parameter clk0_phase_shift                     = "0";
    parameter clk0_duty_cycle                      = 50;

    parameter clk1_output_frequency                = 0;
    parameter clk1_multiply_by                     = 1;
    parameter clk1_divide_by                       = 1;
    parameter clk1_phase_shift                     = "0";
    parameter clk1_duty_cycle                      = 50;

    parameter clk2_output_frequency                = 0;
    parameter clk2_multiply_by                     = 1;
    parameter clk2_divide_by                       = 1;
    parameter clk2_phase_shift                     = "0";
    parameter clk2_duty_cycle                      = 50;

    parameter clk3_output_frequency                = 0;
    parameter clk3_multiply_by                     = 1;
    parameter clk3_divide_by                       = 1;
    parameter clk3_phase_shift                     = "0";
    parameter clk3_duty_cycle                      = 50;

    parameter clk4_output_frequency                = 0;
    parameter clk4_multiply_by                     = 1;
    parameter clk4_divide_by                       = 1;
    parameter clk4_phase_shift                     = "0";
    parameter clk4_duty_cycle                      = 50;

    parameter clk5_output_frequency                = 0;
    parameter clk5_multiply_by                     = 1;
    parameter clk5_divide_by                       = 1;
    parameter clk5_phase_shift                     = "0";
    parameter clk5_duty_cycle                      = 50;

    parameter pfd_min                              = 0;
    parameter pfd_max                              = 0;
    parameter vco_min                              = 0;
    parameter vco_max                              = 0;
    parameter vco_center                           = 0;

    // ADVANCED USE PARAMETERS
    parameter m_initial = 1;
    parameter m = 0;
    parameter n = 1;
    parameter m2 = 1;
    parameter n2 = 1;
    parameter ss = 0;

    parameter c0_high = 1;
    parameter c0_low = 1;
    parameter c0_initial = 1;
    parameter c0_mode = "bypass";
    parameter c0_ph = 0;

    parameter c1_high = 1;
    parameter c1_low = 1;
    parameter c1_initial = 1;
    parameter c1_mode = "bypass";
    parameter c1_ph = 0;

    parameter c2_high = 1;
    parameter c2_low = 1;
    parameter c2_initial = 1;
    parameter c2_mode = "bypass";
    parameter c2_ph = 0;

    parameter c3_high = 1;
    parameter c3_low = 1;
    parameter c3_initial = 1;
    parameter c3_mode = "bypass";
    parameter c3_ph = 0;

    parameter c4_high = 1;
    parameter c4_low = 1;
    parameter c4_initial = 1;
    parameter c4_mode = "bypass";
    parameter c4_ph = 0;

    parameter c5_high = 1;
    parameter c5_low = 1;
    parameter c5_initial = 1;
    parameter c5_mode = "bypass";
    parameter c5_ph = 0;

    parameter m_ph = 0;

    parameter clk0_counter = "c0";
    parameter clk1_counter = "c1";
    parameter clk2_counter = "c2";
    parameter clk3_counter = "c3";
    parameter clk4_counter = "c4";
    parameter clk5_counter = "c5";

    parameter c1_use_casc_in = "off";
    parameter c2_use_casc_in = "off";
    parameter c3_use_casc_in = "off";
    parameter c4_use_casc_in = "off";
    parameter c5_use_casc_in = "off";

    parameter m_test_source = 5;
    parameter c0_test_source = 5;
    parameter c1_test_source = 5;
    parameter c2_test_source = 5;
    parameter c3_test_source = 5;
    parameter c4_test_source = 5;
    parameter c5_test_source = 5;

    // LVDS mode parameters
    parameter enable0_counter = "c0";
    parameter enable1_counter = "c1";
    parameter sclkout0_phase_shift = "0";
    parameter sclkout1_phase_shift = "0";

    parameter vco_multiply_by = 0;
    parameter vco_divide_by = 0;
    parameter vco_post_scale = 1;

    parameter charge_pump_current = 52;
    parameter loop_filter_r = "1.0";
    parameter loop_filter_c = 16;

    parameter pll_compensation_delay = 0;
    parameter simulation_type = "functional";

// SIMULATION_ONLY_PARAMETERS_BEGIN

    parameter down_spread                          = "0.0";

    parameter sim_gate_lock_device_behavior        = "off";

    parameter clk0_phase_shift_num = 0;
    parameter clk1_phase_shift_num = 0;
    parameter clk2_phase_shift_num = 0;
    parameter family_name = "StratixII";

    parameter clk0_use_even_counter_mode = "off";
    parameter clk1_use_even_counter_mode = "off";
    parameter clk2_use_even_counter_mode = "off";
    parameter clk3_use_even_counter_mode = "off";
    parameter clk4_use_even_counter_mode = "off";
    parameter clk5_use_even_counter_mode = "off";

    parameter clk0_use_even_counter_value = "off";
    parameter clk1_use_even_counter_value = "off";
    parameter clk2_use_even_counter_value = "off";
    parameter clk3_use_even_counter_value = "off";
    parameter clk4_use_even_counter_value = "off";
    parameter clk5_use_even_counter_value = "off";

// SIMULATION_ONLY_PARAMETERS_END

    parameter scan_chain_mif_file = "";

    // INPUT PORTS
    input [1:0] inclk;
    input fbin;
    input ena;
    input clkswitch;
    input areset;
    input pfdena;
    input scanclk;
    input scanread;
    input scanwrite;
    input scandata;
    input [3:0] testin;

    // OUTPUT PORTS
    output [5:0] clk;
    output [1:0] clkbad;
    output activeclock;
    output locked;
    output clkloss;
    output scandataout;
    output scandone;
    // lvds specific output ports
    output enable0;
    output enable1;
    output [1:0] sclkout;
    // test ports
    output testupout;
    output testdownout;

    // BUFFER INPUTS
    wire inclk0_ipd;
    wire inclk1_ipd;
    wire ena_ipd;
    wire fbin_ipd;
    wire clkswitch_ipd;
    wire areset_ipd;
    wire pfdena_ipd;
    wire scanclk_ipd;
    wire scanread_ipd;
    wire scanwrite_ipd;
    wire scandata_ipd;
    buf (inclk0_ipd, inclk[0]);
    buf (inclk1_ipd, inclk[1]);
    assign ena_ipd = ena; // -- converted buf to assign
    assign fbin_ipd = fbin; // -- converted buf to assign
    assign clkswitch_ipd = clkswitch; // -- converted buf to assign
    assign areset_ipd = areset; // -- converted buf to assign
    assign pfdena_ipd = pfdena; // -- converted buf to assign
    assign scanclk_ipd = scanclk; // -- converted buf to assign
    assign scanread_ipd = scanread; // -- converted buf to assign
    assign scanwrite_ipd = scanwrite; // -- converted buf to assign
    assign scandata_ipd = scandata; // -- converted buf to assign


    // INTERNAL VARIABLES AND NETS
    integer scan_chain_length;
    integer i;
    integer j;
    integer k;
    integer x;
    integer y;
    integer l_index;
    integer gate_count;
    integer egpp_offset;
    integer sched_time;
    integer delay_chain;
    integer low;
    integer high;
    integer initial_delay;
    integer fbk_phase;
    integer fbk_delay;
    integer phase_shift[0:7];
    integer last_phase_shift[0:7];

    integer m_times_vco_period;
    integer new_m_times_vco_period;
    integer refclk_period;
    integer fbclk_period;
    integer high_time;
    integer low_time;
    integer my_rem;
    integer tmp_rem;
    integer rem;
    integer tmp_vco_per;
    integer vco_per;
    integer offset;
    integer temp_offset;
    integer cycles_to_lock;
    integer cycles_to_unlock;
    integer c0_count;
    integer c0_initial_count;
    integer c1_count;
    integer c1_initial_count;
    integer loop_xplier;
    integer loop_initial;
    integer loop_ph;
    integer cycle_to_adjust;
    integer total_pull_back;
    integer pull_back_M;

    time    fbclk_time;
    time    first_fbclk_time;
    time    refclk_time;
    time    next_vco_sched_time;

    reg got_first_refclk;
    reg got_second_refclk;
    reg got_first_fbclk;
    reg refclk_last_value;
    reg fbclk_last_value;
    reg inclk_last_value;
    reg pll_is_locked;
    reg pll_about_to_lock;
    reg locked_tmp;
    reg c0_got_first_rising_edge;
    reg c1_got_first_rising_edge;
    reg vco_c0_last_value;
    reg vco_c1_last_value;
    reg areset_ipd_last_value;
    reg ena_ipd_last_value;
    reg pfdena_ipd_last_value;
    reg inclk_out_of_range;
    reg schedule_vco_last_value;

    reg gate_out;
    reg vco_val;

    reg [31:0] m_initial_val;
    reg [31:0] m_val[0:1];
    reg [31:0] n_val[0:1];
    reg [31:0] m_delay;
    reg [8*6:1] m_mode_val[0:1];
    reg [8*6:1] n_mode_val[0:1];

    reg [31:0] c_high_val[0:5];
    reg [31:0] c_low_val[0:5];
    reg [8*6:1] c_mode_val[0:5];
    reg [31:0] c_initial_val[0:5];
    integer c_ph_val[0:5];

    // temporary registers for reprogramming
    integer c_ph_val_tmp[0:5];
    reg [31:0] c_high_val_tmp[0:5];
    reg [31:0] c_low_val_tmp[0:5];
    reg [8*6:1] c_mode_val_tmp[0:5];

    // hold registers for reprogramming
    integer c_ph_val_hold[0:5];
    reg [31:0] c_high_val_hold[0:5];
    reg [31:0] c_low_val_hold[0:5];
    reg [8*6:1] c_mode_val_hold[0:5];

    // old values
    reg [31:0] m_val_old[0:1];
    reg [31:0] m_val_tmp[0:1];
    reg [31:0] n_val_old[0:1];
    reg [8*6:1] m_mode_val_old[0:1];
    reg [8*6:1] n_mode_val_old[0:1];
    reg [31:0] c_high_val_old[0:5];
    reg [31:0] c_low_val_old[0:5];
    reg [8*6:1] c_mode_val_old[0:5];
    integer c_ph_val_old[0:5];
    integer   m_ph_val_old;
    integer   m_ph_val_tmp;

    integer cp_curr_old;
    integer cp_curr_val;
    integer lfc_old;
    integer lfc_val;
    reg [9*8:1] lfr_val;
    reg [9*8:1] lfr_old;

    reg [31:0] m_hi;
    reg [31:0] m_lo;

    // ph tap orig values (POF)
    integer c_ph_val_orig[0:5];
    integer m_ph_val_orig;

    reg schedule_vco;
    reg stop_vco;
    reg inclk_n;

    reg [7:0] vco_out;
    reg [7:0] vco_tap;
    reg [7:0] vco_out_last_value;
    reg [7:0] vco_tap_last_value;
    wire inclk_c0;
    wire inclk_c1;
    wire inclk_c2;
    wire inclk_c3;
    wire inclk_c4;
    wire inclk_c5;
    reg  inclk_c0_from_vco;
    reg  inclk_c1_from_vco;
    reg  inclk_c2_from_vco;
    reg  inclk_c3_from_vco;
    reg  inclk_c4_from_vco;
    reg  inclk_c5_from_vco;
    reg  inclk_m_from_vco;
    reg inclk_sclkout0_from_vco;
    reg inclk_sclkout1_from_vco;

    wire inclk_m;
    wire [5:0] clk_tmp;

    wire ena_pll;
    wire n_cntr_inclk;
    reg sclkout0_tmp;
    reg sclkout1_tmp;

    reg vco_c0;
    reg vco_c1;

    wire [5:0] clk_out;
    wire sclkout0;
    wire sclkout1;

    wire c0_clk;
    wire c1_clk;
    wire c2_clk;
    wire c3_clk;
    wire c4_clk;
    wire c5_clk;

    reg first_schedule;

    wire enable0_tmp;
    wire enable1_tmp;
    wire enable_0;
    wire enable_1;
    reg c0_tmp;
    reg c1_tmp;

    reg vco_period_was_phase_adjusted;
    reg phase_adjust_was_scheduled;

    wire refclk;
    wire fbclk;

    wire pllena_reg;
    wire test_mode_inclk;

    // for external feedback mode

    reg [31:0] ext_fbk_cntr_high;
    reg [31:0] ext_fbk_cntr_low;
    reg [31:0] ext_fbk_cntr_modulus;
    reg [8*2:1] ext_fbk_cntr;
    reg [8*6:1] ext_fbk_cntr_mode;
    integer ext_fbk_cntr_ph;
    integer ext_fbk_cntr_initial;
    integer ext_fbk_cntr_index;

    // variables for clk_switch
    reg clk0_is_bad;
    reg clk1_is_bad;
    reg inclk0_last_value;
    reg inclk1_last_value;
    reg other_clock_value;
    reg other_clock_last_value;
    reg primary_clk_is_bad;
    reg current_clk_is_bad;
    reg external_switch;
    reg active_clock;
    reg clkloss_tmp;
    reg got_curr_clk_falling_edge_after_clkswitch;

    integer clk0_count;
    integer clk1_count;
    integer switch_over_count;

    wire scandataout_tmp;
    reg scandone_tmp;
    reg scandone_tmp_last_value;
    integer quiet_time;
    integer slowest_clk_old;
    integer slowest_clk_new;

    reg reconfig_err;
    reg error;
    time    scanclk_last_rising_edge;
    time    scanread_active_edge;
    reg got_first_scanclk;
    reg got_first_gated_scanclk;
    reg gated_scanclk;
    integer scanclk_period;
    reg scanclk_last_value;
    reg scanread_reg;
    reg scanwrite_reg;
    reg scanwrite_enabled;
    reg scanwrite_last_value;
    reg [173:0] scan_data;
    reg [173:0] tmp_scan_data;
    reg c0_rising_edge_transfer_done;
    reg c1_rising_edge_transfer_done;
    reg c2_rising_edge_transfer_done;
    reg c3_rising_edge_transfer_done;
    reg c4_rising_edge_transfer_done;
    reg c5_rising_edge_transfer_done;
    reg scanread_setup_violation;
    integer index;
    integer scanclk_cycles;
    reg d_msg;

    integer num_output_cntrs;
    reg no_warn;

// LOCAL_PARAMETERS_BEGIN

    parameter GPP_SCAN_CHAIN = 174;
    parameter FAST_SCAN_CHAIN = 75;
    // primary clk is always inclk0
    parameter prim_clk = "inclk0";
    parameter GATE_LOCK_CYCLES = 7;

// LOCAL_PARAMETERS_END

    // internal variables for scaling of multiply_by and divide_by values
    integer i_clk0_mult_by;
    integer i_clk0_div_by;
    integer i_clk1_mult_by;
    integer i_clk1_div_by;
    integer i_clk2_mult_by;
    integer i_clk2_div_by;
    integer i_clk3_mult_by;
    integer i_clk3_div_by;
    integer i_clk4_mult_by;
    integer i_clk4_div_by;
    integer i_clk5_mult_by;
    integer i_clk5_div_by;
    integer max_d_value;
    integer new_multiplier;

    // internal variables for storing the phase shift number.(used in lvds mode only)
    integer i_clk0_phase_shift;
    integer i_clk1_phase_shift;
    integer i_clk2_phase_shift;

    // user to advanced internal signals

    integer   i_m_initial;
    integer   i_m;
    integer   i_n;
    integer   i_m2;
    integer   i_n2;
    integer   i_ss;
    integer   i_c_high[0:5];
    integer   i_c_low[0:5];
    integer   i_c_initial[0:5];
    integer   i_c_ph[0:5];
    reg       [8*6:1] i_c_mode[0:5];

    integer   i_vco_min;
    integer   i_vco_max;
    integer   i_vco_center;
    integer   i_pfd_min;
    integer   i_pfd_max;
    integer   i_m_ph;
    integer   m_ph_val;
    reg [8*2:1] i_clk5_counter;
    reg [8*2:1] i_clk4_counter;
    reg [8*2:1] i_clk3_counter;
    reg [8*2:1] i_clk2_counter;
    reg [8*2:1] i_clk1_counter;
    reg [8*2:1] i_clk0_counter;
    integer   i_charge_pump_current;
    integer   i_loop_filter_r;
    integer   max_neg_abs;
    integer   output_count;
    integer   new_divisor;

    integer loop_filter_c_arr[0:3];
    integer fpll_loop_filter_c_arr[0:3];
    integer charge_pump_curr_arr[0:15];
    reg [9*8:1] loop_filter_r_arr[0:39];

    reg pll_in_test_mode;
    reg pll_is_in_reset;
    reg pll_is_disabled;

    // uppercase to lowercase parameter values
    reg [8*`STXII_PLL_WORD_LENGTH:1] l_operation_mode;
    reg [8*`STXII_PLL_WORD_LENGTH:1] l_pll_type;
    reg [8*`STXII_PLL_WORD_LENGTH:1] l_qualify_conf_done;
    reg [8*`STXII_PLL_WORD_LENGTH:1] l_compensate_clock;
    reg [8*`STXII_PLL_WORD_LENGTH:1] l_scan_chain;
    reg [8*`STXII_PLL_WORD_LENGTH:1] l_primary_clock;
    reg [8*`STXII_PLL_WORD_LENGTH:1] l_gate_lock_signal;
    reg [8*`STXII_PLL_WORD_LENGTH:1] l_switch_over_on_lossclk;
    reg [8*`STXII_PLL_WORD_LENGTH:1] l_switch_over_type;
    reg [8*`STXII_PLL_WORD_LENGTH:1] l_switch_over_on_gated_lock;
    reg [8*`STXII_PLL_WORD_LENGTH:1] l_enable_switch_over_counter;
    reg [8*`STXII_PLL_WORD_LENGTH:1] l_feedback_source;
    reg [8*`STXII_PLL_WORD_LENGTH:1] l_bandwidth_type;
    reg [8*`STXII_PLL_WORD_LENGTH:1] l_simulation_type;
    reg [8*`STXII_PLL_WORD_LENGTH:1] l_sim_gate_lock_device_behavior;
    reg [8*`STXII_PLL_WORD_LENGTH:1] l_enable0_counter;
    reg [8*`STXII_PLL_WORD_LENGTH:1] l_enable1_counter;

    integer current_clock;
    integer ena0_cntr;
    integer ena1_cntr;
    reg is_fast_pll;
    reg ic1_use_casc_in;
    reg ic2_use_casc_in;
    reg ic3_use_casc_in;
    reg ic4_use_casc_in;
    reg ic5_use_casc_in;
    reg op_mode;

    reg init;
    reg tap0_is_active;

    ALTERA_DEVICE_FAMILIES dev ();


    // finds the closest integer fraction of a given pair of numerator and denominator.
    task find_simple_integer_fraction;
        input numerator;
        input denominator;
        input max_denom;
        output fraction_num;
        output fraction_div;
        parameter max_iter = 20;

        integer numerator;
        integer denominator;
        integer max_denom;
        integer fraction_num;
        integer fraction_div;

        integer quotient_array[max_iter-1:0];
        integer int_loop_iter;
        integer int_quot;
        integer m_value;
        integer d_value;
        integer old_m_value;
        integer swap;

        integer loop_iter;
        integer num;
        integer den;
        integer i_max_iter;

    begin
        loop_iter = 0;
        num = numerator;
        den = denominator;
        i_max_iter = max_iter;

        while (loop_iter < i_max_iter)
        begin
            int_quot = num / den;
            quotient_array[loop_iter] = int_quot;
            num = num - (den*int_quot);
            loop_iter=loop_iter+1;

            if ((num == 0) || (max_denom != -1) || (loop_iter == i_max_iter))
            begin
                // calculate the numerator and denominator if there is a restriction on the
                // max denom value or if the loop is ending
                m_value = 0;
                d_value = 1;
                // get the rounded value at this stage for the remaining fraction
                if (den != 0)
                begin
                    m_value = (2*num/den);
                end
                // calculate the fraction numerator and denominator at this stage
                for (int_loop_iter = loop_iter-1; int_loop_iter >= 0; int_loop_iter=int_loop_iter-1)
                begin
                    if (m_value == 0)
                    begin
                        m_value = quotient_array[int_loop_iter];
                        d_value = 1;
                    end
                    else
                    begin
                        old_m_value = m_value;
                        m_value = quotient_array[int_loop_iter]*m_value + d_value;
                        d_value = old_m_value;
                    end
                end
                // if the denominator is less than the maximum denom_value or if there is no restriction save it
                if ((d_value <= max_denom) || (max_denom == -1))
                begin
                    if ((m_value == 0) || (d_value == 0))
                    begin
                        fraction_num = numerator;
                        fraction_div = denominator;
                    end
                    else
                    begin
                        fraction_num = m_value;
                        fraction_div = d_value;
                    end
                end
                // end the loop if the denomitor has overflown or the numerator is zero (no remainder during this round)
                if (((d_value > max_denom) && (max_denom != -1)) || (num == 0))
                begin
                    i_max_iter = loop_iter;
                end
            end
            // swap the numerator and denominator for the next round
            swap = den;
            den = num;
            num = swap;
        end
    end
    endtask // find_simple_integer_fraction

    // get the absolute value
    function integer abs;
    input value;
    integer value;
    begin
        if (value < 0)
            abs = value * -1;
        else abs = value;
    end
    endfunction

    // find twice the period of the slowest clock
    function integer slowest_clk;
    input C0, C0_mode, C1, C1_mode, C2, C2_mode, C3, C3_mode, C4, C4_mode, C5, C5_mode, refclk, m_mod;
    integer C0, C1, C2, C3, C4, C5;
    reg [8*6:1] C0_mode, C1_mode, C2_mode, C3_mode, C4_mode, C5_mode;
    integer refclk;
    reg [31:0] m_mod;
    integer max_modulus;
    begin
        max_modulus = 1;
        if (C0_mode != "bypass" && C0_mode != "   off")
            max_modulus = C0;
        if (C1 > max_modulus && C1_mode != "bypass" && C1_mode != "   off")
            max_modulus = C1;
        if (C2 > max_modulus && C2_mode != "bypass" && C2_mode != "   off")
            max_modulus = C2;
        if (C3 > max_modulus && C3_mode != "bypass" && C3_mode != "   off")
            max_modulus = C3;
        if (C4 > max_modulus && C4_mode != "bypass" && C4_mode != "   off")
            max_modulus = C4;
        if (C5 > max_modulus && C5_mode != "bypass" && C5_mode != "   off")
            max_modulus = C5;

        if ((2 * refclk) > (refclk * max_modulus *2 / m_mod))
            slowest_clk = 2 * refclk;
        else
            slowest_clk = (refclk * max_modulus *2 / m_mod);
    end
    endfunction

    // count the number of digits in the given integer
    function integer count_digit;
    input X;
    integer X;
    integer count, result;
    begin
        count = 0;
        result = X;
        while (result != 0)
        begin
            result = (result / 10);
            count = count + 1;
        end

        count_digit = count;
    end
    endfunction

    // reduce the given huge number(X) to Y significant digits
    function integer scale_num;
    input X, Y;
    integer X, Y;
    integer count;
    integer fac_ten, lc;
    begin
        fac_ten = 1;
        count = count_digit(X);

        for (lc = 0; lc < (count-Y); lc = lc + 1)
            fac_ten = fac_ten * 10;

        scale_num = (X / fac_ten);
    end
    endfunction

    // find the greatest common denominator of X and Y
    function integer gcd;
    input X,Y;
    integer X,Y;
    integer L, S, R, G;
    begin
        if (X < Y) // find which is smaller.
        begin
            S = X;
            L = Y;
        end
        else
        begin
            S = Y;
            L = X;
        end

        R = S;
        while ( R > 1)
        begin
            S = L;
            L = R;
            R = S % L;  // divide bigger number by smaller.
                        // remainder becomes smaller number.
        end
        if (R == 0)     // if evenly divisible then L is gcd else it is 1.
            G = L;
        else
            G = R;
        gcd = G;
    end
    endfunction

    // find the least common multiple of A1 to A10
    function integer lcm;
    input A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, P;
    integer A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, P;
    integer M1, M2, M3, M4, M5 , M6, M7, M8, M9, R;
    begin
        M1 = (A1 * A2)/gcd(A1, A2);
        M2 = (M1 * A3)/gcd(M1, A3);
        M3 = (M2 * A4)/gcd(M2, A4);
        M4 = (M3 * A5)/gcd(M3, A5);
        M5 = (M4 * A6)/gcd(M4, A6);
        M6 = (M5 * A7)/gcd(M5, A7);
        M7 = (M6 * A8)/gcd(M6, A8);
        M8 = (M7 * A9)/gcd(M7, A9);
        M9 = (M8 * A10)/gcd(M8, A10);
        if (M9 < 3)
            R = 10;
        else if ((M9 <= 10) && (M9 >= 3))
            R = 4 * M9;
        else if (M9 > 1000)
            R = scale_num(M9, 3);
        else
            R = M9;
        lcm = R;
    end
    endfunction

    // find the factor of division of the output clock frequency
    // compared to the VCO
    function integer output_counter_value;
    input clk_divide, clk_mult, M, N;
    integer clk_divide, clk_mult, M, N;
    integer R;
    begin
        R = (clk_divide * M)/(clk_mult * N);
        output_counter_value = R;
    end
    endfunction

    // find the mode of each of the PLL counters - bypass, even or odd
    function [8*6:1] counter_mode;
    input duty_cycle;
    input output_counter_value;
    integer duty_cycle;
    integer output_counter_value;
    integer half_cycle_high;
    reg [8*6:1] R;
    begin
        half_cycle_high = (2*duty_cycle*output_counter_value)/100;
        if (output_counter_value == 1)
            R = "bypass";
        else if ((half_cycle_high % 2) == 0)
            R = "  even";
        else
            R = "   odd";
        counter_mode = R;
    end
    endfunction

    // find the number of VCO clock cycles to hold the output clock high
    function integer counter_high;
    input output_counter_value, duty_cycle;
    integer output_counter_value, duty_cycle;
    integer half_cycle_high;
    integer tmp_counter_high;
    integer mode;
    begin
        half_cycle_high = (2*duty_cycle*output_counter_value)/100;
        mode = ((half_cycle_high % 2) == 0);
        tmp_counter_high = half_cycle_high/2;
        counter_high = tmp_counter_high + !mode;
    end
    endfunction

    // find the number of VCO clock cycles to hold the output clock low
    function integer counter_low;
    input output_counter_value, duty_cycle;
    integer output_counter_value, duty_cycle, counter_h;
    integer half_cycle_high;
    integer mode;
    integer tmp_counter_high;
    integer counter_l, tmp_counter_low;
    begin
        half_cycle_high = (2*duty_cycle*output_counter_value)/100;
        mode = ((half_cycle_high % 2) == 0);
        tmp_counter_high = half_cycle_high/2;
        counter_h = tmp_counter_high + !mode;
        tmp_counter_low =  output_counter_value - counter_h;
        if (tmp_counter_low == 0)
            counter_l = 1;
        else counter_l = tmp_counter_low;

        counter_low = counter_l;
    end
    endfunction

    // find the smallest time delay amongst t1 to t10
    function integer mintimedelay;
    input t1, t2, t3, t4, t5, t6, t7, t8, t9, t10;
    integer t1, t2, t3, t4, t5, t6, t7, t8, t9, t10;
    integer m1,m2,m3,m4,m5,m6,m7,m8,m9;
    begin
        if (t1 < t2)
            m1 = t1;
        else
            m1 = t2;
        if (m1 < t3)
            m2 = m1;
        else
            m2 = t3;
        if (m2 < t4)
            m3 = m2;
        else
            m3 = t4;
        if (m3 < t5)
            m4 = m3;
        else
            m4 = t5;
        if (m4 < t6)
            m5 = m4;
        else
            m5 = t6;
        if (m5 < t7)
            m6 = m5;
        else
            m6 = t7;
        if (m6 < t8)
            m7 = m6;
        else
            m7 = t8;
        if (m7 < t9)
            m8 = m7;
        else
            m8 = t9;
        if (m8 < t10)
            m9 = m8;
        else
            m9 = t10;
        if (m9 > 0)
            mintimedelay = m9;
        else
            mintimedelay = 0;
    end
    endfunction

    // find the numerically largest negative number, and return its absolute value
    function integer maxnegabs;
    input t1, t2, t3, t4, t5, t6, t7, t8, t9, t10;
    integer t1, t2, t3, t4, t5, t6, t7, t8, t9, t10;
    integer m1,m2,m3,m4,m5,m6,m7,m8,m9;
    begin
        if (t1 < t2) m1 = t1; else m1 = t2;
        if (m1 < t3) m2 = m1; else m2 = t3;
        if (m2 < t4) m3 = m2; else m3 = t4;
        if (m3 < t5) m4 = m3; else m4 = t5;
        if (m4 < t6) m5 = m4; else m5 = t6;
        if (m5 < t7) m6 = m5; else m6 = t7;
        if (m6 < t8) m7 = m6; else m7 = t8;
        if (m7 < t9) m8 = m7; else m8 = t9;
        if (m8 < t10) m9 = m8; else m9 = t10;
        maxnegabs = (m9 < 0) ? 0 - m9 : 0;
    end
    endfunction

    // adjust the given tap_phase by adding the largest negative number (ph_base)
    function integer ph_adjust;
    input tap_phase, ph_base;
    integer tap_phase, ph_base;
    begin
        ph_adjust = tap_phase + ph_base;
    end
    endfunction

    // find the number of VCO clock cycles to wait initially before the first
    // rising edge of the output clock
    function integer counter_initial;
    input tap_phase, m, n;
    integer tap_phase, m, n, phase;
    begin
        if (tap_phase < 0) tap_phase = 0 - tap_phase;
        // adding 0.5 for rounding correction (required in order to round
        // to the nearest integer instead of truncating)
        phase = ((tap_phase * m) / (360 * n)) + 0.5;
        counter_initial = phase;
    end
    endfunction

    // find which VCO phase tap to align the rising edge of the output clock to
    function integer counter_ph;
    input tap_phase;
    input m,n;
    integer m,n, phase;
    integer tap_phase;
    begin
    // adding 0.5 for rounding correction
        phase = (tap_phase * m / n) + 0.5;
        counter_ph = (phase % 360) / 45;
    end
    endfunction

    // convert the given string to length 6 by padding with spaces
    function [8*6:1] translate_string;
    input [8*6:1] mode;
    reg [8*6:1] new_mode;
    begin
        if (mode == "bypass")
            new_mode = "bypass";
        else if (mode == "even")
            new_mode = "  even";
        else if (mode == "odd")
            new_mode = "   odd";

        translate_string = new_mode;
    end
    endfunction

    // convert string to integer with sign
    function integer str2int;
    input [8*16:1] s;

    reg [8*16:1] reg_s;
    reg [8:1] digit;
    reg [8:1] tmp;
    integer m, magnitude;
    integer sign;

    begin
        sign = 1;
        magnitude = 0;
        reg_s = s;
        for (m=1; m<=16; m=m+1)
        begin
            tmp = reg_s[128:121];
            digit = tmp & 8'b00001111;
            reg_s = reg_s << 8;
            // Accumulate ascii digits 0-9 only.
            if ((tmp>=48) && (tmp<=57))
                magnitude = (magnitude * 10) + digit;
            if (tmp == 45)
                sign = -1;  // Found a '-' character, i.e. number is negative.
        end
        str2int = sign*magnitude;
    end
    endfunction

    // this is for stratixii lvds only
    // convert phase delay to integer
    function integer get_int_phase_shift;
    input [8*16:1] s;
    input i_phase_shift;
    integer i_phase_shift;

    begin
        if (i_phase_shift != 0)
        begin
            get_int_phase_shift = i_phase_shift;
        end
        else
        begin
            get_int_phase_shift = str2int(s);
        end
    end
    endfunction

    // calculate the given phase shift (in ps) in terms of degrees
    function integer get_phase_degree;
    input phase_shift;
    integer phase_shift, result;
    begin
        result = (phase_shift * 360) / inclk0_input_frequency;
        // this is to round up the calculation result
        if ( result > 0 )
            result = result + 1;
        else if ( result < 0 )
            result = result - 1;
        else
            result = 0;

        // assign the rounded up result
        get_phase_degree = result;
    end
    endfunction

    // convert uppercase parameter values to lowercase
    // assumes that the maximum character length of a parameter is 18
    function [8*`STXII_PLL_WORD_LENGTH:1] alpha_tolower;
    input [8*`STXII_PLL_WORD_LENGTH:1] given_string;

    reg [8*`STXII_PLL_WORD_LENGTH:1] return_string;
    reg [8*`STXII_PLL_WORD_LENGTH:1] reg_string;
    reg [8:1] tmp;
    reg [8:1] conv_char;
    integer byte_count;
    begin
        return_string = "                    "; // initialise strings to spaces
        conv_char = "        ";
        reg_string = given_string;
        for (byte_count = `STXII_PLL_WORD_LENGTH; byte_count >= 1; byte_count = byte_count - 1)
        begin
            tmp = reg_string[8*`STXII_PLL_WORD_LENGTH:(8*(`STXII_PLL_WORD_LENGTH-1)+1)];
            reg_string = reg_string << 8;
            if ((tmp >= 65) && (tmp <= 90)) // ASCII number of 'A' is 65, 'Z' is 90
            begin
                conv_char = tmp + 32; // 32 is the difference in the position of 'A' and 'a' in the ASCII char set
                return_string = {return_string, conv_char};
            end
            else
                return_string = {return_string, tmp};
        end

        alpha_tolower = return_string;
    end
    endfunction

    function integer display_msg;
    input [8*2:1] cntr_name;
    input msg_code;
    integer msg_code;
    begin
        if (msg_code == 1)
            $display ("Warning : %s counter switched from BYPASS mode to enabled. PLL may lose lock.", cntr_name);
        else if (msg_code == 2)
            $display ("Warning : Illegal 1 value for %s counter. Instead, the %s counter should be BYPASSED. Reconfiguration may not work.", cntr_name, cntr_name);
        else if (msg_code == 3)
            $display ("Warning : Illegal value for counter %s in BYPASS mode. The LSB of the counter should be set to 0 in order to operate the counter in BYPASS mode. Reconfiguration may not work.", cntr_name);
        else if (msg_code == 4)
            $display ("Warning : %s counter switched from enabled to BYPASS mode. PLL may lose lock.", cntr_name);
        $display ("Time: %0t  Instance: %m", $time);
        display_msg = 1;
    end
    endfunction

    initial
    begin

        // convert string parameter values from uppercase to lowercase,
        // as expected in this model
        l_operation_mode             = alpha_tolower(operation_mode);
        l_pll_type                   = alpha_tolower(pll_type);
        l_qualify_conf_done          = alpha_tolower(qualify_conf_done);
        l_compensate_clock           = alpha_tolower(compensate_clock);
        l_primary_clock              = alpha_tolower(prim_clk);
        l_gate_lock_signal           = alpha_tolower(gate_lock_signal);
        l_switch_over_on_lossclk     = alpha_tolower(switch_over_on_lossclk);
        l_switch_over_on_gated_lock  = alpha_tolower(switch_over_on_gated_lock);
        l_enable_switch_over_counter = alpha_tolower(enable_switch_over_counter);
    if (dev.FEATURE_FAMILY_BASE_CYCLONEII(family_name) == 1)
        l_switch_over_type           = "manual";
    else
        l_switch_over_type           = alpha_tolower(switch_over_type);
        l_feedback_source            = alpha_tolower(feedback_source);
        l_bandwidth_type             = alpha_tolower(bandwidth_type);
        l_simulation_type            = alpha_tolower(simulation_type);
        l_sim_gate_lock_device_behavior     = alpha_tolower(sim_gate_lock_device_behavior);
        l_enable0_counter            = alpha_tolower(enable0_counter);
        l_enable1_counter            = alpha_tolower(enable1_counter);

        if (l_enable0_counter == "c0")
            ena0_cntr = 0;
        else
            ena0_cntr = 1;
        if (l_enable1_counter == "c0")
            ena1_cntr = 0;
        else
            ena1_cntr = 1;

        // initialize charge_pump_current, and loop_filter tables
        loop_filter_c_arr[0] = 57;
        loop_filter_c_arr[1] = 16;
        loop_filter_c_arr[2] = 36;
        loop_filter_c_arr[3] = 5;

        fpll_loop_filter_c_arr[0] = 18;
        fpll_loop_filter_c_arr[1] = 13;
        fpll_loop_filter_c_arr[2] = 8;
        fpll_loop_filter_c_arr[3] = 2;

        charge_pump_curr_arr[0] = 6;
        charge_pump_curr_arr[1] = 12;
        charge_pump_curr_arr[2] = 30;
        charge_pump_curr_arr[3] = 36;
        charge_pump_curr_arr[4] = 52;
        charge_pump_curr_arr[5] = 57;
        charge_pump_curr_arr[6] = 72;
        charge_pump_curr_arr[7] = 77;
        charge_pump_curr_arr[8] = 92;
        charge_pump_curr_arr[9] = 96;
        charge_pump_curr_arr[10] = 110;
        charge_pump_curr_arr[11] = 114;
        charge_pump_curr_arr[12] = 127;
        charge_pump_curr_arr[13] = 131;
        charge_pump_curr_arr[14] = 144;
        charge_pump_curr_arr[15] = 148;

        loop_filter_r_arr[0] = " 1.000000";
        loop_filter_r_arr[1] = " 1.500000";
        loop_filter_r_arr[2] = " 2.000000";
        loop_filter_r_arr[3] = " 2.500000";
        loop_filter_r_arr[4] = " 3.000000";
        loop_filter_r_arr[5] = " 3.500000";
        loop_filter_r_arr[6] = " 4.000000";
        loop_filter_r_arr[7] = " 4.500000";
        loop_filter_r_arr[8] = " 5.000000";
        loop_filter_r_arr[9] = " 5.500000";
        loop_filter_r_arr[10] = " 6.000000";
        loop_filter_r_arr[11] = " 6.500000";
        loop_filter_r_arr[12] = " 7.000000";
        loop_filter_r_arr[13] = " 7.500000";
        loop_filter_r_arr[14] = " 8.000000";
        loop_filter_r_arr[15] = " 8.500000";
        loop_filter_r_arr[16] = " 9.000000";
        loop_filter_r_arr[17] = " 9.500000";
        loop_filter_r_arr[18] = "10.000000";
        loop_filter_r_arr[19] = "10.500000";
        loop_filter_r_arr[20] = "11.000000";
        loop_filter_r_arr[21] = "11.500000";
        loop_filter_r_arr[22] = "12.000000";
        loop_filter_r_arr[23] = "12.500000";
        loop_filter_r_arr[24] = "13.000000";
        loop_filter_r_arr[25] = "13.500000";
        loop_filter_r_arr[26] = "14.000000";
        loop_filter_r_arr[27] = "14.500000";
        loop_filter_r_arr[28] = "15.000000";
        loop_filter_r_arr[29] = "15.500000";
        loop_filter_r_arr[30] = "16.000000";
        loop_filter_r_arr[31] = "16.500000";
        loop_filter_r_arr[32] = "17.000000";
        loop_filter_r_arr[33] = "17.500000";
        loop_filter_r_arr[34] = "18.000000";
        loop_filter_r_arr[35] = "18.500000";
        loop_filter_r_arr[36] = "19.000000";
        loop_filter_r_arr[37] = "19.500000";
        loop_filter_r_arr[38] = "20.000000";
        loop_filter_r_arr[39] = "20.500000";

        if (m == 0)
        begin
            i_clk5_counter    = "c5" ;
            i_clk4_counter    = "c4" ;
            i_clk3_counter    = "c3" ;
            i_clk2_counter    = "c2" ;
            i_clk1_counter    = "c1" ;
            i_clk0_counter    = "c0" ;
        end
        else begin
            i_clk5_counter    = alpha_tolower(clk5_counter);
            i_clk4_counter    = alpha_tolower(clk4_counter);
            i_clk3_counter    = alpha_tolower(clk3_counter);
            i_clk2_counter    = alpha_tolower(clk2_counter);
            i_clk1_counter    = alpha_tolower(clk1_counter);
            i_clk0_counter    = alpha_tolower(clk0_counter);
        end

        // VCO feedback loop settings for external feedback mode
        // first find which counter is used for feedback
        if (l_operation_mode == "external_feedback")
        begin
            op_mode = 1;
            if (l_feedback_source == "clk0")
                ext_fbk_cntr = i_clk0_counter;
            else if (l_feedback_source == "clk1")
                ext_fbk_cntr = i_clk1_counter;
            else if (l_feedback_source == "clk2")
                ext_fbk_cntr = i_clk2_counter;
            else if (l_feedback_source == "clk3")
                ext_fbk_cntr = i_clk3_counter;
            else if (l_feedback_source == "clk4")
                ext_fbk_cntr = i_clk4_counter;
            else if (l_feedback_source == "clk5")
                ext_fbk_cntr = i_clk5_counter;
            else ext_fbk_cntr = "c0";

            if (ext_fbk_cntr == "c0")
                ext_fbk_cntr_index = 0;
            else if (ext_fbk_cntr == "c1")
                ext_fbk_cntr_index = 1;
            else if (ext_fbk_cntr == "c2")
                ext_fbk_cntr_index = 2;
            else if (ext_fbk_cntr == "c3")
                ext_fbk_cntr_index = 3;
            else if (ext_fbk_cntr == "c4")
                ext_fbk_cntr_index = 4;
            else if (ext_fbk_cntr == "c5")
                ext_fbk_cntr_index = 5;
        end
        else
        begin
            op_mode = 0;
            ext_fbk_cntr_index = 0;
        end

        if (m == 0)
        begin

            // set the limit of the divide_by value that can be returned by
            // the following function.
            max_d_value = 500;

            // scale down the multiply_by and divide_by values provided by the design
            // before attempting to use them in the calculations below
            find_simple_integer_fraction(clk0_multiply_by, clk0_divide_by,
                            max_d_value, i_clk0_mult_by, i_clk0_div_by);
            find_simple_integer_fraction(clk1_multiply_by, clk1_divide_by,
                            max_d_value, i_clk1_mult_by, i_clk1_div_by);
            find_simple_integer_fraction(clk2_multiply_by, clk2_divide_by,
                            max_d_value, i_clk2_mult_by, i_clk2_div_by);
            find_simple_integer_fraction(clk3_multiply_by, clk3_divide_by,
                            max_d_value, i_clk3_mult_by, i_clk3_div_by);
            find_simple_integer_fraction(clk4_multiply_by, clk4_divide_by,
                            max_d_value, i_clk4_mult_by, i_clk4_div_by);
            find_simple_integer_fraction(clk5_multiply_by, clk5_divide_by,
                            max_d_value, i_clk5_mult_by, i_clk5_div_by);

            // convert user parameters to advanced
            if (((l_pll_type == "fast") || (l_pll_type == "lvds")) && (vco_multiply_by != 0) && (vco_divide_by != 0))
            begin
                i_n = vco_divide_by;
                i_m = vco_multiply_by;
            end
            else begin
                i_n = 1;
                i_m = lcm  (i_clk0_mult_by, i_clk1_mult_by,
                            i_clk2_mult_by, i_clk3_mult_by,
                            i_clk4_mult_by, i_clk5_mult_by,
                            1, 1, 1, 1, inclk0_input_frequency);
            end

            i_c_high[0] = counter_high (output_counter_value(i_clk0_div_by,
                                        i_clk0_mult_by, i_m, i_n), clk0_duty_cycle);
            i_c_high[1] = counter_high (output_counter_value(i_clk1_div_by,
                                        i_clk1_mult_by, i_m, i_n), clk1_duty_cycle);
            i_c_high[2] = counter_high (output_counter_value(i_clk2_div_by,
                                        i_clk2_mult_by, i_m, i_n), clk2_duty_cycle);
            i_c_high[3] = counter_high (output_counter_value(i_clk3_div_by,
                                        i_clk3_mult_by, i_m, i_n), clk3_duty_cycle);
            i_c_high[4] = counter_high (output_counter_value(i_clk4_div_by,
                                        i_clk4_mult_by,  i_m, i_n), clk4_duty_cycle);
            i_c_high[5] = counter_high (output_counter_value(i_clk5_div_by,
                                        i_clk5_mult_by,  i_m, i_n), clk5_duty_cycle);

            i_c_low[0]  = counter_low  (output_counter_value(i_clk0_div_by,
                                        i_clk0_mult_by,  i_m, i_n), clk0_duty_cycle);
            i_c_low[1]  = counter_low  (output_counter_value(i_clk1_div_by,
                                        i_clk1_mult_by,  i_m, i_n), clk1_duty_cycle);
            i_c_low[2]  = counter_low  (output_counter_value(i_clk2_div_by,
                                        i_clk2_mult_by,  i_m, i_n), clk2_duty_cycle);
            i_c_low[3]  = counter_low  (output_counter_value(i_clk3_div_by,
                                        i_clk3_mult_by,  i_m, i_n), clk3_duty_cycle);
            i_c_low[4]  = counter_low  (output_counter_value(i_clk4_div_by,
                                        i_clk4_mult_by,  i_m, i_n), clk4_duty_cycle);
            i_c_low[5]  = counter_low  (output_counter_value(i_clk5_div_by,
                                        i_clk5_mult_by,  i_m, i_n), clk5_duty_cycle);

            if (l_pll_type == "flvds")
            begin
                // Need to readjust phase shift values when the clock multiply value has been readjusted.
                new_multiplier = clk0_multiply_by / i_clk0_mult_by;
                i_clk0_phase_shift = (clk0_phase_shift_num * new_multiplier);
                i_clk1_phase_shift = (clk1_phase_shift_num * new_multiplier);
                i_clk2_phase_shift = (clk2_phase_shift_num * new_multiplier);
            end
            else
            begin
                i_clk0_phase_shift = get_int_phase_shift(clk0_phase_shift, clk0_phase_shift_num);
                i_clk1_phase_shift = get_int_phase_shift(clk1_phase_shift, clk1_phase_shift_num);
                i_clk2_phase_shift = get_int_phase_shift(clk2_phase_shift, clk2_phase_shift_num);
            end

            max_neg_abs = maxnegabs   ( i_clk0_phase_shift,
                                        i_clk1_phase_shift,
                                        i_clk2_phase_shift,
                                        str2int(clk3_phase_shift),
                                        str2int(clk4_phase_shift),
                                        str2int(clk5_phase_shift),
                                        0, 0, 0, 0);

            i_c_initial[0] = counter_initial(get_phase_degree(ph_adjust(i_clk0_phase_shift, max_neg_abs)), i_m, i_n);
            i_c_initial[1] = counter_initial(get_phase_degree(ph_adjust(i_clk1_phase_shift, max_neg_abs)), i_m, i_n);
            i_c_initial[2] = counter_initial(get_phase_degree(ph_adjust(i_clk2_phase_shift, max_neg_abs)), i_m, i_n);
            i_c_initial[3] = counter_initial(get_phase_degree(ph_adjust(str2int(clk3_phase_shift), max_neg_abs)), i_m, i_n);
            i_c_initial[4] = counter_initial(get_phase_degree(ph_adjust(str2int(clk4_phase_shift), max_neg_abs)), i_m, i_n);
            i_c_initial[5] = counter_initial(get_phase_degree(ph_adjust(str2int(clk5_phase_shift), max_neg_abs)), i_m, i_n);

            i_c_mode[0] = counter_mode(clk0_duty_cycle, output_counter_value(i_clk0_div_by, i_clk0_mult_by,  i_m, i_n));
            i_c_mode[1] = counter_mode(clk1_duty_cycle,output_counter_value(i_clk1_div_by, i_clk1_mult_by,  i_m, i_n));
            i_c_mode[2] = counter_mode(clk2_duty_cycle,output_counter_value(i_clk2_div_by, i_clk2_mult_by,  i_m, i_n));
            i_c_mode[3] = counter_mode(clk3_duty_cycle,output_counter_value(i_clk3_div_by, i_clk3_mult_by,  i_m, i_n));
            i_c_mode[4] = counter_mode(clk4_duty_cycle,output_counter_value(i_clk4_div_by, i_clk4_mult_by,  i_m, i_n));
            i_c_mode[5] = counter_mode(clk5_duty_cycle,output_counter_value(i_clk5_div_by, i_clk5_mult_by,  i_m, i_n));

            i_m_ph    = counter_ph(get_phase_degree(max_neg_abs), i_m, i_n);
            i_m_initial = counter_initial(get_phase_degree(max_neg_abs), i_m, i_n);

            i_c_ph[0] = counter_ph(get_phase_degree(ph_adjust(i_clk0_phase_shift, max_neg_abs)), i_m, i_n);
            i_c_ph[1] = counter_ph(get_phase_degree(ph_adjust(i_clk1_phase_shift, max_neg_abs)), i_m, i_n);
            i_c_ph[2] = counter_ph(get_phase_degree(ph_adjust(i_clk2_phase_shift, max_neg_abs)), i_m, i_n);
            i_c_ph[3] = counter_ph(get_phase_degree(ph_adjust(str2int(clk3_phase_shift),max_neg_abs)), i_m, i_n);
            i_c_ph[4] = counter_ph(get_phase_degree(ph_adjust(str2int(clk4_phase_shift),max_neg_abs)), i_m, i_n);
            i_c_ph[5] = counter_ph(get_phase_degree(ph_adjust(str2int(clk5_phase_shift),max_neg_abs)), i_m, i_n);

            // in external feedback mode, need to adjust M value to take
            // into consideration the external feedback counter value
            if (l_operation_mode == "external_feedback")
            begin
                // if there is a negative phase shift, m_initial can only be 1
                if (max_neg_abs > 0)
                    i_m_initial = 1;

                if (i_c_mode[ext_fbk_cntr_index] == "bypass")
                    output_count = 1;
                else
                    output_count = i_c_high[ext_fbk_cntr_index] + i_c_low[ext_fbk_cntr_index];

                new_divisor = gcd(i_m, output_count);
                i_m = i_m / new_divisor;
                i_n = output_count / new_divisor;
            end

        end
        else
        begin //  m != 0

            i_n = n;
            i_m = m;
            i_c_high[0] = c0_high;
            i_c_high[1] = c1_high;
            i_c_high[2] = c2_high;
            i_c_high[3] = c3_high;
            i_c_high[4] = c4_high;
            i_c_high[5] = c5_high;
            i_c_low[0]  = c0_low;
            i_c_low[1]  = c1_low;
            i_c_low[2]  = c2_low;
            i_c_low[3]  = c3_low;
            i_c_low[4]  = c4_low;
            i_c_low[5]  = c5_low;
            i_c_initial[0] = c0_initial;
            i_c_initial[1] = c1_initial;
            i_c_initial[2] = c2_initial;
            i_c_initial[3] = c3_initial;
            i_c_initial[4] = c4_initial;
            i_c_initial[5] = c5_initial;
            i_c_mode[0] = translate_string(alpha_tolower(c0_mode));
            i_c_mode[1] = translate_string(alpha_tolower(c1_mode));
            i_c_mode[2] = translate_string(alpha_tolower(c2_mode));
            i_c_mode[3] = translate_string(alpha_tolower(c3_mode));
            i_c_mode[4] = translate_string(alpha_tolower(c4_mode));
            i_c_mode[5] = translate_string(alpha_tolower(c5_mode));
            i_c_ph[0]  = c0_ph;
            i_c_ph[1]  = c1_ph;
            i_c_ph[2]  = c2_ph;
            i_c_ph[3]  = c3_ph;
            i_c_ph[4]  = c4_ph;
            i_c_ph[5]  = c5_ph;
            i_m_ph   = m_ph;        // default
            i_m_initial = m_initial;

        end // user to advanced conversion

        refclk_period = inclk0_input_frequency * i_n;

        m_times_vco_period = refclk_period;
        new_m_times_vco_period = refclk_period;

        fbclk_period = 0;
        high_time = 0;
        low_time = 0;
        schedule_vco = 0;
        vco_out[7:0] = 8'b0;
        vco_tap[7:0] = 8'b0;
        fbclk_last_value = 0;
        offset = 0;
        temp_offset = 0;
        got_first_refclk = 0;
        got_first_fbclk = 0;
        fbclk_time = 0;
        first_fbclk_time = 0;
        refclk_time = 0;
        first_schedule = 1;
        sched_time = 0;
        vco_val = 0;
        c0_got_first_rising_edge = 0;
        c1_got_first_rising_edge = 0;
        vco_c0_last_value = 0;
        c0_count = 2;
        c0_initial_count = 1;
        c1_count = 2;
        c1_initial_count = 1;
        c0_tmp = 0;
        c1_tmp = 0;
        gate_count = 0;
        gate_out = 0;
        initial_delay = 0;
        fbk_phase = 0;
        for (i = 0; i <= 7; i = i + 1)
        begin
            phase_shift[i] = 0;
            last_phase_shift[i] = 0;
        end
        fbk_delay = 0;
        inclk_n = 0;
        cycle_to_adjust = 0;
        m_delay = 0;
        vco_c0 = 0;
        vco_c1 = 0;
        total_pull_back = 0;
        pull_back_M = 0;
        vco_period_was_phase_adjusted = 0;
        phase_adjust_was_scheduled = 0;
        ena_ipd_last_value = 0;
        inclk_out_of_range = 0;
        scandone_tmp = 0;
        schedule_vco_last_value = 0;

        // set initial values for counter parameters
        m_initial_val = i_m_initial;
        m_val[0] = i_m;
        n_val[0] = i_n;
        m_ph_val = i_m_ph;
        m_ph_val_orig = i_m_ph;
        m_ph_val_tmp = i_m_ph;
        m_val_tmp[0] = i_m;

        m_val[1] = m2;
        n_val[1] = n2;

        if (m_val[0] == 1)
            m_mode_val[0] = "bypass";
        else m_mode_val[0] = "";
        if (m_val[1] == 1)
            m_mode_val[1] = "bypass";
        if (n_val[0] == 1)
            n_mode_val[0] = "bypass";
        if (n_val[1] == 1)
            n_mode_val[1] = "bypass";

        for (i = 0; i < 6; i=i+1)
        begin
            c_high_val[i] = i_c_high[i];
            c_low_val[i] = i_c_low[i];
            c_initial_val[i] = i_c_initial[i];
            c_mode_val[i] = i_c_mode[i];
            c_ph_val[i] = i_c_ph[i];
            c_high_val_tmp[i] = i_c_high[i];
            c_low_val_tmp[i] = i_c_low[i];
            if (c_mode_val[i] == "bypass")
            begin
                if (l_pll_type == "fast" || l_pll_type == "lvds")
                begin
                    c_high_val[i] = 5'b10000;
                    c_low_val[i] = 5'b10000;
                    c_high_val_tmp[i] = 5'b10000;
                    c_low_val_tmp[i] = 5'b10000;
                end
                else begin
                    c_high_val[i] = 9'b100000000;
                    c_low_val[i] = 9'b100000000;
                    c_high_val_tmp[i] = 9'b100000000;
                    c_low_val_tmp[i] = 9'b100000000;
                end
            end

            c_mode_val_tmp[i] = i_c_mode[i];
            c_ph_val_tmp[i] = i_c_ph[i];

            c_ph_val_orig[i] = i_c_ph[i];
            c_high_val_hold[i] = i_c_high[i];
            c_low_val_hold[i] = i_c_low[i];
            c_mode_val_hold[i] = i_c_mode[i];
        end

        lfc_val = loop_filter_c;
        lfr_val = loop_filter_r;
        cp_curr_val = charge_pump_current;

        i = 0;
        j = 0;
        inclk_last_value = 0;

        ext_fbk_cntr_ph = 0;
        ext_fbk_cntr_initial = 1;

        // initialize clkswitch variables

        clk0_is_bad = 0;
        clk1_is_bad = 0;
        inclk0_last_value = 0;
        inclk1_last_value = 0;
        other_clock_value = 0;
        other_clock_last_value = 0;
        primary_clk_is_bad = 0;
        current_clk_is_bad = 0;
        external_switch = 0;
        if (l_primary_clock == "inclk0")
            current_clock = 0;
        else current_clock = 1;

        active_clock = 0;   // primary_clk is always inclk0
        if (l_pll_type == "fast")
            l_switch_over_type = "manual";

        if (l_switch_over_type == "manual" && clkswitch_ipd === 1'b1)
        begin
            current_clock = 1;
            active_clock = 1;
        end
        clkloss_tmp = 0;
        got_curr_clk_falling_edge_after_clkswitch = 0;
        clk0_count = 0;
        clk1_count = 0;
        switch_over_count = 0;

        // initialize reconfiguration variables
        // quiet_time
        quiet_time = slowest_clk  ( c_high_val[0]+c_low_val[0], c_mode_val[0],
                                    c_high_val[1]+c_low_val[1], c_mode_val[1],
                                    c_high_val[2]+c_low_val[2], c_mode_val[2],
                                    c_high_val[3]+c_low_val[3], c_mode_val[3],
                                    c_high_val[4]+c_low_val[4], c_mode_val[4],
                                    c_high_val[5]+c_low_val[5], c_mode_val[5],
                                    refclk_period, m_val[0]);
        reconfig_err = 0;
        error = 0;
        scanread_active_edge = 0;
        if ((l_pll_type == "fast") || (l_pll_type == "lvds"))
        begin
            scan_chain_length = FAST_SCAN_CHAIN;
            num_output_cntrs = 4;
        end
        else
        begin
            scan_chain_length = GPP_SCAN_CHAIN;
            num_output_cntrs = 6;
        end
        scanread_reg = 0;
        scanwrite_reg = 0;
        scanwrite_enabled = 0;
        c0_rising_edge_transfer_done = 0;
        c1_rising_edge_transfer_done = 0;
        c2_rising_edge_transfer_done = 0;
        c3_rising_edge_transfer_done = 0;
        c4_rising_edge_transfer_done = 0;
        c5_rising_edge_transfer_done = 0;
        got_first_scanclk = 0;
        got_first_gated_scanclk = 0;
        gated_scanclk = 1;
        scanread_setup_violation = 0;
        index = 0;

        // initialize the scan_chain contents
        // CP/LF  bits
        scan_data[11:0] = 12'b0;
        for (i = 0; i <= 3; i = i + 1)
        begin
            if ((l_pll_type == "fast") || (l_pll_type == "lvds"))
            begin
                if (fpll_loop_filter_c_arr[i] == loop_filter_c)
                    scan_data[11:10] = i;
            end
            else begin
                if (loop_filter_c_arr[i] == loop_filter_c)
                    scan_data[11:10] = i;
            end
        end
        for (i = 0; i <= 15; i = i + 1)
        begin
            if (charge_pump_curr_arr[i] == charge_pump_current)
                scan_data[3:0] = i;
        end
        for (i = 0; i <= 39; i = i + 1)
        begin
            if (loop_filter_r_arr[i] == loop_filter_r)
            begin
                if ((i >= 16) && (i <= 23))
                    scan_data[9:4] = i+8;
                else if ((i >= 24) && (i <= 31))
                    scan_data[9:4] = i+16;
                else if (i >= 32)
                    scan_data[9:4] = i+24;
                else
                    scan_data[9:4] = i;
            end
        end

        if (l_pll_type == "fast" || l_pll_type == "lvds")
        begin
            scan_data[21:12] = 10'b0; // M, C3-C0 ph
            // C0-C3 high
            scan_data[25:22] = c_high_val[0];
            scan_data[35:32] = c_high_val[1];
            scan_data[45:42] = c_high_val[2];
            scan_data[55:52] = c_high_val[3];
            // C0-C3 low
            scan_data[30:27] = c_low_val[0];
            scan_data[40:37] = c_low_val[1];
            scan_data[50:47] = c_low_val[2];
            scan_data[60:57] = c_low_val[3];
            // C0-C3 mode
            for (i = 0; i < 4; i = i + 1)
            begin
                if (c_mode_val[i] == "   off" || c_mode_val[i] == "bypass")
                begin
                    scan_data[26 + (10*i)] = 1;
                    if (c_mode_val[i] == "   off")
                        scan_data[31 + (10*i)] = 1;
                    else
                        scan_data[31 + (10*i)] = 0;
                end
                else begin
                    scan_data[26 + (10*i)] = 0;
                    if (c_mode_val[i] == "   odd")
                        scan_data[31 + (10*i)] = 1;
                    else
                        scan_data[31 + (10*i)] = 0;
                end
            end
            // M
            if (m_mode_val[0] == "bypass")
            begin
                scan_data[66] = 1;
                scan_data[71] = 0;
                scan_data[65:62] = 4'b0;
                scan_data[70:67] = 4'b0;
            end
            else begin
                scan_data[66] = 0;       // set BYPASS bit to 0
                scan_data[70:67] = m_val[0]/2;   // set M low
                if (m_val[0] % 2 == 0)
                begin
                    // M is an even no. : set M high = low,
                    // set odd/even bit to 0
                    scan_data[65:62] = scan_data[70:67];
                    scan_data[71] = 0;
                end
                else begin // M is odd : M high = low + 1
                    scan_data[65:62] = (m_val[0]/2) + 1;
                    scan_data[71] = 1;
                end
            end
            // N
            scan_data[73:72] = n_val[0];
            if (n_mode_val[0] == "bypass")
            begin
                scan_data[74] = 1;
                scan_data[73:72] = 2'b0;
            end
        end
        else begin             // PLL type is enhanced/auto
            scan_data[25:12] = 14'b0;

            // C5-C0 high
            scan_data[33:26] = c_high_val[5];
            scan_data[51:44] = c_high_val[4];
            scan_data[69:62] = c_high_val[3];
            scan_data[87:80] = c_high_val[2];
            scan_data[105:98] = c_high_val[1];
            scan_data[123:116] = c_high_val[0];
            // C5-C0 low
            scan_data[42:35] = c_low_val[5];
            scan_data[60:53] = c_low_val[4];
            scan_data[78:71] = c_low_val[3];
            scan_data[96:89] = c_low_val[2];
            scan_data[114:107] = c_low_val[1];
            scan_data[132:125] = c_low_val[0];

            for (i = 5; i >= 0; i = i - 1)
            begin
                if (c_mode_val[i] == "   off" || c_mode_val[i] == "bypass")
                begin
                    scan_data[124 - (18*i)] = 1;
                    if (c_mode_val[i] == "   off")
                        scan_data[133 - (18*i)] = 1;
                    else
                        scan_data[133 - (18*i)] = 0;
                end
                else begin
                    scan_data[124 - (18*i)] = 0;
                    if (c_mode_val[i] == "   odd")
                        scan_data[133 - (18*i)] = 1;
                    else
                        scan_data[133 - (18*i)] = 0;
                end
            end

            scan_data[142:134] = m_val[0];
            scan_data[143] = 0;
            scan_data[152:144] = m_val[1];
            scan_data[153] = 0;
            if (m_mode_val[0] == "bypass")
            begin
                scan_data[143] = 1;
                scan_data[142:134] = 9'b0;
            end
            if (m_mode_val[1] == "bypass")
            begin
                scan_data[153] = 1;
                scan_data[152:144] = 9'b0;
            end

            scan_data[162:154] = n_val[0];
            scan_data[172:164] = n_val[1];
            if (n_mode_val[0] == "bypass")
            begin
                scan_data[163] = 1;
                scan_data[162:154] = 9'b0;
            end
            if (n_mode_val[1] == "bypass")
            begin
                scan_data[173] = 1;
                scan_data[172:164] = 9'b0;
            end
        end

        // now save this counter's parameters
        ext_fbk_cntr_high = c_high_val[ext_fbk_cntr_index];
        ext_fbk_cntr_low = c_low_val[ext_fbk_cntr_index];
        ext_fbk_cntr_ph = c_ph_val[ext_fbk_cntr_index];
        ext_fbk_cntr_initial = c_initial_val[ext_fbk_cntr_index];
        ext_fbk_cntr_mode = c_mode_val[ext_fbk_cntr_index];

        if (ext_fbk_cntr_mode == "bypass")
            ext_fbk_cntr_modulus = 1;
        else
            ext_fbk_cntr_modulus = ext_fbk_cntr_high + ext_fbk_cntr_low;

        l_index = 1;
        stop_vco = 0;
        cycles_to_lock = 0;
        cycles_to_unlock = 0;
        locked_tmp = 0;
        pll_is_locked = 0;
        pll_about_to_lock = 0;
        no_warn = 1'b0;

        // check if pll is in test mode
        if (m_test_source != 5 || c0_test_source != 5 || c1_test_source != 5 || c2_test_source != 5 || c3_test_source != 5 || c4_test_source != 5 || c5_test_source != 5)
            pll_in_test_mode = 1'b1;
        else
            pll_in_test_mode = 1'b0;


        pll_is_in_reset = 0;
        pll_is_disabled = 0;
        if (l_pll_type == "fast" || l_pll_type == "lvds")
            is_fast_pll = 1;
        else is_fast_pll = 0;

        if (c1_use_casc_in == "on")
            ic1_use_casc_in = 1;
        else
            ic1_use_casc_in = 0;
        if (c2_use_casc_in == "on")
            ic2_use_casc_in = 1;
        else
            ic2_use_casc_in = 0;
        if (c3_use_casc_in == "on")
            ic3_use_casc_in = 1;
        else
            ic3_use_casc_in = 0;
        if (c4_use_casc_in == "on")
            ic4_use_casc_in = 1;
        else
            ic4_use_casc_in = 0;
        if (c5_use_casc_in == "on")
            ic5_use_casc_in = 1;
        else
            ic5_use_casc_in = 0;

        tap0_is_active = 1;
        next_vco_sched_time = 0;
    end

    always @(clkswitch_ipd)
    begin
        if (clkswitch_ipd === 1'b1 && l_switch_over_type == "auto")
            external_switch = 1;
        else if (l_switch_over_type == "manual")
        begin
            if (clkswitch_ipd === 1'b1)
            begin
                current_clock = 1;
                active_clock = 1;
                inclk_n = inclk1_ipd;
            end
            else if (clkswitch_ipd === 1'b0)
            begin
                current_clock = 0;
                active_clock = 0;
                inclk_n = inclk0_ipd;
            end
        end
    end

    always @(inclk0_ipd or inclk1_ipd)
    begin
        // save the inclk event value
        if (inclk0_ipd !== inclk0_last_value)
        begin
            if (current_clock != 0)
                other_clock_value = inclk0_ipd;
        end
        if (inclk1_ipd !== inclk1_last_value)
        begin
            if (current_clock != 1)
                other_clock_value = inclk1_ipd;
        end

        // check if either input clk is bad
        if (inclk0_ipd === 1'b1 && inclk0_ipd !== inclk0_last_value)
        begin
            clk0_count = clk0_count + 1;
            clk0_is_bad = 0;
            clk1_count = 0;
            if (clk0_count > 2)
            begin
                // no event on other clk for 2 cycles
                clk1_is_bad = 1;
                if (current_clock == 1)
                    current_clk_is_bad = 1;
            end
        end
        if (inclk1_ipd === 1'b1 && inclk1_ipd !== inclk1_last_value)
        begin
            clk1_count = clk1_count + 1;
            clk1_is_bad = 0;
            clk0_count = 0;
            if (clk1_count > 2)
            begin
                // no event on other clk for 2 cycles
                clk0_is_bad = 1;
                if (current_clock == 0)
                    current_clk_is_bad = 1;
            end
        end

        // check if the bad clk is the primary clock, which is always clk0
        if (clk0_is_bad == 1'b1)
            primary_clk_is_bad = 1;
        else
            primary_clk_is_bad = 0;

        // actual switching -- manual switch
        if ((inclk0_ipd !== inclk0_last_value) && current_clock == 0)
        begin
            if (external_switch == 1'b1)
            begin
                if (!got_curr_clk_falling_edge_after_clkswitch)
                begin
                    if (inclk0_ipd === 1'b0)
                        got_curr_clk_falling_edge_after_clkswitch = 1;
                    inclk_n = inclk0_ipd;
                end
            end
            else inclk_n = inclk0_ipd;
        end
        if ((inclk1_ipd !== inclk1_last_value) && current_clock == 1)
        begin
            if (external_switch == 1'b1)
            begin
                if (!got_curr_clk_falling_edge_after_clkswitch)
                begin
                    if (inclk1_ipd === 1'b0)
                        got_curr_clk_falling_edge_after_clkswitch = 1;
                    inclk_n = inclk1_ipd;
                end
            end
            else inclk_n = inclk1_ipd;
        end

        // actual switching -- automatic switch
        if ((other_clock_value == 1'b1) && (other_clock_value != other_clock_last_value) && (l_switch_over_on_lossclk == "on") && l_enable_switch_over_counter == "on" && primary_clk_is_bad)
            switch_over_count = switch_over_count + 1;

        if ((other_clock_value == 1'b0) && (other_clock_value != other_clock_last_value))
        begin
            if ((external_switch && (got_curr_clk_falling_edge_after_clkswitch || current_clk_is_bad)) || (l_switch_over_on_lossclk == "on" && primary_clk_is_bad && l_pll_type !== "fast" && l_pll_type !== "lvds" && (clkswitch_ipd !== 1'b1) && ((l_enable_switch_over_counter == "off" || switch_over_count == switch_over_counter))))
            begin
                got_curr_clk_falling_edge_after_clkswitch = 0;
                if (current_clock == 0)
                    current_clock = 1;
                else
                    current_clock = 0;
                active_clock = ~active_clock;
                switch_over_count = 0;
                external_switch = 0;
                current_clk_is_bad = 0;
            end
        end

        if (l_switch_over_on_lossclk == "on" && (clkswitch_ipd != 1'b1))
        begin
            if (primary_clk_is_bad)
                clkloss_tmp = 1;
            else
                clkloss_tmp = 0;
        end
        else clkloss_tmp = clkswitch_ipd;

        inclk0_last_value = inclk0_ipd;
        inclk1_last_value = inclk1_ipd;
        other_clock_last_value = other_clock_value;

    end

    and (clkbad[0], clk0_is_bad, 1'b1);
    and (clkbad[1], clk1_is_bad, 1'b1);
    and (activeclock, active_clock, 1'b1);
    and (clkloss, clkloss_tmp, 1'b1);

    MF_pll_reg ena_reg ( .clk(!inclk_n),
                                .ena(1'b1),
                                .d(ena_ipd),
                                .clrn(1'b1),
                                .prn(1'b1),
                                .q(pllena_reg));

    and (test_mode_inclk, inclk_n, pllena_reg);
    assign n_cntr_inclk = (pll_in_test_mode === 1'b1) ? test_mode_inclk : inclk_n;
    assign ena_pll = (pll_in_test_mode === 1'b1) ? pllena_reg : ena_ipd;

    assign inclk_m = (m_test_source == 0) ? n_cntr_inclk : op_mode == 1 ? (l_feedback_source == "clk0" ? clk_tmp[0] :
                        l_feedback_source == "clk1" ? clk_tmp[1] :
                        l_feedback_source == "clk2" ? clk_tmp[2] :
                        l_feedback_source == "clk3" ? clk_tmp[3] :
                        l_feedback_source == "clk4" ? clk_tmp[4] :
                        l_feedback_source == "clk5" ? clk_tmp[5] : 1'b0) :
                        inclk_m_from_vco;


    arm_m_cntr m1 (.clk(inclk_m),
                        .reset(areset_ipd || (!ena_pll) || stop_vco),
                        .cout(fbclk),
                        .initial_value(m_initial_val),
                        .modulus(m_val[0]),
                        .time_delay(m_delay));

    arm_n_cntr n1 (.clk(n_cntr_inclk),
                        .reset(areset_ipd),
                        .cout(refclk),
                        .modulus(n_val[0]));


    always @(vco_out[0])
    begin
        // now schedule the other taps with the appropriate phase-shift
        for (k = 1; k <= 7; k=k+1)
        begin
            phase_shift[k] = (k*tmp_vco_per)/8;
            vco_out[k] <= #(phase_shift[k]) vco_out[0];
        end
    end

    always @(vco_out)
    begin
        // check which VCO TAP has event
        for (x = 0; x <= 7; x = x + 1)
        begin
            if (vco_out[x] !== vco_out_last_value[x])
            begin
                // TAP 'X' has event
                if ((x == 0) && (!pll_is_in_reset) && (!pll_is_disabled) && (stop_vco !== 1'b1))
                begin
                    if (vco_out[0] == 1'b1)
                        tap0_is_active = 1;
                    if (tap0_is_active == 1'b1)
                        vco_tap[0] <= vco_out[0];
                end
                else if (tap0_is_active == 1'b1)
                    vco_tap[x] <= vco_out[x];
                if (stop_vco === 1'b1)
                    vco_out[x] <= 1'b0;
            end
        end
        vco_out_last_value = vco_out;
    end

    always @(vco_tap)
    begin
        // check which VCO TAP has event
        for (x = 0; x <= 7; x = x + 1)
        begin
            if (vco_tap[x] !== vco_tap_last_value[x])
            begin
                if (c_ph_val[0] == x)
                begin
                    inclk_c0_from_vco <= vco_tap[x];
                    if (is_fast_pll == 1'b1)
                    begin
                    if (ena0_cntr == 0)
                        inclk_sclkout0_from_vco <= vco_tap[x];
                    if (ena1_cntr == 0)
                        inclk_sclkout1_from_vco <= vco_tap[x];
                    end
                end
                if (c_ph_val[1] == x)
                begin
                    inclk_c1_from_vco <= vco_tap[x];
                    if (is_fast_pll == 1'b1)
                    begin
                    if (ena0_cntr == 1)
                        inclk_sclkout0_from_vco <= vco_tap[x];
                    if (ena1_cntr == 1)
                        inclk_sclkout1_from_vco <= vco_tap[x];
                    end
                end
                if (c_ph_val[2] == x)
                    inclk_c2_from_vco <= vco_tap[x];
                if (c_ph_val[3] == x)
                    inclk_c3_from_vco <= vco_tap[x];
                if (c_ph_val[4] == x)
                    inclk_c4_from_vco <= vco_tap[x];
                if (c_ph_val[5] == x)
                    inclk_c5_from_vco <= vco_tap[x];
                if (m_ph_val == x)
                    inclk_m_from_vco <= vco_tap[x];
            end
        end
        if (scanwrite_enabled === 1'b1)
        begin
        for (x = 0; x <= 7; x = x + 1)
        begin
            if ((vco_tap[x] === 1'b0) && (vco_tap[x] !== vco_tap_last_value[x]))
            begin
                for (y = 0; y <= 5; y = y + 1)
                begin
                    if (c_ph_val[y] == x)
                        c_ph_val[y] <= c_ph_val_tmp[y];
                end
                if (m_ph_val == x)
                    m_ph_val <= m_ph_val_tmp;
            end
        end
        end

        // reset all counter phase tap values to POF programmed values
        if (areset_ipd === 1'b1)
        begin
            m_ph_val <= m_ph_val_orig;
            m_ph_val_tmp <= m_ph_val_orig;
            for (i=0; i<= 5; i=i+1)
            begin
                c_ph_val[i] <= c_ph_val_orig[i];
                c_ph_val_tmp[i] <= c_ph_val_orig[i];
            end
        end

        vco_tap_last_value = vco_tap;
    end

    always @(inclk_sclkout0_from_vco)
    begin
        sclkout0_tmp <= inclk_sclkout0_from_vco;
    end
    always @(inclk_sclkout1_from_vco)
    begin
        sclkout1_tmp <= inclk_sclkout1_from_vco;
    end

    assign inclk_c0 = (c0_test_source == 0) ? n_cntr_inclk : (c0_test_source == 1) ? refclk : inclk_c0_from_vco;

    arm_scale_cntr c0 (.clk(inclk_c0),
                            .reset(areset_ipd || (!ena_pll) || stop_vco),
                            .cout(c0_clk),
                            .high(c_high_val[0]),
                            .low(c_low_val[0]),
                            .initial_value(c_initial_val[0]),
                            .mode(c_mode_val[0]),
                            .ph_tap(c_ph_val[0]));

    always @(posedge c0_clk)
    begin
        if (scanwrite_enabled == 1'b1)
        begin
            c_high_val[0] <= c_high_val_tmp[0];
            c_mode_val[0] <= c_mode_val_tmp[0];
            c0_rising_edge_transfer_done = 1;
        end
    end
    always @(negedge c0_clk)
    begin
        if (c0_rising_edge_transfer_done)
        begin
            c_low_val[0] <= c_low_val_tmp[0];
        end
    end

    assign inclk_c1 = (c1_test_source == 0) ? n_cntr_inclk : (c1_test_source == 2) ? fbclk : (ic1_use_casc_in == 1) ? c0_clk : inclk_c1_from_vco;

    arm_scale_cntr c1 (.clk(inclk_c1),
                            .reset(areset_ipd || (!ena_pll) || stop_vco),
                            .cout(c1_clk),
                            .high(c_high_val[1]),
                            .low(c_low_val[1]),
                            .initial_value(c_initial_val[1]),
                            .mode(c_mode_val[1]),
                            .ph_tap(c_ph_val[1]));

    always @(posedge c1_clk)
    begin
        if (scanwrite_enabled == 1'b1)
        begin
            c_high_val[1] <= c_high_val_tmp[1];
            c_mode_val[1] <= c_mode_val_tmp[1];
            c1_rising_edge_transfer_done = 1;
        end
    end
    always @(negedge c1_clk)
    begin
        if (c1_rising_edge_transfer_done)
        begin
            c_low_val[1] <= c_low_val_tmp[1];
        end
    end

    assign inclk_c2 = (c2_test_source == 0) ? n_cntr_inclk : (ic2_use_casc_in == 1) ? c1_clk : inclk_c2_from_vco;

    arm_scale_cntr c2 (.clk(inclk_c2),
                            .reset(areset_ipd || (!ena_pll) || stop_vco),
                            .cout(c2_clk),
                            .high(c_high_val[2]),
                            .low(c_low_val[2]),
                            .initial_value(c_initial_val[2]),
                            .mode(c_mode_val[2]),
                            .ph_tap(c_ph_val[2]));

    always @(posedge c2_clk)
    begin
        if (scanwrite_enabled == 1'b1)
        begin
            c_high_val[2] <= c_high_val_tmp[2];
            c_mode_val[2] <= c_mode_val_tmp[2];
            c2_rising_edge_transfer_done = 1;
        end
    end
    always @(negedge c2_clk)
    begin
        if (c2_rising_edge_transfer_done)
        begin
            c_low_val[2] <= c_low_val_tmp[2];
        end
    end

    assign inclk_c3 = (c3_test_source == 0) ? n_cntr_inclk : (ic3_use_casc_in == 1) ? c2_clk : inclk_c3_from_vco;
    arm_scale_cntr c3 (.clk(inclk_c3),
                            .reset(areset_ipd || (!ena_pll) || stop_vco),
                            .cout(c3_clk),
                            .high(c_high_val[3]),
                            .low(c_low_val[3]),
                            .initial_value(c_initial_val[3]),
                            .mode(c_mode_val[3]),
                            .ph_tap(c_ph_val[3]));

    always @(posedge c3_clk)
    begin
        if (scanwrite_enabled == 1'b1)
        begin
            c_high_val[3] <= c_high_val_tmp[3];
            c_mode_val[3] <= c_mode_val_tmp[3];
            c3_rising_edge_transfer_done = 1;
        end
    end
    always @(negedge c3_clk)
    begin
        if (c3_rising_edge_transfer_done)
        begin
            c_low_val[3] <= c_low_val_tmp[3];
        end
    end

    assign inclk_c4 = ((c4_test_source == 0) ? n_cntr_inclk : (ic4_use_casc_in == 1) ? c3_clk : inclk_c4_from_vco);
    arm_scale_cntr c4 (.clk(inclk_c4),
                            .reset(areset_ipd || (!ena_pll) || stop_vco),
                            .cout(c4_clk),
                            .high(c_high_val[4]),
                            .low(c_low_val[4]),
                            .initial_value(c_initial_val[4]),
                            .mode(c_mode_val[4]),
                            .ph_tap(c_ph_val[4]));

    always @(posedge c4_clk)
    begin
        if (scanwrite_enabled == 1'b1)
        begin
            c_high_val[4] <= c_high_val_tmp[4];
            c_mode_val[4] <= c_mode_val_tmp[4];
            c4_rising_edge_transfer_done = 1;
        end
    end
    always @(negedge c4_clk)
    begin
        if (c4_rising_edge_transfer_done)
        begin
            c_low_val[4] <= c_low_val_tmp[4];
        end
    end

    assign inclk_c5 = ((c5_test_source == 0) ? n_cntr_inclk : (ic5_use_casc_in == 1) ? c4_clk : inclk_c5_from_vco);
    arm_scale_cntr c5 (.clk(inclk_c5),
                            .reset(areset_ipd || (!ena_pll) || stop_vco),
                            .cout(c5_clk),
                            .high(c_high_val[5]),
                            .low(c_low_val[5]),
                            .initial_value(c_initial_val[5]),
                            .mode(c_mode_val[5]),
                            .ph_tap(c_ph_val[5]));

    always @(posedge c5_clk)
    begin
        if (scanwrite_enabled == 1'b1)
        begin
            c_high_val[5] <= c_high_val_tmp[5];
            c_mode_val[5] <= c_mode_val_tmp[5];
            c5_rising_edge_transfer_done = 1;
        end
    end
    always @(negedge c5_clk)
    begin
        if (c5_rising_edge_transfer_done)
        begin
            c_low_val[5] <= c_low_val_tmp[5];
        end
    end

    always @(vco_tap[c_ph_val[0]] or posedge areset_ipd or negedge ena_pll or stop_vco)
    begin
        if (areset_ipd == 1'b1 || ena_pll == 1'b0 || stop_vco == 1'b1)
        begin
            c0_count = 2;
            c0_initial_count = 1;
            c0_got_first_rising_edge = 0;

        end
        else begin
            if (c0_got_first_rising_edge == 1'b0)
            begin
                if (vco_tap[c_ph_val[0]] == 1'b1 && vco_tap[c_ph_val[0]] != vco_c0_last_value)
                begin
                    if (c0_initial_count == c_initial_val[0])
                        c0_got_first_rising_edge = 1;
                    else
                        c0_initial_count = c0_initial_count + 1;
                end
            end
            else if (vco_tap[c_ph_val[0]] != vco_c0_last_value)
            begin
                c0_count = c0_count + 1;
                if (c0_count == (c_high_val[0] + c_low_val[0]) * 2)
                    c0_count  = 1;
            end
            if (vco_tap[c_ph_val[0]] == 1'b0 && vco_tap[c_ph_val[0]] != vco_c0_last_value)
            begin
                if (c0_count == 1)
                begin
                    c0_tmp = 1;
                    c0_got_first_rising_edge = 0;
                end
                else c0_tmp = 0;
            end
        end
        vco_c0_last_value = vco_tap[c_ph_val[0]];
    end

    always @(vco_tap[c_ph_val[1]] or posedge areset_ipd or negedge ena_pll or stop_vco)
    begin
        if (areset_ipd == 1'b1 || ena_pll == 1'b0 || stop_vco == 1'b1)
        begin
            c1_count = 2;
            c1_initial_count = 1;
            c1_got_first_rising_edge = 0;
        end
        else begin
            if (c1_got_first_rising_edge == 1'b0)
            begin
                if (vco_tap[c_ph_val[1]] == 1'b1 && vco_tap[c_ph_val[1]] != vco_c1_last_value)
                begin
                    if (c1_initial_count == c_initial_val[1])
                        c1_got_first_rising_edge = 1;
                    else
                        c1_initial_count = c1_initial_count + 1;
                end
            end
            else if (vco_tap[c_ph_val[1]] != vco_c1_last_value)
            begin
                c1_count = c1_count + 1;
                if (c1_count == (c_high_val[1] + c_low_val[1]) * 2)
                    c1_count  = 1;
            end
            if (vco_tap[c_ph_val[1]] == 1'b0 && vco_tap[c_ph_val[1]] != vco_c1_last_value)
            begin
                if (c1_count == 1)
                begin
                    c1_tmp = 1;
                    c1_got_first_rising_edge = 0;
                end
                else c1_tmp = 0;
            end
        end
        vco_c1_last_value = vco_tap[c_ph_val[1]];
    end

    assign enable0_tmp = (ena0_cntr == 0) ? c0_tmp : c1_tmp;
    assign enable1_tmp = (ena1_cntr == 0) ? c0_tmp : c1_tmp;

    always @ (inclk_n or ena_pll or areset_ipd)
    begin
        if (areset_ipd == 1'b1 || ena_pll == 1'b0)
        begin
            gate_count = 0;
            gate_out = 0;
        end
        else if (inclk_n == 1'b1 && inclk_last_value != inclk_n)
        begin
            gate_count = gate_count + 1;
            if (l_sim_gate_lock_device_behavior == "on")
            begin
                if (gate_count == gate_lock_counter)
                    gate_out = 1;
            end
            else begin
                if (gate_count == GATE_LOCK_CYCLES)
                    gate_out = 1;
            end
        end
        inclk_last_value = inclk_n;
    end

    assign locked = (l_gate_lock_signal == "yes") ? gate_out && locked_tmp : locked_tmp;

    always @(posedge scanread_ipd)
    begin
        scanread_active_edge = $time;
    end

    always @ (scanclk_ipd)
    begin
        if (scanclk_ipd === 1'b0 && scanclk_last_value === 1'b1)
        begin
            // enable scanwrite on falling edge
            scanwrite_enabled <= scanwrite_reg;
        end
        if (scanread_reg === 1'b1)
            gated_scanclk <= scanclk_ipd && scanread_reg;
        else
            gated_scanclk <= 1'b1;
        if (scanclk_ipd === 1'b1 && scanclk_last_value === 1'b0)
        begin
            // register scanread and scanwrite
            scanread_reg <= scanread_ipd;
            scanwrite_reg <= scanwrite_ipd;

            if (got_first_scanclk)
                scanclk_period = $time - scanclk_last_rising_edge;
            else begin
                got_first_scanclk = 1;
            end
            // reset got_first_scanclk on falling edge of scanread_reg
            if (scanread_ipd == 1'b0 && scanread_reg == 1'b1)
            begin
                got_first_scanclk = 0;
                got_first_gated_scanclk = 0;
            end

            scanclk_last_rising_edge = $time;
        end
        scanclk_last_value = scanclk_ipd;
    end

    always @(posedge gated_scanclk)
    begin
        if ($time > 0)
        begin
        if (!got_first_gated_scanclk)
        begin
            got_first_gated_scanclk = 1;
//            if ($time - scanread_active_edge < scanclk_period)
//            begin
//                scanread_setup_violation = 1;
//                $display("Warning : SCANREAD must go high at least one cycle before SCANDATA is read in.");
//                $display ("Time: %0t  Instance: %m", $time);
//            end
        end
        for (j = scan_chain_length-1; j >= 1; j = j - 1)
        begin
            scan_data[j] = scan_data[j - 1];
        end
        scan_data[0] <= scandata_ipd;
        end
    end

    assign scandataout_tmp = (l_pll_type == "fast" || l_pll_type == "lvds") ? scan_data[FAST_SCAN_CHAIN-1] : scan_data[GPP_SCAN_CHAIN-1];

    always @(posedge scandone_tmp)
    begin
            if (reconfig_err == 1'b0)
            begin
                $display("NOTE : %s PLL Reprogramming completed with the following values (Values in parantheses are original values) : ", family_name);
                $display ("Time: %0t  Instance: %m", $time);

                $display("               N modulus =   %0d (%0d) ", n_val[0], n_val_old[0]);
                $display("               M modulus =   %0d (%0d) ", m_val[0], m_val_old[0]);
                $display("               M ph_tap =    %0d (%0d) ", m_ph_val, m_ph_val_old);
                if (ss > 0)
                begin
                    $display(" M2 modulus =   %0d (%0d) ", m_val[1], m_val_old[1]);
                    $display(" N2 modulus =   %0d (%0d) ", n_val[1], n_val_old[1]);
                end

                for (i = 0; i < num_output_cntrs; i=i+1)
                begin
                    $display("              C%0d  high = %0d (%0d),       C%0d  low = %0d (%0d),       C%0d  mode = %s (%s),       C%0d  phase tap = %0d (%0d)", i, c_high_val[i], c_high_val_old[i], i, c_low_val_tmp[i], c_low_val_old[i], i, c_mode_val[i], c_mode_val_old[i], i, c_ph_val[i], c_ph_val_old[i]);
                end

                // display Charge pump and loop filter values
                $display ("               Charge Pump Current (uA) =   %0d (%0d) ", cp_curr_val, cp_curr_old);
                $display ("               Loop Filter Capacitor (pF) =   %0d (%0d) ", lfc_val, lfc_old);
                $display ("               Loop Filter Resistor (Kohm) =   %s (%s) ", lfr_val, lfr_old);
            end
            else begin
                $display("Warning : Errors were encountered during PLL reprogramming. Please refer to error/warning messages above.");
                $display ("Time: %0t  Instance: %m", $time);
            end
    end

    always @(scanwrite_enabled)
    begin
        if (scanwrite_enabled === 1'b0 && scanwrite_last_value === 1'b1)
        begin
            // falling edge : deassert scandone
            scandone_tmp <= #(1.5*scanclk_period) 1'b0;
            // reset counter transfer flags
            c0_rising_edge_transfer_done = 0;
            c1_rising_edge_transfer_done = 0;
            c2_rising_edge_transfer_done = 0;
            c3_rising_edge_transfer_done = 0;
            c4_rising_edge_transfer_done = 0;
            c5_rising_edge_transfer_done = 0;
        end
        if (scanwrite_enabled === 1'b1 && scanwrite_last_value !== scanwrite_enabled)
        begin

            $display ("NOTE : %s PLL Reprogramming initiated ....", family_name);
            $display ("Time: %0t  Instance: %m", $time);

            error = 0;
            reconfig_err = 0;
            scanread_setup_violation = 0;

            // make temp. copy of scan_data for processing
            tmp_scan_data = scan_data;

            // save old values
            cp_curr_old = cp_curr_val;
            lfc_old = lfc_val;
            lfr_old = lfr_val;

            // CP
            // Bits 0-3 : all values are legal
            cp_curr_val = charge_pump_curr_arr[scan_data[3:0]];

            // LF Resistance : bits 4-9
            // values from 010000 - 010111, 100000 - 100111,
            //             110000- 110111 are illegal
            if (((tmp_scan_data[9:4] >= 6'b010000) && (tmp_scan_data[9:4] <= 6'b010111)) ||
                ((tmp_scan_data[9:4] >= 6'b100000) && (tmp_scan_data[9:4] <= 6'b100111)) ||
                ((tmp_scan_data[9:4] >= 6'b110000) && (tmp_scan_data[9:4] <= 6'b110111)))
            begin
                $display ("Illegal bit settings for Loop Filter Resistance. Legal bit values range from 000000 to 001111, 011000 to 011111, 101000 to 101111 and 111000 to 111111. Reconfiguration may not work.");
                $display ("Time: %0t  Instance: %m", $time);
                reconfig_err = 1;
            end
            else begin
                i = scan_data[9:4];
                if (i >= 56 )
                    i = i - 24;
                else if ((i >= 40) && (i <= 47))
                    i = i - 16;
                else if ((i >= 24) && (i <= 31))
                    i = i - 8;
                lfr_val = loop_filter_r_arr[i];
            end

            // LF Capacitance : bits 10,11 : all values are legal
            if ((l_pll_type == "fast") || (l_pll_type == "lvds"))
                lfc_val = fpll_loop_filter_c_arr[scan_data[11:10]];
            else
                lfc_val = loop_filter_c_arr[scan_data[11:10]];

            // save old values for display info.
            for (i=0; i<=1; i=i+1)
            begin
                m_val_old[i] = m_val[i];
                n_val_old[i] = n_val[i];
                m_mode_val_old[i] = m_mode_val[i];
                n_mode_val_old[i] = n_mode_val[i];
            end
            m_ph_val_old = m_ph_val;
            for (i=0; i<=5; i=i+1)
            begin
                c_high_val_old[i] = c_high_val[i];
                c_low_val_old[i] = c_low_val[i];
                c_ph_val_old[i] = c_ph_val[i];
                c_mode_val_old[i] = c_mode_val[i];
            end

            // first the M counter phase : bit order same for fast and GPP
            if (scan_data[12] == 1'b0)
            begin
                // do nothing
            end
            else if (scan_data[12] === 1'b1 && scan_data[13] === 1'b1)
            begin
                m_ph_val_tmp = m_ph_val_tmp + 1;
                if (m_ph_val_tmp > 7)
                    m_ph_val_tmp = 0;
            end
            else if (scan_data[12] === 1'b1 && scan_data[13] === 1'b0)
            begin
                m_ph_val_tmp = m_ph_val_tmp - 1;
                if (m_ph_val_tmp < 0)
                    m_ph_val_tmp = 7;
            end
            else
            begin
                $display ("Warning : Illegal bit settings for M counter phase tap. Reconfiguration may not work.");
                $display ("Time: %0t  Instance: %m", $time);
                reconfig_err = 1;
            end

            // read the fast PLL bits.
            if (l_pll_type == "fast" || l_pll_type == "lvds")
            begin
                // C3-C0 phase bits
                for (i = 3; i >= 0; i=i-1)
                begin
                    if (tmp_scan_data[14] == 1'b0)
                    begin
                        // do nothing
                    end
                    else if (tmp_scan_data[14] === 1'b1)
                    begin
                        if (tmp_scan_data[15] === 1'b1)
                        begin
                            c_ph_val_tmp[i] = c_ph_val_tmp[i] + 1;
                            if (c_ph_val_tmp[i] > 7)
                                c_ph_val_tmp[i] = 0;
                        end
                        else if (tmp_scan_data[15] === 1'b0)
                        begin
                            c_ph_val_tmp[i] = c_ph_val_tmp[i] - 1;
                            if (c_ph_val_tmp[i] < 0)
                                c_ph_val_tmp[i] = 7;
                        end
                    end
                    tmp_scan_data = tmp_scan_data >> 2;
                end
                // C0-C3 counter moduli
                tmp_scan_data = scan_data;
                for (i = 0; i < 4; i=i+1)
                begin
                    if (tmp_scan_data[26] == 1'b1)
                    begin
                        c_mode_val_tmp[i] = "bypass";
                        if (tmp_scan_data[31] === 1'b1)
                        begin
                            c_mode_val_tmp[i] = "   off";
                            $display("Warning : The specified bit settings will turn OFF the C%0d counter. It cannot be turned on unless the part is re-initialized.", i);
                            $display ("Time: %0t  Instance: %m", $time);
                        end
                    end
                    else if (tmp_scan_data[31] == 1'b1)
                        c_mode_val_tmp[i] = "   odd";
                    else
                        c_mode_val_tmp[i] = "  even";
                    if (tmp_scan_data[25:22] === 4'b0000)
                        c_high_val_tmp[i] = 5'b10000;
                    else
                        c_high_val_tmp[i] = {1'b0, tmp_scan_data[25:22]};
                    if (tmp_scan_data[30:27] === 4'b0000)
                        c_low_val_tmp[i] = 5'b10000;
                    else
                        c_low_val_tmp[i] = {1'b0, tmp_scan_data[30:27]};

                    tmp_scan_data = tmp_scan_data >> 10;
                end
                // M
                error = 0;
                // some temporary storage
                if (scan_data[65:62] == 4'b0000)
                    m_hi = 5'b10000;
                else
                    m_hi = {1'b0, scan_data[65:62]};

                if (scan_data[70:67] == 4'b0000)
                    m_lo = 5'b10000;
                else
                    m_lo = {1'b0, scan_data[70:67]};

                m_val_tmp[0] = m_hi + m_lo;
                if (scan_data[66] === 1'b1)
                begin
                    if (scan_data[71] === 1'b1)
                    begin
                        // this will turn off the M counter : error
                        reconfig_err = 1;
                        error = 1;
                        $display ("The specified bit settings will turn OFF the M counter. This is illegal. Reconfiguration may not work.");
                        $display ("Time: %0t  Instance: %m", $time);
                    end
                    else begin
                        // M counter is being bypassed
                        if (m_mode_val[0] !== "bypass")
                        begin
                            // Mode is switched : give warning
                            d_msg = display_msg(" M", 4);
                        end
                        m_val_tmp[0] = 32'b1;
                        m_mode_val[0] = "bypass";
                    end
                end
                else begin
                    if (m_mode_val[0] === "bypass")
                    begin
                        // Mode is switched : give warning
                        d_msg = display_msg(" M", 1);
                    end
                    m_mode_val[0] = "";
                    if (scan_data[71] === 1'b1)
                    begin
                        // odd : check for duty cycle, if not 50% -- error
                        if (m_hi - m_lo !== 1)
                        begin
                            reconfig_err = 1;
                            $display ("Warning : The M counter of the %s Fast PLL should be configured for 50%% duty cycle only. In this case the HIGH and LOW moduli programmed will result in a duty cycle other than 50%%, which is illegal. Reconfiguration may not work", family_name);
                            $display ("Time: %0t  Instance: %m", $time);
                        end
                    end
                    else begin // even mode
                        if (m_hi !== m_lo)
                        begin
                            reconfig_err = 1;
                            $display ("Warning : The M counter of the %s Fast PLL should be configured for 50%% duty cycle only. In this case the HIGH and LOW moduli programmed will result in a duty cycle other than 50%%, which is illegal. Reconfiguration may not work", family_name);
                            $display ("Time: %0t  Instance: %m", $time);
                        end
                    end
                end

                // N
                error = 0;
                n_val[0] = {1'b0, scan_data[73:72]};
                if (scan_data[74] !== 1'b1)
                begin
                    if (scan_data[73:72] == 2'b01)
                    begin
                        reconfig_err = 1;
                        error = 1;
                        // Cntr value is illegal : give warning
                        d_msg = display_msg(" N", 2);
                    end
                    else if (scan_data[73:72] == 2'b00)
                        n_val[0] = 3'b100;
                    if (error == 1'b0)
                    begin
                        if (n_mode_val[0] === "bypass")
                        begin
                            // Mode is switched : give warning
                            d_msg = display_msg(" N", 1);
                        end
                        n_mode_val[0] = "";
                    end
                end
                else if (scan_data[74] == 1'b1)     // bypass
                begin
                    if (scan_data[72] !== 1'b0)
                    begin
                        reconfig_err = 1;
                        error = 1;
                        // Cntr value is illegal : give warning
                        d_msg = display_msg(" N", 3);
                    end
                    else begin
                        if (n_mode_val[0] != "bypass")
                        begin
                            // Mode is switched : give warning
                            d_msg = display_msg(" N", 4);
                        end
                        n_val[0] = 2'b01;
                        n_mode_val[0] = "bypass";
                    end
                end
            end
            else begin      // pll type is auto or enhanced
                for (i = 0; i < 6; i=i+1)
                begin
                    if (tmp_scan_data[124] == 1'b1)
                    begin
                        c_mode_val_tmp[i] = "bypass";
                        if (tmp_scan_data[133] === 1'b1)
                        begin
                            c_mode_val_tmp[i] = "   off";
                            $display("Warning : The specified bit settings will turn OFF the C%0d counter. It cannot be turned on unless the part is re-initialized.", i);
                            $display ("Time: %0t  Instance: %m", $time);
                        end
                    end
                    else if (tmp_scan_data[133] == 1'b1)
                        c_mode_val_tmp[i] = "   odd";
                    else
                        c_mode_val_tmp[i] = "  even";
                    if (tmp_scan_data[123:116] === 8'b00000000)
                        c_high_val_tmp[i] = 9'b100000000;
                    else
                        c_high_val_tmp[i] = {1'b0, tmp_scan_data[123:116]};
                    if (tmp_scan_data[132:125] === 8'b00000000)
                        c_low_val_tmp[i] = 9'b100000000;
                    else
                        c_low_val_tmp[i] = {1'b0, tmp_scan_data[132:125]};

                    tmp_scan_data = tmp_scan_data << 18;
                end

                // the phase_taps
                tmp_scan_data = scan_data;
                for (i = 0; i < 6; i=i+1)
                begin
                    if (tmp_scan_data[14] == 1'b0)
                    begin
                        // do nothing
                    end
                    else if (tmp_scan_data[14] === 1'b1)
                    begin
                        if (tmp_scan_data[15] === 1'b1)
                        begin
                            c_ph_val_tmp[i] = c_ph_val_tmp[i] + 1;
                            if (c_ph_val_tmp[i] > 7)
                                c_ph_val_tmp[i] = 0;
                        end
                        else if (tmp_scan_data[15] === 1'b0)
                        begin
                            c_ph_val_tmp[i] = c_ph_val_tmp[i] - 1;
                            if (c_ph_val_tmp[i] < 0)
                                c_ph_val_tmp[i] = 7;
                        end
                    end
                    tmp_scan_data = tmp_scan_data >> 2;
                end
                ext_fbk_cntr_high = c_high_val[ext_fbk_cntr_index];
                ext_fbk_cntr_low = c_low_val[ext_fbk_cntr_index];
                ext_fbk_cntr_ph = c_ph_val[ext_fbk_cntr_index];
                ext_fbk_cntr_mode = c_mode_val[ext_fbk_cntr_index];

                // cntrs M/M2
                tmp_scan_data = scan_data;
                for (i=0; i<2; i=i+1)
                begin
                    if (i == 0 || (i == 1 && ss > 0))
                    begin
                        error = 0;
                        m_val_tmp[i] = {1'b0, tmp_scan_data[142:134]};
                        if (tmp_scan_data[143] !== 1'b1)
                        begin
                            if (tmp_scan_data[142:134] == 9'b000000001)
                            begin
                                reconfig_err = 1;
                                error = 1;
                                // Cntr value is illegal : give warning
                                if (i == 0)
                                    d_msg = display_msg(" M", 2);
                                else
                                    d_msg = display_msg("M2", 2);
                            end
                            else if (tmp_scan_data[142:134] == 9'b000000000)
                                m_val_tmp[i] = 10'b1000000000;
                            if (error == 1'b0)
                            begin
                                if (m_mode_val[i] === "bypass")
                                begin
                                    // Mode is switched : give warning
                                    if (i == 0)
                                        d_msg = display_msg(" M", 1);
                                    else
                                        d_msg = display_msg("M2", 1);
                                end
                                m_mode_val[i] = "";
                            end
                        end
                        else if (tmp_scan_data[143] == 1'b1)
                        begin
                            if (tmp_scan_data[134] !== 1'b0)
                            begin
                                reconfig_err = 1;
                                error = 1;
                                // Cntr value is illegal : give warning
                                if (i == 0)
                                    d_msg = display_msg(" M", 3);
                                else
                                    d_msg = display_msg("M2", 3);
                            end
                            else begin
                                if (m_mode_val[i] !== "bypass")
                                begin
                                    // Mode is switched: give warning
                                    if (i == 0)
                                        d_msg = display_msg(" M", 4);
                                    else
                                        d_msg = display_msg("M2", 4);
                                end
                                m_val_tmp[i] = 10'b0000000001;
                                m_mode_val[i] = "bypass";
                            end
                        end
                    end
                    tmp_scan_data = tmp_scan_data >> 10;
                end
                if (ss > 0)
                begin
                    if (m_mode_val[0] != m_mode_val[1])
                    begin
                        reconfig_err = 1;
                        error = 1;
                        $display ("Warning : Incompatible modes for M/M2 counters. Either both should be BYASSED or both NON-BYPASSED. Reconfiguration may not work.");
                        $display ("Time: %0t  Instance: %m", $time);
                    end
                end

                // cntrs N/N2
                tmp_scan_data = scan_data;
                for (i=0; i<2; i=i+1)
                begin
                    if (i == 0 || (i == 1 && ss > 0))
                    begin
                        error = 0;
                        n_val[i] = 0;
                        n_val[i] = {1'b0, tmp_scan_data[162:154]};
                        if (tmp_scan_data[163] !== 1'b1)
                        begin
                            if (tmp_scan_data[162:154] == 9'b000000001)
                            begin
                                reconfig_err = 1;
                                error = 1;
                                // Cntr value is illegal : give warning
                                if (i == 0)
                                    d_msg = display_msg(" N", 2);
                                else
                                    d_msg = display_msg("N2", 2);
                            end
                            else if (tmp_scan_data[162:154] == 9'b000000000)
                                n_val[i] = 10'b1000000000;
                            if (error == 1'b0)
                            begin
                                if (n_mode_val[i] === "bypass")
                                begin
                                    // Mode is switched : give warning
                                    if (i == 0)
                                        d_msg = display_msg(" N", 1);
                                    else
                                        d_msg = display_msg("N2", 1);
                                end
                                n_mode_val[i] = "";
                            end
                        end
                        else if (tmp_scan_data[163] == 1'b1)     // bypass
                        begin
                            if (tmp_scan_data[154] !== 1'b0)
                            begin
                                reconfig_err = 1;
                                error = 1;
                                // Cntr value is illegal : give warning
                                if (i == 0)
                                    d_msg = display_msg(" N", 3);
                                else
                                    d_msg = display_msg("N2", 3);
                            end
                            else begin
                                if (n_mode_val[i] != "bypass")
                                begin
                                    // Mode is switched : give warning
                                    if (i == 0)
                                        d_msg = display_msg(" N", 4);
                                    else
                                        d_msg = display_msg("N2", 4);
                                end
                                n_val[i] = 10'b0000000001;
                                n_mode_val[i] = "bypass";
                            end
                        end
                    end
                    tmp_scan_data = tmp_scan_data >> 10;
                end
                if (ss > 0)
                begin
                    if (n_mode_val[0] != n_mode_val[1])
                    begin
                        reconfig_err = 1;
                        error = 1;
                        $display ("Warning : Incompatible modes for N/N2 counters. Either both should be BYASSED or both NON-BYPASSED. Reconfiguration may not work.");
                        $display ("Time: %0t  Instance: %m", $time);
                    end
                end
            end

            slowest_clk_old = slowest_clk  ( c_high_val[0]+c_low_val[0], c_mode_val[0],
                                        c_high_val[1]+c_low_val[1], c_mode_val[1],
                                        c_high_val[2]+c_low_val[2], c_mode_val[2],
                                        c_high_val[3]+c_low_val[3], c_mode_val[3],
                                        c_high_val[4]+c_low_val[4], c_mode_val[4],
                                        c_high_val[5]+c_low_val[5], c_mode_val[5],
                                        refclk_period, m_val[0]);

            slowest_clk_new = slowest_clk  ( c_high_val_tmp[0]+c_low_val_tmp[0], c_mode_val_tmp[0],
                                        c_high_val_tmp[1]+c_low_val_tmp[1], c_mode_val_tmp[1],
                                        c_high_val_tmp[2]+c_low_val_tmp[2], c_mode_val_tmp[2],
                                        c_high_val_tmp[3]+c_low_val_tmp[3], c_mode_val_tmp[3],
                                        c_high_val_tmp[4]+c_low_val_tmp[4], c_mode_val_tmp[4],
                                        c_high_val_tmp[5]+c_low_val_tmp[5], c_mode_val_tmp[5],
                                        refclk_period, m_val_tmp[0]);

            quiet_time = (slowest_clk_new > slowest_clk_old) ? slowest_clk_new : slowest_clk_old;

            // get quiet time in terms of scanclk cycles
            my_rem = quiet_time % scanclk_period;
            scanclk_cycles = quiet_time/scanclk_period;
            if (my_rem != 0)
                scanclk_cycles = scanclk_cycles + 1;

            scandone_tmp <= #((scanclk_cycles+0.5) * scanclk_period) 1'b1;
        end

        scanwrite_last_value = scanwrite_enabled;
    end

    always @(schedule_vco or areset_ipd or ena_pll)
    begin
        sched_time = 0;

        for (i = 0; i <= 7; i=i+1)
            last_phase_shift[i] = phase_shift[i];

        cycle_to_adjust = 0;
        l_index = 1;
        m_times_vco_period = new_m_times_vco_period;

        // give appropriate messages
        // if areset was asserted
        if (areset_ipd === 1'b1 && areset_ipd_last_value !== areset_ipd)
        begin
            $display (" Note : %s PLL was reset", family_name);
            $display ("Time: %0t  Instance: %m", $time);
            // reset lock parameters
            locked_tmp = 0;
            pll_is_locked = 0;
            pll_about_to_lock = 0;
            cycles_to_lock = 0;
            cycles_to_unlock = 0;
            pll_is_in_reset = 1;
            tap0_is_active = 0;
            for (x = 0; x <= 7; x=x+1)
                vco_tap[x] <= 1'b0;
        end

        // areset deasserted : note time
        // note it as refclk_time to prevent false triggering
        // of stop_vco after areset
        if (areset_ipd === 1'b0 && areset_ipd_last_value === 1'b1 && pll_is_in_reset === 1'b1)
        begin
            refclk_time = $time;
            pll_is_in_reset = 0;
            if ((ena_pll === 1'b1) && (stop_vco !== 1'b1) && (next_vco_sched_time <= $time))
                schedule_vco = ~ schedule_vco;
        end

        // if ena was deasserted
        if (ena_pll == 1'b0 && ena_ipd_last_value !== ena_pll)
        begin
            $display (" Note : %s PLL is disabled", family_name);
            $display ("Time: %0t  Instance: %m", $time);
            pll_is_disabled = 1;
            tap0_is_active = 0;
            for (x = 0; x <= 7; x=x+1)
                vco_tap[x] <= 1'b0;
        end

        if (ena_pll == 1'b1 && ena_ipd_last_value !== ena_pll)
        begin
            $display (" Note : %s PLL is enabled", family_name);
            $display ("Time: %0t  Instance: %m", $time);
            pll_is_disabled = 0;
            if ((areset_ipd !== 1'b1) && (stop_vco !== 1'b1) && (next_vco_sched_time < $time))
                schedule_vco = ~ schedule_vco;
        end

        // illegal value on areset_ipd
        if (areset_ipd === 1'b0 /* converted x or z to 1'b0 */ && (areset_ipd_last_value === 1'b0 || areset_ipd_last_value === 1'b1))
        begin
            $display("Warning : Illegal value 'X' detected on ARESET input");
            $display ("Time: %0t  Instance: %m", $time);
        end

        if (areset_ipd == 1'b1 || ena_pll == 1'b0 || stop_vco == 1'b1)
        begin

            // reset lock parameters
            locked_tmp = 0;
            pll_is_locked = 0;
            pll_about_to_lock = 0;
            cycles_to_lock = 0;
            cycles_to_unlock = 0;

            got_first_refclk = 0;
            got_second_refclk = 0;
            refclk_time = 0;
            got_first_fbclk = 0;
            fbclk_time = 0;
            first_fbclk_time = 0;
            fbclk_period = 0;

            vco_period_was_phase_adjusted = 0;
            phase_adjust_was_scheduled = 0;
        end

        if ( ($time == 0 && first_schedule == 1'b1) || (schedule_vco !== schedule_vco_last_value && (stop_vco !== 1'b1) && (ena_pll === 1'b1) && (areset_ipd !== 1'b1)) )
        begin
            // calculate loop_xplier : this will be different from m_val in ext. fbk mode
            loop_xplier = m_val[0];
            loop_initial = i_m_initial - 1;
            loop_ph = m_ph_val;

            if (op_mode == 1)
            begin
                if (ext_fbk_cntr_mode == "bypass")
                    ext_fbk_cntr_modulus = 1;
                else
                    ext_fbk_cntr_modulus = ext_fbk_cntr_high + ext_fbk_cntr_low;

                loop_xplier = m_val[0] * (ext_fbk_cntr_modulus);
                loop_ph = ext_fbk_cntr_ph;
                loop_initial = ext_fbk_cntr_initial - 1 + ((i_m_initial - 1) * ext_fbk_cntr_modulus);
            end

            // convert initial value to delay
            initial_delay = (loop_initial * m_times_vco_period)/loop_xplier;

            // convert loop ph_tap to delay
            rem = m_times_vco_period % loop_xplier;
            vco_per = m_times_vco_period/loop_xplier;
            if (rem != 0)
                vco_per = vco_per + 1;
            fbk_phase = (loop_ph * vco_per)/8;

            if (op_mode == 1)
            begin
                pull_back_M = (i_m_initial - 1) * (ext_fbk_cntr_modulus) * (m_times_vco_period/loop_xplier);

                while (pull_back_M > refclk_period)
                    pull_back_M = pull_back_M - refclk_period;
            end
            else begin
                pull_back_M = initial_delay + fbk_phase;
            end

            total_pull_back = pull_back_M;
            if (l_simulation_type == "timing")
                total_pull_back = total_pull_back + pll_compensation_delay;

            while (total_pull_back > refclk_period)
                total_pull_back = total_pull_back - refclk_period;

            if (total_pull_back > 0)
                offset = refclk_period - total_pull_back;
            else
                offset = 0;

            if (op_mode == 1)
            begin
                fbk_delay = pull_back_M;
                if (l_simulation_type == "timing")
                    fbk_delay = fbk_delay + pll_compensation_delay;
            end
            else begin
                fbk_delay = total_pull_back - fbk_phase;
                if (fbk_delay < 0)
                begin
                    offset = offset - fbk_phase;
                    fbk_delay = total_pull_back;
                end
            end

            // assign m_delay
            m_delay = fbk_delay;

            for (i = 1; i <= loop_xplier; i=i+1)
            begin
                // adjust cycles
                tmp_vco_per = m_times_vco_period/loop_xplier;
                if (rem != 0 && l_index <= rem)
                begin
                    tmp_rem = (loop_xplier * l_index) % rem;
                    cycle_to_adjust = (loop_xplier * l_index) / rem;
                    if (tmp_rem != 0)
                        cycle_to_adjust = cycle_to_adjust + 1;
                end
                if (cycle_to_adjust == i)
                begin
                    tmp_vco_per = tmp_vco_per + 1;
                    l_index = l_index + 1;
                end

                // calculate high and low periods
                high_time = tmp_vco_per/2;
                if (tmp_vco_per % 2 != 0)
                    high_time = high_time + 1;
                low_time = tmp_vco_per - high_time;

                // schedule the rising and falling egdes
                for (j=0; j<=1; j=j+1)
                begin
                    vco_val = ~vco_val;
                    if (vco_val == 1'b0)
                        sched_time = sched_time + high_time;
                    else
                        sched_time = sched_time + low_time;

                    // schedule tap 0
                    vco_out[0] <= #(sched_time) vco_val;

                end
            end
            if (first_schedule)
            begin
                vco_val = ~vco_val;
                if (vco_val == 1'b0)
                    sched_time = sched_time + high_time;
                else
                    sched_time = sched_time + low_time;
                // schedule tap 0
                vco_out[0] <= #(sched_time) vco_val;
                first_schedule = 0;
            end

            schedule_vco <= #(sched_time) ~schedule_vco;
            next_vco_sched_time = $time + sched_time;

            if (vco_period_was_phase_adjusted)
            begin
                m_times_vco_period = refclk_period;
                new_m_times_vco_period = refclk_period;
                vco_period_was_phase_adjusted = 0;
                phase_adjust_was_scheduled = 1;

                tmp_vco_per = m_times_vco_period/loop_xplier;
                for (k = 0; k <= 7; k=k+1)
                    phase_shift[k] = (k*tmp_vco_per)/8;
            end
        end

        areset_ipd_last_value = areset_ipd;
        ena_ipd_last_value = ena_pll;
        schedule_vco_last_value = schedule_vco;

    end

    always @(pfdena_ipd)
    begin
        if (pfdena_ipd === 1'b0)
        begin
            if (pll_is_locked)
                locked_tmp = 1'b0 /* converted x or z to 1'b0 */;
            pll_is_locked = 0;
            cycles_to_lock = 0;
            $display (" Note : %s PFDENA was deasserted", family_name);
            $display ("Time: %0t  Instance: %m", $time);
        end
        else if (pfdena_ipd === 1'b1 && pfdena_ipd_last_value === 1'b0)
        begin
            // PFD was disabled, now enabled again
            got_first_refclk = 0;
            got_second_refclk = 0;
            refclk_time = $time;
        end
        pfdena_ipd_last_value = pfdena_ipd;
    end

    always @(negedge refclk or negedge fbclk)
    begin
        refclk_last_value = refclk;
        fbclk_last_value = fbclk;
    end

    always @(posedge refclk or posedge fbclk)
    begin
        if (refclk == 1'b1 && refclk_last_value !== refclk && areset_ipd === 1'b0)
        begin
            if (! got_first_refclk)
            begin
                got_first_refclk = 1;
            end else
            begin
                got_second_refclk = 1;
                refclk_period = $time - refclk_time;

                // check if incoming freq. will cause VCO range to be
                // exceeded
                if ((vco_max != 0 && vco_min != 0) && (pfdena_ipd === 1'b1) &&
                    ((refclk_period/loop_xplier > vco_max) ||
                    (refclk_period/loop_xplier < vco_min)) )
                begin
                    if (pll_is_locked == 1'b1)
                    begin
                        $display ("Warning : Input clock freq. is not within VCO range. PLL may lose lock");
                        $display ("Time: %0t  Instance: %m", $time);
                        if (inclk_out_of_range === 1'b1)
                        begin
                            // unlock
                            pll_is_locked = 0;
                            locked_tmp = 0;
                            pll_about_to_lock = 0;
                            cycles_to_lock = 0;
                            $display ("Note : %s PLL lost lock", family_name);
                            $display ("Time: %0t  Instance: %m", $time);
                            vco_period_was_phase_adjusted = 0;
                            phase_adjust_was_scheduled = 0;
                        end
                    end
                    else begin
                        if (no_warn == 1'b0)
                        begin
                            $display ("Warning : Input clock freq. is not within VCO range. PLL may not lock");
                            $display ("Time: %0t  Instance: %m", $time);
                            no_warn = 1'b1;
                        end
                    end
                    inclk_out_of_range = 1;
                end
                else begin
                    inclk_out_of_range = 0;
                end

            end
            if (stop_vco == 1'b1)
            begin
                stop_vco = 0;
                schedule_vco = ~schedule_vco;
            end
            refclk_time = $time;
        end

        if (fbclk == 1'b1 && fbclk_last_value !== fbclk)
        begin
            if (scanwrite_enabled === 1'b1)
            begin
                m_val[0] <= m_val_tmp[0];
                m_val[1] <= m_val_tmp[1];
            end
            if (!got_first_fbclk)
            begin
                got_first_fbclk = 1;
                first_fbclk_time = $time;
            end
            else
                fbclk_period = $time - fbclk_time;

            // need refclk_period here, so initialized to proper value above
            if ( ( ($time - refclk_time > 1.5 * refclk_period) && pfdena_ipd === 1'b1 && pll_is_locked === 1'b1) || ( ($time - refclk_time > 5 * refclk_period) && pfdena_ipd === 1'b1) )
            begin
                stop_vco = 1;
                // reset
                got_first_refclk = 0;
                got_first_fbclk = 0;
                got_second_refclk = 0;
                if (pll_is_locked == 1'b1)
                begin
                    pll_is_locked = 0;
                    locked_tmp = 0;
                    $display ("Note : %s PLL lost lock due to loss of input clock", family_name);
                    $display ("Time: %0t  Instance: %m", $time);
                end
                pll_about_to_lock = 0;
                cycles_to_lock = 0;
                cycles_to_unlock = 0;
                first_schedule = 1;
                vco_period_was_phase_adjusted = 0;
                phase_adjust_was_scheduled = 0;
                tap0_is_active = 0;
                for (x = 0; x <= 7; x=x+1)
                    vco_tap[x] <= 1'b0;
            end
            else if (!pll_is_locked && ($time - refclk_time > 2 * refclk_period) && pfdena_ipd === 1'b1)
            begin
                inclk_out_of_range = 1;
            end
            fbclk_time = $time;
        end

        if (got_second_refclk && pfdena_ipd === 1'b1 && (!inclk_out_of_range))
        begin
            // now we know actual incoming period
            if (abs(fbclk_time - refclk_time) <= 5 || (got_first_fbclk && abs(refclk_period - abs(fbclk_time - refclk_time)) <= 5))
            begin
                // considered in phase
                if (cycles_to_lock == valid_lock_multiplier - 1)
                    pll_about_to_lock <= 1;
                if (cycles_to_lock == valid_lock_multiplier)
                begin
                    if (pll_is_locked === 1'b0)
                    begin
                        $display (" Note : %s PLL locked to incoming clock", family_name);
                        $display ("Time: %0t  Instance: %m", $time);
                    end
                    pll_is_locked = 1;
                    locked_tmp = 1;
                    cycles_to_unlock = 0;
                end
                // increment lock counter only if the second part of the above
                // time check is not true
                if (!(abs(refclk_period - abs(fbclk_time - refclk_time)) <= 5))
                begin
                    cycles_to_lock = cycles_to_lock + 1;
                end

                // adjust m_times_vco_period
                new_m_times_vco_period = refclk_period;

            end else
            begin
                // if locked, begin unlock
                if (pll_is_locked)
                begin
                    cycles_to_unlock = cycles_to_unlock + 1;
                    if (cycles_to_unlock == invalid_lock_multiplier)
                    begin
                        pll_is_locked = 0;
                        locked_tmp = 0;
                        pll_about_to_lock = 0;
                        cycles_to_lock = 0;
                        $display ("Note : %s PLL lost lock", family_name);
                        $display ("Time: %0t  Instance: %m", $time);
                        vco_period_was_phase_adjusted = 0;
                        phase_adjust_was_scheduled = 0;
                    end
                end
                if (abs(refclk_period - fbclk_period) <= 2)
                begin
                    // frequency is still good
                    if ($time == fbclk_time && (!phase_adjust_was_scheduled))
                    begin
                        if (abs(fbclk_time - refclk_time) > refclk_period/2)
                        begin
                            new_m_times_vco_period = m_times_vco_period + (refclk_period - abs(fbclk_time - refclk_time));
                            vco_period_was_phase_adjusted = 1;
                        end else
                        begin
                            new_m_times_vco_period = m_times_vco_period - abs(fbclk_time - refclk_time);
                            vco_period_was_phase_adjusted = 1;
                        end
                    end
                end else
                begin
                    new_m_times_vco_period = refclk_period;
                    phase_adjust_was_scheduled = 0;
                end
            end
        end

        if (reconfig_err == 1'b1)
        begin
            locked_tmp = 0;
        end

        refclk_last_value = refclk;
        fbclk_last_value = fbclk;
    end

    assign clk_tmp[0] = i_clk0_counter == "c0" ? c0_clk : i_clk0_counter == "c1" ? c1_clk : i_clk0_counter == "c2" ? c2_clk : i_clk0_counter == "c3" ? c3_clk : i_clk0_counter == "c4" ? c4_clk : i_clk0_counter == "c5" ? c5_clk : 1'b0;
    assign clk_tmp[1] = i_clk1_counter == "c0" ? c0_clk : i_clk1_counter == "c1" ? c1_clk : i_clk1_counter == "c2" ? c2_clk : i_clk1_counter == "c3" ? c3_clk : i_clk1_counter == "c4" ? c4_clk : i_clk1_counter == "c5" ? c5_clk : 1'b0;
    assign clk_tmp[2] = i_clk2_counter == "c0" ? c0_clk : i_clk2_counter == "c1" ? c1_clk : i_clk2_counter == "c2" ? c2_clk : i_clk2_counter == "c3" ? c3_clk : i_clk2_counter == "c4" ? c4_clk : i_clk2_counter == "c5" ? c5_clk : 1'b0;
    assign clk_tmp[3] = i_clk3_counter == "c0" ? c0_clk : i_clk3_counter == "c1" ? c1_clk : i_clk3_counter == "c2" ? c2_clk : i_clk3_counter == "c3" ? c3_clk : i_clk3_counter == "c4" ? c4_clk : i_clk3_counter == "c5" ? c5_clk : 1'b0;
    assign clk_tmp[4] = i_clk4_counter == "c0" ? c0_clk : i_clk4_counter == "c1" ? c1_clk : i_clk4_counter == "c2" ? c2_clk : i_clk4_counter == "c3" ? c3_clk : i_clk4_counter == "c4" ? c4_clk : i_clk4_counter == "c5" ? c5_clk : 1'b0;
    assign clk_tmp[5] = i_clk5_counter == "c0" ? c0_clk : i_clk5_counter == "c1" ? c1_clk : i_clk5_counter == "c2" ? c2_clk : i_clk5_counter == "c3" ? c3_clk : i_clk5_counter == "c4" ? c4_clk : i_clk5_counter == "c5" ? c5_clk : 1'b0;

    assign clk_out[0] = (areset_ipd === 1'b1 || ena_pll === 1'b0 || pll_in_test_mode === 1'b1) || (pll_about_to_lock == 1'b1 && !reconfig_err) ? clk_tmp[0] : 1'b0 /* converted x or z to 1'b0 */;
    assign clk_out[1] = (areset_ipd === 1'b1 || ena_pll === 1'b0 || pll_in_test_mode === 1'b1) || (pll_about_to_lock == 1'b1 && !reconfig_err) ? clk_tmp[1] : 1'b0 /* converted x or z to 1'b0 */;
    assign clk_out[2] = (areset_ipd === 1'b1 || ena_pll === 1'b0 || pll_in_test_mode === 1'b1) || (pll_about_to_lock == 1'b1 && !reconfig_err) ? clk_tmp[2] : 1'b0 /* converted x or z to 1'b0 */;
    assign clk_out[3] = (areset_ipd === 1'b1 || ena_pll === 1'b0 || pll_in_test_mode === 1'b1) || (pll_about_to_lock == 1'b1 && !reconfig_err) ? clk_tmp[3] : 1'b0 /* converted x or z to 1'b0 */;
    assign clk_out[4] = (areset_ipd === 1'b1 || ena_pll === 1'b0 || pll_in_test_mode === 1'b1) || (pll_about_to_lock == 1'b1 && !reconfig_err) ? clk_tmp[4] : 1'b0 /* converted x or z to 1'b0 */;
    assign clk_out[5] = (areset_ipd === 1'b1 || ena_pll === 1'b0 || pll_in_test_mode === 1'b1) || (pll_about_to_lock == 1'b1 && !reconfig_err) ? clk_tmp[5] : 1'b0 /* converted x or z to 1'b0 */;

    assign sclkout0 = (areset_ipd === 1'b1 || ena_pll === 1'b0 || pll_in_test_mode == 1'b1) || (pll_about_to_lock == 1'b1 && !reconfig_err) ? sclkout0_tmp : 1'b0 /* converted x or z to 1'b0 */;

    assign sclkout1 = (areset_ipd === 1'b1 || ena_pll === 1'b0 || pll_in_test_mode == 1'b1) || (pll_about_to_lock == 1'b1 && !reconfig_err) ? sclkout1_tmp : 1'b0 /* converted x or z to 1'b0 */;

    assign enable_0 = (areset_ipd === 1'b1 || ena_pll === 1'b0 || pll_in_test_mode == 1'b1) || pll_about_to_lock == 1'b1 ? enable0_tmp : 1'b0 /* converted x or z to 1'b0 */;
    assign enable_1 = (areset_ipd === 1'b1 || ena_pll === 1'b0 || pll_in_test_mode == 1'b1) || pll_about_to_lock == 1'b1 ? enable1_tmp : 1'b0 /* converted x or z to 1'b0 */;


    // ACCELERATE OUTPUTS
    and (clk[0], 1'b1, clk_out[0]);
    and (clk[1], 1'b1, clk_out[1]);
    and (clk[2], 1'b1, clk_out[2]);
    and (clk[3], 1'b1, clk_out[3]);
    and (clk[4], 1'b1, clk_out[4]);
    and (clk[5], 1'b1, clk_out[5]);

    and (sclkout[0], 1'b1, sclkout0);
    and (sclkout[1], 1'b1, sclkout1);

    and (enable0, 1'b1, enable_0);
    and (enable1, 1'b1, enable_1);

    and (scandataout, 1'b1, scandataout_tmp);
    and (scandone, 1'b1, scandone_tmp);

endmodule // MF_stratixii_pll

