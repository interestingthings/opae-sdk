// Created by altera_lib_mf.pl from altera_mf.v


//////////////////////////////////////////////////////////////////////////////
//
// Module Name : MF_stratixiii_pll
//
// Description : Behavioral model for StratixIII pll.
//
// Limitations : Does not support Spread Spectrum and Bandwidth.
//
// Outputs     : Up to 10 output clocks, each defined by its own set of
//               parameters. Locked output (active high) indicates when the
//               PLL locks. clkbad and activeclock are used for
//               clock switchover to indicate which input clock has gone
//               bad, when the clock switchover initiates and which input
//               clock is being used as the reference, respectively.
//               scandataout is the data output of the serial scan chain.
//
// New Features : The list below outlines key new features in Stratix III:
//                1. Dynamic Phase Reconfiguration
//                2. Dynamic PLL Reconfiguration (different protocol)
//                3. More output counters
//////////////////////////////////////////////////////////////////////////////

`timescale 1 ps/1 ps
`define STXIII_PLL_WORD_LENGTH 18

/*verilator lint_off CASEX*/
/*verilator lint_off COMBDLY*/
/*verilator lint_off INITIALDLY*/
/*verilator lint_off LITENDIAN*/
/*verilator lint_off MULTIDRIVEN*/
/*verilator lint_off UNOPTFLAT*/
/*verilator lint_off BLKANDNBLK*/
module MF_stratixiii_pll (inclk,
                    fbin,
                    fbout,
                    clkswitch,
                    areset,
                    pfdena,
                    scanclk,
                    scandata,
                    scanclkena,
                    configupdate,
                    clk,
                    phasecounterselect,
                    phaseupdown,
                    phasestep,
                    clkbad,
                    activeclock,
                    locked,
                    scandataout,
                    scandone,
                    phasedone,
                    vcooverrange,
                    vcounderrange
                    );

    parameter operation_mode                       = "normal";
    parameter pll_type                             = "auto"; // auto,fast(left_right),enhanced(top_bottom)
    parameter compensate_clock                     = "clock0";


    parameter inclk0_input_frequency               = 0;
    parameter inclk1_input_frequency               = 0;

    parameter self_reset_on_loss_lock        = "off";
    parameter switch_over_type                     = "auto";

    parameter switch_over_counter                  = 1;
    parameter enable_switch_over_counter           = "off";
    parameter dpa_multiply_by = 0;
    parameter dpa_divide_by = 0;
    parameter dpa_divider = 0;       // 0, 1, 2, 4

    parameter bandwidth                            = 0;
    parameter bandwidth_type                       = "auto";
    parameter use_dc_coupling                      = "false";

    parameter lock_high = 0; // 0 .. 4095
    parameter lock_low = 0;  // 0 .. 7
    parameter lock_window_ui = "0.05"; // "0.05", "0.1", "0.15", "0.2"
    parameter test_bypass_lock_detect              = "off";

    parameter clk0_output_frequency                = 0;
    parameter clk0_multiply_by                     = 0;
    parameter clk0_divide_by                       = 0;
    parameter clk0_phase_shift                     = "0";
    parameter clk0_duty_cycle                      = 50;

    parameter clk1_output_frequency                = 0;
    parameter clk1_multiply_by                     = 0;
    parameter clk1_divide_by                       = 0;
    parameter clk1_phase_shift                     = "0";
    parameter clk1_duty_cycle                      = 50;

    parameter clk2_output_frequency                = 0;
    parameter clk2_multiply_by                     = 0;
    parameter clk2_divide_by                       = 0;
    parameter clk2_phase_shift                     = "0";
    parameter clk2_duty_cycle                      = 50;

    parameter clk3_output_frequency                = 0;
    parameter clk3_multiply_by                     = 0;
    parameter clk3_divide_by                       = 0;
    parameter clk3_phase_shift                     = "0";
    parameter clk3_duty_cycle                      = 50;

    parameter clk4_output_frequency                = 0;
    parameter clk4_multiply_by                     = 0;
    parameter clk4_divide_by                       = 0;
    parameter clk4_phase_shift                     = "0";
    parameter clk4_duty_cycle                      = 50;

    parameter clk5_output_frequency                = 0;
    parameter clk5_multiply_by                     = 0;
    parameter clk5_divide_by                       = 0;
    parameter clk5_phase_shift                     = "0";
    parameter clk5_duty_cycle                      = 50;

    parameter clk6_output_frequency                = 0;
    parameter clk6_multiply_by                     = 0;
    parameter clk6_divide_by                       = 0;
    parameter clk6_phase_shift                     = "0";
    parameter clk6_duty_cycle                      = 50;

    parameter clk7_output_frequency                = 0;
    parameter clk7_multiply_by                     = 0;
    parameter clk7_divide_by                       = 0;
    parameter clk7_phase_shift                     = "0";
    parameter clk7_duty_cycle                      = 50;

    parameter clk8_output_frequency                = 0;
    parameter clk8_multiply_by                     = 0;
    parameter clk8_divide_by                       = 0;
    parameter clk8_phase_shift                     = "0";
    parameter clk8_duty_cycle                      = 50;

    parameter clk9_output_frequency                = 0;
    parameter clk9_multiply_by                     = 0;
    parameter clk9_divide_by                       = 0;
    parameter clk9_phase_shift                     = "0";
    parameter clk9_duty_cycle                      = 50;


    parameter pfd_min                              = 0;
    parameter pfd_max                              = 0;
    parameter vco_min                              = 0;
    parameter vco_max                              = 0;
    parameter vco_center                           = 0;

    // ADVANCED USE PARAMETERS
    parameter m_initial = 1;
    parameter m = 0;
    parameter n = 1;

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

    parameter c6_high = 1;
    parameter c6_low = 1;
    parameter c6_initial = 1;
    parameter c6_mode = "bypass";
    parameter c6_ph = 0;

    parameter c7_high = 1;
    parameter c7_low = 1;
    parameter c7_initial = 1;
    parameter c7_mode = "bypass";
    parameter c7_ph = 0;

    parameter c8_high = 1;
    parameter c8_low = 1;
    parameter c8_initial = 1;
    parameter c8_mode = "bypass";
    parameter c8_ph = 0;

    parameter c9_high = 1;
    parameter c9_low = 1;
    parameter c9_initial = 1;
    parameter c9_mode = "bypass";
    parameter c9_ph = 0;


    parameter m_ph = 0;

    parameter clk0_counter = "unused";
    parameter clk1_counter = "unused";
    parameter clk2_counter = "unused";
    parameter clk3_counter = "unused";
    parameter clk4_counter = "unused";
    parameter clk5_counter = "unused";
    parameter clk6_counter = "unused";
    parameter clk7_counter = "unused";
    parameter clk8_counter = "unused";
    parameter clk9_counter = "unused";

    parameter c1_use_casc_in = "off";
    parameter c2_use_casc_in = "off";
    parameter c3_use_casc_in = "off";
    parameter c4_use_casc_in = "off";
    parameter c5_use_casc_in = "off";
    parameter c6_use_casc_in = "off";
    parameter c7_use_casc_in = "off";
    parameter c8_use_casc_in = "off";
    parameter c9_use_casc_in = "off";

    parameter m_test_source  = -1;
    parameter c0_test_source = -1;
    parameter c1_test_source = -1;
    parameter c2_test_source = -1;
    parameter c3_test_source = -1;
    parameter c4_test_source = -1;
    parameter c5_test_source = -1;
    parameter c6_test_source = -1;
    parameter c7_test_source = -1;
    parameter c8_test_source = -1;
    parameter c9_test_source = -1;

    parameter vco_multiply_by = 0;
    parameter vco_divide_by = 0;
    parameter vco_post_scale = 1; // 1 .. 2
    parameter vco_frequency_control = "auto";
    parameter vco_phase_shift_step = 0;

    parameter charge_pump_current = 10;
    parameter loop_filter_r = "1.0";    // "1.0", "2.0", "4.0", "6.0", "8.0", "12.0", "16.0", "20.0"
    parameter loop_filter_c = 0;        // 0 , 2 , 4

    parameter pll_compensation_delay = 0;
    parameter simulation_type = "functional";

// SIMULATION_ONLY_PARAMETERS_BEGIN

    parameter down_spread                          = "0.0";
    parameter lock_c = 4;

    parameter sim_gate_lock_device_behavior        = "off";

    parameter clk0_phase_shift_num = 0;
    parameter clk1_phase_shift_num = 0;
    parameter clk2_phase_shift_num = 0;
    parameter clk3_phase_shift_num = 0;
    parameter clk4_phase_shift_num = 0;
    parameter family_name = "StratixIII";

    parameter clk0_use_even_counter_mode = "off";
    parameter clk1_use_even_counter_mode = "off";
    parameter clk2_use_even_counter_mode = "off";
    parameter clk3_use_even_counter_mode = "off";
    parameter clk4_use_even_counter_mode = "off";
    parameter clk5_use_even_counter_mode = "off";
    parameter clk6_use_even_counter_mode = "off";
    parameter clk7_use_even_counter_mode = "off";
    parameter clk8_use_even_counter_mode = "off";
    parameter clk9_use_even_counter_mode = "off";

    parameter clk0_use_even_counter_value = "off";
    parameter clk1_use_even_counter_value = "off";
    parameter clk2_use_even_counter_value = "off";
    parameter clk3_use_even_counter_value = "off";
    parameter clk4_use_even_counter_value = "off";
    parameter clk5_use_even_counter_value = "off";
    parameter clk6_use_even_counter_value = "off";
    parameter clk7_use_even_counter_value = "off";
    parameter clk8_use_even_counter_value = "off";
    parameter clk9_use_even_counter_value = "off";

    // TEST ONLY

    parameter init_block_reset_a_count = 1;
    parameter init_block_reset_b_count = 1;

// SIMULATION_ONLY_PARAMETERS_END

// LOCAL_PARAMETERS_BEGIN

    parameter phase_counter_select_width = 4;
    parameter lock_window = 5;
    parameter inclk0_freq = inclk0_input_frequency;
    parameter inclk1_freq = inclk1_input_frequency;

parameter charge_pump_current_bits = 0;
parameter lock_window_ui_bits = 0;
parameter loop_filter_c_bits = 0;
parameter loop_filter_r_bits = 0;
parameter test_counter_c0_delay_chain_bits = 0;
parameter test_counter_c1_delay_chain_bits = 0;
parameter test_counter_c2_delay_chain_bits = 0;
parameter test_counter_c3_delay_chain_bits = 0;
parameter test_counter_c4_delay_chain_bits = 0;
parameter test_counter_c5_delay_chain_bits = 0;
    parameter test_counter_c6_delay_chain_bits = 0;
    parameter test_counter_c7_delay_chain_bits = 0;
    parameter test_counter_c8_delay_chain_bits = 0;
    parameter test_counter_c9_delay_chain_bits = 0;
parameter test_counter_m_delay_chain_bits = 0;
parameter test_counter_n_delay_chain_bits = 0;
parameter test_feedback_comp_delay_chain_bits = 0;
parameter test_input_comp_delay_chain_bits = 0;
parameter test_volt_reg_output_mode_bits = 0;
parameter test_volt_reg_output_voltage_bits = 0;
parameter test_volt_reg_test_mode = "false";
parameter vco_range_detector_high_bits = -1;
parameter vco_range_detector_low_bits = -1;
parameter scan_chain_mif_file = "";

    parameter test_counter_c3_sclk_delay_chain_bits  = -1;
    parameter test_counter_c4_sclk_delay_chain_bits  = -1;
    parameter test_counter_c5_lden_delay_chain_bits  = -1;
    parameter test_counter_c6_lden_delay_chain_bits  = -1;

parameter auto_settings = "true";

// LOCAL_PARAMETERS_END

    // INPUT PORTS
    input [1:0] inclk;
    input fbin;
    input clkswitch;
    input areset;
    input pfdena;
    input [phase_counter_select_width - 1:0] phasecounterselect;
    input phaseupdown;
    input phasestep;
    input scanclk;
    input scanclkena;
    input scandata;
    input configupdate;

    // OUTPUT PORTS
    output [9:0] clk;
    output [1:0] clkbad;
    output activeclock;
    output locked;
    output scandataout;
    output scandone;
    output fbout;
    output phasedone;
    output vcooverrange;
    output vcounderrange;



    // INTERNAL VARIABLES AND NETS
    reg [8*6:1] clk_num[0:9];
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
    integer loop_xplier;
    integer loop_initial;
    integer loop_ph;
    integer cycle_to_adjust;
    integer total_pull_back;
    integer pull_back_M;

    time    fbclk_time;
    time    first_fbclk_time;
    time    refclk_time;

    reg switch_clock;

    reg [31:0] real_lock_high;

    reg got_first_refclk;
    reg got_second_refclk;
    reg got_first_fbclk;
    reg refclk_last_value;
    reg fbclk_last_value;
    reg inclk_last_value;
    reg pll_is_locked;
    reg locked_tmp;
    reg areset_last_value;
    reg pfdena_last_value;
    reg inclk_out_of_range;
    reg schedule_vco_last_value;

    // Test bypass lock detect
    reg pfd_locked;
    integer cycles_pfd_low, cycles_pfd_high;

    reg gate_out;
    reg vco_val;

    reg [31:0] m_initial_val;
    reg [31:0] m_val[0:1];
    reg [31:0] n_val[0:1];
    reg [31:0] m_delay;
    reg [8*6:1] m_mode_val[0:1];
    reg [8*6:1] n_mode_val[0:1];

    reg [31:0] c_high_val[0:9];
    reg [31:0] c_low_val[0:9];
    reg [8*6:1] c_mode_val[0:9];
    reg [31:0] c_initial_val[0:9];
    integer c_ph_val[0:9];

    reg [31:0] c_val; // placeholder for c_high,c_low values

    // VCO Frequency Range control
    reg vco_over, vco_under;

    // temporary registers for reprogramming
    integer c_ph_val_tmp[0:9];
    reg [31:0] c_high_val_tmp[0:9];
    reg [31:0] c_hval[0:9];
    reg [31:0] c_low_val_tmp[0:9];
    reg [31:0] c_lval[0:9];
    reg [8*6:1] c_mode_val_tmp[0:9];

    // hold registers for reprogramming
    integer c_ph_val_hold[0:9];
    reg [31:0] c_high_val_hold[0:9];
    reg [31:0] c_low_val_hold[0:9];
    reg [8*6:1] c_mode_val_hold[0:9];

    // old values
    reg [31:0] m_val_old[0:1];
    reg [31:0] m_val_tmp[0:1];
    reg [31:0] n_val_old[0:1];
    reg [8*6:1] m_mode_val_old[0:1];
    reg [8*6:1] n_mode_val_old[0:1];
    reg [31:0] c_high_val_old[0:9];
    reg [31:0] c_low_val_old[0:9];
    reg [8*6:1] c_mode_val_old[0:9];
    integer c_ph_val_old[0:9];
    integer   m_ph_val_old;
    integer   m_ph_val_tmp;

    integer cp_curr_old;
    integer cp_curr_val;
    integer lfc_old;
    integer lfc_val;
    integer vco_cur;
    integer vco_old;
    reg [9*8:1] lfr_val;
    reg [9*8:1] lfr_old;
    reg [1:2] lfc_val_bit_setting, lfc_val_old_bit_setting;
    reg vco_val_bit_setting, vco_val_old_bit_setting;
    reg [3:7] lfr_val_bit_setting, lfr_val_old_bit_setting;
    reg [14:16] cp_curr_bit_setting, cp_curr_old_bit_setting;

    // Setting on  - display real values
    // Setting off - display only bits
    reg pll_reconfig_display_full_setting;

    reg [7:0] m_hi;
    reg [7:0] m_lo;
    reg [7:0] n_hi;
    reg [7:0] n_lo;

    // ph tap orig values (POF)
    integer c_ph_val_orig[0:9];
    integer m_ph_val_orig;

    reg schedule_vco;
    reg stop_vco;
    reg inclk_n;
    reg inclk_man;
    reg inclk_es;

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
    wire inclk_c6;
    wire inclk_c7;
    wire inclk_c8;
    wire inclk_c9;

    wire  inclk_c0_from_vco;
    wire  inclk_c1_from_vco;
    wire  inclk_c2_from_vco;
    wire  inclk_c3_from_vco;
    wire  inclk_c4_from_vco;
    wire  inclk_c5_from_vco;
    wire  inclk_c6_from_vco;
    wire  inclk_c7_from_vco;
    wire  inclk_c8_from_vco;
    wire  inclk_c9_from_vco;

    wire  inclk_m_from_vco;

    wire inclk_m;
    wire pfdena_wire;
    wire [9:0] clk_tmp, clk_out_pfd;


    wire [9:0] clk_out;

    wire c0_clk;
    wire c1_clk;
    wire c2_clk;
    wire c3_clk;
    wire c4_clk;
    wire c5_clk;
    wire c6_clk;
    wire c7_clk;
    wire c8_clk;
    wire c9_clk;

    reg first_schedule;

    reg vco_period_was_phase_adjusted;
    reg phase_adjust_was_scheduled;

    wire refclk;
    wire fbclk;

    wire pllena_reg;
    wire test_mode_inclk;

    // Self Reset
    wire reset_self;

    // Clock Switchover
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
    reg got_curr_clk_falling_edge_after_clkswitch;

    integer clk0_count;
    integer clk1_count;
    integer switch_over_count;

    wire scandataout_tmp;
    reg scandata_in, scandata_out; // hold scan data in negative-edge triggered ff (on either side on chain)
    reg scandone_tmp;
    reg initiate_reconfig;
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
    wire update_conf_latches;
    reg  update_conf_latches_reg;
    reg [-1:232] scan_data;
    reg scanclkena_reg; // register scanclkena on negative edge of scanclk
    reg c0_rising_edge_transfer_done;
    reg c1_rising_edge_transfer_done;
    reg c2_rising_edge_transfer_done;
    reg c3_rising_edge_transfer_done;
    reg c4_rising_edge_transfer_done;
    reg c5_rising_edge_transfer_done;
    reg c6_rising_edge_transfer_done;
    reg c7_rising_edge_transfer_done;
    reg c8_rising_edge_transfer_done;
    reg c9_rising_edge_transfer_done;
    reg scanread_setup_violation;
    integer index;
    integer scanclk_cycles;
    reg d_msg;

    integer num_output_cntrs;
    reg no_warn;

    // Phase reconfig

    reg [3:0] phasecounterselect_reg;
    reg phaseupdown_reg;
    reg phasestep_reg;
    integer select_counter;
    integer phasestep_high_count;
    reg update_phase;


// LOCAL_PARAMETERS_BEGIN

    parameter SCAN_CHAIN = 144;
    parameter GPP_SCAN_CHAIN  = 234;
    parameter FAST_SCAN_CHAIN = 180;
    // primary clk is always inclk0
    parameter num_phase_taps = 8;

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
    integer i_clk6_mult_by;
    integer i_clk6_div_by;
    integer i_clk7_mult_by;
    integer i_clk7_div_by;
    integer i_clk8_mult_by;
    integer i_clk8_div_by;
    integer i_clk9_mult_by;
    integer i_clk9_div_by;
    integer max_d_value;
    integer new_multiplier;

    // internal variables for storing the phase shift number.(used in lvds mode only)
    integer i_clk0_phase_shift;
    integer i_clk1_phase_shift;
    integer i_clk2_phase_shift;
    integer i_clk3_phase_shift;
    integer i_clk4_phase_shift;

    // user to advanced internal signals

    integer   i_m_initial;
    integer   i_m;
    integer   i_n;
    integer   i_c_high[0:9];
    integer   i_c_low[0:9];
    integer   i_c_initial[0:9];
    integer   i_c_ph[0:9];
    reg       [8*6:1] i_c_mode[0:9];

    integer   i_vco_min;
    integer   i_vco_max;
    integer   i_vco_min_no_division;
    integer   i_vco_max_no_division;
    integer   i_vco_center;
    integer   i_pfd_min;
    integer   i_pfd_max;
    integer   i_m_ph;
    integer   m_ph_val;
    reg [8*2:1] i_clk9_counter;
    reg [8*2:1] i_clk8_counter;
    reg [8*2:1] i_clk7_counter;
    reg [8*2:1] i_clk6_counter;
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

    reg pll_in_test_mode;
    reg pll_is_in_reset;
    reg pll_has_just_been_reconfigured;

    // uppercase to lowercase parameter values
    reg [8*`STXIII_PLL_WORD_LENGTH:1] l_operation_mode;
    reg [8*`STXIII_PLL_WORD_LENGTH:1] l_pll_type;
    reg [8*`STXIII_PLL_WORD_LENGTH:1] l_compensate_clock;
    reg [8*`STXIII_PLL_WORD_LENGTH:1] l_scan_chain;
    reg [8*`STXIII_PLL_WORD_LENGTH:1] l_switch_over_type;
    reg [8*`STXIII_PLL_WORD_LENGTH:1] l_bandwidth_type;
    reg [8*`STXIII_PLL_WORD_LENGTH:1] l_simulation_type;
    reg [8*`STXIII_PLL_WORD_LENGTH:1] l_sim_gate_lock_device_behavior;
    reg [8*`STXIII_PLL_WORD_LENGTH:1] l_vco_frequency_control;
    reg [8*`STXIII_PLL_WORD_LENGTH:1] l_enable_switch_over_counter;
    reg [8*`STXIII_PLL_WORD_LENGTH:1] l_self_reset_on_loss_lock;



    integer current_clock;
    integer current_clock_man;
    reg is_fast_pll;
    reg ic1_use_casc_in;
    reg ic2_use_casc_in;
    reg ic3_use_casc_in;
    reg ic4_use_casc_in;
    reg ic5_use_casc_in;
    reg ic6_use_casc_in;
    reg ic7_use_casc_in;
    reg ic8_use_casc_in;
    reg ic9_use_casc_in;

    reg init;
    reg tap0_is_active;

    real inclk0_period, last_inclk0_period,inclk1_period, last_inclk1_period;
    real last_inclk0_edge,last_inclk1_edge,diff_percent_period;
    reg first_inclk0_edge_detect,first_inclk1_edge_detect;



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
        num = (numerator == 0) ? 1 : numerator;
        den = (denominator == 0) ? 1 : denominator;
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
                    fraction_num = m_value;
                    fraction_div = d_value;
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
    input C0, C0_mode, C1, C1_mode, C2, C2_mode, C3, C3_mode, C4, C4_mode, C5, C5_mode, C6, C6_mode, C7, C7_mode, C8, C8_mode, C9, C9_mode, refclk, m_mod;
    integer C0, C1, C2, C3, C4, C5, C6, C7, C8, C9;
    reg [8*6:1] C0_mode, C1_mode, C2_mode, C3_mode, C4_mode, C5_mode, C6_mode, C7_mode, C8_mode, C9_mode;
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
        if (C6 > max_modulus && C6_mode != "bypass" && C6_mode != "   off")
            max_modulus = C6;
        if (C7 > max_modulus && C7_mode != "bypass" && C7_mode != "   off")
            max_modulus = C7;
        if (C8 > max_modulus && C8_mode != "bypass" && C8_mode != "   off")
            max_modulus = C8;
        if (C9 > max_modulus && C9_mode != "bypass" && C9_mode != "   off")
            max_modulus = C9;

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

    // find the M and N values for Manual phase based on the following 5 criterias:
    // 1. The PFD frequency (i.e. Fin / N) must be in the range 5 MHz to 720 MHz
    // 2. The VCO frequency (i.e. Fin * M / N) must be in the range 300 MHz to 1300 MHz
    // 3. M is less than 512
    // 4. N is less than 512
    // 5. It's the smallest M/N which satisfies all the above constraints, and is within 2ps
    //    of the desired vco-phase-shift-step
    task find_m_and_n_4_manual_phase;
        input inclock_period;
        input vco_phase_shift_step;
        input clk0_mult, clk1_mult, clk2_mult, clk3_mult, clk4_mult;
        input clk5_mult, clk6_mult, clk7_mult, clk8_mult, clk9_mult;
        input clk0_div,  clk1_div,  clk2_div,  clk3_div,  clk4_div;
        input clk5_div,  clk6_div,  clk7_div,  clk8_div,  clk9_div;
        input clk0_used,  clk1_used,  clk2_used,  clk3_used,  clk4_used;
        input clk5_used,  clk6_used,  clk7_used,  clk8_used,  clk9_used;
        output m;
        output n;

        parameter max_m = 511;
        parameter max_n = 511;
        parameter max_pfd = 720;
        parameter min_pfd = 5;
        parameter max_vco = 1600; // max vco frequency. (in mHz)
        parameter min_vco = 300;  // min vco frequency. (in mHz)
        parameter max_offset = 0.004;

        reg[160:1] clk0_used,  clk1_used,  clk2_used,  clk3_used,  clk4_used;
        reg[160:1] clk5_used,  clk6_used,  clk7_used,  clk8_used,  clk9_used;

        integer inclock_period;
        integer vco_phase_shift_step;
        integer clk0_mult, clk1_mult, clk2_mult, clk3_mult, clk4_mult;
        integer clk5_mult, clk6_mult, clk7_mult, clk8_mult, clk9_mult;
        integer clk0_div,  clk1_div,  clk2_div,  clk3_div,  clk4_div;
        integer clk5_div,  clk6_div,  clk7_div,  clk8_div,  clk9_div;
        integer m;
        integer n;
        integer pre_m;
        integer pre_n;
        integer m_out;
        integer n_out;
        integer closest_vco_step_value;

        integer vco_period;
        integer pfd_freq;
        integer vco_freq;
        integer vco_ps_step_value;
        real    clk0_div_factor_real;
        real    clk1_div_factor_real;
        real    clk2_div_factor_real;
        real    clk3_div_factor_real;
        real    clk4_div_factor_real;
        real    clk5_div_factor_real;
        real    clk6_div_factor_real;
        real    clk7_div_factor_real;
        real    clk8_div_factor_real;
        real    clk9_div_factor_real;
        real    clk0_div_factor_diff;
        real    clk1_div_factor_diff;
        real    clk2_div_factor_diff;
        real    clk3_div_factor_diff;
        real    clk4_div_factor_diff;
        real    clk5_div_factor_diff;
        real    clk6_div_factor_diff;
        real    clk7_div_factor_diff;
        real    clk8_div_factor_diff;
        real    clk9_div_factor_diff;
        integer clk0_div_factor_int;
        integer clk1_div_factor_int;
        integer clk2_div_factor_int;
        integer clk3_div_factor_int;
        integer clk4_div_factor_int;
        integer clk5_div_factor_int;
        integer clk6_div_factor_int;
        integer clk7_div_factor_int;
        integer clk8_div_factor_int;
        integer clk9_div_factor_int;
    begin

        vco_period = vco_phase_shift_step * 8;

        pre_m = 0;
        pre_n = 0;
        closest_vco_step_value = 0;

        begin : LOOP_1
                for (n_out = 1; n_out < max_n; n_out = n_out +1)
                begin
                    for (m_out = 1; m_out < max_m; m_out = m_out +1)
                    begin
                        clk0_div_factor_real = (clk0_div * m_out * 1.0 ) / (clk0_mult * n_out);
                        clk1_div_factor_real = (clk1_div * m_out * 1.0) / (clk1_mult * n_out);
                        clk2_div_factor_real = (clk2_div * m_out * 1.0) / (clk2_mult * n_out);
                        clk3_div_factor_real = (clk3_div * m_out * 1.0) / (clk3_mult * n_out);
                        clk4_div_factor_real = (clk4_div * m_out * 1.0) / (clk4_mult * n_out);
                        clk5_div_factor_real = (clk5_div * m_out * 1.0) / (clk5_mult * n_out);
                        clk6_div_factor_real = (clk6_div * m_out * 1.0) / (clk6_mult * n_out);
                        clk7_div_factor_real = (clk7_div * m_out * 1.0) / (clk7_mult * n_out);
                        clk8_div_factor_real = (clk8_div * m_out * 1.0) / (clk8_mult * n_out);
                        clk9_div_factor_real = (clk9_div * m_out * 1.0) / (clk9_mult * n_out);

                        clk0_div_factor_int = clk0_div_factor_real;
                        clk1_div_factor_int = clk1_div_factor_real;
                        clk2_div_factor_int = clk2_div_factor_real;
                        clk3_div_factor_int = clk3_div_factor_real;
                        clk4_div_factor_int = clk4_div_factor_real;
                        clk5_div_factor_int = clk5_div_factor_real;
                        clk6_div_factor_int = clk6_div_factor_real;
                        clk7_div_factor_int = clk7_div_factor_real;
                        clk8_div_factor_int = clk8_div_factor_real;
                        clk9_div_factor_int = clk9_div_factor_real;

                        clk0_div_factor_diff = (clk0_div_factor_real - clk0_div_factor_int < 0) ? (clk0_div_factor_real - clk0_div_factor_int) * -1.0 : clk0_div_factor_real - clk0_div_factor_int;
                        clk1_div_factor_diff = (clk1_div_factor_real - clk1_div_factor_int < 0) ? (clk1_div_factor_real - clk1_div_factor_int) * -1.0 : clk1_div_factor_real - clk1_div_factor_int;
                        clk2_div_factor_diff = (clk2_div_factor_real - clk2_div_factor_int < 0) ? (clk2_div_factor_real - clk2_div_factor_int) * -1.0 : clk2_div_factor_real - clk2_div_factor_int;
                        clk3_div_factor_diff = (clk3_div_factor_real - clk3_div_factor_int < 0) ? (clk3_div_factor_real - clk3_div_factor_int) * -1.0 : clk3_div_factor_real - clk3_div_factor_int;
                        clk4_div_factor_diff = (clk4_div_factor_real - clk4_div_factor_int < 0) ? (clk4_div_factor_real - clk4_div_factor_int) * -1.0 : clk4_div_factor_real - clk4_div_factor_int;
                        clk5_div_factor_diff = (clk5_div_factor_real - clk5_div_factor_int < 0) ? (clk5_div_factor_real - clk5_div_factor_int) * -1.0 : clk5_div_factor_real - clk5_div_factor_int;
                        clk6_div_factor_diff = (clk6_div_factor_real - clk6_div_factor_int < 0) ? (clk6_div_factor_real - clk6_div_factor_int) * -1.0 : clk6_div_factor_real - clk6_div_factor_int;
                        clk7_div_factor_diff = (clk7_div_factor_real - clk7_div_factor_int < 0) ? (clk7_div_factor_real - clk7_div_factor_int) * -1.0 : clk7_div_factor_real - clk7_div_factor_int;
                        clk8_div_factor_diff = (clk8_div_factor_real - clk8_div_factor_int < 0) ? (clk8_div_factor_real - clk8_div_factor_int) * -1.0 : clk8_div_factor_real - clk8_div_factor_int;
                        clk9_div_factor_diff = (clk9_div_factor_real - clk9_div_factor_int < 0) ? (clk9_div_factor_real - clk9_div_factor_int) * -1.0 : clk9_div_factor_real - clk9_div_factor_int;


                        if (((clk0_div_factor_diff < max_offset) || (clk0_used == "unused")) &&
                            ((clk1_div_factor_diff < max_offset) || (clk1_used == "unused")) &&
                            ((clk2_div_factor_diff < max_offset) || (clk2_used == "unused")) &&
                            ((clk3_div_factor_diff < max_offset) || (clk3_used == "unused")) &&
                            ((clk4_div_factor_diff < max_offset) || (clk4_used == "unused")) &&
                            ((clk5_div_factor_diff < max_offset) || (clk5_used == "unused")) &&
                            ((clk6_div_factor_diff < max_offset) || (clk6_used == "unused")) &&
                            ((clk7_div_factor_diff < max_offset) || (clk7_used == "unused")) &&
                            ((clk8_div_factor_diff < max_offset) || (clk8_used == "unused")) &&
                            ((clk9_div_factor_diff < max_offset) || (clk9_used == "unused")) )
                        begin
                            if ((m_out != 0) && (n_out != 0))
                            begin
                                pfd_freq = 1000000 / (inclock_period * n_out);
                                vco_freq = (1000000 * m_out) / (inclock_period * n_out);
                                vco_ps_step_value = (inclock_period * n_out) / (8 * m_out);

                                if ( (m_out < max_m) && (n_out < max_n) && (pfd_freq >= min_pfd) && (pfd_freq <= max_pfd) &&
                                    (vco_freq >= min_vco) && (vco_freq <= max_vco) )
                                begin
                                    if (abs(vco_ps_step_value - vco_phase_shift_step) <= 2)
                                    begin
                                        pre_m = m_out;
                                        pre_n = n_out;
                                        disable LOOP_1;
                                    end
                                    else
                                    begin
                                        if ((closest_vco_step_value == 0) || (abs(vco_ps_step_value - vco_phase_shift_step) < abs(closest_vco_step_value - vco_phase_shift_step)))
                                        begin
                                            pre_m = m_out;
                                            pre_n = n_out;
                                            closest_vco_step_value = vco_ps_step_value;
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
        end

        if ((pre_m != 0) && (pre_n != 0))
        begin
            find_simple_integer_fraction(pre_m, pre_n,
                        max_n, m, n);
        end
        else
        begin
            n = 1;
            m = lcm  (clk0_mult, clk1_mult, clk2_mult, clk3_mult,
                    clk4_mult, clk5_mult, clk6_mult,
                    clk7_mult, clk8_mult, clk9_mult, inclock_period);
        end
    end
    endtask // find_m_and_n_4_manual_phase

    // find the factor of division of the output clock frequency
    // compared to the VCO
    function integer output_counter_value;
    input clk_divide, clk_mult, M, N;
    integer clk_divide, clk_mult, M, N;
    real r;
    integer r_int;
    begin
        r = (clk_divide * M * 1.0)/(clk_mult * N);
        r_int = r;
        output_counter_value = r_int;
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
        half_cycle_high = (2*duty_cycle*output_counter_value)/100.0;
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
        half_cycle_high = (2*duty_cycle*output_counter_value)/100.0;
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
    begin
        half_cycle_high = (2*duty_cycle*output_counter_value)/100.0;
        mode = ((half_cycle_high % 2) == 0);
        tmp_counter_high = half_cycle_high/2;
        counter_h = tmp_counter_high + !mode;
        counter_low =  output_counter_value - counter_h;
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
        phase = ((tap_phase * m) / (360.0 * n)) + 0.6;
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
        counter_ph = (phase % 360) / 45.0;

        if (counter_ph == 8)
            counter_ph = 0;
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

    // this is for stratixiii lvds only
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
        result = (phase_shift * 360) / inclk0_freq;
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
    function [8*`STXIII_PLL_WORD_LENGTH:1] alpha_tolower;
    input [8*`STXIII_PLL_WORD_LENGTH:1] given_string;

    reg [8*`STXIII_PLL_WORD_LENGTH:1] return_string;
    reg [8*`STXIII_PLL_WORD_LENGTH:1] reg_string;
    reg [8:1] tmp;
    reg [8:1] conv_char;
    integer byte_count;
    begin
        return_string = "                    "; // initialise strings to spaces
        conv_char = "        ";
        reg_string = given_string;
        for (byte_count = `STXIII_PLL_WORD_LENGTH; byte_count >= 1; byte_count = byte_count - 1)
        begin
            tmp = reg_string[8*`STXIII_PLL_WORD_LENGTH:(8*(`STXIII_PLL_WORD_LENGTH-1)+1)];
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
        scandata_out = 1'b0;
        first_inclk0_edge_detect = 1'b0;
        first_inclk1_edge_detect = 1'b0;
        pll_reconfig_display_full_setting = 1'b0;
        initiate_reconfig = 1'b0;
    switch_over_count = 0;
        // convert string parameter values from uppercase to lowercase,
        // as expected in this model
        l_operation_mode             = alpha_tolower(operation_mode);
        l_pll_type                   = alpha_tolower(pll_type);
        l_compensate_clock           = alpha_tolower(compensate_clock);
        l_switch_over_type           = alpha_tolower(switch_over_type);
        l_bandwidth_type             = alpha_tolower(bandwidth_type);
        l_simulation_type            = alpha_tolower(simulation_type);
        l_sim_gate_lock_device_behavior = alpha_tolower(sim_gate_lock_device_behavior);
        l_vco_frequency_control      = alpha_tolower(vco_frequency_control);
        l_enable_switch_over_counter = alpha_tolower(enable_switch_over_counter);
        l_self_reset_on_loss_lock    = alpha_tolower(self_reset_on_loss_lock);

        real_lock_high = (l_sim_gate_lock_device_behavior == "on") ? lock_high : 0;
        // initialize charge_pump_current, and loop_filter tables
        loop_filter_c_arr[0] = 0;
        loop_filter_c_arr[1] = 0;
        loop_filter_c_arr[2] = 0;
        loop_filter_c_arr[3] = 0;

        fpll_loop_filter_c_arr[0] = 0;
        fpll_loop_filter_c_arr[1] = 0;
        fpll_loop_filter_c_arr[2] = 0;
        fpll_loop_filter_c_arr[3] = 0;

        charge_pump_curr_arr[0] = 0;
        charge_pump_curr_arr[1] = 0;
        charge_pump_curr_arr[2] = 0;
        charge_pump_curr_arr[3] = 0;
        charge_pump_curr_arr[4] = 0;
        charge_pump_curr_arr[5] = 0;
        charge_pump_curr_arr[6] = 0;
        charge_pump_curr_arr[7] = 0;
        charge_pump_curr_arr[8] = 0;
        charge_pump_curr_arr[9] = 0;
        charge_pump_curr_arr[10] = 0;
        charge_pump_curr_arr[11] = 0;
        charge_pump_curr_arr[12] = 0;
        charge_pump_curr_arr[13] = 0;
        charge_pump_curr_arr[14] = 0;
        charge_pump_curr_arr[15] = 0;

        i_vco_max = vco_max;
        i_vco_min = vco_min;

        if(vco_post_scale == 1)
        begin
            i_vco_max_no_division = vco_max * 2;
            i_vco_min_no_division = vco_min * 2;
        end
        else
        begin
            i_vco_max_no_division = vco_max;
            i_vco_min_no_division = vco_min;
        end


        if (m == 0)
        begin
            i_clk9_counter    = "c9";
            i_clk8_counter    = "c8";
            i_clk7_counter    = "c7";
            i_clk6_counter    = "c6";
            i_clk5_counter    = "c5" ;
            i_clk4_counter    = "c4" ;
            i_clk3_counter    = "c3" ;
            i_clk2_counter    = "c2" ;
            i_clk1_counter    = "c1" ;
            i_clk0_counter    = "c0" ;
        end
        else begin
            i_clk9_counter    = alpha_tolower(clk9_counter);
            i_clk8_counter    = alpha_tolower(clk8_counter);
            i_clk7_counter    = alpha_tolower(clk7_counter);
            i_clk6_counter    = alpha_tolower(clk6_counter);
            i_clk5_counter    = alpha_tolower(clk5_counter);
            i_clk4_counter    = alpha_tolower(clk4_counter);
            i_clk3_counter    = alpha_tolower(clk3_counter);
            i_clk2_counter    = alpha_tolower(clk2_counter);
            i_clk1_counter    = alpha_tolower(clk1_counter);
            i_clk0_counter    = alpha_tolower(clk0_counter);
        end

        if (m == 0)
        begin

            // set the limit of the divide_by value that can be returned by
            // the following function.
            max_d_value = 1500;

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
            find_simple_integer_fraction(clk6_multiply_by, clk6_divide_by,
                            max_d_value, i_clk6_mult_by, i_clk6_div_by);
            find_simple_integer_fraction(clk7_multiply_by, clk7_divide_by,
                            max_d_value, i_clk7_mult_by, i_clk7_div_by);
            find_simple_integer_fraction(clk8_multiply_by, clk8_divide_by,
                            max_d_value, i_clk8_mult_by, i_clk8_div_by);
            find_simple_integer_fraction(clk9_multiply_by, clk9_divide_by,
                            max_d_value, i_clk9_mult_by, i_clk9_div_by);

            // convert user parameters to advanced
            if (l_vco_frequency_control == "manual_phase")
            begin
                find_m_and_n_4_manual_phase(inclk0_freq, vco_phase_shift_step,
                            i_clk0_mult_by, i_clk1_mult_by,
                            i_clk2_mult_by, i_clk3_mult_by,i_clk4_mult_by,
                i_clk5_mult_by,
                i_clk6_mult_by, i_clk7_mult_by,
                i_clk8_mult_by, i_clk9_mult_by,
                            i_clk0_div_by, i_clk1_div_by,
                            i_clk2_div_by, i_clk3_div_by,i_clk4_div_by,
                i_clk5_div_by,
                i_clk6_div_by, i_clk7_div_by,
                i_clk8_div_by, i_clk9_div_by,
                            clk0_counter, clk1_counter,
                            clk2_counter, clk3_counter,clk4_counter,
                clk5_counter,
                clk6_counter, clk7_counter,
                clk8_counter, clk9_counter,
                            i_m, i_n);
            end
            else if (((l_pll_type == "fast") || (l_pll_type == "lvds") || (l_pll_type == "left_right")) && (vco_multiply_by != 0) && (vco_divide_by != 0))
            begin
                i_n = vco_divide_by;
                i_m = vco_multiply_by;
            end
            else begin
                i_n = 1;
                if (((l_pll_type == "fast") || (l_pll_type == "left_right")) && (l_compensate_clock == "lvdsclk"))
                    i_m = i_clk0_mult_by;
                else
                    i_m = lcm  (i_clk0_mult_by, i_clk1_mult_by,
                            i_clk2_mult_by, i_clk3_mult_by,i_clk4_mult_by,
                i_clk5_mult_by,
                i_clk6_mult_by, i_clk7_mult_by,
                i_clk8_mult_by, i_clk9_mult_by,
                            inclk0_freq);
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
            i_c_high[6] = counter_high (output_counter_value(i_clk6_div_by,
                                        i_clk6_mult_by,  i_m, i_n), clk6_duty_cycle);
            i_c_high[7] = counter_high (output_counter_value(i_clk7_div_by,
                                        i_clk7_mult_by,  i_m, i_n), clk7_duty_cycle);
            i_c_high[8] = counter_high (output_counter_value(i_clk8_div_by,
                                        i_clk8_mult_by,  i_m, i_n), clk8_duty_cycle);
            i_c_high[9] = counter_high (output_counter_value(i_clk9_div_by,
                                        i_clk9_mult_by,  i_m, i_n), clk9_duty_cycle);

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
            i_c_low[6]  = counter_low  (output_counter_value(i_clk6_div_by,
                                        i_clk6_mult_by,  i_m, i_n), clk6_duty_cycle);
            i_c_low[7]  = counter_low  (output_counter_value(i_clk7_div_by,
                                        i_clk7_mult_by,  i_m, i_n), clk7_duty_cycle);
            i_c_low[8]  = counter_low  (output_counter_value(i_clk8_div_by,
                                        i_clk8_mult_by,  i_m, i_n), clk8_duty_cycle);
            i_c_low[9]  = counter_low  (output_counter_value(i_clk9_div_by,
                                        i_clk9_mult_by,  i_m, i_n), clk9_duty_cycle);

            if (l_pll_type == "flvds")
            begin
                // Need to readjust phase shift values when the clock multiply value has been readjusted.
                new_multiplier = clk0_multiply_by / i_clk0_mult_by;
                i_clk0_phase_shift = (clk0_phase_shift_num * new_multiplier);
                i_clk1_phase_shift = (clk1_phase_shift_num * new_multiplier);
                i_clk2_phase_shift = (clk2_phase_shift_num * new_multiplier);
                i_clk3_phase_shift = 0;
                i_clk4_phase_shift = 0;
            end
            else
            begin
                i_clk0_phase_shift = get_int_phase_shift(clk0_phase_shift, clk0_phase_shift_num);
                i_clk1_phase_shift = get_int_phase_shift(clk1_phase_shift, clk1_phase_shift_num);
                i_clk2_phase_shift = get_int_phase_shift(clk2_phase_shift, clk2_phase_shift_num);
                i_clk3_phase_shift = get_int_phase_shift(clk3_phase_shift, clk3_phase_shift_num);
                i_clk4_phase_shift = get_int_phase_shift(clk4_phase_shift, clk4_phase_shift_num);
            end

            max_neg_abs = maxnegabs   ( i_clk0_phase_shift,
                                        i_clk1_phase_shift,
                                        i_clk2_phase_shift,
                                        i_clk3_phase_shift,
                                        i_clk4_phase_shift,
                                            str2int(clk5_phase_shift),
                                            str2int(clk6_phase_shift),
                                            str2int(clk7_phase_shift),
                                            str2int(clk8_phase_shift),
                                            str2int(clk9_phase_shift)
                                        );

            i_c_initial[0] = counter_initial(get_phase_degree(ph_adjust(i_clk0_phase_shift, max_neg_abs)), i_m, i_n);
            i_c_initial[1] = counter_initial(get_phase_degree(ph_adjust(i_clk1_phase_shift, max_neg_abs)), i_m, i_n);
            i_c_initial[2] = counter_initial(get_phase_degree(ph_adjust(i_clk2_phase_shift, max_neg_abs)), i_m, i_n);
            i_c_initial[3] = counter_initial(get_phase_degree(ph_adjust(i_clk3_phase_shift, max_neg_abs)), i_m, i_n);
            i_c_initial[4] = counter_initial(get_phase_degree(ph_adjust(i_clk4_phase_shift, max_neg_abs)), i_m, i_n);
            i_c_initial[5] = counter_initial(get_phase_degree(ph_adjust(str2int(clk5_phase_shift), max_neg_abs)), i_m, i_n);
            i_c_initial[6] = counter_initial(get_phase_degree(ph_adjust(str2int(clk6_phase_shift), max_neg_abs)), i_m, i_n);
            i_c_initial[7] = counter_initial(get_phase_degree(ph_adjust(str2int(clk7_phase_shift), max_neg_abs)), i_m, i_n);
            i_c_initial[8] = counter_initial(get_phase_degree(ph_adjust(str2int(clk8_phase_shift), max_neg_abs)), i_m, i_n);
            i_c_initial[9] = counter_initial(get_phase_degree(ph_adjust(str2int(clk9_phase_shift), max_neg_abs)), i_m, i_n);

            i_c_mode[0] = counter_mode(clk0_duty_cycle,output_counter_value(i_clk0_div_by, i_clk0_mult_by,  i_m, i_n));
            i_c_mode[1] = counter_mode(clk1_duty_cycle,output_counter_value(i_clk1_div_by, i_clk1_mult_by,  i_m, i_n));
            i_c_mode[2] = counter_mode(clk2_duty_cycle,output_counter_value(i_clk2_div_by, i_clk2_mult_by,  i_m, i_n));
            i_c_mode[3] = counter_mode(clk3_duty_cycle,output_counter_value(i_clk3_div_by, i_clk3_mult_by,  i_m, i_n));
            i_c_mode[4] = counter_mode(clk4_duty_cycle,output_counter_value(i_clk4_div_by, i_clk4_mult_by,  i_m, i_n));
            i_c_mode[5] = counter_mode(clk5_duty_cycle,output_counter_value(i_clk5_div_by, i_clk5_mult_by,  i_m, i_n));
            i_c_mode[6] = counter_mode(clk6_duty_cycle,output_counter_value(i_clk6_div_by, i_clk6_mult_by,  i_m, i_n));
            i_c_mode[7] = counter_mode(clk7_duty_cycle,output_counter_value(i_clk7_div_by, i_clk7_mult_by,  i_m, i_n));
            i_c_mode[8] = counter_mode(clk8_duty_cycle,output_counter_value(i_clk8_div_by, i_clk8_mult_by,  i_m, i_n));
            i_c_mode[9] = counter_mode(clk9_duty_cycle,output_counter_value(i_clk9_div_by, i_clk9_mult_by,  i_m, i_n));

            i_m_ph    = counter_ph(get_phase_degree(max_neg_abs), i_m, i_n);
            i_m_initial = counter_initial(get_phase_degree(max_neg_abs), i_m, i_n);

            i_c_ph[0] = counter_ph(get_phase_degree(ph_adjust(i_clk0_phase_shift, max_neg_abs)), i_m, i_n);
            i_c_ph[1] = counter_ph(get_phase_degree(ph_adjust(i_clk1_phase_shift, max_neg_abs)), i_m, i_n);
            i_c_ph[2] = counter_ph(get_phase_degree(ph_adjust(i_clk2_phase_shift, max_neg_abs)), i_m, i_n);
            i_c_ph[3] = counter_ph(get_phase_degree(ph_adjust(i_clk3_phase_shift,max_neg_abs)), i_m, i_n);
            i_c_ph[4] = counter_ph(get_phase_degree(ph_adjust(i_clk4_phase_shift,max_neg_abs)), i_m, i_n);
            i_c_ph[5] = counter_ph(get_phase_degree(ph_adjust(str2int(clk5_phase_shift),max_neg_abs)), i_m, i_n);
            i_c_ph[6] = counter_ph(get_phase_degree(ph_adjust(str2int(clk6_phase_shift),max_neg_abs)), i_m, i_n);
            i_c_ph[7] = counter_ph(get_phase_degree(ph_adjust(str2int(clk7_phase_shift),max_neg_abs)), i_m, i_n);
            i_c_ph[8] = counter_ph(get_phase_degree(ph_adjust(str2int(clk8_phase_shift),max_neg_abs)), i_m, i_n);
            i_c_ph[9] = counter_ph(get_phase_degree(ph_adjust(str2int(clk9_phase_shift),max_neg_abs)), i_m, i_n);


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
            i_c_high[6] = c6_high;
            i_c_high[7] = c7_high;
            i_c_high[8] = c8_high;
            i_c_high[9] = c9_high;
            i_c_low[0]  = c0_low;
            i_c_low[1]  = c1_low;
            i_c_low[2]  = c2_low;
            i_c_low[3]  = c3_low;
            i_c_low[4]  = c4_low;
            i_c_low[5]  = c5_low;
            i_c_low[6]  = c6_low;
            i_c_low[7]  = c7_low;
            i_c_low[8]  = c8_low;
            i_c_low[9]  = c9_low;
            i_c_initial[0] = c0_initial;
            i_c_initial[1] = c1_initial;
            i_c_initial[2] = c2_initial;
            i_c_initial[3] = c3_initial;
            i_c_initial[4] = c4_initial;
            i_c_initial[5] = c5_initial;
            i_c_initial[6] = c6_initial;
            i_c_initial[7] = c7_initial;
            i_c_initial[8] = c8_initial;
            i_c_initial[9] = c9_initial;
            i_c_mode[0] = translate_string(alpha_tolower(c0_mode));
            i_c_mode[1] = translate_string(alpha_tolower(c1_mode));
            i_c_mode[2] = translate_string(alpha_tolower(c2_mode));
            i_c_mode[3] = translate_string(alpha_tolower(c3_mode));
            i_c_mode[4] = translate_string(alpha_tolower(c4_mode));
            i_c_mode[5] = translate_string(alpha_tolower(c5_mode));
            i_c_mode[6] = translate_string(alpha_tolower(c6_mode));
            i_c_mode[7] = translate_string(alpha_tolower(c7_mode));
            i_c_mode[8] = translate_string(alpha_tolower(c8_mode));
            i_c_mode[9] = translate_string(alpha_tolower(c9_mode));
            i_c_ph[0]  = c0_ph;
            i_c_ph[1]  = c1_ph;
            i_c_ph[2]  = c2_ph;
            i_c_ph[3]  = c3_ph;
            i_c_ph[4]  = c4_ph;
            i_c_ph[5]  = c5_ph;
            i_c_ph[6]  = c6_ph;
            i_c_ph[7]  = c7_ph;
            i_c_ph[8]  = c8_ph;
            i_c_ph[9]  = c9_ph;
            i_m_ph   = m_ph;        // default
            i_m_initial = m_initial;

        end // user to advanced conversion

        switch_clock = 1'b0;

        refclk_period = inclk0_freq * i_n;

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
        inclk_es = 0;
        inclk_man = 0;
        cycle_to_adjust = 0;
        m_delay = 0;
        total_pull_back = 0;
        pull_back_M = 0;
        vco_period_was_phase_adjusted = 0;
        phase_adjust_was_scheduled = 0;
        inclk_out_of_range = 0;
        scandone_tmp = 1'b0;
        schedule_vco_last_value = 0;


        if ((l_pll_type == "fast") || (l_pll_type == "lvds") || (l_pll_type == "left_right"))
        begin
            scan_chain_length = FAST_SCAN_CHAIN;
            num_output_cntrs = 7;
        end
        else
        begin
            scan_chain_length = GPP_SCAN_CHAIN;
            num_output_cntrs = 10;
        end

        phasestep_high_count = 0;
        update_phase = 0;
        // set initial values for counter parameters
        m_initial_val = i_m_initial;
        m_val[0] = i_m;
        n_val[0] = i_n;
        m_ph_val = i_m_ph;
        m_ph_val_orig = i_m_ph;
        m_ph_val_tmp = i_m_ph;
        m_val_tmp[0] = i_m;


        if (m_val[0] == 1)
            m_mode_val[0] = "bypass";
        else m_mode_val[0] = "";
        if (m_val[1] == 1)
            m_mode_val[1] = "bypass";
        if (n_val[0] == 1)
            n_mode_val[0] = "bypass";
        if (n_val[1] == 1)
            n_mode_val[1] = "bypass";

        for (i = 0; i < 10; i=i+1)
        begin
            c_high_val[i] = i_c_high[i];
            c_low_val[i] = i_c_low[i];
            c_initial_val[i] = i_c_initial[i];
            c_mode_val[i] = i_c_mode[i];
            c_ph_val[i] = i_c_ph[i];
            c_high_val_tmp[i] = i_c_high[i];
            c_hval[i] = i_c_high[i];
            c_low_val_tmp[i] = i_c_low[i];
            c_lval[i] = i_c_low[i];
            if (c_mode_val[i] == "bypass")
            begin
                if (l_pll_type == "fast" || l_pll_type == "lvds" || l_pll_type == "left_right")
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
        vco_cur = vco_post_scale;

        i = 0;
        j = 0;
        inclk_last_value = 0;


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
        current_clock = 0;
        current_clock_man = 0;

        active_clock = 0;   // primary_clk is always inclk0
        if (l_pll_type == "fast" || (l_pll_type == "left_right"))
            l_switch_over_type = "manual";

        if (l_switch_over_type == "manual" && clkswitch === 1'b1)
        begin
            current_clock_man = 1;
            active_clock = 1;
        end
        got_curr_clk_falling_edge_after_clkswitch = 0;
        clk0_count = 0;
        clk1_count = 0;

        // initialize reconfiguration variables
        // quiet_time
        quiet_time = slowest_clk  ( c_high_val[0]+c_low_val[0], c_mode_val[0],
                                    c_high_val[1]+c_low_val[1], c_mode_val[1],
                                    c_high_val[2]+c_low_val[2], c_mode_val[2],
                                    c_high_val[3]+c_low_val[3], c_mode_val[3],
                                    c_high_val[4]+c_low_val[4], c_mode_val[4],
                                    c_high_val[5]+c_low_val[5], c_mode_val[5],
                                    c_high_val[6]+c_low_val[6], c_mode_val[6],
                                    c_high_val[7]+c_low_val[7], c_mode_val[7],
                                    c_high_val[8]+c_low_val[8], c_mode_val[8],
                                    c_high_val[9]+c_low_val[9], c_mode_val[9],
                                    refclk_period, m_val[0]);
        reconfig_err = 0;
        error = 0;


        c0_rising_edge_transfer_done = 0;
        c1_rising_edge_transfer_done = 0;
        c2_rising_edge_transfer_done = 0;
        c3_rising_edge_transfer_done = 0;
        c4_rising_edge_transfer_done = 0;
        c5_rising_edge_transfer_done = 0;
        c6_rising_edge_transfer_done = 0;
        c7_rising_edge_transfer_done = 0;
        c8_rising_edge_transfer_done = 0;
        c9_rising_edge_transfer_done = 0;
        got_first_scanclk = 0;
        got_first_gated_scanclk = 0;
        gated_scanclk = 1;
        scanread_setup_violation = 0;
        index = 0;

        vco_over  = 1'b0;
        vco_under = 1'b0;

        // Initialize the scan chain

        // LF unused : bit 1
        scan_data[-1:0] = 2'b00;
        // LF Capacitance : bits 1,2 : all values are legal
        scan_data[1:2] = loop_filter_c_bits;
        // LF Resistance : bits 3-7
        scan_data[3:7] = loop_filter_r_bits;

        // VCO post scale
        if(vco_post_scale == 1)
        begin
            scan_data[8] = 1'b1;
            vco_val_old_bit_setting = 1'b1;
        end
        else
        begin
            scan_data[8] = 1'b0;
            vco_val_old_bit_setting = 1'b0;
        end

        scan_data[9:13] = 5'b00000;
        // CP
        // Bit 8 : CRBYPASS
        // Bit 9-13 : unused
        // Bits 14-16 : all values are legal
                scan_data[14:16] = charge_pump_current_bits;
        // store as old values

        cp_curr_old_bit_setting = charge_pump_current_bits;
        lfc_val_old_bit_setting = loop_filter_c_bits;
        lfr_val_old_bit_setting = loop_filter_r_bits;

        // C counters (start bit 53) bit 1:mode(bypass),bit 2-9:high,bit 10:mode(odd/even),bit 11-18:low
        for (i = 0; i < num_output_cntrs; i = i + 1)
        begin
            // 1. Mode - bypass
            if (c_mode_val[i] == "bypass")
            begin
                scan_data[53 + i*18 + 0] = 1'b1;
                if (c_mode_val[i] == "   odd")
                    scan_data[53 + i*18 + 9] = 1'b1;
                else
                    scan_data[53 + i*18 + 9] = 1'b0;
            end
            else
            begin
                scan_data[53 + i*18 + 0] = 1'b0;
                // 3. Mode - odd/even
                if (c_mode_val[i] == "   odd")
                    scan_data[53 + i*18 + 9] = 1'b1;
                else
                    scan_data[53 + i*18 + 9] = 1'b0;
            end
            // 2. Hi
            c_val = c_high_val[i];
            for (j = 1; j <= 8; j = j + 1)
                scan_data[53 + i*18 + j]  = c_val[8 - j];

            // 4. Low
            c_val = c_low_val[i];
            for (j = 10; j <= 17; j = j + 1)
                scan_data[53 + i*18 + j] = c_val[17 - j];
        end

        // M counter
        // 1. Mode - bypass (bit 17)
        if (m_mode_val[0] == "bypass")
                scan_data[17] = 1'b1;
        else
                scan_data[17] = 1'b0;  // set bypass bit to 0

        // 2. High (bit 18-25)
        // 3. Mode - odd/even (bit 26)
        if (m_val[0] % 2 == 0)
        begin
            // M is an even no. : set M high = low,
            // set odd/even bit to 0
                scan_data[18:25] = m_val[0]/2;
                scan_data[26] = 1'b0;
        end
        else
        begin
            // M is odd : M high = low + 1
                scan_data[18:25] = m_val[0]/2 + 1;
                scan_data[26] = 1'b1;
        end
        // 4. Low (bit 27-34)
            scan_data[27:34] = m_val[0]/2;


        // N counter
        // 1. Mode - bypass (bit 35)
        if (n_mode_val[0] == "bypass")
                scan_data[35] = 1'b1;
        else
                scan_data[35] = 1'b0;  // set bypass bit to 0
        // 2. High (bit 36-43)
        // 3. Mode - odd/even (bit 44)
        if (n_val[0] % 2 == 0)
        begin
            // N is an even no. : set N high = low,
            // set odd/even bit to 0
                scan_data[36:43] = n_val[0]/2;
                scan_data[44] = 1'b0;
        end
        else
        begin // N is odd : N high = N low + 1
                scan_data[36:43] = n_val[0]/2 + 1;
                scan_data[44] = 1'b1;
        end
        // 4. Low (bit 45-52)
                scan_data[45:52] = n_val[0]/2;


        l_index = 1;
        stop_vco = 0;
        cycles_to_lock = 0;
        cycles_to_unlock = 0;
        locked_tmp = 0;
        pll_is_locked = 0;
        no_warn = 1'b0;

        pfd_locked = 1'b0;
        cycles_pfd_high = 0;
        cycles_pfd_low  = 0;

        // check if pll is in test mode
        if (m_test_source != -1 || c0_test_source != -1 || c1_test_source != -1 || c2_test_source != -1 || c3_test_source != -1 || c4_test_source != -1 || c5_test_source != -1 || c6_test_source != -1 || c7_test_source != -1 || c8_test_source != -1 || c9_test_source != -1)
            pll_in_test_mode = 1'b1;
        else
            pll_in_test_mode = 1'b0;

        pll_is_in_reset = 0;
        pll_has_just_been_reconfigured = 0;
        if (l_pll_type == "fast" || l_pll_type == "lvds" || l_pll_type == "left_right")
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
        if (c6_use_casc_in == "on")
            ic6_use_casc_in = 1;
        else
            ic6_use_casc_in = 0;
        if (c7_use_casc_in == "on")
            ic7_use_casc_in = 1;
        else
            ic7_use_casc_in = 0;
        if (c8_use_casc_in == "on")
            ic8_use_casc_in = 1;
        else
            ic8_use_casc_in = 0;
        if (c9_use_casc_in == "on")
            ic9_use_casc_in = 1;
        else
            ic9_use_casc_in = 0;

        tap0_is_active = 1;

// To display clock mapping
    case( i_clk0_counter)
            "c0" : clk_num[0] = "  clk0";
            "c1" : clk_num[0] = "  clk1";
            "c2" : clk_num[0] = "  clk2";
            "c3" : clk_num[0] = "  clk3";
            "c4" : clk_num[0] = "  clk4";
            "c5" : clk_num[0] = "  clk5";
            "c6" : clk_num[0] = "  clk6";
            "c7" : clk_num[0] = "  clk7";
            "c8" : clk_num[0] = "  clk8";
            "c9" : clk_num[0] = "  clk9";
            default:clk_num[0] = "unused";
    endcase

        case( i_clk1_counter)
            "c0" : clk_num[1] = "  clk0";
            "c1" : clk_num[1] = "  clk1";
            "c2" : clk_num[1] = "  clk2";
            "c3" : clk_num[1] = "  clk3";
            "c4" : clk_num[1] = "  clk4";
            "c5" : clk_num[1] = "  clk5";
            "c6" : clk_num[1] = "  clk6";
            "c7" : clk_num[1] = "  clk7";
            "c8" : clk_num[1] = "  clk8";
            "c9" : clk_num[1] = "  clk9";
            default:clk_num[1] = "unused";
    endcase

    case( i_clk2_counter)
            "c0" : clk_num[2] = "  clk0";
            "c1" : clk_num[2] = "  clk1";
            "c2" : clk_num[2] = "  clk2";
            "c3" : clk_num[2] = "  clk3";
            "c4" : clk_num[2] = "  clk4";
            "c5" : clk_num[2] = "  clk5";
            "c6" : clk_num[2] = "  clk6";
            "c7" : clk_num[2] = "  clk7";
            "c8" : clk_num[2] = "  clk8";
            "c9" : clk_num[2] = "  clk9";
            default:clk_num[2] = "unused";
    endcase

    case( i_clk3_counter)
            "c0" : clk_num[3] = "  clk0";
            "c1" : clk_num[3] = "  clk1";
            "c2" : clk_num[3] = "  clk2";
            "c3" : clk_num[3] = "  clk3";
            "c4" : clk_num[3] = "  clk4";
            "c5" : clk_num[3] = "  clk5";
            "c6" : clk_num[3] = "  clk6";
            "c7" : clk_num[3] = "  clk7";
            "c8" : clk_num[3] = "  clk8";
            "c9" : clk_num[3] = "  clk9";
            default:clk_num[3] = "unused";
    endcase

    case( i_clk4_counter)
            "c0" : clk_num[4] = "  clk0";
            "c1" : clk_num[4] = "  clk1";
            "c2" : clk_num[4] = "  clk2";
            "c3" : clk_num[4] = "  clk3";
            "c4" : clk_num[4] = "  clk4";
            "c5" : clk_num[4] = "  clk5";
            "c6" : clk_num[4] = "  clk6";
            "c7" : clk_num[4] = "  clk7";
            "c8" : clk_num[4] = "  clk8";
            "c9" : clk_num[4] = "  clk9";
            default:clk_num[4] = "unused";
    endcase

    case( i_clk5_counter)
            "c0" : clk_num[5] = "  clk0";
            "c1" : clk_num[5] = "  clk1";
            "c2" : clk_num[5] = "  clk2";
            "c3" : clk_num[5] = "  clk3";
            "c4" : clk_num[5] = "  clk4";
            "c5" : clk_num[5] = "  clk5";
            "c6" : clk_num[5] = "  clk6";
            "c7" : clk_num[5] = "  clk7";
            "c8" : clk_num[5] = "  clk8";
            "c9" : clk_num[5] = "  clk9";
            default:clk_num[5] = "unused";
    endcase

    case( i_clk6_counter)
            "c0" : clk_num[6] = "  clk0";
            "c1" : clk_num[6] = "  clk1";
            "c2" : clk_num[6] = "  clk2";
            "c3" : clk_num[6] = "  clk3";
            "c4" : clk_num[6] = "  clk4";
            "c5" : clk_num[6] = "  clk5";
            "c6" : clk_num[6] = "  clk6";
            "c7" : clk_num[6] = "  clk7";
            "c8" : clk_num[6] = "  clk8";
            "c9" : clk_num[6] = "  clk9";
            default:clk_num[6] = "unused";
    endcase

    case( i_clk7_counter)
            "c0" : clk_num[7] = "  clk0";
            "c1" : clk_num[7] = "  clk1";
            "c2" : clk_num[7] = "  clk2";
            "c3" : clk_num[7] = "  clk3";
            "c4" : clk_num[7] = "  clk4";
            "c5" : clk_num[7] = "  clk5";
            "c6" : clk_num[7] = "  clk6";
            "c7" : clk_num[7] = "  clk7";
            "c8" : clk_num[7] = "  clk8";
            "c9" : clk_num[7] = "  clk9";
            default:clk_num[7] = "unused";
    endcase

    case( i_clk8_counter)
            "c0" : clk_num[8] = "  clk0";
            "c1" : clk_num[8] = "  clk1";
            "c2" : clk_num[8] = "  clk2";
            "c3" : clk_num[8] = "  clk3";
            "c4" : clk_num[8] = "  clk4";
            "c5" : clk_num[8] = "  clk5";
            "c6" : clk_num[8] = "  clk6";
            "c7" : clk_num[8] = "  clk7";
            "c8" : clk_num[8] = "  clk8";
            "c9" : clk_num[8] = "  clk9";
            default:clk_num[8] = "unused";
    endcase

    case( i_clk9_counter)
            "c0" : clk_num[9] = "  clk0";
            "c1" : clk_num[9] = "  clk1";
            "c2" : clk_num[9] = "  clk2";
            "c3" : clk_num[9] = "  clk3";
            "c4" : clk_num[9] = "  clk4";
            "c5" : clk_num[9] = "  clk5";
            "c6" : clk_num[9] = "  clk6";
            "c7" : clk_num[9] = "  clk7";
            "c8" : clk_num[9] = "  clk8";
            "c9" : clk_num[9] = "  clk9";
            default:clk_num[9] = "unused";
    endcase

        end


// Clock Switchover

always @(clkswitch)
begin
    if (clkswitch === 1'b1 && l_switch_over_type == "auto")
        external_switch = 1;
    else if (l_switch_over_type == "manual")
    begin
        if(clkswitch === 1'b1)
            switch_clock = 1'b1;
        else
            switch_clock = 1'b0;
    end
end


always @(posedge inclk[0])
begin
// Determine the inclk0 frequency
    if (first_inclk0_edge_detect == 1'b0)
        begin
            first_inclk0_edge_detect = 1'b1;
        end
    else
        begin
            last_inclk0_period = inclk0_period;
            inclk0_period = $realtime - last_inclk0_edge;
        end
    last_inclk0_edge = $realtime;

end

always @(posedge inclk[1])
begin
// Determine the inclk1 frequency
    if (first_inclk1_edge_detect == 1'b0)
        begin
            first_inclk1_edge_detect = 1'b1;
        end
    else
        begin
            last_inclk1_period = inclk1_period;
            inclk1_period = $realtime - last_inclk1_edge;
        end
    last_inclk1_edge = $realtime;

end

    always @(inclk[0] or inclk[1])
    begin
        if(switch_clock == 1'b1)
        begin
                if(current_clock_man == 0)
                begin
                    current_clock_man = 1;
                    active_clock = 1;
                end
                else
                begin
                    current_clock_man = 0;
                    active_clock = 0;
                end
                switch_clock = 1'b0;
            end

        if (current_clock_man == 0)
            inclk_man = inclk[0];
        else
            inclk_man = inclk[1];


        // save the inclk event value
        if (inclk[0] !== inclk0_last_value)
        begin
            if (current_clock != 0)
                other_clock_value = inclk[0];
        end
        if (inclk[1] !== inclk1_last_value)
        begin
            if (current_clock != 1)
                other_clock_value = inclk[1];
        end

        // check if either input clk is bad
        if (inclk[0] === 1'b1 && inclk[0] !== inclk0_last_value)
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
        if (inclk[1] === 1'b1 && inclk[1] !== inclk1_last_value)
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
        if ((inclk[0] !== inclk0_last_value) && current_clock == 0)
        begin
            if (external_switch == 1'b1)
            begin
                if (!got_curr_clk_falling_edge_after_clkswitch)
                begin
                    if (inclk[0] === 1'b0)
                        got_curr_clk_falling_edge_after_clkswitch = 1;
                    inclk_es = inclk[0];
                end
            end
            else inclk_es = inclk[0];
        end
        if ((inclk[1] !== inclk1_last_value) && current_clock == 1)
        begin
            if (external_switch == 1'b1)
            begin
                if (!got_curr_clk_falling_edge_after_clkswitch)
                begin
                    if (inclk[1] === 1'b0)
                        got_curr_clk_falling_edge_after_clkswitch = 1;
                    inclk_es = inclk[1];
                end
            end
            else inclk_es = inclk[1];
        end

        // actual switching -- automatic switch
        if ((other_clock_value == 1'b1) && (other_clock_value != other_clock_last_value) && l_enable_switch_over_counter == "on" && primary_clk_is_bad)
            switch_over_count = switch_over_count + 1;

        if ((other_clock_value == 1'b0) && (other_clock_value != other_clock_last_value))
        begin
            if ((external_switch && (got_curr_clk_falling_edge_after_clkswitch || current_clk_is_bad)) || (primary_clk_is_bad && (clkswitch !== 1'b1) && ((l_enable_switch_over_counter == "off" || switch_over_count == switch_over_counter))))
            begin
                if (areset === 1'b0)
                begin
                    if ((inclk0_period > inclk1_period) && (inclk1_period != 0))
                        diff_percent_period = (( inclk0_period - inclk1_period ) * 100) / inclk1_period;
                    else if (inclk0_period != 0)
                        diff_percent_period = (( inclk1_period - inclk0_period ) * 100) / inclk0_period;

                    if((diff_percent_period > 20)&& (l_switch_over_type == "auto"))
                    begin
                        $display ("Warning : The input clock frequencies specified for the specified PLL are too far apart for auto-switch-over feature to work properly. Please make sure that the clock frequencies are 20 percent apart for correct functionality.");
                        $display ("Time: %0t  Instance: %m", $time);
                    end
                end

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
            else if(l_switch_over_type == "auto")
                begin
                    if(current_clock == 0 && clk0_is_bad == 1'b1 && clk1_is_bad == 1'b0 )
                        begin
                            current_clock = 1;
                            active_clock = ~active_clock;
                        end

                    if(current_clock == 1 && clk1_is_bad == 1'b1 && clk0_is_bad == 1'b0 )
                        begin
                            current_clock = 0;
                            active_clock = ~active_clock;
                        end
                end
        end

        if(l_switch_over_type == "manual")
            inclk_n = inclk_man;
        else
            inclk_n = inclk_es;

        inclk0_last_value = inclk[0];
        inclk1_last_value = inclk[1];
        other_clock_last_value = other_clock_value;

    end

    and (clkbad[0], clk0_is_bad, 1'b1);
    and (clkbad[1], clk1_is_bad, 1'b1);
    and (activeclock, active_clock, 1'b1);


    assign inclk_m = (m_test_source == 0) ? fbclk : (m_test_source == 1) ? refclk : inclk_m_from_vco;


    ttn_m_cntr m1 (.clk(inclk_m),
                        .reset(areset || stop_vco),
                        .cout(fbclk),
                        .initial_value(m_initial_val),
                        .modulus(m_val[0]),
                        .time_delay(m_delay));

    ttn_n_cntr n1 (.clk(inclk_n),
                        .reset(areset),
                        .cout(refclk),
                        .modulus(n_val[0]));



    // Update clock on /o counters from corresponding VCO tap
    assign inclk_m_from_vco  = vco_tap[m_ph_val];
    assign inclk_c0_from_vco = vco_tap[c_ph_val[0]];
    assign inclk_c1_from_vco = vco_tap[c_ph_val[1]];
    assign inclk_c2_from_vco = vco_tap[c_ph_val[2]];
    assign inclk_c3_from_vco = vco_tap[c_ph_val[3]];
    assign inclk_c4_from_vco = vco_tap[c_ph_val[4]];
    assign inclk_c5_from_vco = vco_tap[c_ph_val[5]];
    assign inclk_c6_from_vco = vco_tap[c_ph_val[6]];
    assign inclk_c7_from_vco = vco_tap[c_ph_val[7]];
    assign inclk_c8_from_vco = vco_tap[c_ph_val[8]];
    assign inclk_c9_from_vco = vco_tap[c_ph_val[9]];
always @(vco_out)
    begin
        // check which VCO TAP has event
        for (x = 0; x <= 7; x = x + 1)
        begin
            if (vco_out[x] !== vco_out_last_value[x])
            begin
                // TAP 'X' has event
                if ((x == 0) && (!pll_is_in_reset) && (stop_vco !== 1'b1))
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
        // Update phase taps for C/M counters on negative edge of VCO clock output

        if (update_phase == 1'b1)
        begin
            for (x = 0; x <= 7; x = x + 1)
            begin
                if ((vco_tap[x] === 1'b0) && (vco_tap[x] !== vco_tap_last_value[x]))
                begin
                    for (y = 0; y < 10; y = y + 1)
                    begin
                        if (c_ph_val_tmp[y] == x)
                            c_ph_val[y] = c_ph_val_tmp[y];
                    end
                    if (m_ph_val_tmp == x)
                        m_ph_val = m_ph_val_tmp;
                end
            end
            update_phase <= #(0.5*scanclk_period) 1'b0;
        end

        // On reset, set all C/M counter phase taps to POF programmed values
        if (areset === 1'b1)
        begin
            m_ph_val = m_ph_val_orig;
            m_ph_val_tmp = m_ph_val_orig;
            for (i=0; i<= 9; i=i+1)
            begin
                c_ph_val[i] = c_ph_val_orig[i];
                c_ph_val_tmp[i] = c_ph_val_orig[i];
            end
        end

        vco_tap_last_value = vco_tap;
    end

    assign inclk_c0 = (c0_test_source == 0) ? fbclk : (c0_test_source == 1) ? refclk : inclk_c0_from_vco;

    ttn_scale_cntr c0 (.clk(inclk_c0),
                            .reset(areset  || stop_vco),
                            .cout(c0_clk),
                            .high(c_high_val[0]),
                            .low(c_low_val[0]),
                            .initial_value(c_initial_val[0]),
                            .mode(c_mode_val[0]),
                            .ph_tap(c_ph_val[0]));

    // Update /o counters mode and duty cycle immediately after configupdate is asserted
    always @(posedge scanclk)
    begin
        if (update_conf_latches_reg == 1'b1)
        begin
            c_high_val[0] <= c_high_val_tmp[0];
            c_mode_val[0] <= c_mode_val_tmp[0];
            c0_rising_edge_transfer_done = 1;
        end
    end
    always @(negedge scanclk)
    begin
        if (c0_rising_edge_transfer_done)
        begin
            c_low_val[0] <= c_low_val_tmp[0];
        end
    end

    assign inclk_c1 = (c1_test_source == 0) ? fbclk : (c1_test_source == 1) ? refclk : (ic1_use_casc_in == 1) ? c0_clk : inclk_c1_from_vco;

    ttn_scale_cntr c1 (.clk(inclk_c1),
                            .reset(areset || stop_vco),
                            .cout(c1_clk),
                            .high(c_high_val[1]),
                            .low(c_low_val[1]),
                            .initial_value(c_initial_val[1]),
                            .mode(c_mode_val[1]),
                            .ph_tap(c_ph_val[1]));

    always @(posedge scanclk)
    begin
        if (update_conf_latches_reg == 1'b1)
        begin
            c_high_val[1] <= c_high_val_tmp[1];
            c_mode_val[1] <= c_mode_val_tmp[1];
            c1_rising_edge_transfer_done = 1;
        end
    end
    always @(negedge scanclk)
    begin
        if (c1_rising_edge_transfer_done)
        begin
            c_low_val[1] <= c_low_val_tmp[1];
        end
    end

    assign inclk_c2 = (c2_test_source == 0) ? fbclk : (c2_test_source == 1) ? refclk :(ic2_use_casc_in == 1) ? c1_clk : inclk_c2_from_vco;

    ttn_scale_cntr c2 (.clk(inclk_c2),
                            .reset(areset || stop_vco),
                            .cout(c2_clk),
                            .high(c_high_val[2]),
                            .low(c_low_val[2]),
                            .initial_value(c_initial_val[2]),
                            .mode(c_mode_val[2]),
                            .ph_tap(c_ph_val[2]));

    always @(posedge scanclk)
    begin
        if (update_conf_latches_reg == 1'b1)
        begin
            c_high_val[2] <= c_high_val_tmp[2];
            c_mode_val[2] <= c_mode_val_tmp[2];
            c2_rising_edge_transfer_done = 1;
        end
    end
    always @(negedge scanclk)
    begin
        if (c2_rising_edge_transfer_done)
        begin
            c_low_val[2] <= c_low_val_tmp[2];
        end
    end

    assign inclk_c3 = (c3_test_source == 0) ? fbclk : (c3_test_source == 1) ? refclk : (ic3_use_casc_in == 1) ? c2_clk : inclk_c3_from_vco;

    ttn_scale_cntr c3 (.clk(inclk_c3),
                            .reset(areset  || stop_vco),
                            .cout(c3_clk),
                            .high(c_high_val[3]),
                            .low(c_low_val[3]),
                            .initial_value(c_initial_val[3]),
                            .mode(c_mode_val[3]),
                            .ph_tap(c_ph_val[3]));

    always @(posedge scanclk)
    begin
        if (update_conf_latches_reg == 1'b1)
        begin
            c_high_val[3] <= c_high_val_tmp[3];
            c_mode_val[3] <= c_mode_val_tmp[3];
            c3_rising_edge_transfer_done = 1;
        end
    end
    always @(negedge scanclk)
    begin
        if (c3_rising_edge_transfer_done)
        begin
            c_low_val[3] <= c_low_val_tmp[3];
        end
    end

    assign inclk_c4 = ((c4_test_source == 0) ? fbclk : (c4_test_source == 1) ? refclk :  (ic4_use_casc_in == 1) ? c3_clk : inclk_c4_from_vco);
    ttn_scale_cntr c4 (.clk(inclk_c4),
                            .reset(areset || stop_vco),
                            .cout(c4_clk),
                            .high(c_high_val[4]),
                            .low(c_low_val[4]),
                            .initial_value(c_initial_val[4]),
                            .mode(c_mode_val[4]),
                            .ph_tap(c_ph_val[4]));

    always @(posedge scanclk)
    begin
        if (update_conf_latches_reg == 1'b1)
        begin
            c_high_val[4] <= c_high_val_tmp[4];
            c_mode_val[4] <= c_mode_val_tmp[4];
            c4_rising_edge_transfer_done = 1;
        end
    end
    always @(negedge scanclk)
    begin
        if (c4_rising_edge_transfer_done)
        begin
            c_low_val[4] <= c_low_val_tmp[4];
        end
    end

    assign inclk_c5 = (c5_test_source == 0) ? fbclk : (c5_test_source == 1) ? refclk : (ic5_use_casc_in == 1) ? c4_clk : inclk_c5_from_vco;
    ttn_scale_cntr c5 (.clk(inclk_c5),
                            .reset(areset  || stop_vco),
                            .cout(c5_clk),
                            .high(c_high_val[5]),
                            .low(c_low_val[5]),
                            .initial_value(c_initial_val[5]),
                            .mode(c_mode_val[5]),
                            .ph_tap(c_ph_val[5]));

    always @(posedge scanclk)
    begin
        if (update_conf_latches_reg == 1'b1)
        begin
            c_high_val[5] <= c_high_val_tmp[5];
            c_mode_val[5] <= c_mode_val_tmp[5];
            c5_rising_edge_transfer_done = 1;
        end
    end
    always @(negedge scanclk)
    begin
        if (c5_rising_edge_transfer_done)
        begin
            c_low_val[5] <= c_low_val_tmp[5];
        end
    end

    assign inclk_c6 = ((c6_test_source == 0) ? fbclk : (c6_test_source == 1) ? refclk :  (ic6_use_casc_in == 1) ? c5_clk : inclk_c6_from_vco);
    ttn_scale_cntr c6 (.clk(inclk_c6),
                            .reset(areset  || stop_vco),
                            .cout(c6_clk),
                            .high(c_high_val[6]),
                            .low(c_low_val[6]),
                            .initial_value(c_initial_val[6]),
                            .mode(c_mode_val[6]),
                            .ph_tap(c_ph_val[6]));

    always @(posedge scanclk)
    begin
        if (update_conf_latches_reg == 1'b1)
        begin
            c_high_val[6] <= c_high_val_tmp[6];
            c_mode_val[6] <= c_mode_val_tmp[6];
            c6_rising_edge_transfer_done = 1;
        end
    end
    always @(negedge scanclk)
    begin
        if (c6_rising_edge_transfer_done)
        begin
            c_low_val[6] <= c_low_val_tmp[6];
        end
    end

    assign inclk_c7 = ((c7_test_source == 0) ? fbclk : (c7_test_source == 1) ? refclk :  (ic7_use_casc_in == 1) ? c6_clk : inclk_c7_from_vco);
    ttn_scale_cntr c7 (.clk(inclk_c7),
                            .reset(areset  || stop_vco),
                            .cout(c7_clk),
                            .high(c_high_val[7]),
                            .low(c_low_val[7]),
                            .initial_value(c_initial_val[7]),
                            .mode(c_mode_val[7]),
                            .ph_tap(c_ph_val[7]));

    always @(posedge scanclk)
    begin
        if (update_conf_latches_reg == 1'b1)
        begin
            c_high_val[7] <= c_high_val_tmp[7];
            c_mode_val[7] <= c_mode_val_tmp[7];
            c7_rising_edge_transfer_done = 1;
        end
    end
    always @(negedge scanclk)
    begin
        if (c7_rising_edge_transfer_done)
        begin
            c_low_val[7] <= c_low_val_tmp[7];
        end
    end

    assign inclk_c8 = ((c8_test_source == 0) ? fbclk : (c8_test_source == 1) ? refclk :  (ic8_use_casc_in == 1) ? c7_clk : inclk_c8_from_vco);
    ttn_scale_cntr c8 (.clk(inclk_c8),
                            .reset(areset || stop_vco),
                            .cout(c8_clk),
                            .high(c_high_val[8]),
                            .low(c_low_val[8]),
                            .initial_value(c_initial_val[8]),
                            .mode(c_mode_val[8]),
                            .ph_tap(c_ph_val[8]));

    always @(posedge scanclk)
    begin
        if (update_conf_latches_reg == 1'b1)
        begin
            c_high_val[8] <= c_high_val_tmp[8];
            c_mode_val[8] <= c_mode_val_tmp[8];
            c8_rising_edge_transfer_done = 1;
        end
    end
    always @(negedge scanclk)
    begin
        if (c8_rising_edge_transfer_done)
        begin
            c_low_val[8] <= c_low_val_tmp[8];
        end
    end

    assign inclk_c9 = ((c9_test_source == 0) ? fbclk : (c9_test_source == 1) ? refclk :  (ic9_use_casc_in == 1) ? c8_clk : inclk_c9_from_vco);
    ttn_scale_cntr c9 (.clk(inclk_c9),
                            .reset(areset  || stop_vco),
                            .cout(c9_clk),
                            .high(c_high_val[9]),
                            .low(c_low_val[9]),
                            .initial_value(c_initial_val[9]),
                            .mode(c_mode_val[9]),
                            .ph_tap(c_ph_val[9]));

    always @(posedge scanclk)
    begin
        if (update_conf_latches_reg == 1'b1)
        begin
            c_high_val[9] <= c_high_val_tmp[9];
            c_mode_val[9] <= c_mode_val_tmp[9];
            c9_rising_edge_transfer_done = 1;
        end
    end
    always @(negedge scanclk)
    begin
        if (c9_rising_edge_transfer_done)
        begin
            c_low_val[9] <= c_low_val_tmp[9];
        end
    end

assign locked = (test_bypass_lock_detect == "on") ? pfd_locked : locked_tmp;

// Register scanclk enable
    always @(negedge scanclk)
        scanclkena_reg <= scanclkena;

// Negative edge flip-flop in front of scan-chain

    always @(negedge scanclk)
    begin
        if (scanclkena_reg)
        begin
            scandata_in <= scandata;
        end
    end

// Scan chain
    always @(posedge scanclk)
    begin
        if (got_first_scanclk === 1'b0)
                got_first_scanclk = 1'b1;
        else
                scanclk_period = $time - scanclk_last_rising_edge;
        if (scanclkena_reg)
        begin
            for (j = scan_chain_length-2; j >= 0; j = j - 1)
                scan_data[j] = scan_data[j - 1];
            scan_data[-1] <= scandata_in;
        end
        scanclk_last_rising_edge = $realtime;
    end

// Scan output
    assign scandataout_tmp = (l_pll_type == "fast" || l_pll_type == "lvds" || l_pll_type == "left_right") ? scan_data[FAST_SCAN_CHAIN-2] : scan_data[GPP_SCAN_CHAIN-2];

// Negative edge flip-flop in rear of scan-chain

    always @(negedge scanclk)
    begin
        if (scanclkena_reg)
        begin
            scandata_out <= scandataout_tmp;
        end
    end

// Scan complete
    always @(negedge scandone_tmp)
    begin
            if (got_first_scanclk === 1'b1)
            begin
            if (reconfig_err == 1'b0)
            begin
                $display("NOTE : PLL Reprogramming completed with the following values (Values in parantheses are original values) : ");
                $display ("Time: %0t  Instance: %m", $time);

                $display("               N modulus =   %0d (%0d) ", n_val[0], n_val_old[0]);
                $display("               M modulus =   %0d (%0d) ", m_val[0], m_val_old[0]);


                for (i = 0; i < num_output_cntrs; i=i+1)
                begin
                    $display("              %s :    C%0d  high = %0d (%0d),       C%0d  low = %0d (%0d),       C%0d  mode = %s (%s)", clk_num[i],i, c_high_val[i], c_high_val_old[i], i, c_low_val_tmp[i], c_low_val_old[i], i, c_mode_val[i], c_mode_val_old[i]);
                end

                // display Charge pump and loop filter values
                if (pll_reconfig_display_full_setting == 1'b1)
                begin
                    $display ("               Charge Pump Current (uA) =   %0d (%0d) ", cp_curr_val, cp_curr_old);
                    $display ("               Loop Filter Capacitor (pF) =   %0d (%0d) ", lfc_val, lfc_old);
                    $display ("               Loop Filter Resistor (Kohm) =   %s (%s) ", lfr_val, lfr_old);
                    $display ("               VCO_Post_Scale  =   %0d (%0d) ", vco_cur, vco_old);
                end
                else
                begin
                    $display ("               Charge Pump Current  =   %0d (%0d) ", cp_curr_bit_setting, cp_curr_old_bit_setting);
                    $display ("               Loop Filter Capacitor  =   %0d (%0d) ", lfc_val_bit_setting, lfc_val_old_bit_setting);
                    $display ("               Loop Filter Resistor   =   %0d (%0d) ", lfr_val_bit_setting, lfr_val_old_bit_setting);
                    $display ("               VCO_Post_Scale   =   %b (%b) ", vco_val_bit_setting, vco_val_old_bit_setting);
                end
                cp_curr_old_bit_setting = cp_curr_bit_setting;
                lfc_val_old_bit_setting = lfc_val_bit_setting;
                lfr_val_old_bit_setting = lfr_val_bit_setting;
                vco_val_old_bit_setting = vco_val_bit_setting;
            end
            else begin
                $display("Warning : Errors were encountered during PLL reprogramming. Please refer to error/warning messages above.");
                $display ("Time: %0t  Instance: %m", $time);
            end
            end
    end

// ************ PLL Phase Reconfiguration ************* //

// Latch updown,counter values at pos edge of scan clock
always @(posedge scanclk)
begin
    if (phasestep_reg == 1'b1)
    begin
        if (phasestep_high_count == 1)
        begin
            phasecounterselect_reg <= phasecounterselect;
            phaseupdown_reg <= phaseupdown;
            // start reconfiguration
            if (phasecounterselect < 4'b1100) // no counters selected
            begin
                if (phasecounterselect == 0) // all output counters selected
                begin
                    for (i = 0; i < num_output_cntrs; i = i + 1)
                        c_ph_val_tmp[i] = (phaseupdown == 1'b1) ?
                                    (c_ph_val_tmp[i] + 1) % num_phase_taps :
                                    (c_ph_val_tmp[i] == 0) ? num_phase_taps - 1 : (c_ph_val_tmp[i] - 1) % num_phase_taps ;
                end
                else if (phasecounterselect == 1) // select M counter
                begin
                    m_ph_val_tmp = (phaseupdown == 1'b1) ?
                                (m_ph_val + 1) % num_phase_taps :
                                (m_ph_val == 0) ? num_phase_taps - 1 : (m_ph_val - 1) % num_phase_taps ;
                end
                else // select C counters
                begin
                    select_counter = phasecounterselect - 2;
                    c_ph_val_tmp[select_counter] =  (phaseupdown == 1'b1) ?
                                            (c_ph_val_tmp[select_counter] + 1) % num_phase_taps :
                                            (c_ph_val_tmp[select_counter] == 0) ? num_phase_taps - 1 : (c_ph_val_tmp[select_counter] - 1) % num_phase_taps ;
                end
                update_phase <= 1'b1;
            end

        end
        phasestep_high_count = phasestep_high_count + 1;

    end
end

// Latch phase enable (same as phasestep) on neg edge of scan clock
always @(negedge scanclk)
begin
    phasestep_reg <= phasestep;
end

always @(posedge phasestep)
begin
    if (update_phase == 1'b0) phasestep_high_count = 0; // phase adjustments must be 1 cycle apart
                                                        // if not, next phasestep cycle is skipped
end

// ************ PLL Full Reconfiguration ************* //
assign update_conf_latches = configupdate;


        // reset counter transfer flags
    always @(negedge scandone_tmp)
    begin
        c0_rising_edge_transfer_done = 0;
        c1_rising_edge_transfer_done = 0;
        c2_rising_edge_transfer_done = 0;
        c3_rising_edge_transfer_done = 0;
        c4_rising_edge_transfer_done = 0;
        c5_rising_edge_transfer_done = 0;
        c6_rising_edge_transfer_done = 0;
        c7_rising_edge_transfer_done = 0;
        c8_rising_edge_transfer_done = 0;
        c9_rising_edge_transfer_done = 0;
        update_conf_latches_reg <= 1'b0;
    end


    always @(posedge update_conf_latches)
    begin
        initiate_reconfig <= 1'b1;
    end

    always @(posedge areset)
    begin
        if (scandone_tmp == 1'b1) scandone_tmp = 1'b0;
    end

    always @(posedge scanclk)
    begin
        if (initiate_reconfig == 1'b1)
        begin
            initiate_reconfig <= 1'b0;
            $display ("NOTE : PLL Reprogramming initiated ....");
            $display ("Time: %0t  Instance: %m", $time);

            scandone_tmp <= #(scanclk_period) 1'b1;
            update_conf_latches_reg <= update_conf_latches;

            error = 0;
            reconfig_err = 0;
            scanread_setup_violation = 0;

            // save old values
            cp_curr_old = cp_curr_val;
            lfc_old = lfc_val;
            lfr_old = lfr_val;
            vco_old = vco_cur;
            // save old values of bit settings
            cp_curr_bit_setting = scan_data[14:16];
            lfc_val_bit_setting = scan_data[1:2];
            lfr_val_bit_setting = scan_data[3:7];
            vco_val_bit_setting = scan_data[8];

            // LF unused : bit 1
            // LF Capacitance : bits 1,2 : all values are legal
            if ((l_pll_type == "fast") || (l_pll_type == "lvds") || (l_pll_type == "left_right"))
                lfc_val = fpll_loop_filter_c_arr[scan_data[1:2]];
            else
                lfc_val = loop_filter_c_arr[scan_data[1:2]];

            // LF Resistance : bits 3-7
            // valid values - 00000,00100,10000,10100,11000,11011,11100,11110
            if (((scan_data[3:7] == 5'b00000) || (scan_data[3:7] == 5'b00100)) ||
                ((scan_data[3:7] == 5'b10000) || (scan_data[3:7] == 5'b10100)) ||
                ((scan_data[3:7] == 5'b11000) || (scan_data[3:7] == 5'b11011)) ||
                ((scan_data[3:7] == 5'b11100) || (scan_data[3:7] == 5'b11110))
            )
            begin
                lfr_val =   (scan_data[3:7] == 5'b00000) ? "20" :
                            (scan_data[3:7] == 5'b00100) ? "16" :
                            (scan_data[3:7] == 5'b10000) ? "12" :
                            (scan_data[3:7] == 5'b10100) ? "8" :
                            (scan_data[3:7] == 5'b11000) ? "6" :
                            (scan_data[3:7] == 5'b11011) ? "4" :
                            (scan_data[3:7] == 5'b11100) ? "2" : "1";
            end

            //VCO post scale value
            if (scan_data[8] === 1'b1)  // vco_post_scale = 1
            begin
                i_vco_max = i_vco_max_no_division/2;
                i_vco_min = i_vco_min_no_division/2;
                vco_cur = 1;
            end
            else
            begin
                i_vco_max = vco_max;
                i_vco_min = vco_min;
                vco_cur = 2;
            end

            // CP
            // Bit 8 : CRBYPASS
            // Bit 9-13 : unused
            // Bits 14-16 : all values are legal
            cp_curr_val = scan_data[14:16];

            // save old values for display info.
            for (i=0; i<=1; i=i+1)
            begin
                m_val_old[i] = m_val[i];
                n_val_old[i] = n_val[i];
                m_mode_val_old[i] = m_mode_val[i];
                n_mode_val_old[i] = n_mode_val[i];
            end
            for (i=0; i< num_output_cntrs; i=i+1)
            begin
                c_high_val_old[i] = c_high_val[i];
                c_low_val_old[i] = c_low_val[i];
                c_mode_val_old[i] = c_mode_val[i];
            end

            // M counter
            // 1. Mode - bypass (bit 17)
            if (scan_data[17] == 1'b1)
                m_mode_val[0] = "bypass";
            // 3. Mode - odd/even (bit 26)
            else if (scan_data[26] == 1'b1)
                m_mode_val[0] = "   odd";
            else
                m_mode_val[0] = "  even";
            // 2. High (bit 18-25)
                m_hi = scan_data[18:25];
            // 4. Low (bit 27-34)
                m_lo = scan_data[27:34];


            // N counter
            // 1. Mode - bypass (bit 35)
            if (scan_data[35] == 1'b1)
                n_mode_val[0] = "bypass";
            // 3. Mode - odd/even (bit 44)
            else if (scan_data[44] == 1'b1)
                n_mode_val[0] = "   odd";
            else
                n_mode_val[0] = "  even";

            // 2. High (bit 36-43)
                n_hi = scan_data[36:43];

            // 4. Low (bit 45-52)
                n_lo = scan_data[45:52];



//Update the current M and N counter values if the counters are NOT bypassed

if (m_mode_val[0] != "bypass")
m_val[0] = m_hi + m_lo;
if (n_mode_val[0] != "bypass")
n_val[0] = n_hi + n_lo;



            // C counters (start bit 53) bit 1:mode(bypass),bit 2-9:high,bit 10:mode(odd/even),bit 11-18:low

            for (i = 0; i < num_output_cntrs; i = i + 1)
            begin
                // 1. Mode - bypass
                if (scan_data[53 + i*18 + 0] == 1'b1)
                        c_mode_val_tmp[i] = "bypass";
                // 3. Mode - odd/even
                else if (scan_data[53 + i*18 + 9] == 1'b1)
                    c_mode_val_tmp[i] = "   odd";
                else
                    c_mode_val_tmp[i] = "  even";

                // 2. Hi
                for (j = 1; j <= 8; j = j + 1)
                    c_val[8-j] = scan_data[53 + i*18 + j];
                c_hval[i] = c_val[7:0];
                if (c_hval[i] !== 32'h00000000)
                    c_high_val_tmp[i] = c_hval[i];
                else
                    c_high_val_tmp[i] = 9'b100000000;
                // 4. Low
                for (j = 10; j <= 17; j = j + 1)
                    c_val[17 - j] = scan_data[53 + i*18 + j];
                c_lval[i] = c_val[7:0];
                if (c_lval[i] !== 32'h00000000)
                    c_low_val_tmp[i] = c_lval[i];
                else
                    c_low_val_tmp[i] = 9'b100000000;
            end

            // Legality Checks

            if (m_mode_val[0] != "bypass")
            begin
            if ((m_hi !== m_lo) && (m_mode_val[0] != "   odd"))
            begin
                    reconfig_err = 1;
                    $display ("Warning : The M counter of the %s Fast PLL should be configured for 50%% duty cycle only. In this case the HIGH and LOW moduli programmed will result in a duty cycle other than 50%%, which is illegal. Reconfiguration may not work", family_name);
                    $display ("Time: %0t  Instance: %m", $time);
            end
            else if (m_hi !== 8'b00000000)
            begin
                    // counter value
                    m_val_tmp[0] = m_hi + m_lo;
            end
            else
                m_val_tmp[0] =  9'b100000000;
            end
            else
                m_val_tmp[0] = 8'b00000001;

            if (n_mode_val[0] != "bypass")
            begin
            if ((n_hi !== n_lo) && (n_mode_val[0] != "   odd"))
            begin
                    reconfig_err = 1;
                    $display ("Warning : The N counter of the %s Fast PLL should be configured for 50%% duty cycle only. In this case the HIGH and LOW moduli programmed will result in a duty cycle other than 50%%, which is illegal. Reconfiguration may not work", family_name);
                    $display ("Time: %0t  Instance: %m", $time);
            end
            else if (n_hi !== 8'b00000000)
            begin
                    // counter value
                    n_val[0] = n_hi + n_lo;
            end
            else
                n_val[0] =  9'b100000000;
            end
            else
                n_val[0] = 8'b00000001;



// TODO : Give warnings/errors in the following cases?
// 1. Illegal counter values (error)
// 2. Change of mode (warning)
// 3. Only 50% duty cycle allowed for M counter (odd mode - hi-lo=1,even - hi-lo=0)

        end
    end

    // Self reset on loss of lock
    assign reset_self = (l_self_reset_on_loss_lock == "on") ? ~pll_is_locked : 1'b0;

    always @(posedge reset_self)
    begin
        $display (" Note : %s PLL self reset due to loss of lock", family_name);
        $display ("Time: %0t  Instance: %m", $time);
    end

    // Phase shift on /o counters

    always @(schedule_vco or areset)
    begin
        sched_time = 0;

        for (i = 0; i <= 7; i=i+1)
            last_phase_shift[i] = phase_shift[i];

        cycle_to_adjust = 0;
        l_index = 1;
        m_times_vco_period = new_m_times_vco_period;

        // give appropriate messages
        // if areset was asserted
        if (areset === 1'b1 && areset_last_value !== areset)
        begin
            $display (" Note : %s PLL was reset", family_name);
            $display ("Time: %0t  Instance: %m", $time);
            // reset lock parameters
            pll_is_locked = 0;
            cycles_to_lock = 0;
            cycles_to_unlock = 0;
            tap0_is_active = 0;
            phase_adjust_was_scheduled = 0;
            for (x = 0; x <= 7; x=x+1)
                vco_tap[x] <= 1'b0;
        end

        // illegal value on areset
        if (areset === 1'b0 /* converted x or z to 1'b0 */ && (areset_last_value === 1'b0 || areset_last_value === 1'b1))
        begin
            $display("Warning : Illegal value 'X' detected on ARESET input");
            $display ("Time: %0t  Instance: %m", $time);
        end

        if ((areset == 1'b1))
        begin
            pll_is_in_reset = 1;
            got_first_refclk = 0;
            got_second_refclk = 0;
        end

        if ((schedule_vco !== schedule_vco_last_value) && (areset == 1'b1 || stop_vco == 1'b1))
        begin

            // drop VCO taps to 0
            for (i = 0; i <= 7; i=i+1)
            begin
                for (j = 0; j <= last_phase_shift[i] + 1; j=j+1)
                    vco_out[i] <= #(j) 1'b0;
                phase_shift[i] = 0;
                last_phase_shift[i] = 0;
            end

            // reset lock parameters
            pll_is_locked = 0;
            cycles_to_lock = 0;
            cycles_to_unlock = 0;

            got_first_refclk = 0;
            got_second_refclk = 0;
            refclk_time = 0;
            got_first_fbclk = 0;
            fbclk_time = 0;
            first_fbclk_time = 0;
            fbclk_period = 0;

            first_schedule = 1;
            vco_val = 0;
            vco_period_was_phase_adjusted = 0;
            phase_adjust_was_scheduled = 0;

            // reset all counter phase tap values to POF programmed values
            m_ph_val = m_ph_val_orig;
            for (i=0; i<= 5; i=i+1)
                c_ph_val[i] = c_ph_val_orig[i];

        end else if (areset === 1'b0 && stop_vco === 1'b0)
        begin
            // else note areset deassert time
            // note it as refclk_time to prevent false triggering
            // of stop_vco after areset
            if (areset === 1'b0 && areset_last_value === 1'b1 && pll_is_in_reset === 1'b1)
            begin
                refclk_time = $time;
                locked_tmp = 1'b0;
            end
            pll_is_in_reset = 0;

            // calculate loop_xplier : this will be different from m_val in ext. fbk mode
            loop_xplier = m_val[0];
            loop_initial = i_m_initial - 1;
            loop_ph = m_ph_val;

            // convert initial value to delay
            initial_delay = (loop_initial * m_times_vco_period)/loop_xplier;

            // convert loop ph_tap to delay
            rem = m_times_vco_period % loop_xplier;
            vco_per = m_times_vco_period/loop_xplier;
            if (rem != 0)
                vco_per = vco_per + 1;
            fbk_phase = (loop_ph * vco_per)/8;

            pull_back_M = initial_delay + fbk_phase;

            total_pull_back = pull_back_M;
            if (l_simulation_type == "timing")
                total_pull_back = total_pull_back + pll_compensation_delay;

            while (total_pull_back > refclk_period)
                total_pull_back = total_pull_back - refclk_period;

            if (total_pull_back > 0)
                offset = refclk_period - total_pull_back;
            else
                offset = 0;

            fbk_delay = total_pull_back - fbk_phase;
            if (fbk_delay < 0)
            begin
                offset = offset - fbk_phase;
                fbk_delay = total_pull_back;
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

                    // schedule taps with appropriate phase shifts
                    for (k = 0; k <= 7; k=k+1)
                    begin
                        phase_shift[k] = (k*tmp_vco_per)/8;
                        if (first_schedule)
                            vco_out[k] <= #(sched_time + phase_shift[k]) vco_val;
                        else
                            vco_out[k] <= #(sched_time + last_phase_shift[k]) vco_val;
                    end
                end
            end
            if (first_schedule)
            begin
                vco_val = ~vco_val;
                if (vco_val == 1'b0)
                    sched_time = sched_time + high_time;
                else
                    sched_time = sched_time + low_time;
                for (k = 0; k <= 7; k=k+1)
                begin
                    phase_shift[k] = (k*tmp_vco_per)/8;
                    vco_out[k] <= #(sched_time+phase_shift[k]) vco_val;
                end
                first_schedule = 0;
            end

            schedule_vco <= #(sched_time) ~schedule_vco;
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

        areset_last_value = areset;
        schedule_vco_last_value = schedule_vco;

    end

    assign pfdena_wire = (pfdena === 1'b0) ? 1'b0 : 1'b1;
    // PFD enable
    always @(pfdena_wire)
    begin
        if (pfdena_wire === 1'b0)
        begin
            if (pll_is_locked)
                locked_tmp = 1'b0 /* converted x or z to 1'b0 */;
            pll_is_locked = 0;
            cycles_to_lock = 0;
            $display (" Note : PFDENA was deasserted");
            $display ("Time: %0t  Instance: %m", $time);
        end
        else if (pfdena_wire === 1'b1 && pfdena_last_value === 1'b0)
        begin
            // PFD was disabled, now enabled again
            got_first_refclk = 0;
            got_second_refclk = 0;
            refclk_time = $time;
        end
        pfdena_last_value = pfdena_wire;
    end

    always @(negedge refclk or negedge fbclk)
    begin
        refclk_last_value = refclk;
        fbclk_last_value = fbclk;
    end

    // Bypass lock detect

    always @(posedge refclk)
    begin
    if (test_bypass_lock_detect == "on")
        begin
            if (pfdena_wire === 1'b1)
            begin
                    cycles_pfd_low = 0;
                    if (pfd_locked == 1'b0)
                    begin
                    if (cycles_pfd_high == lock_high)
                    begin
                        $display ("Note : %s PLL locked in test mode on PFD enable assert", family_name);
                        $display ("Time: %0t  Instance: %m", $time);
                        pfd_locked <= 1'b1;
                    end
                    cycles_pfd_high = cycles_pfd_high + 1;
                        end
                end
            if (pfdena_wire === 1'b0)
            begin
                    cycles_pfd_high = 0;
                    if (pfd_locked == 1'b1)
                    begin
                    if (cycles_pfd_low == lock_low)
                    begin
                        $display ("Note : %s PLL lost lock in test mode on PFD enable deassert", family_name);
                        $display ("Time: %0t  Instance: %m", $time);
                        pfd_locked <= 1'b0;
                    end
                    cycles_pfd_low = cycles_pfd_low + 1;
                        end
                end
        end
    end

    always @(posedge scandone_tmp or posedge locked_tmp)
    begin
        if(scandone_tmp == 1)
            pll_has_just_been_reconfigured <= 1;
        else
            pll_has_just_been_reconfigured <= 0;
    end

    // VCO Frequency Range check
    always @(posedge refclk or posedge fbclk)
    begin
        if (refclk == 1'b1 && refclk_last_value !== refclk && areset === 1'b0)
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
                if ((i_vco_max != 0 && i_vco_min != 0) && (pfdena_wire === 1'b1) &&
                    ((refclk_period/loop_xplier > i_vco_max) ||
                    (refclk_period/loop_xplier < i_vco_min)) )
                begin
                    if (pll_is_locked == 1'b1)
                    begin
                        if (refclk_period/loop_xplier > i_vco_max)
                        begin
                            $display ("Warning : Input clock freq. is over VCO range. %s PLL may lose lock", family_name);
                            vco_over = 1'b1;
                        end
                        if (refclk_period/loop_xplier < i_vco_min)
                        begin
                            $display ("Warning : Input clock freq. is under VCO range. %s PLL may lose lock", family_name);
                            vco_under = 1'b1;
                        end

                        $display ("Time: %0t  Instance: %m", $time);
                        if (inclk_out_of_range === 1'b1)
                        begin
                            // unlock
                            pll_is_locked = 0;
                            locked_tmp = 0;
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
                            if (refclk_period/loop_xplier > i_vco_max)
                            begin
                                $display ("Warning : Input clock freq. is over VCO range. %s PLL may lose lock", family_name);
                                vco_over = 1'b1;
                            end
                            if (refclk_period/loop_xplier < i_vco_min)
                            begin
                                $display ("Warning : Input clock freq. is under VCO range. %s PLL may lose lock", family_name);
                                vco_under = 1'b1;
                            end
                            $display ("Time: %0t  Instance: %m", $time);
                            no_warn = 1'b1;
                        end
                    end
                    inclk_out_of_range = 1;
                end
                else begin
                    vco_over  = 1'b0;
                    vco_under = 1'b0;
                    inclk_out_of_range = 0;
                    no_warn = 1'b0;
                end

            end
            if (stop_vco == 1'b1)
            begin
                stop_vco = 0;
                schedule_vco = ~schedule_vco;
            end
            refclk_time = $time;
        end

        // Update M counter value on feedback clock edge

        if (fbclk == 1'b1 && fbclk_last_value !== fbclk)
        begin
            if (update_conf_latches === 1'b1)
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
            if ( ( ($time - refclk_time > 1.5 * refclk_period) && pfdena_wire === 1'b1 && pll_is_locked === 1'b1) ||
                ( ($time - refclk_time > 5 * refclk_period) && (pfdena_wire === 1'b1) && (pll_has_just_been_reconfigured == 0) ) ||
                ( ($time - refclk_time > 50 * refclk_period) && (pfdena_wire === 1'b1) && (pll_has_just_been_reconfigured == 1) ) )
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
                    $display ("Note : %s PLL lost lock due to loss of input clock or the input clock is not detected within the allowed time frame.", family_name);
                    if ((i_vco_max == 0) && (i_vco_min == 0))
                        $display ("Note : Please run timing simulation to check whether the input clock is operating within the supported VCO range or not.");
                    $display ("Time: %0t  Instance: %m", $time);
                end
                cycles_to_lock = 0;
                cycles_to_unlock = 0;
                first_schedule = 1;
                vco_period_was_phase_adjusted = 0;
                phase_adjust_was_scheduled = 0;
                tap0_is_active = 0;
                for (x = 0; x <= 7; x=x+1)
                    vco_tap[x] <= 1'b0;
            end
            fbclk_time = $time;
        end


        // Core lock functionality

        if (got_second_refclk && pfdena_wire === 1'b1 && (!inclk_out_of_range))
        begin
            // now we know actual incoming period
            if (abs(fbclk_time - refclk_time) <= lock_window || (got_first_fbclk && abs(refclk_period - abs(fbclk_time - refclk_time)) <= lock_window))
            begin
                // considered in phase
                if (cycles_to_lock == real_lock_high)
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
                if (!(abs(refclk_period - abs(fbclk_time - refclk_time)) <= lock_window))
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
                    if (cycles_to_unlock == lock_low)
                    begin
                        pll_is_locked = 0;
                        locked_tmp = 0;
                        cycles_to_lock = 0;
                        $display ("Note : %s PLL lost lock", family_name);
                        $display ("Time: %0t  Instance: %m", $time);
                        vco_period_was_phase_adjusted = 0;
                        phase_adjust_was_scheduled = 0;
                        got_first_refclk = 0;
                        got_first_fbclk = 0;
                        got_second_refclk = 0;
                    end
                end
                if (abs(refclk_period - fbclk_period) <= 2)
                begin
                    // frequency is still good
                    if ($time == fbclk_time && (!phase_adjust_was_scheduled))
                    begin
                        if (abs(fbclk_time - refclk_time) > refclk_period/2)
                        begin
                            new_m_times_vco_period = abs(m_times_vco_period + (refclk_period - abs(fbclk_time - refclk_time)));
                            vco_period_was_phase_adjusted = 1;
                        end else
                        begin
                            new_m_times_vco_period = abs(m_times_vco_period - abs(fbclk_time - refclk_time));
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

    assign clk_tmp[0] = i_clk0_counter == "c0" ? c0_clk : i_clk0_counter == "c1" ? c1_clk : i_clk0_counter == "c2" ? c2_clk : i_clk0_counter == "c3" ? c3_clk : i_clk0_counter == "c4" ? c4_clk : i_clk0_counter == "c5" ? c5_clk : i_clk0_counter == "c6" ? c6_clk : i_clk0_counter == "c7" ? c7_clk : i_clk0_counter == "c8" ? c8_clk : i_clk0_counter == "c9" ? c9_clk : 1'b0;
    assign clk_tmp[1] = i_clk1_counter == "c0" ? c0_clk : i_clk1_counter == "c1" ? c1_clk : i_clk1_counter == "c2" ? c2_clk : i_clk1_counter == "c3" ? c3_clk : i_clk1_counter == "c4" ? c4_clk : i_clk1_counter == "c5" ? c5_clk : i_clk1_counter == "c6" ? c6_clk : i_clk1_counter == "c7" ? c7_clk : i_clk1_counter == "c8" ? c8_clk : i_clk1_counter == "c9" ? c9_clk : 1'b0;
    assign clk_tmp[2] = i_clk2_counter == "c0" ? c0_clk : i_clk2_counter == "c1" ? c1_clk : i_clk2_counter == "c2" ? c2_clk : i_clk2_counter == "c3" ? c3_clk : i_clk2_counter == "c4" ? c4_clk : i_clk2_counter == "c5" ? c5_clk : i_clk2_counter == "c6" ? c6_clk : i_clk2_counter == "c7" ? c7_clk : i_clk2_counter == "c8" ? c8_clk : i_clk2_counter == "c9" ? c9_clk : 1'b0;
    assign clk_tmp[3] = i_clk3_counter == "c0" ? c0_clk : i_clk3_counter == "c1" ? c1_clk : i_clk3_counter == "c2" ? c2_clk : i_clk3_counter == "c3" ? c3_clk : i_clk3_counter == "c4" ? c4_clk : i_clk3_counter == "c5" ? c5_clk : i_clk3_counter == "c6" ? c6_clk : i_clk3_counter == "c7" ? c7_clk : i_clk3_counter == "c8" ? c8_clk : i_clk3_counter == "c9" ? c9_clk : 1'b0;
    assign clk_tmp[4] = i_clk4_counter == "c0" ? c0_clk : i_clk4_counter == "c1" ? c1_clk : i_clk4_counter == "c2" ? c2_clk : i_clk4_counter == "c3" ? c3_clk : i_clk4_counter == "c4" ? c4_clk : i_clk4_counter == "c5" ? c5_clk : i_clk4_counter == "c6" ? c6_clk : i_clk4_counter == "c7" ? c7_clk : i_clk4_counter == "c8" ? c8_clk : i_clk4_counter == "c9" ? c9_clk : 1'b0;
    assign clk_tmp[5] = i_clk5_counter == "c0" ? c0_clk : i_clk5_counter == "c1" ? c1_clk : i_clk5_counter == "c2" ? c2_clk : i_clk5_counter == "c3" ? c3_clk : i_clk5_counter == "c4" ? c4_clk : i_clk5_counter == "c5" ? c5_clk : i_clk5_counter == "c6" ? c6_clk : i_clk5_counter == "c7" ? c7_clk : i_clk5_counter == "c8" ? c8_clk : i_clk5_counter == "c9" ? c9_clk : 1'b0;
    assign clk_tmp[6] = i_clk6_counter == "c0" ? c0_clk : i_clk6_counter == "c1" ? c1_clk : i_clk6_counter == "c2" ? c2_clk : i_clk6_counter == "c3" ? c3_clk : i_clk6_counter == "c4" ? c4_clk : i_clk6_counter == "c5" ? c5_clk : i_clk6_counter == "c6" ? c6_clk : i_clk6_counter == "c7" ? c7_clk : i_clk6_counter == "c8" ? c8_clk : i_clk6_counter == "c9" ? c9_clk : 1'b0;
    assign clk_tmp[7] = i_clk7_counter == "c0" ? c0_clk : i_clk7_counter == "c1" ? c1_clk : i_clk7_counter == "c2" ? c2_clk : i_clk7_counter == "c3" ? c3_clk : i_clk7_counter == "c4" ? c4_clk : i_clk7_counter == "c5" ? c5_clk : i_clk7_counter == "c6" ? c6_clk : i_clk7_counter == "c7" ? c7_clk : i_clk7_counter == "c8" ? c8_clk : i_clk7_counter == "c9" ? c9_clk : 1'b0;
    assign clk_tmp[8] = i_clk8_counter == "c0" ? c0_clk : i_clk8_counter == "c1" ? c1_clk : i_clk8_counter == "c2" ? c2_clk : i_clk8_counter == "c3" ? c3_clk : i_clk8_counter == "c4" ? c4_clk : i_clk8_counter == "c5" ? c5_clk : i_clk8_counter == "c6" ? c6_clk : i_clk8_counter == "c7" ? c7_clk : i_clk8_counter == "c8" ? c8_clk : i_clk8_counter == "c9" ? c9_clk : 1'b0;
    assign clk_tmp[9] = i_clk9_counter == "c0" ? c0_clk : i_clk9_counter == "c1" ? c1_clk : i_clk9_counter == "c2" ? c2_clk : i_clk9_counter == "c3" ? c3_clk : i_clk9_counter == "c4" ? c4_clk : i_clk9_counter == "c5" ? c5_clk : i_clk9_counter == "c6" ? c6_clk : i_clk9_counter == "c7" ? c7_clk : i_clk9_counter == "c8" ? c8_clk : i_clk9_counter == "c9" ? c9_clk : 1'b0;

assign clk_out_pfd[0] = (pfd_locked == 1'b1) ? clk_tmp[0] : 1'b0 /* converted x or z to 1'b0 */;
assign clk_out_pfd[1] = (pfd_locked == 1'b1) ? clk_tmp[1] : 1'b0 /* converted x or z to 1'b0 */;
assign clk_out_pfd[2] = (pfd_locked == 1'b1) ? clk_tmp[2] : 1'b0 /* converted x or z to 1'b0 */;
assign clk_out_pfd[3] = (pfd_locked == 1'b1) ? clk_tmp[3] : 1'b0 /* converted x or z to 1'b0 */;
assign clk_out_pfd[4] = (pfd_locked == 1'b1) ? clk_tmp[4] : 1'b0 /* converted x or z to 1'b0 */;
    assign clk_out_pfd[5] = (pfd_locked == 1'b1) ? clk_tmp[5] : 1'b0 /* converted x or z to 1'b0 */;
    assign clk_out_pfd[6] = (pfd_locked == 1'b1) ? clk_tmp[6] : 1'b0 /* converted x or z to 1'b0 */;
    assign clk_out_pfd[7] = (pfd_locked == 1'b1) ? clk_tmp[7] : 1'b0 /* converted x or z to 1'b0 */;
    assign clk_out_pfd[8] = (pfd_locked == 1'b1) ? clk_tmp[8] : 1'b0 /* converted x or z to 1'b0 */;
    assign clk_out_pfd[9] = (pfd_locked == 1'b1) ? clk_tmp[9] : 1'b0 /* converted x or z to 1'b0 */;

    assign clk_out[0] = (test_bypass_lock_detect == "on") ? clk_out_pfd[0] : ((areset === 1'b1 || pll_in_test_mode === 1'b1) || (locked == 1'b1 && !reconfig_err) ? clk_tmp[0] : 1'b0 /* converted x or z to 1'b0 */);
    assign clk_out[1] = (test_bypass_lock_detect == "on") ? clk_out_pfd[1] : ((areset === 1'b1 || pll_in_test_mode === 1'b1) || (locked == 1'b1 && !reconfig_err) ? clk_tmp[1] : 1'b0 /* converted x or z to 1'b0 */);
    assign clk_out[2] = (test_bypass_lock_detect == "on") ? clk_out_pfd[2] : ((areset === 1'b1 || pll_in_test_mode === 1'b1) || (locked == 1'b1 && !reconfig_err) ? clk_tmp[2] : 1'b0 /* converted x or z to 1'b0 */);
    assign clk_out[3] = (test_bypass_lock_detect == "on") ? clk_out_pfd[3] : ((areset === 1'b1 || pll_in_test_mode === 1'b1) || (locked == 1'b1 && !reconfig_err) ? clk_tmp[3] : 1'b0 /* converted x or z to 1'b0 */);
    assign clk_out[4] = (test_bypass_lock_detect == "on") ? clk_out_pfd[4] : ((areset === 1'b1 || pll_in_test_mode === 1'b1) || (locked == 1'b1 && !reconfig_err) ? clk_tmp[4] : 1'b0 /* converted x or z to 1'b0 */);
    assign clk_out[5] = (test_bypass_lock_detect == "on") ? clk_out_pfd[5] : ((areset === 1'b1 || pll_in_test_mode === 1'b1) || (locked == 1'b1 && !reconfig_err) ? clk_tmp[5] : 1'b0 /* converted x or z to 1'b0 */);
    assign clk_out[6] = (test_bypass_lock_detect == "on") ? clk_out_pfd[6] : ((areset === 1'b1 || pll_in_test_mode === 1'b1) || (locked == 1'b1 && !reconfig_err) ? clk_tmp[6] : 1'b0 /* converted x or z to 1'b0 */);
    assign clk_out[7] = (test_bypass_lock_detect == "on") ? clk_out_pfd[7] : ((areset === 1'b1 || pll_in_test_mode === 1'b1) || (locked == 1'b1 && !reconfig_err) ? clk_tmp[7] : 1'b0 /* converted x or z to 1'b0 */);
    assign clk_out[8] = (test_bypass_lock_detect == "on") ? clk_out_pfd[8] : ((areset === 1'b1 || pll_in_test_mode === 1'b1) || (locked == 1'b1 && !reconfig_err) ? clk_tmp[8] : 1'b0 /* converted x or z to 1'b0 */);
    assign clk_out[9] = (test_bypass_lock_detect == "on") ? clk_out_pfd[9] : ((areset === 1'b1 || pll_in_test_mode === 1'b1) || (locked == 1'b1 && !reconfig_err) ? clk_tmp[9] : 1'b0 /* converted x or z to 1'b0 */);

    // ACCELERATE OUTPUTS
    and (clk[0], 1'b1, clk_out[0]);
    and (clk[1], 1'b1, clk_out[1]);
    and (clk[2], 1'b1, clk_out[2]);
    and (clk[3], 1'b1, clk_out[3]);
    and (clk[4], 1'b1, clk_out[4]);
    and (clk[5], 1'b1, clk_out[5]);
    and (clk[6], 1'b1, clk_out[6]);
    and (clk[7], 1'b1, clk_out[7]);
    and (clk[8], 1'b1, clk_out[8]);
    and (clk[9], 1'b1, clk_out[9]);

    and (scandataout, 1'b1, scandata_out);
    and (scandone, 1'b1, scandone_tmp);

assign fbout = fbclk;
assign vcooverrange  = (vco_range_detector_high_bits == -1) ? 1'b0 /* converted x or z to 1'b0 */ : vco_over;
assign vcounderrange = (vco_range_detector_low_bits == -1) ? 1'b0 /* converted x or z to 1'b0 */ :vco_under;
assign phasedone = ~update_phase;

endmodule // MF_stratixiii_pll

