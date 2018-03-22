// Created by altera_lib_mf.pl from altera_mf.v

// START MODULE NAME -----------------------------------------------------------
//
// Module Name : ALTPLL
//
// Description : Phase-Locked Loop (PLL) behavioral model. Model supports basic
//               PLL features such as clock division and multiplication,
//               programmable duty cycle and phase shifts, various feedback modes
//               and clock delays. Also supports real-time reconfiguration of
//               PLL "parameters" and clock switchover between the 2 input
//               reference clocks. Up to 10 clock outputs may be used.
//
// Limitations : Applicable to Stratix, Stratix-GX, Stratix II and Cyclone II device families only
//               There is no support in the model for spread-spectrum feature
//
// Expected results : Up to 10 output clocks, each defined by its own set of
//                    parameters. Locked output (active high) indicates when the
//                    PLL locks. clkbad, clkloss and activeclock are used for
//                    clock switchover to inidicate which input clock has gone
//                    bad, when the clock switchover initiates and which input
//                    clock is being used as the reference, respectively.
//                    scandataout is the data output of the serial scan chain.

//END MODULE NAME --------------------------------------------------------------

`timescale 1 ps / 1ps
`define STR_LENGTH 18

// MODULE DECLARATION
/*verilator lint_off CASEX*/
/*verilator lint_off COMBDLY*/
/*verilator lint_off INITIALDLY*/
/*verilator lint_off LITENDIAN*/
/*verilator lint_off MULTIDRIVEN*/
/*verilator lint_off UNOPTFLAT*/
/*verilator lint_off BLKANDNBLK*/
module altpll (
    inclk,      // input reference clock - up to 2 can be used
    fbin,       // external feedback input port
    pllena,     // PLL enable signal
    clkswitch,  // switch between inclk0 and inclk1
    areset,     // asynchronous reset
    pfdena,     // enable the Phase Frequency Detector (PFD)
    clkena,     // enable clk0 to clk5 clock outputs
    extclkena,  // enable extclk0 to extclk3 clock outputs
    scanclk,    // clock for the serial scan chain
    scanaclr,   // asynchronous clear the serial scan chain
    scanclkena,
    scanread,   // determines when the scan chain can read in data from the scandata port
    scanwrite,  // determines when the scan chain can write out data into pll
    scandata,    // data for the scan chain
    phasecounterselect,
    phaseupdown,
    phasestep,
    configupdate,
    fbmimicbidir,
    clk,         // internal clock outputs (feeds the core)
    extclk,      // external clock outputs (feeds pins)
    clkbad,      // indicates if inclk0/inclk1 has gone bad
    enable0,     // load enable pulse 0 for lvds
    enable1,     // load enable pulse l for lvds
    activeclock, // indicates which input clock is being used
    clkloss,     // indicates when clock switchover initiates
    locked,      // indicates when the PLL locks onto the input clock
    scandataout, // data output of the serial scan chain
    scandone,    // indicates when pll reconfiguration is complete
    sclkout0,    // serial clock output 0 for lvds
    sclkout1,     // serial clock output 1 for lvds
    phasedone,
    vcooverrange,
    vcounderrange,
    fbout,
    fref,
    icdrclk
);

// GLOBAL PARAMETER DECLARATION
parameter   intended_device_family    = "Stratix" ;
parameter   operation_mode            = "NORMAL" ;
parameter   pll_type                  = "AUTO" ;
parameter   qualify_conf_done         = "OFF" ;
parameter   compensate_clock          = "CLK0" ;
parameter   scan_chain                = "LONG";
parameter   primary_clock             = "inclk0";
parameter   inclk0_input_frequency    = 1000;
parameter   inclk1_input_frequency    = 0;
parameter   gate_lock_signal          = "NO";
parameter   gate_lock_counter         = 0;
parameter   lock_high                 = 1;
parameter   lock_low                  = 0;
parameter   valid_lock_multiplier     = 1;
parameter   invalid_lock_multiplier   = 5;
parameter   switch_over_type          = "AUTO";
parameter   switch_over_on_lossclk    = "OFF" ;
parameter   switch_over_on_gated_lock = "OFF" ;
parameter   enable_switch_over_counter = "OFF";
parameter   switch_over_counter       = 0;
parameter   feedback_source           = "EXTCLK0" ;
parameter   bandwidth                 = 0;
parameter   bandwidth_type            = "UNUSED";
parameter   lpm_hint                  = "UNUSED";
parameter   spread_frequency          = 0;
parameter   down_spread               = "0.0";
parameter   self_reset_on_gated_loss_lock = "OFF";
parameter   self_reset_on_loss_lock = "OFF";
parameter   lock_window_ui           = "0.05";
parameter   width_clock              = 6;
parameter   width_phasecounterselect = 4;
parameter charge_pump_current_bits = 9999;
parameter loop_filter_c_bits = 9999;
parameter loop_filter_r_bits = 9999;
parameter scan_chain_mif_file = "UNUSED";

// SIMULATION_ONLY_PARAMETERS_BEGIN

parameter   simulation_type           = "functional";
parameter   source_is_pll             = "off";

// SIMULATION_ONLY_PARAMETERS_END

parameter   skip_vco                    = "off";

//  internal clock specifications
parameter   clk9_multiply_by        = 1;
parameter   clk8_multiply_by        = 1;
parameter   clk7_multiply_by        = 1;
parameter   clk6_multiply_by        = 1;
parameter   clk5_multiply_by        = 1;
parameter   clk4_multiply_by        = 1;
parameter   clk3_multiply_by        = 1;
parameter   clk2_multiply_by        = 1;
parameter   clk1_multiply_by        = 1;
parameter   clk0_multiply_by        = 1;
parameter   clk9_divide_by          = 1;
parameter   clk8_divide_by          = 1;
parameter   clk7_divide_by          = 1;
parameter   clk6_divide_by          = 1;
parameter   clk5_divide_by          = 1;
parameter   clk4_divide_by          = 1;
parameter   clk3_divide_by          = 1;
parameter   clk2_divide_by          = 1;
parameter   clk1_divide_by          = 1;
parameter   clk0_divide_by          = 1;
parameter   clk9_phase_shift        = "0";
parameter   clk8_phase_shift        = "0";
parameter   clk7_phase_shift        = "0";
parameter   clk6_phase_shift        = "0";
parameter   clk5_phase_shift        = "0";
parameter   clk4_phase_shift        = "0";
parameter   clk3_phase_shift        = "0";
parameter   clk2_phase_shift        = "0";
parameter   clk1_phase_shift        = "0";
parameter   clk0_phase_shift        = "0";

parameter   clk5_time_delay         = "0";  // For stratix pll use only
parameter   clk4_time_delay         = "0";  // For stratix pll use only
parameter   clk3_time_delay         = "0";  // For stratix pll use only
parameter   clk2_time_delay         = "0";  // For stratix pll use only
parameter   clk1_time_delay         = "0";  // For stratix pll use only
parameter   clk0_time_delay         = "0";  // For stratix pll use only
parameter   clk9_duty_cycle         = 50;
parameter   clk8_duty_cycle         = 50;
parameter   clk7_duty_cycle         = 50;
parameter   clk6_duty_cycle         = 50;
parameter   clk5_duty_cycle         = 50;
parameter   clk4_duty_cycle         = 50;
parameter   clk3_duty_cycle         = 50;
parameter   clk2_duty_cycle         = 50;
parameter   clk1_duty_cycle         = 50;
parameter   clk0_duty_cycle         = 50;

parameter   clk9_use_even_counter_mode    = "OFF";
parameter   clk8_use_even_counter_mode    = "OFF";
parameter   clk7_use_even_counter_mode    = "OFF";
parameter   clk6_use_even_counter_mode    = "OFF";
parameter   clk5_use_even_counter_mode    = "OFF";
parameter   clk4_use_even_counter_mode    = "OFF";
parameter   clk3_use_even_counter_mode    = "OFF";
parameter   clk2_use_even_counter_mode    = "OFF";
parameter   clk1_use_even_counter_mode    = "OFF";
parameter   clk0_use_even_counter_mode    = "OFF";
parameter   clk9_use_even_counter_value   = "OFF";
parameter   clk8_use_even_counter_value   = "OFF";
parameter   clk7_use_even_counter_value   = "OFF";
parameter   clk6_use_even_counter_value   = "OFF";
parameter   clk5_use_even_counter_value   = "OFF";
parameter   clk4_use_even_counter_value   = "OFF";
parameter   clk3_use_even_counter_value   = "OFF";
parameter   clk2_use_even_counter_value   = "OFF";
parameter   clk1_use_even_counter_value   = "OFF";
parameter   clk0_use_even_counter_value   = "OFF";

parameter   clk2_output_frequency   = 0;
parameter   clk1_output_frequency   = 0;
parameter   clk0_output_frequency   = 0;

//  external clock specifications (for stratix pll use only)
parameter   extclk3_multiply_by     = 1;
parameter   extclk2_multiply_by     = 1;
parameter   extclk1_multiply_by     = 1;
parameter   extclk0_multiply_by     = 1;
parameter   extclk3_divide_by       = 1;
parameter   extclk2_divide_by       = 1;
parameter   extclk1_divide_by       = 1;
parameter   extclk0_divide_by       = 1;
parameter   extclk3_phase_shift     = "0";
parameter   extclk2_phase_shift     = "0";
parameter   extclk1_phase_shift     = "0";
parameter   extclk0_phase_shift     = "0";
parameter   extclk3_time_delay      = "0";
parameter   extclk2_time_delay      = "0";
parameter   extclk1_time_delay      = "0";
parameter   extclk0_time_delay      = "0";
parameter   extclk3_duty_cycle      = 50;
parameter   extclk2_duty_cycle      = 50;
parameter   extclk1_duty_cycle      = 50;
parameter   extclk0_duty_cycle      = 50;

// The following 4 parameters are for Stratix II pll in lvds mode only
parameter vco_multiply_by = 0;
parameter vco_divide_by = 0;
parameter sclkout0_phase_shift = "0";
parameter sclkout1_phase_shift = "0";

parameter dpa_multiply_by = 0;
parameter dpa_divide_by = 0;
parameter dpa_divider = 0;

//  advanced user parameters
parameter   vco_min             = 0;
parameter   vco_max             = 0;
parameter   vco_center          = 0;
parameter   pfd_min             = 0;
parameter   pfd_max             = 0;
parameter   m_initial           = 1;
parameter   m                   = 0; // m must default to 0 in order for altpll to calculate advanced parameters for itself
parameter   n                   = 1;
parameter   m2                  = 1;
parameter   n2                  = 1;
parameter   ss                  = 0;
parameter   l0_high             = 1;
parameter   l1_high             = 1;
parameter   g0_high             = 1;
parameter   g1_high             = 1;
parameter   g2_high             = 1;
parameter   g3_high             = 1;
parameter   e0_high             = 1;
parameter   e1_high             = 1;
parameter   e2_high             = 1;
parameter   e3_high             = 1;
parameter   l0_low              = 1;
parameter   l1_low              = 1;
parameter   g0_low              = 1;
parameter   g1_low              = 1;
parameter   g2_low              = 1;
parameter   g3_low              = 1;
parameter   e0_low              = 1;
parameter   e1_low              = 1;
parameter   e2_low              = 1;
parameter   e3_low              = 1;
parameter   l0_initial          = 1;
parameter   l1_initial          = 1;
parameter   g0_initial          = 1;
parameter   g1_initial          = 1;
parameter   g2_initial          = 1;
parameter   g3_initial          = 1;
parameter   e0_initial          = 1;
parameter   e1_initial          = 1;
parameter   e2_initial          = 1;
parameter   e3_initial          = 1;
parameter   l0_mode             = "bypass";
parameter   l1_mode             = "bypass";
parameter   g0_mode             = "bypass";
parameter   g1_mode             = "bypass";
parameter   g2_mode             = "bypass";
parameter   g3_mode             = "bypass";
parameter   e0_mode             = "bypass";
parameter   e1_mode             = "bypass";
parameter   e2_mode             = "bypass";
parameter   e3_mode             = "bypass";
parameter   l0_ph               = 0;
parameter   l1_ph               = 0;
parameter   g0_ph               = 0;
parameter   g1_ph               = 0;
parameter   g2_ph               = 0;
parameter   g3_ph               = 0;
parameter   e0_ph               = 0;
parameter   e1_ph               = 0;
parameter   e2_ph               = 0;
parameter   e3_ph               = 0;
parameter   m_ph                = 0;
parameter   l0_time_delay       = 0;
parameter   l1_time_delay       = 0;
parameter   g0_time_delay       = 0;
parameter   g1_time_delay       = 0;
parameter   g2_time_delay       = 0;
parameter   g3_time_delay       = 0;
parameter   e0_time_delay       = 0;
parameter   e1_time_delay       = 0;
parameter   e2_time_delay       = 0;
parameter   e3_time_delay       = 0;
parameter   m_time_delay        = 0;
parameter   n_time_delay        = 0;
parameter   extclk3_counter     = "e3" ;
parameter   extclk2_counter     = "e2" ;
parameter   extclk1_counter     = "e1" ;
parameter   extclk0_counter     = "e0" ;
parameter   clk9_counter        = "c9" ;
parameter   clk8_counter        = "c8" ;
parameter   clk7_counter        = "c7" ;
parameter   clk6_counter        = "c6" ;
parameter   clk5_counter        = "l1" ;
parameter   clk4_counter        = "l0" ;
parameter   clk3_counter        = "g3" ;
parameter   clk2_counter        = "g2" ;
parameter   clk1_counter        = "g1" ;
parameter   clk0_counter        = "g0" ;
parameter   enable0_counter     = "l0";
parameter   enable1_counter     = "l0";
parameter   charge_pump_current = 2;
parameter   loop_filter_r       = "1.0";
parameter   loop_filter_c       = 5;
parameter   vco_post_scale      = 0;
parameter   vco_frequency_control = "AUTO";
parameter   vco_phase_shift_step = 0;
parameter   lpm_type            = "altpll";

// The following parameter are used to define the connectivity for some of the input
// and output ports.
parameter port_clkena0 = "PORT_CONNECTIVITY";
parameter port_clkena1 = "PORT_CONNECTIVITY";
parameter port_clkena2 = "PORT_CONNECTIVITY";
parameter port_clkena3 = "PORT_CONNECTIVITY";
parameter port_clkena4 = "PORT_CONNECTIVITY";
parameter port_clkena5 = "PORT_CONNECTIVITY";
parameter port_extclkena0 = "PORT_CONNECTIVITY";
parameter port_extclkena1 = "PORT_CONNECTIVITY";
parameter port_extclkena2 = "PORT_CONNECTIVITY";
parameter port_extclkena3 = "PORT_CONNECTIVITY";
parameter port_extclk0 = "PORT_CONNECTIVITY";
parameter port_extclk1 = "PORT_CONNECTIVITY";
parameter port_extclk2 = "PORT_CONNECTIVITY";
parameter port_extclk3 = "PORT_CONNECTIVITY";
parameter port_clk0 = "PORT_CONNECTIVITY";
parameter port_clk1 = "PORT_CONNECTIVITY";
parameter port_clk2 = "PORT_CONNECTIVITY";
parameter port_clk3 = "PORT_CONNECTIVITY";
parameter port_clk4 = "PORT_CONNECTIVITY";
parameter port_clk5 = "PORT_CONNECTIVITY";
parameter port_clk6 = "PORT_CONNECTIVITY";
parameter port_clk7 = "PORT_CONNECTIVITY";
parameter port_clk8 = "PORT_CONNECTIVITY";
parameter port_clk9 = "PORT_CONNECTIVITY";
parameter port_scandata = "PORT_CONNECTIVITY";
parameter port_scandataout = "PORT_CONNECTIVITY";
parameter port_scandone = "PORT_CONNECTIVITY";
parameter port_sclkout1 = "PORT_CONNECTIVITY";
parameter port_sclkout0 = "PORT_CONNECTIVITY";
parameter port_clkbad0 = "PORT_CONNECTIVITY";
parameter port_clkbad1 = "PORT_CONNECTIVITY";
parameter port_activeclock = "PORT_CONNECTIVITY";
parameter port_clkloss = "PORT_CONNECTIVITY";
parameter port_inclk1 = "PORT_CONNECTIVITY";
parameter port_inclk0 = "PORT_CONNECTIVITY";
parameter port_fbin = "PORT_CONNECTIVITY";
parameter port_fbout = "PORT_CONNECTIVITY";
parameter port_pllena = "PORT_CONNECTIVITY";
parameter port_clkswitch = "PORT_CONNECTIVITY";
parameter port_areset = "PORT_CONNECTIVITY";
parameter port_pfdena = "PORT_CONNECTIVITY";
parameter port_scanclk = "PORT_CONNECTIVITY";
parameter port_scanaclr = "PORT_CONNECTIVITY";
parameter port_scanread = "PORT_CONNECTIVITY";
parameter port_scanwrite = "PORT_CONNECTIVITY";
parameter port_enable0 = "PORT_CONNECTIVITY";
parameter port_enable1 = "PORT_CONNECTIVITY";
parameter port_locked = "PORT_CONNECTIVITY";
parameter port_configupdate = "PORT_CONNECTIVITY";
parameter port_phasecounterselect = "PORT_CONNECTIVITY";
parameter port_phasedone = "PORT_CONNECTIVITY";
parameter port_phasestep = "PORT_CONNECTIVITY";
parameter port_phaseupdown = "PORT_CONNECTIVITY";
parameter port_vcooverrange = "PORT_CONNECTIVITY";
parameter port_vcounderrange = "PORT_CONNECTIVITY";
parameter port_scanclkena = "PORT_CONNECTIVITY";
parameter using_fbmimicbidir_port = "ON";

//For Stratixii pll use only
parameter   c0_high             = 1;
parameter   c1_high             = 1;
parameter   c2_high             = 1;
parameter   c3_high             = 1;
parameter   c4_high             = 1;
parameter   c5_high             = 1;
parameter   c6_high             = 1;
parameter   c7_high             = 1;
parameter   c8_high             = 1;
parameter   c9_high             = 1;
parameter   c0_low              = 1;
parameter   c1_low              = 1;
parameter   c2_low              = 1;
parameter   c3_low              = 1;
parameter   c4_low              = 1;
parameter   c5_low              = 1;
parameter   c6_low              = 1;
parameter   c7_low              = 1;
parameter   c8_low              = 1;
parameter   c9_low              = 1;
parameter   c0_initial          = 1;
parameter   c1_initial          = 1;
parameter   c2_initial          = 1;
parameter   c3_initial          = 1;
parameter   c4_initial          = 1;
parameter   c5_initial          = 1;
parameter   c6_initial          = 1;
parameter   c7_initial          = 1;
parameter   c8_initial          = 1;
parameter   c9_initial          = 1;
parameter   c0_mode             = "bypass";
parameter   c1_mode             = "bypass";
parameter   c2_mode             = "bypass";
parameter   c3_mode             = "bypass";
parameter   c4_mode             = "bypass";
parameter   c5_mode             = "bypass";
parameter   c6_mode             = "bypass";
parameter   c7_mode             = "bypass";
parameter   c8_mode             = "bypass";
parameter   c9_mode             = "bypass";
parameter   c0_ph               = 0;
parameter   c1_ph               = 0;
parameter   c2_ph               = 0;
parameter   c3_ph               = 0;
parameter   c4_ph               = 0;
parameter   c5_ph               = 0;
parameter   c6_ph               = 0;
parameter   c7_ph               = 0;
parameter   c8_ph               = 0;
parameter   c9_ph               = 0;
parameter   c1_use_casc_in      = "off";
parameter   c2_use_casc_in      = "off";
parameter   c3_use_casc_in      = "off";
parameter   c4_use_casc_in      = "off";
parameter   c5_use_casc_in      = "off";
parameter   c6_use_casc_in      = "off";
parameter   c7_use_casc_in      = "off";
parameter   c8_use_casc_in      = "off";
parameter   c9_use_casc_in      = "off";
parameter   m_test_source       = 5;
parameter   c0_test_source      = 5;
parameter   c1_test_source      = 5;
parameter   c2_test_source      = 5;
parameter   c3_test_source      = 5;
parameter   c4_test_source      = 5;
parameter   c5_test_source      = 5;
parameter   c6_test_source      = 5;
parameter   c7_test_source      = 5;
parameter   c8_test_source      = 5;
parameter   c9_test_source      = 5;
parameter   sim_gate_lock_device_behavior = "OFF";

// INPUT PORT DECLARATION
input       [1:0] inclk;
input       fbin;
input       pllena;
input       clkswitch;
input       areset;
input       pfdena;
input       [5:0] clkena;
input       [3:0] extclkena;
input       scanclk;
input       scanclkena;
input       scanaclr;
input       scanread;
input       scanwrite;
input       scandata;
input       [width_phasecounterselect-1:0] phasecounterselect;
input       phaseupdown;
input       phasestep;
input       configupdate;

// INOUT PORT DECLARATION
inout fbmimicbidir;

// OUTPUT PORT DECLARATION
output        [width_clock-1:0] clk;
output        [3:0] extclk;
output        [1:0] clkbad;
output        activeclock;
output        enable0;
output        enable1;
output        clkloss;
output        locked;
output        scandataout;
output        scandone;
output        sclkout0;
output        sclkout1;
output        phasedone;
output        vcooverrange;
output        vcounderrange;
output        fbout;
output        fref;
output        icdrclk;

// pullups
logic ena_pullup; // -- converted tristate to logic
logic pfdena_pullup; // -- converted tristate to logic
logic [5:0] clkena_pullup; // -- converted tristate to logic
logic [3:0] extclkena_pullup; // -- converted tristate to logic
logic scanclkena_pullup; // -- converted tristate to logic

// pulldowns
logic fbin_pulldown; // -- converted tristate to logic
logic [1:0] inclk_pulldown; // -- converted tristate to logic
logic clkswitch_pulldown; // -- converted tristate to logic
logic areset_pulldown; // -- converted tristate to logic
logic scanclk_pulldown; // -- converted tristate to logic
logic scanclr_pulldown; // -- converted tristate to logic
logic scanread_pulldown; // -- converted tristate to logic
logic scanwrite_pulldown; // -- converted tristate to logic
logic scandata_pulldown; // -- converted tristate to logic
logic comparator_pulldown; // -- converted tristate to logic
logic configupdate_pulldown; // -- converted tristate to logic
logic [3:0] phasecounterselect_pulldown; // -- converted tristate to logic
logic phaseupdown_pulldown; // -- converted tristate to logic
logic phasestep_pulldown; // -- converted tristate to logic

// For fast mode, the stratix pll atom model will give active low signal on locked output.
// Therefore, need to invert the lock signal for fast mode as in user view, locked signal is
// always active high.
wire locked_tmp;
wire pll_lock;
wire [1:0] stratix_inclk;
wire stratix_fbin;
wire stratix_ena;
wire stratix_clkswitch;
wire stratix_areset;
wire stratix_pfdena;
wire [5:0] stratix_clkena;
wire [3:0] stratix_extclkena;
wire stratix_scanclk;
wire stratix_scanclr;
wire stratix_scandata;
wire [5:0] stratix_clk;
wire [3:0] stratix_extclk;
wire [1:0] stratix_clkbad;
wire stratix_activeclock;
wire stratix_locked;
wire stratix_clkloss;
wire stratix_scandataout;
wire stratix_enable0;
wire stratix_enable1;

wire [1:0] stratixii_inclk;
wire stratixii_fbin;
wire stratixii_ena;
wire stratixii_clkswitch;
wire stratixii_areset;
wire stratixii_pfdena;
wire stratixii_scanread;
wire stratixii_scanwrite;
wire stratixii_scanclk;
wire stratixii_scandata;
wire stratixii_scandone;
wire [5:0] stratixii_clk;
wire [1:0] stratixii_clkbad;
wire stratixii_activeclock;
wire stratixii_locked;
wire stratixii_clkloss;
wire stratixii_scandataout;
wire stratixii_enable0;
wire stratixii_enable1;
wire stratixii_sclkout0;
wire stratixii_sclkout1;
wire [1:0] stratix3_inclk;
wire stratix3_clkswitch;
wire stratix3_areset;
wire stratix3_pfdena;
wire stratix3_scanclk;
wire [9:0] stratix3_clk;
wire [1:0] stratix3_clkbad;
wire stratix3_activeclock;
wire stratix3_locked;
wire stratix3_scandataout;
wire stratix3_scandone;
wire stratix3_phasedone;
wire stratix3_vcooverrange;
wire stratix3_vcounderrange;
wire stratix3_fbin;
wire stratix3_fbout;
wire [3:0] stratix3_phasecounterselect;

wire [1:0] cyclone3_inclk;
wire cyclone3_clkswitch;
wire cyclone3_areset;
wire cyclone3_pfdena;
wire cyclone3_scanclk;
wire [4:0] cyclone3_clk;
wire [1:0] cyclone3_clkbad;
wire cyclone3_activeclock;
wire cyclone3_locked;
wire cyclone3_scandataout;
wire cyclone3_scandone;
wire cyclone3_phasedone;
wire cyclone3_vcooverrange;
wire cyclone3_vcounderrange;
wire cyclone3_fbout;
wire [2:0] cyclone3_phasecounterselect;

wire [1:0] cyclone3gl_inclk;
wire cyclone3gl_clkswitch;
wire cyclone3gl_areset;
wire cyclone3gl_pfdena;
wire cyclone3gl_scanclk;
wire [4:0] cyclone3gl_clk;
wire [1:0] cyclone3gl_clkbad;
wire cyclone3gl_activeclock;
wire cyclone3gl_locked;
wire cyclone3gl_scandataout;
wire cyclone3gl_scandone;
wire cyclone3gl_phasedone;
wire cyclone3gl_vcooverrange;
wire cyclone3gl_vcounderrange;
wire cyclone3gl_fbout;
wire [2:0] cyclone3gl_phasecounterselect;
wire cyclone3gl_fref;
wire cyclone3gl_icdrclk;
wire[9:0] clk_wire;
wire[9:0] clk_tmp;
wire[1:0] clkbad_wire;
wire activeclock_wire;
wire clkloss_wire;
wire scandataout_wire;
wire scandone_wire;
wire sclkout0_wire;
wire sclkout1_wire;
wire locked_wire;
wire phasedone_wire;
wire vcooverrange_wire;
wire vcounderrange_wire;
wire fbout_wire;
wire iobuf_io;
wire iobuf_o;

reg pll_lock_sync;

reg family_stratixiii;
reg family_cycloneiii;
reg family_cycloneiiigl;
reg family_base_cycloneii;
reg family_arriaii;
reg family_has_stratix_style_pll;
reg family_has_stratixii_style_pll;

ALTERA_DEVICE_FAMILIES dev ();

// FUNCTION DECLARATION

// convert uppercase parameter values to lowercase
// assumes that the maximum character length of a parameter is 18
function [8*`STR_LENGTH:1] alpha_tolower;
input [8*`STR_LENGTH:1] given_string;

reg [8*`STR_LENGTH:1] return_string;
reg [8*`STR_LENGTH:1] reg_string;
reg [8:1] tmp;
reg [8:1] conv_char;
integer byte_count;
begin
    return_string = "                    "; // initialise strings to spaces
    conv_char = "        ";
    reg_string = given_string;
    for (byte_count = `STR_LENGTH; byte_count >= 1; byte_count = byte_count - 1)
    begin
        tmp = reg_string[8*`STR_LENGTH:(8*(`STR_LENGTH-1)+1)];
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

// INITIAL BLOCK
initial
begin

    // Begin of parameter checking

    if (clk5_multiply_by <= 0)
    begin
        $display("ERROR: The clk5_multiply_by must be greater than 0");
        $display("Time: %0t  Instance: %m", $time);
        $stop;
    end

    if (clk4_multiply_by <= 0)
    begin
        $display("ERROR: The clk4_multiply_by must be greater than 0");
        $display("Time: %0t  Instance: %m", $time);
        $stop;
    end

    if (clk3_multiply_by <= 0)
    begin
        $display("ERROR: The clk3_multiply_by must be greater than 0");
        $display("Time: %0t  Instance: %m", $time);
        $stop;
    end


    if (clk2_multiply_by <= 0)
    begin
        $display("ERROR: The clk2_multiply_by must be greater than 0");
        $display("Time: %0t  Instance: %m", $time);
        $stop;
    end

    if (clk1_multiply_by <= 0)
    begin
        $display("ERROR: The clk1_multiply_by must be greater than 0");
        $display("Time: %0t  Instance: %m", $time);
        $stop;
    end

    if (clk0_multiply_by <= 0)
    begin
        $display("ERROR: The clk0_multiply_by must be greater than 0");
        $display("Time: %0t  Instance: %m", $time);
        $stop;
    end

    if (clk5_divide_by <= 0)
    begin
        $display("ERROR: The clk5_divide_by must be greater than 0");
        $display("Time: %0t  Instance: %m", $time);
        $stop;
    end


    if (clk4_divide_by <= 0)
    begin
        $display("ERROR: The clk4_divide_by must be greater than 0");
        $display("Time: %0t  Instance: %m", $time);
        $stop;
    end


    if (clk3_divide_by <= 0)
    begin
        $display("ERROR: The clk3_divide_by must be greater than 0");
        $display("Time: %0t  Instance: %m", $time);
        $stop;
    end


    if (clk2_divide_by <= 0)
    begin
        $display("ERROR: The clk2_divide_by must be greater than 0");
        $display("Time: %0t  Instance: %m", $time);
        $stop;
    end


    if (clk1_divide_by <= 0)
    begin
        $display("ERROR: The clk1_divide_by must be greater than 0");
        $display("Time: %0t  Instance: %m", $time);
        $stop;
    end


    if (clk0_divide_by <= 0)
    begin
        $display("ERROR: The clk0_divide_by must be greater than 0");
        $display("Time: %0t  Instance: %m", $time);
        $stop;
    end

    if (extclk3_multiply_by <= 0)
    begin
        $display("ERROR: The extclk3_multiply_by must be greater than 0");
        $display("Time: %0t  Instance: %m", $time);
        $stop;
    end

    if (extclk2_multiply_by <= 0)
    begin
        $display("ERROR: The extclk2_multiply_by must be greater than 0");
        $display("Time: %0t  Instance: %m", $time);
        $stop;
    end

    if (extclk1_multiply_by <= 0)
    begin
        $display("ERROR: The extclk1_multiply_by must be greater than 0");
        $display("Time: %0t  Instance: %m", $time);
        $stop;
    end

    if (extclk0_multiply_by <= 0)
    begin
        $display("ERROR: The extclk0_multiply_by must be greater than 0");
        $display("Time: %0t  Instance: %m", $time);
        $stop;
    end


    if (extclk3_divide_by <= 0)
    begin
        $display("ERROR: The extclk3_divide_by must be greater than 0");
        $display("Time: %0t  Instance: %m", $time);
        $stop;
    end


    if (extclk2_divide_by <= 0)
    begin
        $display("ERROR: The extclk2_divide_by must be greater than 0");
        $display("Time: %0t  Instance: %m", $time);
        $stop;
    end


    if (extclk1_divide_by <= 0)
    begin
        $display("ERROR: The extclk1_divide_by must be greater than 0");
        $display("Time: %0t  Instance: %m", $time);
        $stop;
    end


    if (extclk0_divide_by <= 0)
    begin
        $display("ERROR: The extclk0_divide_by must be greater than 0");
        $display("Time: %0t  Instance: %m", $time);
        $stop;
    end

    if (!((primary_clock == "inclk0") || (primary_clock == "INCLK0") ||
        (primary_clock == "inclk1") || (primary_clock == "INCLK1")))
    begin
        $display("ERROR: The primary clock is set to an illegal value");
        $display("Time: %0t  Instance: %m", $time);
        $stop;
    end

    if (dev.IS_VALID_FAMILY(intended_device_family) == 0)
    begin
        $display ("Error! Unknown INTENDED_DEVICE_FAMILY=%s.", intended_device_family);
        $stop;
    end

    family_stratixiii = dev.FEATURE_FAMILY_STRATIXIII(intended_device_family);
    family_cycloneiiigl = dev.FEATURE_FAMILY_CYCLONEIVGX(intended_device_family);
    family_cycloneiii = !family_cycloneiiigl && (dev.FEATURE_FAMILY_CYCLONEIII(intended_device_family) || dev.FEATURE_FAMILY_MAX10(intended_device_family) );
    family_base_cycloneii = dev.FEATURE_FAMILY_BASE_CYCLONEII(intended_device_family);
    family_arriaii = dev.FEATURE_FAMILY_ARRIAIIGX(intended_device_family);
    family_has_stratix_style_pll = dev.FEATURE_FAMILY_HAS_STRATIX_STYLE_PLL(intended_device_family);
    family_has_stratixii_style_pll = dev.FEATURE_FAMILY_HAS_STRATIXII_STYLE_PLL(intended_device_family);

    if((family_arriaii) && (operation_mode == "external_feedback"))
    begin
        $display ("ERROR: The external feedback mode is not supported for the ARRIA II family.");
        $stop;
    end

    if((family_arriaii) && (pll_type == "top_bottom"))
    begin
        $display ("WARNING: A pll_type specification is not supported for the ARRIA II family.  It will be ignored.");
        $display ("Time: %0t  Instance: %m", $time);
    end

    if((family_arriaii) && ((port_clk7 != "PORT_UNUSED") || (port_clk8 != "PORT_UNUSED") || (port_clk9 != "PORT_UNUSED")))
    begin
        $display ("ERROR: One or more clock outputs used in the design are not supported in ARRIA II family.");
        $stop;
    end

    // End of parameter checking

    pll_lock_sync = 1'b1;

end

// COMPONENT INSTANTIATION
generate
if ((intended_device_family == "Stratix") || (intended_device_family == "STRATIX") || (intended_device_family == "stratix") || (intended_device_family == "Yeager") || (intended_device_family == "YEAGER") || (intended_device_family == "yeager")
    || (intended_device_family == "Cyclone") || (intended_device_family == "CYCLONE") || (intended_device_family == "cyclone") || (intended_device_family == "ACEX2K") || (intended_device_family == "acex2k") || (intended_device_family == "ACEX 2K") || (intended_device_family == "acex 2k") || (intended_device_family == "Tornado") || (intended_device_family == "TORNADO") || (intended_device_family == "tornado")
    || (intended_device_family == "Stratix GX") || (intended_device_family == "STRATIX GX") || (intended_device_family == "stratix gx") || (intended_device_family == "Stratix-GX") || (intended_device_family == "STRATIX-GX") || (intended_device_family == "stratix-gx") || (intended_device_family == "StratixGX") || (intended_device_family == "STRATIXGX") || (intended_device_family == "stratixgx") || (intended_device_family == "Aurora") || (intended_device_family == "AURORA") || (intended_device_family == "aurora")
    || (intended_device_family == "StratixHC"))
begin : stratix_pll

MF_stratix_pll
#(
        .operation_mode         (operation_mode),
        .pll_type               (pll_type),
        .qualify_conf_done      (qualify_conf_done),
        .compensate_clock       (compensate_clock),
        .scan_chain             (scan_chain),
        .primary_clock          (primary_clock),
        .inclk0_input_frequency (inclk0_input_frequency),
        .inclk1_input_frequency (inclk1_input_frequency),
        .gate_lock_signal       (gate_lock_signal),
        .gate_lock_counter      (gate_lock_counter),
        .valid_lock_multiplier  (valid_lock_multiplier),
        .invalid_lock_multiplier (invalid_lock_multiplier),
        .switch_over_on_lossclk (switch_over_on_lossclk),
        .switch_over_on_gated_lock (switch_over_on_gated_lock),
        .enable_switch_over_counter (enable_switch_over_counter),
        .switch_over_counter    (switch_over_counter),
        .feedback_source        (feedback_source),
        .bandwidth              (bandwidth),
        .bandwidth_type         (bandwidth_type),
        .spread_frequency       (spread_frequency),
        .down_spread            (down_spread),
        .simulation_type        (simulation_type),
        .skip_vco               (skip_vco),
        .family_name            (intended_device_family),

        //  internal clock specifications
        .clk5_multiply_by       (clk5_multiply_by),
        .clk4_multiply_by       (clk4_multiply_by),
        .clk3_multiply_by       (clk3_multiply_by),
        .clk2_multiply_by       (clk2_multiply_by),
        .clk1_multiply_by       (clk1_multiply_by),
        .clk0_multiply_by       (clk0_multiply_by),
        .clk5_divide_by         (clk5_divide_by),
        .clk4_divide_by         (clk4_divide_by),
        .clk3_divide_by         (clk3_divide_by),
        .clk2_divide_by         (clk2_divide_by),
        .clk1_divide_by         (clk1_divide_by),
        .clk0_divide_by         (clk0_divide_by),
        .clk5_phase_shift       (clk5_phase_shift),
        .clk4_phase_shift       (clk4_phase_shift),
        .clk3_phase_shift       (clk3_phase_shift),
        .clk2_phase_shift       (clk2_phase_shift),
        .clk1_phase_shift       (clk1_phase_shift),
        .clk0_phase_shift       (clk0_phase_shift),
        .clk5_time_delay        (clk5_time_delay),
        .clk4_time_delay        (clk4_time_delay),
        .clk3_time_delay        (clk3_time_delay),
        .clk2_time_delay        (clk2_time_delay),
        .clk1_time_delay        (clk1_time_delay),
        .clk0_time_delay        (clk0_time_delay),
        .clk5_duty_cycle        (clk5_duty_cycle),
        .clk4_duty_cycle        (clk4_duty_cycle),
        .clk3_duty_cycle        (clk3_duty_cycle),
        .clk2_duty_cycle        (clk2_duty_cycle),
        .clk1_duty_cycle        (clk1_duty_cycle),
        .clk0_duty_cycle        (clk0_duty_cycle),

        //  external clock specifications
        .extclk3_multiply_by    (extclk3_multiply_by),
        .extclk2_multiply_by    (extclk2_multiply_by),
        .extclk1_multiply_by    (extclk1_multiply_by),
        .extclk0_multiply_by    (extclk0_multiply_by),
        .extclk3_divide_by      (extclk3_divide_by),
        .extclk2_divide_by      (extclk2_divide_by),
        .extclk1_divide_by      (extclk1_divide_by),
        .extclk0_divide_by      (extclk0_divide_by),
        .extclk3_phase_shift    (extclk3_phase_shift),
        .extclk2_phase_shift    (extclk2_phase_shift),
        .extclk1_phase_shift    (extclk1_phase_shift),
        .extclk0_phase_shift    (extclk0_phase_shift),
        .extclk3_time_delay     (extclk3_time_delay),
        .extclk2_time_delay     (extclk2_time_delay),
        .extclk1_time_delay     (extclk1_time_delay),
        .extclk0_time_delay     (extclk0_time_delay),
        .extclk3_duty_cycle     (extclk3_duty_cycle),
        .extclk2_duty_cycle     (extclk2_duty_cycle),
        .extclk1_duty_cycle     (extclk1_duty_cycle),
        .extclk0_duty_cycle     (extclk0_duty_cycle),

        // advanced parameters
        .vco_min                ((vco_min == 0 && m != 0)? 1000 : vco_min),
        .vco_max                ((vco_max == 0 && m != 0)? 3600 : vco_max),
        .vco_center             (vco_center),
        .pfd_min                (pfd_min),
        .pfd_max                (pfd_max),
        .m_initial              (m_initial),
        .m                      (m),
        .n                      (n),
        .m2                     (m2),
        .n2                     (n2),
        .ss                     (ss),
        .l0_high                (l0_high),
        .l1_high                (l1_high),
        .g0_high                (g0_high),
        .g1_high                (g1_high),
        .g2_high                (g2_high),
        .g3_high                (g3_high),
        .e0_high                (e0_high),
        .e1_high                (e1_high),
        .e2_high                (e2_high),
        .e3_high                (e3_high),
        .l0_low                 (l0_low),
        .l1_low                 (l1_low),
        .g0_low                 (g0_low),
        .g1_low                 (g1_low),
        .g2_low                 (g2_low),
        .g3_low                 (g3_low),
        .e0_low                 (e0_low),
        .e1_low                 (e1_low),
        .e2_low                 (e2_low),
        .e3_low                 (e3_low),
        .l0_initial             (l0_initial),
        .l1_initial             (l1_initial),
        .g0_initial             (g0_initial),
        .g1_initial             (g1_initial),
        .g2_initial             (g2_initial),
        .g3_initial             (g3_initial),
        .e0_initial             (e0_initial),
        .e1_initial             (e1_initial),
        .e2_initial             (e2_initial),
        .e3_initial             (e3_initial),
        .l0_mode                (l0_mode),
        .l1_mode                (l1_mode),
        .g0_mode                (g0_mode),
        .g1_mode                (g1_mode),
        .g2_mode                (g2_mode),
        .g3_mode                (g3_mode),
        .e0_mode                (e0_mode),
        .e1_mode                (e1_mode),
        .e2_mode                (e2_mode),
        .e3_mode                (e3_mode),
        .l0_ph                  (l0_ph),
        .l1_ph                  (l1_ph),
        .g0_ph                  (g0_ph),
        .g1_ph                  (g1_ph),
        .g2_ph                  (g2_ph),
        .g3_ph                  (g3_ph),
        .e0_ph                  (e0_ph),
        .e1_ph                  (e1_ph),
        .e2_ph                  (e2_ph),
        .e3_ph                  (e3_ph),
        .m_ph                   (m_ph),
        .l0_time_delay          (l0_time_delay),
        .l1_time_delay          (l1_time_delay),
        .g0_time_delay          (g0_time_delay),
        .g1_time_delay          (g1_time_delay),
        .g2_time_delay          (g2_time_delay),
        .g3_time_delay          (g3_time_delay),
        .e0_time_delay          (e0_time_delay),
        .e1_time_delay          (e1_time_delay),
        .e2_time_delay          (e2_time_delay),
        .e3_time_delay          (e3_time_delay),
        .m_time_delay           (m_time_delay),
        .n_time_delay           (n_time_delay),
        .extclk3_counter        (extclk3_counter),
        .extclk2_counter        (extclk2_counter),
        .extclk1_counter        (extclk1_counter),
        .extclk0_counter        (extclk0_counter),
        .clk5_counter           (clk5_counter),
        .clk4_counter           (clk4_counter),
        .clk3_counter           (clk3_counter),
        .clk2_counter           (clk2_counter),
        .clk1_counter           (clk1_counter),
        .clk0_counter           (clk0_counter),
        .enable0_counter        (enable0_counter),
        .enable1_counter        (enable1_counter),
        .charge_pump_current    (charge_pump_current),
        .loop_filter_r          (loop_filter_r),
        .loop_filter_c          (loop_filter_c)
)

pll0
(
    .inclk (stratix_inclk),
    .fbin (stratix_fbin),
    .ena (stratix_ena),
    .clkswitch (stratix_clkswitch),
    .areset (stratix_areset),
    .pfdena (stratix_pfdena),
    .clkena (stratix_clkena),
    .extclkena (stratix_extclkena),
    .scanclk (stratix_scanclk),
    .scanaclr (stratix_scanclr),
    .scandata (stratix_scandata),
    .comparator(),
    .clk (stratix_clk),
    .extclk (stratix_extclk),
    .clkbad (stratix_clkbad),
    .activeclock (stratix_activeclock),
    .locked (locked_tmp),
    .clkloss (stratix_clkloss),
    .scandataout (stratix_scandataout),
    .enable0 (stratix_enable0),
    .enable1 (stratix_enable1)
);

end
endgenerate

generate
if ((intended_device_family == "Stratix II") || (intended_device_family == "STRATIX II") || (intended_device_family == "stratix ii") || (intended_device_family == "StratixII") || (intended_device_family == "STRATIXII") || (intended_device_family == "stratixii") || (intended_device_family == "Armstrong") || (intended_device_family == "ARMSTRONG") || (intended_device_family == "armstrong")
    || (intended_device_family == "HardCopy II") || (intended_device_family == "HARDCOPY II") || (intended_device_family == "hardcopy ii") || (intended_device_family == "HardCopyII") || (intended_device_family == "HARDCOPYII") || (intended_device_family == "hardcopyii") || (intended_device_family == "Fusion") || (intended_device_family == "FUSION") || (intended_device_family == "fusion")
    || (intended_device_family == "Stratix II GX") || (intended_device_family == "STRATIX II GX") || (intended_device_family == "stratix ii gx") || (intended_device_family == "StratixIIGX") || (intended_device_family == "STRATIXIIGX") || (intended_device_family == "stratixiigx")
    || (intended_device_family == "Arria GX") || (intended_device_family == "ARRIA GX") || (intended_device_family == "arria gx") || (intended_device_family == "ArriaGX") || (intended_device_family == "ARRIAGX") || (intended_device_family == "arriagx") || (intended_device_family == "Stratix II GX Lite") || (intended_device_family == "STRATIX II GX LITE") || (intended_device_family == "stratix ii gx lite") || (intended_device_family == "StratixIIGXLite") || (intended_device_family == "STRATIXIIGXLITE") || (intended_device_family == "stratixiigxlite")
    || (intended_device_family == "Cyclone II") || (intended_device_family == "CYCLONE II") || (intended_device_family == "cyclone ii") || (intended_device_family == "Cycloneii") || (intended_device_family == "CYCLONEII") || (intended_device_family == "cycloneii") || (intended_device_family == "Magellan") || (intended_device_family == "MAGELLAN") || (intended_device_family == "magellan"))
begin : stratixii_pll

MF_stratixii_pll
#(
        .operation_mode         (operation_mode),
        .pll_type               (pll_type),
        .qualify_conf_done      (qualify_conf_done),
        .compensate_clock       (compensate_clock),
        .inclk0_input_frequency (inclk0_input_frequency),
        .inclk1_input_frequency (inclk1_input_frequency),
        .gate_lock_signal       (gate_lock_signal),
        .gate_lock_counter      (gate_lock_counter),
        .valid_lock_multiplier  (valid_lock_multiplier),
        .invalid_lock_multiplier (invalid_lock_multiplier),
        .switch_over_type       (switch_over_type),
        .switch_over_on_lossclk (switch_over_on_lossclk),
        .switch_over_on_gated_lock (switch_over_on_gated_lock),
        .enable_switch_over_counter (enable_switch_over_counter),
        .switch_over_counter    (switch_over_counter),
        .feedback_source        ((feedback_source == "EXTCLK0") ? "CLK0" : feedback_source),
        .bandwidth              (bandwidth),
        .bandwidth_type         (bandwidth_type),
        .spread_frequency       (spread_frequency),
        .down_spread            (down_spread),
        .self_reset_on_gated_loss_lock (self_reset_on_gated_loss_lock),
        .simulation_type        (simulation_type),
        .family_name            (intended_device_family),

        //  internal clock specifications
        .clk5_multiply_by       (clk5_multiply_by),
        .clk4_multiply_by       (clk4_multiply_by),
        .clk3_multiply_by       (clk3_multiply_by),
        .clk2_multiply_by       (clk2_multiply_by),
        .clk1_multiply_by       (clk1_multiply_by),
        .clk0_multiply_by       (clk0_multiply_by),
        .clk5_divide_by         (clk5_divide_by),
        .clk4_divide_by         (clk4_divide_by),
        .clk3_divide_by         (clk3_divide_by),
        .clk2_divide_by         (clk2_divide_by),
        .clk1_divide_by         (clk1_divide_by),
        .clk0_divide_by         (clk0_divide_by),
        .clk5_phase_shift       (clk5_phase_shift),
        .clk4_phase_shift       (clk4_phase_shift),
        .clk3_phase_shift       (clk3_phase_shift),
        .clk2_phase_shift       (clk2_phase_shift),
        .clk1_phase_shift       (clk1_phase_shift),
        .clk0_phase_shift       (clk0_phase_shift),
        .clk5_duty_cycle        (clk5_duty_cycle),
        .clk4_duty_cycle        (clk4_duty_cycle),
        .clk3_duty_cycle        (clk3_duty_cycle),
        .clk2_duty_cycle        (clk2_duty_cycle),
        .clk1_duty_cycle        (clk1_duty_cycle),
        .clk0_duty_cycle        (clk0_duty_cycle),
        .vco_multiply_by        (vco_multiply_by),
        .vco_divide_by          (vco_divide_by),
        .clk2_output_frequency  (clk2_output_frequency),
        .clk1_output_frequency  (clk1_output_frequency),
        .clk0_output_frequency  (clk0_output_frequency),

        // advanced parameters
        .vco_min                ((vco_min == 0 && m != 0)? 700 : vco_min),
        .vco_max                ((vco_max == 0 && m != 0)? 3600 : vco_max),
        .vco_center             (vco_center),
        .pfd_min                (pfd_min),
        .pfd_max                (pfd_max),
        .m_initial              (m_initial),
        .m                      (m),
        .n                      (n),
        .m2                     (m2),
        .n2                     (n2),
        .ss                     (ss),
        .c0_high                (c0_high),
        .c1_high                (c1_high),
        .c2_high                (c2_high),
        .c3_high                (c3_high),
        .c4_high                (c4_high),
        .c5_high                (c5_high),
        .c0_low                 (c0_low),
        .c1_low                 (c1_low),
        .c2_low                 (c2_low),
        .c3_low                 (c3_low),
        .c4_low                 (c4_low),
        .c5_low                 (c5_low),
        .c0_initial             (c0_initial),
        .c1_initial             (c1_initial),
        .c2_initial             (c2_initial),
        .c3_initial             (c3_initial),
        .c4_initial             (c4_initial),
        .c5_initial             (c5_initial),
        .c0_mode                (c0_mode),
        .c1_mode                (c1_mode),
        .c2_mode                (c2_mode),
        .c3_mode                (c3_mode),
        .c4_mode                (c4_mode),
        .c5_mode                (c5_mode),
        .c0_ph                  (c0_ph),
        .c1_ph                  (c1_ph),
        .c2_ph                  (c2_ph),
        .c3_ph                  (c3_ph),
        .c4_ph                  (c4_ph),
        .c5_ph                  (c5_ph),
        .m_ph                   (m_ph),
        .c1_use_casc_in         (c1_use_casc_in),
        .c2_use_casc_in         (c2_use_casc_in),
        .c3_use_casc_in         (c3_use_casc_in),
        .c4_use_casc_in         (c4_use_casc_in),
        .c5_use_casc_in         (c5_use_casc_in),
        .clk5_counter           ((clk5_counter == "l1") ? "c5" : clk5_counter),
        .clk4_counter           ((clk4_counter == "l0") ? "c4" : clk4_counter),
        .clk3_counter           ((clk3_counter == "g3") ? "c3" : clk3_counter),
        .clk2_counter           ((clk2_counter == "g2") ? "c2" : clk2_counter),
        .clk1_counter           ((clk1_counter == "g1") ? "c1" : clk1_counter),
        .clk0_counter           ((clk0_counter == "g0") ? "c0" : clk0_counter),
        .enable0_counter        ((enable0_counter == "l0") ? "c0" : enable0_counter),
        .enable1_counter        ((enable1_counter == "l0") ? "c1" : enable1_counter),
        .charge_pump_current    ((m == 0)? 52 : charge_pump_current),
        .loop_filter_r          (loop_filter_r),
        .loop_filter_c          ((m == 0)? 16 : loop_filter_c),
        .m_test_source          (m_test_source),
        .c0_test_source         (c0_test_source),
        .c1_test_source         (c1_test_source),
        .c2_test_source         (c2_test_source),
        .c3_test_source         (c3_test_source),
        .c4_test_source         (c4_test_source),
        .c5_test_source         (c5_test_source),
        .sim_gate_lock_device_behavior (sim_gate_lock_device_behavior)
)

pll1
(
    .inclk (stratixii_inclk),
    .fbin (stratixii_fbin),
    .ena (stratixii_ena),
    .clkswitch (stratixii_clkswitch),
    .areset (stratixii_areset),
    .pfdena (stratixii_pfdena),
    .scanclk (stratixii_scanclk),
    .scanread (stratixii_scanread),
    .scanwrite (stratixii_scanwrite),
    .scandata (stratixii_scandata),
    .testin(),
    .scandone (stratixii_scandone),
    .clk (stratixii_clk),
    .clkbad (stratixii_clkbad),
    .activeclock (stratixii_activeclock),
    .locked (stratixii_locked),
    .clkloss (stratixii_clkloss),
    .scandataout (stratixii_scandataout),
    .enable0 (stratixii_enable0),
    .enable1 (stratixii_enable1),
    .testupout (),
    .testdownout (),
    .sclkout({stratixii_sclkout1, stratixii_sclkout0})
);

end
endgenerate

generate
if ((intended_device_family == "Stratix III") || (intended_device_family == "STRATIX III") || (intended_device_family == "stratix iii") || (intended_device_family == "StratixIII") || (intended_device_family == "STRATIXIII") || (intended_device_family == "stratixiii") || (intended_device_family == "Titan") || (intended_device_family == "TITAN") || (intended_device_family == "titan") || (intended_device_family == "SIII") || (intended_device_family == "siii")
    || (intended_device_family == "Stratix IV") || (intended_device_family == "STRATIX IV") || (intended_device_family == "stratix iv") || (intended_device_family == "TGX") || (intended_device_family == "tgx") || (intended_device_family == "StratixIV") || (intended_device_family == "STRATIXIV") || (intended_device_family == "stratixiv") || (intended_device_family == "Stratix IV (GT)") || (intended_device_family == "STRATIX IV (GT)") || (intended_device_family == "stratix iv (gt)") || (intended_device_family == "Stratix IV (GX)") || (intended_device_family == "STRATIX IV (GX)") || (intended_device_family == "stratix iv (gx)") || (intended_device_family == "Stratix IV (E)") || (intended_device_family == "STRATIX IV (E)") || (intended_device_family == "stratix iv (e)") || (intended_device_family == "StratixIV(GT)") || (intended_device_family == "STRATIXIV(GT)") || (intended_device_family == "stratixiv(gt)") || (intended_device_family == "StratixIV(GX)") || (intended_device_family == "STRATIXIV(GX)") || (intended_device_family == "stratixiv(gx)") || (intended_device_family == "StratixIV(E)") || (intended_device_family == "STRATIXIV(E)") || (intended_device_family == "stratixiv(e)") || (intended_device_family == "StratixIIIGX") || (intended_device_family == "STRATIXIIIGX") || (intended_device_family == "stratixiiigx") || (intended_device_family == "Stratix IV (GT/GX/E)") || (intended_device_family == "STRATIX IV (GT/GX/E)") || (intended_device_family == "stratix iv (gt/gx/e)") || (intended_device_family == "Stratix IV (GT/E/GX)") || (intended_device_family == "STRATIX IV (GT/E/GX)") || (intended_device_family == "stratix iv (gt/e/gx)") || (intended_device_family == "Stratix IV (E/GT/GX)") || (intended_device_family == "STRATIX IV (E/GT/GX)") || (intended_device_family == "stratix iv (e/gt/gx)") || (intended_device_family == "Stratix IV (E/GX/GT)") || (intended_device_family == "STRATIX IV (E/GX/GT)") || (intended_device_family == "stratix iv (e/gx/gt)") || (intended_device_family == "StratixIV(GT/GX/E)") || (intended_device_family == "STRATIXIV(GT/GX/E)") || (intended_device_family == "stratixiv(gt/gx/e)") || (intended_device_family == "StratixIV(GT/E/GX)") || (intended_device_family == "STRATIXIV(GT/E/GX)") || (intended_device_family == "stratixiv(gt/e/gx)") || (intended_device_family == "StratixIV(E/GX/GT)") || (intended_device_family == "STRATIXIV(E/GX/GT)") || (intended_device_family == "stratixiv(e/gx/gt)") || (intended_device_family == "StratixIV(E/GT/GX)") || (intended_device_family == "STRATIXIV(E/GT/GX)") || (intended_device_family == "stratixiv(e/gt/gx)") || (intended_device_family == "Stratix IV (GX/E)") || (intended_device_family == "STRATIX IV (GX/E)") || (intended_device_family == "stratix iv (gx/e)") || (intended_device_family == "StratixIV(GX/E)") || (intended_device_family == "STRATIXIV(GX/E)") || (intended_device_family == "stratixiv(gx/e)")
    || (intended_device_family == "Arria II GX") || (intended_device_family == "ARRIA II GX") || (intended_device_family == "arria ii gx") || (intended_device_family == "ArriaIIGX") || (intended_device_family == "ARRIAIIGX") || (intended_device_family == "arriaiigx") || (intended_device_family == "Arria IIGX") || (intended_device_family == "ARRIA IIGX") || (intended_device_family == "arria iigx") || (intended_device_family == "ArriaII GX") || (intended_device_family == "ARRIAII GX") || (intended_device_family == "arriaii gx") || (intended_device_family == "Arria II") || (intended_device_family == "ARRIA II") || (intended_device_family == "arria ii") || (intended_device_family == "ArriaII") || (intended_device_family == "ARRIAII") || (intended_device_family == "arriaii") || (intended_device_family == "Arria II (GX/E)") || (intended_device_family == "ARRIA II (GX/E)") || (intended_device_family == "arria ii (gx/e)") || (intended_device_family == "ArriaII(GX/E)") || (intended_device_family == "ARRIAII(GX/E)") || (intended_device_family == "arriaii(gx/e)") || (intended_device_family == "PIRANHA") || (intended_device_family == "piranha")
    || (intended_device_family == "HardCopy IV") || (intended_device_family == "HARDCOPY IV") || (intended_device_family == "hardcopy iv") || (intended_device_family == "HardCopyIV") || (intended_device_family == "HARDCOPYIV") || (intended_device_family == "hardcopyiv") || (intended_device_family == "HardCopy IV (GX)") || (intended_device_family == "HARDCOPY IV (GX)") || (intended_device_family == "hardcopy iv (gx)") || (intended_device_family == "HardCopy IV (E)") || (intended_device_family == "HARDCOPY IV (E)") || (intended_device_family == "hardcopy iv (e)") || (intended_device_family == "HardCopyIV(GX)") || (intended_device_family == "HARDCOPYIV(GX)") || (intended_device_family == "hardcopyiv(gx)") || (intended_device_family == "HardCopyIV(E)") || (intended_device_family == "HARDCOPYIV(E)") || (intended_device_family == "hardcopyiv(e)") || (intended_device_family == "HCXIV") || (intended_device_family == "hcxiv") || (intended_device_family == "HardCopy IV (GX/E)") || (intended_device_family == "HARDCOPY IV (GX/E)") || (intended_device_family == "hardcopy iv (gx/e)") || (intended_device_family == "HardCopy IV (E/GX)") || (intended_device_family == "HARDCOPY IV (E/GX)") || (intended_device_family == "hardcopy iv (e/gx)") || (intended_device_family == "HardCopyIV(GX/E)") || (intended_device_family == "HARDCOPYIV(GX/E)") || (intended_device_family == "hardcopyiv(gx/e)") || (intended_device_family == "HardCopyIV(E/GX)") || (intended_device_family == "HARDCOPYIV(E/GX)") || (intended_device_family == "hardcopyiv(e/gx)")
    || (intended_device_family == "Stratix V") || (intended_device_family == "STRATIX V") || (intended_device_family == "stratix v") || (intended_device_family == "StratixV") || (intended_device_family == "STRATIXV") || (intended_device_family == "stratixv") || (intended_device_family == "Stratix V (GS)") || (intended_device_family == "STRATIX V (GS)") || (intended_device_family == "stratix v (gs)") || (intended_device_family == "StratixV(GS)") || (intended_device_family == "STRATIXV(GS)") || (intended_device_family == "stratixv(gs)") || (intended_device_family == "Stratix V (GX)") || (intended_device_family == "STRATIX V (GX)") || (intended_device_family == "stratix v (gx)") || (intended_device_family == "StratixV(GX)") || (intended_device_family == "STRATIXV(GX)") || (intended_device_family == "stratixv(gx)") || (intended_device_family == "Stratix V (GS/GX)") || (intended_device_family == "STRATIX V (GS/GX)") || (intended_device_family == "stratix v (gs/gx)") || (intended_device_family == "StratixV(GS/GX)") || (intended_device_family == "STRATIXV(GS/GX)") || (intended_device_family == "stratixv(gs/gx)") || (intended_device_family == "Stratix V (GX/GS)") || (intended_device_family == "STRATIX V (GX/GS)") || (intended_device_family == "stratix v (gx/gs)") || (intended_device_family == "StratixV(GX/GS)") || (intended_device_family == "STRATIXV(GX/GS)") || (intended_device_family == "stratixv(gx/gs)")
    || (intended_device_family == "Arria V GZ") || (intended_device_family == "ARRIA V GZ") || (intended_device_family == "arria v gz") || (intended_device_family == "ArriaVGZ")  || (intended_device_family == "ARRIAVGZ")  || (intended_device_family == "arriavgz")
    || (intended_device_family == "ArriaV") || (intended_device_family == "ARRIAV") || (intended_device_family == "arriav") || (intended_device_family == "Arria V") || (intended_device_family == "ARRIA V") || (intended_device_family == "arria v")
    || (intended_device_family == "Arria II GZ") || (intended_device_family == "ARRIA II GZ") || (intended_device_family == "arria ii gz") || (intended_device_family == "ArriaII GZ") || (intended_device_family == "ARRIAII GZ") || (intended_device_family == "arriaii gz") || (intended_device_family == "Arria IIGZ") || (intended_device_family == "ARRIA IIGZ") || (intended_device_family == "arria iigz") || (intended_device_family == "ArriaIIGZ") || (intended_device_family == "ARRIAIIGZ") || (intended_device_family == "arriaiigz")
    || (intended_device_family == "HardCopy III") || (intended_device_family == "HARDCOPY III") || (intended_device_family == "hardcopy iii") || (intended_device_family == "HardCopyIII") || (intended_device_family == "HARDCOPYIII") || (intended_device_family == "hardcopyiii") || (intended_device_family == "HCX") || (intended_device_family == "hcx"))
begin : stratixiii_pll

MF_stratixiii_pll
#(
        .operation_mode         (operation_mode),
        .pll_type               (pll_type),
        .compensate_clock       (compensate_clock),
        .inclk0_input_frequency (inclk0_input_frequency),
        .inclk1_input_frequency (inclk1_input_frequency),
        .self_reset_on_loss_lock (self_reset_on_loss_lock),
        .switch_over_type       (switch_over_type),
        .enable_switch_over_counter (enable_switch_over_counter),
        .switch_over_counter    (switch_over_counter),
        .bandwidth              (bandwidth),
        .bandwidth_type         (bandwidth_type),
        .lock_high              (lock_high),
        .lock_low               (lock_low),
        .lock_window_ui         (lock_window_ui),
        .simulation_type        (simulation_type),
        .vco_frequency_control  (vco_frequency_control),
        .vco_phase_shift_step   (vco_phase_shift_step),
        .family_name            (intended_device_family),

        //  internal clock specifications
        .clk9_multiply_by       (clk9_multiply_by),
        .clk8_multiply_by       (clk8_multiply_by),
        .clk7_multiply_by       (clk7_multiply_by),
        .clk6_multiply_by       (clk6_multiply_by),
        .clk5_multiply_by       (clk5_multiply_by),
        .clk4_multiply_by       (clk4_multiply_by),
        .clk3_multiply_by       (clk3_multiply_by),
        .clk2_multiply_by       (clk2_multiply_by),
        .clk1_multiply_by       (clk1_multiply_by),
        .clk0_multiply_by       (clk0_multiply_by),
        .clk9_divide_by         (clk9_divide_by),
        .clk8_divide_by         (clk8_divide_by),
        .clk7_divide_by         (clk7_divide_by),
        .clk6_divide_by         (clk6_divide_by),
        .clk5_divide_by         (clk5_divide_by),
        .clk4_divide_by         (clk4_divide_by),
        .clk3_divide_by         (clk3_divide_by),
        .clk2_divide_by         (clk2_divide_by),
        .clk1_divide_by         (clk1_divide_by),
        .clk0_divide_by         (clk0_divide_by),
        .clk9_phase_shift       (clk9_phase_shift),
        .clk8_phase_shift       (clk8_phase_shift),
        .clk7_phase_shift       (clk7_phase_shift),
        .clk6_phase_shift       (clk6_phase_shift),
        .clk5_phase_shift       (clk5_phase_shift),
        .clk4_phase_shift       (clk4_phase_shift),
        .clk3_phase_shift       (clk3_phase_shift),
        .clk2_phase_shift       (clk2_phase_shift),
        .clk1_phase_shift       (clk1_phase_shift),
        .clk0_phase_shift       (clk0_phase_shift),
        .clk9_duty_cycle        (clk9_duty_cycle),
        .clk8_duty_cycle        (clk8_duty_cycle),
        .clk7_duty_cycle        (clk7_duty_cycle),
        .clk6_duty_cycle        (clk6_duty_cycle),
        .clk5_duty_cycle        (clk5_duty_cycle),
        .clk4_duty_cycle        (clk4_duty_cycle),
        .clk3_duty_cycle        (clk3_duty_cycle),
        .clk2_duty_cycle        (clk2_duty_cycle),
        .clk1_duty_cycle        (clk1_duty_cycle),
        .clk0_duty_cycle        (clk0_duty_cycle),
        .vco_multiply_by        (vco_multiply_by),
        .vco_divide_by          (vco_divide_by),
        .dpa_multiply_by        (dpa_multiply_by),
        .dpa_divide_by          (dpa_divide_by),
        .dpa_divider            (dpa_divider),
        .clk2_output_frequency  (clk2_output_frequency),
        .clk1_output_frequency  (clk1_output_frequency),
        .clk0_output_frequency  (clk0_output_frequency),
        .clk9_use_even_counter_mode    (clk9_use_even_counter_mode),
        .clk8_use_even_counter_mode    (clk8_use_even_counter_mode),
        .clk7_use_even_counter_mode    (clk7_use_even_counter_mode),
        .clk6_use_even_counter_mode    (clk6_use_even_counter_mode),
        .clk5_use_even_counter_mode    (clk5_use_even_counter_mode),
        .clk4_use_even_counter_mode    (clk4_use_even_counter_mode),
        .clk3_use_even_counter_mode    (clk3_use_even_counter_mode),
        .clk2_use_even_counter_mode    (clk2_use_even_counter_mode),
        .clk1_use_even_counter_mode    (clk1_use_even_counter_mode),
        .clk0_use_even_counter_mode    (clk0_use_even_counter_mode),
        .clk9_use_even_counter_value   (clk9_use_even_counter_value),
        .clk8_use_even_counter_value   (clk8_use_even_counter_value),
        .clk7_use_even_counter_value   (clk7_use_even_counter_value),
        .clk6_use_even_counter_value   (clk6_use_even_counter_value),
        .clk5_use_even_counter_value   (clk5_use_even_counter_value),
        .clk4_use_even_counter_value   (clk4_use_even_counter_value),
        .clk3_use_even_counter_value   (clk3_use_even_counter_value),
        .clk2_use_even_counter_value   (clk2_use_even_counter_value),
        .clk1_use_even_counter_value   (clk1_use_even_counter_value),
        .clk0_use_even_counter_value   (clk0_use_even_counter_value),

        // advanced parameters
        .vco_min                ((vco_min == 0 && m != 0)? 100 : vco_min),
        .vco_max                ((vco_max == 0 && m != 0)? 3600 : vco_max),
        .vco_center             (vco_center),
        .pfd_min                (pfd_min),
        .pfd_max                (pfd_max),
        .m_initial              (m_initial),
        .m                      (m),
        .n                      (n),
        .c0_high                (c0_high),
        .c1_high                (c1_high),
        .c2_high                (c2_high),
        .c3_high                (c3_high),
        .c4_high                (c4_high),
        .c5_high                (c5_high),
        .c6_high                (c6_high),
        .c7_high                (c7_high),
        .c8_high                (c8_high),
        .c9_high                (c9_high),
        .c0_low                 (c0_low),
        .c1_low                 (c1_low),
        .c2_low                 (c2_low),
        .c3_low                 (c3_low),
        .c4_low                 (c4_low),
        .c5_low                 (c5_low),
        .c6_low                 (c6_low),
        .c7_low                 (c7_low),
        .c8_low                 (c8_low),
        .c9_low                 (c9_low),
        .c0_initial             (c0_initial),
        .c1_initial             (c1_initial),
        .c2_initial             (c2_initial),
        .c3_initial             (c3_initial),
        .c4_initial             (c4_initial),
        .c5_initial             (c5_initial),
        .c6_initial             (c6_initial),
        .c7_initial             (c7_initial),
        .c8_initial             (c8_initial),
        .c9_initial             (c9_initial),
        .c0_mode                (c0_mode),
        .c1_mode                (c1_mode),
        .c2_mode                (c2_mode),
        .c3_mode                (c3_mode),
        .c4_mode                (c4_mode),
        .c5_mode                (c5_mode),
        .c6_mode                (c6_mode),
        .c7_mode                (c7_mode),
        .c8_mode                (c8_mode),
        .c9_mode                (c9_mode),
        .c0_ph                  (c0_ph),
        .c1_ph                  (c1_ph),
        .c2_ph                  (c2_ph),
        .c3_ph                  (c3_ph),
        .c4_ph                  (c4_ph),
        .c5_ph                  (c5_ph),
        .c6_ph                  (c6_ph),
        .c7_ph                  (c7_ph),
        .c8_ph                  (c8_ph),
        .c9_ph                  (c9_ph),
        .m_ph                   (m_ph),
        .c1_use_casc_in         (c1_use_casc_in),
        .c2_use_casc_in         (c2_use_casc_in),
        .c3_use_casc_in         (c3_use_casc_in),
        .c4_use_casc_in         (c4_use_casc_in),
        .c5_use_casc_in         (c5_use_casc_in),
        .c6_use_casc_in         (c6_use_casc_in),
        .c7_use_casc_in         (c7_use_casc_in),
        .c8_use_casc_in         (c8_use_casc_in),
        .c9_use_casc_in         (c9_use_casc_in),
        .clk9_counter           ((port_clk9 != "PORT_USED") ? "unused" : clk9_counter),
        .clk8_counter           ((port_clk8 != "PORT_USED") ? "unused" : clk8_counter),
        .clk7_counter           ((port_clk7 != "PORT_USED") ? "unused" : clk7_counter),
        .clk6_counter           ((port_clk6 != "PORT_USED") ? "unused" : clk6_counter),
        .clk5_counter           ((port_clk5 != "PORT_USED") ? "unused" : (clk5_counter == "l1") ? "c5" : clk5_counter),
        .clk4_counter           ((port_clk4 != "PORT_USED") ? "unused" : (clk4_counter == "l0") ? "c4" : clk4_counter),
        .clk3_counter           ((port_clk3 != "PORT_USED") ? "unused" : (clk3_counter == "g3") ? "c3" : clk3_counter),
        .clk2_counter           ((port_clk2 != "PORT_USED") ? "unused" : (clk2_counter == "g2") ? "c2" : clk2_counter),
        .clk1_counter           ((port_clk1 != "PORT_USED") ? "unused" : (clk1_counter == "g1") ? "c1" : clk1_counter),
        .clk0_counter           ((port_clk0 != "PORT_USED") ? "unused" : (clk0_counter == "g0") ? "c0" : clk0_counter),
        .charge_pump_current    (charge_pump_current),
        .loop_filter_r          (loop_filter_r),
        .loop_filter_c          (loop_filter_c),
        .charge_pump_current_bits (charge_pump_current_bits),
        .loop_filter_c_bits     (loop_filter_c_bits),
        .loop_filter_r_bits     (loop_filter_r_bits),
        .m_test_source          ((m_test_source == 5)  ? -1 : m_test_source),
        .c0_test_source         ((c0_test_source == 5) ? -1 : c0_test_source),
        .c1_test_source         ((c1_test_source == 5) ? -1 : c1_test_source),
        .c2_test_source         ((c2_test_source == 5) ? -1 : c2_test_source),
        .c3_test_source         ((c3_test_source == 5) ? -1 : c3_test_source),
        .c4_test_source         ((c4_test_source == 5) ? -1 : c4_test_source),
        .c5_test_source         ((c5_test_source == 5) ? -1 : c5_test_source),
        .c6_test_source         ((c6_test_source == 5) ? -1 : c6_test_source),
        .c7_test_source         ((c7_test_source == 5) ? -1 : c7_test_source),
        .c8_test_source         ((c8_test_source == 5) ? -1 : c8_test_source),
        .c9_test_source         ((c9_test_source == 5) ? -1 : c9_test_source)
)

pll2
(
    .inclk (stratix3_inclk),
    .fbin (stratix3_fbin),
    .clkswitch (stratix3_clkswitch),
    .areset (stratix3_areset),
    .pfdena (stratix3_pfdena),
    .scanclk (stratix3_scanclk),
    .scandata (scandata),
    .scanclkena (scanclkena_pullup),
    .configupdate (configupdate_pulldown),
    .clk (stratix3_clk),
    .phasecounterselect (stratix3_phasecounterselect),
    .phaseupdown (phaseupdown_pulldown),
    .phasestep (phasestep_pulldown),
    .clkbad (stratix3_clkbad),
    .activeclock (stratix3_activeclock),
    .locked (stratix3_locked),
    .scandataout (stratix3_scandataout),
    .scandone (stratix3_scandone),
    .phasedone (stratix3_phasedone),
    .vcooverrange (stratix3_vcooverrange),
    .vcounderrange (stratix3_vcounderrange),
    .fbout (stratix3_fbout)
);

end
endgenerate

// cycloneiii_msg
generate
if ((intended_device_family == "Cyclone III") || (intended_device_family == "CYCLONE III") || (intended_device_family == "cyclone iii") || (intended_device_family == "CycloneIII") || (intended_device_family == "CYCLONEIII") || (intended_device_family == "cycloneiii") || (intended_device_family == "Barracuda") || (intended_device_family == "BARRACUDA") || (intended_device_family == "barracuda") || (intended_device_family == "Cuda") || (intended_device_family == "CUDA") || (intended_device_family == "cuda") || (intended_device_family == "CIII") || (intended_device_family == "ciii")
    || (intended_device_family == "Cyclone III LS") || (intended_device_family == "CYCLONE III LS") || (intended_device_family == "cyclone iii ls") || (intended_device_family == "CycloneIIILS") || (intended_device_family == "CYCLONEIIILS") || (intended_device_family == "cycloneiiils") || (intended_device_family == "Cyclone III LPS") || (intended_device_family == "CYCLONE III LPS") || (intended_device_family == "cyclone iii lps") || (intended_device_family == "Cyclone LPS") || (intended_device_family == "CYCLONE LPS") || (intended_device_family == "cyclone lps") || (intended_device_family == "CycloneLPS") || (intended_device_family == "CYCLONELPS") || (intended_device_family == "cyclonelps") || (intended_device_family == "Tarpon") || (intended_device_family == "TARPON") || (intended_device_family == "tarpon") || (intended_device_family == "Cyclone IIIE") || (intended_device_family == "CYCLONE IIIE") || (intended_device_family == "cyclone iiie")
    || (intended_device_family == "Cyclone IV E") || (intended_device_family == "CYCLONE IV E") || (intended_device_family == "cyclone iv e") || (intended_device_family == "CycloneIV E") || (intended_device_family == "CYCLONEIV E") || (intended_device_family == "cycloneiv e") || (intended_device_family == "Cyclone IVE") || (intended_device_family == "CYCLONE IVE") || (intended_device_family == "cyclone ive") || (intended_device_family == "CycloneIVE") || (intended_device_family == "CYCLONEIVE") || (intended_device_family == "cycloneive")
	|| (intended_device_family == "MAX 10") || (intended_device_family == "MAX 10 FPGA") || (intended_device_family == "MAX10") || (intended_device_family == "max 10 fpga") || (intended_device_family == "MAX10FPGA") || (intended_device_family == "max10fpga") || (intended_device_family == "Max 10 FPGA") || (intended_device_family == "Max10FPGA"))
begin : cycloneiii_pll

MF_cycloneiii_pll
#(
        .operation_mode         (operation_mode),
        .pll_type               (pll_type),
        .compensate_clock       (compensate_clock),
        .inclk0_input_frequency (inclk0_input_frequency),
        .inclk1_input_frequency (inclk1_input_frequency),
        .self_reset_on_loss_lock (self_reset_on_loss_lock),
        .switch_over_type       (switch_over_type),
        .enable_switch_over_counter (enable_switch_over_counter),
        .switch_over_counter    (switch_over_counter),
        .bandwidth              (bandwidth),
        .bandwidth_type         (bandwidth_type),
        .lock_high              (lock_high),
        .lock_low               (lock_low),
        .lock_window_ui         (lock_window_ui),
        .simulation_type        (simulation_type),
        .vco_frequency_control  (vco_frequency_control),
        .vco_phase_shift_step   (vco_phase_shift_step),
        .family_name            (intended_device_family),

        //  internal clock specifications
        .clk4_multiply_by       (clk4_multiply_by),
        .clk3_multiply_by       (clk3_multiply_by),
        .clk2_multiply_by       (clk2_multiply_by),
        .clk1_multiply_by       (clk1_multiply_by),
        .clk0_multiply_by       (clk0_multiply_by),
        .clk4_divide_by         (clk4_divide_by),
        .clk3_divide_by         (clk3_divide_by),
        .clk2_divide_by         (clk2_divide_by),
        .clk1_divide_by         (clk1_divide_by),
        .clk0_divide_by         (clk0_divide_by),
        .clk4_phase_shift       (clk4_phase_shift),
        .clk3_phase_shift       (clk3_phase_shift),
        .clk2_phase_shift       (clk2_phase_shift),
        .clk1_phase_shift       (clk1_phase_shift),
        .clk0_phase_shift       (clk0_phase_shift),
        .clk4_duty_cycle        (clk4_duty_cycle),
        .clk3_duty_cycle        (clk3_duty_cycle),
        .clk2_duty_cycle        (clk2_duty_cycle),
        .clk1_duty_cycle        (clk1_duty_cycle),
        .clk0_duty_cycle        (clk0_duty_cycle),
        .vco_multiply_by        (vco_multiply_by),
        .vco_divide_by          (vco_divide_by),
        .clk2_output_frequency  (clk2_output_frequency),
        .clk1_output_frequency  (clk1_output_frequency),
        .clk0_output_frequency  (clk0_output_frequency),
        .clk4_use_even_counter_mode    (clk4_use_even_counter_mode),
        .clk3_use_even_counter_mode    (clk3_use_even_counter_mode),
        .clk2_use_even_counter_mode    (clk2_use_even_counter_mode),
        .clk1_use_even_counter_mode    (clk1_use_even_counter_mode),
        .clk0_use_even_counter_mode    (clk0_use_even_counter_mode),
        .clk4_use_even_counter_value   (clk4_use_even_counter_value),
        .clk3_use_even_counter_value   (clk3_use_even_counter_value),
        .clk2_use_even_counter_value   (clk2_use_even_counter_value),
        .clk1_use_even_counter_value   (clk1_use_even_counter_value),
        .clk0_use_even_counter_value   (clk0_use_even_counter_value),

        // advanced parameters
        .vco_min                ((vco_min == 0 && m != 0)? 200 : vco_min),
        .vco_max                ((vco_max == 0 && m != 0)? 3600 : vco_max),
        .vco_center             (vco_center),
        .pfd_min                (pfd_min),
        .pfd_max                (pfd_max),
        .m_initial              (m_initial),
        .m                      (m),
        .n                      (n),
        .c0_high                (c0_high),
        .c1_high                (c1_high),
        .c2_high                (c2_high),
        .c3_high                (c3_high),
        .c4_high                (c4_high),
        .c0_low                 (c0_low),
        .c1_low                 (c1_low),
        .c2_low                 (c2_low),
        .c3_low                 (c3_low),
        .c4_low                 (c4_low),
        .c0_initial             (c0_initial),
        .c1_initial             (c1_initial),
        .c2_initial             (c2_initial),
        .c3_initial             (c3_initial),
        .c4_initial             (c4_initial),
        .c0_mode                (c0_mode),
        .c1_mode                (c1_mode),
        .c2_mode                (c2_mode),
        .c3_mode                (c3_mode),
        .c4_mode                (c4_mode),
        .c0_ph                  (c0_ph),
        .c1_ph                  (c1_ph),
        .c2_ph                  (c2_ph),
        .c3_ph                  (c3_ph),
        .c4_ph                  (c4_ph),
        .m_ph                   (m_ph),
        .c1_use_casc_in         (c1_use_casc_in),
        .c2_use_casc_in         (c2_use_casc_in),
        .c3_use_casc_in         (c3_use_casc_in),
        .c4_use_casc_in         (c4_use_casc_in),
        .clk4_counter           ((port_clk4 != "PORT_USED") ? "unused" : (clk4_counter == "l0") ? "c4" : clk4_counter),
        .clk3_counter           ((port_clk3 != "PORT_USED") ? "unused" : (clk3_counter == "g3") ? "c3" : clk3_counter),
        .clk2_counter           ((port_clk2 != "PORT_USED") ? "unused" : (clk2_counter == "g2") ? "c2" : clk2_counter),
        .clk1_counter           ((port_clk1 != "PORT_USED") ? "unused" : (clk1_counter == "g1") ? "c1" : clk1_counter),
        .clk0_counter           ((port_clk0 != "PORT_USED") ? "unused" : (clk0_counter == "g0") ? "c0" : clk0_counter),
        .charge_pump_current    (charge_pump_current),
        .loop_filter_r          (loop_filter_r),
        .loop_filter_c          (loop_filter_c),
        .charge_pump_current_bits (charge_pump_current_bits),
        .loop_filter_c_bits     (loop_filter_c_bits),
        .loop_filter_r_bits     (loop_filter_r_bits),
        .m_test_source          ((m_test_source == 5)  ? -1 : m_test_source),
        .c0_test_source         ((c0_test_source == 5) ? -1 : c0_test_source),
        .c1_test_source         ((c1_test_source == 5) ? -1 : c1_test_source),
        .c2_test_source         ((c2_test_source == 5) ? -1 : c2_test_source),
        .c3_test_source         ((c3_test_source == 5) ? -1 : c3_test_source),
        .c4_test_source         ((c4_test_source == 5) ? -1 : c4_test_source)
)

pll3
(
    .inclk (cyclone3_inclk),
    .fbin (fbin),
    .clkswitch (cyclone3_clkswitch),
    .areset (cyclone3_areset),
    .pfdena (cyclone3_pfdena),
    .scanclk (cyclone3_scanclk),
    .scandata (scandata),
    .scanclkena (scanclkena_pullup),
    .configupdate (configupdate_pulldown),
    .clk (cyclone3_clk),
    .phasecounterselect (cyclone3_phasecounterselect),
    .phaseupdown (phaseupdown_pulldown),
    .phasestep (phasestep_pulldown),
    .clkbad (cyclone3_clkbad),
    .activeclock (cyclone3_activeclock),
    .locked (cyclone3_locked),
    .scandataout (cyclone3_scandataout),
    .scandone (cyclone3_scandone),
    .phasedone (cyclone3_phasedone),
    .vcooverrange (cyclone3_vcooverrange),
    .vcounderrange (cyclone3_vcounderrange),
    .fbout (cyclone3_fbout)
);

end
endgenerate
// cycloneiii_msg

generate
if ((intended_device_family == "Cyclone IV GX") || (intended_device_family == "CYCLONE IV GX") || (intended_device_family == "cyclone iv gx") || (intended_device_family == "Cyclone IVGX") || (intended_device_family == "CYCLONE IVGX") || (intended_device_family == "cyclone ivgx") || (intended_device_family == "CycloneIV GX") || (intended_device_family == "CYCLONEIV GX") || (intended_device_family == "cycloneiv gx") || (intended_device_family == "CycloneIVGX") || (intended_device_family == "CYCLONEIVGX") || (intended_device_family == "cycloneivgx") || (intended_device_family == "Cyclone IV") || (intended_device_family == "CYCLONE IV") || (intended_device_family == "cyclone iv") || (intended_device_family == "CycloneIV") || (intended_device_family == "CYCLONEIV") || (intended_device_family == "cycloneiv") || (intended_device_family == "Cyclone IV (GX)") || (intended_device_family == "CYCLONE IV (GX)") || (intended_device_family == "cyclone iv (gx)") || (intended_device_family == "CycloneIV(GX)") || (intended_device_family == "CYCLONEIV(GX)") || (intended_device_family == "cycloneiv(gx)") || (intended_device_family == "Cyclone III GX") || (intended_device_family == "CYCLONE III GX") || (intended_device_family == "cyclone iii gx") || (intended_device_family == "CycloneIII GX") || (intended_device_family == "CYCLONEIII GX") || (intended_device_family == "cycloneiii gx") || (intended_device_family == "Cyclone IIIGX") || (intended_device_family == "CYCLONE IIIGX") || (intended_device_family == "cyclone iiigx") || (intended_device_family == "CycloneIIIGX") || (intended_device_family == "CYCLONEIIIGX") || (intended_device_family == "cycloneiiigx") || (intended_device_family == "Cyclone III GL") || (intended_device_family == "CYCLONE III GL") || (intended_device_family == "cyclone iii gl") || (intended_device_family == "CycloneIII GL") || (intended_device_family == "CYCLONEIII GL") || (intended_device_family == "cycloneiii gl") || (intended_device_family == "Cyclone IIIGL") || (intended_device_family == "CYCLONE IIIGL") || (intended_device_family == "cyclone iiigl") || (intended_device_family == "CycloneIIIGL") || (intended_device_family == "CYCLONEIIIGL") || (intended_device_family == "cycloneiiigl") || (intended_device_family == "Stingray") || (intended_device_family == "STINGRAY") || (intended_device_family == "stingray"))
begin : cycloneiv_pll

MF_cycloneiiigl_pll
#(
        .operation_mode         (operation_mode),
        .pll_type               (pll_type),
        .compensate_clock       (compensate_clock),
        .inclk0_input_frequency (inclk0_input_frequency),
        .inclk1_input_frequency (inclk1_input_frequency),
        .self_reset_on_loss_lock (self_reset_on_loss_lock),
        .switch_over_type       (switch_over_type),
        .enable_switch_over_counter (enable_switch_over_counter),
        .switch_over_counter    (switch_over_counter),
        .bandwidth              (bandwidth),
        .bandwidth_type         (bandwidth_type),
        .lock_high              (lock_high),
        .lock_low               (lock_low),
        .lock_window_ui         (lock_window_ui),
        .simulation_type        (simulation_type),
        .vco_frequency_control  (vco_frequency_control),
        .vco_phase_shift_step   (vco_phase_shift_step),
        .family_name            (intended_device_family),

        //  internal clock specifications
        .clk4_multiply_by       (clk4_multiply_by),
        .clk3_multiply_by       (clk3_multiply_by),
        .clk2_multiply_by       (clk2_multiply_by),
        .clk1_multiply_by       (clk1_multiply_by),
        .clk0_multiply_by       (clk0_multiply_by),
        .clk4_divide_by         (clk4_divide_by),
        .clk3_divide_by         (clk3_divide_by),
        .clk2_divide_by         (clk2_divide_by),
        .clk1_divide_by         (clk1_divide_by),
        .clk0_divide_by         (clk0_divide_by),
        .clk4_phase_shift       (clk4_phase_shift),
        .clk3_phase_shift       (clk3_phase_shift),
        .clk2_phase_shift       (clk2_phase_shift),
        .clk1_phase_shift       (clk1_phase_shift),
        .clk0_phase_shift       (clk0_phase_shift),
        .clk4_duty_cycle        (clk4_duty_cycle),
        .clk3_duty_cycle        (clk3_duty_cycle),
        .clk2_duty_cycle        (clk2_duty_cycle),
        .clk1_duty_cycle        (clk1_duty_cycle),
        .clk0_duty_cycle        (clk0_duty_cycle),
        .dpa_multiply_by        (dpa_multiply_by),
        .dpa_divide_by          (dpa_divide_by),
        .vco_multiply_by        (vco_multiply_by),
        .vco_divide_by          (vco_divide_by),
        .clk2_output_frequency  (clk2_output_frequency),
        .clk1_output_frequency  (clk1_output_frequency),
        .clk0_output_frequency  (clk0_output_frequency),
        .clk4_use_even_counter_mode    (clk4_use_even_counter_mode),
        .clk3_use_even_counter_mode    (clk3_use_even_counter_mode),
        .clk2_use_even_counter_mode    (clk2_use_even_counter_mode),
        .clk1_use_even_counter_mode    (clk1_use_even_counter_mode),
        .clk0_use_even_counter_mode    (clk0_use_even_counter_mode),
        .clk4_use_even_counter_value   (clk4_use_even_counter_value),
        .clk3_use_even_counter_value   (clk3_use_even_counter_value),
        .clk2_use_even_counter_value   (clk2_use_even_counter_value),
        .clk1_use_even_counter_value   (clk1_use_even_counter_value),
        .clk0_use_even_counter_value   (clk0_use_even_counter_value),

        // advanced parameters
        .vco_min                ((vco_min == 0 && m != 0)? 200 : vco_min),
        .vco_max                ((vco_max == 0 && m != 0)? 3600 : vco_max),
        .vco_center             (vco_center),
        .dpa_divider            (dpa_divider),
        .pfd_min                (pfd_min),
        .pfd_max                (pfd_max),
        .m_initial              (m_initial),
        .m                      (m),
        .n                      (n),
        .c0_high                (c0_high),
        .c1_high                (c1_high),
        .c2_high                (c2_high),
        .c3_high                (c3_high),
        .c4_high                (c4_high),
        .c0_low                 (c0_low),
        .c1_low                 (c1_low),
        .c2_low                 (c2_low),
        .c3_low                 (c3_low),
        .c4_low                 (c4_low),
        .c0_initial             (c0_initial),
        .c1_initial             (c1_initial),
        .c2_initial             (c2_initial),
        .c3_initial             (c3_initial),
        .c4_initial             (c4_initial),
        .c0_mode                (c0_mode),
        .c1_mode                (c1_mode),
        .c2_mode                (c2_mode),
        .c3_mode                (c3_mode),
        .c4_mode                (c4_mode),
        .c0_ph                  (c0_ph),
        .c1_ph                  (c1_ph),
        .c2_ph                  (c2_ph),
        .c3_ph                  (c3_ph),
        .c4_ph                  (c4_ph),
        .m_ph                   (m_ph),
        .c1_use_casc_in         (c1_use_casc_in),
        .c2_use_casc_in         (c2_use_casc_in),
        .c3_use_casc_in         (c3_use_casc_in),
        .c4_use_casc_in         (c4_use_casc_in),
        .clk4_counter           ((port_clk4 !="PORT_USED") ? "unused" : (clk4_counter =="l0") ? "c4" : clk4_counter),
        .clk3_counter           ((port_clk3 !="PORT_USED") ? "unused" : (clk3_counter =="g3") ? "c3" : clk3_counter),
        .clk2_counter           ((port_clk2 !="PORT_USED") ? "unused" : (clk2_counter =="g2") ? "c2" : clk2_counter),
        .clk1_counter           ((port_clk1 !="PORT_USED") ? "unused" : (clk1_counter =="g1") ? "c1" : clk1_counter),
        .clk0_counter           ((port_clk0 !="PORT_USED") ? "unused" : (clk0_counter =="g0") ? "c0" : clk0_counter),
        .charge_pump_current    (charge_pump_current),
        .loop_filter_r          (loop_filter_r),
        .loop_filter_c          (loop_filter_c),
        .charge_pump_current_bits (charge_pump_current_bits),
        .loop_filter_c_bits     (loop_filter_c_bits),
        .loop_filter_r_bits     (loop_filter_r_bits),
        .m_test_source          ((m_test_source ==5)  ? -1 : m_test_source),
        .c0_test_source         ((c0_test_source ==5) ? -1 : c0_test_source),
        .c1_test_source         ((c1_test_source ==5) ? -1 : c1_test_source),
        .c2_test_source         ((c2_test_source ==5) ? -1 : c2_test_source),
        .c3_test_source         ((c3_test_source ==5) ? -1 : c3_test_source),
        .c4_test_source         ((c4_test_source ==5) ? -1 : c4_test_source)
)

pll4
(
    .inclk (cyclone3gl_inclk),
    .fbin (fbin),
    .clkswitch (cyclone3gl_clkswitch),
    .areset (cyclone3gl_areset),
    .pfdena (cyclone3gl_pfdena),
    .scanclk (cyclone3gl_scanclk),
    .scandata (scandata),
    .scanclkena (scanclkena_pullup),
    .configupdate (configupdate_pulldown),
    .clk (cyclone3gl_clk),
    .phasecounterselect (cyclone3gl_phasecounterselect),
    .phaseupdown (phaseupdown_pulldown),
    .phasestep (phasestep_pulldown),
    .clkbad (cyclone3gl_clkbad),
    .activeclock (cyclone3gl_activeclock),
    .locked (cyclone3gl_locked),
    .scandataout (cyclone3gl_scandataout),
    .scandone (cyclone3gl_scandone),
    .phasedone (cyclone3gl_phasedone),
    .vcooverrange (cyclone3gl_vcooverrange),
    .vcounderrange (cyclone3gl_vcounderrange),
    .fbout (cyclone3gl_fbout),
    .fref (cyclone3gl_fref),
    .icdrclk (cyclone3gl_icdrclk)
);

end
endgenerate

pll_iobuf iobuf1
(
    .i (stratix3_fbout),
    .oe (1'b1),
    .io (iobuf_io),
    .o (iobuf_o)
);

// ALWAYS CONSTRUCT BLOCK
always @(posedge pll_lock or posedge areset)
begin
    if (areset)
        pll_lock_sync <= 1'b0;
    else
        pll_lock_sync <= 1'b1;
end

// CONTINOUS ASSIGNMENT
assign ena_pullup = ((port_pllena == "PORT_CONNECTIVITY") ||
                        (port_pllena == "PORT_USED")) ? pllena : 1'b1;
assign pfdena_pullup = ((port_pfdena == "PORT_CONNECTIVITY") ||
                        (port_pfdena == "PORT_USED")) ? pfdena : 1'b1;
assign clkena_pullup[0] = (!(alpha_tolower(pll_type) == "fast") ||
                            (port_clkena0 == "PORT_USED")) &&
                            (port_clkena0 != "PORT_UNUSED") ? clkena[0] : 1'b1;
assign clkena_pullup[1] = (!(alpha_tolower(pll_type) == "fast") ||
                            (port_clkena1 == "PORT_USED")) &&
                            (port_clkena1 != "PORT_UNUSED") ? clkena[1] : 1'b1;
assign clkena_pullup[2] = (!(alpha_tolower(pll_type) == "fast") ||
                            (port_clkena2 == "PORT_USED")) &&
                            (port_clkena2 != "PORT_UNUSED") ? clkena[2] : 1'b1;
assign clkena_pullup[3] = (!(alpha_tolower(pll_type) == "fast") ||
                            (port_clkena3 == "PORT_USED")) &&
                            (port_clkena3 != "PORT_UNUSED") ? clkena[3] : 1'b1;
assign clkena_pullup[4] = (!(alpha_tolower(pll_type) == "fast") ||
                            (port_clkena4 == "PORT_USED")) &&
                            (port_clkena4 != "PORT_UNUSED") ? clkena[4] : 1'b1;
assign clkena_pullup[5] = (!(alpha_tolower(pll_type) == "fast") ||
                            (port_clkena5 == "PORT_USED")) &&
                            (port_clkena5 != "PORT_UNUSED") ? clkena[5] : 1'b1;

assign extclkena_pullup[0] = (!(alpha_tolower(pll_type) == "fast") ||
                            (port_extclkena0 == "PORT_USED")) &&
                            (port_extclkena0 != "PORT_UNUSED") ? extclkena[0] : 1'b1;
assign extclkena_pullup[1] = (!(alpha_tolower(pll_type) == "fast") ||
                            (port_extclkena1 == "PORT_USED")) &&
                            (port_extclkena1 != "PORT_UNUSED") ? extclkena[1] : 1'b1;
assign extclkena_pullup[2] = (!(alpha_tolower(pll_type) == "fast") ||
                            (port_extclkena2 == "PORT_USED")) &&
                            (port_extclkena2 != "PORT_UNUSED") ? extclkena[2] : 1'b1;
assign extclkena_pullup[3] = (!(alpha_tolower(pll_type) == "fast") ||
                            (port_extclkena3 == "PORT_USED")) &&
                            (port_extclkena3 != "PORT_UNUSED") ? extclkena[3] : 1'b1;
assign scanclkena_pullup = ((port_scanclkena == "PORT_CONNECTIVITY") ||
                            (port_scanclkena == "PORT_USED")) ? scanclkena : 1'b1;

assign fbin_pulldown = ((port_fbin == "PORT_CONNECTIVITY") ||
                        (port_fbin == "PORT_USED")) ? fbin : 1'b0;

assign phasecounterselect_pulldown[width_phasecounterselect-1 :0] = ((port_phasecounterselect == "PORT_CONNECTIVITY") ||
                            (port_phasecounterselect == "PORT_USED")) ? phasecounterselect[width_phasecounterselect-1 :0] : {width_phasecounterselect{1'b0}};
assign phaseupdown_pulldown = ((port_phaseupdown == "PORT_CONNECTIVITY") ||
                            (port_phaseupdown == "PORT_USED")) ? phaseupdown : 1'b0;
assign phasestep_pulldown = ((port_phasestep == "PORT_CONNECTIVITY") ||
                            (port_phasestep == "PORT_USED")) ? phasestep : 1'b0;
assign configupdate_pulldown = ((port_configupdate == "PORT_CONNECTIVITY") ||
                            (port_configupdate == "PORT_USED")) ? configupdate : 1'b0;

assign scanclk_pulldown = ((port_scanclk != "PORT_UNUSED")) ? scanclk : 1'b0;
assign scanread_pulldown = ((port_scanread == "PORT_CONNECTIVITY") ||
                        (port_scanread == "PORT_USED")) ? scanread : 1'b0;
assign scanwrite_pulldown = ((port_scanwrite == "PORT_CONNECTIVITY") ||
                        (port_scanwrite == "PORT_USED")) ? scanwrite : 1'b0;
assign scandata_pulldown = ((port_scandata == "PORT_CONNECTIVITY") ||
                        (port_scandata == "PORT_USED")) ? scandata : 1'b0;
assign inclk_pulldown = inclk;
assign clkswitch_pulldown = ((port_clkswitch == "PORT_CONNECTIVITY") ||
                        (port_clkswitch == "PORT_USED")) ? clkswitch : 1'b0;
assign areset_pulldown = ((port_areset == "PORT_CONNECTIVITY") ||
                        (port_areset == "PORT_USED")) ? areset : 1'b0;
assign scanclr_pulldown = ((port_scanaclr == "PORT_CONNECTIVITY") ||
                        (port_scanaclr == "PORT_USED")) ? scanaclr : 1'b0;

assign stratix_inclk = (family_has_stratix_style_pll) ? inclk_pulldown : {2{1'b0}};
assign stratix_fbin  = (family_has_stratix_style_pll) ? fbin_pulldown : 1'b0;
assign stratix_ena   = (family_has_stratix_style_pll) ? ena_pullup : 1'bZ;
assign stratix_clkswitch = (family_has_stratix_style_pll) ? clkswitch_pulldown : 1'b0;
assign stratix_areset  = (family_has_stratix_style_pll) ? areset_pulldown : 1'b0;
assign stratix_pfdena = (family_has_stratix_style_pll) ? pfdena_pullup : 1'b1;
assign stratix_clkena = (family_has_stratix_style_pll) ? clkena_pullup : {5{1'b0}};
assign stratix_extclkena = (family_has_stratix_style_pll) ? extclkena_pullup : {3{1'b0}};
assign stratix_scanclk = (family_has_stratix_style_pll) ? scanclk_pulldown : 1'b0;
assign stratix_scanclr = (family_has_stratix_style_pll) ? scanclr_pulldown : 1'b0;
assign stratix_scandata = (family_has_stratix_style_pll) ? scandata_pulldown : 1'b0;
assign stratixii_inclk = (family_has_stratixii_style_pll) ? inclk_pulldown : {2{1'b0}};
assign stratixii_fbin  = (family_has_stratixii_style_pll) ? fbin_pulldown : 1'b0;
assign stratixii_ena   = (family_has_stratixii_style_pll) ? ena_pullup : 1'bZ;
assign stratixii_clkswitch = (family_has_stratixii_style_pll) ? clkswitch_pulldown : 1'b0;
assign stratixii_areset = (family_has_stratixii_style_pll) ? areset_pulldown : 1'b0;
assign stratixii_pfdena = (family_has_stratixii_style_pll) ? pfdena_pullup : 1'b1;
assign stratixii_scanread = (family_has_stratixii_style_pll) ? scanread_pulldown : 1'b0;
assign stratixii_scanwrite = (family_has_stratixii_style_pll) ? scanwrite_pulldown : 1'b0;
assign stratixii_scanclk = (family_has_stratixii_style_pll) ? scanclk_pulldown : 1'b0;
assign stratixii_scandata = (family_has_stratixii_style_pll) ? scandata_pulldown : 1'b0;
assign stratix3_inclk = (family_stratixiii) ? inclk_pulldown : {2{1'b0}};
assign stratix3_clkswitch =  (family_stratixiii) ? clkswitch_pulldown : 1'b0;
assign stratix3_areset   = (family_stratixiii) ? areset_pulldown : 1'b0;
assign stratix3_pfdena  = (family_stratixiii) ? pfdena_pullup : 1'b1;
assign stratix3_scanclk = (family_stratixiii) ? scanclk_pulldown : 1'b0;
assign stratix3_phasecounterselect = (family_stratixiii) ? phasecounterselect_pulldown : {4{1'b0}};
assign cyclone3_inclk = (family_cycloneiii) ? inclk_pulldown : {2{1'b0}};
assign cyclone3_clkswitch =  (family_cycloneiii) ? clkswitch_pulldown : 1'b0;
assign cyclone3_areset   = (family_cycloneiii) ? areset_pulldown : 1'b0;
assign cyclone3_pfdena  = (family_cycloneiii) ? pfdena_pullup : 1'b1;
assign cyclone3_scanclk = (family_cycloneiii) ? scanclk_pulldown : 1'b0;
assign cyclone3_phasecounterselect = (family_cycloneiii) ? phasecounterselect_pulldown[2:0] : {3{1'b0}};
assign cyclone3gl_inclk = (family_cycloneiiigl) ? inclk_pulldown : {2{1'b0}};
assign cyclone3gl_clkswitch =  (family_cycloneiiigl) ? clkswitch_pulldown : 1'b0;
assign cyclone3gl_areset   = (family_cycloneiiigl) ? areset_pulldown : 1'b0;
assign cyclone3gl_pfdena  = (family_cycloneiiigl) ? pfdena_pullup : 1'b1;
assign cyclone3gl_scanclk = (family_cycloneiiigl) ? scanclk_pulldown : 1'b0;
assign cyclone3gl_phasecounterselect = (family_cycloneiiigl) ? phasecounterselect_pulldown[2:0] : {3{1'b0}};
assign scandone_wire =  (family_has_stratixii_style_pll) ? stratixii_scandone :
                        (family_stratixiii) ? stratix3_scandone :
                        (family_cycloneiii) ? cyclone3_scandone :
                        (family_cycloneiiigl) ? cyclone3gl_scandone :
                        1'b0;
assign scandone = (port_scandone != "PORT_UNUSED") ? scandone_wire : 1'b0;
assign clk_wire = (family_base_cycloneii) ? {7'b0, stratixii_clk[2:0]} :
                (family_has_stratixii_style_pll) ? {4'b0, stratixii_clk} :
                (family_stratixiii) ? {stratix3_clk} :
                (family_cycloneiii) ? {5'b0, cyclone3_clk} :
                (family_cycloneiiigl) ? {5'b0, cyclone3gl_clk} :
                {4'b0, stratix_clk};
assign clk_tmp[0] = (port_clk0 != "PORT_UNUSED") ? clk_wire[0] : 1'b0;
assign clk_tmp[1] = (port_clk1 != "PORT_UNUSED") ? clk_wire[1] : 1'b0;
assign clk_tmp[2] = (port_clk2 != "PORT_UNUSED") ? clk_wire[2] : 1'b0;
assign clk_tmp[3] = (port_clk3 != "PORT_UNUSED") ? clk_wire[3] : 1'b0;
assign clk_tmp[4] = (port_clk4 != "PORT_UNUSED") ? clk_wire[4] : 1'b0;
assign clk_tmp[5] = (port_clk5 != "PORT_UNUSED") ? clk_wire[5] : 1'b0;
assign clk_tmp[6] = (port_clk6 != "PORT_UNUSED") ? clk_wire[6] : 1'b0;
assign clk_tmp[7] = (port_clk7 != "PORT_UNUSED") ? clk_wire[7] : 1'b0;
assign clk_tmp[8] = (port_clk8 != "PORT_UNUSED") ? clk_wire[8] : 1'b0;
assign clk_tmp[9] = (port_clk9 != "PORT_UNUSED") ? clk_wire[9] : 1'b0;
assign clk = clk_tmp[width_clock-1:0];
assign extclk[0] = (port_extclk0 != "PORT_UNUSED") ? stratix_extclk[0] : 1'b0;
assign extclk[1] = (port_extclk1 != "PORT_UNUSED") ? stratix_extclk[1] : 1'b0;
assign extclk[2] = (port_extclk2 != "PORT_UNUSED") ? stratix_extclk[2] : 1'b0;
assign extclk[3] = (port_extclk3 != "PORT_UNUSED") ? stratix_extclk[3] : 1'b0;
assign clkbad_wire = (family_base_cycloneii) ? 2'b0 :
                (family_has_stratixii_style_pll) ? stratixii_clkbad :
                (family_stratixiii) ? stratix3_clkbad :
                (family_cycloneiii) ? cyclone3_clkbad :
                (family_cycloneiiigl) ? cyclone3gl_clkbad :
                stratix_clkbad;
assign clkbad[0] = (port_clkbad0 != "PORT_UNUSED") ? clkbad_wire[0] : 1'b0;
assign clkbad[1] = (port_clkbad1 != "PORT_UNUSED") ? clkbad_wire[1] : 1'b0;
assign activeclock_wire = (family_base_cycloneii) ? 1'b0 :
                    (family_has_stratixii_style_pll) ? stratixii_activeclock :
                    (family_stratixiii) ? stratix3_activeclock :
                    (family_cycloneiii) ? cyclone3_activeclock :
                    (family_cycloneiiigl) ? cyclone3gl_activeclock :
                    stratix_activeclock;
assign activeclock = (port_activeclock != "PORT_UNUSED") ? activeclock_wire : 1'b0;

assign pll_lock    = (family_stratixiii) ? stratix3_locked :
                    (family_cycloneiii) ? cyclone3_locked :
                    (family_cycloneiiigl) ? cyclone3gl_locked : 1'b0;

assign locked_wire = (family_has_stratixii_style_pll) ? stratixii_locked :
                    (family_stratixiii) ? stratix3_locked & pll_lock_sync:
                    (family_cycloneiii) ? cyclone3_locked & pll_lock_sync:
                    (family_cycloneiiigl) ? cyclone3gl_locked :
                    stratix_locked;
assign locked = (port_locked != "PORT_UNUSED") ? locked_wire : 1'b0;
assign stratix_locked = (alpha_tolower(pll_type) == "fast") ? (!locked_tmp) : locked_tmp;
assign clkloss_wire = (family_base_cycloneii) ? 1'b0 :
                    (family_has_stratixii_style_pll) ? stratixii_clkloss :
                    stratix_clkloss;
assign clkloss = (port_clkloss != "PORT_UNUSED") ? clkloss_wire : 1'b0;
assign scandataout_wire = (family_base_cycloneii) ? 1'b0 :
                    (family_has_stratixii_style_pll) ? stratixii_scandataout :
                    (family_stratixiii) ? stratix3_scandataout :
                    (family_cycloneiii) ? cyclone3_scandataout :
                    (family_cycloneiiigl) ? cyclone3gl_scandataout :
                    stratix_scandataout;
assign scandataout = (port_scandataout != "PORT_UNUSED") ? scandataout_wire : 1'b0;
assign enable0 = (family_base_cycloneii) ? 1'b0 :
                    (family_has_stratixii_style_pll) ? stratixii_enable0 :
                    stratix_enable0;
assign enable1 = (family_base_cycloneii) ? 1'b0 :
                    (family_has_stratixii_style_pll) ? stratixii_enable1 :
                    stratix_enable1;
assign sclkout0_wire = (family_has_stratixii_style_pll) ? stratixii_sclkout0 : 1'b0;
assign sclkout0 = (port_sclkout0 != "PORT_UNUSED") ? sclkout0_wire : 1'b0;
assign sclkout1_wire = (family_has_stratixii_style_pll) ? stratixii_sclkout1 : 1'b0;
assign sclkout1 = (port_sclkout1 != "PORT_UNUSED") ? sclkout1_wire : 1'b0;
assign phasedone_wire =  (family_stratixiii) ? stratix3_phasedone :
            (family_cycloneiii) ? cyclone3_phasedone :
            (family_cycloneiiigl) ? cyclone3gl_phasedone :
            1'b0;
assign phasedone = (port_phasedone != "PORT_UNUSED") ? phasedone_wire : 1'b0;
assign vcooverrange_wire =  (family_stratixiii) ? stratix3_vcooverrange :
            (family_cycloneiii) ? cyclone3_vcooverrange :
            (family_cycloneiiigl) ? cyclone3gl_vcooverrange :
            1'b0;
assign vcooverrange = (port_vcooverrange != "PORT_UNUSED") ? vcooverrange_wire : 1'b0;
assign vcounderrange_wire = (family_stratixiii) ? stratix3_vcounderrange :
            (family_cycloneiii) ? cyclone3_vcounderrange :
            (family_cycloneiiigl) ? cyclone3gl_vcounderrange :
            1'b0;
assign vcounderrange = (port_vcounderrange != "PORT_UNUSED") ? vcounderrange_wire : 1'b0;
assign fbout_wire =  (family_stratixiii) ? stratix3_fbout :
            (family_cycloneiii) ? cyclone3_fbout :
            (family_cycloneiiigl) ? cyclone3gl_fbout :
            1'b0;
assign fbout = (port_fbout != "PORT_UNUSED") ? fbout_wire : 1'b0;
assign fbmimicbidir = ((using_fbmimicbidir_port == "ON") && (alpha_tolower(operation_mode) == "zero_delay_buffer") && family_stratixiii && (family_arriaii == 0)) ? iobuf_io : 1'b0;
assign stratix3_fbin = ((using_fbmimicbidir_port == "ON") && (alpha_tolower(operation_mode) == "zero_delay_buffer") && family_stratixiii && (family_arriaii == 0)) ? iobuf_o : ((alpha_tolower(operation_mode) == "zero_delay_buffer") && family_arriaii) ? fbout_wire : fbin;

assign fref = cyclone3gl_fref;
assign icdrclk = cyclone3gl_icdrclk;

endmodule //altpll

