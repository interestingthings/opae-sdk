// Created by altera_lib_mf.pl from altera_mf.v

// END OF MODULE

//--------------------------------------------------------------------------
// Module Name      : altmult_accum
//
// Description      : a*b + x (MAC)
//
// Limitation       : Stratix DSP block
//
// Results expected : signed & unsigned, maximum of 3 pipelines(latency) each.
//
//--------------------------------------------------------------------------

`timescale 1 ps / 1 ps

/*verilator lint_off CASEX*/
/*verilator lint_off COMBDLY*/
/*verilator lint_off INITIALDLY*/
/*verilator lint_off LITENDIAN*/
/*verilator lint_off MULTIDRIVEN*/
/*verilator lint_off UNOPTFLAT*/
/*verilator lint_off BLKANDNBLK*/
module altmult_accum (  dataa,
                        datab,
			            datac,
                        scanina,
                        scaninb,
                        sourcea,
                        sourceb,
                        accum_sload_upper_data,
                        addnsub,
                        accum_sload,
                        signa,
                        signb,
                        clock0,
                        clock1,
                        clock2,
                        clock3,
                        ena0,
                        ena1,
                        ena2,
                        ena3,
                        aclr0,
                        aclr1,
                        aclr2,
                        aclr3,
                        result,
                        overflow,
                        scanouta,
                        scanoutb,
                        mult_round,
                        mult_saturation,
                        accum_round,
                        accum_saturation,
                        mult_is_saturated,
                        accum_is_saturated,
			            coefsel0,
		             	coefsel1,
			            coefsel2,
			            coefsel3);

    // ---------------------
    // PARAMETER DECLARATION
    // ---------------------
    parameter width_a                   = 2;
    parameter width_b                   = 2;
	parameter width_c					= 22;
    parameter width_result              = 5;
    parameter number_of_multipliers		= 1;
    parameter input_reg_a               = "CLOCK0";
    parameter input_aclr_a              = "ACLR3";
    parameter multiplier1_direction		= "UNUSED";
    parameter multiplier3_direction		= "UNUSED";

    parameter input_reg_b               = "CLOCK0";
    parameter input_aclr_b              = "ACLR3";
    parameter port_addnsub              = "PORT_CONNECTIVITY";
    parameter addnsub_reg               = "CLOCK0";
    parameter addnsub_aclr              = "ACLR3";
    parameter addnsub_pipeline_reg      = "CLOCK0";
    parameter addnsub_pipeline_aclr     = "ACLR3";
    parameter accum_direction           = "ADD";
    parameter accum_sload_reg           = "CLOCK0";
    parameter accum_sload_aclr          = "ACLR3";
    parameter accum_sload_pipeline_reg  = "CLOCK0";
    parameter accum_sload_pipeline_aclr = "ACLR3";
    parameter representation_a          = "UNSIGNED";
    parameter port_signa                = "PORT_CONNECTIVITY";
    parameter sign_reg_a                = "CLOCK0";
    parameter sign_aclr_a               = "ACLR3";
    parameter sign_pipeline_reg_a       = "CLOCK0";
    parameter sign_pipeline_aclr_a      = "ACLR3";
    parameter port_signb                = "PORT_CONNECTIVITY";
    parameter representation_b          = "UNSIGNED";
    parameter sign_reg_b                = "CLOCK0";
    parameter sign_aclr_b               = "ACLR3";
    parameter sign_pipeline_reg_b       = "CLOCK0";
    parameter sign_pipeline_aclr_b      = "ACLR3";
    parameter multiplier_reg            = "CLOCK0";
    parameter multiplier_aclr           = "ACLR3";
    parameter output_reg                = "CLOCK0";
    parameter output_aclr               = "ACLR3";
    parameter lpm_type                  = "altmult_accum";
    parameter lpm_hint                  = "UNUSED";

    parameter extra_multiplier_latency       = 0;
    parameter extra_accumulator_latency      = 0;
    parameter dedicated_multiplier_circuitry = "AUTO";
    parameter dsp_block_balancing            = "AUTO";
    parameter intended_device_family         = "Stratix";

    // StratixII related parameter
    parameter accum_round_aclr = "ACLR3";
    parameter accum_round_pipeline_aclr = "ACLR3";
    parameter accum_round_pipeline_reg = "CLOCK0";
    parameter accum_round_reg = "CLOCK0";
    parameter accum_saturation_aclr = "ACLR3";
    parameter accum_saturation_pipeline_aclr = "ACLR3";
    parameter accum_saturation_pipeline_reg = "CLOCK0";
    parameter accum_saturation_reg = "CLOCK0";
    parameter accum_sload_upper_data_aclr = "ACLR3";
    parameter accum_sload_upper_data_pipeline_aclr = "ACLR3";
    parameter accum_sload_upper_data_pipeline_reg = "CLOCK0";
    parameter accum_sload_upper_data_reg = "CLOCK0";
    parameter mult_round_aclr = "ACLR3";
    parameter mult_round_reg = "CLOCK0";
    parameter mult_saturation_aclr = "ACLR3";
    parameter mult_saturation_reg = "CLOCK0";

    parameter input_source_a  = "DATAA";
    parameter input_source_b  = "DATAB";
    parameter width_upper_data = 1;
    parameter multiplier_rounding = "NO";
    parameter multiplier_saturation = "NO";
    parameter accumulator_rounding = "NO";
    parameter accumulator_saturation = "NO";
    parameter port_mult_is_saturated = "UNUSED";
    parameter port_accum_is_saturated = "UNUSED";

// LOCAL_PARAMETERS_BEGIN

    parameter int_width_a = ((multiplier_saturation == "NO") && (multiplier_rounding == "NO") && (accumulator_saturation == "NO") && (accumulator_rounding == "NO")) ? width_a : 18;
    parameter int_width_b = ((multiplier_saturation == "NO") && (multiplier_rounding == "NO") && (accumulator_saturation == "NO") && (accumulator_rounding == "NO")) ? width_b : 18;
    parameter int_width_result = ((multiplier_saturation == "NO") && (multiplier_rounding == "NO") && (accumulator_saturation == "NO") && (accumulator_rounding == "NO")) ?
                                    ((int_width_a + int_width_b - 1) > width_result ? (int_width_a + int_width_b - 1) : width_result) :
                                    ((int_width_a + int_width_b - 1) > 52 ? (int_width_a + int_width_b - 1) : 52);
    parameter int_extra_width = ((multiplier_saturation == "NO") && (multiplier_rounding == "NO") && (accumulator_saturation == "NO") && (accumulator_rounding == "NO")) ? 0 : (int_width_a + int_width_b - width_a - width_b);
    parameter diff_width_a = (int_width_a > width_a) ? int_width_a - width_a : 1;
    parameter diff_width_b = (int_width_b > width_b) ? int_width_b - width_b : 1;
    parameter sat_for_ini = ((multiplier_saturation == "NO") && (accumulator_saturation == "NO")) ? 0 : (int_width_a + int_width_b - 34);
    parameter mult_round_for_ini = ((multiplier_rounding == "NO")? 0 : (int_width_a + int_width_b - 18));
    parameter bits_to_round = (((multiplier_rounding == "NO") && (accumulator_rounding == "NO"))? 0 : int_width_a + int_width_b - 18);
    parameter sload_for_limit = (width_result < width_upper_data)? width_result + int_extra_width : width_upper_data ;
    parameter accum_sat_for_limit = ((accumulator_saturation == "NO")? int_width_result - 1 : int_width_a + int_width_b - 33 );
    parameter int_width_extra_bit = (int_width_result - int_width_a - int_width_b > 0) ? int_width_result - int_width_a - int_width_b : 0;
	//StratixV parameters
  	parameter preadder_mode	= "SIMPLE";
  	parameter loadconst_value = 0;
  	parameter width_coef = 0;

  	parameter loadconst_control_register = "CLOCK0";
  	parameter loadconst_control_aclr	= "ACLR0";

	parameter coefsel0_register = "CLOCK0";
  	parameter coefsel1_register	= "CLOCK0";
  	parameter coefsel2_register	= "CLOCK0";
  	parameter coefsel3_register	= "CLOCK0";
   	parameter coefsel0_aclr	= "ACLR0";
   	parameter coefsel1_aclr	= "ACLR0";
	parameter coefsel2_aclr	= "ACLR0";
   	parameter coefsel3_aclr	= "ACLR0";

   	parameter preadder_direction_0	= "ADD";
	parameter preadder_direction_1	= "ADD";
	parameter preadder_direction_2	= "ADD";
	parameter preadder_direction_3	= "ADD";

	parameter systolic_delay1 = "UNREGISTERED";
	parameter systolic_delay3 = "UNREGISTERED";
	parameter systolic_aclr1 = "NONE";
	parameter systolic_aclr3 = "NONE";

	//coefficient storage
	parameter coef0_0 = 0;
	parameter coef0_1 = 0;
	parameter coef0_2 = 0;
	parameter coef0_3 = 0;
	parameter coef0_4 = 0;
	parameter coef0_5 = 0;
	parameter coef0_6 = 0;
	parameter coef0_7 = 0;

	parameter coef1_0 = 0;
	parameter coef1_1 = 0;
	parameter coef1_2 = 0;
	parameter coef1_3 = 0;
	parameter coef1_4 = 0;
	parameter coef1_5 = 0;
	parameter coef1_6 = 0;
	parameter coef1_7 = 0;

	parameter coef2_0 = 0;
	parameter coef2_1 = 0;
	parameter coef2_2 = 0;
	parameter coef2_3 = 0;
	parameter coef2_4 = 0;
	parameter coef2_5 = 0;
	parameter coef2_6 = 0;
	parameter coef2_7 = 0;

	parameter coef3_0 = 0;
	parameter coef3_1 = 0;
	parameter coef3_2 = 0;
	parameter coef3_3 = 0;
	parameter coef3_4 = 0;
	parameter coef3_5 = 0;
	parameter coef3_6 = 0;
	parameter coef3_7 = 0;

// LOCAL_PARAMETERS_END

    // ----------------
    // PORT DECLARATION
    // ----------------

    // data input ports
    input [width_a -1 : 0] dataa;
    input [width_b -1 : 0] datab;
	input [width_c -1 : 0] datac;
    input [width_a -1 : 0] scanina;
    input [width_b -1 : 0] scaninb;
    input sourcea;
    input sourceb;
    input [width_result -1 : width_result - width_upper_data] accum_sload_upper_data;

    // control signals
    input addnsub;
    input accum_sload;
    input signa;
    input signb;

    // clock ports
    input clock0;
    input clock1;
    input clock2;
    input clock3;

    // clock enable ports
    input ena0;
    input ena1;
    input ena2;
    input ena3;

    // clear ports
    input aclr0;
    input aclr1;
    input aclr2;
    input aclr3;

    // round and saturate ports
    input mult_round;
    input mult_saturation;
    input accum_round;
    input accum_saturation;

	//StratixV only input ports
	input [2:0]coefsel0;
	input [2:0]coefsel1;
	input [2:0]coefsel2;
	input [2:0]coefsel3;

    // output ports
    output [width_result -1 : 0] result;
    output overflow;
    output [width_a -1 : 0] scanouta;
    output [width_b -1 : 0] scanoutb;

    output mult_is_saturated;
    output accum_is_saturated;


    // ---------------
    // REG DECLARATION
    // ---------------
    reg [width_result -1 : 0] result;

    reg [int_width_result -1 : 0] mult_res_out;
    reg [int_width_result : 0] temp_sum;


    reg [width_result + 1 : 0] result_pipe [extra_accumulator_latency : 0];
    reg [width_result + 1 : 0] result_full ;

    reg [int_width_result - 1 : 0] result_int;

    reg [int_width_a - 1 : 0] mult_a_reg;
    reg [int_width_a - 1 : 0] mult_a_int;
    reg [int_width_a + int_width_b - 1 : 0] mult_res;
    reg [int_width_a + int_width_b - 1 : 0] temp_mult_1;
    reg [int_width_a + int_width_b - 1 : 0] temp_mult;


    reg [int_width_b -1 :0] mult_b_reg;
    reg [int_width_b -1 :0] mult_b_int;

    reg [5 + int_width_a + int_width_b + width_upper_data : 0] mult_pipe [extra_multiplier_latency:0];
    reg [5 + int_width_a + int_width_b + width_upper_data : 0] mult_full;

    reg [width_upper_data - 1 : 0] sload_upper_data_reg;

    reg [width_result - width_upper_data -1 + 4 : 0] lower_bits;

    reg mult_signed_out;
    reg [width_upper_data - 1 : 0] sload_upper_data_pipe_reg;


    reg zero_acc_reg;
    reg zero_acc_pipe_reg;
    reg sign_a_reg;
    reg sign_a_pipe_reg;
    reg sign_b_reg;
    reg sign_b_pipe_reg;
    reg addsub_reg;
    reg addsub_pipe_reg;

    reg mult_signed;
    reg temp_mult_signed;
    reg neg_a;
    reg neg_b;

    reg overflow_int;
    reg cout_int;
    reg overflow_tmp_int;

    reg overflow;

    reg [int_width_a + int_width_b -1 : 0] mult_round_out;
    reg mult_saturate_overflow;
    reg [int_width_a + int_width_b -1 : 0] mult_saturate_out;
    reg [int_width_a + int_width_b -1 : 0] mult_result;
    reg [int_width_a + int_width_b -1 : 0] mult_final_out;

    reg [int_width_result -1 : 0] accum_round_out;
    reg accum_saturate_overflow;
    reg [int_width_result -1 : 0] accum_saturate_out;
    reg [int_width_result -1 : 0] accum_result;
    reg [int_width_result -1 : 0] accum_final_out;

    logic mult_is_saturated_latent; // -- converted tristate to logic
    reg mult_is_saturated_int;
    reg mult_is_saturated_reg;

    reg accum_is_saturated_latent;
    reg [extra_accumulator_latency : 0] accum_saturate_pipe;
    reg [extra_accumulator_latency : 0] mult_is_saturated_pipe;

    reg  mult_round_tmp;
    reg  mult_saturation_tmp;
    reg  accum_round_tmp1;
    reg  accum_round_tmp2;
    reg  accum_saturation_tmp1;
    reg  accum_saturation_tmp2;
    reg is_stratixv;
    reg is_stratixiii;
    reg is_stratixii;
    reg is_cycloneii;

    reg  [int_width_result - int_width_a - int_width_b + 2 - 1 : 0] accum_result_sign_bits;

    reg [31:0] head_result;

    // -------------------
    // INTEGER DECLARATION
    // -------------------
    integer i;
    integer i2;
    integer i3;
    integer i4;
    integer head_mult;
    integer flag;


    //-----------------
    // TRI DECLARATION
    //-----------------

    logic [width_a -1 : 0] dataa; // -- converted tristate to logic
    logic [width_b -1 : 0] datab; // -- converted tristate to logic
    logic [width_a -1 : 0] scanina; // -- converted tristate to logic
    logic [width_b -1 : 0] scaninb; // -- converted tristate to logic
    logic sourcea; // -- converted tristate to logic
    logic sourceb; // -- converted tristate to logic
    logic ena0; // -- converted tristate to logic
    logic ena1; // -- converted tristate to logic
    logic ena2; // -- converted tristate to logic
    logic ena3; // -- converted tristate to logic
    logic aclr0; // -- converted tristate to logic
    logic aclr1; // -- converted tristate to logic
    logic aclr2; // -- converted tristate to logic
    logic aclr3; // -- converted tristate to logic
    logic mult_round; // -- converted tristate to logic
    logic mult_saturation; // -- converted tristate to logic
    logic accum_round; // -- converted tristate to logic
    logic accum_saturation; // -- converted tristate to logic

    // Tri wire for clear signal

    logic input_a_wire_clr; // -- converted tristate to logic
    logic input_b_wire_clr; // -- converted tristate to logic

    logic addsub_wire_clr; // -- converted tristate to logic
    logic addsub_pipe_wire_clr; // -- converted tristate to logic

    logic zero_wire_clr; // -- converted tristate to logic
    logic zero_pipe_wire_clr; // -- converted tristate to logic

    logic sign_a_wire_clr; // -- converted tristate to logic
    logic sign_pipe_a_wire_clr; // -- converted tristate to logic

    logic sign_b_wire_clr; // -- converted tristate to logic
    logic sign_pipe_b_wire_clr; // -- converted tristate to logic

    logic multiplier_wire_clr; // -- converted tristate to logic
    logic mult_pipe_wire_clr; // -- converted tristate to logic

    logic output_wire_clr; // -- converted tristate to logic

    logic mult_round_wire_clr; // -- converted tristate to logic
    logic mult_saturation_wire_clr; // -- converted tristate to logic

    logic accum_round_wire_clr; // -- converted tristate to logic
    logic accum_round_pipe_wire_clr; // -- converted tristate to logic

    logic accum_saturation_wire_clr; // -- converted tristate to logic
    logic accum_saturation_pipe_wire_clr; // -- converted tristate to logic

    logic accum_sload_upper_data_wire_clr; // -- converted tristate to logic
    logic accum_sload_upper_data_pipe_wire_clr; // -- converted tristate to logic


    // Tri wire for enable signal

    logic input_a_wire_en; // -- converted tristate to logic
    logic input_b_wire_en; // -- converted tristate to logic

    logic addsub_wire_en; // -- converted tristate to logic
    logic addsub_pipe_wire_en; // -- converted tristate to logic

    logic zero_wire_en; // -- converted tristate to logic
    logic zero_pipe_wire_en; // -- converted tristate to logic

    logic sign_a_wire_en; // -- converted tristate to logic
    logic sign_pipe_a_wire_en; // -- converted tristate to logic

    logic sign_b_wire_en; // -- converted tristate to logic
    logic sign_pipe_b_wire_en; // -- converted tristate to logic

    logic multiplier_wire_en; // -- converted tristate to logic
    logic mult_pipe_wire_en; // -- converted tristate to logic

    logic output_wire_en; // -- converted tristate to logic

    logic mult_round_wire_en; // -- converted tristate to logic
    logic mult_saturation_wire_en; // -- converted tristate to logic

    logic accum_round_wire_en; // -- converted tristate to logic
    logic accum_round_pipe_wire_en; // -- converted tristate to logic

    logic accum_saturation_wire_en; // -- converted tristate to logic
    logic accum_saturation_pipe_wire_en; // -- converted tristate to logic

    logic accum_sload_upper_data_wire_en; // -- converted tristate to logic
    logic accum_sload_upper_data_pipe_wire_en; // -- converted tristate to logic

    // ------------------------
    // SUPPLY WIRE DECLARATION
    // ------------------------

    supply0 [int_width_a + int_width_b - 1 : 0] temp_mult_zero;


    // ----------------
    // WIRE DECLARATION
    // ----------------

    // Wire for Clock signals

    wire input_a_wire_clk;
    wire input_b_wire_clk;

    wire addsub_wire_clk;
    wire addsub_pipe_wire_clk;

    wire zero_wire_clk;
    wire zero_pipe_wire_clk;

    wire sign_a_wire_clk;
    wire sign_pipe_a_wire_clk;

    wire sign_b_wire_clk;
    wire sign_pipe_b_wire_clk;

    wire multiplier_wire_clk;
    wire mult_pipe_wire_clk;

    wire output_wire_clk;

    wire [width_a -1 : 0] scanouta;
    wire [int_width_a + int_width_b -1 : 0] mult_out_latent;
    wire [width_b -1 : 0] scanoutb;

    wire addsub_int;
    wire sign_a_int;
    wire sign_b_int;

    wire zero_acc_int;
    wire sign_a_reg_int;
    wire sign_b_reg_int;

    wire addsub_latent;
    wire zeroacc_latent;
    wire signa_latent;
    wire signb_latent;
    wire mult_signed_latent;

    wire [width_upper_data - 1 : 0] sload_upper_data_latent;
    reg [int_width_result - 1 : 0] sload_upper_data_pipe_wire;

    wire [int_width_a -1 :0] mult_a_wire;
    wire [int_width_b -1 :0] mult_b_wire;
    wire [width_upper_data - 1 : 0] sload_upper_data_wire;
    reg [int_width_a -1 : 0] mult_a_tmp;
    reg [int_width_b -1 : 0] mult_b_tmp;

    wire zero_acc_wire;
    wire zero_acc_pipe_wire;

    wire sign_a_wire;
    wire sign_a_pipe_wire;
    wire sign_b_wire;
    wire sign_b_pipe_wire;

    wire addsub_wire;
    wire addsub_pipe_wire;

    wire mult_round_int;
    wire mult_round_wire_clk;
    wire mult_saturation_int;
    wire mult_saturation_wire_clk;

    wire accum_round_tmp1_wire;
    wire accum_round_wire_clk;
    wire accum_round_int;
    wire accum_round_pipe_wire_clk;

    wire accum_saturation_tmp1_wire;
    wire accum_saturation_wire_clk;
    wire accum_saturation_int;
    wire accum_saturation_pipe_wire_clk;

    wire accum_sload_upper_data_wire_clk;
    wire accum_sload_upper_data_pipe_wire_clk;
    wire [width_result -1 : width_result - width_upper_data] accum_sload_upper_data_int;

    logic mult_is_saturated_wire; // -- converted tristate to logic

    wire [31:0] head_result_wire;

    // ------------------------
    // COMPONENT INSTANTIATIONS
    // ------------------------
    ALTERA_DEVICE_FAMILIES dev ();


    // --------------------
    // ASSIGNMENT STATEMENTS
    // --------------------


    assign addsub_int = (port_addnsub == "PORT_USED") ? addsub_pipe_wire :
                                (port_addnsub == "PORT_UNUSED") ? ((accum_direction == "ADD") ? 1'b1 : 1'b0) :
                                    ((addnsub ===1'b0 /* converted x or z to 1'b0 */) ||
                                    (addsub_wire_clk ===1'b0 /* converted x or z to 1'b0 */) ||
                                    (addsub_pipe_wire_clk ===1'b0 /* converted x or z to 1'b0 */)) ?
                                        ((accum_direction == "ADD") ? 1'b1 : 1'b0) : addsub_pipe_wire;

    assign sign_a_int = (port_signa == "PORT_USED") ? sign_a_pipe_wire :
                                (port_signa == "PORT_UNUSED") ? ((representation_a == "SIGNED") ? 1'b1 : 1'b0) :
                                    ((signa ===1'b0 /* converted x or z to 1'b0 */) ||
                                    (sign_a_wire_clk ===1'b0 /* converted x or z to 1'b0 */) ||
                                    (sign_pipe_a_wire_clk ===1'b0 /* converted x or z to 1'b0 */)) ?
                                        ((representation_a == "SIGNED") ? 1'b1 : 1'b0) : sign_a_pipe_wire;

    assign sign_b_int = (port_signb == "PORT_USED") ? sign_b_pipe_wire :
                                (port_signb == "PORT_UNUSED") ? ((representation_b == "SIGNED") ? 1'b1 : 1'b0) :
                                    ((signb ===1'b0 /* converted x or z to 1'b0 */) ||
                                    (sign_b_wire_clk ===1'b0 /* converted x or z to 1'b0 */) ||
                                    (sign_pipe_b_wire_clk ===1'b0 /* converted x or z to 1'b0 */)) ?
                                        ((representation_b == "SIGNED") ? 1'b1 : 1'b0) : sign_b_pipe_wire;



    assign sign_a_reg_int = (port_signa == "PORT_USED") ? sign_a_wire :
                                (port_signa == "PORT_UNUSED") ? ((representation_a == "SIGNED") ? 1'b1 : 1'b0) :
                                    ((signa ===1'b0 /* converted x or z to 1'b0 */) ||
                                    (sign_a_wire_clk ===1'b0 /* converted x or z to 1'b0 */) ||
                                    (sign_pipe_a_wire_clk ===1'b0 /* converted x or z to 1'b0 */)) ?
                                        ((representation_a == "SIGNED") ? 1'b1 : 1'b0) : sign_a_wire;

    assign sign_b_reg_int = (port_signb == "PORT_USED") ? sign_b_wire :
                                (port_signb == "PORT_UNUSED") ? ((representation_b == "SIGNED") ? 1'b1 : 1'b0) :
                                    ((signb ===1'b0 /* converted x or z to 1'b0 */) ||
                                    (sign_b_wire_clk ===1'b0 /* converted x or z to 1'b0 */) ||
                                    (sign_pipe_b_wire_clk ===1'b0 /* converted x or z to 1'b0 */)) ?
                                        ((representation_b == "SIGNED") ? 1'b1 : 1'b0) : sign_b_wire;

    assign zero_acc_int   = ((accum_sload ===1'b0 /* converted x or z to 1'b0 */) ||
                            (zero_wire_clk===1'b0 /* converted x or z to 1'b0 */) ||
                            (zero_pipe_wire_clk===1'b0 /* converted x or z to 1'b0 */)) ?
                                1'b0 : zero_acc_pipe_wire;

    assign accum_sload_upper_data_int = ((accum_sload_upper_data === {width_upper_data{1'b0 /* converted x or z to 1'b0 */}}) ||
                                        (accum_sload_upper_data_wire_clk === 1'b0 /* converted x or z to 1'b0 */) ||
                                        (accum_sload_upper_data_pipe_wire_clk === 1'b0 /* converted x or z to 1'b0 */)) ?
                                            {width_upper_data{1'b0}} : accum_sload_upper_data;

    assign scanouta       = mult_a_wire[int_width_a - 1 : int_width_a - width_a];
    assign scanoutb       = mult_b_wire[int_width_b - 1 : int_width_b - width_b];

    assign {addsub_latent, zeroacc_latent, signa_latent, signb_latent, mult_signed_latent, mult_out_latent, sload_upper_data_latent, mult_is_saturated_latent} = (extra_multiplier_latency > 0) ?
                mult_full : {addsub_wire, zero_acc_wire, sign_a_wire, sign_b_wire, temp_mult_signed, mult_final_out, sload_upper_data_wire, mult_saturate_overflow};

    assign mult_is_saturated = (port_mult_is_saturated != "UNUSED") ? mult_is_saturated_int : 1'b0;
    assign accum_is_saturated = (port_accum_is_saturated != "UNUSED") ? accum_is_saturated_latent : 1'b0;

    // ---------------------------------------------------------------------------------
    // Initialization block where all the internal signals and registers are initialized
    // ---------------------------------------------------------------------------------
    initial
    begin

        is_stratixv = dev.FEATURE_FAMILY_STRATIXV(intended_device_family);
        is_stratixiii = dev.FEATURE_FAMILY_STRATIXIII(intended_device_family);
        is_stratixii = dev.FEATURE_FAMILY_STRATIXII(intended_device_family);
        is_cycloneii = dev.FEATURE_FAMILY_CYCLONEII(intended_device_family);

        // Checking for invalid parameters, in case Wizard is bypassed (hand-modified).

		//ALTMULT_ADD EOL FAMILY CHECKS
		if(dev.FEATURE_FAMILY_IS_ALTMULT_ADD_EOL(intended_device_family) == 1)
		begin
				$display ("Error: ALTMULT_ADD is EOL for %s device family", intended_device_family);
				$display("Time: %0t  Instance: %m", $time);
				$stop;
		end
		//Legality check, block new family from running pre_layout simulation using altera_mf (family with altera_mult_add flow)
		if(dev.FEATURE_FAMILY_HAS_ALTERA_MULT_ADD_FLOW(intended_device_family) == 1)
		begin
				$display ("Error: ALTMULT_ACCUM is not supported for %s device family", intended_device_family);
				$display("Time: %0t  Instance: %m", $time);
				$stop;
		end

        if ((dedicated_multiplier_circuitry != "AUTO") &&
            (dedicated_multiplier_circuitry != "YES") &&
            (dedicated_multiplier_circuitry != "NO"))
        begin
            $display("Error: The DEDICATED_MULTIPLIER_CIRCUITRY parameter is set to an illegal value.");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end
        if (width_a <= 0)
        begin
            $display("Error: width_a must be greater than 0.");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end
        if (width_b <= 0)
        begin
            $display("Error: width_b must be greater than 0.");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end
        if (width_result <= 0)
        begin
            $display("Error: width_result must be greater than 0.");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if (( (is_stratixii == 0) &&
                (is_cycloneii == 0))
                && (input_source_a != "DATAA"))
        begin
            $display("Error: The input source for port A are limited to input dataa.");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if (( (is_stratixii == 0) &&
            (is_cycloneii == 0))
            && (input_source_b != "DATAB"))
        begin
            $display("Error: The input source for port B are limited to input datab.");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((is_stratixii == 0) && (multiplier_rounding != "NO"))
        begin
            $display("Error: There is no rounding feature for %s device.", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((is_stratixii == 0) && (accumulator_rounding != "NO"))
        begin
            $display("Error: There is no rounding feature for %s device.", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((is_stratixii == 0) && (multiplier_saturation != "NO"))
        begin
            $display("Error: There is no saturation feature for %s device.", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((is_stratixii == 0) && (accumulator_saturation != "NO"))
        begin
            $display("Error: There is no saturation feature for %s device.", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((is_stratixiii) && (port_addnsub != "PORT_UNUSED"))
        begin
            $display ("Error: The addnsub port is not available for %s device.", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((is_stratixiii) && (accum_direction != "ADD") &&
            (accum_direction != "SUB"))
        begin
            $display ("Error: Invalid value for ACCUM_DIRECTION parameter for %s device.", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((is_stratixiii) && (input_source_a == "VARIABLE"))
        begin
            $display ("Error: Invalid value for INPUT_SOURCE_A parameter for %s device.", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end


        temp_sum             = 0;
        head_result          = 0;
        head_mult            = 0;
        overflow_int         = 0;
        mult_a_reg           = 0;
        mult_b_reg           = 0;
        flag                 = 0;

        zero_acc_reg         = 0;
        zero_acc_pipe_reg     = 0;
        sload_upper_data_reg = 0;
        lower_bits           = 0;
        sload_upper_data_pipe_reg = 0;

        sign_a_reg  = (signa ===1'b0 /* converted x or z to 1'b0 */)   ? ((representation_a == "SIGNED") ? 1 : 0) : 0;
        sign_a_pipe_reg = (signa ===1'b0 /* converted x or z to 1'b0 */)   ? ((representation_a == "SIGNED") ? 1 : 0) : 0;
        sign_b_reg  = (signb ===1'b0 /* converted x or z to 1'b0 */)   ? ((representation_b == "SIGNED") ? 1 : 0) : 0;
        sign_b_pipe_reg = (signb ===1'b0 /* converted x or z to 1'b0 */)   ? ((representation_b == "SIGNED") ? 1 : 0) : 0;
        addsub_reg  = (addnsub ===1'b0 /* converted x or z to 1'b0 */) ? ((accum_direction == "ADD")     ? 1 : 0) : 0;
        addsub_pipe_reg = (addnsub ===1'b0 /* converted x or z to 1'b0 */) ? ((accum_direction == "ADD")     ? 1 : 0) : 0;

        result_int      = 0;
        result          = 0;
        overflow        = 0;
        mult_full       = 0;
        mult_res_out    = 0;
        mult_signed_out = 0;
        mult_res        = 0;

        mult_is_saturated_int = 0;
        mult_is_saturated_reg = 0;
        mult_saturation_tmp = 0;
        mult_saturate_overflow = 0;

        accum_result = 0;
        accum_saturate_overflow = 0;
        accum_is_saturated_latent = 0;

        mult_a_tmp = 0;
        mult_b_tmp = 0;
        mult_final_out = 0;
        temp_mult = 0;
        temp_mult_signed = 0;

        for (i=0; i<=extra_accumulator_latency; i=i+1)
        begin
            result_pipe [i] = 0;
            accum_saturate_pipe[i] = 0;
            mult_is_saturated_pipe[i] = 0;
        end

        for (i=0; i<= extra_multiplier_latency; i=i+1)
        begin
            mult_pipe [i] = 0;
        end

    end


    // ---------------------------------------------------------
    // This block updates the internal clock signals accordingly
    // every time the global clock signal changes state
    // ---------------------------------------------------------

    assign input_a_wire_clk =   (input_reg_a == "CLOCK0")? clock0:
                                (input_reg_a == "UNREGISTERED")? 1'b0:
                                (input_reg_a == "CLOCK1")? clock1:
                                (input_reg_a == "CLOCK2")? clock2:
                                (input_reg_a == "CLOCK3")? clock3: 1'b0;

    assign input_b_wire_clk =   (input_reg_b == "CLOCK0")? clock0:
                                (input_reg_b == "UNREGISTERED")? 1'b0:
                                (input_reg_b == "CLOCK1")? clock1:
                                (input_reg_b == "CLOCK2")? clock2:
                                (input_reg_b == "CLOCK3")? clock3: 1'b0;


    assign addsub_wire_clk =    (addnsub_reg == "CLOCK0")? clock0:
                                (addnsub_reg == "UNREGISTERED")? 1'b0:
                                (addnsub_reg == "CLOCK1")? clock1:
                                (addnsub_reg == "CLOCK2")? clock2:
                                (addnsub_reg == "CLOCK3")? clock3: 1'b0;


    assign addsub_pipe_wire_clk =   (addnsub_pipeline_reg == "CLOCK0")? clock0:
                                    (addnsub_pipeline_reg == "UNREGISTERED")? 1'b0:
                                    (addnsub_pipeline_reg == "CLOCK1")? clock1:
                                    (addnsub_pipeline_reg == "CLOCK2")? clock2:
                                    (addnsub_pipeline_reg == "CLOCK3")? clock3: 1'b0;


    assign zero_wire_clk =  (accum_sload_reg == "CLOCK0")? clock0:
                            (accum_sload_reg == "UNREGISTERED")? 1'b0:
                            (accum_sload_reg == "CLOCK1")? clock1:
                            (accum_sload_reg == "CLOCK2")? clock2:
                            (accum_sload_reg == "CLOCK3")? clock3: 1'b0;

    assign accum_sload_upper_data_wire_clk =    (accum_sload_upper_data_reg == "CLOCK0")? clock0:
                                                (accum_sload_upper_data_reg == "UNREGISTERED")? 1'b0:
                                                (accum_sload_upper_data_reg == "CLOCK1")? clock1:
                                                (accum_sload_upper_data_reg == "CLOCK2")? clock2:
                                                (accum_sload_upper_data_reg == "CLOCK3")? clock3: 1'b0;

    assign zero_pipe_wire_clk = (accum_sload_pipeline_reg == "CLOCK0")? clock0:
                                (accum_sload_pipeline_reg == "UNREGISTERED")? 1'b0:
                                (accum_sload_pipeline_reg == "CLOCK1")? clock1:
                                (accum_sload_pipeline_reg == "CLOCK2")? clock2:
                                (accum_sload_pipeline_reg == "CLOCK3")? clock3: 1'b0;

    assign accum_sload_upper_data_pipe_wire_clk =   (accum_sload_upper_data_pipeline_reg == "CLOCK0")? clock0:
                                                    (accum_sload_upper_data_pipeline_reg == "UNREGISTERED")? 1'b0:
                                                    (accum_sload_upper_data_pipeline_reg == "CLOCK1")? clock1:
                                                    (accum_sload_upper_data_pipeline_reg == "CLOCK2")? clock2:
                                                    (accum_sload_upper_data_pipeline_reg == "CLOCK3")? clock3: 1'b0;

    assign sign_a_wire_clk =(sign_reg_a == "CLOCK0")? clock0:
                            (sign_reg_a == "UNREGISTERED")? 1'b0:
                            (sign_reg_a == "CLOCK1")? clock1:
                            (sign_reg_a == "CLOCK2")? clock2:
                            (sign_reg_a == "CLOCK3")? clock3: 1'b0;


    assign sign_b_wire_clk =(sign_reg_b == "CLOCK0")? clock0:
                            (sign_reg_b == "UNREGISTERED")? 1'b0:
                            (sign_reg_b == "CLOCK1")? clock1:
                            (sign_reg_b == "CLOCK2")? clock2:
                            (sign_reg_b == "CLOCK3")? clock3: 1'b0;



    assign sign_pipe_a_wire_clk = (sign_pipeline_reg_a == "CLOCK0")? clock0:
                            (sign_pipeline_reg_a == "UNREGISTERED")? 1'b0:
                            (sign_pipeline_reg_a == "CLOCK1")? clock1:
                            (sign_pipeline_reg_a == "CLOCK2")? clock2:
                            (sign_pipeline_reg_a == "CLOCK3")? clock3: 1'b0;


    assign sign_pipe_b_wire_clk = (sign_pipeline_reg_b == "CLOCK0")? clock0:
                            (sign_pipeline_reg_b == "UNREGISTERED")? 1'b0:
                            (sign_pipeline_reg_b == "CLOCK1")? clock1:
                            (sign_pipeline_reg_b == "CLOCK2")? clock2:
                            (sign_pipeline_reg_b == "CLOCK3")? clock3: 1'b0;


    assign multiplier_wire_clk =(multiplier_reg == "CLOCK0")? clock0:
                                (multiplier_reg == "UNREGISTERED")? 1'b0:
                                (multiplier_reg == "CLOCK1")? clock1:
                                (multiplier_reg == "CLOCK2")? clock2:
                                (multiplier_reg == "CLOCK3")? clock3: 1'b0;

    assign output_wire_clk =    (output_reg == "CLOCK0")? clock0:
                                (output_reg == "UNREGISTERED")? 1'b0:
                                (output_reg == "CLOCK1")? clock1:
                                (output_reg == "CLOCK2")? clock2:
                                (output_reg == "CLOCK3")? clock3: 1'b0;


    assign mult_pipe_wire_clk  =   (multiplier_reg == "UNREGISTERED")? clock0:
                                    multiplier_wire_clk;

    assign mult_round_wire_clk =(mult_round_reg == "CLOCK0")? clock0:
                                (mult_round_reg == "UNREGISTERED")? 1'b0:
                                (mult_round_reg == "CLOCK1")? clock1:
                                (mult_round_reg == "CLOCK2")? clock2:
                                (mult_round_reg == "CLOCK3")? clock3: 1'b0;

    assign mult_saturation_wire_clk = (mult_saturation_reg == "CLOCK0")? clock0:
                            (mult_saturation_reg == "UNREGISTERED")? 1'b0:
                            (mult_saturation_reg == "CLOCK1")? clock1:
                            (mult_saturation_reg == "CLOCK2")? clock2:
                            (mult_saturation_reg == "CLOCK3")? clock3: 1'b0;

    assign accum_round_wire_clk = (accum_round_reg == "CLOCK0")? clock0:
                            (accum_round_reg == "UNREGISTERED")? 1'b0:
                            (accum_round_reg == "CLOCK1")? clock1:
                            (accum_round_reg == "CLOCK2")? clock2:
                            (accum_round_reg == "CLOCK3")? clock3: 1'b0;

    assign accum_round_pipe_wire_clk = (accum_round_pipeline_reg == "CLOCK0")? clock0:
                            (accum_round_pipeline_reg == "UNREGISTERED")? 1'b0:
                            (accum_round_pipeline_reg == "CLOCK1")? clock1:
                            (accum_round_pipeline_reg == "CLOCK2")? clock2:
                            (accum_round_pipeline_reg == "CLOCK3")? clock3: 1'b0;

    assign accum_saturation_wire_clk = (accum_saturation_reg == "CLOCK0")? clock0:
                            (accum_saturation_reg == "UNREGISTERED")? 1'b0:
                            (accum_saturation_reg == "CLOCK1")? clock1:
                            (accum_saturation_reg == "CLOCK2")? clock2:
                            (accum_saturation_reg == "CLOCK3")? clock3: 1'b0;

    assign accum_saturation_pipe_wire_clk = (accum_saturation_pipeline_reg == "CLOCK0")? clock0:
                            (accum_saturation_pipeline_reg == "UNREGISTERED")? 1'b0:
                            (accum_saturation_pipeline_reg == "CLOCK1")? clock1:
                            (accum_saturation_pipeline_reg == "CLOCK2")? clock2:
                            (accum_saturation_pipeline_reg == "CLOCK3")? clock3: 1'b0;


    // ----------------------------------------------------------------
    // This block updates the internal clock enable signals accordingly
    // every time the global clock enable signal changes state
    // ----------------------------------------------------------------



    assign input_a_wire_en =(input_reg_a == "CLOCK0")? ena0:
                            (input_reg_a == "UNREGISTERED")? 1'b1:
                            (input_reg_a == "CLOCK1")? ena1:
                            (input_reg_a == "CLOCK2")? ena2:
                            (input_reg_a == "CLOCK3")? ena3: 1'b1;

    assign input_b_wire_en =(input_reg_b == "CLOCK0")? ena0:
                            (input_reg_b == "UNREGISTERED")? 1'b1:
                            (input_reg_b == "CLOCK1")? ena1:
                            (input_reg_b == "CLOCK2")? ena2:
                            (input_reg_b == "CLOCK3")? ena3: 1'b1;


    assign addsub_wire_en = (addnsub_reg == "CLOCK0")? ena0:
                            (addnsub_reg == "UNREGISTERED")? 1'b1:
                            (addnsub_reg == "CLOCK1")? ena1:
                            (addnsub_reg == "CLOCK2")? ena2:
                            (addnsub_reg == "CLOCK3")? ena3: 1'b1;


    assign addsub_pipe_wire_en =(addnsub_pipeline_reg == "CLOCK0")? ena0:
                                (addnsub_pipeline_reg == "UNREGISTERED")? 1'b1:
                                (addnsub_pipeline_reg == "CLOCK1")? ena1:
                                (addnsub_pipeline_reg == "CLOCK2")? ena2:
                                (addnsub_pipeline_reg == "CLOCK3")? ena3: 1'b1;


    assign zero_wire_en =   (accum_sload_reg == "CLOCK0")? ena0:
                            (accum_sload_reg == "UNREGISTERED")? 1'b1:
                            (accum_sload_reg == "CLOCK1")? ena1:
                            (accum_sload_reg == "CLOCK2")? ena2:
                            (accum_sload_reg == "CLOCK3")? ena3: 1'b1;

    assign accum_sload_upper_data_wire_en =  (accum_sload_upper_data_reg == "CLOCK0")? ena0:
                            (accum_sload_upper_data_reg == "UNREGISTERED")? 1'b1:
                            (accum_sload_upper_data_reg == "CLOCK1")? ena1:
                            (accum_sload_upper_data_reg == "CLOCK2")? ena2:
                            (accum_sload_upper_data_reg == "CLOCK3")? ena3: 1'b1;

    assign zero_pipe_wire_en =  (accum_sload_pipeline_reg == "CLOCK0")? ena0:
                                (accum_sload_pipeline_reg == "UNREGISTERED")? 1'b1:
                                (accum_sload_pipeline_reg == "CLOCK1")? ena1:
                                (accum_sload_pipeline_reg == "CLOCK2")? ena2:
                                (accum_sload_pipeline_reg == "CLOCK3")? ena3: 1'b1;

    assign accum_sload_upper_data_pipe_wire_en =  (accum_sload_upper_data_pipeline_reg == "CLOCK0")? ena0:
                                (accum_sload_upper_data_pipeline_reg == "UNREGISTERED")? 1'b1:
                                (accum_sload_upper_data_pipeline_reg == "CLOCK1")? ena1:
                                (accum_sload_upper_data_pipeline_reg == "CLOCK2")? ena2:
                                (accum_sload_upper_data_pipeline_reg == "CLOCK3")? ena3: 1'b1;

    assign sign_a_wire_en = (sign_reg_a == "CLOCK0")? ena0:
                            (sign_reg_a == "UNREGISTERED")? 1'b1:
                            (sign_reg_a == "CLOCK1")? ena1:
                            (sign_reg_a == "CLOCK2")? ena2:
                            (sign_reg_a == "CLOCK3")? ena3: 1'b1;


    assign sign_b_wire_en = (sign_reg_b == "CLOCK0")? ena0:
                            (sign_reg_b == "UNREGISTERED")? 1'b1:
                            (sign_reg_b == "CLOCK1")? ena1:
                            (sign_reg_b == "CLOCK2")? ena2:
                            (sign_reg_b == "CLOCK3")? ena3: 1'b1;



    assign sign_pipe_a_wire_en = (sign_pipeline_reg_a == "CLOCK0")? ena0:
                            (sign_pipeline_reg_a == "UNREGISTERED")? 1'b1:
                            (sign_pipeline_reg_a == "CLOCK1")? ena1:
                            (sign_pipeline_reg_a == "CLOCK2")? ena2:
                            (sign_pipeline_reg_a == "CLOCK3")? ena3: 1'b1;


    assign sign_pipe_b_wire_en = (sign_pipeline_reg_b == "CLOCK0")? ena0:
                            (sign_pipeline_reg_b == "UNREGISTERED")? 1'b1:
                            (sign_pipeline_reg_b == "CLOCK1")? ena1:
                            (sign_pipeline_reg_b == "CLOCK2")? ena2:
                            (sign_pipeline_reg_b == "CLOCK3")? ena3: 1'b1;


    assign multiplier_wire_en = (multiplier_reg == "CLOCK0")? ena0:
                            (multiplier_reg == "UNREGISTERED")? 1'b1:
                            (multiplier_reg == "CLOCK1")? ena1:
                            (multiplier_reg == "CLOCK2")? ena2:
                            (multiplier_reg == "CLOCK3")? ena3: 1'b1;

    assign output_wire_en = (output_reg == "CLOCK0")? ena0:
                            (output_reg == "UNREGISTERED")? 1'b1:
                            (output_reg == "CLOCK1")? ena1:
                            (output_reg == "CLOCK2")? ena2:
                            (output_reg == "CLOCK3")? ena3: 1'b1;


    assign mult_pipe_wire_en  = (multiplier_reg == "UNREGISTERED")? ena0:
                                multiplier_wire_en;


    assign mult_round_wire_en = (mult_round_reg == "CLOCK0")? ena0:
                            (mult_round_reg == "UNREGISTERED")? 1'b1:
                            (mult_round_reg == "CLOCK1")? ena1:
                            (mult_round_reg == "CLOCK2")? ena2:
                            (mult_round_reg == "CLOCK3")? ena3: 1'b1;


    assign mult_saturation_wire_en = (mult_saturation_reg == "CLOCK0")? ena0:
                            (mult_saturation_reg == "UNREGISTERED")? 1'b1:
                            (mult_saturation_reg == "CLOCK1")? ena1:
                            (mult_saturation_reg == "CLOCK2")? ena2:
                            (mult_saturation_reg == "CLOCK3")? ena3: 1'b1;

    assign accum_round_wire_en = (accum_round_reg == "CLOCK0")? ena0:
                            (accum_round_reg == "UNREGISTERED")? 1'b1:
                            (accum_round_reg == "CLOCK1")? ena1:
                            (accum_round_reg == "CLOCK2")? ena2:
                            (accum_round_reg == "CLOCK3")? ena3: 1'b1;

    assign accum_round_pipe_wire_en = (accum_round_pipeline_reg == "CLOCK0")? ena0:
                            (accum_round_pipeline_reg == "UNREGISTERED")? 1'b1:
                            (accum_round_pipeline_reg == "CLOCK1")? ena1:
                            (accum_round_pipeline_reg == "CLOCK2")? ena2:
                            (accum_round_pipeline_reg == "CLOCK3")? ena3: 1'b1;

    assign accum_saturation_wire_en = (accum_saturation_reg == "CLOCK0")? ena0:
                            (accum_saturation_reg == "UNREGISTERED")? 1'b1:
                            (accum_saturation_reg == "CLOCK1")? ena1:
                            (accum_saturation_reg == "CLOCK2")? ena2:
                            (accum_saturation_reg == "CLOCK3")? ena3: 1'b1;

    assign accum_saturation_pipe_wire_en = (accum_saturation_pipeline_reg == "CLOCK0")? ena0:
                            (accum_saturation_pipeline_reg == "UNREGISTERED")? 1'b1:
                            (accum_saturation_pipeline_reg == "CLOCK1")? ena1:
                            (accum_saturation_pipeline_reg == "CLOCK2")? ena2:
                            (accum_saturation_pipeline_reg == "CLOCK3")? ena3: 1'b1;

    // ---------------------------------------------------------
    // This block updates the internal clear signals accordingly
    // every time the global clear signal changes state
    // ---------------------------------------------------------

    assign input_a_wire_clr =(input_aclr_a == "ACLR3")? aclr3:
                            (input_aclr_a == "UNUSED")? 1'b0:
                            (input_aclr_a == "ACLR0")? aclr0:
                            (input_aclr_a == "ACLR1")? aclr1:
                            (input_aclr_a == "ACLR2")? aclr2: 1'b0;

    assign input_b_wire_clr = (input_aclr_b == "ACLR3")? aclr3:
                            (input_aclr_b == "UNUSED")? 1'b0:
                            (input_aclr_b == "ACLR0")? aclr0:
                            (input_aclr_b == "ACLR1")? aclr1:
                            (input_aclr_b == "ACLR2")? aclr2: 1'b0;


    assign addsub_wire_clr =(addnsub_aclr == "ACLR3")? aclr3:
                            (addnsub_aclr == "UNUSED")? 1'b0:
                            (addnsub_aclr == "ACLR0")? aclr0:
                            (addnsub_aclr == "ACLR1")? aclr1:
                            (addnsub_aclr == "ACLR2")? aclr2: 1'b0;


    assign addsub_pipe_wire_clr =   (addnsub_pipeline_aclr == "ACLR3")? aclr3:
                                    (addnsub_pipeline_aclr == "UNUSED")? 1'b0:
                                    (addnsub_pipeline_aclr == "ACLR0")? aclr0:
                                    (addnsub_pipeline_aclr == "ACLR1")? aclr1:
                                    (addnsub_pipeline_aclr == "ACLR2")? aclr2: 1'b0;


    assign zero_wire_clr =  (accum_sload_aclr == "ACLR3")? aclr3:
                            (accum_sload_aclr == "UNUSED")? 1'b0:
                            (accum_sload_aclr == "ACLR0")? aclr0:
                            (accum_sload_aclr == "ACLR1")? aclr1:
                            (accum_sload_aclr == "ACLR2")? aclr2: 1'b0;

    assign accum_sload_upper_data_wire_clr =  (accum_sload_upper_data_aclr == "ACLR3")? aclr3:
                            (accum_sload_upper_data_aclr == "UNUSED")? 1'b0:
                            (accum_sload_upper_data_aclr == "ACLR0")? aclr0:
                            (accum_sload_upper_data_aclr == "ACLR1")? aclr1:
                            (accum_sload_upper_data_aclr == "ACLR2")? aclr2: 1'b0;

    assign zero_pipe_wire_clr =  (accum_sload_pipeline_aclr == "ACLR3")? aclr3:
                            (accum_sload_pipeline_aclr == "UNUSED")? 1'b0:
                            (accum_sload_pipeline_aclr == "ACLR0")? aclr0:
                            (accum_sload_pipeline_aclr == "ACLR1")? aclr1:
                            (accum_sload_pipeline_aclr == "ACLR2")? aclr2: 1'b0;

    assign accum_sload_upper_data_pipe_wire_clr =  (accum_sload_upper_data_pipeline_aclr == "ACLR3")? aclr3:
                            (accum_sload_upper_data_pipeline_aclr == "UNUSED")? 1'b0:
                            (accum_sload_upper_data_pipeline_aclr == "ACLR0")? aclr0:
                            (accum_sload_upper_data_pipeline_aclr == "ACLR1")? aclr1:
                            (accum_sload_upper_data_pipeline_aclr == "ACLR2")? aclr2: 1'b0;

    assign sign_a_wire_clr =(sign_aclr_a == "ACLR3")? aclr3:
                            (sign_aclr_a == "UNUSED")? 1'b0:
                            (sign_aclr_a == "ACLR0")? aclr0:
                            (sign_aclr_a == "ACLR1")? aclr1:
                            (sign_aclr_a == "ACLR2")? aclr2: 1'b0;


    assign sign_b_wire_clr =    (sign_aclr_b == "ACLR3")? aclr3:
                                (sign_aclr_b == "UNUSED")? 1'b0:
                                (sign_aclr_b == "ACLR0")? aclr0:
                                (sign_aclr_b == "ACLR1")? aclr1:
                                (sign_aclr_b == "ACLR2")? aclr2: 1'b0;




    assign sign_pipe_a_wire_clr = (sign_pipeline_aclr_a == "ACLR3")? aclr3:
                            (sign_pipeline_aclr_a == "UNUSED")? 1'b0:
                            (sign_pipeline_aclr_a == "ACLR0")? aclr0:
                            (sign_pipeline_aclr_a == "ACLR1")? aclr1:
                            (sign_pipeline_aclr_a == "ACLR2")? aclr2: 1'b0;


    assign sign_pipe_b_wire_clr = (sign_pipeline_aclr_b == "ACLR3")? aclr3:
                            (sign_pipeline_aclr_b == "UNUSED")? 1'b0:
                            (sign_pipeline_aclr_b == "ACLR0")? aclr0:
                            (sign_pipeline_aclr_b == "ACLR1")? aclr1:
                            (sign_pipeline_aclr_b == "ACLR2")? aclr2: 1'b0;


    assign multiplier_wire_clr = (multiplier_aclr == "ACLR3")? aclr3:
                            (multiplier_aclr == "UNUSED")? 1'b0:
                            (multiplier_aclr == "ACLR0")? aclr0:
                            (multiplier_aclr == "ACLR1")? aclr1:
                            (multiplier_aclr == "ACLR2")? aclr2: 1'b0;

    assign output_wire_clr =(output_aclr == "ACLR3")? aclr3:
                            (output_aclr == "UNUSED")? 1'b0:
                            (output_aclr == "ACLR0")? aclr0:
                            (output_aclr == "ACLR1")? aclr1:
                            (output_aclr == "ACLR2")? aclr2: 1'b0;


    assign mult_pipe_wire_clr  = (multiplier_reg == "UNREGISTERED")? aclr0:
                            multiplier_wire_clr;

    assign mult_round_wire_clr = (mult_round_aclr == "ACLR3")? aclr3:
                            (mult_round_aclr == "UNUSED")? 1'b0:
                            (mult_round_aclr == "ACLR0")? aclr0:
                            (mult_round_aclr == "ACLR1")? aclr1:
                            (mult_round_aclr == "ACLR2")? aclr2: 1'b0;

    assign mult_saturation_wire_clr = (mult_saturation_aclr == "ACLR3")? aclr3:
                            (mult_saturation_aclr == "UNUSED")? 1'b0:
                            (mult_saturation_aclr == "ACLR0")? aclr0:
                            (mult_saturation_aclr == "ACLR1")? aclr1:
                            (mult_saturation_aclr == "ACLR2")? aclr2: 1'b0;

    assign accum_round_wire_clr = (accum_round_aclr == "ACLR3")? aclr3:
                            (accum_round_aclr == "UNUSED")? 1'b0:
                            (accum_round_aclr == "ACLR0")? aclr0:
                            (accum_round_aclr == "ACLR1")? aclr1:
                            (accum_round_aclr == "ACLR2")? aclr2: 1'b0;

    assign accum_round_pipe_wire_clr = (accum_round_pipeline_aclr == "ACLR3")? aclr3:
                            (accum_round_pipeline_aclr == "UNUSED")? 1'b0:
                            (accum_round_pipeline_aclr == "ACLR0")? aclr0:
                            (accum_round_pipeline_aclr == "ACLR1")? aclr1:
                            (accum_round_pipeline_aclr == "ACLR2")? aclr2: 1'b0;

    assign accum_saturation_wire_clr = (accum_saturation_aclr == "ACLR3")? aclr3:
                            (accum_saturation_aclr == "UNUSED")? 1'b0:
                            (accum_saturation_aclr == "ACLR0")? aclr0:
                            (accum_saturation_aclr == "ACLR1")? aclr1:
                            (accum_saturation_aclr == "ACLR2")? aclr2: 1'b0;

    assign accum_saturation_pipe_wire_clr = (accum_saturation_pipeline_aclr == "ACLR3")? aclr3:
                            (accum_saturation_pipeline_aclr == "UNUSED")? 1'b0:
                            (accum_saturation_pipeline_aclr == "ACLR0")? aclr0:
                            (accum_saturation_pipeline_aclr == "ACLR1")? aclr1:
                            (accum_saturation_pipeline_aclr == "ACLR2")? aclr2: 1'b0;

    // ------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set mult_a)
    // Signal Registered : dataa
    //
    // Register is controlled by posedge input_wire_a_clk
    // Register has an asynchronous clear signal, input_reg_a_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        input_reg_a is unregistered and dataa changes value
    // ------------------------------------------------------------------------
    assign mult_a_wire = (input_reg_a == "UNREGISTERED")? mult_a_tmp : mult_a_reg;

    always @ (dataa or sourcea or scanina)
    begin
        if (int_width_a == width_a)
        begin
            if (input_source_a == "DATAA")
                mult_a_tmp = dataa;
            else if ((input_source_a == "SCANA") || (sourcea == 1))
                mult_a_tmp = scanina;
            else
                mult_a_tmp = dataa;
        end
        else
        begin
            if (input_source_a == "DATAA")
                mult_a_tmp = {dataa, {(diff_width_a){1'b0}}};
            else if ((input_source_a == "SCANA") || (sourcea == 1))
                mult_a_tmp = {scanina, {(diff_width_a){1'b0}}};
            else
                mult_a_tmp = {dataa, {(diff_width_a){1'b0}}};
        end
    end

    always @(posedge input_a_wire_clk or posedge input_a_wire_clr)
    begin
        if (input_a_wire_clr == 1)
            mult_a_reg <= 0;
        else if ((input_a_wire_clk == 1) && (input_a_wire_en == 1))
        begin
            if (input_source_a == "DATAA")
                mult_a_reg <= (int_width_a == width_a) ? dataa : {dataa, {(diff_width_a){1'b0}}};
            else if (input_source_a == "SCANA")
                mult_a_reg <= (int_width_a == width_a) ? scanina : {scanina,{(diff_width_a){1'b0}}};
            else if  (input_source_a == "VARIABLE")
            begin
                if (sourcea == 1)
                    mult_a_reg <= (int_width_a == width_a) ? scanina : {scanina, {(diff_width_a){1'b0}}};
                else
                    mult_a_reg <= (int_width_a == width_a) ? dataa : {dataa, {(diff_width_a){1'b0}}};
                end
        end
    end


    // ------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set mult_b)
    // Signal Registered : datab
    //
    // Register is controlled by posedge input_wire_b_clk
    // Register has an asynchronous clear signal, input_reg_b_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        input_reg_b is unregistered and datab changes value
    // ------------------------------------------------------------------------
    assign mult_b_wire = (input_reg_b == "UNREGISTERED")? mult_b_tmp : mult_b_reg;

    always @ (datab or sourceb or scaninb)
    begin
        if (int_width_b == width_b)
        begin
            if (input_source_b == "DATAB")
                mult_b_tmp = datab;
            else if ((input_source_b == "SCANB") || (sourceb == 1))
                mult_b_tmp = scaninb;
            else
                mult_b_tmp = datab;
        end
        else
        begin
            if (input_source_b == "DATAB")
                mult_b_tmp = {datab, {(diff_width_b){1'b0}}};
        else if ((input_source_b == "SCANB") || (sourceb == 1))
                mult_b_tmp = {scaninb, {(diff_width_b){1'b0}}};
            else
                mult_b_tmp = {datab, {(diff_width_b){1'b0}}};
        end
    end

    always @(posedge input_b_wire_clk or posedge input_b_wire_clr )
    begin
        if (input_b_wire_clr == 1)
            mult_b_reg <= 0;
        else if ((input_b_wire_clk == 1) && (input_b_wire_en == 1))
        begin
            if (input_source_b == "DATAB")
                mult_b_reg <= (int_width_b == width_b) ? datab : {datab, {(diff_width_b){1'b0}}};
            else if (input_source_b == "SCANB")
                mult_b_reg <= (int_width_b == width_b) ? scaninb : {scaninb, {(diff_width_b){1'b0}}};
            else if  (input_source_b == "VARIABLE")
            begin
                if (sourceb == 1)
                    mult_b_reg <= (int_width_b == width_b) ? scaninb : {scaninb, {(diff_width_b){1'b0}}};
                else
                    mult_b_reg <= (int_width_b == width_b) ? datab : {datab, {(diff_width_b){1'b0}}};
            end
        end
    end


    // -----------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set addnsub_reg)
    // Signal Registered : addnsub
    //
    // Register is controlled by posedge addsub_wire_clk
    // Register has an asynchronous clear signal, addsub_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        addnsub_reg is unregistered and addnsub changes value
    // -----------------------------------------------------------------------------
    assign addsub_wire = ((addnsub_reg == "UNREGISTERED") )? addnsub : addsub_reg;

    always @(posedge addsub_wire_clk or posedge addsub_wire_clr)
    begin
        if (addsub_wire_clr == 1)
            addsub_reg <= 0;
        else if ((addsub_wire_clk == 1) && (addsub_wire_en == 1))
            addsub_reg <= addnsub;
    end


    // -----------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set addsub_pipe)
    // Signal Registered : addsub_latent
    //
    // Register is controlled by posedge addsub_pipe_wire_clk
    // Register has an asynchronous clear signal, addsub_pipe_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        addsub_pipeline_reg is unregistered and addsub_latent changes value
    // -----------------------------------------------------------------------------
    assign addsub_pipe_wire = (addnsub_pipeline_reg == "UNREGISTERED")?addsub_latent : addsub_pipe_reg;

    always @(posedge addsub_pipe_wire_clk or posedge addsub_pipe_wire_clr )
    begin
        if (addsub_pipe_wire_clr == 1)
            addsub_pipe_reg <= 0;
        else if ((addsub_pipe_wire_clk == 1) && (addsub_pipe_wire_en == 1))
            addsub_pipe_reg <= addsub_latent;

    end


    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set zero_acc_reg)
    // Signal Registered : accum_sload
    //
    // Register is controlled by posedge zero_wire_clk
    // Register has an asynchronous clear signal, zero_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        accum_sload_reg is unregistered and accum_sload changes value
    // ------------------------------------------------------------------------------
    assign zero_acc_wire = (accum_sload_reg == "UNREGISTERED")?accum_sload : zero_acc_reg;

    always @(posedge zero_wire_clk or posedge zero_wire_clr)
    begin
        if (zero_wire_clr == 1)
        begin
            zero_acc_reg <= 0;
        end
        else if ((zero_wire_clk == 1) && (zero_wire_en == 1))
        begin
            zero_acc_reg <=  accum_sload;
        end
    end

    assign sload_upper_data_wire = (accum_sload_upper_data_reg == "UNREGISTERED")? accum_sload_upper_data_int : sload_upper_data_reg;


    always @(posedge accum_sload_upper_data_wire_clk or posedge accum_sload_upper_data_wire_clr)
    begin
        if (accum_sload_upper_data_wire_clr == 1)
        begin
            sload_upper_data_reg <= 0;
        end
        else if ((accum_sload_upper_data_wire_clk == 1) && (accum_sload_upper_data_wire_en == 1))
        begin
            sload_upper_data_reg <= accum_sload_upper_data_int;
        end
    end

    // --------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set zero_acc_pipe)
    // Signal Registered : zeroacc_latent
    //
    // Register is controlled by posedge zero_pipe_wire_clk
    // Register has an asynchronous clear signal, zero_pipe_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        accum_sload_pipeline_reg is unregistered and zeroacc_latent changes value
    // --------------------------------------------------------------------------------
    assign zero_acc_pipe_wire = (accum_sload_pipeline_reg == "UNREGISTERED")?zeroacc_latent : zero_acc_pipe_reg;

    always @(posedge zero_pipe_wire_clk or posedge zero_pipe_wire_clr)
    begin
        if (zero_pipe_wire_clr == 1)
        begin
            zero_acc_pipe_reg <= 0;
        end
        else if ((zero_pipe_wire_clk == 1) && (zero_pipe_wire_en == 1))
        begin
            zero_acc_pipe_reg <= zeroacc_latent;
        end

    end


    always @(posedge accum_sload_upper_data_pipe_wire_clk or posedge accum_sload_upper_data_pipe_wire_clr)
    begin
        if (accum_sload_upper_data_pipe_wire_clr == 1)
        begin
            sload_upper_data_pipe_reg <= 0;
        end
        else if ((accum_sload_upper_data_pipe_wire_clk == 1) && (accum_sload_upper_data_pipe_wire_en == 1))
        begin
            sload_upper_data_pipe_reg <= sload_upper_data_latent;
        end

    end

    always @(sload_upper_data_latent or sload_upper_data_pipe_reg or sign_a_int or sign_b_int )
    begin
        if (accum_sload_upper_data_pipeline_reg == "UNREGISTERED")
        begin
            if(int_width_result > width_result)
            begin

                if(sign_a_int | sign_b_int)
                begin
                    sload_upper_data_pipe_wire[int_width_result - 1 : 0] = {int_width_result{sload_upper_data_latent[width_upper_data-1]}};
                end
                else
                begin
                    sload_upper_data_pipe_wire[int_width_result - 1 : 0] = {int_width_result{1'b0}};
                end

                if(width_result > width_upper_data)
                begin
                    for(i4 = 0; i4 < width_result - width_upper_data + int_extra_width; i4 = i4 + 1)
                    begin
                        sload_upper_data_pipe_wire[i4] = 1'b0;
                    end
                    sload_upper_data_pipe_wire[width_result - 1 + int_extra_width : width_result - width_upper_data + int_extra_width] = sload_upper_data_latent;
                end
                else if(width_result == width_upper_data)
                begin
                    for(i4 = 0; i4 < int_extra_width; i4 = i4 + 1)
                    begin
                        sload_upper_data_pipe_wire[i4] = 1'b0;
                    end
                    sload_upper_data_pipe_wire[width_result - 1 + int_extra_width: 0 + int_extra_width] = sload_upper_data_latent;
                end
                else
                begin
                    for(i4 = int_extra_width; i4 < sload_for_limit; i4 = i4 + 1)
                    begin
                        sload_upper_data_pipe_wire[i4] = sload_upper_data_latent[i4];
                    end
                    for(i4 = 0; i4 < int_extra_width; i4 = i4 + 1)
                    begin
                        sload_upper_data_pipe_wire[i4] = 1'b0;
                    end
                end
            end
            else
            begin
                if(width_result > width_upper_data)
                begin
                    for(i4 = 0; i4 < width_result - width_upper_data + int_extra_width; i4 = i4 + 1)
                    begin
                        sload_upper_data_pipe_wire[i4] = 1'b0;
                    end
                    sload_upper_data_pipe_wire[width_result - 1 + int_extra_width : width_result - width_upper_data + int_extra_width] = sload_upper_data_latent;
                end
                else if(width_result == width_upper_data)
                begin
                    for(i4 = 0; i4 < int_extra_width; i4 = i4 + 1)
                    begin
                        sload_upper_data_pipe_wire[i4] = 1'b0;
                    end
                    sload_upper_data_pipe_wire[width_result - 1 + int_extra_width : 0 + int_extra_width] = sload_upper_data_latent;
                end
                else
                begin
                    for(i4 = int_extra_width; i4 < sload_for_limit; i4 = i4 + 1)
                    begin
                        sload_upper_data_pipe_wire[i4] = sload_upper_data_latent[i4];
                    end
                    for(i4 = 0; i4 < int_extra_width; i4 = i4 + 1)
                    begin
                        sload_upper_data_pipe_wire[i4] = 1'b0;
                    end
                end
            end
        end
        else
        begin
            if(int_width_result > width_result)
            begin

                if(sign_a_int | sign_b_int)
                begin
                    sload_upper_data_pipe_wire[int_width_result - 1 : 0] = {int_width_result{sload_upper_data_pipe_reg[width_upper_data-1]}};
                end
                else
                begin
                    sload_upper_data_pipe_wire[int_width_result - 1 : 0] = {int_width_result{1'b0}};
                end

                if(width_result > width_upper_data)
                begin
                    for(i4 = 0; i4 < width_result - width_upper_data + int_extra_width; i4 = i4 + 1)
                    begin
                        sload_upper_data_pipe_wire[i4] = 1'b0;
                    end
                    sload_upper_data_pipe_wire[width_result - 1 + int_extra_width : width_result - width_upper_data + int_extra_width] = sload_upper_data_pipe_reg;
                end
                else if(width_result == width_upper_data)
                begin
                    for(i4 = 0; i4 < int_extra_width; i4 = i4 + 1)
                    begin
                        sload_upper_data_pipe_wire[i4] = 1'b0;
                    end
                    sload_upper_data_pipe_wire[width_result - 1 + int_extra_width: 0 + int_extra_width] = sload_upper_data_pipe_reg;
                end
                else
                begin
                    for(i4 = int_extra_width; i4 < sload_for_limit; i4 = i4 + 1)
                    begin
                        sload_upper_data_pipe_wire[i4] = sload_upper_data_pipe_reg[i4];
                    end
                    for(i4 = 0; i4 < int_extra_width; i4 = i4 + 1)
                    begin
                        sload_upper_data_pipe_wire[i4] = 1'b0;
                    end
                end
            end
            else
            begin
                if(width_result > width_upper_data)
                begin
                    for(i4 = 0; i4 < width_result - width_upper_data + int_extra_width; i4 = i4 + 1)
                    begin
                        sload_upper_data_pipe_wire[i4] = 1'b0;
                    end
                    sload_upper_data_pipe_wire[width_result - 1 + int_extra_width : width_result - width_upper_data + int_extra_width] = sload_upper_data_pipe_reg;
                end
                else if(width_result == width_upper_data)
                begin
                    for(i4 = 0; i4 < int_extra_width; i4 = i4 + 1)
                    begin
                        sload_upper_data_pipe_wire[i4] = 1'b0;
                    end
                    sload_upper_data_pipe_wire[width_result - 1 + int_extra_width : 0 + int_extra_width] = sload_upper_data_pipe_reg;
                end
                else
                begin
                    for(i4 = int_extra_width; i4 < sload_for_limit; i4 = i4 + 1)
                    begin
                        sload_upper_data_pipe_wire[i4] = sload_upper_data_pipe_reg[i4];
                    end
                    for(i4 = 0; i4 < int_extra_width; i4 = i4 + 1)
                    begin
                        sload_upper_data_pipe_wire[i4] = 1'b0;
                    end
                end
            end
        end
    end

    // ----------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set sign_a_reg)
    // Signal Registered : signa
    //
    // Register is controlled by posedge sign_a_wire_clk
    // Register has an asynchronous clear signal, sign_a_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        sign_reg_a is unregistered and signa changes value
    // ----------------------------------------------------------------------------
    assign  sign_a_wire = (sign_reg_a == "UNREGISTERED")? signa : sign_a_reg;

    always @(posedge sign_a_wire_clk or posedge sign_a_wire_clr)
    begin
        if (sign_a_wire_clr == 1)
            sign_a_reg <= 0;
        else if ((sign_a_wire_clk == 1) && (sign_a_wire_en == 1))
            sign_a_reg <= signa;
    end


    // -----------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set sign_a_pipe)
    // Signal Registered : signa_latent
    //
    // Register is controlled by posedge sign_pipe_a_wire_clk
    // Register has an asynchronous clear signal, sign_pipe_a_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        sign_pipeline_reg_a is unregistered and signa_latent changes value
    // -----------------------------------------------------------------------------
    assign  sign_a_pipe_wire = (sign_pipeline_reg_a == "UNREGISTERED")? signa_latent : sign_a_pipe_reg;

    always @(posedge sign_pipe_a_wire_clk or posedge sign_pipe_a_wire_clr)
    begin
        if (sign_pipe_a_wire_clr == 1)
            sign_a_pipe_reg <= 0;
        else if ((sign_pipe_a_wire_clk == 1) && (sign_pipe_a_wire_en == 1))
            sign_a_pipe_reg <= signa_latent;
    end


    // ----------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set sign_b_reg)
    // Signal Registered : signb
    //
    // Register is controlled by posedge sign_b_wire_clk
    // Register has an asynchronous clear signal, sign_b_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        sign_reg_b is unregistered and signb changes value
    // ----------------------------------------------------------------------------
    assign  sign_b_wire = (sign_reg_b == "UNREGISTERED") ? signb : sign_b_reg;

    always @(posedge sign_b_wire_clk or posedge sign_b_wire_clr)
    begin
            if (sign_b_wire_clr == 1)
                sign_b_reg <= 0;
            else if ((sign_b_wire_clk == 1) && (sign_b_wire_en == 1))
                sign_b_reg <= signb;
    end


    // -----------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set sign_b_pipe)
    // Signal Registered : signb_latent
    //
    // Register is controlled by posedge sign_pipe_b_wire_clk
    // Register has an asynchronous clear signal, sign_pipe_b_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        sign_pipeline_reg_b is unregistered and signb_latent changes value
    // -----------------------------------------------------------------------------
    assign sign_b_pipe_wire = (sign_pipeline_reg_b == "UNREGISTERED" )? signb_latent : sign_b_pipe_reg;

    always @(posedge sign_pipe_b_wire_clk or posedge sign_pipe_b_wire_clr )
    begin
        if (sign_pipe_b_wire_clr == 1)
            sign_b_pipe_reg <= 0;
        else if ((sign_pipe_b_wire_clk == 1) && (sign_pipe_b_wire_en == 1))
            sign_b_pipe_reg <=  signb_latent;

    end

    // ----------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set mult_round)
    // Signal Registered : mult_round
    //
    // Register is controlled by posedge mult_round_wire_clk
    // Register has an asynchronous clear signal, mult_round_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        mult_round_reg is unregistered and mult_round changes value
    // ----------------------------------------------------------------------------

    assign mult_round_int = (mult_round_reg == "UNREGISTERED")? mult_round : mult_round_tmp;

    always @(posedge mult_round_wire_clk or posedge mult_round_wire_clr)
    begin
        if (mult_round_wire_clr == 1)
            mult_round_tmp <= 0;
        else if ((mult_round_wire_clk == 1) && (mult_round_wire_en == 1))
            mult_round_tmp <= mult_round;
    end

    // ----------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set mult_saturation)
    // Signal Registered : mult_saturation
    //
    // Register is controlled by posedge mult_saturation_wire_clk
    // Register has an asynchronous clear signal, mult_saturation_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        mult_saturation_reg is unregistered and mult_saturation changes value
    // ----------------------------------------------------------------------------

    assign mult_saturation_int = (mult_saturation_reg == "UNREGISTERED")? mult_saturation : mult_saturation_tmp;

    always @(posedge mult_saturation_wire_clk or posedge mult_saturation_wire_clr)
    begin
        if (mult_saturation_wire_clr == 1)
            mult_saturation_tmp <= 0;
        else if ((mult_saturation_wire_clk == 1) && (mult_saturation_wire_en == 1))
            mult_saturation_tmp <= mult_saturation;
    end

    // ----------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set accum_round)
    // Signal Registered : accum_round
    //
    // Register is controlled by posedge accum_round_wire_clk
    // Register has an asynchronous clear signal, accum_round_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        accum_round_reg is unregistered and accum_round changes value
    // ----------------------------------------------------------------------------

    assign accum_round_tmp1_wire = (accum_round_reg == "UNREGISTERED")? ((is_stratixiii == 1) ? accum_sload : accum_round) : accum_round_tmp1;

    always @(posedge accum_round_wire_clk or posedge accum_round_wire_clr)
    begin
        if (accum_round_wire_clr == 1)
            accum_round_tmp1 <= 0;
        else if ((accum_round_wire_clk == 1) && (accum_round_wire_en == 1))
        begin
            if (is_stratixiii == 1)
                accum_round_tmp1 <= accum_sload;
            else
                accum_round_tmp1 <= accum_round;
        end
    end

    // ----------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set accum_round_tmp1)
    // Signal Registered : accum_round_tmp1
    //
    // Register is controlled by posedge accum_round_pipe_wire_clk
    // Register has an asynchronous clear signal, accum_round_pipe_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        accum_round_pipeline_reg is unregistered and accum_round_tmp1_wire changes value
    // ----------------------------------------------------------------------------

    assign accum_round_int = (accum_round_pipeline_reg == "UNREGISTERED")? accum_round_tmp1_wire : accum_round_tmp2;

    always @(posedge accum_round_pipe_wire_clk or posedge accum_round_pipe_wire_clr)
    begin
        if (accum_round_pipe_wire_clr == 1)
            accum_round_tmp2 <= 0;
        else if ((accum_round_pipe_wire_clk == 1) && (accum_round_pipe_wire_en == 1))
            accum_round_tmp2 <= accum_round_tmp1_wire;
    end


    // ----------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set accum_saturation)
    // Signal Registered : accum_saturation
    //
    // Register is controlled by posedge accum_saturation_wire_clk
    // Register has an asynchronous clear signal, accum_saturation_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        accum_saturation_reg is unregistered and accum_saturation changes value
    // ----------------------------------------------------------------------------

    assign accum_saturation_tmp1_wire = (accum_saturation_reg == "UNREGISTERED")? accum_saturation : accum_saturation_tmp1;

    always @(posedge accum_saturation_wire_clk or posedge accum_saturation_wire_clr)
    begin
        if (accum_saturation_wire_clr == 1)
            accum_saturation_tmp1 <= 0;
        else if ((accum_saturation_wire_clk == 1) && (accum_saturation_wire_en == 1))
            accum_saturation_tmp1 <= accum_saturation;
    end

    // ----------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set accum_saturation_tmp1)
    // Signal Registered : accum_saturation_tmp1
    //
    // Register is controlled by posedge accum_saturation_pipe_wire_clk
    // Register has an asynchronous clear signal, accum_saturation_pipe_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        accum_saturation_pipeline_reg is unregistered and accum_saturation_tmp1_wire changes value
    // ----------------------------------------------------------------------------

    assign accum_saturation_int = (accum_saturation_pipeline_reg == "UNREGISTERED")? accum_saturation_tmp1_wire : accum_saturation_tmp2;

    always @(posedge accum_saturation_pipe_wire_clk or posedge accum_saturation_pipe_wire_clr)
    begin
        if (accum_saturation_pipe_wire_clr == 1)
            accum_saturation_tmp2 <= 0;
        else if ((accum_saturation_pipe_wire_clk == 1) && (accum_saturation_pipe_wire_en == 1))
            accum_saturation_tmp2 <= accum_saturation_tmp1_wire;
    end


    // ------------------------------------------------------------------------------------------------------
    // This block checks if the two numbers to be multiplied (mult_a/mult_b) is to be interpreted
    // as a negative number or not. If so, then two's complement is performed.
    // The numbers are then multipled
    // The sign of the result (positive or negative) is determined based on the sign of the two input numbers
    // ------------------------------------------------------------------------------------------------------

    always @(mult_a_wire or mult_b_wire or sign_a_reg_int or sign_b_reg_int or temp_mult_zero)
    begin
        neg_a = mult_a_wire [int_width_a-1] & (sign_a_reg_int);
        neg_b = mult_b_wire [int_width_b-1] & (sign_b_reg_int);

        mult_a_int = (neg_a == 1) ? ~mult_a_wire + 1 : mult_a_wire;
        mult_b_int = (neg_b == 1) ? ~mult_b_wire + 1 : mult_b_wire;

        temp_mult_1        = mult_a_int * mult_b_int;
        temp_mult_signed = sign_a_reg_int | sign_b_reg_int;
        temp_mult        = (neg_a ^ neg_b) ? (temp_mult_zero - temp_mult_1) : temp_mult_1;

    end

    always @(temp_mult or mult_saturation_int or mult_round_int)
    begin

        if (is_stratixii == 1)
        begin
            // StratixII rounding support

            // This is based on both input is in Q1.15 format

            if ((multiplier_rounding == "YES") ||
                ((multiplier_rounding == "VARIABLE") && (mult_round_int == 1)))
            begin
                mult_round_out = temp_mult + ( 1 << (bits_to_round));

            end
            else
            begin
                mult_round_out = temp_mult;
            end

            // StratixII saturation support

            if ((multiplier_saturation == "YES") ||
                (( multiplier_saturation == "VARIABLE") && (mult_saturation_int == 1)))
            begin
                mult_saturate_overflow = (mult_round_out[int_width_a + int_width_b - 1] == 0 && mult_round_out[int_width_a + int_width_b - 2] == 1);
                if (mult_saturate_overflow == 0)
                begin
                    mult_saturate_out = mult_round_out;
                end
                else
                begin
                    for (i = (int_width_a + int_width_b - 1); i >= (int_width_a + int_width_b - 2); i = i - 1)
                    begin
                        mult_saturate_out[i] = mult_round_out[int_width_a + int_width_b - 1];
                    end

                    for (i = (int_width_a + int_width_b - 3); i >= 0; i = i - 1)
                    begin
                        mult_saturate_out[i] = ~mult_round_out[int_width_a + int_width_b - 1];
                    end

                    for (i= sat_for_ini; i >=0; i = i - 1)
                    begin
                        mult_saturate_out[i] = 1'b0;
                    end

                end
            end
            else
            begin
                mult_saturate_out = mult_round_out;
                mult_saturate_overflow = 0;
            end

            if ((multiplier_rounding == "YES") ||
                ((multiplier_rounding == "VARIABLE") && (mult_round_int == 1)))
            begin
                    mult_result = mult_saturate_out;

                    for (i = mult_round_for_ini; i >= 0; i = i - 1)
                    begin
                        mult_result[i] = 1'b0;
                    end
            end
            else
            begin
                    mult_result = mult_saturate_out;
            end
        end

        mult_final_out = (is_stratixii == 0) ?
                            temp_mult : mult_result;

    end


    // ---------------------------------------------------------------------------------------
    // This block contains 2 register (to set mult_res and mult_signed)
    // Signals Registered : mult_out_latent, mult_signed_latent
    //
    // Both the registers are controlled by the same clock signal, posedge multiplier_wire_clk
    // Both registers share the same clock enable signal multipler_wire_en
    // Both registers have the same asynchronous signal, posedge multiplier_wire_clr
    // ---------------------------------------------------------------------------------------
    assign mult_is_saturated_wire = (multiplier_reg == "UNREGISTERED")? mult_is_saturated_latent : mult_is_saturated_reg;

    always @(posedge multiplier_wire_clk or posedge multiplier_wire_clr)
    begin
        if (multiplier_wire_clr == 1)
        begin
            mult_res <=0;
            mult_signed <=0;
            mult_is_saturated_reg <=0;
        end
        else if ((multiplier_wire_clk == 1) && (multiplier_wire_en == 1))
        begin
            mult_res <= mult_out_latent;
            mult_signed <= mult_signed_latent;
            mult_is_saturated_reg <= mult_is_saturated_latent;
        end
    end


    // --------------------------------------------------------------------
    // This block contains 1 register (to set mult_full)
    // Signal Registered : mult_pipe
    //
    // Register is controlled by posedge mult_pipe_wire_clk
    // Register also has an asynchronous clear signal posedge mult_pipe_wire_clr
    // --------------------------------------------------------------------
    always @(posedge mult_pipe_wire_clk or posedge mult_pipe_wire_clr )
    begin
        if (mult_pipe_wire_clr ==1)
        begin
            // clear the pipeline
            for (i2=0; i2<=extra_multiplier_latency; i2=i2+1)
            begin
                mult_pipe [i2] = 0;
            end
            mult_full = 0;
        end
        else if ((mult_pipe_wire_clk == 1) && (mult_pipe_wire_en == 1))
        begin
            mult_pipe [head_mult] = {addsub_wire, zero_acc_wire, sign_a_wire, sign_b_wire, temp_mult_signed, mult_final_out, sload_upper_data_wire, mult_saturate_overflow};
            head_mult             = (head_mult +1) % (extra_multiplier_latency);
            mult_full             = mult_pipe[head_mult];
        end
    end


    // -------------------------------------------------------------
    // This is the main process block that performs the accumulation
    // -------------------------------------------------------------
    always @(posedge output_wire_clk or posedge output_wire_clr)
    begin
        if (output_wire_clr == 1)
        begin
            temp_sum = 0;
            accum_result = 0;

            result_int = (is_stratixii == 0) ?
                            temp_sum[int_width_result -1 : 0] : accum_result;

            overflow_int = 0;
            accum_saturate_overflow = 0;
            mult_is_saturated_int = 0;
            for (i3=0; i3<=extra_accumulator_latency; i3=i3+1)
            begin
                result_pipe [i3] = 0;
                accum_saturate_pipe[i3] = 0;
                mult_is_saturated_pipe[i3] = 0;
            end

            flag = ~flag;

        end
        else if (output_wire_clk ==1)
        begin

        if (output_wire_en ==1)
        begin
            if (extra_accumulator_latency == 0)
            begin
                mult_is_saturated_int = mult_is_saturated_wire;
            end

            if (multiplier_reg == "UNREGISTERED")
            begin
                if (int_width_extra_bit > 0) begin
    				mult_res_out    =  {{int_width_extra_bit {(sign_a_int | sign_b_int) & mult_out_latent [int_width_a+int_width_b -1]}}, mult_out_latent};
    			end
    			else begin
    				mult_res_out    =  mult_out_latent;
    			end
                mult_signed_out =  (sign_a_int | sign_b_int);
            end
            else
            begin
                if (int_width_extra_bit > 0) begin
        			mult_res_out    =  {{int_width_extra_bit {(sign_a_int | sign_b_int) & mult_res [int_width_a+int_width_b -1]}}, mult_res};
        		end
        		else begin
        			mult_res_out    =  mult_res;
        		end
                mult_signed_out =  (sign_a_int | sign_b_int);
            end

            if (addsub_int)
            begin
                //add
                if (is_stratixii == 0 &&
                    is_cycloneii == 0)
                begin
                    temp_sum = ( (zero_acc_int==0) ? result_int : 0) + mult_res_out;
                end
                else
                begin
                    temp_sum = ( (zero_acc_int==0) ? result_int : sload_upper_data_pipe_wire) + mult_res_out;
                end

                cout_int = temp_sum [int_width_result];
            end
            else
            begin
                //subtract
                if (is_stratixii == 0 &&
                    is_cycloneii == 0)
                begin
                    temp_sum = ( (zero_acc_int==0) ? result_int : 0) - (mult_res_out);
                    cout_int = (( (zero_acc_int==0) ? result_int : 0) >= mult_res_out) ? 1 : 0;
                end
                else
                begin
                    temp_sum = ( (zero_acc_int==0) ? result_int : sload_upper_data_pipe_wire) - mult_res_out;
                    cout_int = (( (zero_acc_int==0) ? result_int : sload_upper_data_pipe_wire) >= mult_res_out) ? 1 : 0;
                end
            end

            //compute overflow
            if ((mult_signed_out==1) && (mult_res_out != 0))
            begin
                if (zero_acc_int == 0)
                begin
                    overflow_tmp_int = (mult_res_out [int_width_a+int_width_b -1] ~^ result_int [int_width_result-1]) ^ (~addsub_int);
                    overflow_int     =  overflow_tmp_int & (result_int [int_width_result -1] ^ temp_sum[int_width_result -1]);
                end
                else
                begin
                    overflow_tmp_int = (mult_res_out [int_width_a+int_width_b -1] ~^ sload_upper_data_pipe_wire [int_width_result-1]) ^ (~addsub_int);
                    overflow_int     =  overflow_tmp_int & (sload_upper_data_pipe_wire [int_width_result -1] ^ temp_sum[int_width_result -1]);
                end
            end
            else
            begin
                overflow_int = (addsub_int ==1)? cout_int : ~cout_int;
            end

            if (is_stratixii == 1)
            begin
                // StratixII rounding support

                // This is based on both input is in Q1.15 format

                if ((accumulator_rounding == "YES") ||
                    ((accumulator_rounding == "VARIABLE") && (accum_round_int == 1)))
                begin
                    accum_round_out = temp_sum[int_width_result -1 : 0] + ( 1 << (bits_to_round));
                end
                else
                begin
                    accum_round_out = temp_sum[int_width_result - 1 : 0];
                end

                // StratixII saturation support

                if ((accumulator_saturation == "YES") ||
                    ((accumulator_saturation == "VARIABLE") && (accum_saturation_int == 1)))
                begin
                    accum_result_sign_bits = accum_round_out[int_width_result-1 : int_width_a + int_width_b - 2];

                    if ( (((&accum_result_sign_bits) | (|accum_result_sign_bits) | (^accum_result_sign_bits)) == 0) ||
                        (((&accum_result_sign_bits) & (|accum_result_sign_bits) & !(^accum_result_sign_bits)) == 1))
                    begin
                        accum_saturate_overflow = 1'b0;
                    end
                    else
                    begin
                        accum_saturate_overflow = 1'b1;
                    end

                    if (accum_saturate_overflow == 0)
                    begin
                        accum_saturate_out = accum_round_out;
                        accum_saturate_out[sat_for_ini] = 1'b0;
                    end
                    else
                    begin

                        for (i = (int_width_result - 1); i >= (int_width_a + int_width_b - 2); i = i - 1)
                        begin
                            accum_saturate_out[i] = accum_round_out[int_width_result-1];
                        end


                        for (i = (int_width_a + int_width_b - 3); i >= accum_sat_for_limit; i = i - 1)
                        begin
                            accum_saturate_out[i] = ~accum_round_out[int_width_result -1];
                        end

                        for (i = sat_for_ini; i >= 0; i = i - 1)
                        begin
                            accum_saturate_out[i] = 1'b0;
                        end

                    end
                end
                else
                begin
                    accum_saturate_out = accum_round_out;
                    accum_saturate_overflow = 0;
                end

                if ((accumulator_rounding == "YES") ||
                    ((accumulator_rounding == "VARIABLE") && (accum_round_int == 1)))
                begin
                    accum_result = accum_saturate_out;

                    for (i = bits_to_round; i >= 0; i = i - 1)
                    begin
                        accum_result[i] = 1'b0;
                    end
                end
                else
                begin
                    accum_result = accum_saturate_out;
                end
            end

            result_int = (is_stratixii == 0) ?
                            temp_sum[int_width_result -1 : 0] : accum_result;

            flag = ~flag;
        end

        end
    end

    always @ (posedge flag or negedge flag)
    begin
        if (extra_accumulator_latency == 0)
        begin
            result   <= result_int[width_result - 1 + int_extra_width : int_extra_width];
            overflow <= overflow_int;
            accum_is_saturated_latent <= accum_saturate_overflow;
        end
        else
        begin
            result_pipe [head_result] <= {overflow_int, result_int[width_result - 1 + int_extra_width : int_extra_width]};
            //mult_is_saturated_pipe[head_result] = mult_is_saturated_wire;
            accum_saturate_pipe[head_result] <= accum_saturate_overflow;
            head_result               <= (head_result +1) % (extra_accumulator_latency + 1);
            mult_is_saturated_int     <= mult_is_saturated_wire;
        end

    end

    assign head_result_wire = head_result[31:0];

    always @ (head_result_wire or result_pipe[head_result_wire])
    begin
        if (extra_accumulator_latency != 0)
        begin
            result_full <= result_pipe[head_result_wire];
        end
    end

    always @ (accum_saturate_pipe[head_result_wire] or head_result_wire)
    begin
        if (extra_accumulator_latency != 0)
        begin
            accum_is_saturated_latent <= accum_saturate_pipe[head_result_wire];
        end
    end

    always @ (result_full[width_result:0])
    begin
        if (extra_accumulator_latency != 0)
        begin
            result   <= result_full [width_result-1:0];
            overflow <= result_full [width_result];
        end
    end

endmodule  // end of ALTMULT_ACCUM

