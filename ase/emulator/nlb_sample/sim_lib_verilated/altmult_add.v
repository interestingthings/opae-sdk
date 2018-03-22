// Created by altera_lib_mf.pl from altera_mf.v

//--------------------------------------------------------------------------
// Module Name      : altmult_add
//
// Description      : a*b + c*d
//
// Limitation       : Stratix DSP block
//
// Results expected : signed & unsigned, maximum of 3 pipelines(latency) each.
//                    possible of zero pipeline.
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
module altmult_add (    dataa,
                        datab,
                        datac,
                        scanina,
                        scaninb,
                        sourcea,
                        sourceb,
                        clock3,
                        clock2,
                        clock1,
                        clock0,
                        aclr3,
                        aclr2,
                        aclr1,
                        aclr0,
                        ena3,
                        ena2,
                        ena1,
                        ena0,
                        signa,
                        signb,
                        addnsub1,
                        addnsub3,
                        result,
                        scanouta,
                        scanoutb,
                        mult01_round,
                        mult23_round,
                        mult01_saturation,
                        mult23_saturation,
                        addnsub1_round,
                        addnsub3_round,
                        mult0_is_saturated,
                        mult1_is_saturated,
                        mult2_is_saturated,
                        mult3_is_saturated,
                        output_round,
                        chainout_round,
                        output_saturate,
                        chainout_saturate,
                        overflow,
                        chainout_sat_overflow,
                        chainin,
                        zero_chainout,
                        rotate,
                        shift_right,
                        zero_loopback,
                        accum_sload,
			            coefsel0,
		             	coefsel1,
			            coefsel2,
			            coefsel3);


    // ---------------------
    // PARAMETER DECLARATION
    // ---------------------

    parameter width_a               = 16;
    parameter width_b               = 16;
	parameter width_c				= 22;
    parameter width_result          = 34;
    parameter number_of_multipliers = 1;
    parameter lpm_type              = "altmult_add";
    parameter lpm_hint              = "UNUSED";

    // A inputs

    parameter multiplier1_direction = "UNUSED";
    parameter multiplier3_direction = "UNUSED";

    parameter input_register_a0 = "CLOCK0";
    parameter input_aclr_a0     = "ACLR3";
    parameter input_source_a0   = "DATAA";

    parameter input_register_a1 = "CLOCK0";
    parameter input_aclr_a1     = "ACLR3";
    parameter input_source_a1   = "DATAA";

    parameter input_register_a2 = "CLOCK0";
    parameter input_aclr_a2     = "ACLR3";
    parameter input_source_a2   = "DATAA";

    parameter input_register_a3 = "CLOCK0";
    parameter input_aclr_a3     = "ACLR3";
    parameter input_source_a3   = "DATAA";

    parameter port_signa                 = "PORT_CONNECTIVITY";
    parameter representation_a           = "UNSIGNED";
    parameter signed_register_a          = "CLOCK0";
    parameter signed_aclr_a              = "ACLR3";
    parameter signed_pipeline_register_a = "CLOCK0";
    parameter signed_pipeline_aclr_a     = "ACLR3";

    parameter scanouta_register = "UNREGISTERED";
    parameter scanouta_aclr = "NONE";

    // B inputs

    parameter input_register_b0 = "CLOCK0";
    parameter input_aclr_b0     = "ACLR3";
    parameter input_source_b0   = "DATAB";

    parameter input_register_b1 = "CLOCK0";
    parameter input_aclr_b1     = "ACLR3";
    parameter input_source_b1   = "DATAB";

    parameter input_register_b2 = "CLOCK0";
    parameter input_aclr_b2     = "ACLR3";
    parameter input_source_b2   = "DATAB";

    parameter input_register_b3 = "CLOCK0";
    parameter input_aclr_b3     = "ACLR3";
    parameter input_source_b3   = "DATAB";

    parameter port_signb                 = "PORT_CONNECTIVITY";
    parameter representation_b           = "UNSIGNED";
    parameter signed_register_b          = "CLOCK0";
    parameter signed_aclr_b              = "ACLR3";
    parameter signed_pipeline_register_b = "CLOCK0";
    parameter signed_pipeline_aclr_b     = "ACLR3";

    //C inputs
    parameter input_register_c0	= "CLOCK0";
	parameter input_aclr_c0		= "ACLR0";

   	parameter input_register_c1	= "CLOCK0";
   	parameter input_aclr_c1	 	= "ACLR0";

	parameter input_register_c2	= "CLOCK0";
    parameter input_aclr_c2		= "ACLR0";

	parameter input_register_c3	= "CLOCK0";
	parameter input_aclr_c3		= "ACLR0";

    // multiplier parameters

    parameter multiplier_register0 = "CLOCK0";
    parameter multiplier_aclr0     = "ACLR3";
    parameter multiplier_register1 = "CLOCK0";
    parameter multiplier_aclr1     = "ACLR3";
    parameter multiplier_register2 = "CLOCK0";
    parameter multiplier_aclr2     = "ACLR3";
    parameter multiplier_register3 = "CLOCK0";
    parameter multiplier_aclr3     = "ACLR3";

    parameter port_addnsub1                         = "PORT_CONNECTIVITY";
    parameter addnsub_multiplier_register1          = "CLOCK0";
    parameter addnsub_multiplier_aclr1              = "ACLR3";
    parameter addnsub_multiplier_pipeline_register1 = "CLOCK0";
    parameter addnsub_multiplier_pipeline_aclr1     = "ACLR3";

    parameter port_addnsub3                         = "PORT_CONNECTIVITY";
    parameter addnsub_multiplier_register3          = "CLOCK0";
    parameter addnsub_multiplier_aclr3              = "ACLR3";
    parameter addnsub_multiplier_pipeline_register3 = "CLOCK0";
    parameter addnsub_multiplier_pipeline_aclr3     = "ACLR3";

    parameter addnsub1_round_aclr                   = "ACLR3";
    parameter addnsub1_round_pipeline_aclr          = "ACLR3";
    parameter addnsub1_round_register               = "CLOCK0";
    parameter addnsub1_round_pipeline_register      = "CLOCK0";
    parameter addnsub3_round_aclr                   = "ACLR3";
    parameter addnsub3_round_pipeline_aclr          = "ACLR3";
    parameter addnsub3_round_register               = "CLOCK0";
    parameter addnsub3_round_pipeline_register      = "CLOCK0";

    parameter mult01_round_aclr                     = "ACLR3";
    parameter mult01_round_register                 = "CLOCK0";
    parameter mult01_saturation_register            = "CLOCK0";
    parameter mult01_saturation_aclr                = "ACLR3";
    parameter mult23_round_register                 = "CLOCK0";
    parameter mult23_round_aclr                     = "ACLR3";
    parameter mult23_saturation_register            = "CLOCK0";
    parameter mult23_saturation_aclr                = "ACLR3";

    // StratixII parameters
    parameter multiplier01_rounding = "NO";
    parameter multiplier01_saturation = "NO";
    parameter multiplier23_rounding = "NO";
    parameter multiplier23_saturation = "NO";
    parameter adder1_rounding = "NO";
    parameter adder3_rounding = "NO";
    parameter port_mult0_is_saturated = "UNUSED";
    parameter port_mult1_is_saturated = "UNUSED";
    parameter port_mult2_is_saturated = "UNUSED";
    parameter port_mult3_is_saturated = "UNUSED";

    // Stratix III parameters
    // Rounding parameters
    parameter output_rounding = "NO";
    parameter output_round_type = "NEAREST_INTEGER";
    parameter width_msb = 17;
    parameter output_round_register = "UNREGISTERED";
    parameter output_round_aclr = "NONE";
    parameter output_round_pipeline_register = "UNREGISTERED";
    parameter output_round_pipeline_aclr = "NONE";

    parameter chainout_rounding = "NO";
    parameter chainout_round_register = "UNREGISTERED";
    parameter chainout_round_aclr = "NONE";
    parameter chainout_round_pipeline_register = "UNREGISTERED";
    parameter chainout_round_pipeline_aclr = "NONE";
    parameter chainout_round_output_register = "UNREGISTERED";
    parameter chainout_round_output_aclr = "NONE";

    // saturation parameters
    parameter port_output_is_overflow = "PORT_UNUSED";
    parameter port_chainout_sat_is_overflow = "PORT_UNUSED";
    parameter output_saturation = "NO";
    parameter output_saturate_type = "ASYMMETRIC";
    parameter width_saturate_sign = 1;
    parameter output_saturate_register = "UNREGISTERED";
    parameter output_saturate_aclr = "NONE";
    parameter output_saturate_pipeline_register = "UNREGISTERED";
    parameter output_saturate_pipeline_aclr = "NONE";

    parameter chainout_saturation = "NO";
    parameter chainout_saturate_register = "UNREGISTERED";
    parameter chainout_saturate_aclr = "NONE";
    parameter chainout_saturate_pipeline_register = "UNREGISTERED";
    parameter chainout_saturate_pipeline_aclr = "NONE";
    parameter chainout_saturate_output_register = "UNREGISTERED";
    parameter chainout_saturate_output_aclr = "NONE";

    // chainout parameters
    parameter chainout_adder = "NO";
    parameter chainout_register = "UNREGISTERED";
    parameter chainout_aclr = "ACLR3";
    parameter width_chainin = 1;
    parameter zero_chainout_output_register = "UNREGISTERED";
    parameter zero_chainout_output_aclr = "NONE";

    // rotate & shift parameters
    parameter shift_mode = "NO";
    parameter rotate_aclr = "NONE";
    parameter rotate_register = "UNREGISTERED";
    parameter rotate_pipeline_register = "UNREGISTERED";
    parameter rotate_pipeline_aclr = "NONE";
    parameter rotate_output_register = "UNREGISTERED";
    parameter rotate_output_aclr = "NONE";
    parameter shift_right_register = "UNREGISTERED";
    parameter shift_right_aclr = "NONE";
    parameter shift_right_pipeline_register = "UNREGISTERED";
    parameter shift_right_pipeline_aclr = "NONE";
    parameter shift_right_output_register = "UNREGISTERED";
    parameter shift_right_output_aclr = "NONE";

    // loopback parameters
    parameter zero_loopback_register = "UNREGISTERED";
    parameter zero_loopback_aclr = "NONE";
    parameter zero_loopback_pipeline_register = "UNREGISTERED";
    parameter zero_loopback_pipeline_aclr = "NONE";
    parameter zero_loopback_output_register = "UNREGISTERED";
    parameter zero_loopback_output_aclr = "NONE";

    // accumulator parameters
    parameter accum_sload_register = "UNREGISTERED";
    parameter accum_sload_aclr = "NONE";
    parameter accum_sload_pipeline_register = "UNREGISTERED";
    parameter accum_sload_pipeline_aclr = "NONE";
    parameter accum_direction = "ADD";
    parameter accumulator = "NO";

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
    // output parameters

    parameter output_register = "CLOCK0";
    parameter output_aclr     = "ACLR3";

    // general setting parameters

    parameter extra_latency                  = 0;
    parameter dedicated_multiplier_circuitry = "AUTO";
    parameter dsp_block_balancing            = "AUTO";
    parameter intended_device_family         = "Stratix";

    // ----------------
    // PORT DECLARATION
    // ----------------

    // data input ports
    input [number_of_multipliers * width_a -1 : 0] dataa;
    input [number_of_multipliers * width_b -1 : 0] datab;
    input [number_of_multipliers * width_c -1 : 0] datac;

    input [width_a -1 : 0] scanina;
    input [width_b -1 : 0] scaninb;

    input [number_of_multipliers -1 : 0] sourcea;
    input [number_of_multipliers -1 : 0] sourceb;

    // clock ports
    input clock3;
    input clock2;
    input clock1;
    input clock0;

    // clear ports
    input aclr3;
    input aclr2;
    input aclr1;
    input aclr0;

    // clock enable ports
    input ena3;
    input ena2;
    input ena1;
    input ena0;

    // control signals
    input signa;
    input signb;
    input addnsub1;
    input addnsub3;

    // StratixII only input ports
    input mult01_round;
    input mult23_round;
    input mult01_saturation;
    input mult23_saturation;
    input addnsub1_round;
    input addnsub3_round;

    // Stratix III only input ports
    input output_round;
    input chainout_round;
    input output_saturate;
    input chainout_saturate;
    input [width_chainin - 1 : 0] chainin;
    input zero_chainout;
    input rotate;
    input shift_right;
    input zero_loopback;
    input accum_sload;

	//StratixV only input ports
	input [2:0]coefsel0;
	input [2:0]coefsel1;
	input [2:0]coefsel2;
	input [2:0]coefsel3;

    // output ports
    output [width_result -1 : 0] result;
    output [width_a -1 : 0] scanouta;
    output [width_b -1 : 0] scanoutb;

    // StratixII only output ports
    output mult0_is_saturated;
    output mult1_is_saturated;
    output mult2_is_saturated;
    output mult3_is_saturated;

    // Stratix III only output ports
    output overflow;
    output chainout_sat_overflow;

// LOCAL_PARAMETERS_BEGIN

    // -----------------------------------
    //  Parameters internally used
    // -----------------------------------
    // Represent the internal used width_a
    parameter int_width_c = ((preadder_mode == "INPUT" )? width_c: 1);

    parameter int_width_preadder = ((preadder_mode == "INPUT" || preadder_mode == "SQUARE" || preadder_mode == "COEF" )?((width_a > width_b)? width_a + 1 : width_b + 1):width_a);

    parameter int_width_a = ((preadder_mode == "INPUT" || preadder_mode == "SQUARE" || preadder_mode == "COEF" )?((width_a > width_b)? width_a + 1 : width_b + 1):
    						((multiplier01_saturation == "NO") && (multiplier23_saturation == "NO") &&
                            (multiplier01_rounding == "NO") && (multiplier23_rounding == "NO") &&
                            (output_rounding == "NO") && (output_saturation == "NO") &&
                            (chainout_rounding == "NO") && (chainout_saturation == "NO") &&
                            (chainout_adder == "NO") && (input_source_b0 != "LOOPBACK"))? width_a:
                            (width_a < 18)? 18 : width_a);
    // Represent the internal used width_b
    parameter int_width_b = ((preadder_mode == "SQUARE" )?((width_a > width_b)? width_a + 1 : width_b + 1):
    						(preadder_mode == "COEF" || preadder_mode == "CONSTANT")?width_coef:
    						((multiplier01_saturation == "NO") && (multiplier23_saturation == "NO") &&
                            (multiplier01_rounding == "NO") && (multiplier23_rounding == "NO") &&
                            (output_rounding == "NO") && (output_saturation == "NO") &&
                            (chainout_rounding == "NO") && (chainout_saturation == "NO") &&
                            (chainout_adder == "NO") && (input_source_b0 != "LOOPBACK"))? width_b:
                            (width_b < 18)? 18 : width_b);

    parameter int_width_multiply_b = ((preadder_mode == "SIMPLE" || preadder_mode =="SQUARE")? int_width_b :
                                      (preadder_mode == "INPUT") ? int_width_c :
                                      (preadder_mode == "CONSTANT" || preadder_mode == "COEF") ? width_coef: int_width_b);

    //Represent the internally used width_result
    parameter int_width_result = (((multiplier01_saturation == "NO") && (multiplier23_saturation == "NO") &&
                                    (multiplier01_rounding == "NO") && (multiplier23_rounding == "NO") &&
                                    (output_rounding == "NO") && (output_saturation == "NO")
                                    && (chainout_rounding == "NO") && (chainout_saturation == "NO") &&
                                    (chainout_adder == "NO") && (shift_mode == "NO"))? width_result:
                                    (shift_mode != "NO") ? 64 :
                                    (chainout_adder == "YES") ? 44 :
                                    (width_result > (int_width_a + int_width_b))?
                                    (width_result + width_result - int_width_a - int_width_b):
                                    int_width_a + int_width_b);

    parameter mult_b_pre_width = int_width_b + 19;

    // Represent the internally used width_result
    parameter int_mult_diff_bit = (((multiplier01_saturation == "NO") && (multiplier23_saturation == "NO") &&
                                    (multiplier01_rounding == "NO") && (multiplier23_rounding == "NO")
                                    && (output_rounding == "NO") && (output_saturation == "NO") &&
                                    (chainout_rounding == "NO") && (chainout_saturation == "NO") &&
                                    (chainout_adder == "NO"))? 0:
                                    (chainout_adder == "YES") ? ((width_result > width_a + width_b + 8) ? 0: (int_width_a - width_a + int_width_b - width_b)) :
                                    (int_width_a - width_a + int_width_b - width_b));

    parameter int_mult_diff_bit_loopbk = (int_width_result > width_result)? (int_width_result - width_result) :
                                            (width_result - int_width_result);

    parameter sat_ini_value = (((multiplier01_saturation == "NO") && (multiplier23_saturation == "NO"))? 3:
                                int_width_a + int_width_b - 3);

    parameter round_position = ((output_rounding != "NO") || (output_saturate_type == "SYMMETRIC")) ?
                                (input_source_b0 == "LOOPBACK")? 18 :
                                ((width_a + width_b) > width_result)?
                                (int_width_a + int_width_b - width_msb - (width_a + width_b - width_result)) :
                                ((width_a + width_b) == width_result)?
                                (int_width_a + int_width_b - width_msb):
                                (int_width_a + int_width_b - width_msb + (width_result - width_msb) + (width_msb - width_a - width_b)):
                                2;

    parameter chainout_round_position = ((chainout_rounding != "NO") || (output_saturate_type == "SYMMETRIC")) ?
                                (width_result >= int_width_result)? width_result - width_msb :
                                (width_result - width_msb > 0)? width_result + int_mult_diff_bit - width_msb:
                                0 : 2;

    parameter saturation_position = (output_saturation != "NO") ? (chainout_saturation == "NO")?
                                ((width_a + width_b) > width_result)?
                                (int_width_a + int_width_b - width_saturate_sign - (width_a + width_b - width_result)) :
                                ((width_a + width_b) == width_result)?
                                (int_width_a + int_width_b - width_saturate_sign):
                                (int_width_a + int_width_b - width_saturate_sign + (width_result - width_saturate_sign) + (width_saturate_sign - width_a - width_b)): //2;
                                (width_result >= int_width_result)? width_result - width_saturate_sign :
                                (width_result - width_saturate_sign > 0)? width_result + int_mult_diff_bit - width_saturate_sign:
                                0 : 2;

    parameter chainout_saturation_position = (chainout_saturation != "NO") ?
                                (width_result >= int_width_result)? width_result - width_saturate_sign :
                                (width_result - width_saturate_sign > 0)? width_result + int_mult_diff_bit - width_saturate_sign:
                                0 : 2;

    parameter result_msb_stxiii = ((number_of_multipliers == 1) && (width_result > width_a + width_b))?
                                (width_a + width_b - 1):
                                (((number_of_multipliers == 2) || (input_source_b0 == "LOOPBACK")) && (width_result > width_a + width_b + 1))?
                                (width_a + width_b):
                                ((number_of_multipliers > 2) && (width_result > width_a + width_b + 2))?
                                (width_a + width_b + 1):
                                (width_result - 1);

    parameter result_msb = (width_a + width_b - 1);

    parameter shift_partition = (shift_mode == "NO") ? 1 : (int_width_result / 2);
    parameter shift_msb = (shift_mode == "NO") ? 1 : (int_width_result - 1);
    parameter sat_msb = (int_width_a + int_width_b - 1);
    parameter chainout_sat_msb = (int_width_result - 1);

    parameter chainout_input_a = (width_a < 18) ? (18 - width_a) :
                                                1;

    parameter chainout_input_b = (width_b < 18) ? (18 - width_b) :
                                                1;

    parameter mult_res_pad = (int_width_result > int_width_a + int_width_b)? (int_width_result - int_width_a - int_width_b) :
                                                1;

    parameter result_pad = ((width_result - 1 + int_mult_diff_bit) > int_width_result)? (width_result + 1 + int_mult_diff_bit - int_width_result) :
                                                1;

    parameter result_stxiii_pad = (width_result > width_a + width_b)?
                                                (width_result - width_a - width_b) :   1;

    parameter loopback_input_pad = (int_width_b > width_b)? (int_width_b - width_b) : 1;

    parameter loopback_lower_bound = (int_width_b > width_b)? width_b : 0 ;

    parameter accum_width = (int_width_a + int_width_b < 44)? 44: int_width_a + int_width_b;

    parameter feedback_width = ((accum_width + int_mult_diff_bit) < 2*int_width_result)? accum_width + int_mult_diff_bit : 2*int_width_result;

    parameter lower_range = ((2*int_width_result - 1) < (int_width_a + int_width_b)) ? int_width_result : int_width_a + int_width_b;

    parameter addsub1_clr = ((port_addnsub1 == "PORT_USED") || ((port_addnsub1 == "PORT_CONNECTIVITY")&&(multiplier1_direction== "UNUSED")))? 1 : 0;

    parameter addsub3_clr = ((port_addnsub3 == "PORT_USED") || ((port_addnsub3 == "PORT_CONNECTIVITY")&&(multiplier3_direction== "UNUSED")))? 1 : 0;

    parameter lsb_position = 36 - width_a - width_b;

    parameter extra_sign_bit_width = (port_signa == "PORT_USED" || port_signb == "PORT_USED")? accum_width - width_result - lsb_position :
                                (representation_a == "UNSIGNED" && representation_b == "UNSIGNED")? accum_width - width_result - lsb_position:
                                accum_width - width_result + 1 - lsb_position;

    parameter bit_position = accum_width - lsb_position - extra_sign_bit_width - 1;



// LOCAL_PARAMETERS_END

    // -----------------------------------
    // Constants internally used
    // -----------------------------------
    // Represent the number of bits needed to be rounded in multiplier where the
    // value 17 here refers to the 2 sign bits and the 15 wanted bits for rounding
    `define MULT_ROUND_BITS  (((multiplier01_rounding == "NO") && (multiplier23_rounding == "NO"))? 1 : (int_width_a + int_width_b) - 17)

    // Represent the number of bits needed to be rounded in adder where the
    // value 18 here refers to the 3 sign bits and the 15 wanted bits for rounding.
    `define ADDER_ROUND_BITS (((adder1_rounding == "NO") && (adder3_rounding == "NO"))? 1 :(int_width_a + int_width_b) - 17)

    // Represent the user defined width_result
    `define RESULT_WIDTH 44

    // Represent the range for shift mode
    `define SHIFT_MODE_WIDTH (shift_mode != "NO")? 31 : width_result - 1

    // Represent the range for loopback input
    `define LOOPBACK_WIRE_WIDTH (input_source_b0 == "LOOPBACK")? (width_a + 18) : (int_width_result < width_a + 18) ? (width_a + 18) : int_width_result
    // ---------------
    // REG DECLARATION
    // ---------------

    reg  [2*int_width_result - 1 :0] temp_sum;
    reg  [2*int_width_result : 0] mult_res_ext;
    reg  [2*int_width_result - 1 : 0] temp_sum_reg;

    reg  [4 * int_width_a -1 : 0] mult_a_reg;
    reg  [4 * int_width_b -1 : 0] mult_b_reg;
    reg  [int_width_c -1 : 0] mult_c_reg;


    reg  [(int_width_a + int_width_b) -1:0] mult_res_0;
    reg  [(int_width_a + int_width_b) -1:0] mult_res_1;
    reg  [(int_width_a + int_width_b) -1:0] mult_res_2;
    reg  [(int_width_a + int_width_b) -1:0] mult_res_3;


    reg  [4 * (int_width_a + int_width_b) -1:0] mult_res_reg;
    reg  [(int_width_a + int_width_b - 1) :0] mult_res_temp;


    reg sign_a_pipe_reg;
    reg sign_a_reg;
    reg sign_b_pipe_reg;
    reg sign_b_reg;

    reg addsub1_reg;
    reg addsub1_pipe_reg;

    reg addsub3_reg;
    reg addsub3_pipe_reg;


    // StratixII features related internal reg type

    reg [(int_width_a + int_width_b + 3) -1 : 0] mult0_round_out;
    reg [(int_width_a + int_width_b + 3) -1 : 0] mult0_saturate_out;
    reg [(int_width_a + int_width_b + 3) -1 : 0] mult0_result;
    reg mult0_saturate_overflow;
    reg mult0_saturate_overflow_stat;

    reg [(int_width_a + int_width_b + 3) -1 : 0] mult1_round_out;
    reg [(int_width_a + int_width_b + 3) -1 : 0] mult1_saturate_out;
    reg [(int_width_a + int_width_b) -1 : 0] mult1_result;
    reg mult1_saturate_overflow;
    reg mult1_saturate_overflow_stat;

    reg [(int_width_a + int_width_b + 3) -1 : 0] mult2_round_out;
    reg [(int_width_a + int_width_b + 3) -1 : 0] mult2_saturate_out;
    reg [(int_width_a + int_width_b) -1 : 0] mult2_result;
    reg mult2_saturate_overflow;
    reg mult2_saturate_overflow_stat;

    reg [(int_width_a + int_width_b + 3) -1 : 0] mult3_round_out;
    reg [(int_width_a + int_width_b + 3) -1 : 0] mult3_saturate_out;
    reg [(int_width_a + int_width_b) -1 : 0] mult3_result;
    reg mult3_saturate_overflow;
    reg mult3_saturate_overflow_stat;

    reg mult01_round_reg;
    reg mult01_saturate_reg;
    reg mult23_round_reg;
    reg mult23_saturate_reg;
    reg [3 : 0] mult_saturate_overflow_reg;
    reg [3 : 0] mult_saturate_overflow_pipe_reg;

    reg [int_width_result : 0] adder1_round_out;
    reg [int_width_result : 0] adder1_result;
    reg [int_width_result : 0] adder2_result;
    reg addnsub1_round_reg;
    reg addnsub1_round_pipe_reg;

    reg [int_width_result : 0] adder3_round_out;
    reg [int_width_result : 0] adder3_result;
    reg addnsub3_round_reg;
    reg addnsub3_round_pipe_reg;

    // Stratix III only internal registers
    reg outround_reg;
    reg outround_pipe_reg;
    reg chainout_round_reg;
    reg chainout_round_pipe_reg;
    reg chainout_round_out_reg;
    reg outsat_reg;
    reg outsat_pipe_reg;
    reg chainout_sat_reg;
    reg chainout_sat_pipe_reg;
    reg chainout_sat_out_reg;
    reg zerochainout_reg;
    reg rotate_reg;
    reg rotate_pipe_reg;
    reg rotate_out_reg;
    reg shiftr_reg;
    reg shiftr_pipe_reg;
    reg shiftr_out_reg;
    reg zeroloopback_reg;
    reg zeroloopback_pipe_reg;
    reg zeroloopback_out_reg;
    reg accumsload_reg;
    reg accumsload_pipe_reg;

    reg [int_width_a -1 : 0] scanouta_reg;
    reg [2*int_width_result - 1: 0] adder1_reg;
    reg [2*int_width_result - 1: 0] adder3_reg;
    reg [2*int_width_result - 1: 0] adder1_sum;
    reg [2*int_width_result - 1: 0] adder3_sum;
    reg [accum_width + int_mult_diff_bit : 0] adder1_res_ext;
    reg [2*int_width_result: 0] adder3_res_ext;
    reg [2*int_width_result - 1: 0] round_block_result;
    reg [2*int_width_result - 1: 0] sat_block_result;
    reg [2*int_width_result - 1: 0] round_sat_blk_res;
    reg [int_width_result: 0] chainout_round_block_result;
    reg [int_width_result: 0] chainout_sat_block_result;
    reg [2*int_width_result - 1: 0] round_sat_in_result;
    reg [int_width_result: 0] chainout_rnd_sat_blk_res;
    reg [int_width_result: 0] chainout_output_reg;
    reg [int_width_result: 0] chainout_final_out;
    reg [int_width_result : 0] shift_rot_result;
    reg [2*int_width_result - 1: 0] acc_feedback_reg;
    reg [int_width_result: 0] chout_shftrot_reg;
    reg [int_width_result: 0] loopback_wire_reg;
    reg [int_width_result: 0] loopback_wire_latency;

    reg overflow_status;
    reg overflow_stat_reg;
    reg [extra_latency : 0] overflow_stat_pipe_reg;
    reg [extra_latency : 0] accum_overflow_stat_pipe_reg;
    reg [extra_latency : 0] unsigned_sub1_overflow_pipe_reg;
    reg [extra_latency : 0] unsigned_sub3_overflow_pipe_reg;
    reg chainout_overflow_status;
    reg chainout_overflow_stat_reg;
    reg stick_bits_or;
    reg cho_stick_bits_or;
    reg sat_bits_or;
    reg cho_sat_bits_or;
    reg round_happen;
    reg cho_round_happen;

    reg overflow_checking;
    reg round_checking;

    reg [accum_width + int_mult_diff_bit : 0] accum_res_temp;
    reg [accum_width + int_mult_diff_bit : 0] accum_res;
    reg [accum_width + int_mult_diff_bit : 0] acc_feedback_temp;
    reg accum_overflow;
    reg accum_overflow_int;
    reg accum_overflow_reg;
    reg [accum_width + int_mult_diff_bit : 0] adder3_res_temp;
    reg unsigned_sub1_overflow;
    reg unsigned_sub3_overflow;
    reg unsigned_sub1_overflow_reg;
    reg unsigned_sub3_overflow_reg;
    reg unsigned_sub1_overflow_mult_reg;
    reg unsigned_sub3_overflow_mult_reg;
    wire unsigned_sub1_overflow_wire;
    wire unsigned_sub3_overflow_wire;

    wire [mult_b_pre_width - 1 : 0] loopback_wire_temp;

    // StratixV internal register
    reg [2:0]coeffsel_a_reg;
    reg [2:0]coeffsel_b_reg;
    reg [2:0]coeffsel_c_reg;
    reg [2:0]coeffsel_d_reg;

    reg [2*int_width_a - 1: 0] preadder_sum1a;
    reg [2*int_width_b - 1: 0] preadder_sum2a;

    reg [(int_width_a + int_width_b + 1) -1 : 0] preadder0_result;
    reg [(int_width_a + int_width_b + 1) -1 : 0] preadder1_result;
    reg [(int_width_a + int_width_b + 1) -1 : 0] preadder2_result;
    reg [(int_width_a + int_width_b + 1) -1 : 0] preadder3_result;

    reg  [(int_width_a + int_width_b) -1:0] preadder_res_0;
    reg  [(int_width_a + int_width_b) -1:0] preadder_res_1;
    reg  [(int_width_a + int_width_b) -1:0] preadder_res_2;
    reg  [(int_width_a + int_width_b) -1:0] preadder_res_3;

    reg  [(int_width_a + int_width_b) -1:0] mult_res_reg_0;
    reg  [(int_width_a + int_width_b) -1:0] mult_res_reg_2;
    reg  [2*int_width_result - 1: 0] adder1_res_reg_0;
    reg  [2*int_width_result - 1: 0] adder1_res_reg_1;
    reg  [(width_chainin) -1:0] chainin_reg;
    reg  [2*int_width_result - 1: 0] round_sat_in_reg;


    //-----------------
    // TRI DECLARATION
    //-----------------
    logic signa_z; // -- converted tristate to logic
    logic signb_z; // -- converted tristate to logic
    logic addnsub1_z; // -- converted tristate to logic
    logic addnsub3_z; // -- converted tristate to logic
    logic  [4 * int_width_a -1 : 0] dataa_int; // -- converted tristate to logic
    logic  [4 * int_width_b -1 : 0] datab_int; // -- converted tristate to logic
    logic  [int_width_c -1 : 0] datac_int; // -- converted tristate to logic
    logic  [4 * int_width_a -1 : 0] new_dataa_int; // -- converted tristate to logic
    logic  [4 * int_width_a -1 : 0] chainout_new_dataa_int; // -- converted tristate to logic
    logic  [4 * int_width_b -1 : 0] new_datab_int; // -- converted tristate to logic
    logic  [4 * int_width_b -1 : 0] chainout_new_datab_int; // -- converted tristate to logic
    reg  [4 * int_width_a -1 : 0] dataa_reg;
    reg  [4 * int_width_b -1 : 0] datab_reg;
    logic  [int_width_a - 1 : 0] scanina_z; // -- converted tristate to logic
    logic  [int_width_b - 1 : 0] scaninb_z; // -- converted tristate to logic

    // Stratix III signals
    logic outround_int; // -- converted tristate to logic
    logic chainout_round_int; // -- converted tristate to logic
    logic outsat_int; // -- converted tristate to logic
    logic chainout_sat_int; // -- converted tristate to logic
    logic zerochainout_int; // -- converted tristate to logic
    logic rotate_int; // -- converted tristate to logic
    logic shiftr_int; // -- converted tristate to logic
    logic zeroloopback_int; // -- converted tristate to logic
    logic accumsload_int; // -- converted tristate to logic
    logic [width_chainin - 1 : 0] chainin_int; // -- converted tristate to logic

    // Stratix V signals
    //logic loadconst_int; // -- converted tristate to logic
    //logic negate_int; // -- converted tristate to logic
    //logic accum_int; // -- converted tristate to logic
	logic [2:0]coeffsel_a_int; // -- converted tristate to logic
    logic [2:0]coeffsel_b_int; // -- converted tristate to logic
    logic [2:0]coeffsel_c_int; // -- converted tristate to logic
    logic [2:0]coeffsel_d_int; // -- converted tristate to logic

    // Tri wire for clear signal
    logic input_reg_a0_wire_clr; // -- converted tristate to logic
    logic input_reg_a1_wire_clr; // -- converted tristate to logic
    logic input_reg_a2_wire_clr; // -- converted tristate to logic
    logic input_reg_a3_wire_clr; // -- converted tristate to logic

    logic input_reg_b0_wire_clr; // -- converted tristate to logic
    logic input_reg_b1_wire_clr; // -- converted tristate to logic
    logic input_reg_b2_wire_clr; // -- converted tristate to logic
    logic input_reg_b3_wire_clr; // -- converted tristate to logic

    logic input_reg_c0_wire_clr; // -- converted tristate to logic
    logic input_reg_c1_wire_clr; // -- converted tristate to logic
    logic input_reg_c2_wire_clr; // -- converted tristate to logic
    logic input_reg_c3_wire_clr; // -- converted tristate to logic

    logic sign_reg_a_wire_clr; // -- converted tristate to logic
    logic sign_pipe_a_wire_clr; // -- converted tristate to logic

    logic sign_reg_b_wire_clr; // -- converted tristate to logic
    logic sign_pipe_b_wire_clr; // -- converted tristate to logic

    logic addsub1_reg_wire_clr; // -- converted tristate to logic
    logic addsub1_pipe_wire_clr; // -- converted tristate to logic

    logic addsub3_reg_wire_clr; // -- converted tristate to logic
    logic addsub3_pipe_wire_clr; // -- converted tristate to logic

    // Stratix III only aclr signals
    logic outround_reg_wire_clr; // -- converted tristate to logic
    logic outround_pipe_wire_clr; // -- converted tristate to logic
    logic chainout_round_reg_wire_clr; // -- converted tristate to logic
    logic chainout_round_pipe_wire_clr; // -- converted tristate to logic
    logic chainout_round_out_reg_wire_clr; // -- converted tristate to logic
    logic outsat_reg_wire_clr; // -- converted tristate to logic
    logic outsat_pipe_wire_clr; // -- converted tristate to logic
    logic chainout_sat_reg_wire_clr; // -- converted tristate to logic
    logic chainout_sat_pipe_wire_clr; // -- converted tristate to logic
    logic chainout_sat_out_reg_wire_clr; // -- converted tristate to logic
    logic scanouta_reg_wire_clr; // -- converted tristate to logic
    logic chainout_reg_wire_clr; // -- converted tristate to logic
    logic zerochainout_reg_wire_clr; // -- converted tristate to logic
    logic rotate_reg_wire_clr; // -- converted tristate to logic
    logic rotate_pipe_wire_clr; // -- converted tristate to logic
    logic rotate_out_reg_wire_clr; // -- converted tristate to logic
    logic shiftr_reg_wire_clr; // -- converted tristate to logic
    logic shiftr_pipe_wire_clr; // -- converted tristate to logic
    logic shiftr_out_reg_wire_clr; // -- converted tristate to logic
    logic zeroloopback_reg_wire_clr; // -- converted tristate to logic
    logic zeroloopback_pipe_wire_clr; // -- converted tristate to logic
    logic zeroloopback_out_wire_clr; // -- converted tristate to logic
    logic accumsload_reg_wire_clr; // -- converted tristate to logic
    logic accumsload_pipe_wire_clr; // -- converted tristate to logic
    // end Stratix III only aclr signals

    // Stratix V only aclr signals
    logic coeffsela_reg_wire_clr; // -- converted tristate to logic
    logic coeffselb_reg_wire_clr; // -- converted tristate to logic
    logic coeffselc_reg_wire_clr; // -- converted tristate to logic
    logic coeffseld_reg_wire_clr; // -- converted tristate to logic

    // end Stratix V only aclr signals

    logic multiplier_reg0_wire_clr; // -- converted tristate to logic
    logic multiplier_reg1_wire_clr; // -- converted tristate to logic
    logic multiplier_reg2_wire_clr; // -- converted tristate to logic
    logic multiplier_reg3_wire_clr; // -- converted tristate to logic

    logic addnsub1_round_wire_clr; // -- converted tristate to logic
    logic addnsub1_round_pipe_wire_clr; // -- converted tristate to logic

    logic addnsub3_round_wire_clr; // -- converted tristate to logic
    logic addnsub3_round_pipe_wire_clr; // -- converted tristate to logic

    logic mult01_round_wire_clr; // -- converted tristate to logic
    logic mult01_saturate_wire_clr; // -- converted tristate to logic

    logic mult23_round_wire_clr; // -- converted tristate to logic
    logic mult23_saturate_wire_clr; // -- converted tristate to logic

    logic output_reg_wire_clr; // -- converted tristate to logic

    logic [3 : 0] sourcea_wire; // -- converted tristate to logic
    logic [3 : 0] sourceb_wire; // -- converted tristate to logic



    // Tri wire for enable signal

    logic input_reg_a0_wire_en; // -- converted tristate to logic
    logic input_reg_a1_wire_en; // -- converted tristate to logic
    logic input_reg_a2_wire_en; // -- converted tristate to logic
    logic input_reg_a3_wire_en; // -- converted tristate to logic

    logic input_reg_b0_wire_en; // -- converted tristate to logic
    logic input_reg_b1_wire_en; // -- converted tristate to logic
    logic input_reg_b2_wire_en; // -- converted tristate to logic
    logic input_reg_b3_wire_en; // -- converted tristate to logic

    logic input_reg_c0_wire_en; // -- converted tristate to logic
    logic input_reg_c1_wire_en; // -- converted tristate to logic
    logic input_reg_c2_wire_en; // -- converted tristate to logic
    logic input_reg_c3_wire_en; // -- converted tristate to logic

    logic sign_reg_a_wire_en; // -- converted tristate to logic
    logic sign_pipe_a_wire_en; // -- converted tristate to logic

    logic sign_reg_b_wire_en; // -- converted tristate to logic
    logic sign_pipe_b_wire_en; // -- converted tristate to logic

    logic addsub1_reg_wire_en; // -- converted tristate to logic
    logic addsub1_pipe_wire_en; // -- converted tristate to logic

    logic addsub3_reg_wire_en; // -- converted tristate to logic
    logic addsub3_pipe_wire_en; // -- converted tristate to logic

    // Stratix III only ena signals
    logic outround_reg_wire_en; // -- converted tristate to logic
    logic outround_pipe_wire_en; // -- converted tristate to logic
    logic chainout_round_reg_wire_en; // -- converted tristate to logic
    logic chainout_round_pipe_wire_en; // -- converted tristate to logic
    logic chainout_round_out_reg_wire_en; // -- converted tristate to logic
    logic outsat_reg_wire_en; // -- converted tristate to logic
    logic outsat_pipe_wire_en; // -- converted tristate to logic
    logic chainout_sat_reg_wire_en; // -- converted tristate to logic
    logic chainout_sat_pipe_wire_en; // -- converted tristate to logic
    logic chainout_sat_out_reg_wire_en; // -- converted tristate to logic
    logic scanouta_reg_wire_en; // -- converted tristate to logic
    logic chainout_reg_wire_en; // -- converted tristate to logic
    logic zerochainout_reg_wire_en; // -- converted tristate to logic
    logic rotate_reg_wire_en; // -- converted tristate to logic
    logic rotate_pipe_wire_en; // -- converted tristate to logic
    logic rotate_out_reg_wire_en; // -- converted tristate to logic
    logic shiftr_reg_wire_en; // -- converted tristate to logic
    logic shiftr_pipe_wire_en; // -- converted tristate to logic
    logic shiftr_out_reg_wire_en; // -- converted tristate to logic
    logic zeroloopback_reg_wire_en; // -- converted tristate to logic
    logic zeroloopback_pipe_wire_en; // -- converted tristate to logic
    logic zeroloopback_out_wire_en; // -- converted tristate to logic
    logic accumsload_reg_wire_en; // -- converted tristate to logic
    logic accumsload_pipe_wire_en; // -- converted tristate to logic
    // end Stratix III only ena signals

    // Stratix V only ena signals
    logic coeffsela_reg_wire_en; // -- converted tristate to logic
    logic coeffselb_reg_wire_en; // -- converted tristate to logic
    logic coeffselc_reg_wire_en; // -- converted tristate to logic
    logic coeffseld_reg_wire_en; // -- converted tristate to logic

    // end Stratix V only ena signals

    logic multiplier_reg0_wire_en; // -- converted tristate to logic
    logic multiplier_reg1_wire_en; // -- converted tristate to logic
    logic multiplier_reg2_wire_en; // -- converted tristate to logic
    logic multiplier_reg3_wire_en; // -- converted tristate to logic

    logic addnsub1_round_wire_en; // -- converted tristate to logic
    logic addnsub1_round_pipe_wire_en; // -- converted tristate to logic

    logic addnsub3_round_wire_en; // -- converted tristate to logic
    logic addnsub3_round_pipe_wire_en; // -- converted tristate to logic

    logic mult01_round_wire_en; // -- converted tristate to logic
    logic mult01_saturate_wire_en; // -- converted tristate to logic

    logic mult23_round_wire_en; // -- converted tristate to logic
    logic mult23_saturate_wire_en; // -- converted tristate to logic

    logic output_reg_wire_en; // -- converted tristate to logic

    logic mult0_source_scanin_en; // -- converted tristate to logic
    logic mult1_source_scanin_en; // -- converted tristate to logic
    logic mult2_source_scanin_en; // -- converted tristate to logic
    logic mult3_source_scanin_en; // -- converted tristate to logic



    // ----------------
    // WIRE DECLARATION
    // ----------------

    // Wire for Clock signals
    wire input_reg_a0_wire_clk;
    wire input_reg_a1_wire_clk;
    wire input_reg_a2_wire_clk;
    wire input_reg_a3_wire_clk;

    wire input_reg_b0_wire_clk;
    wire input_reg_b1_wire_clk;
    wire input_reg_b2_wire_clk;
    wire input_reg_b3_wire_clk;

    wire input_reg_c0_wire_clk;
    wire input_reg_c1_wire_clk;
    wire input_reg_c2_wire_clk;
    wire input_reg_c3_wire_clk;

    wire sign_reg_a_wire_clk;
    wire sign_pipe_a_wire_clk;

    wire sign_reg_b_wire_clk;
    wire sign_pipe_b_wire_clk;

    wire addsub1_reg_wire_clk;
    wire addsub1_pipe_wire_clk;

    wire addsub3_reg_wire_clk;
    wire addsub3_pipe_wire_clk;

    // Stratix III only clock signals
    wire outround_reg_wire_clk;
    wire outround_pipe_wire_clk;
    wire chainout_round_reg_wire_clk;
    wire chainout_round_pipe_wire_clk;
    wire chainout_round_out_reg_wire_clk;
    wire outsat_reg_wire_clk;
    wire outsat_pipe_wire_clk;
    wire chainout_sat_reg_wire_clk;
    wire chainout_sat_pipe_wire_clk;
    wire chainout_sat_out_reg_wire_clk;
    wire scanouta_reg_wire_clk;
    wire chainout_reg_wire_clk;
    wire zerochainout_reg_wire_clk;
    wire rotate_reg_wire_clk;
    wire rotate_pipe_wire_clk;
    wire rotate_out_reg_wire_clk;
    wire shiftr_reg_wire_clk;
    wire shiftr_pipe_wire_clk;
    wire shiftr_out_reg_wire_clk;
    wire zeroloopback_reg_wire_clk;
    wire zeroloopback_pipe_wire_clk;
    wire zeroloopback_out_wire_clk;
    wire accumsload_reg_wire_clk;
    wire accumsload_pipe_wire_clk;
    // end Stratix III only clock signals

    //Stratix V only clock signals
    wire coeffsela_reg_wire_clk;
    wire coeffselb_reg_wire_clk;
    wire coeffselc_reg_wire_clk;
    wire coeffseld_reg_wire_clk;
    wire  [4 * (int_width_preadder) -1:0] preadder_res_wire;
    wire [26:0] coeffsel_a_pre;
    wire [26:0] coeffsel_b_pre;
    wire [26:0] coeffsel_c_pre;
    wire [26:0] coeffsel_d_pre;

    // For fixing warning,
    wire systolic1_reg_wire_clk, systolic3_reg_wire_clk;
    wire systolic1_reg_wire_clr, systolic3_reg_wire_clr;
    wire systolic1_reg_wire_en, systolic3_reg_wire_en;
    // end Stratix V only clock signals

    wire multiplier_reg0_wire_clk;
    wire multiplier_reg1_wire_clk;
    wire multiplier_reg2_wire_clk;
    wire multiplier_reg3_wire_clk;

    wire output_reg_wire_clk;

    wire addnsub1_round_wire_clk;
    wire addnsub1_round_pipe_wire_clk;
    wire addnsub1_round_wire;
    wire addnsub1_round_pipe_wire;
    wire addnsub1_round_pre;
    wire addnsub3_round_wire_clk;
    wire addnsub3_round_pipe_wire_clk;
    wire addnsub3_round_wire;
    wire addnsub3_round_pipe_wire;
    wire addnsub3_round_pre;

    wire mult01_round_wire_clk;
    wire mult01_saturate_wire_clk;
    wire mult23_round_wire_clk;
    wire mult23_saturate_wire_clk;
    wire mult01_round_pre;
    wire mult01_saturate_pre;
    wire mult01_round_wire;
    wire mult01_saturate_wire;
    wire mult23_round_pre;
    wire mult23_saturate_pre;
    wire mult23_round_wire;
    wire mult23_saturate_wire;
    wire [3 : 0] mult_is_saturate_vec;
    wire [3 : 0] mult_saturate_overflow_vec;

    wire [4 * int_width_a -1 : 0] mult_a_pre;
    wire [4 * int_width_b -1 : 0] mult_b_pre;
    wire [int_width_c -1 : 0] mult_c_pre;

    wire [int_width_a -1 : 0] scanouta;
    wire [int_width_b -1 : 0] scanoutb;

    wire sign_a_int;
    wire sign_b_int;

    wire addsub1_int;
    wire addsub3_int;

    wire  [4 * int_width_a -1 : 0] mult_a_wire;
    wire  [4 * int_width_b -1 : 0] mult_b_wire;
    wire  [4 * int_width_c -1 : 0] mult_c_wire;
    wire  [4 * (int_width_a + int_width_b) -1:0] mult_res_wire;
    wire sign_a_pipe_wire;
    wire sign_a_wire;
    wire sign_b_pipe_wire;
    wire sign_b_wire;
    wire addsub1_wire;
    wire addsub1_pipe_wire;
    wire addsub3_wire;
    wire addsub3_pipe_wire;

    wire ena_aclr_signa_wire;
    wire ena_aclr_signb_wire;

    wire [int_width_a -1 : 0] i_scanina;
    wire [int_width_b -1 : 0] i_scaninb;

    wire [(2*int_width_result - 1): 0] output_reg_wire_result;
    wire [31:0] head_result_wire;
    reg [(2*int_width_result - 1): 0] output_laten_result;
    reg [(2*int_width_result - 1): 0] result_pipe [extra_latency : 0];
    reg [(2*int_width_result - 1): 0] result_pipe1 [extra_latency : 0];
    reg [31:0] head_result;
    integer head_result_int;

    // Stratix III only wires
    wire outround_wire;
    wire outround_pipe_wire;
    wire chainout_round_wire;
    wire chainout_round_pipe_wire;
    wire chainout_round_out_wire;
    wire outsat_wire;
    wire outsat_pipe_wire;
    wire chainout_sat_wire;
    wire chainout_sat_pipe_wire;
    wire chainout_sat_out_wire;
    wire [int_width_a -1 : 0] scanouta_wire;
    wire [int_width_result: 0] chainout_add_result;
    wire [2*int_width_result - 1: 0] adder1_res_wire;
    wire [2*int_width_result - 1: 0] adder3_res_wire;
    wire [int_width_result - 1: 0] chainout_adder_in_wire;
    wire zerochainout_wire;
    wire rotate_wire;
    wire rotate_pipe_wire;
    wire rotate_out_wire;
    wire shiftr_wire;
    wire shiftr_pipe_wire;
    wire shiftr_out_wire;
    wire zeroloopback_wire;
    wire zeroloopback_pipe_wire;
    wire zeroloopback_out_wire;
    wire accumsload_wire;
    wire accumsload_pipe_wire;
    wire [int_width_result: 0] chainout_output_wire;
    wire [int_width_result: 0] shift_rot_blk_in_wire;
    wire [int_width_result - 1: 0] loopback_out_wire;
    wire [int_width_result - 1: 0] loopback_out_wire_feedback;
    reg [int_width_result: 0] loopback_wire;
    wire [2*int_width_result - 1: 0] acc_feedback;

    wire [width_result - 1 : 0] result_stxiii;
    wire [width_result - 1 : 0] result_stxiii_ext;

    wire  [width_result - 1 : 0] result_ext;
    wire  [width_result - 1 : 0] result_stxii_ext;

    // StratixV only wires
    wire [width_result - 1 : 0]accumsload_sel;
    wire [63 : 0]load_const_value;
    wire [2:0]coeffsel_a_wire;
    wire [2:0]coeffsel_b_wire;
    wire [2:0]coeffsel_c_wire;
    wire [2:0]coeffsel_d_wire;
    wire  [(int_width_a + int_width_b) -1:0] systolic_register1;
    wire  [(int_width_a + int_width_b) -1:0] systolic_register3;
    wire  [2*int_width_result - 1: 0] adder1_systolic_register0;
    wire  [2*int_width_result - 1: 0] adder1_systolic_register1;
    wire  [2*int_width_result - 1: 0] adder1_systolic;
    wire  [(width_chainin) -1:0] chainin_register1;

    //fix lint warning
    wire [chainout_input_a + width_a - 1 :0] chainout_new_dataa_temp;
    wire [chainout_input_a + width_a - 1 :0] chainout_new_dataa_temp2;
    wire [chainout_input_a + width_a - 1 :0] chainout_new_dataa_temp3;
    wire [chainout_input_a + width_a - 1 :0] chainout_new_dataa_temp4;
    wire [chainout_input_b + width_b +width_coef - 1 :0] chainout_new_datab_temp;
    wire [chainout_input_b + width_b +width_coef - 1 :0] chainout_new_datab_temp2;
    wire [chainout_input_b + width_b +width_coef - 1 :0] chainout_new_datab_temp3;
    wire [chainout_input_b + width_b +width_coef - 1 :0] chainout_new_datab_temp4;
    wire [int_width_b - 1: 0] mult_b_pre_temp;
    wire [result_pad + int_width_result + 1 - int_mult_diff_bit : 0] result_stxiii_temp;
    wire [result_pad + int_width_result - int_mult_diff_bit : 0] result_stxiii_temp2;
    wire [result_pad + int_width_result - int_mult_diff_bit : 0] result_stxiii_temp3;
    wire [result_pad + int_width_result - 1 - int_mult_diff_bit : 0] result_stxii_ext_temp;
    wire [result_pad + int_width_result - 1 - int_mult_diff_bit : 0] result_stxii_ext_temp2;

    wire stratixii_block;
    wire stratixiii_block;
	wire stratixv_block;
	wire altera_mult_add_block;

    //accumulator overflow fix
    integer x;
    integer i;

    reg and_sign_wire;
    reg or_sign_wire;
    reg [extra_sign_bit_width - 1 : 0] extra_sign_bits;
    reg msb;

    // -------------------
    // INTEGER DECLARATION
    // -------------------
    integer num_bit_mult0;
    integer num_bit_mult1;
    integer num_bit_mult2;
    integer num_bit_mult3;
    integer j;
    integer num_mult;
    integer num_stor;
    integer rnd_bit_cnt;
    integer sat_bit_cnt;
    integer cho_rnd_bit_cnt;
    integer cho_sat_bit_cnt;
    integer sat_all_bit_cnt;
    integer cho_sat_all_bit_cnt;
    integer lpbck_cnt;
    integer overflow_status_bit_pos;

    // ------------------------
    // COMPONENT INSTANTIATIONS
    // ------------------------
    ALTERA_DEVICE_FAMILIES dev ();


    // -----------------------------------------------------------------------------
    // This block checks if the two numbers to be multiplied (mult_a/mult_b) is to
    // be interpreted as a negative number or not. If so, then two's complement is
    // performed.
    // The numbers are then multipled. The sign of the result (positive or negative)
    // is determined based on the sign of the two input numbers
    // ------------------------------------------------------------------------------

    function [(int_width_a + int_width_b - 1):0] do_multiply;
        input [32 : 0] multiplier;
        input signa_wire;
        input signb_wire;
    begin:MULTIPLY

        reg [int_width_a + int_width_b -1 :0] temp_mult_zero;
        reg [int_width_a + int_width_b -1 :0] temp_mult;
        reg [int_width_a -1 :0]        op_a;
        reg [int_width_b -1 :0]        op_b;
        reg [int_width_a -1 :0]        op_a_int;
        reg [int_width_b -1 :0]        op_b_int;
        reg neg_a;
        reg neg_b;
        reg temp_mult_signed;

        temp_mult_zero = 0;
        temp_mult = 0;

        op_a = mult_a_wire >> (multiplier * int_width_a);
        op_b = mult_b_wire >> (multiplier * int_width_b);

        neg_a = op_a[int_width_a-1] & (signa_wire);
        neg_b = op_b[int_width_b-1] & (signb_wire);

        op_a_int = (neg_a == 1) ? (~op_a + 1) : op_a;
        op_b_int = (neg_b == 1) ? (~op_b + 1) : op_b;

        temp_mult = op_a_int * op_b_int;
        temp_mult = (neg_a ^ neg_b) ? (temp_mult_zero - temp_mult) : temp_mult;

        do_multiply = temp_mult;
    end
    endfunction

    function [(int_width_a + int_width_b - 1):0] do_multiply_loopback;
        input [32 : 0] multiplier;
        input signa_wire;
        input signb_wire;
    begin:MULTIPLY

        reg [int_width_a + int_width_b -1 :0] temp_mult_zero;
        reg [int_width_a + int_width_b -1 :0] temp_mult;
        reg [int_width_a -1 :0]        op_a;
        reg [int_width_b -1 :0]        op_b;
        reg [int_width_a -1 :0]        op_a_int;
        reg [int_width_b -1 :0]        op_b_int;
        reg neg_a;
        reg neg_b;
        reg temp_mult_signed;

        temp_mult_zero = 0;
        temp_mult = 0;

        op_a = mult_a_wire >> (multiplier * int_width_a);
        op_b = mult_b_wire >> (multiplier * int_width_b + (int_width_b - width_b));

        if(int_width_b > width_b)
            op_b[int_width_b - 1: loopback_lower_bound] = ({(loopback_input_pad){(op_b[width_b - 1])& (sign_b_pipe_wire)}});

        neg_a = op_a[int_width_a-1] & (signa_wire);
        neg_b = op_b[int_width_b-1] & (signb_wire);

        op_a_int = (neg_a == 1) ? (~op_a + 1) : op_a;
        op_b_int = (neg_b == 1) ? (~op_b + 1) : op_b;

        temp_mult = op_a_int * op_b_int;
        temp_mult = (neg_a ^ neg_b) ? (temp_mult_zero - temp_mult) : temp_mult;

        do_multiply_loopback = temp_mult;
    end
    endfunction

    function [(int_width_a + int_width_b  - 1):0] do_multiply_stratixv;
        input [32 : 0] multiplier;
        input signa_wire;
        input signb_wire;
    begin:MULTIPLY_STRATIXV

        reg [int_width_a + int_width_multiply_b -1 :0] temp_mult_zero;
        reg [int_width_a + int_width_b -1 :0] temp_mult;
        reg [int_width_a -1 :0]        op_a;
        reg [int_width_multiply_b -1 :0]        op_b;
        reg [int_width_a -1 :0]        op_a_int;
        reg [int_width_multiply_b -1 :0]        op_b_int;
        reg neg_a;
        reg neg_b;
        reg temp_mult_signed;

        temp_mult_zero = 0;
        temp_mult = 0;

        op_a = preadder_sum1a;
        op_b = preadder_sum2a;

        neg_a = op_a[int_width_a-1] & (signa_wire);
        neg_b = op_b[int_width_multiply_b-1] & (signb_wire);

        op_a_int = (neg_a == 1) ? (~op_a + 1) : op_a;
        op_b_int = (neg_b == 1) ? (~op_b + 1) : op_b;

        temp_mult = op_a_int * op_b_int;
        temp_mult = (neg_a ^ neg_b) ? (temp_mult_zero - temp_mult) : temp_mult;

        do_multiply_stratixv = temp_mult;
    end
    endfunction


// -----------------------------------------------------------------------------
    // This block checks if the two numbers to be added (mult_a/mult_b) is to
    // be interpreted as a negative number or not. If so, then two's complement is
    // performed.
    // The 1st number subtracts the 2nd number. The sign of the result (positive or negative)
    // is determined based on the sign of the two input numbers
    // ------------------------------------------------------------------------------

    function [2*int_width_result:0] do_sub1_level1;
        input [32:0] adder;
        input signa_wire;
        input signb_wire;
    begin:SUB_LV1

        reg [2*int_width_result - 1 :0] temp_sub;
        reg [2*int_width_result - 1 :0] op_a;
        reg [2*int_width_result - 1 :0] op_b;

        temp_sub = 0;
        unsigned_sub1_overflow = 0;


        if (stratixiii_block == 0 && stratixv_block == 0)
        begin
            op_a = temp_sum;
            op_b = mult_res_ext;
            op_a[2*int_width_result - 1:int_width_result] = {(2*int_width_result - int_width_result){op_a[int_width_result - 1] & (signa_wire | signb_wire)}};
            op_b[2*int_width_result - 1:int_width_result] = {(2*int_width_result - int_width_result){op_b[int_width_result - 1] & (signa_wire | signb_wire)}};
        end
        else
        begin
            op_a = adder1_sum;
            op_b = mult_res_ext;
            op_a[2*int_width_result - 1:lower_range] = {(2*int_width_result - lower_range){op_a[lower_range - 1] & (signa_wire | signb_wire)}};
            op_b[2*int_width_result - 1:lower_range] = {(2*int_width_result - lower_range){op_b[lower_range - 1] & (signa_wire | signb_wire)}};
        end

        temp_sub = op_a - op_b;
        if(temp_sub[2*int_width_result - 1] == 1)
        begin
            unsigned_sub1_overflow = 1'b1;
        end
        do_sub1_level1 = temp_sub;
    end
    endfunction

    function [2*int_width_result - 1:0] do_add1_level1;
        input [32:0] adder;
        input signa_wire;
        input signb_wire;
    begin:ADD_LV1

        reg [2*int_width_result - 1 :0] temp_add;
        reg [2*int_width_result - 1 :0] op_a;
        reg [2*int_width_result - 1 :0] op_b;

        temp_add = 0;

        if (stratixiii_block == 0 && stratixv_block == 0)
        begin
            op_a = temp_sum;
            op_b = mult_res_ext;
            op_a[2*int_width_result - 1:int_width_result] = {(2*int_width_result - int_width_result){op_a[int_width_result - 1] & (signa_wire | signb_wire)}};
            op_b[2*int_width_result - 1:int_width_result] = {(2*int_width_result - int_width_result){op_b[int_width_result - 1] & (signa_wire | signb_wire)}};
        end
        else
        begin
            op_a = adder1_sum;
            op_b = mult_res_ext;
            op_a[2*int_width_result - 1:lower_range] = {(2*int_width_result - lower_range){op_a[lower_range - 1] & (signa_wire | signb_wire)}};
            op_b[2*int_width_result - 1:lower_range] = {(2*int_width_result - lower_range){op_b[lower_range - 1] & (signa_wire | signb_wire)}};
        end

        temp_add = op_a + op_b + chainin_register1;
        do_add1_level1 = temp_add;
    end
    endfunction

    // -----------------------------------------------------------------------------
    // This block checks if the two numbers to be added (mult_a/mult_b) is to
    // be interpreted as a negative number or not. If so, then two's complement is
    // performed.
    // The 1st number subtracts the 2nd number. The sign of the result (positive or negative)
    // is determined based on the sign of the two input numbers
    // ------------------------------------------------------------------------------

    function [2*int_width_result - 1:0] do_sub3_level1;
        input [32:0] adder;
        input signa_wire;
        input signb_wire;
    begin:SUB3_LV1

        reg [2*int_width_result - 1 :0] temp_sub;
        reg [2*int_width_result - 1 :0] op_a;
        reg [2*int_width_result - 1 :0] op_b;

        temp_sub = 0;
        unsigned_sub3_overflow = 0;

        op_a = adder3_sum;
        op_b = mult_res_ext;

        op_a[2*int_width_result - 1:lower_range] = {(2*int_width_result - lower_range){op_a[lower_range - 1] & (signa_wire | signb_wire)}};
        op_b[2*int_width_result - 1:lower_range] = {(2*int_width_result - lower_range){op_b[lower_range - 1] & (signa_wire | signb_wire)}};

        temp_sub = op_a - op_b ;
        if(temp_sub[2*int_width_result - 1] == 1)
        begin
            unsigned_sub3_overflow = 1'b1;
        end
        do_sub3_level1 = temp_sub;
    end
    endfunction

    function [2*int_width_result - 1:0] do_add3_level1;
        input [32:0] adder;
        input signa_wire;
        input signb_wire;
        begin:ADD3_LV1

        reg [2*int_width_result - 1 :0] temp_add;
        reg [2*int_width_result - 1 :0] op_a;
        reg [2*int_width_result - 1 :0] op_b;

        temp_add = 0;

        op_a = adder3_sum;
        op_b = mult_res_ext;

        op_a[2*int_width_result - 1:lower_range] = {(2*int_width_result - lower_range){op_a[lower_range - 1] & (signa_wire | signb_wire)}};
        op_b[2*int_width_result - 1:lower_range] = {(2*int_width_result - lower_range){op_b[lower_range - 1] & (signa_wire | signb_wire)}};

        temp_add = op_a + op_b;
        do_add3_level1 = temp_add;
    end
    endfunction

// -----------------------------------------------------------------------------
    // This block checks if the two numbers to be added (data_a/data_b) is to
    // be interpreted as a negative number or not. If so, then two's complement is
    // performed.
    // The 1st number subtracts the 2nd number. The sign of the result (positive or negative)
    // is determined based on the sign of the two input numbers
    // ------------------------------------------------------------------------------

    function [2*int_width_result - 1:0] do_preadder_sub;
        input [32:0] adder;
        input signa_wire;
        input signb_wire;
    begin:PREADDER_SUB

        reg [2*int_width_result - 1 :0] temp_sub;
        reg [2*int_width_result - 1 :0] op_a;
        reg [2*int_width_result - 1 :0] op_b;

        temp_sub = 0;

        op_a = mult_a_wire >> (adder * int_width_a);
   		op_b = mult_b_wire >> (adder * int_width_b);
        op_a[2*int_width_result - 1:width_a] = {(2*int_width_result - width_a){op_a[width_a - 1] & (signa_wire | signb_wire)}};
        op_b[2*int_width_result - 1:width_b] = {(2*int_width_result - width_b){op_b[width_b - 1] & (signa_wire | signb_wire)}};

        temp_sub = op_a - op_b;
	    do_preadder_sub = temp_sub;
    end
    endfunction

    function [2*int_width_result - 1:0] do_preadder_add;
        input [32:0] adder;
        input signa_wire;
        input signb_wire;
    begin:PREADDER_ADD

        reg [2*int_width_result - 1 :0] temp_add;
        reg [2*int_width_result - 1 :0] op_a;
        reg [2*int_width_result - 1 :0] op_b;

        temp_add = 0;

        op_a = mult_a_wire >> (adder * int_width_a);
   		op_b = mult_b_wire >> (adder * int_width_b);
        op_a[2*int_width_result - 1:width_a] = {(2*int_width_result - width_a){op_a[width_a - 1] & (signa_wire | signb_wire)}};
        op_b[2*int_width_result - 1:width_b] = {(2*int_width_result - width_b){op_b[width_b - 1] & (signa_wire | signb_wire)}};

        temp_add = op_a + op_b;
        do_preadder_add = temp_add;
    end
    endfunction

    // --------------------------------------------------------------
    // initialization block of all the internal signals and registers
    // --------------------------------------------------------------
    initial
    begin
	    //Legality check, block unsupported family from running pre_layout simulation using altera_mf (family with altera_mult_add flow)
		if(dev.FEATURE_FAMILY_IS_ALTMULT_ADD_EOL(intended_device_family) == 1)
		begin
				$display ("Error: ALTMULT_ADD is EOL for %s device family", intended_device_family);
				$display("Time: %0t  Instance: %m", $time);
				$stop;
		end

		//Legality check, block new family from running pre_layout simulation using altera_mf (family with altera_mult_add flow)
		if(dev.FEATURE_FAMILY_HAS_ALTERA_MULT_ADD_FLOW(intended_device_family) == 1)
		begin
			if(accumulator != "NO")
			begin
				$display ("Error: Accumulator mode is not supported in altera_mf for %s device family", intended_device_family);
				$display("Time: %0t  Instance: %m", $time);
				$stop;
			end

			if(port_addnsub1 != "PORT_UNUSED" || port_addnsub3 != "PORT_UNUSED")
			begin
				$display ("Error: Dynamic adder is not supported in altera_mf for %s device family", intended_device_family);
				$display("Time: %0t  Instance: %m", $time);
				$stop;
			end
			if(chainout_adder != "NO")
			begin
				$display ("Error: Chain adder is not supported in altera_mf for %s device family", intended_device_family);
				$display("Time: %0t  Instance: %m", $time);
				$stop;
			end
			if(systolic_delay1 != "UNREGISTERED" || systolic_delay3 != "UNREGISTERED")
			begin
				$display ("Error: Systolic mode is not supported in altera_mf for %s device family", intended_device_family);
				$display("Time: %0t  Instance: %m", $time);
				$stop;
			end
			if(input_source_a0 != "DATAA" || input_source_a1 != "DATAA" || input_source_a2 != "DATAA" || input_source_a3 != "DATAA")
			begin
				$display ("Error: INPUT_SOURCE_A is set to an unsupported value. Only DATAA input is supported in altera_mf for %s device family", intended_device_family);
				$display("Time: %0t  Instance: %m", $time);
				$stop;
			end
			if(input_source_b0 != "DATAB" || input_source_b1 != "DATAB" || input_source_b2 != "DATAB" || input_source_b3 != "DATAB")
			begin
				$display ("Error: INPUT_SOURCE_B is set to an unsupported value. Only DATAB input is supported in altera_mf for %s device family", intended_device_family);
				$display("Time: %0t  Instance: %m", $time);
				$stop;
			end
			if(preadder_mode != "SIMPLE")
			begin
				$display ("Error: PREADDER_MODE is set to an unsupported value. Only SIMPLE mode is supported in altera_mf for %s device family", intended_device_family);
				$display("Time: %0t  Instance: %m", $time);
				$stop;
			end
			if(output_rounding != "NO" || chainout_rounding != "NO" ||
			   adder1_rounding != "NO" || adder3_rounding != "NO" ||
			   multiplier01_rounding != "NO" || multiplier23_rounding != "NO")
			begin
				$display ("Error: Rounding is not supported in altera_mf for %s device family", intended_device_family);
				$display("Time: %0t  Instance: %m", $time);
				$stop;
			end
			if(output_saturation != "NO" || chainout_saturation != "NO" ||
			   port_mult0_is_saturated != "UNUSED" || port_mult1_is_saturated != "UNUSED" || port_mult2_is_saturated != "UNUSED" || port_mult3_is_saturated != "UNUSED" ||
			   multiplier01_saturation != "NO" || multiplier23_saturation != "NO" ||
			   port_output_is_overflow != "PORT_UNUSED")
			begin
				$display ("Error: Saturation is not supported in altera_mf for %s device family", intended_device_family);
				$display("Time: %0t  Instance: %m", $time);
				$stop;
			end
			if(shift_mode != "NO")
			begin
				$display ("Error: Shift is not supported in altera_mf for %s device family", intended_device_family);
				$display("Time: %0t  Instance: %m", $time);
				$stop;
			end
			if(signed_pipeline_register_a != "UNREGISTERED" || signed_pipeline_register_b!= "UNREGISTERED" ||
				addnsub_multiplier_pipeline_register1 != "UNREGISTERED" || addnsub_multiplier_pipeline_register3 != "UNREGISTERED" ||
				accum_sload_pipeline_register != "UNREGISTERED")
			begin
				$display ("Warning: Pipeline register is not supported in altera_mf for %s device family", intended_device_family);
				$display("Time: %0t  Instance: %m", $time);
			end
		end

        // Checking for invalid parameters, in case Wizard is bypassed (hand-modified).
        if (number_of_multipliers > 4)
        begin
            $display("Altmult_add does not currently support NUMBER_OF_MULTIPLIERS > 4");
            $stop;
        end
        if (number_of_multipliers <= 0)
        begin
            $display("NUMBER_OF_MULTIPLIERS must be greater than 0.");
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
		if (width_c < 0)
        begin
            $display("Error: width_c must be greater than 0.");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end
        if (width_result <= 0)
        begin
            $display("Error: width_result must be greater than 0.");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((input_source_a0 != "DATAA") &&
            (input_source_a0 != "SCANA") &&
            (input_source_a0 != "PREADDER") &&
            (input_source_a0 != "VARIABLE"))
        begin
            $display("Error: The INPUT_SOURCE_A0 parameter is set to an illegal value.");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((input_source_a1 != "DATAA") &&
            (input_source_a1 != "SCANA") &&
            (input_source_a1 != "PREADDER") &&
            (input_source_a1 != "VARIABLE"))
        begin
            $display("Error: The INPUT_SOURCE_A1 parameter is set to an illegal value.");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((input_source_a2 != "DATAA") &&
            (input_source_a2 != "SCANA") &&
            (input_source_a2 != "PREADDER") &&
            (input_source_a2 != "VARIABLE"))
        begin
            $display("Error: The INPUT_SOURCE_A2 parameter is set to an illegal value.");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((input_source_a3 != "DATAA") &&
            (input_source_a3 != "SCANA") &&
            (input_source_a3 != "PREADDER") &&
            (input_source_a3 != "VARIABLE"))
        begin
            $display("Error: The INPUT_SOURCE_A3 parameter is set to an illegal value.");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((input_source_b0 != "DATAB") &&
            (input_source_b0 != "SCANB") &&
            (input_source_b0 != "PREADDER") &&
            (input_source_b0 != "DATAC") &&
            (input_source_b0 != "VARIABLE") && (input_source_b0 != "LOOPBACK"))
        begin
            $display("Error: The INPUT_SOURCE_B0 parameter is set to an illegal value.");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((input_source_b1 != "DATAB") &&
            (input_source_b1 != "SCANB") &&
            (input_source_b1 != "PREADDER") &&
            (input_source_b1 != "VARIABLE"))
        begin
            $display("Error: The INPUT_SOURCE_B1 parameter is set to an illegal value.");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((input_source_b2 != "DATAB") &&
            (input_source_b2 != "SCANB") &&
            (input_source_b2 != "PREADDER") &&
            (input_source_b2 != "DATAC") &&
            (input_source_b2 != "VARIABLE"))
        begin
            $display("Error: The INPUT_SOURCE_B2 parameter is set to an illegal value.");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((input_source_b3 != "DATAB") &&
            (input_source_b3 != "SCANB") &&
            (input_source_b3 != "PREADDER") &&
            (input_source_b3 != "VARIABLE"))
        begin
            $display("Error: The INPUT_SOURCE_B3 parameter is set to an illegal value.");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((dev.FEATURE_FAMILY_BASE_STRATIXII(intended_device_family) == 0) && (dev.FEATURE_FAMILY_CYCLONEII(intended_device_family) == 0) &&
            (input_source_a0 == "VARIABLE"))
        begin
            $display("Error: Input source as VARIABLE is not supported in %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((dev.FEATURE_FAMILY_BASE_STRATIXII(intended_device_family) == 0) && (dev.FEATURE_FAMILY_CYCLONEII(intended_device_family) == 0) &&
            (input_source_a1 == "VARIABLE"))
        begin
            $display("Error: Input source as VARIABLE is not supported in %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((dev.FEATURE_FAMILY_BASE_STRATIXII(intended_device_family) == 0) && (dev.FEATURE_FAMILY_CYCLONEII(intended_device_family) == 0) &&
            (input_source_a2 == "VARIABLE"))
        begin
            $display("Error: Input source as VARIABLE is not supported in %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((dev.FEATURE_FAMILY_BASE_STRATIXII(intended_device_family) == 0) && (dev.FEATURE_FAMILY_CYCLONEII(intended_device_family) == 0) &&
            (input_source_a3 == "VARIABLE"))
        begin
            $display("Error: Input source as VARIABLE is not supported in %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((dev.FEATURE_FAMILY_BASE_STRATIXII(intended_device_family) == 0) && (dev.FEATURE_FAMILY_CYCLONEII(intended_device_family) == 0) &&
            (input_source_b0 == "VARIABLE"))
        begin
            $display("Error: Input source as VARIABLE is not supported in %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((dev.FEATURE_FAMILY_BASE_STRATIXII(intended_device_family) == 0) && (dev.FEATURE_FAMILY_CYCLONEII(intended_device_family) == 0) &&
            (input_source_b1 == "VARIABLE"))
        begin
            $display("Error: Input source as VARIABLE is not supported in %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((dev.FEATURE_FAMILY_BASE_STRATIXII(intended_device_family) == 0) && (dev.FEATURE_FAMILY_CYCLONEII(intended_device_family) == 0) &&
            (input_source_b2 == "VARIABLE"))
        begin
            $display("Error: Input source as VARIABLE is not supported in %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((dev.FEATURE_FAMILY_BASE_STRATIXII(intended_device_family) == 0) && (dev.FEATURE_FAMILY_CYCLONEII(intended_device_family) == 0) &&
            (input_source_b3 == "VARIABLE"))
        begin
            $display("Error: Input source as VARIABLE is not supported in %s device family", intended_device_family);
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

        if ((dev.FEATURE_FAMILY_BASE_STRATIXII(intended_device_family) == 0) &&
            ((multiplier01_rounding == "YES") || (multiplier23_rounding == "YES") ||
            (multiplier01_rounding == "VARIABLE") || (multiplier23_rounding == "VARIABLE")))
        begin
            $display("Error: Rounding for multiplier is not supported in %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((dev.FEATURE_FAMILY_BASE_STRATIXII(intended_device_family) == 0) &&
            ((adder1_rounding == "YES") || (adder3_rounding == "YES") ||
            (adder1_rounding == "VARIABLE") || (adder3_rounding == "VARIABLE")))
        begin
            $display("Error: Rounding for adder is not supported in %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((dev.FEATURE_FAMILY_BASE_STRATIXII(intended_device_family) == 0) &&
            ((multiplier01_saturation == "YES") || (multiplier23_saturation == "YES") ||
            (multiplier01_saturation == "VARIABLE") || (multiplier23_saturation == "VARIABLE")))
        begin
            $display("Error: Saturation for multiplier is not supported in %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((multiplier01_saturation == "NO") && (multiplier23_saturation == "NO") &&
            (multiplier01_rounding == "NO") && (multiplier23_rounding == "NO")
            && (output_saturation == "NO") && (output_rounding == "NO") && (chainout_rounding == "NO")
            && (chainout_saturation == "NO") && (chainout_adder =="NO") && (shift_mode == "NO"))
        begin
            if (int_width_result != width_result)
            begin
                $display ("Error: Internal parameter setting of int_width_result is illegal");
                $display("Time: %0t  Instance: %m", $time);
                $stop;
            end

            if (int_mult_diff_bit != 0)
            begin
                $display ("Error: Internal parameter setting of int_mult_diff_bit is illegal");
                $display("Time: %0t  Instance: %m", $time);
                $stop;
            end

        end
        else
        begin
            if (((width_a < 18) && (int_width_a != 18)) ||
                ((width_a >= 18) && (int_width_a != width_a)))
            begin
                $display ("Error: Internal parameter setting of int_width_a is illegal");
                $display("Time: %0t  Instance: %m", $time);
                $stop;
            end


            if (((width_b < 18) && (int_width_b != 18)) ||
                ((width_b >= 18) && (int_width_b != width_b)))
            begin
                $display ("Error: Internal parameter setting of int_width_b is illegal");
                $display("Time: %0t  Instance: %m", $time);
                $stop;
            end

            if ((chainout_adder == "NO") && (shift_mode == "NO"))
            begin
                if ((int_width_result > (int_width_a + int_width_b)))
                begin
                    if (int_width_result != (width_result + width_result - int_width_a - int_width_b))
                    begin
                        $display ("Error: Internal parameter setting for int_width_result is illegal");
                        $display("Time: %0t  Instance: %m", $time);
                        $stop;
                    end
                end
                else
                    if ((int_width_result != (int_width_a + int_width_b)))
                    begin
                        $display ("Error: Internal parameter setting for int_width_result is illegal");
                        $display("Time: %0t  Instance: %m", $time);
                        $stop;
                    end

                if ((int_mult_diff_bit != (int_width_a - width_a + int_width_b - width_b)))
                begin
                    $display ("Error: Internal parameter setting of int_mult_diff_bit is illegal");
                    $display("Time: %0t  Instance: %m", $time);
                    $stop;
                end
            end
        end

        // Stratix III parameters checking
        if ((dev.FEATURE_FAMILY_STRATIXIII(intended_device_family) == 0) && ((output_rounding == "YES") ||
            (output_rounding == "VARIABLE") || (chainout_rounding == "YES") || (chainout_rounding == "VARIABLE")))
        begin
            $display ("Error: Output rounding and/or Chainout rounding are not supported for %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((dev.FEATURE_FAMILY_STRATIXIII(intended_device_family) == 0) && ((output_saturation == "YES") ||
            (output_saturation == "VARIABLE") || (chainout_saturation == "YES") || (chainout_saturation == "VARIABLE")))
        begin
            $display ("Error: Output saturation and/or Chainout saturation are not supported for %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((dev.FEATURE_FAMILY_STRATIXIII(intended_device_family) == 0) && (input_source_b0 == "LOOPBACK"))
        begin
            $display ("Error: Loopback mode is not supported for %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((dev.FEATURE_FAMILY_STRATIXIII(intended_device_family) == 0) && (chainout_adder == "YES"))
        begin
            $display("Error: Chainout mode is not supported for %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((dev.FEATURE_FAMILY_STRATIXIII(intended_device_family) == 0) && (shift_mode != "NO"))
        begin
            $display ("Error: shift and rotate modes are not supported for %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((dev.FEATURE_FAMILY_STRATIXIII(intended_device_family) == 0) && (accumulator == "YES"))
        begin
            $display ("Error: Accumulator mode is not supported for %s device family", intended_device_family);
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((output_rounding != "YES") && (output_rounding != "NO") && (output_rounding != "VARIABLE"))
        begin
            $display ("Error: The OUTPUT_ROUNDING parameter is set to an invalid value");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((chainout_rounding != "YES") && (chainout_rounding != "NO") && (chainout_rounding != "VARIABLE"))
        begin
            $display ("Error: The CHAINOUT_ROUNDING parameter is set to an invalid value");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((output_saturation != "YES") && (output_saturation != "NO") && (output_saturation != "VARIABLE"))
        begin
            $display ("Error: The OUTPUT_SATURATION parameter is set to an invalid value");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((chainout_saturation != "YES") && (chainout_saturation != "NO") && (chainout_saturation != "VARIABLE"))
        begin
            $display ("Error: The CHAINOUT_SATURATION parameter is set to an invalid value");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((output_rounding != "NO") && ((output_round_type != "NEAREST_INTEGER") && (output_round_type != "NEAREST_EVEN")))
        begin
            $display ("Error: The OUTPUT_ROUND_TYPE parameter is set to an invalid value");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((output_saturation != "NO") && ((output_saturate_type != "ASYMMETRIC") && (output_saturate_type != "SYMMETRIC")))
        begin
            $display ("Error: The OUTPUT_SATURATE_TYPE parameter is set to an invalid value");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if ((shift_mode != "NO") && (shift_mode != "LEFT") && (shift_mode != "RIGHT") && (shift_mode != "ROTATION") &&
            (shift_mode != "VARIABLE"))
        begin
            $display ("Error: The SHIFT_MODE parameter is set to an invalid value");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if (accumulator == "YES")
        begin
            if ((accum_direction != "ADD") && (accum_direction != "SUB"))
            begin
                $display ("Error: The ACCUM_DIRECTION parameter is set to an invalid value");
                $display("Time: %0t  Instance: %m", $time);
                $stop;
            end
        end

        if (dev.FEATURE_FAMILY_STRATIXIII(intended_device_family) == 1)
        begin
            if ((output_rounding == "YES") && (accumulator == "YES"))
            begin
                $display ("Error: In accumulator mode, the OUTPUT_ROUNDING parameter has to be set to VARIABLE if used");
                $display("Time: %0t  Instance: %m", $time);
                $stop;
            end

            if ((chainout_adder == "YES") && (output_rounding != "NO"))
            begin
                $display ("Error: In chainout mode, output rounding cannot be turned on");
                $display("Time: %0t  Instance: %m", $time);
                $stop;
            end
        end


        temp_sum_reg = 0;
        mult_a_reg = 0;
        mult_b_reg   = 0;
        mult_c_reg   = 0;
        mult_res_reg = 0;

        sign_a_reg  =   ((port_signa == "PORT_CONNECTIVITY")?
                        (representation_a != "UNUSED" ? (representation_a == "SIGNED" ? 1 : 0) : 0) :
                        (port_signa == "PORT_USED")? 0 :
                        (port_signa == "PORT_UNUSED")? (representation_a == "SIGNED" ? 1 : 0) : 0);

        sign_a_pipe_reg =   ((port_signa == "PORT_CONNECTIVITY")?
                            (representation_a != "UNUSED" ? (representation_a == "SIGNED" ? 1 : 0) : 0) :
                            (port_signa == "PORT_USED")? 0 :
                            (port_signa == "PORT_UNUSED")? (representation_a == "SIGNED" ? 1 : 0) : 0);

        sign_b_reg  =   ((port_signb == "PORT_CONNECTIVITY")?
                        (representation_b != "UNUSED" ? (representation_b == "SIGNED" ? 1 : 0) : 0) :
                        (port_signb == "PORT_USED")? 0 :
                        (port_signb == "PORT_UNUSED")? (representation_b == "SIGNED" ? 1 : 0) : 0);

        sign_b_pipe_reg =   ((port_signb == "PORT_CONNECTIVITY")?
                            (representation_b != "UNUSED" ? (representation_b == "SIGNED" ? 1 : 0) : 0) :
                            (port_signb == "PORT_USED")? 0 :
                            (port_signb == "PORT_UNUSED")? (representation_b == "SIGNED" ? 1 : 0) : 0);

        addsub1_reg  =  ((port_addnsub1 == "PORT_CONNECTIVITY")?
                        (multiplier1_direction != "UNUSED" ? (multiplier1_direction == "ADD" ? 1 : 0) : 0) :
                        (port_addnsub1 == "PORT_USED")? 0 :
                        (port_addnsub1 == "PORT_UNUSED")? (multiplier1_direction == "ADD" ? 1 : 0) : 0);

        addsub1_pipe_reg = addsub1_reg;

        addsub3_reg  =  ((port_addnsub3 == "PORT_CONNECTIVITY")?
                        (multiplier3_direction != "UNUSED" ? (multiplier3_direction == "ADD" ? 1 : 0) : 0) :
                        (port_addnsub3 == "PORT_USED")? 0 :
                        (port_addnsub3 == "PORT_UNUSED")? (multiplier3_direction == "ADD" ? 1 : 0) : 0);

        addsub3_pipe_reg = addsub3_reg;

        // StratixII related reg type initialization

        mult0_round_out = 0;
        mult0_saturate_out = 0;
        mult0_result = 0;
        mult0_saturate_overflow = 0;

        mult1_round_out = 0;
        mult1_saturate_out = 0;
        mult1_result = 0;
        mult1_saturate_overflow = 0;

        mult_saturate_overflow_reg [3] = 0;
        mult_saturate_overflow_reg [2] = 0;
        mult_saturate_overflow_reg [1] = 0;
        mult_saturate_overflow_reg [0] = 0;

        mult_saturate_overflow_pipe_reg [3] = 0;
        mult_saturate_overflow_pipe_reg [2] = 0;
        mult_saturate_overflow_pipe_reg [1] = 0;
        mult_saturate_overflow_pipe_reg [0] = 0;
        head_result = 0;

        // Stratix III reg type initialization
        chainout_overflow_status = 0;
        overflow_status = 0;
        outround_reg = 0;
        outround_pipe_reg = 0;
        chainout_round_reg = 0;
        chainout_round_pipe_reg = 0;
        chainout_round_out_reg = 0;
        outsat_reg = 0;
        outsat_pipe_reg = 0;
        chainout_sat_reg = 0;
        chainout_sat_pipe_reg = 0;
        chainout_sat_out_reg = 0;
        zerochainout_reg = 0;
        rotate_reg = 0;
        rotate_pipe_reg = 0;
        rotate_out_reg = 0;
        shiftr_reg = 0;
        shiftr_pipe_reg = 0;
        shiftr_out_reg = 0;
        zeroloopback_reg = 0;
        zeroloopback_pipe_reg = 0;
        zeroloopback_out_reg = 0;
        accumsload_reg = 0;
        accumsload_pipe_reg = 0;

        scanouta_reg = 0;
        adder1_reg = 0;
        adder3_reg = 0;
        adder1_sum = 0;
        adder3_sum = 0;
        adder1_res_ext = 0;
        adder3_res_ext = 0;
        round_block_result = 0;
        sat_block_result = 0;
        round_sat_blk_res = 0;
        chainout_round_block_result = 0;
        chainout_sat_block_result = 0;
        round_sat_in_result = 0;
        chainout_rnd_sat_blk_res = 0;
        chainout_output_reg = 0;
        chainout_final_out = 0;
        shift_rot_result = 0;
        acc_feedback_reg = 0;
        chout_shftrot_reg = 0;

        overflow_status = 0;
        overflow_stat_reg = 0;
        chainout_overflow_status = 0;
        chainout_overflow_stat_reg = 0;
        stick_bits_or = 0;
        cho_stick_bits_or = 0;
        accum_overflow = 0;
        accum_overflow_reg = 0;
        unsigned_sub1_overflow = 0;
        unsigned_sub3_overflow = 0;
        unsigned_sub1_overflow_reg = 0;
        unsigned_sub3_overflow_reg = 0;
        unsigned_sub1_overflow_mult_reg = 0;
        unsigned_sub3_overflow_mult_reg = 0;

        preadder_sum1a = 0;
        preadder_sum2a = 0;
        preadder_res_0 = 0;
        preadder_res_1 = 0;
        preadder_res_2 = 0;
        preadder_res_3 = 0;
        coeffsel_a_reg = 0;
        coeffsel_b_reg = 0;
        coeffsel_c_reg = 0;
        coeffsel_d_reg = 0;
        adder1_res_reg_0 = 0;
        adder1_res_reg_1 = 0;
		round_sat_in_reg = 0;
		chainin_reg = 0;

        for ( num_stor = extra_latency; num_stor >= 0; num_stor = num_stor - 1 )
        begin
            result_pipe[num_stor] = {int_width_result{1'b0}};
            result_pipe1[num_stor] = {int_width_result{1'b0}};
            overflow_stat_pipe_reg = 1'b0;
            unsigned_sub1_overflow_pipe_reg <= 1'b0;
            unsigned_sub3_overflow_pipe_reg <= 1'b0;
            accum_overflow_stat_pipe_reg = 1'b0;
        end

        for (lpbck_cnt = 0; lpbck_cnt <= int_width_result; lpbck_cnt = lpbck_cnt+1)
        begin
            loopback_wire_reg[lpbck_cnt] = 1'b0;
        end

    end // end initialization block

    assign stratixii_block = dev.FEATURE_FAMILY_BASE_STRATIXII(intended_device_family) || (stratixiii_block && (dedicated_multiplier_circuitry=="NO"));
    assign stratixiii_block = dev.FEATURE_FAMILY_STRATIXIII(intended_device_family) && (dedicated_multiplier_circuitry!="NO");

	//SPR 356362: Force stratixv_block to false as StratixV does not support simulation atom
    assign stratixv_block = dev.FEATURE_FAMILY_STRATIXV(intended_device_family) && (dedicated_multiplier_circuitry!="NO") && 1'b0;

    assign altera_mult_add_block = dev.FEATURE_FAMILY_HAS_ALTERA_MULT_ADD_FLOW(intended_device_family);

    assign signa_z = signa;
    assign signb_z = signb;
    assign addnsub1_z = addnsub1;
    assign addnsub3_z = addnsub3;
    assign scanina_z[width_a - 1 : 0] = scanina[width_a - 1 : 0];
    assign scaninb_z[width_b - 1 : 0] = scaninb[width_b - 1 : 0];

    always @(dataa or datab)
    begin
        dataa_reg[(number_of_multipliers * width_a) - 1:0] = dataa[(number_of_multipliers* width_a) -1:0];
        datab_reg[(number_of_multipliers * width_b) - 1:0] = datab[(number_of_multipliers * width_b) - 1:0];
    end

    assign new_dataa_int[int_width_a - 1:int_width_a - width_a] = (number_of_multipliers >= 1) ?
                                                                    dataa_reg[width_a - 1:0]: {width_a{1'b0}};

    assign chainout_new_dataa_temp =  ((sign_a_int == 1) ?
                                        {{(chainout_input_a) {dataa_reg[width_a - 1]}}, dataa_reg[width_a - 1:0]} :
                                        {{(chainout_input_a) {1'b0}}, dataa_reg[width_a - 1:0]});

    assign chainout_new_dataa_int[int_width_a -1:0] = ((chainout_adder == "YES") && stratixiii_block == 1) ?
                                                        (((number_of_multipliers >= 1) && (width_result > width_a + width_b + 8) && (width_a < 18)) ?
                                                        chainout_new_dataa_temp[int_width_a - 1 : 0] :
                                                        {int_width_a{1'b0}}) : {int_width_a{1'b0}};

    assign new_dataa_int[(2 * int_width_a) - 1: (2 * int_width_a) - width_a] = (number_of_multipliers >= 2)?
                                                                                dataa_reg[(2 * width_a) - 1: width_a] : {width_a{1'b0}};

    assign chainout_new_dataa_temp2 = ((sign_a_int == 1) ?
                                    {{(chainout_input_a) {dataa_reg[(2*width_a) - 1]}}, dataa_reg[(2*width_a) - 1:width_a]} :
                                    {{(chainout_input_a) {1'b0}}, dataa_reg[(2*width_a) - 1:width_a]});

    assign chainout_new_dataa_int[(2 *int_width_a) - 1: int_width_a] = ((chainout_adder == "YES") && stratixiii_block == 1) ?
                                                                        (((number_of_multipliers >= 2) && (width_result > width_a + width_b + 8) && (width_a < 18)) ?
                                                                        chainout_new_dataa_temp2[int_width_a - 1 : 0] :
                                                                        {int_width_a{1'b0}}) : {int_width_a{1'b0}};

    assign new_dataa_int[(3 * int_width_a) - 1: (3 * int_width_a) - width_a] = (number_of_multipliers >= 3)?
                                                                                dataa_reg[(3 * width_a) - 1:(2 * width_a)] : {width_a{1'b0}};

    assign chainout_new_dataa_temp3 = ((sign_a_int == 1) ?
                                        {{(chainout_input_a) {dataa_reg[(3*width_a) - 1]}}, dataa_reg[(3*width_a) - 1:(2*width_a)]} :
                                        {{(chainout_input_a) {1'b0}}, dataa_reg[(3*width_a) - 1:(2*width_a)]});

    assign chainout_new_dataa_int[(3 *int_width_a) - 1: (2*int_width_a)] = ((chainout_adder == "YES") && stratixiii_block == 1) ?
                                                                            (((number_of_multipliers >= 3) && (width_result > width_a + width_b + 8) && (width_a < 18)) ?
                                                                            chainout_new_dataa_temp3[int_width_a - 1 : 0]:
                                                                            {int_width_a{1'b0}}) : {int_width_a{1'b0}};

    assign new_dataa_int[(4 * int_width_a) - 1: (4 * int_width_a) - width_a] = (number_of_multipliers >= 4) ?
                                                                                dataa_reg[(4 * width_a) - 1:(3 * width_a)] : {width_a{1'b0}};

    assign chainout_new_dataa_temp4 = ((sign_a_int == 1) ?
                                    {{(chainout_input_a) {dataa_reg[(4*width_a) - 1]}}, dataa_reg[(4*width_a) - 1:(3*width_a)]} :
                                    {{(chainout_input_a) {1'b0}}, dataa_reg[(4*width_a) - 1:(3*width_a)]});

    assign chainout_new_dataa_int[(4 *int_width_a) - 1: (3*int_width_a)] = ((chainout_adder == "YES") && stratixiii_block == 1) ?
                                                                            (((number_of_multipliers >= 4) && (width_result > width_a + width_b + 8) && (width_a < 18)) ?
                                                                            chainout_new_dataa_temp4[int_width_a - 1 : 0]:
                                                                            {int_width_a{1'b0}}) : {int_width_a{1'b0}};

    assign new_datab_int[int_width_b - 1:int_width_b - width_b] = (number_of_multipliers >= 1) ?
                                                                    datab_reg[width_b - 1:0]: {width_b{1'b0}};

    assign chainout_new_datab_temp = ((sign_b_int == 1) ?
                                    {{(chainout_input_b) {datab_reg[width_b - 1]}}, datab_reg[width_b - 1:0]} :
                                    {{(chainout_input_b) {1'b0}}, datab_reg[width_b - 1:0]});

    assign chainout_new_datab_int[int_width_b -1:0] = ((chainout_adder == "YES") && stratixiii_block == 1) ?
                                                        (((number_of_multipliers >= 1) && (width_result > width_a + width_b + 8) && (width_b < 18)) ?
                                                        chainout_new_datab_temp[int_width_b -1:0]:
                                                        {int_width_b{1'b0}}) : {int_width_b{1'b0}};

    assign new_datab_int[(2 * int_width_b) - 1: (2 * int_width_b) - width_b] = (number_of_multipliers >= 2)?
                                                                                datab_reg[(2 * width_b) - 1:width_b]:{width_b{1'b0}};

    assign chainout_new_datab_temp2 = ((sign_b_int == 1) ?
                                    {{(chainout_input_b) {datab_reg[(2*width_b) - 1]}}, datab_reg[(2*width_b) - 1:width_b]} :
                                    {{(chainout_input_b) {1'b0}}, datab_reg[(2*width_b) - 1:width_b]});

    assign chainout_new_datab_int[(2*int_width_b) -1:int_width_b] = ((chainout_adder == "YES") && stratixiii_block == 1) ?
                                                                        (((number_of_multipliers >= 2) && (width_result > width_a + width_b + 8) && (width_b < 18)) ?
                                                                        chainout_new_datab_temp2[int_width_b -1:0]:
                                                                        {int_width_b{1'b0}}) : {int_width_b{1'b0}};

    assign new_datab_int[(3 * int_width_b) - 1: (3 * int_width_b) - width_b] = (number_of_multipliers >= 3)?
                                                                                datab_reg[(3 * width_b) - 1:(2 * width_b)] : {width_b{1'b0}};

    assign chainout_new_datab_temp3 = ((sign_b_int == 1) ?
                                    {{(chainout_input_b) {datab_reg[(3*width_b) - 1]}}, datab_reg[(3*width_b) - 1:(2*width_b)]} :
                                    {{(chainout_input_b) {1'b0}}, datab_reg[(3*width_b) - 1:(2*width_b)]});

    assign chainout_new_datab_int[(3*int_width_b) -1:(2*int_width_b)] = ((chainout_adder == "YES") && stratixiii_block == 1) ?
                                                                        (((number_of_multipliers >= 3) && (width_result > width_a + width_b + 8) && (width_b < 18)) ?
                                                                        chainout_new_datab_temp3[int_width_b -1:0]:
                                                                        {int_width_b{1'b0}}) : {int_width_b{1'b0}};

    assign new_datab_int[(4 * int_width_b) - 1: (4 * int_width_b) - width_b] = (number_of_multipliers >= 4) ?
                                                                                datab_reg[(4 * width_b) - 1:(3 * width_b)] : {width_b{1'b0}};

    assign chainout_new_datab_temp4 = ((sign_b_int == 1) ?
                                    {{(chainout_input_b) {datab_reg[(4*width_b) - 1]}}, datab_reg[(4*width_b) - 1:(3*width_b)]} :
                                    {{(chainout_input_b) {1'b0}}, datab_reg[(4*width_b) - 1:(3*width_b)]});

    assign chainout_new_datab_int[(4*int_width_b) -1:(3*int_width_b)] = ((chainout_adder == "YES") && stratixiii_block == 1) ?
                                                                        (((number_of_multipliers >= 4) && (width_result > width_a + width_b + 8) && (width_b < 18)) ?
                                                                        chainout_new_datab_temp4[int_width_b -1:0]:
                                                                        {int_width_b{1'b0}}) : {int_width_b{1'b0}};

    assign dataa_int[number_of_multipliers * int_width_a-1:0] = (((multiplier01_saturation == "NO") && (multiplier23_saturation == "NO") &&
                                                                (multiplier01_rounding == "NO") && (multiplier23_rounding == "NO") &&
                                                                (output_rounding == "NO") && (output_saturation == "NO") &&
                                                                (chainout_rounding == "NO") && (chainout_saturation == "NO") && (chainout_adder == "NO") && (input_source_b0 != "LOOPBACK"))?
                                                                dataa[number_of_multipliers * width_a - 1:0]:
                                                                ((width_a < 18) ?
                                                                (((chainout_adder == "YES") && (width_result > width_a + width_b + 8)) ?
                                                                chainout_new_dataa_int[number_of_multipliers * int_width_a-1:0] :
                                                                new_dataa_int[number_of_multipliers * int_width_a-1:0]) : dataa[number_of_multipliers * width_a - 1:0]));

    assign datab_int[number_of_multipliers * int_width_b-1:0] = (((multiplier01_saturation == "NO") && (multiplier23_saturation == "NO") &&
                                                                (multiplier01_rounding == "NO") && (multiplier23_rounding == "NO") &&
                                                                (output_rounding == "NO") && (output_saturation == "NO") &&
                                                                (chainout_rounding == "NO") && (chainout_saturation == "NO") && (chainout_adder == "NO") && (input_source_b0 != "LOOPBACK"))?
                                                                datab[number_of_multipliers * width_b - 1:0]:
                                                                ((width_b < 18)?
                                                                (((chainout_adder == "YES") && (width_result > width_a + width_b + 8)) ?
                                                                chainout_new_datab_int[number_of_multipliers * int_width_b-1:0] :
                                                                new_datab_int[number_of_multipliers * int_width_b - 1:0]) : datab[number_of_multipliers * width_b - 1:0]));

	assign datac_int[int_width_c-1:0] = ((stratixv_block == 1 && (preadder_mode == "INPUT"))? datac[int_width_c - 1:0]: 0);

    assign addnsub1_round_pre = addnsub1_round;
    assign addnsub3_round_pre = addnsub3_round;
    assign mult01_round_pre = mult01_round;
    assign mult01_saturate_pre = mult01_saturation;
    assign mult23_round_pre = mult23_round;
    assign mult23_saturate_pre = mult23_saturation;

    // ---------------------------------------------------------
    // This block updates the output port for each multiplier's
    // saturation port only if port_mult0_is_saturated is set to used
    // ---------------------------------------------------------


    assign mult0_is_saturated = (port_mult0_is_saturated == "UNUSED")? 1'b0 /* converted x or z to 1'b0 */:
                                (port_mult0_is_saturated == "USED")? mult_is_saturate_vec[0]: 1'b0 /* converted x or z to 1'b0 */;

    assign mult1_is_saturated = (port_mult1_is_saturated == "UNUSED")? 1'b0 /* converted x or z to 1'b0 */:
                                (port_mult1_is_saturated == "USED")? mult_is_saturate_vec[1]: 1'b0 /* converted x or z to 1'b0 */;

    assign mult2_is_saturated = (port_mult2_is_saturated == "UNUSED")? 1'b0 /* converted x or z to 1'b0 */:
                                (port_mult2_is_saturated == "USED")? mult_is_saturate_vec[2]: 1'b0 /* converted x or z to 1'b0 */;

    assign mult3_is_saturated = (port_mult3_is_saturated == "UNUSED")? 1'b0 /* converted x or z to 1'b0 */:
                                (port_mult3_is_saturated == "USED")? mult_is_saturate_vec[3]: 1'b0 /* converted x or z to 1'b0 */;

    assign sourcea_wire[number_of_multipliers - 1 : 0] = sourcea[number_of_multipliers - 1 : 0];

    assign sourceb_wire[number_of_multipliers - 1 : 0] = sourceb[number_of_multipliers - 1 : 0];


    // ---------------------------------------------------------
    // This block updates the internal clock signals accordingly
    // every time the global clock signal changes state
    // ---------------------------------------------------------

    assign input_reg_a0_wire_clk =  (input_register_a0 == "CLOCK0")? clock0:
                                    (input_register_a0 == "UNREGISTERED")? 1'b0:
                                    (input_register_a0 == "CLOCK1")? clock1:
                                    (input_register_a0 == "CLOCK2")? clock2:
                                    (input_register_a0 == "CLOCK3")? clock3: 1'b0;


    assign input_reg_a1_wire_clk =  (input_register_a1 == "CLOCK0")? clock0:
                                    (input_register_a1 == "UNREGISTERED")? 1'b0:
                                    (input_register_a1 == "CLOCK1")? clock1:
                                    (input_register_a1 == "CLOCK2")? clock2:
                                    (input_register_a1 == "CLOCK3")? clock3: 1'b0;


    assign input_reg_a2_wire_clk =  (input_register_a2 == "CLOCK0")? clock0:
                                    (input_register_a2 == "UNREGISTERED")? 1'b0:
                                    (input_register_a2 == "CLOCK1")? clock1:
                                    (input_register_a2 == "CLOCK2")? clock2:
                                    (input_register_a2 == "CLOCK3")? clock3: 1'b0;



    assign input_reg_a3_wire_clk =  (input_register_a3 == "CLOCK0")? clock0:
                                    (input_register_a3 == "UNREGISTERED")? 1'b0:
                                    (input_register_a3 == "CLOCK1")? clock1:
                                    (input_register_a3 == "CLOCK2")? clock2:
                                    (input_register_a3 == "CLOCK3")? clock3: 1'b0;


    assign input_reg_b0_wire_clk =  (input_register_b0 == "CLOCK0")? clock0:
                                    (input_register_b0 == "UNREGISTERED")? 1'b0:
                                    (input_register_b0 == "CLOCK1")? clock1:
                                    (input_register_b0 == "CLOCK2")? clock2:
                                    (input_register_b0 == "CLOCK3")? clock3: 1'b0;


    assign input_reg_b1_wire_clk =  (input_register_b1 == "CLOCK0")? clock0:
                                    (input_register_b1 == "UNREGISTERED")? 1'b0:
                                    (input_register_b1 == "CLOCK1")? clock1:
                                    (input_register_b1 == "CLOCK2")? clock2:
                                    (input_register_b1 == "CLOCK3")? clock3: 1'b0;


    assign input_reg_b2_wire_clk =  (input_register_b2 == "CLOCK0")? clock0:
                                    (input_register_b2 == "UNREGISTERED")? 1'b0:
                                    (input_register_b2 == "CLOCK1")? clock1:
                                    (input_register_b2 == "CLOCK2")? clock2:
                                    (input_register_b2 == "CLOCK3")? clock3: 1'b0;


    assign input_reg_b3_wire_clk =  (input_register_b3 == "CLOCK0")? clock0:
                                    (input_register_b3 == "UNREGISTERED")? 1'b0:
                                    (input_register_b3 == "CLOCK1")? clock1:
                                    (input_register_b3 == "CLOCK2")? clock2:
                                    (input_register_b3 == "CLOCK3")? clock3: 1'b0;

	assign input_reg_c0_wire_clk =  (input_register_c0 == "CLOCK0")? clock0:
                                    (input_register_c0 == "UNREGISTERED")? 1'b0:
                                    (input_register_c0 == "CLOCK1")? clock1:
                                    (input_register_c0 == "CLOCK2")? clock2: 1'b0;


    assign input_reg_c1_wire_clk =  (input_register_c1 == "CLOCK0")? clock0:
                                    (input_register_c1 == "UNREGISTERED")? 1'b0:
                                    (input_register_c1 == "CLOCK1")? clock1:
                                    (input_register_c1 == "CLOCK2")? clock2: 1'b0;


    assign input_reg_c2_wire_clk =  (input_register_c2 == "CLOCK0")? clock0:
                                    (input_register_c2 == "UNREGISTERED")? 1'b0:
                                    (input_register_c2 == "CLOCK1")? clock1:
                                    (input_register_c2 == "CLOCK2")? clock2: 1'b0;


    assign input_reg_c3_wire_clk =  (input_register_c3 == "CLOCK0")? clock0:
                                    (input_register_c3 == "UNREGISTERED")? 1'b0:
                                    (input_register_c3 == "CLOCK1")? clock1:
                                    (input_register_c3 == "CLOCK2")? clock2: 1'b0;

    assign addsub1_reg_wire_clk =   (addnsub_multiplier_register1 == "CLOCK0")? clock0:
                                    (addnsub_multiplier_register1 == "UNREGISTERED")? 1'b0:
                                    (addnsub_multiplier_register1 == "CLOCK1")? clock1:
                                    (addnsub_multiplier_register1 == "CLOCK2")? clock2:
                                    (addnsub_multiplier_register1 == "CLOCK3")? clock3: 1'b0;


    assign addsub1_pipe_wire_clk =  (addnsub_multiplier_pipeline_register1 == "CLOCK0")? clock0:
                                    (addnsub_multiplier_pipeline_register1 == "UNREGISTERED")? 1'b0:
                                    (addnsub_multiplier_pipeline_register1 == "CLOCK1")? clock1:
                                    (addnsub_multiplier_pipeline_register1 == "CLOCK2")? clock2:
                                    (addnsub_multiplier_pipeline_register1 == "CLOCK3")? clock3: 1'b0;



    assign addsub3_reg_wire_clk =   (addnsub_multiplier_register3 == "CLOCK0")? clock0:
                                    (addnsub_multiplier_register3 == "UNREGISTERED")? 1'b0:
                                    (addnsub_multiplier_register3 == "CLOCK1")? clock1:
                                    (addnsub_multiplier_register3 == "CLOCK2")? clock2:
                                    (addnsub_multiplier_register3 == "CLOCK3")? clock3: 1'b0;



    assign addsub3_pipe_wire_clk =  (addnsub_multiplier_pipeline_register3 == "CLOCK0")? clock0:
                                    (addnsub_multiplier_pipeline_register3 == "UNREGISTERED")? 1'b0:
                                    (addnsub_multiplier_pipeline_register3 == "CLOCK1")? clock1:
                                    (addnsub_multiplier_pipeline_register3 == "CLOCK2")? clock2:
                                    (addnsub_multiplier_pipeline_register3 == "CLOCK3")? clock3: 1'b0;




    assign sign_reg_a_wire_clk =    (signed_register_a == "CLOCK0")? clock0:
                                    (signed_register_a == "UNREGISTERED")? 1'b0:
                                    (signed_register_a == "CLOCK1")? clock1:
                                    (signed_register_a == "CLOCK2")? clock2:
                                    (signed_register_a == "CLOCK3")? clock3: 1'b0;



    assign sign_pipe_a_wire_clk =   (signed_pipeline_register_a == "CLOCK0")? clock0:
                                    (signed_pipeline_register_a == "UNREGISTERED")? 1'b0:
                                    (signed_pipeline_register_a == "CLOCK1")? clock1:
                                    (signed_pipeline_register_a == "CLOCK2")? clock2:
                                    (signed_pipeline_register_a == "CLOCK3")? clock3: 1'b0;



    assign sign_reg_b_wire_clk =    (signed_register_b == "CLOCK0")? clock0:
                                    (signed_register_b == "UNREGISTERED")? 1'b0:
                                    (signed_register_b == "CLOCK1")? clock1:
                                    (signed_register_b == "CLOCK2")? clock2:
                                    (signed_register_b == "CLOCK3")? clock3: 1'b0;



    assign sign_pipe_b_wire_clk =   (signed_pipeline_register_b == "CLOCK0")? clock0:
                                    (signed_pipeline_register_b == "UNREGISTERED")? 1'b0:
                                    (signed_pipeline_register_b == "CLOCK1")? clock1:
                                    (signed_pipeline_register_b == "CLOCK2")? clock2:
                                    (signed_pipeline_register_b == "CLOCK3")? clock3: 1'b0;



    assign multiplier_reg0_wire_clk =   (multiplier_register0 == "CLOCK0")? clock0:
                                        (multiplier_register0 == "UNREGISTERED")? 1'b0:
                                        (multiplier_register0 == "CLOCK1")? clock1:
                                        (multiplier_register0 == "CLOCK2")? clock2:
                                        (multiplier_register0 == "CLOCK3")? clock3: 1'b0;



    assign multiplier_reg1_wire_clk =   (multiplier_register1 == "CLOCK0")? clock0:
                                        (multiplier_register1 == "UNREGISTERED")? 1'b0:
                                        (multiplier_register1 == "CLOCK1")? clock1:
                                        (multiplier_register1 == "CLOCK2")? clock2:
                                        (multiplier_register1 == "CLOCK3")? clock3: 1'b0;


    assign multiplier_reg2_wire_clk =   (multiplier_register2 == "CLOCK0")? clock0:
                                        (multiplier_register2 == "UNREGISTERED")? 1'b0:
                                        (multiplier_register2 == "CLOCK1")? clock1:
                                        (multiplier_register2 == "CLOCK2")? clock2:
                                        (multiplier_register2 == "CLOCK3")? clock3: 1'b0;



    assign multiplier_reg3_wire_clk =   (multiplier_register3 == "CLOCK0")? clock0:
                                        (multiplier_register3 == "UNREGISTERED")? 1'b0:
                                        (multiplier_register3 == "CLOCK1")? clock1:
                                        (multiplier_register3 == "CLOCK2")? clock2:
                                        (multiplier_register3 == "CLOCK3")? clock3: 1'b0;



    assign output_reg_wire_clk =    (output_register == "CLOCK0")? clock0:
                                    (output_register == "UNREGISTERED")? 1'b0:
                                    (output_register == "CLOCK1")? clock1:
                                    (output_register == "CLOCK2")? clock2:
                                    (output_register == "CLOCK3")? clock3: 1'b0;


    assign addnsub1_round_wire_clk =    (addnsub1_round_register == "CLOCK0")? clock0:
                                        (addnsub1_round_register == "UNREGISTERED")? 1'b0:
                                        (addnsub1_round_register == "CLOCK1")? clock1:
                                        (addnsub1_round_register == "CLOCK2")? clock2:
                                        (addnsub1_round_register == "CLOCK3")? clock3: 1'b0;


    assign addnsub1_round_pipe_wire_clk =   (addnsub1_round_pipeline_register == "CLOCK0")? clock0:
                                            (addnsub1_round_pipeline_register == "UNREGISTERED")? 1'b0:
                                            (addnsub1_round_pipeline_register == "CLOCK1")? clock1:
                                            (addnsub1_round_pipeline_register == "CLOCK2")? clock2:
                                            (addnsub1_round_pipeline_register == "CLOCK3")? clock3: 1'b0;


    assign addnsub3_round_wire_clk =    (addnsub3_round_register == "CLOCK0")? clock0:
                                        (addnsub3_round_register == "UNREGISTERED")? 1'b0:
                                        (addnsub3_round_register == "CLOCK1")? clock1:
                                        (addnsub3_round_register == "CLOCK2")? clock2:
                                        (addnsub3_round_register == "CLOCK3")? clock3: 1'b0;

    assign addnsub3_round_pipe_wire_clk =   (addnsub3_round_pipeline_register == "CLOCK0")? clock0:
                                            (addnsub3_round_pipeline_register == "UNREGISTERED")? 1'b0:
                                            (addnsub3_round_pipeline_register == "CLOCK1")? clock1:
                                            (addnsub3_round_pipeline_register == "CLOCK2")? clock2:
                                            (addnsub3_round_pipeline_register == "CLOCK3")? clock3: 1'b0;

    assign mult01_round_wire_clk =  (mult01_round_register == "CLOCK0")? clock0:
                                    (mult01_round_register == "UNREGISTERED")? 1'b0:
                                    (mult01_round_register == "CLOCK1")? clock1:
                                    (mult01_round_register == "CLOCK2")? clock2:
                                    (mult01_round_register == "CLOCK3")? clock3: 1'b0;


    assign mult01_saturate_wire_clk =   (mult01_saturation_register == "CLOCK0")? clock0:
                                        (mult01_saturation_register == "UNREGISTERED")? 1'b0:
                                        (mult01_saturation_register == "CLOCK1")? clock1:
                                        (mult01_saturation_register == "CLOCK2")? clock2:
                                        (mult01_saturation_register == "CLOCK3")? clock3: 1'b0;


    assign mult23_round_wire_clk =  (mult23_round_register == "CLOCK0")? clock0:
                                    (mult23_round_register == "UNREGISTERED")? 1'b0:
                                    (mult23_round_register == "CLOCK1")? clock1:
                                    (mult23_round_register == "CLOCK2")? clock2:
                                    (mult23_round_register == "CLOCK3")? clock3: 1'b0;

    assign mult23_saturate_wire_clk =   (mult23_saturation_register == "CLOCK0")? clock0:
                                        (mult23_saturation_register == "UNREGISTERED")? 1'b0:
                                        (mult23_saturation_register == "CLOCK1")? clock1:
                                        (mult23_saturation_register == "CLOCK2")? clock2:
                                        (mult23_saturation_register == "CLOCK3")? clock3: 1'b0;

    assign outround_reg_wire_clk =  (output_round_register == "CLOCK0") ? clock0:
                                    (output_round_register == "UNREGISTERED") ? 1'b0:
                                    (output_round_register == "CLOCK1") ? clock1:
                                    (output_round_register == "CLOCK2") ? clock2:
                                    (output_round_register == "CLOCK3") ? clock3 : 1'b0;

    assign outround_pipe_wire_clk = (output_round_pipeline_register == "CLOCK0") ? clock0:
                                    (output_round_pipeline_register == "UNREGISTERED") ? 1'b0:
                                    (output_round_pipeline_register == "CLOCK1") ? clock1:
                                    (output_round_pipeline_register == "CLOCK2") ? clock2:
                                    (output_round_pipeline_register == "CLOCK3") ? clock3 : 1'b0;

    assign chainout_round_reg_wire_clk =    (chainout_round_register == "CLOCK0") ? clock0:
                                            (chainout_round_register == "UNREGISTERED") ? 1'b0:
                                            (chainout_round_register == "CLOCK1") ? clock1:
                                            (chainout_round_register == "CLOCK2") ? clock2:
                                            (chainout_round_register == "CLOCK3") ? clock3 : 1'b0;

    assign chainout_round_pipe_wire_clk =   (chainout_round_pipeline_register == "CLOCK0") ? clock0:
                                            (chainout_round_pipeline_register == "UNREGISTERED") ? 1'b0:
                                            (chainout_round_pipeline_register == "CLOCK1") ? clock1:
                                            (chainout_round_pipeline_register == "CLOCK2") ? clock2:
                                            (chainout_round_pipeline_register == "CLOCK3") ? clock3 : 1'b0;

    assign chainout_round_out_reg_wire_clk =    (chainout_round_output_register == "CLOCK0") ? clock0:
                                                (chainout_round_output_register == "UNREGISTERED") ? 1'b0:
                                                (chainout_round_output_register == "CLOCK1") ? clock1:
                                                (chainout_round_output_register == "CLOCK2") ? clock2:
                                                (chainout_round_output_register == "CLOCK3") ? clock3 : 1'b0;

    assign outsat_reg_wire_clk =    (output_saturate_register == "CLOCK0") ? clock0:
                                    (output_saturate_register == "UNREGISTERED") ? 1'b0:
                                    (output_saturate_register == "CLOCK1") ? clock1:
                                    (output_saturate_register == "CLOCK2") ? clock2:
                                    (output_saturate_register == "CLOCK3") ? clock3 : 1'b0;

    assign outsat_pipe_wire_clk =   (output_saturate_pipeline_register == "CLOCK0") ? clock0:
                                    (output_saturate_pipeline_register == "UNREGISTERED") ? 1'b0:
                                    (output_saturate_pipeline_register == "CLOCK1") ? clock1:
                                    (output_saturate_pipeline_register == "CLOCK2") ? clock2:
                                    (output_saturate_pipeline_register == "CLOCK3") ? clock3 : 1'b0;

    assign chainout_sat_reg_wire_clk =      (chainout_saturate_register == "CLOCK0") ? clock0:
                                            (chainout_saturate_register == "UNREGISTERED") ? 1'b0:
                                            (chainout_saturate_register == "CLOCK1") ? clock1:
                                            (chainout_saturate_register == "CLOCK2") ? clock2:
                                            (chainout_saturate_register == "CLOCK3") ? clock3 : 1'b0;

    assign chainout_sat_pipe_wire_clk =     (chainout_saturate_pipeline_register == "CLOCK0") ? clock0:
                                            (chainout_saturate_pipeline_register == "UNREGISTERED") ? 1'b0:
                                            (chainout_saturate_pipeline_register == "CLOCK1") ? clock1:
                                            (chainout_saturate_pipeline_register == "CLOCK2") ? clock2:
                                            (chainout_saturate_pipeline_register == "CLOCK3") ? clock3 : 1'b0;

    assign chainout_sat_out_reg_wire_clk =      (chainout_saturate_output_register == "CLOCK0") ? clock0:
                                                (chainout_saturate_output_register == "UNREGISTERED") ? 1'b0:
                                                (chainout_saturate_output_register == "CLOCK1") ? clock1:
                                                (chainout_saturate_output_register == "CLOCK2") ? clock2:
                                                (chainout_saturate_output_register == "CLOCK3") ? clock3 : 1'b0;

    assign scanouta_reg_wire_clk =  (scanouta_register == "CLOCK0") ? clock0:
                                    (scanouta_register == "UNREGISTERED") ? 1'b0:
                                    (scanouta_register == "CLOCK1") ? clock1:
                                    (scanouta_register == "CLOCK2") ? clock2:
                                    (scanouta_register == "CLOCK3") ? clock3 : 1'b0;

    assign chainout_reg_wire_clk =  (chainout_register == "CLOCK0") ? clock0:
                                    (chainout_register == "UNREGISTERED") ? 1'b0:
                                    (chainout_register == "CLOCK1") ? clock1:
                                    (chainout_register == "CLOCK2") ? clock2:
                                    (chainout_register == "CLOCK3") ? clock3 : 1'b0;

    assign zerochainout_reg_wire_clk =  (zero_chainout_output_register == "CLOCK0") ? clock0:
                                        (zero_chainout_output_register == "UNREGISTERED") ? 1'b0:
                                        (zero_chainout_output_register == "CLOCK1") ? clock1:
                                        (zero_chainout_output_register == "CLOCK2") ? clock2:
                                        (zero_chainout_output_register == "CLOCK3") ? clock3 : 1'b0;

    assign rotate_reg_wire_clk =    (rotate_register == "CLOCK0") ? clock0:
                                    (rotate_register == "UNREGISTERED") ? 1'b0:
                                    (rotate_register == "CLOCK1") ? clock1:
                                    (rotate_register == "CLOCK2") ? clock2:
                                    (rotate_register == "CLOCK3") ? clock3 : 1'b0;

    assign rotate_pipe_wire_clk =   (rotate_pipeline_register == "CLOCK0") ? clock0:
                                    (rotate_pipeline_register == "UNREGISTERED") ? 1'b0:
                                    (rotate_pipeline_register == "CLOCK1") ? clock1:
                                    (rotate_pipeline_register == "CLOCK2") ? clock2:
                                    (rotate_pipeline_register == "CLOCK3") ? clock3 : 1'b0;

    assign rotate_out_reg_wire_clk =    (rotate_output_register == "CLOCK0") ? clock0:
                                        (rotate_output_register == "UNREGISTERED") ? 1'b0:
                                        (rotate_output_register == "CLOCK1") ? clock1:
                                        (rotate_output_register == "CLOCK2") ? clock2:
                                        (rotate_output_register == "CLOCK3") ? clock3 : 1'b0;

    assign shiftr_reg_wire_clk =    (shift_right_register == "CLOCK0") ? clock0:
                                    (shift_right_register == "UNREGISTERED") ? 1'b0:
                                    (shift_right_register == "CLOCK1") ? clock1:
                                    (shift_right_register == "CLOCK2") ? clock2:
                                    (shift_right_register == "CLOCK3") ? clock3 : 1'b0;

    assign shiftr_pipe_wire_clk =   (shift_right_pipeline_register == "CLOCK0") ? clock0:
                                    (shift_right_pipeline_register == "UNREGISTERED") ? 1'b0:
                                    (shift_right_pipeline_register == "CLOCK1") ? clock1:
                                    (shift_right_pipeline_register == "CLOCK2") ? clock2:
                                    (shift_right_pipeline_register == "CLOCK3") ? clock3 : 1'b0;

    assign shiftr_out_reg_wire_clk =    (shift_right_output_register == "CLOCK0") ? clock0:
                                        (shift_right_output_register == "UNREGISTERED") ? 1'b0:
                                        (shift_right_output_register == "CLOCK1") ? clock1:
                                        (shift_right_output_register == "CLOCK2") ? clock2:
                                        (shift_right_output_register == "CLOCK3") ? clock3 : 1'b0;

    assign zeroloopback_reg_wire_clk =  (zero_loopback_register == "CLOCK0") ? clock0 :
                                        (zero_loopback_register == "UNREGISTERED") ? 1'b0:
                                        (zero_loopback_register == "CLOCK1") ? clock1 :
                                        (zero_loopback_register == "CLOCK2") ? clock2 :
                                        (zero_loopback_register == "CLOCK3") ? clock3 : 1'b0;

    assign zeroloopback_pipe_wire_clk = (zero_loopback_pipeline_register == "CLOCK0") ? clock0 :
                                        (zero_loopback_pipeline_register == "UNREGISTERED") ? 1'b0:
                                        (zero_loopback_pipeline_register == "CLOCK1") ? clock1 :
                                        (zero_loopback_pipeline_register == "CLOCK2") ? clock2 :
                                        (zero_loopback_pipeline_register == "CLOCK3") ? clock3 : 1'b0;

    assign zeroloopback_out_wire_clk =  (zero_loopback_output_register == "CLOCK0") ? clock0 :
                                        (zero_loopback_output_register == "UNREGISTERED") ? 1'b0:
                                        (zero_loopback_output_register == "CLOCK1") ? clock1 :
                                        (zero_loopback_output_register == "CLOCK2") ? clock2 :
                                        (zero_loopback_output_register == "CLOCK3") ? clock3 : 1'b0;

    assign accumsload_reg_wire_clk =    (accum_sload_register == "CLOCK0") ? clock0 :
                                        (accum_sload_register == "UNREGISTERED") ? 1'b0:
                                        (accum_sload_register == "CLOCK1") ? clock1 :
                                        (accum_sload_register == "CLOCK2") ? clock2 :
                                        (accum_sload_register == "CLOCK3") ? clock3 : 1'b0;

    assign accumsload_pipe_wire_clk =   (accum_sload_pipeline_register == "CLOCK0") ? clock0 :
                                        (accum_sload_pipeline_register == "UNREGISTERED") ? 1'b0:
                                        (accum_sload_pipeline_register == "CLOCK1") ? clock1 :
                                        (accum_sload_pipeline_register == "CLOCK2") ? clock2 :
                                        (accum_sload_pipeline_register == "CLOCK3") ? clock3 : 1'b0;

	assign coeffsela_reg_wire_clk =  (coefsel0_register == "CLOCK0") ? clock0 :
                                     (coefsel0_register == "UNREGISTERED") ? 1'b0:
                                     (coefsel0_register == "CLOCK1") ? clock1 :
                                     (coefsel0_register == "CLOCK2") ? clock2 : 1'b0;

	assign coeffselb_reg_wire_clk =  (coefsel1_register == "CLOCK0") ? clock0 :
                                     (coefsel1_register == "UNREGISTERED") ? 1'b0:
                                     (coefsel1_register == "CLOCK1") ? clock1 :
                                     (coefsel1_register == "CLOCK2") ? clock2 : 1'b0;

	assign coeffselc_reg_wire_clk =  (coefsel2_register == "CLOCK0") ? clock0 :
                                     (coefsel2_register == "UNREGISTERED") ? 1'b0:
                                     (coefsel2_register == "CLOCK1") ? clock1 :
                                     (coefsel2_register == "CLOCK2") ? clock2 : 1'b0;

	assign coeffseld_reg_wire_clk =  (coefsel3_register == "CLOCK0") ? clock0 :
                                     (coefsel3_register == "UNREGISTERED") ? 1'b0:
                                     (coefsel3_register == "CLOCK1") ? clock1 :
                                     (coefsel3_register == "CLOCK2") ? clock2 : 1'b0;

	assign systolic1_reg_wire_clk =  (systolic_delay1 == "CLOCK0") ? clock0 :
                                     (systolic_delay1 == "UNREGISTERED") ? 1'b0:
                                     (systolic_delay1 == "CLOCK1") ? clock1 :
                                     (systolic_delay1 == "CLOCK2") ? clock2 : 1'b0;

	assign systolic3_reg_wire_clk =  (systolic_delay3 == "CLOCK0") ? clock0 :
                                     (systolic_delay3 == "UNREGISTERED") ? 1'b0:
                                     (systolic_delay3 == "CLOCK1") ? clock1 :
                                     (systolic_delay3 == "CLOCK2") ? clock2 : 1'b0;

    // ----------------------------------------------------------------
    // This block updates the internal clock enable signals accordingly
    // every time the global clock enable signal changes state
    // ----------------------------------------------------------------


    assign input_reg_a0_wire_en =   (input_register_a0 == "CLOCK0")? ena0:
                                    (input_register_a0 == "UNREGISTERED")? 1'b1:
                                    (input_register_a0 == "CLOCK1")? ena1:
                                    (input_register_a0 == "CLOCK2")? ena2:
                                    (input_register_a0 == "CLOCK3")? ena3: 1'b1;



    assign input_reg_a1_wire_en =   (input_register_a1 == "CLOCK0")? ena0:
                                    (input_register_a1 == "UNREGISTERED")? 1'b1:
                                    (input_register_a1 == "CLOCK1")? ena1:
                                    (input_register_a1 == "CLOCK2")? ena2:
                                    (input_register_a1 == "CLOCK3")? ena3: 1'b1;


    assign input_reg_a2_wire_en =   (input_register_a2 == "CLOCK0")? ena0:
                                    (input_register_a2 == "UNREGISTERED")? 1'b1:
                                    (input_register_a2 == "CLOCK1")? ena1:
                                    (input_register_a2 == "CLOCK2")? ena2:
                                    (input_register_a2 == "CLOCK3")? ena3: 1'b1;


    assign input_reg_a3_wire_en =   (input_register_a3 == "CLOCK0")? ena0:
                                    (input_register_a3 == "UNREGISTERED")? 1'b1:
                                    (input_register_a3 == "CLOCK1")? ena1:
                                    (input_register_a3 == "CLOCK2")? ena2:
                                    (input_register_a3 == "CLOCK3")? ena3: 1'b1;


    assign input_reg_b0_wire_en =   (input_register_b0 == "CLOCK0")? ena0:
                                    (input_register_b0 == "UNREGISTERED")? 1'b1:
                                    (input_register_b0 == "CLOCK1")? ena1:
                                    (input_register_b0 == "CLOCK2")? ena2:
                                    (input_register_b0 == "CLOCK3")? ena3: 1'b1;



    assign input_reg_b1_wire_en =   (input_register_b1 == "CLOCK0")? ena0:
                                    (input_register_b1 == "UNREGISTERED")? 1'b1:
                                    (input_register_b1 == "CLOCK1")? ena1:
                                    (input_register_b1 == "CLOCK2")? ena2:
                                    (input_register_b1 == "CLOCK3")? ena3: 1'b1;


    assign input_reg_b2_wire_en =   (input_register_b2 == "CLOCK0")? ena0:
                                    (input_register_b2 == "UNREGISTERED")? 1'b1:
                                    (input_register_b2 == "CLOCK1")? ena1:
                                    (input_register_b2 == "CLOCK2")? ena2:
                                    (input_register_b2 == "CLOCK3")? ena3: 1'b1;

    assign input_reg_b3_wire_en =   (input_register_b3 == "CLOCK0")? ena0:
                                    (input_register_b3 == "UNREGISTERED")? 1'b1:
                                    (input_register_b3 == "CLOCK1")? ena1:
                                    (input_register_b3 == "CLOCK2")? ena2:
                                    (input_register_b3 == "CLOCK3")? ena3: 1'b1;

	assign input_reg_c0_wire_en =   (input_register_c0 == "CLOCK0")? ena0:
                                    (input_register_c0 == "UNREGISTERED")? 1'b1:
                                    (input_register_c0 == "CLOCK1")? ena1:
                                    (input_register_c0 == "CLOCK2")? ena2: 1'b1;

    assign input_reg_c1_wire_en =   (input_register_c1 == "CLOCK0")? ena0:
                                    (input_register_c1 == "UNREGISTERED")? 1'b1:
                                    (input_register_c1 == "CLOCK1")? ena1:
                                    (input_register_c1 == "CLOCK2")? ena2: 1'b1;

    assign input_reg_c2_wire_en =   (input_register_c2 == "CLOCK0")? ena0:
                                    (input_register_c2 == "UNREGISTERED")? 1'b1:
                                    (input_register_c2 == "CLOCK1")? ena1:
                                    (input_register_c2 == "CLOCK2")? ena2: 1'b1;

    assign input_reg_c3_wire_en =   (input_register_c3 == "CLOCK0")? ena0:
                                    (input_register_c3 == "UNREGISTERED")? 1'b1:
                                    (input_register_c3 == "CLOCK1")? ena1:
                                    (input_register_c3 == "CLOCK2")? ena2: 1'b1;

    assign addsub1_reg_wire_en =    (addnsub_multiplier_register1 == "CLOCK0")? ena0:
                                    (addnsub_multiplier_register1 == "UNREGISTERED")? 1'b1:
                                    (addnsub_multiplier_register1 == "CLOCK1")? ena1:
                                    (addnsub_multiplier_register1 == "CLOCK2")? ena2:
                                    (addnsub_multiplier_register1 == "CLOCK3")? ena3: 1'b1;



    assign addsub1_pipe_wire_en =   (addnsub_multiplier_pipeline_register1 == "CLOCK0")? ena0:
                                    (addnsub_multiplier_pipeline_register1 == "UNREGISTERED")? 1'b1:
                                    (addnsub_multiplier_pipeline_register1 == "CLOCK1")? ena1:
                                    (addnsub_multiplier_pipeline_register1 == "CLOCK2")? ena2:
                                    (addnsub_multiplier_pipeline_register1 == "CLOCK3")? ena3: 1'b1;


    assign addsub3_reg_wire_en =    (addnsub_multiplier_register3 == "CLOCK0")? ena0:
                                    (addnsub_multiplier_register3 == "UNREGISTERED")? 1'b1:
                                    (addnsub_multiplier_register3 == "CLOCK1")? ena1:
                                    (addnsub_multiplier_register3 == "CLOCK2")? ena2:
                                    (addnsub_multiplier_register3 == "CLOCK3")? ena3: 1'b1;



    assign addsub3_pipe_wire_en =   (addnsub_multiplier_pipeline_register3 == "CLOCK0")? ena0:
                                    (addnsub_multiplier_pipeline_register3 == "UNREGISTERED")? 1'b1:
                                    (addnsub_multiplier_pipeline_register3 == "CLOCK1")? ena1:
                                    (addnsub_multiplier_pipeline_register3 == "CLOCK2")? ena2:
                                    (addnsub_multiplier_pipeline_register3 == "CLOCK3")? ena3: 1'b1;



    assign sign_reg_a_wire_en =     (signed_register_a == "CLOCK0")? ena0:
                                    (signed_register_a == "UNREGISTERED")? 1'b1:
                                    (signed_register_a == "CLOCK1")? ena1:
                                    (signed_register_a == "CLOCK2")? ena2:
                                    (signed_register_a == "CLOCK3")? ena3: 1'b1;



    assign sign_pipe_a_wire_en =    (signed_pipeline_register_a == "CLOCK0")? ena0:
                                    (signed_pipeline_register_a == "UNREGISTERED")? 1'b1:
                                    (signed_pipeline_register_a == "CLOCK1")? ena1:
                                    (signed_pipeline_register_a == "CLOCK2")? ena2:
                                    (signed_pipeline_register_a == "CLOCK3")? ena3: 1'b1;



    assign sign_reg_b_wire_en =     (signed_register_b == "CLOCK0")? ena0:
                                    (signed_register_b == "UNREGISTERED")? 1'b1:
                                    (signed_register_b == "CLOCK1")? ena1:
                                    (signed_register_b == "CLOCK2")? ena2:
                                    (signed_register_b == "CLOCK3")? ena3: 1'b1;



    assign sign_pipe_b_wire_en =    (signed_pipeline_register_b == "CLOCK0")? ena0:
                                    (signed_pipeline_register_b == "UNREGISTERED")? 1'b1:
                                    (signed_pipeline_register_b == "CLOCK1")? ena1:
                                    (signed_pipeline_register_b == "CLOCK2")? ena2:
                                    (signed_pipeline_register_b == "CLOCK3")? ena3: 1'b1;



    assign multiplier_reg0_wire_en =    (multiplier_register0 == "CLOCK0")? ena0:
                                        (multiplier_register0 == "UNREGISTERED")? 1'b1:
                                        (multiplier_register0 == "CLOCK1")? ena1:
                                        (multiplier_register0 == "CLOCK2")? ena2:
                                        (multiplier_register0 == "CLOCK3")? ena3: 1'b1;



    assign multiplier_reg1_wire_en =    (multiplier_register1 == "CLOCK0")? ena0:
                                        (multiplier_register1 == "UNREGISTERED")? 1'b1:
                                        (multiplier_register1 == "CLOCK1")? ena1:
                                        (multiplier_register1 == "CLOCK2")? ena2:
                                        (multiplier_register1 == "CLOCK3")? ena3: 1'b1;


    assign multiplier_reg2_wire_en =    (multiplier_register2 == "CLOCK0")? ena0:
                                        (multiplier_register2 == "UNREGISTERED")? 1'b1:
                                        (multiplier_register2 == "CLOCK1")? ena1:
                                        (multiplier_register2 == "CLOCK2")? ena2:
                                        (multiplier_register2 == "CLOCK3")? ena3: 1'b1;



    assign multiplier_reg3_wire_en =    (multiplier_register3 == "CLOCK0")? ena0:
                                        (multiplier_register3 == "UNREGISTERED")? 1'b1:
                                        (multiplier_register3 == "CLOCK1")? ena1:
                                        (multiplier_register3 == "CLOCK2")? ena2:
                                        (multiplier_register3 == "CLOCK3")? ena3: 1'b1;



    assign output_reg_wire_en =     (output_register == "CLOCK0")? ena0:
                                    (output_register == "UNREGISTERED")? 1'b1:
                                    (output_register == "CLOCK1")? ena1:
                                    (output_register == "CLOCK2")? ena2:
                                    (output_register == "CLOCK3")? ena3: 1'b1;


    assign addnsub1_round_wire_en =     (addnsub1_round_register == "CLOCK0")? ena0:
                                        (addnsub1_round_register == "UNREGISTERED")? 1'b1:
                                        (addnsub1_round_register == "CLOCK1")? ena1:
                                        (addnsub1_round_register == "CLOCK2")? ena2:
                                        (addnsub1_round_register == "CLOCK3")? ena3: 1'b1;


    assign addnsub1_round_pipe_wire_en =    (addnsub1_round_pipeline_register == "CLOCK0")? ena0:
                                            (addnsub1_round_pipeline_register == "UNREGISTERED")? 1'b1:
                                            (addnsub1_round_pipeline_register == "CLOCK1")? ena1:
                                            (addnsub1_round_pipeline_register == "CLOCK2")? ena2:
                                            (addnsub1_round_pipeline_register == "CLOCK3")? ena3: 1'b1;


    assign addnsub3_round_wire_en = (addnsub3_round_register == "CLOCK0")? ena0:
                                    (addnsub3_round_register == "UNREGISTERED")? 1'b1:
                                    (addnsub3_round_register == "CLOCK1")? ena1:
                                    (addnsub3_round_register == "CLOCK2")? ena2:
                                    (addnsub3_round_register == "CLOCK3")? ena3: 1'b1;


    assign addnsub3_round_pipe_wire_en =    (addnsub3_round_pipeline_register == "CLOCK0")? ena0:
                                            (addnsub3_round_pipeline_register == "UNREGISTERED")? 1'b1:
                                            (addnsub3_round_pipeline_register == "CLOCK1")? ena1:
                                            (addnsub3_round_pipeline_register == "CLOCK2")? ena2:
                                            (addnsub3_round_pipeline_register == "CLOCK3")? ena3: 1'b1;


    assign mult01_round_wire_en =   (mult01_round_register == "CLOCK0")? ena0:
                                    (mult01_round_register == "UNREGISTERED")? 1'b1:
                                    (mult01_round_register == "CLOCK1")? ena1:
                                    (mult01_round_register == "CLOCK2")? ena2:
                                    (mult01_round_register == "CLOCK3")? ena3: 1'b1;


    assign mult01_saturate_wire_en =    (mult01_saturation_register == "CLOCK0")? ena0:
                                        (mult01_saturation_register == "UNREGISTERED")? 1'b1:
                                        (mult01_saturation_register == "CLOCK1")? ena1:
                                        (mult01_saturation_register == "CLOCK2")? ena2:
                                        (mult01_saturation_register == "CLOCK3")? ena3: 1'b1;


    assign mult23_round_wire_en =   (mult23_round_register == "CLOCK0")? ena0:
                                    (mult23_round_register == "UNREGISTERED")? 1'b1:
                                    (mult23_round_register == "CLOCK1")? ena1:
                                    (mult23_round_register == "CLOCK2")? ena2:
                                    (mult23_round_register == "CLOCK3")? ena3: 1'b1;


    assign mult23_saturate_wire_en =    (mult23_saturation_register == "CLOCK0")? ena0:
                                        (mult23_saturation_register == "UNREGISTERED")? 1'b1:
                                        (mult23_saturation_register == "CLOCK1")? ena1:
                                        (mult23_saturation_register == "CLOCK2")? ena2:
                                        (mult23_saturation_register == "CLOCK3")? ena3: 1'b1;


    assign outround_reg_wire_en =  (output_round_register == "CLOCK0") ? ena0:
                                    (output_round_register == "UNREGISTERED") ? 1'b1:
                                    (output_round_register == "CLOCK1") ? ena1:
                                    (output_round_register == "CLOCK2") ? ena2:
                                    (output_round_register == "CLOCK3") ? ena3 : 1'b1;

    assign outround_pipe_wire_en = (output_round_pipeline_register == "CLOCK0") ? ena0:
                                    (output_round_pipeline_register == "UNREGISTERED") ? 1'b1:
                                    (output_round_pipeline_register == "CLOCK1") ? ena1:
                                    (output_round_pipeline_register == "CLOCK2") ? ena2:
                                    (output_round_pipeline_register == "CLOCK3") ? ena3 : 1'b1;

    assign chainout_round_reg_wire_en =    (chainout_round_register == "CLOCK0") ? ena0:
                                            (chainout_round_register == "UNREGISTERED") ? 1'b1:
                                            (chainout_round_register == "CLOCK1") ? ena1:
                                            (chainout_round_register == "CLOCK2") ? ena2:
                                            (chainout_round_register == "CLOCK3") ? ena3 : 1'b1;

    assign chainout_round_pipe_wire_en =   (chainout_round_pipeline_register == "CLOCK0") ? ena0:
                                            (chainout_round_pipeline_register == "UNREGISTERED") ? 1'b1:
                                            (chainout_round_pipeline_register == "CLOCK1") ? ena1:
                                            (chainout_round_pipeline_register == "CLOCK2") ? ena2:
                                            (chainout_round_pipeline_register == "CLOCK3") ? ena3 : 1'b1;

    assign chainout_round_out_reg_wire_en =    (chainout_round_output_register == "CLOCK0") ? ena0:
                                                (chainout_round_output_register == "UNREGISTERED") ? 1'b1:
                                                (chainout_round_output_register == "CLOCK1") ? ena1:
                                                (chainout_round_output_register == "CLOCK2") ? ena2:
                                                (chainout_round_output_register == "CLOCK3") ? ena3 : 1'b1;

    assign outsat_reg_wire_en =    (output_saturate_register == "CLOCK0") ? ena0:
                                    (output_saturate_register == "UNREGISTERED") ? 1'b1:
                                    (output_saturate_register == "CLOCK1") ? ena1:
                                    (output_saturate_register == "CLOCK2") ? ena2:
                                    (output_saturate_register == "CLOCK3") ? ena3 : 1'b1;

    assign outsat_pipe_wire_en =   (output_saturate_pipeline_register == "CLOCK0") ? ena0:
                                    (output_saturate_pipeline_register == "UNREGISTERED") ? 1'b1:
                                    (output_saturate_pipeline_register == "CLOCK1") ? ena1:
                                    (output_saturate_pipeline_register == "CLOCK2") ? ena2:
                                    (output_saturate_pipeline_register == "CLOCK3") ? ena3 : 1'b1;

    assign chainout_sat_reg_wire_en =      (chainout_saturate_register == "CLOCK0") ? ena0:
                                            (chainout_saturate_register == "UNREGISTERED") ? 1'b1:
                                            (chainout_saturate_register == "CLOCK1") ? ena1:
                                            (chainout_saturate_register == "CLOCK2") ? ena2:
                                            (chainout_saturate_register == "CLOCK3") ? ena3 : 1'b1;

    assign chainout_sat_pipe_wire_en =     (chainout_saturate_pipeline_register == "CLOCK0") ? ena0:
                                            (chainout_saturate_pipeline_register == "UNREGISTERED") ? 1'b1:
                                            (chainout_saturate_pipeline_register == "CLOCK1") ? ena1:
                                            (chainout_saturate_pipeline_register == "CLOCK2") ? ena2:
                                            (chainout_saturate_pipeline_register == "CLOCK3") ? ena3 : 1'b1;

    assign chainout_sat_out_reg_wire_en =      (chainout_saturate_output_register == "CLOCK0") ? ena0:
                                                (chainout_saturate_output_register == "UNREGISTERED") ? 1'b1:
                                                (chainout_saturate_output_register == "CLOCK1") ? ena1:
                                                (chainout_saturate_output_register == "CLOCK2") ? ena2:
                                                (chainout_saturate_output_register == "CLOCK3") ? ena3 : 1'b1;

    assign scanouta_reg_wire_en =   (scanouta_register == "CLOCK0") ? ena0:
                                    (scanouta_register == "UNREGISTERED") ? 1'b1:
                                    (scanouta_register == "CLOCK1") ? ena1:
                                    (scanouta_register == "CLOCK2") ? ena2:
                                    (scanouta_register == "CLOCK3") ? ena3 : 1'b1;

    assign chainout_reg_wire_en  =  (chainout_register == "CLOCK0") ? ena0:
                                    (chainout_register == "UNREGISTERED") ? 1'b1:
                                    (chainout_register == "CLOCK1") ? ena1:
                                    (chainout_register == "CLOCK2") ? ena2:
                                    (chainout_register == "CLOCK3") ? ena3 : 1'b1;

    assign zerochainout_reg_wire_en =  (zero_chainout_output_register == "CLOCK0") ? ena0:
                                        (zero_chainout_output_register == "UNREGISTERED") ? 1'b1:
                                        (zero_chainout_output_register == "CLOCK1") ? ena1:
                                        (zero_chainout_output_register == "CLOCK2") ? ena2:
                                        (zero_chainout_output_register == "CLOCK3") ? ena3 : 1'b1;

    assign rotate_reg_wire_en =     (rotate_register == "CLOCK0") ? ena0:
                                    (rotate_register == "UNREGISTERED") ? 1'b1:
                                    (rotate_register == "CLOCK1") ? ena1:
                                    (rotate_register == "CLOCK2") ? ena2:
                                    (rotate_register == "CLOCK3") ? ena3 : 1'b1;

    assign rotate_pipe_wire_en =    (rotate_pipeline_register == "CLOCK0") ? ena0:
                                    (rotate_pipeline_register == "UNREGISTERED") ? 1'b1:
                                    (rotate_pipeline_register == "CLOCK1") ? ena1:
                                    (rotate_pipeline_register == "CLOCK2") ? ena2:
                                    (rotate_pipeline_register == "CLOCK3") ? ena3 : 1'b1;

    assign rotate_out_reg_wire_en =     (rotate_output_register == "CLOCK0") ? ena0:
                                        (rotate_output_register == "UNREGISTERED") ? 1'b1:
                                        (rotate_output_register == "CLOCK1") ? ena1:
                                        (rotate_output_register == "CLOCK2") ? ena2:
                                        (rotate_output_register == "CLOCK3") ? ena3 : 1'b1;

    assign shiftr_reg_wire_en =     (shift_right_register == "CLOCK0") ? ena0:
                                    (shift_right_register == "UNREGISTERED") ? 1'b1:
                                    (shift_right_register == "CLOCK1") ? ena1:
                                    (shift_right_register == "CLOCK2") ? ena2:
                                    (shift_right_register == "CLOCK3") ? ena3 : 1'b1;

    assign shiftr_pipe_wire_en =    (shift_right_pipeline_register == "CLOCK0") ? ena0:
                                    (shift_right_pipeline_register == "UNREGISTERED") ? 1'b1:
                                    (shift_right_pipeline_register == "CLOCK1") ? ena1:
                                    (shift_right_pipeline_register == "CLOCK2") ? ena2:
                                    (shift_right_pipeline_register == "CLOCK3") ? ena3 : 1'b1;

    assign shiftr_out_reg_wire_en =     (shift_right_output_register == "CLOCK0") ? ena0:
                                        (shift_right_output_register == "UNREGISTERED") ? 1'b1:
                                        (shift_right_output_register == "CLOCK1") ? ena1:
                                        (shift_right_output_register == "CLOCK2") ? ena2:
                                        (shift_right_output_register == "CLOCK3") ? ena3 : 1'b1;

    assign zeroloopback_reg_wire_en =  (zero_loopback_register == "CLOCK0") ? ena0 :
                                        (zero_loopback_register == "UNREGISTERED") ? 1'b1:
                                        (zero_loopback_register == "CLOCK1") ? ena1 :
                                        (zero_loopback_register == "CLOCK2") ? ena2 :
                                        (zero_loopback_register == "CLOCK3") ? ena3 : 1'b1;

    assign zeroloopback_pipe_wire_en = (zero_loopback_pipeline_register == "CLOCK0") ? ena0 :
                                        (zero_loopback_pipeline_register == "UNREGISTERED") ? 1'b1:
                                        (zero_loopback_pipeline_register == "CLOCK1") ? ena1 :
                                        (zero_loopback_pipeline_register == "CLOCK2") ? ena2 :
                                        (zero_loopback_pipeline_register == "CLOCK3") ? ena3 : 1'b1;

    assign zeroloopback_out_wire_en =  (zero_loopback_output_register == "CLOCK0") ? ena0 :
                                        (zero_loopback_output_register == "UNREGISTERED") ? 1'b1:
                                        (zero_loopback_output_register == "CLOCK1") ? ena1 :
                                        (zero_loopback_output_register == "CLOCK2") ? ena2 :
                                        (zero_loopback_output_register == "CLOCK3") ? ena3 : 1'b1;

    assign accumsload_reg_wire_en =    (accum_sload_register == "CLOCK0") ? ena0 :
                                        (accum_sload_register == "UNREGISTERED") ? 1'b1:
                                        (accum_sload_register == "CLOCK1") ? ena1 :
                                        (accum_sload_register == "CLOCK2") ? ena2 :
                                        (accum_sload_register == "CLOCK3") ? ena3 : 1'b1;

    assign accumsload_pipe_wire_en =   (accum_sload_pipeline_register == "CLOCK0") ? ena0 :
                                        (accum_sload_pipeline_register == "UNREGISTERED") ? 1'b1:
                                        (accum_sload_pipeline_register == "CLOCK1") ? ena1 :
                                        (accum_sload_pipeline_register == "CLOCK2") ? ena2 :
                                        (accum_sload_pipeline_register == "CLOCK3") ? ena3 : 1'b1;

	assign coeffsela_reg_wire_en =  (coefsel0_register == "CLOCK0") ? ena0:
                                    (coefsel0_register == "UNREGISTERED") ? 1'b1:
                                    (coefsel0_register == "CLOCK1") ? ena1:
                                    (coefsel0_register == "CLOCK2") ? ena2: 1'b1;

	assign coeffselb_reg_wire_en =  (coefsel1_register == "CLOCK0") ? ena0:
                                    (coefsel1_register == "UNREGISTERED") ? 1'b1:
                                    (coefsel1_register == "CLOCK1") ? ena1:
                                    (coefsel1_register == "CLOCK2") ? ena2: 1'b1;

	assign coeffselc_reg_wire_en =  (coefsel2_register == "CLOCK0") ? ena0:
                                    (coefsel2_register == "UNREGISTERED") ? 1'b1:
                                    (coefsel2_register == "CLOCK1") ? ena1:
                                    (coefsel2_register == "CLOCK2") ? ena2: 1'b1;

	assign coeffseld_reg_wire_en =  (coefsel3_register == "CLOCK0") ? ena0:
                                    (coefsel3_register == "UNREGISTERED") ? 1'b1:
                                    (coefsel3_register == "CLOCK1") ? ena1:
                                    (coefsel3_register == "CLOCK2") ? ena2: 1'b1;

	assign systolic1_reg_wire_en =  (systolic_delay1 == "CLOCK0") ? ena0:
                                    (systolic_delay1 == "UNREGISTERED") ? 1'b1:
                                    (systolic_delay1 == "CLOCK1") ? ena1:
                                    (systolic_delay1 == "CLOCK2") ? ena2: 1'b1;

	assign systolic3_reg_wire_en =  (systolic_delay3 == "CLOCK0") ? ena0:
                                    (systolic_delay3 == "UNREGISTERED") ? 1'b1:
                                    (systolic_delay3 == "CLOCK1") ? ena1:
                                    (systolic_delay3 == "CLOCK2") ? ena2: 1'b1;


    // ---------------------------------------------------------
    // This block updates the internal clear signals accordingly
    // every time the global clear signal changes state
    // ---------------------------------------------------------

    assign input_reg_a0_wire_clr =  (input_aclr_a0 == "ACLR3")? aclr3:
                                    (input_aclr_a0 == "UNREGISTERED")? 1'b0:
                                    (input_aclr_a0 == "ACLR0")? aclr0:
                                    (input_aclr_a0 == "ACLR1")? aclr1:
                                    (input_aclr_a0 == "ACLR2")? aclr2: 1'b0;



    assign input_reg_a1_wire_clr =  (input_aclr_a1 == "ACLR3")? aclr3:
                                    (input_aclr_a1 == "UNREGISTERED")? 1'b0:
                                    (input_aclr_a1 == "ACLR0")? aclr0:
                                    (input_aclr_a1 == "ACLR1")? aclr1:
                                    (input_aclr_a1 == "ACLR2")? aclr2: 1'b0;


    assign input_reg_a2_wire_clr =  (input_aclr_a2 == "ACLR3")? aclr3:
                                    (input_aclr_a2 == "UNREGISTERED")? 1'b0:
                                    (input_aclr_a2 == "ACLR0")? aclr0:
                                    (input_aclr_a2 == "ACLR1")? aclr1:
                                    (input_aclr_a2 == "ACLR2")? aclr2: 1'b0;



    assign input_reg_a3_wire_clr =  (input_aclr_a3 == "ACLR3")? aclr3:
                                    (input_aclr_a3 == "UNREGISTERED")? 1'b0:
                                    (input_aclr_a3 == "ACLR0")? aclr0:
                                    (input_aclr_a3 == "ACLR1")? aclr1:
                                    (input_aclr_a3 == "ACLR2")? aclr2: 1'b0;


    assign input_reg_b0_wire_clr =  (input_aclr_b0 == "ACLR3")? aclr3:
                                    (input_aclr_b0 == "UNREGISTERED")? 1'b0:
                                    (input_aclr_b0 == "ACLR0")? aclr0:
                                    (input_aclr_b0 == "ACLR1")? aclr1:
                                    (input_aclr_b0 == "ACLR2")? aclr2: 1'b0;


    assign input_reg_b1_wire_clr =  (input_aclr_b1 == "ACLR3")? aclr3:
                                    (input_aclr_b1 == "UNREGISTERED")? 1'b0:
                                    (input_aclr_b1 == "ACLR0")? aclr0:
                                    (input_aclr_b1 == "ACLR1")? aclr1:
                                    (input_aclr_b1 == "ACLR2")? aclr2: 1'b0;


    assign input_reg_b2_wire_clr =  (input_aclr_b2 == "ACLR3")? aclr3:
                                    (input_aclr_b2 == "UNREGISTERED")? 1'b0:
                                    (input_aclr_b2 == "ACLR0")? aclr0:
                                    (input_aclr_b2 == "ACLR1")? aclr1:
                                    (input_aclr_b2 == "ACLR2")? aclr2: 1'b0;



    assign input_reg_b3_wire_clr =  (input_aclr_b3 == "ACLR3")? aclr3:
                                    (input_aclr_b3 == "UNREGISTERED")? 1'b0:
                                    (input_aclr_b3 == "ACLR0")? aclr0:
                                    (input_aclr_b3 == "ACLR1")? aclr1:
                                    (input_aclr_b3 == "ACLR2")? aclr2: 1'b0;

	assign input_reg_c0_wire_clr =  (input_aclr_c0 == "UNREGISTERED")? 1'b0:
                                    (input_aclr_c0 == "ACLR0")? aclr0:
                                    (input_aclr_c0 == "ACLR1")? aclr1: 1'b0;

    assign input_reg_c1_wire_clr =  (input_aclr_c1 == "UNREGISTERED")? 1'b0:
                                    (input_aclr_c1 == "ACLR0")? aclr0:
                                    (input_aclr_c1 == "ACLR1")? aclr1: 1'b0;

    assign input_reg_c2_wire_clr =  (input_aclr_c2 == "UNREGISTERED")? 1'b0:
                                    (input_aclr_c2 == "ACLR0")? aclr0:
                                    (input_aclr_c2 == "ACLR1")? aclr1: 1'b0;

    assign input_reg_c3_wire_clr =  (input_aclr_c3 == "UNREGISTERED")? 1'b0:
                                    (input_aclr_c3 == "ACLR0")? aclr0:
                                    (input_aclr_c3 == "ACLR1")? aclr1: 1'b0;


    assign addsub1_reg_wire_clr =   (addnsub_multiplier_aclr1 == "ACLR3")? aclr3:
                                    (addnsub_multiplier_aclr1 == "UNREGISTERED")? 1'b0:
                                    (addnsub_multiplier_aclr1 == "ACLR0")? aclr0:
                                    (addnsub_multiplier_aclr1 == "ACLR1")? aclr1:
                                    (addnsub_multiplier_aclr1 == "ACLR2")? aclr2: 1'b0;



    assign addsub1_pipe_wire_clr =  (addnsub_multiplier_pipeline_aclr1 == "ACLR3")? aclr3:
                                    (addnsub_multiplier_pipeline_aclr1 == "UNREGISTERED")? 1'b0:
                                    (addnsub_multiplier_pipeline_aclr1 == "ACLR0")? aclr0:
                                    (addnsub_multiplier_pipeline_aclr1 == "ACLR1")? aclr1:
                                    (addnsub_multiplier_pipeline_aclr1 == "ACLR2")? aclr2: 1'b0;




    assign addsub3_reg_wire_clr =   (addnsub_multiplier_aclr3 == "ACLR3")? aclr3:
                                    (addnsub_multiplier_aclr3 == "UNREGISTERED")? 1'b0:
                                    (addnsub_multiplier_aclr3 == "ACLR0")? aclr0:
                                    (addnsub_multiplier_aclr3 == "ACLR1")? aclr1:
                                    (addnsub_multiplier_aclr3 == "ACLR2")? aclr2: 1'b0;



    assign addsub3_pipe_wire_clr =  (addnsub_multiplier_pipeline_aclr3 == "ACLR3")? aclr3:
                                    (addnsub_multiplier_pipeline_aclr3 == "UNREGISTERED")? 1'b0:
                                    (addnsub_multiplier_pipeline_aclr3 == "ACLR0")? aclr0:
                                    (addnsub_multiplier_pipeline_aclr3 == "ACLR1")? aclr1:
                                    (addnsub_multiplier_pipeline_aclr3 == "ACLR2")? aclr2: 1'b0;




    assign sign_reg_a_wire_clr =    (signed_aclr_a == "ACLR3")? aclr3:
                                    (signed_aclr_a == "UNREGISTERED")? 1'b0:
                                    (signed_aclr_a == "ACLR0")? aclr0:
                                    (signed_aclr_a == "ACLR1")? aclr1:
                                    (signed_aclr_a == "ACLR2")? aclr2: 1'b0;



    assign sign_pipe_a_wire_clr =   (signed_pipeline_aclr_a == "ACLR3")? aclr3:
                                    (signed_pipeline_aclr_a == "UNREGISTERED")? 1'b0:
                                    (signed_pipeline_aclr_a == "ACLR0")? aclr0:
                                    (signed_pipeline_aclr_a == "ACLR1")? aclr1:
                                    (signed_pipeline_aclr_a == "ACLR2")? aclr2: 1'b0;



    assign sign_reg_b_wire_clr =    (signed_aclr_b == "ACLR3")? aclr3:
                                    (signed_aclr_b == "UNREGISTERED")? 1'b0:
                                    (signed_aclr_b == "ACLR0")? aclr0:
                                    (signed_aclr_b == "ACLR1")? aclr1:
                                    (signed_aclr_b == "ACLR2")? aclr2: 1'b0;



    assign sign_pipe_b_wire_clr =   (signed_pipeline_aclr_b == "ACLR3")? aclr3:
                                    (signed_pipeline_aclr_b == "UNREGISTERED")? 1'b0:
                                    (signed_pipeline_aclr_b == "ACLR0")? aclr0:
                                    (signed_pipeline_aclr_b == "ACLR1")? aclr1:
                                    (signed_pipeline_aclr_b == "ACLR2")? aclr2: 1'b0;




    assign multiplier_reg0_wire_clr =   (multiplier_aclr0 == "ACLR3")? aclr3:
                                        (multiplier_aclr0 == "UNREGISTERED")? 1'b0:
                                        (multiplier_aclr0 == "ACLR0")? aclr0:
                                        (multiplier_aclr0 == "ACLR1")? aclr1:
                                        (multiplier_aclr0 == "ACLR2")? aclr2: 1'b0;



    assign multiplier_reg1_wire_clr =   (multiplier_aclr1 == "ACLR3")? aclr3:
                                        (multiplier_aclr1 == "UNREGISTERED")? 1'b0:
                                        (multiplier_aclr1 == "ACLR0")? aclr0:
                                        (multiplier_aclr1 == "ACLR1")? aclr1:
                                        (multiplier_aclr1 == "ACLR2")? aclr2: 1'b0;



    assign multiplier_reg2_wire_clr =   (multiplier_aclr2 == "ACLR3")? aclr3:
                                        (multiplier_aclr2 == "UNREGISTERED")? 1'b0:
                                        (multiplier_aclr2 == "ACLR0")? aclr0:
                                        (multiplier_aclr2 == "ACLR1")? aclr1:
                                        (multiplier_aclr2 == "ACLR2")? aclr2: 1'b0;




    assign multiplier_reg3_wire_clr =   (multiplier_aclr3 == "ACLR3")? aclr3:
                                        (multiplier_aclr3 == "UNREGISTERED")? 1'b0:
                                        (multiplier_aclr3 == "ACLR0")? aclr0:
                                        (multiplier_aclr3 == "ACLR1")? aclr1:
                                        (multiplier_aclr3 == "ACLR2")? aclr2: 1'b0;




    assign output_reg_wire_clr =    (output_aclr == "ACLR3")? aclr3:
                                    (output_aclr == "UNREGISTERED")? 1'b0:
                                    (output_aclr == "ACLR0")? aclr0:
                                    (output_aclr == "ACLR1")? aclr1:
                                    (output_aclr == "ACLR2")? aclr2: 1'b0;



    assign addnsub1_round_wire_clr =    (addnsub1_round_aclr == "ACLR3")? aclr3:
                                        (addnsub1_round_register == "UNREGISTERED")? 1'b0:
                                        (addnsub1_round_aclr == "ACLR0")? aclr0:
                                        (addnsub1_round_aclr == "ACLR1")? aclr1:
                                        (addnsub1_round_aclr == "ACLR2")? aclr2: 1'b0;



    assign addnsub1_round_pipe_wire_clr =   (addnsub1_round_pipeline_aclr == "ACLR3")? aclr3:
                                            (addnsub1_round_pipeline_register == "UNREGISTERED")? 1'b0:
                                            (addnsub1_round_pipeline_aclr == "ACLR0")? aclr0:
                                            (addnsub1_round_pipeline_aclr == "ACLR1")? aclr1:
                                            (addnsub1_round_pipeline_aclr == "ACLR2")? aclr2: 1'b0;



    assign addnsub3_round_wire_clr =    (addnsub3_round_aclr == "ACLR3")? aclr3:
                                        (addnsub3_round_register == "UNREGISTERED")? 1'b0:
                                        (addnsub3_round_aclr == "ACLR0")? aclr0:
                                        (addnsub3_round_aclr == "ACLR1")? aclr1:
                                        (addnsub3_round_aclr == "ACLR2")? aclr2: 1'b0;



    assign addnsub3_round_pipe_wire_clr =   (addnsub3_round_pipeline_aclr == "ACLR3")? aclr3:
                                            (addnsub3_round_pipeline_register == "UNREGISTERED")? 1'b0:
                                            (addnsub3_round_pipeline_aclr == "ACLR0")? aclr0:
                                            (addnsub3_round_pipeline_aclr == "ACLR1")? aclr1:
                                            (addnsub3_round_pipeline_aclr == "ACLR2")? aclr2: 1'b0;



    assign mult01_round_wire_clr =  (mult01_round_aclr == "ACLR3")? aclr3:
                                    (mult01_round_register == "UNREGISTERED")? 1'b0:
                                    (mult01_round_aclr == "ACLR0")? aclr0:
                                    (mult01_round_aclr == "ACLR1")? aclr1:
                                    (mult01_round_aclr == "ACLR2")? aclr2: 1'b0;



    assign mult01_saturate_wire_clr =   (mult01_saturation_aclr == "ACLR3")? aclr3:
                                        (mult01_saturation_register == "UNREGISTERED")? 1'b0:
                                        (mult01_saturation_aclr == "ACLR0")? aclr0:
                                        (mult01_saturation_aclr == "ACLR1")? aclr1:
                                        (mult01_saturation_aclr == "ACLR2")? aclr2: 1'b0;



    assign mult23_round_wire_clr =  (mult23_round_aclr == "ACLR3")? aclr3:
                                    (mult23_round_register == "UNREGISTERED")? 1'b0:
                                    (mult23_round_aclr == "ACLR0")? aclr0:
                                    (mult23_round_aclr == "ACLR1")? aclr1:
                                    (mult23_round_aclr == "ACLR2")? aclr2: 1'b0;



    assign mult23_saturate_wire_clr =   (mult23_saturation_aclr == "ACLR3")? aclr3:
                                        (mult23_saturation_register == "UNREGISTERED")? 1'b0:
                                        (mult23_saturation_aclr == "ACLR0")? aclr0:
                                        (mult23_saturation_aclr == "ACLR1")? aclr1:
                                        (mult23_saturation_aclr == "ACLR2")? aclr2: 1'b0;

    assign outround_reg_wire_clr =  (output_round_aclr == "ACLR0") ? aclr0:
                                    (output_round_aclr == "NONE") ? 1'b0:
                                    (output_round_aclr == "ACLR1") ? aclr1:
                                    (output_round_aclr == "ACLR2") ? aclr2:
                                    (output_round_aclr == "ACLR3") ? aclr3 : 1'b0;

    assign outround_pipe_wire_clr = (output_round_pipeline_aclr == "ACLR0") ? aclr0:
                                    (output_round_pipeline_aclr == "NONE") ? 1'b0:
                                    (output_round_pipeline_aclr == "ACLR1") ? aclr1:
                                    (output_round_pipeline_aclr == "ACLR2") ? aclr2:
                                    (output_round_pipeline_aclr == "ACLR3") ? aclr3 : 1'b0;

    assign chainout_round_reg_wire_clr =    (chainout_round_aclr == "ACLR0") ? aclr0:
                                            (chainout_round_aclr == "NONE") ? 1'b0:
                                            (chainout_round_aclr == "ACLR1") ? aclr1:
                                            (chainout_round_aclr == "ACLR2") ? aclr2:
                                            (chainout_round_aclr == "ACLR3") ? aclr3 : 1'b0;

    assign chainout_round_pipe_wire_clr =   (chainout_round_pipeline_aclr == "ACLR0") ? aclr0:
                                            (chainout_round_pipeline_aclr == "NONE") ? 1'b0:
                                            (chainout_round_pipeline_aclr == "ACLR1") ? aclr1:
                                            (chainout_round_pipeline_aclr == "ACLR2") ? aclr2:
                                            (chainout_round_pipeline_aclr == "ACLR3") ? aclr3 : 1'b0;

    assign chainout_round_out_reg_wire_clr =    (chainout_round_output_aclr == "ACLR0") ? aclr0:
                                                (chainout_round_output_aclr == "NONE") ? 1'b0:
                                                (chainout_round_output_aclr == "ACLR1") ? aclr1:
                                                (chainout_round_output_aclr == "ACLR2") ? aclr2:
                                                (chainout_round_output_aclr == "ACLR3") ? aclr3 : 1'b0;

    assign outsat_reg_wire_clr =  (output_saturate_aclr == "ACLR0") ? aclr0:
                                    (output_saturate_aclr == "NONE") ? 1'b0:
                                    (output_saturate_aclr == "ACLR1") ? aclr1:
                                    (output_saturate_aclr == "ACLR2") ? aclr2:
                                    (output_saturate_aclr == "ACLR3") ? aclr3 : 1'b0;

    assign outsat_pipe_wire_clr = (output_saturate_pipeline_aclr == "ACLR0") ? aclr0:
                                    (output_saturate_pipeline_aclr == "NONE") ? 1'b0:
                                    (output_saturate_pipeline_aclr == "ACLR1") ? aclr1:
                                    (output_saturate_pipeline_aclr == "ACLR2") ? aclr2:
                                    (output_saturate_pipeline_aclr == "ACLR3") ? aclr3 : 1'b0;

    assign chainout_sat_reg_wire_clr =    (chainout_saturate_aclr == "ACLR0") ? aclr0:
                                            (chainout_saturate_aclr == "NONE") ? 1'b0:
                                            (chainout_saturate_aclr == "ACLR1") ? aclr1:
                                            (chainout_saturate_aclr == "ACLR2") ? aclr2:
                                            (chainout_saturate_aclr == "ACLR3") ? aclr3 : 1'b0;

    assign chainout_sat_pipe_wire_clr =   (chainout_saturate_pipeline_aclr == "ACLR0") ? aclr0:
                                            (chainout_saturate_pipeline_aclr == "NONE") ? 1'b0:
                                            (chainout_saturate_pipeline_aclr == "ACLR1") ? aclr1:
                                            (chainout_saturate_pipeline_aclr == "ACLR2") ? aclr2:
                                            (chainout_saturate_pipeline_aclr == "ACLR3") ? aclr3 : 1'b0;

    assign chainout_sat_out_reg_wire_clr =    (chainout_saturate_output_aclr == "ACLR0") ? aclr0:
                                                (chainout_saturate_output_aclr == "NONE") ? 1'b0:
                                                (chainout_saturate_output_aclr == "ACLR1") ? aclr1:
                                                (chainout_saturate_output_aclr == "ACLR2") ? aclr2:
                                                (chainout_saturate_output_aclr == "ACLR3") ? aclr3 : 1'b0;

    assign scanouta_reg_wire_clr =  (scanouta_aclr == "ACLR0") ? aclr0:
                                    (scanouta_aclr == "NONE") ? 1'b0:
                                    (scanouta_aclr == "ACLR1") ? aclr1:
                                    (scanouta_aclr == "ACLR2") ? aclr2:
                                    (scanouta_aclr == "ACLR3") ? aclr3 : 1'b0;

    assign chainout_reg_wire_clr =  (chainout_aclr == "ACLR0") ? aclr0:
                                    (chainout_aclr == "NONE") ? 1'b0:
                                    (chainout_aclr == "ACLR1") ? aclr1:
                                    (chainout_aclr == "ACLR2") ? aclr2:
                                    (chainout_aclr == "ACLR3") ? aclr3 : 1'b0;

    assign zerochainout_reg_wire_clr =  (zero_chainout_output_register == "ACLR0") ? aclr0:
                                        (zero_chainout_output_register == "NONE") ? 1'b0:
                                        (zero_chainout_output_register == "ACLR1") ? aclr1:
                                        (zero_chainout_output_register == "ACLR2") ? aclr2:
                                        (zero_chainout_output_register == "ACLR3") ? aclr3 : 1'b0;

    assign rotate_reg_wire_clr =    (rotate_aclr == "ACLR0") ? aclr0:
                                    (rotate_aclr == "NONE") ? 1'b0:
                                    (rotate_aclr == "ACLR1") ? aclr1:
                                    (rotate_aclr == "ACLR2") ? aclr2:
                                    (rotate_aclr == "ACLR3") ? aclr3 : 1'b0;

    assign rotate_pipe_wire_clr =   (rotate_pipeline_aclr == "ACLR0") ? aclr0:
                                    (rotate_pipeline_aclr == "NONE") ? 1'b0:
                                    (rotate_pipeline_aclr == "ACLR1") ? aclr1:
                                    (rotate_pipeline_aclr == "ACLR2") ? aclr2:
                                    (rotate_pipeline_aclr == "ACLR3") ? aclr3 : 1'b0;

    assign rotate_out_reg_wire_clr =    (rotate_output_aclr == "ACLR0") ? aclr0:
                                        (rotate_output_aclr == "NONE") ? 1'b0:
                                        (rotate_output_aclr == "ACLR1") ? aclr1:
                                        (rotate_output_aclr == "ACLR2") ? aclr2:
                                        (rotate_output_aclr == "ACLR3") ? aclr3 : 1'b0;

    assign shiftr_reg_wire_clr =    (shift_right_aclr == "ACLR0") ? aclr0:
                                    (shift_right_aclr == "NONE") ? 1'b0:
                                    (shift_right_aclr == "ACLR1") ? aclr1:
                                    (shift_right_aclr == "ACLR2") ? aclr2:
                                    (shift_right_aclr == "ACLR3") ? aclr3 : 1'b0;

    assign shiftr_pipe_wire_clr =   (shift_right_pipeline_aclr == "ACLR0") ? aclr0:
                                    (shift_right_pipeline_aclr == "NONE") ? 1'b0:
                                    (shift_right_pipeline_aclr == "ACLR1") ? aclr1:
                                    (shift_right_pipeline_aclr == "ACLR2") ? aclr2:
                                    (shift_right_pipeline_aclr == "ACLR3") ? aclr3 : 1'b0;

    assign shiftr_out_reg_wire_clr =    (shift_right_output_aclr == "ACLR0") ? aclr0:
                                        (shift_right_output_aclr == "NONE") ? 1'b0:
                                        (shift_right_output_aclr == "ACLR1") ? aclr1:
                                        (shift_right_output_aclr == "ACLR2") ? aclr2:
                                        (shift_right_output_aclr == "ACLR3") ? aclr3 : 1'b0;

    assign zeroloopback_reg_wire_clr =  (zero_loopback_aclr == "ACLR0") ? aclr0 :
                                        (zero_loopback_aclr == "NONE") ? 1'b0:
                                        (zero_loopback_aclr == "ACLR1") ? aclr1 :
                                        (zero_loopback_aclr == "ACLR2") ? aclr2 :
                                        (zero_loopback_aclr == "ACLR3") ? aclr3 : 1'b0;

    assign zeroloopback_pipe_wire_clr = (zero_loopback_pipeline_aclr == "ACLR0") ? aclr0 :
                                        (zero_loopback_pipeline_aclr == "NONE") ? 1'b0:
                                        (zero_loopback_pipeline_aclr == "ACLR1") ? aclr1 :
                                        (zero_loopback_pipeline_aclr == "ACLR2") ? aclr2 :
                                        (zero_loopback_pipeline_aclr == "ACLR3") ? aclr3 : 1'b0;

    assign zeroloopback_out_wire_clr =  (zero_loopback_output_aclr == "ACLR0") ? aclr0 :
                                        (zero_loopback_output_aclr == "NONE") ? 1'b0:
                                        (zero_loopback_output_aclr == "ACLR1") ? aclr1 :
                                        (zero_loopback_output_aclr == "ACLR2") ? aclr2 :
                                        (zero_loopback_output_aclr == "ACLR3") ? aclr3 : 1'b0;

    assign accumsload_reg_wire_clr =    (accum_sload_aclr == "ACLR0") ? aclr0 :
                                        (accum_sload_aclr == "NONE") ? 1'b0:
                                        (accum_sload_aclr == "ACLR1") ? aclr1 :
                                        (accum_sload_aclr == "ACLR2") ? aclr2 :
                                        (accum_sload_aclr == "ACLR3") ? aclr3 : 1'b0;

    assign accumsload_pipe_wire_clr =   (accum_sload_pipeline_aclr == "ACLR0") ? aclr0 :
                                        (accum_sload_pipeline_aclr == "NONE") ? 1'b0:
                                        (accum_sload_pipeline_aclr == "ACLR1") ? aclr1 :
                                        (accum_sload_pipeline_aclr == "ACLR2") ? aclr2 :
                                        (accum_sload_pipeline_aclr == "ACLR3") ? aclr3 : 1'b0;

	assign coeffsela_reg_wire_clr =  (coefsel0_aclr == "ACLR0") ? aclr0 :
                                     (coefsel0_aclr == "NONE") ? 1'b0:
                                     (coefsel0_aclr == "ACLR1") ? aclr1 : 1'b0;

	assign coeffselb_reg_wire_clr =  (coefsel1_aclr == "ACLR0") ? aclr0 :
                                     (coefsel1_aclr == "NONE") ? 1'b0:
                                     (coefsel1_aclr == "ACLR1") ? aclr1 : 1'b0;

	assign coeffselc_reg_wire_clr =  (coefsel2_aclr == "ACLR0") ? aclr0 :
                                     (coefsel2_aclr == "NONE") ? 1'b0:
                                     (coefsel2_aclr == "ACLR1") ? aclr1 : 1'b0;

	assign coeffseld_reg_wire_clr =  (coefsel3_aclr == "ACLR0") ? aclr0 :
                                     (coefsel3_aclr == "NONE") ? 1'b0:
                                     (coefsel3_aclr == "ACLR1") ? aclr1 : 1'b0;

	assign systolic1_reg_wire_clr =  (systolic_aclr1 == "ACLR0") ? aclr0 :
                                     (systolic_aclr1 == "NONE") ? 1'b0:
                                     (systolic_aclr1 == "ACLR1") ? aclr1 : 1'b0;

	assign systolic3_reg_wire_clr =  (systolic_aclr3 == "ACLR0") ? aclr0 :
                                     (systolic_aclr3 == "NONE") ? 1'b0:
                                     (systolic_aclr3 == "ACLR1") ? aclr1 : 1'b0;

    // -------------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set mult_a[int_width_a-1:0])
    // Signal Registered : mult_a_pre[int_width_a-1:0]
    //
    // Register is controlled by posedge input_reg_a0_wire_clk
    // Register has a clock enable input_reg_a0_wire_en
    // Register has an asynchronous clear signal, input_reg_a0_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        input_register_a0 is unregistered and mult_a_pre[int_width_a-1:0] changes value
    // -------------------------------------------------------------------------------------
    assign mult_a_wire[int_width_a-1:0] =   (input_register_a0 == "UNREGISTERED")?
                                            mult_a_pre[int_width_a-1:0]: mult_a_reg[int_width_a-1:0];
    always @(posedge input_reg_a0_wire_clk or posedge input_reg_a0_wire_clr)
    begin
            if (input_reg_a0_wire_clr == 1)
                mult_a_reg[int_width_a-1:0] <= 0;
            else if ((input_reg_a0_wire_clk === 1'b1) && (input_reg_a0_wire_en == 1))
                mult_a_reg[int_width_a-1:0] <= mult_a_pre[int_width_a-1:0];
    end


    // -----------------------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set mult_a[(2*int_width_a)-1:int_width_a])
    // Signal Registered : mult_a_pre[(2*int_width_a)-1:int_width_a]
    //
    // Register is controlled by posedge input_reg_a1_wire_clk
    // Register has a clock enable input_reg_a1_wire_en
    // Register has an asynchronous clear signal, input_reg_a1_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        input_register_a1 is unregistered and mult_a_pre[(2*int_width_a)-1:int_width_a] changes value
    // -----------------------------------------------------------------------------------------------

    assign  mult_a_wire[(2*int_width_a)-1:int_width_a] = (input_register_a1 == "UNREGISTERED")?
                                    mult_a_pre[(2*int_width_a)-1:int_width_a]: mult_a_reg[(2*int_width_a)-1:int_width_a];

    always @(posedge input_reg_a1_wire_clk or posedge input_reg_a1_wire_clr)

    begin
            if (input_reg_a1_wire_clr == 1)
                mult_a_reg[(2*int_width_a)-1:int_width_a] <= 0;
            else if ((input_reg_a1_wire_clk == 1) && (input_reg_a1_wire_en == 1))
                mult_a_reg[(2*int_width_a)-1:int_width_a] <= mult_a_pre[(2*int_width_a)-1:int_width_a];
    end


    // -------------------------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set mult_a[(3*int_width_a)-1:2*int_width_a])
    // Signal Registered : mult_a_pre[(3*int_width_a)-1:2*int_width_a]
    //
    // Register is controlled by posedge input_reg_a2_wire_clk
    // Register has a clock enable input_reg_a2_wire_en
    // Register has an asynchronous clear signal, input_reg_a2_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        input_register_a2 is unregistered and mult_a_pre[(3*int_width_a)-1:2*int_width_a] changes value
    // -------------------------------------------------------------------------------------------------
    assign  mult_a_wire[(3*int_width_a)-1 : 2*int_width_a ] = (input_register_a2 == "UNREGISTERED")?
                            mult_a_pre[(3*int_width_a)-1 : 2*int_width_a]: mult_a_reg[(3*int_width_a)-1 : 2*int_width_a ];


    always @(posedge input_reg_a2_wire_clk or posedge input_reg_a2_wire_clr)
    begin
            if (input_reg_a2_wire_clr == 1)
                mult_a_reg[(3*int_width_a)-1 : 2*int_width_a ] <= 0;
            else if ((input_reg_a2_wire_clk == 1) && (input_reg_a2_wire_en == 1))
                mult_a_reg[(3*int_width_a)-1 : 2*int_width_a ] <= mult_a_pre[(3*int_width_a)-1 : 2*int_width_a];
    end


    // -------------------------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set mult_a[(4*int_width_a)-1:3*int_width_a])
    // Signal Registered : mult_a_pre[(4*int_width_a)-1:3*int_width_a]
    //
    // Register is controlled by posedge input_reg_a3_wire_clk
    // Register has a clock enable input_reg_a3_wire_en
    // Register has an asynchronous clear signal, input_reg_a3_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        input_register_a3 is unregistered and mult_a_pre[(4*int_width_a)-1:3*int_width_a] changes value
    // -------------------------------------------------------------------------------------------------
    assign  mult_a_wire[(4*int_width_a)-1 : 3*int_width_a ] = (input_register_a3 == "UNREGISTERED")?
                                mult_a_pre[(4*int_width_a)-1:3*int_width_a]: mult_a_reg[(4*int_width_a)-1:3*int_width_a];

    always @(posedge input_reg_a3_wire_clk or posedge input_reg_a3_wire_clr)
    begin
            if (input_reg_a3_wire_clr == 1)
                mult_a_reg[(4*int_width_a)-1 : 3*int_width_a ] <= 0;
            else if ((input_reg_a3_wire_clk == 1) && (input_reg_a3_wire_en == 1))
                mult_a_reg[(4*int_width_a)-1 : 3*int_width_a ] <= mult_a_pre[(4*int_width_a)-1:3*int_width_a];

    end


    // -------------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set mult_b[int_width_b-1:0])
    // Signal Registered : mult_b_pre[int_width_b-1:0]
    //
    // Register is controlled by posedge input_reg_b0_wire_clk
    // Register has a clock enable input_reg_b0_wire_en
    // Register has an asynchronous clear signal, input_reg_b0_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        input_register_b0 is unregistered and mult_b_pre[int_width_b-1:0] changes value
    // -------------------------------------------------------------------------------------

    assign mult_b_wire[int_width_b-1:0] = (input_register_b0 == "UNREGISTERED")?
                                            mult_b_pre[int_width_b-1:0]: mult_b_reg[int_width_b-1:0];

    always @(posedge input_reg_b0_wire_clk or posedge input_reg_b0_wire_clr)
    begin
            if (input_reg_b0_wire_clr == 1)
                mult_b_reg[int_width_b-1:0] <= 0;
            else if ((input_reg_b0_wire_clk == 1) && (input_reg_b0_wire_en == 1))
                mult_b_reg[int_width_b-1:0] <= mult_b_pre[int_width_b-1:0];
    end


    // -----------------------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set mult_b[(2*int_width_b)-1:int_width_b])
    // Signal Registered : mult_b_pre[(2*int_width_b)-1:int_width_b]
    //
    // Register is controlled by posedge input_reg_a1_wire_clk
    // Register has a clock enable input_reg_b1_wire_en
    // Register has an asynchronous clear signal, input_reg_b1_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        input_register_b1 is unregistered and mult_b_pre[(2*int_width_b)-1:int_width_b] changes value
    // -----------------------------------------------------------------------------------------------
    assign mult_b_wire[(2*int_width_b)-1:int_width_b] = (input_register_b1 == "UNREGISTERED")?
                                    mult_b_pre[(2*int_width_b)-1:int_width_b]: mult_b_reg[(2*int_width_b)-1:int_width_b];



    always @(posedge input_reg_b1_wire_clk or posedge input_reg_b1_wire_clr)
    begin
            if (input_reg_b1_wire_clr == 1)
                mult_b_reg[(2*int_width_b)-1:int_width_b] <= 0;
            else if ((input_reg_b1_wire_clk == 1) && (input_reg_b1_wire_en == 1))
                mult_b_reg[(2*int_width_b)-1:int_width_b] <= mult_b_pre[(2*int_width_b)-1:int_width_b];

    end


    // -------------------------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set mult_b[(3*int_width_b)-1:2*int_width_b])
    // Signal Registered : mult_b_pre[(3*int_width_b)-1:2*int_width_b]
    //
    // Register is controlled by posedge input_reg_b2_wire_clk
    // Register has a clock enable input_reg_b2_wire_en
    // Register has an asynchronous clear signal, input_reg_b2_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        input_register_b2 is unregistered and mult_b_pre[(3*int_width_b)-1:2*int_width_b] changes value
    // -------------------------------------------------------------------------------------------------
    assign mult_b_wire[(3*int_width_b)-1:2*int_width_b] = (input_register_b2 == "UNREGISTERED")?
                                mult_b_pre[(3*int_width_b)-1:2*int_width_b]: mult_b_reg[(3*int_width_b)-1:2*int_width_b];


    always @(posedge input_reg_b2_wire_clk or posedge input_reg_b2_wire_clr)
    begin
            if (input_reg_b2_wire_clr == 1)
                mult_b_reg[(3*int_width_b)-1:2*int_width_b] <= 0;
            else if ((input_reg_b2_wire_clk == 1) && (input_reg_b2_wire_en == 1))
                mult_b_reg[(3*int_width_b)-1:2*int_width_b] <= mult_b_pre[(3*int_width_b)-1:2*int_width_b];

    end


    // -------------------------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set mult_b[(4*int_width_b)-1:3*int_width_b])
    // Signal Registered : mult_b_pre[(4*int_width_b)-1:3*int_width_b]
    //
    // Register is controlled by posedge input_reg_b3_wire_clk
    // Register has a clock enable input_reg_b3_wire_en
    // Register has an asynchronous clear signal, input_reg_b3_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        input_register_b3 is unregistered and mult_b_pre[(4*int_width_b)-1:3*int_width_b] changes value
    // -------------------------------------------------------------------------------------------------
    assign mult_b_wire[(4*int_width_b)-1:3*int_width_b] = (input_register_b3 == "UNREGISTERED")?
                                mult_b_pre[(4*int_width_b)-1:3*int_width_b]: mult_b_reg[(4*int_width_b)-1:3*int_width_b];


    always @(posedge input_reg_b3_wire_clk or posedge input_reg_b3_wire_clr)
    begin
            if (input_reg_b3_wire_clr == 1)
                mult_b_reg[(4*int_width_b)-1 : 3*int_width_b ] <= 0;
            else if ((input_reg_b3_wire_clk == 1) && (input_reg_b3_wire_en == 1))
                mult_b_reg[(4*int_width_b)-1:3*int_width_b] <= mult_b_pre[(4*int_width_b)-1:3*int_width_b];

    end

    // -------------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set mult_c[int_width_c-1:0])
    // Signal Registered : mult_c_pre[int_width_c-1:0]
    //
    // Register is controlled by posedge input_reg_c0_wire_clk
    // Register has a clock enable input_reg_c0_wire_en
    // Register has an asynchronous clear signal, input_reg_c0_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        input_register_c0 is unregistered and mult_c_pre[int_width_c-1:0] changes value
    // -------------------------------------------------------------------------------------

    assign mult_c_wire[int_width_c-1:0] = (input_register_c0 == "UNREGISTERED")?
                                            mult_c_pre[int_width_c-1:0]: mult_c_reg[int_width_c-1:0];

    always @(posedge input_reg_c0_wire_clk or posedge input_reg_c0_wire_clr)
    begin
            if (input_reg_c0_wire_clr == 1)
                mult_c_reg[int_width_c-1:0] <= 0;
            else if ((input_reg_c0_wire_clk == 1) && (input_reg_c0_wire_en == 1))
                mult_c_reg[int_width_c-1:0] <= mult_c_pre[int_width_c-1:0];
    end

    // -------------------------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set mult01_round_wire)
    // Signal Registered : mult01_round_pre
    //
    // Register is controlled by posedge mult01_round_wire_clk
    // Register has a clock enable mult01_round_wire_en
    // Register has an asynchronous clear signal, mult01_round_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        mult01_round_register is unregistered and mult01_round changes value
    // -------------------------------------------------------------------------------------------------
    assign mult01_round_wire = (mult01_round_register == "UNREGISTERED")?
                                mult01_round_pre : mult01_round_reg;

    always @(posedge mult01_round_wire_clk or posedge mult01_round_wire_clr)
    begin
            if (mult01_round_wire_clr == 1)
                mult01_round_reg <= 0;
            else if ((mult01_round_wire_clk == 1) && (mult01_round_wire_en == 1))
                mult01_round_reg <= mult01_round_pre;

    end

    // -------------------------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set mult01_saturate_wire)
    // Signal Registered : mult01_saturation_pre
    //
    // Register is controlled by posedge mult01_saturate_wire_clk
    // Register has a clock enable mult01_saturate_wire_en
    // Register has an asynchronous clear signal, mult01_saturate_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        mult01_saturation_register is unregistered and mult01_saturate_pre changes value
    // -------------------------------------------------------------------------------------------------
    assign mult01_saturate_wire = (mult01_saturation_register == "UNREGISTERED")?
                                    mult01_saturate_pre : mult01_saturate_reg;

    always @(posedge mult01_saturate_wire_clk or posedge mult01_saturate_wire_clr)
    begin
            if (mult01_saturate_wire_clr == 1)
                mult01_saturate_reg <= 0;
            else if ((mult01_saturate_wire_clk == 1) && (mult01_saturate_wire_en == 1))
                mult01_saturate_reg <= mult01_saturate_pre;

    end

    // -------------------------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set mult23_round_wire)
    // Signal Registered : mult23_round_pre
    //
    // Register is controlled by posedge mult23_round_wire_clk
    // Register has a clock enable mult23_round_wire_en
    // Register has an asynchronous clear signal, mult23_round_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        mult23_round_register is unregistered and mult23_round_pre changes value
    // -------------------------------------------------------------------------------------------------
    assign mult23_round_wire = (mult23_round_register == "UNREGISTERED")?
                                mult23_round_pre : mult23_round_reg;

    always @(posedge mult23_round_wire_clk or posedge mult23_round_wire_clr)
    begin
            if (mult23_round_wire_clr == 1)
                mult23_round_reg <= 0;
            else if ((mult23_round_wire_clk == 1) && (mult23_round_wire_en == 1))
                mult23_round_reg <= mult23_round_pre;

    end

    // -------------------------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set mult23_saturate_wire)
    // Signal Registered : mult23_round_pre
    //
    // Register is controlled by posedge mult23_saturate_wire_clk
    // Register has a clock enable mult23_saturate_wire_en
    // Register has an asynchronous clear signal, mult23_saturate_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        mult23_saturation_register is unregistered and mult23_saturation_pre changes value
    // -------------------------------------------------------------------------------------------------
    assign mult23_saturate_wire =   (mult23_saturation_register == "UNREGISTERED")?
                                    mult23_saturate_pre : mult23_saturate_reg;

    always @(posedge mult23_saturate_wire_clk or posedge mult23_saturate_wire_clr)
    begin
            if (mult23_saturate_wire_clr == 1)
                mult23_saturate_reg <= 0;
            else if ((mult23_saturate_wire_clk == 1) && (mult23_saturate_wire_en == 1))
                mult23_saturate_reg <= mult23_saturate_pre;

    end

    // ---------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set addnsub1_round_wire)
    // Signal Registered : addnsub1_round_pre
    //
    // Register is controlled by posedge addnsub1_round_wire_clk
    // Register has a clock enable addnsub1_round_wire_en
    // Register has an asynchronous clear signal, addnsub1_round_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        addnsub1_round_register is unregistered and addnsub1_round_pre changes value
    // ---------------------------------------------------------------------------------
    assign addnsub1_round_wire =    (addnsub1_round_register=="UNREGISTERED")?
                                    addnsub1_round_pre : addnsub1_round_reg;

    always @(posedge addnsub1_round_wire_clk or posedge addnsub1_round_wire_clr)
    begin
            if (addnsub1_round_wire_clr == 1)
                addnsub1_round_reg <= 0;
            else if ((addnsub1_round_wire_clk == 1) && (addnsub1_round_wire_en == 1))
                addnsub1_round_reg <= addnsub1_round_pre;
    end

    // ---------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set addnsub1_round_pipe_wire)
    // Signal Registered : addnsub1_round_wire
    //
    // Register is controlled by posedge addnsub1_round_pipe_wire_clk
    // Register has a clock enable addnsub1_round_pipe_wire_en
    // Register has an asynchronous clear signal, addnsub1_round_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        addnsub1_round_pipeline_register is unregistered and addnsub1_round_wire changes value
    // ---------------------------------------------------------------------------------
    assign addnsub1_round_pipe_wire = (addnsub1_round_pipeline_register=="UNREGISTERED")?
                                        addnsub1_round_wire : addnsub1_round_pipe_reg;

    always @(posedge addnsub1_round_pipe_wire_clk or posedge addnsub1_round_pipe_wire_clr)
    begin
            if (addnsub1_round_pipe_wire_clr == 1)
                addnsub1_round_pipe_reg <= 0;
            else if ((addnsub1_round_pipe_wire_clk == 1) && (addnsub1_round_pipe_wire_en == 1))
                addnsub1_round_pipe_reg <= addnsub1_round_wire;
    end

    // ---------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set addnsub3_round_wire)
    // Signal Registered : addnsub3_round_pre
    //
    // Register is controlled by posedge addnsub3_round_wire_clk
    // Register has a clock enable addnsub3_round_wire_en
    // Register has an asynchronous clear signal, addnsub3_round_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        addnsub3_round_register is unregistered and addnsub3_round_pre changes value
    // ---------------------------------------------------------------------------------
    assign addnsub3_round_wire = (addnsub3_round_register=="UNREGISTERED")?
                                    addnsub3_round_pre : addnsub3_round_reg;

    always @(posedge addnsub3_round_wire_clk or posedge addnsub3_round_wire_clr)
    begin
            if (addnsub3_round_wire_clr == 1)
                addnsub3_round_reg <= 0;
            else if ((addnsub3_round_wire_clk == 1) && (addnsub3_round_wire_en == 1))
                addnsub3_round_reg <= addnsub3_round_pre;
    end

    // ---------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set addnsub3_round_pipe_wire)
    // Signal Registered : addnsub3_round_wire
    //
    // Register is controlled by posedge addnsub3_round_pipe_wire_clk
    // Register has a clock enable addnsub3_round_pipe_wire_en
    // Register has an asynchronous clear signal, addnsub3_round_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        addnsub3_round_pipeline_register is unregistered and addnsub3_round_wire changes value
    // ---------------------------------------------------------------------------------
    assign addnsub3_round_pipe_wire = (addnsub3_round_pipeline_register=="UNREGISTERED")?
                                        addnsub3_round_wire : addnsub3_round_pipe_reg;

    always @(posedge addnsub3_round_pipe_wire_clk or posedge addnsub3_round_pipe_wire_clr)
    begin
            if (addnsub3_round_pipe_wire_clr == 1)
                addnsub3_round_pipe_reg <= 0;
            else if ((addnsub3_round_pipe_wire_clk == 1) && (addnsub3_round_pipe_wire_en == 1))
                addnsub3_round_pipe_reg <= addnsub3_round_wire;
    end


    // ---------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set addsub1_reg)
    // Signal Registered : addsub1_int
    //
    // Register is controlled by posedge addsub1_reg_wire_clk
    // Register has a clock enable addsub1_reg_wire_en
    // Register has an asynchronous clear signal, addsub1_reg_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        addnsub_multiplier_register1 is unregistered and addsub1_int changes value
    // ---------------------------------------------------------------------------------
    assign addsub1_wire = (addnsub_multiplier_register1=="UNREGISTERED")? addsub1_int : addsub1_reg;

    always @(posedge addsub1_reg_wire_clk or posedge addsub1_reg_wire_clr)
    begin
            if ((addsub1_reg_wire_clr == 1) && (addsub1_clr == 1))
                addsub1_reg <= 0;
            else if ((addsub1_reg_wire_clk == 1) && (addsub1_reg_wire_en == 1))
                addsub1_reg <= addsub1_int;
    end


    // -------------------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set addsub1_pipe)
    // Signal Registered : addsub1_reg
    //
    // Register is controlled by posedge addsub1_pipe_wire_clk
    // Register has a clock enable addsub1_pipe_wire_en
    // Register has an asynchronous clear signal, addsub1_pipe_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        addnsub_multiplier_pipeline_register1 is unregistered and addsub1_reg changes value
    // ------------------------------------------------------------------------------------------

    assign addsub1_pipe_wire = (addnsub_multiplier_pipeline_register1 == "UNREGISTERED")?
                                addsub1_wire : addsub1_pipe_reg;
    always @(posedge addsub1_pipe_wire_clk or posedge addsub1_pipe_wire_clr)
    begin
            if ((addsub1_pipe_wire_clr == 1) && (addsub1_clr == 1))
                addsub1_pipe_reg <= 0;
            else if ((addsub1_pipe_wire_clk == 1) && (addsub1_pipe_wire_en == 1))
                addsub1_pipe_reg <= addsub1_wire;
    end


    // ---------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set addsub3_reg)
    // Signal Registered : addsub3_int
    //
    // Register is controlled by posedge addsub3_reg_wire_clk
    // Register has a clock enable addsub3_reg_wire_en
    // Register has an asynchronous clear signal, addsub3_reg_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        addnsub_multiplier_register3 is unregistered and addsub3_int changes value
    // ---------------------------------------------------------------------------------
    assign addsub3_wire = (addnsub_multiplier_register3=="UNREGISTERED")?
                                addsub3_int : addsub3_reg;


    always @(posedge addsub3_reg_wire_clk or posedge addsub3_reg_wire_clr)
    begin
            if ((addsub3_reg_wire_clr == 1) && (addsub3_clr == 1))
                addsub3_reg <= 0;
            else if ((addsub3_reg_wire_clk == 1) && (addsub3_reg_wire_en == 1))
                addsub3_reg <= addsub3_int;
    end


    // -------------------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set addsub3_pipe)
    // Signal Registered : addsub3_reg
    //
    // Register is controlled by posedge addsub3_pipe_wire_clk
    // Register has a clock enable addsub3_pipe_wire_en
    // Register has an asynchronous clear signal, addsub3_pipe_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        addnsub_multiplier_pipeline_register3 is unregistered and addsub3_reg changes value
    // ------------------------------------------------------------------------------------------
    assign addsub3_pipe_wire = (addnsub_multiplier_pipeline_register3 == "UNREGISTERED")?
                                addsub3_wire  : addsub3_pipe_reg;

    always @(posedge addsub3_pipe_wire_clk or posedge addsub3_pipe_wire_clr)
    begin
            if ((addsub3_pipe_wire_clr == 1) && (addsub3_clr == 1))
                addsub3_pipe_reg <= 0;
            else if ((addsub3_pipe_wire_clk == 1) && (addsub3_pipe_wire_en == 1))
                addsub3_pipe_reg <= addsub3_wire;
    end


    // ----------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set sign_a_reg)
    // Signal Registered : sign_a_int
    //
    // Register is controlled by posedge sign_reg_a_wire_clk
    // Register has a clock enable sign_reg_a_wire_en
    // Register has an asynchronous clear signal, sign_reg_a_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        signed_register_a is unregistered and sign_a_int changes value
    // ----------------------------------------------------------------------------

    assign ena_aclr_signa_wire = ((port_signa == "PORT_USED") || ((port_signa == "PORT_CONNECTIVITY") && ((representation_a == "UNUSED") || (signa !==1'b0 /* converted x or z to 1'b0 */ )))) ? 1'b1 : 1'b0;
    assign sign_a_wire = (signed_register_a == "UNREGISTERED")? sign_a_int : sign_a_reg;
    always @(posedge sign_reg_a_wire_clk or posedge sign_reg_a_wire_clr)
    begin
            if ((sign_reg_a_wire_clr == 1) && (ena_aclr_signa_wire == 1'b1))
                sign_a_reg <= 0;
            else if ((sign_reg_a_wire_clk == 1) && (sign_reg_a_wire_en == 1))
                sign_a_reg <= sign_a_int;
    end


    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set sign_a_pipe)
    // Signal Registered : sign_a_reg
    //
    // Register is controlled by posedge sign_pipe_a_wire_clk
    // Register has a clock enable sign_pipe_a_wire_en
    // Register has an asynchronous clear signal, sign_pipe_a_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        signed_pipeline_register_a is unregistered and sign_a_reg changes value
    // ------------------------------------------------------------------------------

    assign sign_a_pipe_wire = (signed_pipeline_register_a == "UNREGISTERED")? sign_a_wire : sign_a_pipe_reg;
    always @(posedge sign_pipe_a_wire_clk or posedge sign_pipe_a_wire_clr)
    begin
            if ((sign_pipe_a_wire_clr == 1) && (ena_aclr_signa_wire == 1'b1))
                sign_a_pipe_reg <= 0;
            else if ((sign_pipe_a_wire_clk == 1) && (sign_pipe_a_wire_en == 1))
                sign_a_pipe_reg <= sign_a_wire;
    end


    // ----------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set sign_b_reg)
    // Signal Registered : sign_b_int
    //
    // Register is controlled by posedge sign_reg_b_wire_clk
    // Register has a clock enable sign_reg_b_wire_en
    // Register has an asynchronous clear signal, sign_reg_b_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        signed_register_b is unregistered and sign_b_int changes value
    // ----------------------------------------------------------------------------
    assign ena_aclr_signb_wire = ((port_signb == "PORT_USED") || ((port_signb == "PORT_CONNECTIVITY") && ((representation_b == "UNUSED") || (signb !==1'b0 /* converted x or z to 1'b0 */ )))) ? 1'b1 : 1'b0;
    assign sign_b_wire = (signed_register_b == "UNREGISTERED")? sign_b_int : sign_b_reg;

    always @(posedge sign_reg_b_wire_clk or posedge sign_reg_b_wire_clr)
    begin
            if ((sign_reg_b_wire_clr == 1) && (ena_aclr_signb_wire == 1'b1))
                sign_b_reg <= 0;
            else if ((sign_reg_b_wire_clk == 1) && (sign_reg_b_wire_en == 1))
                sign_b_reg <= sign_b_int;

    end


    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set sign_b_pipe)
    // Signal Registered : sign_b_reg
    //
    // Register is controlled by posedge sign_pipe_b_wire_clk
    // Register has a clock enable sign_pipe_b_wire_en
    // Register has an asynchronous clear signal, sign_pipe_b_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        signed_pipeline_register_b is unregistered and sign_b_reg changes value
    // ------------------------------------------------------------------------------
    assign sign_b_pipe_wire = (signed_pipeline_register_b == "UNREGISTERED")? sign_b_wire : sign_b_pipe_reg;
    always @(posedge sign_pipe_b_wire_clk or posedge sign_pipe_b_wire_clr)

    begin
            if ((sign_pipe_b_wire_clr == 1) && (ena_aclr_signb_wire == 1'b1))
                sign_b_pipe_reg <= 0;
            else if ((sign_pipe_b_wire_clk == 1) && (sign_pipe_b_wire_en == 1))
                sign_b_pipe_reg <= sign_b_wire;

    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set outround_reg/wire)
    // Signal Registered : outround_int
    //
    // Register is controlled by posedge outround_reg_wire_clk
    // Register has a clock enable outround_reg_wire_en
    // Register has an asynchronous clear signal, outround_reg_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        output_round_register is unregistered and outround_int changes value
    // ------------------------------------------------------------------------------
    assign outround_wire = (output_round_register == "UNREGISTERED")? outround_int : outround_reg;
    always @(posedge outround_reg_wire_clk or posedge outround_reg_wire_clr)

    begin
            if (outround_reg_wire_clr == 1)
                outround_reg <= 0;
            else if ((outround_reg_wire_clk == 1) && (outround_reg_wire_en == 1))
                outround_reg <= outround_int;

    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set outround_pipe_wire)
    // Signal Registered : outround_wire
    //
    // Register is controlled by posedge outround_pipe_wire_clk
    // Register has a clock enable outround_pipe_wire_en
    // Register has an asynchronous clear signal, outround_pipe_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        output_round_pipeline_register is unregistered and outround_wire changes value
    // ------------------------------------------------------------------------------
    assign outround_pipe_wire = (output_round_pipeline_register == "UNREGISTERED")? outround_wire : outround_pipe_reg;
    always @(posedge outround_pipe_wire_clk or posedge outround_pipe_wire_clr)

    begin
            if (outround_pipe_wire_clr == 1)
                outround_pipe_reg <= 0;
            else if ((outround_pipe_wire_clk == 1) && (outround_pipe_wire_en == 1))
                outround_pipe_reg <= outround_wire;

    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set chainout_round_reg/wire)
    // Signal Registered : chainout_round_int
    //
    // Register is controlled by posedge chainout_round_reg_wire_clk
    // Register has a clock enable chainout_round_reg_wire_en
    // Register has an asynchronous clear signal, chainout_round_reg_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        chainout_round_register is unregistered and chainout_round_int changes value
    // ------------------------------------------------------------------------------
    assign chainout_round_wire = (chainout_round_register == "UNREGISTERED")? chainout_round_int : chainout_round_reg;
    always @(posedge chainout_round_reg_wire_clk or posedge chainout_round_reg_wire_clr)

    begin
            if (chainout_round_reg_wire_clr == 1)
                chainout_round_reg <= 0;
            else if ((chainout_round_reg_wire_clk == 1) && (chainout_round_reg_wire_en == 1))
                chainout_round_reg <= chainout_round_int;

    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set chainout_round_pipe_reg/wire)
    // Signal Registered : chainout_round_wire
    //
    // Register is controlled by posedge chainout_round_pipe_wire_clk
    // Register has a clock enable chainout_round_pipe_wire_en
    // Register has an asynchronous clear signal, chainout_round_pipe_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        chainout_round_pipeline_register is unregistered and chainout_round_wire changes value
    // ------------------------------------------------------------------------------
    assign chainout_round_pipe_wire = (chainout_round_pipeline_register == "UNREGISTERED")? chainout_round_wire : chainout_round_pipe_reg;
    always @(posedge chainout_round_pipe_wire_clk or posedge chainout_round_pipe_wire_clr)

    begin
            if (chainout_round_pipe_wire_clr == 1)
                chainout_round_pipe_reg <= 0;
            else if ((chainout_round_pipe_wire_clk == 1) && (chainout_round_pipe_wire_en == 1))
                chainout_round_pipe_reg <= chainout_round_wire;

    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set chainout_round_out_reg/wire)
    // Signal Registered : chainout_round_pipe_wire
    //
    // Register is controlled by posedge chainout_round_out_reg_wire_clk
    // Register has a clock enable chainout_round_out_reg_wire_en
    // Register has an asynchronous clear signal, chainout_round_out_reg_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        chainout_round_output_register is unregistered and chainout_round_pipe_wire changes value
    // ------------------------------------------------------------------------------
    assign chainout_round_out_wire = (chainout_round_output_register == "UNREGISTERED")? chainout_round_pipe_wire : chainout_round_out_reg;
    always @(posedge chainout_round_out_reg_wire_clk or posedge chainout_round_out_reg_wire_clr)

    begin
            if (chainout_round_out_reg_wire_clr == 1)
                chainout_round_out_reg <= 0;
            else if ((chainout_round_out_reg_wire_clk == 1) && (chainout_round_out_reg_wire_en == 1))
                chainout_round_out_reg <= chainout_round_pipe_wire;

    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set outsat_reg/wire)
    // Signal Registered : outsat_int
    //
    // Register is controlled by posedge outsat_reg_wire_clk
    // Register has a clock enable outsat_reg_wire_en
    // Register has an asynchronous clear signal, outsat_reg_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        output_saturate_register is unregistered and outsat_int changes value
    // ------------------------------------------------------------------------------
    assign outsat_wire = (output_saturate_register == "UNREGISTERED")? outsat_int : outsat_reg;
    always @(posedge outsat_reg_wire_clk or posedge outsat_reg_wire_clr)

    begin
            if (outsat_reg_wire_clr == 1)
                outsat_reg <= 0;
            else if ((outsat_reg_wire_clk == 1) && (outsat_reg_wire_en == 1))
                outsat_reg <= outsat_int;

    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set outsat_pipe_wire)
    // Signal Registered : outsat_wire
    //
    // Register is controlled by posedge outsat_pipe_wire_clk
    // Register has a clock enable outsat_pipe_wire_en
    // Register has an asynchronous clear signal, outsat_pipe_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        output_saturate_pipeline_register is unregistered and outsat_wire changes value
    // ------------------------------------------------------------------------------
    assign outsat_pipe_wire = (output_saturate_pipeline_register == "UNREGISTERED")? outsat_wire : outsat_pipe_reg;
    always @(posedge outsat_pipe_wire_clk or posedge outsat_pipe_wire_clr)

    begin
            if (outsat_pipe_wire_clr == 1)
                outsat_pipe_reg <= 0;
            else if ((outsat_pipe_wire_clk == 1) && (outsat_pipe_wire_en == 1))
                outsat_pipe_reg <= outsat_wire;

    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set chainout_sat_reg/wire)
    // Signal Registered : chainout_sat_int
    //
    // Register is controlled by posedge chainout_sat_reg_wire_clk
    // Register has a clock enable chainout_sat_reg_wire_en
    // Register has an asynchronous clear signal, chainout_sat_reg_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        chainout_saturate_register is unregistered and chainout_sat_int changes value
    // ------------------------------------------------------------------------------
    assign chainout_sat_wire = (chainout_saturate_register == "UNREGISTERED")? chainout_sat_int : chainout_sat_reg;
    always @(posedge chainout_sat_reg_wire_clk or posedge chainout_sat_reg_wire_clr)

    begin
            if (chainout_sat_reg_wire_clr == 1)
                chainout_sat_reg <= 0;
            else if ((chainout_sat_reg_wire_clk == 1) && (chainout_sat_reg_wire_en == 1))
                chainout_sat_reg <= chainout_sat_int;

    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set chainout_sat_pipe_reg/wire)
    // Signal Registered : chainout_sat_wire
    //
    // Register is controlled by posedge chainout_sat_pipe_wire_clk
    // Register has a clock enable chainout_sat_pipe_wire_en
    // Register has an asynchronous clear signal, chainout_sat_pipe_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        chainout_saturate_pipeline_register is unregistered and chainout_sat_wire changes value
    // ------------------------------------------------------------------------------
    assign chainout_sat_pipe_wire = (chainout_saturate_pipeline_register == "UNREGISTERED")? chainout_sat_wire : chainout_sat_pipe_reg;
    always @(posedge chainout_sat_pipe_wire_clk or posedge chainout_sat_pipe_wire_clr)

    begin
            if (chainout_sat_pipe_wire_clr == 1)
                chainout_sat_pipe_reg <= 0;
            else if ((chainout_sat_pipe_wire_clk == 1) && (chainout_sat_pipe_wire_en == 1))
                chainout_sat_pipe_reg <= chainout_sat_wire;

    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set chainout_sat_out_reg/wire)
    // Signal Registered : chainout_sat_pipe_wire
    //
    // Register is controlled by posedge chainout_sat_out_reg_wire_clk
    // Register has a clock enable chainout_sat_out_reg_wire_en
    // Register has an asynchronous clear signal, chainout_sat_out_reg_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        chainout_saturate_output_register is unregistered and chainout_sat_pipe_wire changes value
    // ------------------------------------------------------------------------------
    assign chainout_sat_out_wire = (chainout_saturate_output_register == "UNREGISTERED")? chainout_sat_pipe_wire : chainout_sat_out_reg;
    always @(posedge chainout_sat_out_reg_wire_clk or posedge chainout_sat_out_reg_wire_clr)

    begin
            if (chainout_sat_out_reg_wire_clr == 1)
                chainout_sat_out_reg <= 0;
            else if ((chainout_sat_out_reg_wire_clk == 1) && (chainout_sat_out_reg_wire_en == 1))
                chainout_sat_out_reg <= chainout_sat_pipe_wire;

    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set scanouta_reg/wire)
    // Signal Registered : mult_a_wire
    //
    // Register is controlled by posedge scanouta_reg_wire_clk
    // Register has a clock enable scanouta_reg_wire_en
    // Register has an asynchronous clear signal, scanouta_reg_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        scanouta_register is unregistered and mult_a_wire changes value
    // ------------------------------------------------------------------------------

    assign scanouta_wire[int_width_a -1 : 0] =  (scanouta_register == "UNREGISTERED")?
                                                (chainout_adder == "YES" && (width_result > width_a + width_b + 8))?
                                                mult_a_wire[(number_of_multipliers * int_width_a) - 1 -  (int_width_a - width_a) : ((number_of_multipliers-1) * int_width_a)]:
                                                mult_a_wire[(number_of_multipliers * int_width_a) - 1 : ((number_of_multipliers-1) * int_width_a) + (int_width_a - width_a)]:
                                                scanouta_reg;

    always @(posedge scanouta_reg_wire_clk or posedge scanouta_reg_wire_clr)

    begin
            if (scanouta_reg_wire_clr == 1)
                scanouta_reg[int_width_a -1 : 0] <= 0;
            else if ((scanouta_reg_wire_clk == 1) && (scanouta_reg_wire_en == 1))
                if(chainout_adder == "YES" && (width_result > width_a + width_b + 8))
                    scanouta_reg[int_width_a - 1 : 0] <= mult_a_wire[(number_of_multipliers * int_width_a) - 1 -  (int_width_a - width_a) : ((number_of_multipliers-1) * int_width_a)];
                else
                scanouta_reg[int_width_a -1 : 0] <= mult_a_wire[(number_of_multipliers * int_width_a) - 1 : ((number_of_multipliers-1) * int_width_a) + (int_width_a - width_a)];
    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set zerochainout_reg/wire)
    // Signal Registered : zero_chainout_int
    //
    // Register is controlled by posedge zerochainout_reg_wire_clk
    // Register has a clock enable zerochainout_reg_wire_en
    // Register has an asynchronous clear signal, zerochainout_reg_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        zero_chainout_output_register is unregistered and zero_chainout_int changes value
    // ------------------------------------------------------------------------------
    assign zerochainout_wire = (zero_chainout_output_register == "UNREGISTERED")? zerochainout_int
                                : zerochainout_reg;
    always @(posedge zerochainout_reg_wire_clk or posedge zerochainout_reg_wire_clr)

    begin
            if (zerochainout_reg_wire_clr == 1)
                zerochainout_reg <= 0;
            else if ((zerochainout_reg_wire_clk == 1) && (zerochainout_reg_wire_en == 1))
                zerochainout_reg <= zerochainout_int;
    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set rotate_reg/wire)
    // Signal Registered : rotate_int
    //
    // Register is controlled by posedge rotate_reg_wire_clk
    // Register has a clock enable rotate_reg_wire_en
    // Register has an asynchronous clear signal, rotate_reg_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        rotate_register is unregistered and rotate_int changes value
    // ------------------------------------------------------------------------------
    assign rotate_wire = (rotate_register == "UNREGISTERED")? rotate_int
                                : rotate_reg;
    always @(posedge rotate_reg_wire_clk or posedge rotate_reg_wire_clr)

    begin
            if (rotate_reg_wire_clr == 1)
                rotate_reg <= 0;
            else if ((rotate_reg_wire_clk == 1) && (rotate_reg_wire_en == 1))
                rotate_reg <= rotate_int;
    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set rotate_pipe_reg/wire)
    // Signal Registered : rotate_wire
    //
    // Register is controlled by posedge rotate_pipe_wire_clk
    // Register has a clock enable rotate_pipe_wire_en
    // Register has an asynchronous clear signal, rotate_pipe_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        rotate_pipeline_register is unregistered and rotate_wire changes value
    // ------------------------------------------------------------------------------
    assign rotate_pipe_wire = (rotate_pipeline_register == "UNREGISTERED")? rotate_wire
                                : rotate_pipe_reg;
    always @(posedge rotate_pipe_wire_clk or posedge rotate_pipe_wire_clr)

    begin
            if (rotate_pipe_wire_clr == 1)
                rotate_pipe_reg <= 0;
            else if ((rotate_pipe_wire_clk == 1) && (rotate_pipe_wire_en == 1))
                rotate_pipe_reg <= rotate_wire;
    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set rotate_out_reg/wire)
    // Signal Registered : rotate_pipe_wire
    //
    // Register is controlled by posedge rotate_out_reg_wire_clk
    // Register has a clock enable rotate_out_reg_wire_en
    // Register has an asynchronous clear signal, rotate_out_reg_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        rotate_output_register is unregistered and rotate_pipe_wire changes value
    // ------------------------------------------------------------------------------
    assign rotate_out_wire = (rotate_output_register == "UNREGISTERED")? rotate_pipe_wire
                                : rotate_out_reg;
    always @(posedge rotate_out_reg_wire_clk or posedge rotate_out_reg_wire_clr)

    begin
            if (rotate_out_reg_wire_clr == 1)
                rotate_out_reg <= 0;
            else if ((rotate_out_reg_wire_clk == 1) && (rotate_out_reg_wire_en == 1))
                rotate_out_reg <= rotate_pipe_wire;
    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set shiftr_reg/wire)
    // Signal Registered : shiftr_int
    //
    // Register is controlled by posedge shiftr_reg_wire_clk
    // Register has a clock enable shiftr_reg_wire_en
    // Register has an asynchronous clear signal, shiftr_reg_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        shift_right_register is unregistered and shiftr_int changes value
    // ------------------------------------------------------------------------------
    assign shiftr_wire = (shift_right_register == "UNREGISTERED")? shiftr_int
                                : shiftr_reg;
    always @(posedge shiftr_reg_wire_clk or posedge shiftr_reg_wire_clr)

    begin
            if (shiftr_reg_wire_clr == 1)
                shiftr_reg <= 0;
            else if ((shiftr_reg_wire_clk == 1) && (shiftr_reg_wire_en == 1))
                shiftr_reg <= shiftr_int;
    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set shiftr_pipe_reg/wire)
    // Signal Registered : shiftr_wire
    //
    // Register is controlled by posedge shiftr_pipe_wire_clk
    // Register has a clock enable shiftr_pipe_wire_en
    // Register has an asynchronous clear signal, shiftr_pipe_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        shift_right_pipeline_register is unregistered and shiftr_wire changes value
    // ------------------------------------------------------------------------------
    assign shiftr_pipe_wire = (shift_right_pipeline_register == "UNREGISTERED")? shiftr_wire
                                : shiftr_pipe_reg;
    always @(posedge shiftr_pipe_wire_clk or posedge shiftr_pipe_wire_clr)

    begin
            if (shiftr_pipe_wire_clr == 1)
                shiftr_pipe_reg <= 0;
            else if ((shiftr_pipe_wire_clk == 1) && (shiftr_pipe_wire_en == 1))
                shiftr_pipe_reg <= shiftr_wire;
    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set shiftr_out_reg/wire)
    // Signal Registered : shiftr_pipe_wire
    //
    // Register is controlled by posedge shiftr_out_reg_wire_clk
    // Register has a clock enable shiftr_out_reg_wire_en
    // Register has an asynchronous clear signal, shiftr_out_reg_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        shift_right_output_register is unregistered and shiftr_pipe_wire changes value
    // ------------------------------------------------------------------------------
    assign shiftr_out_wire = (shift_right_output_register == "UNREGISTERED")? shiftr_pipe_wire
                                : shiftr_out_reg;
    always @(posedge shiftr_out_reg_wire_clk or posedge shiftr_out_reg_wire_clr)

    begin
            if (shiftr_out_reg_wire_clr == 1)
                shiftr_out_reg <= 0;
            else if ((shiftr_out_reg_wire_clk == 1) && (shiftr_out_reg_wire_en == 1))
                shiftr_out_reg <= shiftr_pipe_wire;
    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set zeroloopback_reg/wire)
    // Signal Registered : zeroloopback_int
    //
    // Register is controlled by posedge zeroloopback_reg_wire_clk
    // Register has a clock enable zeroloopback_reg_wire_en
    // Register has an asynchronous clear signal, zeroloopback_reg_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        zero_loopback_register is unregistered and zeroloopback_int changes value
    // ------------------------------------------------------------------------------
    assign zeroloopback_wire = (zero_loopback_register == "UNREGISTERED")? zeroloopback_int
                                : zeroloopback_reg;
    always @(posedge zeroloopback_reg_wire_clk or posedge zeroloopback_reg_wire_clr)
    begin
            if (zeroloopback_reg_wire_clr == 1)
                zeroloopback_reg <= 0;
            else if ((zeroloopback_reg_wire_clk == 1) && (zeroloopback_reg_wire_en == 1))
                zeroloopback_reg <= zeroloopback_int;
    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set zeroloopback_pipe_reg/wire)
    // Signal Registered : zeroloopback_wire
    //
    // Register is controlled by posedge zeroloopback_pipe_wire_clk
    // Register has a clock enable zeroloopback_pipe_wire_en
    // Register has an asynchronous clear signal, zeroloopback_pipe_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        zero_loopback_pipeline_register is unregistered and zeroloopback_wire changes value
    // ------------------------------------------------------------------------------
    assign zeroloopback_pipe_wire = (zero_loopback_pipeline_register == "UNREGISTERED")? zeroloopback_wire
                                : zeroloopback_pipe_reg;
    always @(posedge zeroloopback_pipe_wire_clk or posedge zeroloopback_pipe_wire_clr)
    begin
            if (zeroloopback_pipe_wire_clr == 1)
                zeroloopback_pipe_reg <= 0;
            else if ((zeroloopback_pipe_wire_clk == 1) && (zeroloopback_pipe_wire_en == 1))
                zeroloopback_pipe_reg <= zeroloopback_wire;
    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set zeroloopback_out_reg/wire)
    // Signal Registered : zeroloopback_pipe_wire
    //
    // Register is controlled by posedge zeroloopback_out_wire_clk
    // Register has a clock enable zeroloopback_out_wire_en
    // Register has an asynchronous clear signal, zeroloopback_out_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        zero_loopback_output_register is unregistered and zeroloopback_pipe_wire changes value
    // ------------------------------------------------------------------------------
    assign zeroloopback_out_wire = (zero_loopback_output_register == "UNREGISTERED")? zeroloopback_pipe_wire
                                : zeroloopback_out_reg;
    always @(posedge zeroloopback_out_wire_clk or posedge zeroloopback_out_wire_clr)
    begin
            if (zeroloopback_out_wire_clr == 1)
                zeroloopback_out_reg <= 0;
            else if ((zeroloopback_out_wire_clk == 1) && (zeroloopback_out_wire_en == 1))
                zeroloopback_out_reg <= zeroloopback_pipe_wire;
    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set accumsload_reg/wire)
    // Signal Registered : accumsload_int
    //
    // Register is controlled by posedge accumsload_reg_wire_clk
    // Register has a clock enable accumsload_reg_wire_en
    // Register has an asynchronous clear signal, accumsload_reg_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        accum_sload_register is unregistered and accumsload_int changes value
    // ------------------------------------------------------------------------------
    assign accumsload_wire = (accum_sload_register == "UNREGISTERED")? accumsload_int
                                : accumsload_reg;
    always @(posedge accumsload_reg_wire_clk or posedge accumsload_reg_wire_clr)
    begin
            if (accumsload_reg_wire_clr == 1)
                accumsload_reg <= 0;
            else if ((accumsload_reg_wire_clk == 1) && (accumsload_reg_wire_en == 1))
                accumsload_reg <= accumsload_int;
    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set accumsload_pipe_reg/wire)
    // Signal Registered : accumsload_wire
    //
    // Register is controlled by posedge accumsload_pipe_wire_clk
    // Register has a clock enable accumsload_pipe_wire_en
    // Register has an asynchronous clear signal, accumsload_pipe_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        accum_sload_pipeline_register is unregistered and accumsload_wire changes value
    // ------------------------------------------------------------------------------
    assign accumsload_pipe_wire = (accum_sload_pipeline_register == "UNREGISTERED")? accumsload_wire
                                : accumsload_pipe_reg;
    always @(posedge accumsload_pipe_wire_clk or posedge accumsload_pipe_wire_clr)
    begin
            if (accumsload_pipe_wire_clr == 1)
                accumsload_pipe_reg <= 0;
            else if ((accumsload_pipe_wire_clk == 1) && (accumsload_pipe_wire_en == 1))
                accumsload_pipe_reg <= accumsload_wire;
    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set coeffsela_reg/wire)
    // Signal Registered : coeffsel_a_int
    //
    // Register is controlled by posedge coeffsela_reg_wire_clk
    // Register has a clock enable coeffsela_reg_wire_en
    // Register has an asynchronous clear signal, coeffsela_reg_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        coefsel0_register is unregistered and coeffsel_a_int changes value
    // ------------------------------------------------------------------------------
    assign coeffsel_a_wire = (coefsel0_register == "UNREGISTERED")? coeffsel_a_int
                                : coeffsel_a_reg;
    always @(posedge coeffsela_reg_wire_clk or posedge coeffsela_reg_wire_clr)
    begin
            if (coeffsela_reg_wire_clr == 1)
                coeffsel_a_reg <= 0;
            else if ((coeffsela_reg_wire_clk == 1) && (coeffsela_reg_wire_en == 1))
                coeffsel_a_reg <= coeffsel_a_int;
    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set coeffselb_reg/wire)
    // Signal Registered : coeffsel_b_int
    //
    // Register is controlled by posedge coeffselb_reg_wire_clk
    // Register has a clock enable coeffselb_reg_wire_en
    // Register has an asynchronous clear signal, coeffselb_reg_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        coefsel1_register is unregistered and coeffsel_b_int changes value
    // ------------------------------------------------------------------------------
    assign coeffsel_b_wire = (coefsel1_register == "UNREGISTERED")? coeffsel_b_int
                                : coeffsel_b_reg;
    always @(posedge coeffselb_reg_wire_clk or posedge coeffselb_reg_wire_clr)
    begin
            if (coeffselb_reg_wire_clr == 1)
                coeffsel_b_reg <= 0;
            else if ((coeffselb_reg_wire_clk == 1) && (coeffselb_reg_wire_en == 1))
                coeffsel_b_reg <= coeffsel_b_int;
    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set coeffselc_reg/wire)
    // Signal Registered : coeffsel_c_int
    //
    // Register is controlled by posedge coeffselc_reg_wire_clk
    // Register has a clock enable coeffselc_reg_wire_en
    // Register has an asynchronous clear signal, coeffselc_reg_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        coefsel2_register is unregistered and coeffsel_c_int changes value
    // ------------------------------------------------------------------------------
    assign coeffsel_c_wire = (coefsel2_register == "UNREGISTERED")? coeffsel_c_int
                                : coeffsel_c_reg;
    always @(posedge coeffselc_reg_wire_clk or posedge coeffselc_reg_wire_clr)
    begin
            if (coeffselc_reg_wire_clr == 1)
                coeffsel_c_reg <= 0;
            else if ((coeffselc_reg_wire_clk == 1) && (coeffselc_reg_wire_en == 1))
                coeffsel_c_reg <= coeffsel_c_int;
    end

    // ------------------------------------------------------------------------------
    // This block contains 1 register and 1 combinatorial block (to set coeffseld_reg/wire)
    // Signal Registered : coeffsel_d_int
    //
    // Register is controlled by posedge coeffseld_reg_wire_clk
    // Register has a clock enable coeffseld_reg_wire_en
    // Register has an asynchronous clear signal, coeffseld_reg_wire_clr
    // NOTE : The combinatorial block will be executed if
    //        coefsel3_register is unregistered and coeffsel_d_int changes value
    // ------------------------------------------------------------------------------
    assign coeffsel_d_wire = (coefsel3_register == "UNREGISTERED")? coeffsel_d_int
                                : coeffsel_d_reg;
    always @(posedge coeffseld_reg_wire_clk or posedge coeffseld_reg_wire_clr)
    begin
            if (coeffseld_reg_wire_clr == 1)
                coeffsel_d_reg <= 0;
            else if ((coeffseld_reg_wire_clk == 1) && (coeffseld_reg_wire_en == 1))
                coeffsel_d_reg <= coeffsel_d_int;
    end

    //This will perform the Preadder mode in StratixV
    // --------------------------------------------------------
    // This block basically calls the task do_preadder_sub/add() to set
    // the value of preadder_res_0[2*int_width_result - 1:0]
    // sign_a_reg or sign_b_reg will trigger the task call.
    // --------------------------------------------------------
    assign preadder_res_wire[(int_width_preadder - 1) :0] = preadder0_result[(int_width_preadder  - 1) :0];

    always @(preadder_res_0)
    begin
	preadder0_result  <= preadder_res_0;
    end

    always @(mult_a_wire[(int_width_a *1) -1 : (int_width_a*0)] or mult_b_wire[(int_width_b  *1) -1 : (int_width_b *0)] or
            sign_a_wire )
    begin
    	if(stratixv_block && (preadder_mode == "COEF" || preadder_mode == "INPUT" || preadder_mode == "SQUARE" ))
    	begin
			if(preadder_direction_0 == "ADD")
		        preadder_res_0 = do_preadder_add (0, sign_a_wire, sign_a_wire);
			else
				preadder_res_0 = do_preadder_sub (0, sign_a_wire, sign_a_wire);
		end
    end

    // --------------------------------------------------------
    // This block basically calls the task do_preadder_sub/add() to set
    // the value of preadder_res_1[2*int_width_result - 1:0]
    // sign_a_reg or sign_b_reg will trigger the task call.
    // --------------------------------------------------------
    assign preadder_res_wire[(((int_width_preadder) *2) - 1) : (int_width_preadder)] = preadder1_result[(int_width_preadder - 1) :0];

    always @(preadder_res_1)
    begin
	preadder1_result  <= preadder_res_1;
    end

    always @(mult_a_wire[(int_width_a *2) -1 : (int_width_a*1)] or mult_b_wire[(int_width_b  *2) -1 : (int_width_b *1)] or
            sign_a_wire )
    begin
    	if(stratixv_block && (preadder_mode == "COEF" || preadder_mode == "INPUT" || preadder_mode == "SQUARE" ))
    	begin
			if(preadder_direction_1 == "ADD")
		        preadder_res_1 = do_preadder_add (1, sign_a_wire, sign_a_wire);
			else
				preadder_res_1 = do_preadder_sub (1, sign_a_wire, sign_a_wire);
		end
    end

    // --------------------------------------------------------
    // This block basically calls the task do_preadder_sub/add() to set
    // the value of preadder_res_2[2*int_width_result - 1:0]
    // sign_a_reg or sign_b_reg will trigger the task call.
    // --------------------------------------------------------
    assign preadder_res_wire[((int_width_preadder) *3) -1 : (2*(int_width_preadder))] = preadder2_result[(int_width_preadder - 1) :0];

    always @(preadder_res_2)
    begin
	preadder2_result  <= preadder_res_2;
    end

    always @(mult_a_wire[(int_width_a *3) -1 : (int_width_a*2)] or mult_b_wire[(int_width_b  *3) -1 : (int_width_b *2)] or
            sign_a_wire )
    begin
    	if(stratixv_block && (preadder_mode == "COEF" || preadder_mode == "INPUT" || preadder_mode == "SQUARE" ))
    	begin
			if(preadder_direction_2 == "ADD")
		        preadder_res_2 = do_preadder_add (2, sign_a_wire, sign_a_wire);
			else
				preadder_res_2 = do_preadder_sub (2, sign_a_wire, sign_a_wire);
		end
    end

    // --------------------------------------------------------
    // This block basically calls the task do_preadder_sub/add() to set
    // the value of preadder_res_3[2*int_width_result - 1:0]
    // sign_a_reg or sign_b_reg will trigger the task call.
    // --------------------------------------------------------
    assign preadder_res_wire[((int_width_preadder) *4) -1 : 3*(int_width_preadder)] = preadder3_result[(int_width_preadder - 1) :0];

    always @(preadder_res_3)
    begin
	preadder3_result  <= preadder_res_3;
    end

    always @(mult_a_wire[(int_width_a *4) -1 : (int_width_a*3)] or mult_b_wire[(int_width_b  *4) -1 : (int_width_b *3)] or
            sign_a_wire)
    begin
    	if(stratixv_block && (preadder_mode == "COEF" || preadder_mode == "INPUT" || preadder_mode == "SQUARE" ))
    	begin
			if(preadder_direction_3 == "ADD")
		        preadder_res_3 = do_preadder_add (3, sign_a_wire, sign_a_wire);
			else
				preadder_res_3 = do_preadder_sub (3, sign_a_wire, sign_a_wire);
		end
    end


    // --------------------------------------------------------
    // This block basically calls the task do_multiply() to set
    // the value of mult_res_0[(int_width_a + int_width_b) -1 :0]
    //
    // If multiplier_register0 is registered, the call of the task
    // will be triggered by a posedge multiplier_reg0_wire_clk.
    // It also has an asynchronous clear signal multiplier_reg0_wire_clr
    //
    // If multiplier_register0 is unregistered, a change of value
    // in either mult_a[int_width_a-1:0], mult_b[int_width_a-1:0],
    // sign_a_reg or sign_b_reg will trigger the task call.
    // --------------------------------------------------------
    assign mult_res_wire[(int_width_a + int_width_b - 1) :0] =  ((multiplier_register0 == "UNREGISTERED") || (stratixiii_block == 1) || (stratixv_block == 1))?
                                                                mult0_result[(int_width_a + int_width_b - 1) :0] :
                                                                mult_res_reg[(int_width_a + int_width_b - 1) :0];

    assign mult_saturate_overflow_vec[0] =  (multiplier_register0 == "UNREGISTERED")?
                                            mult0_saturate_overflow : mult_saturate_overflow_reg[0];


    // This always block is to perform the rounding and saturation operations (StratixII only)
    always @(mult_res_0 or mult01_round_wire or mult01_saturate_wire)
    begin
        if (stratixii_block)
        begin
            // -------------------------------------------------------
            // Stratix II Rounding support
            // This block basically carries out the rounding for the
            // mult_res_0. The equation to get the mult0_round_out is
            // obtained from the Stratix II Mac FFD which is below:
            // round_adder_constant = (1 << (wfraction - wfraction_round - 1))
            // roundout[] = datain[] + round_adder_constant
            // For Stratix II rounding, we round up the bits to 15 bits
            // or in another word wfraction_round = 15.
            // --------------------------------------------------------

            if ((multiplier01_rounding == "YES") ||
                ((multiplier01_rounding == "VARIABLE") && (mult01_round_wire == 1)))
            begin
                mult0_round_out[(int_width_a + int_width_b) -1 :0] = mult_res_0[(int_width_a + int_width_b) -1 :0] + ( 1 << (`MULT_ROUND_BITS - 1));
            end
            else
            begin
                mult0_round_out[(int_width_a + int_width_b) -1 :0] = mult_res_0[(int_width_a + int_width_b) -1 :0];
            end

            mult0_round_out[((int_width_a + int_width_b) + 2) : (int_width_a + int_width_b)] = {2{1'b0}};

            // -------------------------------------------------------
            // Stratix II Saturation support
            // This carries out the saturation for mult0_round_out.
            // The equation to get the saturated result is obtained
            // from Stratix II MAC FFD which is below:
            // satoverflow = 1 if sign bit is different
            // satvalue[wtotal-1 : wfraction] = roundout[wtotal-1]
            // satvalue[wfraction-1 : 0] = !roundout[wtotal-1]
            // -------------------------------------------------------

            if ((multiplier01_saturation == "YES") ||
                (( multiplier01_saturation == "VARIABLE") && (mult01_saturate_wire == 1)))
            begin

                mult0_saturate_overflow_stat = (~mult0_round_out[int_width_a + int_width_b - 1]) && mult0_round_out[int_width_a + int_width_b - 2];

                if (mult0_saturate_overflow_stat == 0)
                begin
                    mult0_saturate_out = mult0_round_out;
                    mult0_saturate_overflow = mult0_round_out[0];
                end
                else
                begin

                    // We are doing Q2.31 saturation
                    for (num_bit_mult0 = (int_width_a + int_width_b - 1); num_bit_mult0 >= (int_width_a + int_width_b - 2); num_bit_mult0 = num_bit_mult0 - 1)
                    begin
                        mult0_saturate_out[num_bit_mult0] = mult0_round_out[int_width_a + int_width_b - 1];
                    end

                    for (num_bit_mult0 = sat_ini_value; num_bit_mult0 >= 3; num_bit_mult0 = num_bit_mult0 - 1)
                    begin
                        mult0_saturate_out[num_bit_mult0] = ~mult0_round_out[int_width_a + int_width_b - 1];
                    end

                    mult0_saturate_out[2 : 0] = mult0_round_out[2:0];

                    mult0_saturate_overflow = mult0_saturate_overflow_stat;
                end
            end
            else
            begin
                mult0_saturate_out = mult0_round_out;
                mult0_saturate_overflow = 1'b0;
            end

            if ((multiplier01_rounding == "YES") ||
                ((multiplier01_rounding  == "VARIABLE") && (mult01_round_wire == 1)))
            begin

                for (num_bit_mult0 = (`MULT_ROUND_BITS - 1); num_bit_mult0 >= 0; num_bit_mult0 = num_bit_mult0 - 1)
                begin
                    mult0_saturate_out[num_bit_mult0] = 1'b0;
                end

            end
        end
    end

    always @(mult0_saturate_out or mult_res_0 or systolic_register1)
    begin
        if (stratixii_block)
        begin
            mult0_result <= mult0_saturate_out[(int_width_a + int_width_b) -1 :0];
        end
        else if(stratixv_block)
        begin
        	if(systolic_delay1 == output_register)
        		mult0_result  <= systolic_register1;
        	else
        		mult0_result  <= mult_res_0;
        end
        else
        begin
            mult0_result  <= mult_res_0;
        end

    end

    assign systolic_register1 = (systolic_delay1 == "UNREGISTERED")? mult_res_0
                                : mult_res_reg_0;
    always @(posedge systolic1_reg_wire_clk or posedge systolic1_reg_wire_clr)
    begin
        if (stratixv_block == 1)
        begin
            if (systolic1_reg_wire_clr == 1)
            begin
                mult_res_reg_0[(int_width_a + int_width_b) -1 :0] <= 0;
            end
            else if ((systolic1_reg_wire_clk == 1) && (systolic1_reg_wire_en == 1))
            begin
                mult_res_reg_0[(int_width_a + int_width_b - 1) : 0] <= mult_res_0;
            end
        end
	end

	assign chainin_register1 = (systolic_delay1 == "UNREGISTERED")? 0
                                : chainin_reg;
    always @(posedge systolic1_reg_wire_clk or posedge systolic1_reg_wire_clr)
    begin
        if (stratixv_block == 1)
        begin
            if (systolic1_reg_wire_clr == 1)
            begin
                chainin_reg[(width_chainin) -1 :0] <= 0;
            end
            else if ((systolic1_reg_wire_clk == 1) && (systolic1_reg_wire_en == 1))
            begin
                chainin_reg[(width_chainin - 1) : 0] <= chainin_int;
            end
        end
	end

    // this block simulates the pipeline register after the multiplier (for non-StratixIII families)
    // and the pipeline register after the 1st level adder (for Stratix III)
    always @(posedge multiplier_reg0_wire_clk or posedge multiplier_reg0_wire_clr)
    begin
        if (stratixiii_block == 0 && stratixv_block == 0)
        begin
            if (multiplier_reg0_wire_clr == 1)
            begin
                mult_res_reg[(int_width_a + int_width_b) -1 :0] <= 0;
                mult_saturate_overflow_reg[0] <= 0;
            end
            else if ((multiplier_reg0_wire_clk == 1) && (multiplier_reg0_wire_en == 1))
            begin
                if (stratixii_block == 0)
                    mult_res_reg[(int_width_a + int_width_b) - 1 : 0] <= mult_res_0[(int_width_a + int_width_b) -1 :0];
                else
                begin
                    mult_res_reg[(int_width_a + int_width_b - 1) : 0] <= mult0_result;
                    mult_saturate_overflow_reg[0] <= mult0_saturate_overflow;
                end
            end
        end
        else  // Stratix III - multiplier_reg refers to the register after the 1st adder
        begin
            if (multiplier_reg0_wire_clr == 1)
            begin
                adder1_reg[2*int_width_result - 1 : 0] <= 0;
                unsigned_sub1_overflow_mult_reg <= 0;
            end
            else if ((multiplier_reg0_wire_clk == 1) && (multiplier_reg0_wire_en == 1))
            begin
                adder1_reg[2*int_width_result - 1: 0] <= adder1_sum[2*int_width_result - 1 : 0];
                unsigned_sub1_overflow_mult_reg <= unsigned_sub1_overflow;
            end
        end
    end



    always @(mult_a_wire[(int_width_a *1) -1 : (int_width_a*0)] or mult_b_wire[(int_width_b  *1) -1 : (int_width_b *0)] or mult_c_wire[int_width_c-1:0] or
            preadder_res_wire[int_width_preadder - 1:0] or sign_a_wire or sign_b_wire)
    begin
    	if(stratixv_block)
    	begin
    		preadder_sum1a = 0;
    		preadder_sum2a = 0;
			if(preadder_mode == "CONSTANT")
			begin
				preadder_sum1a = mult_a_wire >> (0 * int_width_a);
				preadder_sum2a = coeffsel_a_pre;
			end
			else if(preadder_mode == "COEF")
			begin
				preadder_sum1a = preadder_res_wire[int_width_preadder - 1:0];
				preadder_sum2a = coeffsel_a_pre;
			end
			else if(preadder_mode == "INPUT")
			begin
				preadder_sum1a = preadder_res_wire[int_width_preadder - 1:0];
				preadder_sum2a = mult_c_wire;
			end
			else if(preadder_mode == "SQUARE")
			begin
				preadder_sum1a = preadder_res_wire[int_width_preadder - 1:0];
				preadder_sum2a = preadder_res_wire[int_width_preadder - 1:0];
			end
			else
			begin
				preadder_sum1a = mult_a_wire >> (0 * width_a);
				preadder_sum2a = mult_b_wire >> (0 * width_b);
			end
	    	mult_res_0 = do_multiply_stratixv(0, sign_a_wire, sign_b_wire);
	    end
    	else
	        mult_res_0 = do_multiply (0, sign_a_wire, sign_b_wire);
    end

    // ------------------------------------------------------------------------
    // This block basically calls the task do_multiply() to set the value of
    // mult_res_1[(int_width_a + int_width_b) -1 :0]
    //
    // If multiplier_register1 is registered, the call of the task
    // will be triggered by a posedge multiplier_reg1_wire_clk.
    // It also has an asynchronous clear signal multiplier_reg1_wire_clr
    //
    // If multiplier_register1 is unregistered, a change of value
    // in either mult_a[(2*int_width_a)-1:int_width_a], mult_b[(2*int_width_a)-1:int_width_a],
    // sign_a_reg or sign_b_reg will trigger the task call.
    // -----------------------------------------------------------------------

    assign mult_res_wire[(((int_width_a + int_width_b) *2) - 1) : (int_width_a + int_width_b)] =  ((multiplier_register1 == "UNREGISTERED") || (stratixiii_block == 1) || (stratixv_block == 1))?
                                                                    mult1_result[(int_width_a + int_width_b - 1) : 0]:
                                                            mult_res_reg[((int_width_a + int_width_b) *2) - 1: (int_width_a + int_width_b)];

    assign mult_saturate_overflow_vec[1] =  (multiplier_register1 == "UNREGISTERED")?
                                            mult1_saturate_overflow : mult_saturate_overflow_reg[1];


    // This always block is to perform the rounding and saturation operations (StratixII only)
    always @(mult_res_1 or mult01_round_wire or mult01_saturate_wire)
    begin
        if (stratixii_block)
        begin
            // -------------------------------------------------------
            // Stratix II Rounding support
            // This block basically carries out the rounding for the
            // mult_res_1. The equation to get the mult1_round_out is
            // obtained from the Stratix II Mac FFD which is below:
            // round_adder_constant = (1 << (wfraction - wfraction_round - 1))
            // roundout[] = datain[] + round_adder_constant
            // For Stratix II rounding, we round up the bits to 15 bits
            // or in another word wfraction_round = 15.
            // --------------------------------------------------------

            if ((multiplier01_rounding == "YES") ||
                ((multiplier01_rounding == "VARIABLE") && (mult01_round_wire == 1)))
            begin
                mult1_round_out[(int_width_a + int_width_b) -1 :0] = mult_res_1[(int_width_a + int_width_b) -1 :0] + ( 1 << (`MULT_ROUND_BITS - 1));
            end
            else
            begin
                mult1_round_out[(int_width_a + int_width_b) -1 :0] = mult_res_1[(int_width_a + int_width_b) -1 :0];
            end

            mult1_round_out[((int_width_a + int_width_b) + 2) : (int_width_a + int_width_b)] = {2{1'b0}};


            // -------------------------------------------------------
            // Stratix II Saturation support
            // This carries out the saturation for mult1_round_out.
            // The equation to get the saturated result is obtained
            // from Stratix II MAC FFD which is below:
            // satoverflow = 1 if sign bit is different
            // satvalue[wtotal-1 : wfraction] = roundout[wtotal-1]
            // satvalue[wfraction-1 : 0] = !roundout[wtotal-1]
            // -------------------------------------------------------


            if ((multiplier01_saturation == "YES") ||
                (( multiplier01_saturation == "VARIABLE") && (mult01_saturate_wire == 1)))
            begin
                mult1_saturate_overflow_stat = (~mult1_round_out[int_width_a + int_width_b - 1]) && mult1_round_out[int_width_a + int_width_b - 2];

                if (mult1_saturate_overflow_stat == 0)
                begin
                    mult1_saturate_out = mult1_round_out;
                    mult1_saturate_overflow = mult1_round_out[0];
                end
                else
                begin
                    // We are doing Q2.31 saturation. Thus we would insert additional bit
                    // for the LSB
                    for (num_bit_mult1 = (int_width_a + int_width_b - 1); num_bit_mult1 >= (int_width_a + int_width_b - 2); num_bit_mult1 = num_bit_mult1 - 1)
                    begin
                        mult1_saturate_out[num_bit_mult1] = mult1_round_out[int_width_a + int_width_b - 1];
                    end

                    for (num_bit_mult1 = sat_ini_value; num_bit_mult1 >= 3; num_bit_mult1 = num_bit_mult1 - 1)
                    begin
                        mult1_saturate_out[num_bit_mult1] = ~mult1_round_out[int_width_a + int_width_b - 1];
                    end

                    mult1_saturate_out[2:0] = mult1_round_out[2:0];
                    mult1_saturate_overflow = mult1_saturate_overflow_stat;
                end
            end
            else
            begin
                mult1_saturate_out = mult1_round_out;
                mult1_saturate_overflow = 1'b0;
            end

            if ((multiplier01_rounding == "YES") ||
                ((multiplier01_rounding  == "VARIABLE") && (mult01_round_wire == 1)))
            begin

                for (num_bit_mult1 = (`MULT_ROUND_BITS - 1); num_bit_mult1 >= 0; num_bit_mult1 = num_bit_mult1 - 1)
                begin
                    mult1_saturate_out[num_bit_mult1] = 1'b0;
                end

            end
        end
    end

    always @(mult1_saturate_out or mult_res_1)
    begin
        if (stratixii_block)
        begin
            mult1_result <= mult1_saturate_out[(int_width_a + int_width_b) -1 :0];
        end
        else
        begin
            mult1_result  <= mult_res_1;
        end
    end

    // simulate the register after the multiplier for non-Stratix III families
    // does not apply to the Stratix III family
    always @(posedge multiplier_reg1_wire_clk or posedge multiplier_reg1_wire_clr)
    begin
        if (stratixiii_block == 0 && stratixv_block == 0)
        begin
            if (multiplier_reg1_wire_clr == 1)
            begin
                mult_res_reg[((int_width_a + int_width_b) *2) -1 : (int_width_a + int_width_b)] <= 0;
                mult_saturate_overflow_reg[1] <= 0;
            end
            else if ((multiplier_reg1_wire_clk == 1) && (multiplier_reg1_wire_en == 1))
                if (stratixii_block == 0)
                    mult_res_reg[((int_width_a + int_width_b) *2) -1 : (int_width_a + int_width_b)] <=
                                            mult_res_1[(int_width_a + int_width_b) -1 :0];
                else
                begin
                    mult_res_reg[((int_width_a + int_width_b) *2) -1 : (int_width_a + int_width_b)] <=  mult1_result;
                    mult_saturate_overflow_reg[1] <= mult1_saturate_overflow;
                end
        end
    end


    always @(mult_a_wire[(int_width_a *2) -1 : (int_width_a*1)] or mult_b_wire[(int_width_b  *2) -1 : (int_width_b *1)] or
            preadder_res_wire[(((int_width_preadder) *2) - 1) : (int_width_preadder)] or sign_a_wire or sign_b_wire)
    begin
    	if(stratixv_block)
    	begin
    		preadder_sum1a = 0;
    		preadder_sum2a = 0;
			if(preadder_mode == "CONSTANT" )
			begin
				preadder_sum1a = mult_a_wire >> (1 * int_width_a);
				preadder_sum2a = coeffsel_b_pre;
			end
			else if(preadder_mode == "COEF")
			begin
				preadder_sum1a = preadder_res_wire[(((int_width_preadder) *2) - 1) : (int_width_preadder)];
				preadder_sum2a = coeffsel_b_pre;
			end
			else if(preadder_mode == "SQUARE")
			begin
				preadder_sum1a = preadder_res_wire[(((int_width_preadder) *2) - 1) : (int_width_preadder)];
				preadder_sum2a = preadder_res_wire[(((int_width_preadder) *2) - 1) : (int_width_preadder)];
			end
			else
			begin
				preadder_sum1a = mult_a_wire >> (1 * int_width_a);
				preadder_sum2a = mult_b_wire >> (1 * int_width_b);
			end
	    	mult_res_1 = do_multiply_stratixv(1, sign_a_wire, sign_b_wire);
	    end
        else if(input_source_b0 == "LOOPBACK")
            mult_res_1 = do_multiply_loopback (1, sign_a_wire, sign_b_wire);
        else
            mult_res_1 = do_multiply (1, sign_a_wire, sign_b_wire);
    end


    // ----------------------------------------------------------------------------
    // This block basically calls the task do_multiply() to set the value of
    // mult_res_2[(int_width_a + int_width_b) -1 :0]
    //
    // If multiplier_register2 is registered, the call of the task
    // will be triggered by a posedge multiplier_reg2_wire_clk.
    // It also has an asynchronous clear signal multiplier_reg2_wire_clr
    //
    // If multiplier_register2 is unregistered, a change of value
    // in either mult_a[(3*int_width_a)-1:2*int_width_a], mult_b[(3*int_width_a)-1:2*int_width_a],
    // sign_a_reg or sign_b_reg will trigger the task call.
    // ---------------------------------------------------------------------------

    assign mult_res_wire[((int_width_a + int_width_b) *3) -1 : (2*(int_width_a + int_width_b))] =  ((multiplier_register2 == "UNREGISTERED") || (stratixiii_block == 1) || (stratixv_block == 1))?
                                                                                            mult2_result[(int_width_a + int_width_b) -1 :0] :
                                                        mult_res_reg[((int_width_a + int_width_b) *3) -1 : (2*(int_width_a + int_width_b))];

    assign mult_saturate_overflow_vec[2] =  (multiplier_register2 == "UNREGISTERED")?
                                            mult2_saturate_overflow : mult_saturate_overflow_reg[2];

    // This always block is to perform the rounding and saturation operations (StratixII only)
    always @(mult_res_2 or mult23_round_wire or mult23_saturate_wire)
    begin
        if (stratixii_block)
        begin
            // -------------------------------------------------------
            // Stratix II Rounding support
            // This block basically carries out the rounding for the
            // mult_res_2. The equation to get the mult2_round_out is
            // obtained from the Stratix II Mac FFD which is below:
            // round_adder_constant = (1 << (wfraction - wfraction_round - 1))
            // roundout[] = datain[] + round_adder_constant
            // For Stratix II rounding, we round up the bits to 15 bits
            // or in another word wfraction_round = 15.
            // --------------------------------------------------------

            if ((multiplier23_rounding == "YES") ||
                ((multiplier23_rounding == "VARIABLE") && (mult23_round_wire == 1)))
            begin
                mult2_round_out[(int_width_a + int_width_b) -1 :0] = mult_res_2[(int_width_a + int_width_b) -1 :0] + ( 1 << (`MULT_ROUND_BITS - 1));
            end
            else
            begin
                mult2_round_out[(int_width_a + int_width_b) -1 :0] = mult_res_2[(int_width_a + int_width_b) -1 :0];
            end

            mult2_round_out[((int_width_a + int_width_b) + 2) : (int_width_a + int_width_b)] = {2{1'b0}};

            // -------------------------------------------------------
            // Stratix II Saturation support
            // This carries out the saturation for mult2_round_out.
            // The equation to get the saturated result is obtained
            // from Stratix II MAC FFD which is below:
            // satoverflow = 1 if sign bit is different
            // satvalue[wtotal-1 : wfraction] = roundout[wtotal-1]
            // satvalue[wfraction-1 : 0] = !roundout[wtotal-1]
            // -------------------------------------------------------


            if ((multiplier23_saturation == "YES") ||
                (( multiplier23_saturation == "VARIABLE") && (mult23_saturate_wire == 1)))
            begin
                mult2_saturate_overflow_stat = (~mult2_round_out[int_width_a + int_width_b - 1]) && mult2_round_out[int_width_a + int_width_b - 2];

                if (mult2_saturate_overflow_stat == 0)
                begin
                    mult2_saturate_out = mult2_round_out;
                    mult2_saturate_overflow = mult2_round_out[0];
                end
                else
                begin
                    // We are doing Q2.31 saturation. Thus we would insert additional bit
                    // for the LSB
                    for (num_bit_mult2 = (int_width_a + int_width_b - 1); num_bit_mult2 >= (int_width_a + int_width_b - 2); num_bit_mult2 = num_bit_mult2 - 1)
                    begin
                        mult2_saturate_out[num_bit_mult2] = mult2_round_out[int_width_a + int_width_b - 1];
                    end

                    for (num_bit_mult2 = sat_ini_value; num_bit_mult2 >= 3; num_bit_mult2 = num_bit_mult2 - 1)
                    begin
                        mult2_saturate_out[num_bit_mult2] = ~mult2_round_out[int_width_a + int_width_b - 1];
                    end

                    mult2_saturate_out[2:0] = mult2_round_out[2:0];
                    mult2_saturate_overflow = mult2_saturate_overflow_stat;
                end
            end
            else
            begin
                mult2_saturate_out = mult2_round_out;
                mult2_saturate_overflow = 1'b0;
            end

            if ((multiplier23_rounding == "YES") ||
                ((multiplier23_rounding  == "VARIABLE") && (mult23_round_wire == 1)))
            begin

                for (num_bit_mult2 = (`MULT_ROUND_BITS - 1); num_bit_mult2 >= 0; num_bit_mult2 = num_bit_mult2 - 1)
                begin
                    mult2_saturate_out[num_bit_mult2] = 1'b0;
                end

            end
        end
    end

    always @(mult2_saturate_out or mult_res_2 or systolic_register3)
    begin
        if (stratixii_block)
        begin
            mult2_result <= mult2_saturate_out[(int_width_a + int_width_b) -1 :0];
        end
        else if(stratixv_block)
        begin
        	if(systolic_delay1 == output_register)
        		mult2_result  <= systolic_register3;
        	else
                mult2_result  <= mult_res_2;
        end
        else
        begin
            mult2_result  <= mult_res_2;
        end
    end

    assign systolic_register3 = (systolic_delay3 == "UNREGISTERED")? mult_res_2
                                : mult_res_reg_2;
    always @(posedge systolic3_reg_wire_clk or posedge systolic3_reg_wire_clr)
    begin
        if (stratixv_block == 1)
        begin
            if (systolic3_reg_wire_clr == 1)
            begin
                mult_res_reg_2[(int_width_a + int_width_b) -1 :0] <= 0;
            end
            else if ((systolic3_reg_wire_clk == 1) && (systolic3_reg_wire_en == 1))
            begin
                mult_res_reg_2[(int_width_a + int_width_b - 1) : 0] <= mult_res_2;
            end
        end
	end

    // simulate the register after the multiplier (for non-Stratix III families)
    // and simulate the register after the 1st adder for Stratix III family
    always @(posedge multiplier_reg2_wire_clk or posedge multiplier_reg2_wire_clr)
    begin
        if (stratixiii_block == 0 && stratixv_block == 0)
        begin
            if (multiplier_reg2_wire_clr == 1)
            begin
                mult_res_reg[((int_width_a + int_width_b) *3) -1 : (2*(int_width_a + int_width_b))] <= 0;
                mult_saturate_overflow_reg[2] <= 0;
            end
            else if ((multiplier_reg2_wire_clk == 1) && (multiplier_reg2_wire_en == 1))
                if (stratixii_block == 0)
                    mult_res_reg[((int_width_a + int_width_b) *3) -1 : (2*(int_width_a + int_width_b))] <=
                            mult_res_2[(int_width_a + int_width_b) -1 :0];
                else
                begin
                    mult_res_reg[((int_width_a + int_width_b) *3) -1 : (2*(int_width_a + int_width_b))] <=  mult2_result;
                    mult_saturate_overflow_reg[2] <= mult2_saturate_overflow;
                end
        end
        else  // Stratix III - multiplier_reg here refers to the register after the 1st adder
        begin
            if (multiplier_reg2_wire_clr == 1)
            begin
                adder3_reg[2*int_width_result - 1 : 0] <= 0;
                unsigned_sub3_overflow_mult_reg <= 0;
            end
            else if ((multiplier_reg2_wire_clk == 1) && (multiplier_reg2_wire_en == 1))
            begin
                adder3_reg[2*int_width_result - 1: 0] <= adder3_sum[2*int_width_result - 1 : 0];
                unsigned_sub3_overflow_mult_reg <= unsigned_sub3_overflow;
            end
        end
    end

    always @(mult_a_wire[(int_width_a *3) -1 : (int_width_a*2)] or mult_b_wire[(int_width_b  *3) -1 : (int_width_b *2)] or
            preadder_res_wire[((int_width_preadder) *3) -1 : (2*(int_width_preadder))] or sign_a_wire or sign_b_wire)
    begin
    	if(stratixv_block)
    	begin
    		preadder_sum1a = 0;
    		preadder_sum2a = 0;
			if(preadder_mode == "CONSTANT")
			begin
				preadder_sum1a = mult_a_wire >> (2 * int_width_a);
				preadder_sum2a = coeffsel_c_pre;
			end
			else if(preadder_mode == "COEF")
			begin
				preadder_sum1a = preadder_res_wire[((int_width_preadder) *3) -1 : (2*(int_width_preadder))];
				preadder_sum2a = coeffsel_c_pre;
			end
			else if(preadder_mode == "SQUARE")
			begin
				preadder_sum1a = preadder_res_wire[((int_width_preadder) *3) -1 : (2*(int_width_preadder))];
				preadder_sum2a = preadder_res_wire[((int_width_preadder) *3) -1 : (2*(int_width_preadder))];
			end
			else
			begin
				preadder_sum1a = mult_a_wire >> (2 * int_width_a);
				preadder_sum2a = mult_b_wire >> (2 * int_width_b);
			end
    		mult_res_2 = do_multiply_stratixv (2, sign_a_wire, sign_b_wire);
    	end
    	else
        	mult_res_2 = do_multiply (2, sign_a_wire, sign_b_wire);
    end




    // ----------------------------------------------------------------------------
    // This block basically calls the task do_multiply() to set the value of
    // mult_res_3[(int_width_a + int_width_b) -1 :0]
    //
    // If multiplier_register3 is registered, the call of the task
    // will be triggered by a posedge multiplier_reg3_wire_clk.
    // It also has an asynchronous clear signal multiplier_reg3_wire_clr
    //
    // If multiplier_register3 is unregistered, a change of value
    // in either mult_a[(4*int_width_a)-1:3*int_width_a], mult_b[(4*int_width_a)-1:3*int_width_a],
    // sign_a_reg or sign_b_reg will trigger the task call.
    // ---------------------------------------------------------------------------

    assign mult_res_wire[((int_width_a + int_width_b) *4) -1 : 3*(int_width_a + int_width_b)] = ((multiplier_register3 == "UNREGISTERED") || (stratixiii_block == 1) || (stratixv_block == 1))?
                                                                        mult3_result[(int_width_a + int_width_b) -1 :0] :
                                                                        mult_res_reg[((int_width_a + int_width_b) *4) -1 : 3*(int_width_a + int_width_b)];

    assign mult_saturate_overflow_vec[3] =  (multiplier_register3 == "UNREGISTERED")?
                                            mult3_saturate_overflow : mult_saturate_overflow_reg[3];

    // This always block is to perform the rounding and saturation operations (StratixII only)
    always @(mult_res_3 or mult23_round_wire or mult23_saturate_wire)
    begin
        if (stratixii_block)
        begin
            // -------------------------------------------------------
            // Stratix II Rounding support
            // This block basically carries out the rounding for the
            // mult_res_3. The equation to get the mult3_round_out is
            // obtained from the Stratix II Mac FFD which is below:
            // round_adder_constant = (1 << (wfraction - wfraction_round - 1))
            // roundout[] = datain[] + round_adder_constant
            // For Stratix II rounding, we round up the bits to 15 bits
            // or in another word wfraction_round = 15.
            // --------------------------------------------------------

            if ((multiplier23_rounding == "YES") ||
                ((multiplier23_rounding == "VARIABLE") && (mult23_round_wire == 1)))
            begin
                mult3_round_out[(int_width_a + int_width_b) -1 :0] = mult_res_3[(int_width_a + int_width_b) -1 :0] + ( 1 << (`MULT_ROUND_BITS - 1));
            end
            else
            begin
                mult3_round_out[(int_width_a + int_width_b) -1 :0] = mult_res_3[(int_width_a + int_width_b) -1 :0];
            end

            mult3_round_out[((int_width_a + int_width_b) + 2) : (int_width_a + int_width_b)] = {2{1'b0}};

            // -------------------------------------------------------
            // Stratix II Saturation support
            // This carries out the saturation for mult3_round_out.
            // The equation to get the saturated result is obtained
            // from Stratix II MAC FFD which is below:
            // satoverflow = 1 if sign bit is different
            // satvalue[wtotal-1 : wfraction] = roundout[wtotal-1]
            // satvalue[wfraction-1 : 0] = !roundout[wtotal-1]
            // -------------------------------------------------------


            if ((multiplier23_saturation == "YES") ||
                (( multiplier23_saturation == "VARIABLE") && (mult23_saturate_wire == 1)))
            begin
                mult3_saturate_overflow_stat = (~mult3_round_out[int_width_a + int_width_b - 1]) && mult3_round_out[int_width_a + int_width_b - 2];

                if (mult3_saturate_overflow_stat == 0)
                begin
                    mult3_saturate_out = mult3_round_out;
                    mult3_saturate_overflow = mult3_round_out[0];
                end
                else
                begin
                    // We are doing Q2.31 saturation. Thus we would make sure the 3 LSB bits isn't reset
                    for (num_bit_mult3 = (int_width_a + int_width_b -1); num_bit_mult3 >= (int_width_a + int_width_b - 2); num_bit_mult3 = num_bit_mult3 - 1)
                    begin
                        mult3_saturate_out[num_bit_mult3] = mult3_round_out[int_width_a + int_width_b - 1];
                    end

                    for (num_bit_mult3 = sat_ini_value; num_bit_mult3 >= 3; num_bit_mult3 = num_bit_mult3 - 1)
                    begin
                        mult3_saturate_out[num_bit_mult3] = ~mult3_round_out[int_width_a + int_width_b - 1];
                    end

                    mult3_saturate_out[2:0] = mult3_round_out[2:0];
                    mult3_saturate_overflow = mult3_saturate_overflow_stat;
                end
            end
            else
            begin
                mult3_saturate_out = mult3_round_out;
                mult3_saturate_overflow = 1'b0;
            end

            if ((multiplier23_rounding == "YES") ||
                ((multiplier23_rounding  == "VARIABLE") && (mult23_round_wire == 1)))
            begin

                for (num_bit_mult3 = (`MULT_ROUND_BITS - 1); num_bit_mult3 >= 0; num_bit_mult3 = num_bit_mult3 - 1)
                begin
                    mult3_saturate_out[num_bit_mult3] = 1'b0;
                end

            end
        end
    end

    always @(mult3_saturate_out or mult_res_3)
    begin
        if (stratixii_block)
        begin
            mult3_result <= mult3_saturate_out[(int_width_a + int_width_b) -1 :0];
        end
        else
        begin
            mult3_result <= mult_res_3;
        end
    end

    // simulate the register after the multiplier for non-Stratix III families
    // does not apply to the Stratix III family
    always @(posedge multiplier_reg3_wire_clk or posedge multiplier_reg3_wire_clr)
    begin
        if (stratixiii_block == 0 && stratixv_block == 0)
        begin
            if (multiplier_reg3_wire_clr == 1)
            begin
                mult_res_reg[((int_width_a + int_width_b) *4) -1 : (3*(int_width_a + int_width_b))] <= 0;
                mult_saturate_overflow_reg[3] <= 0;
            end
            else if ((multiplier_reg3_wire_clk == 1) && (multiplier_reg3_wire_en == 1))
                if (stratixii_block == 0)
                    mult_res_reg[((int_width_a + int_width_b) *4) -1 : (3*(int_width_a + int_width_b))] <=
                            mult_res_3[(int_width_a + int_width_b) -1 :0];
                else
                begin
                    mult_res_reg[((int_width_a + int_width_b) *4) -1: 3*(int_width_a + int_width_b)] <=  mult3_result;
                    mult_saturate_overflow_reg[3] <= mult3_saturate_overflow;
                end
        end
    end




    always @(mult_a_wire[(int_width_a *4) -1 : (int_width_a*3)] or mult_b_wire[(int_width_b  *4) -1 : (int_width_b *3)] or
            preadder_res_wire[((int_width_preadder) *4) -1 : 3*(int_width_preadder)] or sign_a_wire or sign_b_wire)
    begin
    	if(stratixv_block)
    	begin
    		preadder_sum1a = 0;
    		preadder_sum2a = 0;
			if(preadder_mode == "CONSTANT")
			begin
				preadder_sum1a = mult_a_wire >> (3 * int_width_a);
				preadder_sum2a = coeffsel_d_pre;
			end
			else if(preadder_mode == "COEF")
			begin
				preadder_sum1a = preadder_res_wire[((int_width_preadder) *4) -1 : 3*(int_width_preadder)];
				preadder_sum2a = coeffsel_d_pre;
			end
			else if(preadder_mode == "SQUARE")
			begin
				preadder_sum1a = preadder_res_wire[((int_width_preadder) *4) -1 : 3*(int_width_preadder)];
				preadder_sum2a = preadder_res_wire[((int_width_preadder) *4) -1 : 3*(int_width_preadder)];
			end
			else
			begin
				preadder_sum1a = mult_a_wire >> (3 * int_width_a);
				preadder_sum2a = mult_b_wire >> (3 * int_width_b);
			end
    		mult_res_3 = do_multiply_stratixv (3, sign_a_wire, sign_b_wire);
    	end
    	else
        	mult_res_3 = do_multiply (3, sign_a_wire, sign_b_wire);
    end

    //------------------------------
    // Assign statements for coefficient storage
    //------------------------------
    assign coeffsel_a_pre = (coeffsel_a_wire == 0)? coef0_0 :
    						(coeffsel_a_wire == 1)? coef0_1 :
    						(coeffsel_a_wire == 2)? coef0_2 :
    						(coeffsel_a_wire == 3)? coef0_3 :
    						(coeffsel_a_wire == 4)? coef0_4 :
    						(coeffsel_a_wire == 5)? coef0_5 :
    						(coeffsel_a_wire == 6)? coef0_6 : coef0_7 ;

	assign coeffsel_b_pre = (coeffsel_b_wire == 0)? coef1_0 :
    						(coeffsel_b_wire == 1)? coef1_1 :
    						(coeffsel_b_wire == 2)? coef1_2 :
    						(coeffsel_b_wire == 3)? coef1_3 :
    						(coeffsel_b_wire == 4)? coef1_4 :
    						(coeffsel_b_wire == 5)? coef1_5 :
    						(coeffsel_b_wire == 6)? coef1_6 : coef1_7 ;

	assign coeffsel_c_pre = (coeffsel_c_wire == 0)? coef2_0 :
    						(coeffsel_c_wire == 1)? coef2_1 :
    						(coeffsel_c_wire == 2)? coef2_2 :
    						(coeffsel_c_wire == 3)? coef2_3 :
    						(coeffsel_c_wire == 4)? coef2_4 :
    						(coeffsel_c_wire == 5)? coef2_5 :
    						(coeffsel_c_wire == 6)? coef2_6 : coef2_7 ;

	assign coeffsel_d_pre = (coeffsel_d_wire == 0)? coef3_0 :
    						(coeffsel_d_wire == 1)? coef3_1 :
    						(coeffsel_d_wire == 2)? coef3_2 :
    						(coeffsel_d_wire == 3)? coef3_3 :
    						(coeffsel_d_wire == 4)? coef3_4 :
    						(coeffsel_d_wire == 5)? coef3_5 :
    						(coeffsel_d_wire == 6)? coef3_6 : coef3_7 ;
    //------------------------------
    // Continuous assign statements
    //------------------------------

    // Clock in all the A input registers
    assign i_scanina = (stratixii_block == 0)?
                            dataa_int[int_width_a-1:0] : scanina_z;

    assign mult_a_pre[int_width_a-1:0] =    (stratixv_block == 1)? dataa_int[width_a-1:0]:
                                            (input_source_a0 == "DATAA")? dataa_int[int_width_a-1:0] :
                                            (input_source_a0 == "SCANA")? i_scanina :
                                            (sourcea_wire[0] == 1)? scanina_z : dataa_int[int_width_a-1:0];

    assign mult_a_pre[(2*int_width_a)-1:int_width_a] =  (stratixv_block == 1)? dataa_int[(2*width_a)-1:width_a] :
                                                        (input_source_a1 == "DATAA")?dataa_int[(2*int_width_a)-1:int_width_a] :
                                                        (input_source_a1 == "SCANA")? mult_a_wire[int_width_a-1:0] :
                                                        (sourcea_wire[1] == 1)? mult_a_wire[int_width_a-1:0] : dataa_int[(2*int_width_a)-1:int_width_a];

    assign mult_a_pre[(3*int_width_a)-1:2*int_width_a] =    (stratixv_block == 1)? dataa_int[(3*width_a)-1:2*width_a]:
                                                            (input_source_a2 == "DATAA") ?dataa_int[(3*int_width_a)-1:2*int_width_a]:
                                                            (input_source_a2 == "SCANA")? mult_a_wire[(2*int_width_a)-1:int_width_a] :
                                                            (sourcea_wire[2] == 1)? mult_a_wire[(2*int_width_a)-1:int_width_a] : dataa_int[(3*int_width_a)-1:2*int_width_a];

    assign mult_a_pre[(4*int_width_a)-1:3*int_width_a] =    (stratixv_block == 1)? dataa_int[(4*width_a)-1:3*width_a] :
                                                            (input_source_a3 == "DATAA") ?dataa_int[(4*int_width_a)-1:3*int_width_a] :
                                                            (input_source_a3 == "SCANA")? mult_a_wire[(3*int_width_a)-1:2*int_width_a] :
                                                            (sourcea_wire[3] == 1)? mult_a_wire[(3*int_width_a)-1:2*int_width_a] : dataa_int[(4*int_width_a)-1:3*int_width_a];

    assign scanouta = (altera_mult_add_block == 1) ? 'bz : (stratixiii_block == 0) ?
                        mult_a_wire[(number_of_multipliers * int_width_a) - 1 : ((number_of_multipliers-1) * int_width_a) + (int_width_a - width_a)]
                        : scanouta_wire[int_width_a - 1: 0];

    assign scanoutb = (altera_mult_add_block == 1) ? 'bz : (chainout_adder == "YES" && (width_result > width_a + width_b + 8))?
                        mult_b_wire[(number_of_multipliers * int_width_b) - 1  - (int_width_b - width_b) : ((number_of_multipliers-1) * int_width_b)]:
                        mult_b_wire[(number_of_multipliers * int_width_b) - 1 : ((number_of_multipliers-1) * int_width_b) + (int_width_b - width_b)];

    // Clock in all the B input registers
    assign i_scaninb = (stratixii_block == 0)?
                        datab_int[int_width_b-1:0] : scaninb_z;

    assign loopback_wire_temp = {{int_width_b{1'b0}}, loopback_wire[`LOOPBACK_WIRE_WIDTH : width_a]};

    assign mult_b_pre_temp = (input_source_b0 == "LOOPBACK") ? loopback_wire_temp[int_width_b - 1 : 0] : datab_int[int_width_b-1:0];

    assign mult_b_pre[int_width_b-1:0] =    (stratixv_block == 1)? datab_int[width_b-1:0]:
                                            (input_source_b0 == "DATAB")? datab_int[int_width_b-1:0] :
                                            (input_source_b0 == "SCANB")? ((mult0_source_scanin_en == 1'b0)? i_scaninb : datab_int[int_width_b-1:0]) :
                                            (sourceb_wire[0] == 1)? scaninb_z :
                                            mult_b_pre_temp[int_width_b-1:0];

    assign mult_b_pre[(2*int_width_b)-1:int_width_b] =  (stratixv_block == 1)? datab_int[(2*width_b)-1 : width_b ]:
                                                        (input_source_b1 == "DATAB") ?
                                                        ((input_source_b0 == "LOOPBACK") ? datab_int[int_width_b -1 :0] :
                                                        datab_int[(2*int_width_b)-1 : int_width_b ]):
                                                        (input_source_b1 == "SCANB")?
                                                        (stratixiii_block == 1 || stratixv_block == 1) ? mult_b_wire[int_width_b -1 : 0] :
                                                        ((mult1_source_scanin_en == 1'b0)? mult_b_wire[int_width_b -1 : 0] : datab_int[(2*int_width_b)-1 : int_width_b ]) :
                                                        (sourceb_wire[1] == 1)? mult_b_wire[int_width_b -1 : 0] :
                                                        datab_int[(2*int_width_b)-1 : int_width_b ];

    assign mult_b_pre[(3*int_width_b)-1:2*int_width_b] =    (stratixv_block == 1)?datab_int[(3*width_b)-1:2*width_b]:
                                                            (input_source_b2 == "DATAB") ?
                                                            ((input_source_b0 == "LOOPBACK") ? datab_int[(2*int_width_b)-1: int_width_b]:
                                                            datab_int[(3*int_width_b)-1:2*int_width_b]) :
                                                            (input_source_b2 == "SCANB")?
                                                            (stratixiii_block == 1 || stratixv_block == 1) ?  mult_b_wire[(2*int_width_b)-1:int_width_b] :
                                                            ((mult2_source_scanin_en == 1'b0)? mult_b_wire[(2*int_width_b)-1:int_width_b] : datab_int[(3*int_width_b)-1:2*int_width_b]) :
                                                            (sourceb_wire[2] == 1)? mult_b_wire[(2*int_width_b)-1:int_width_b] :
                                                            datab_int[(3*int_width_b)-1:2*int_width_b];

    assign mult_b_pre[(4*int_width_b)-1:3*int_width_b] =    (stratixv_block == 1)?datab_int[(4*width_b)-1:3*width_b]:
                                                            (input_source_b3 == "DATAB") ?
                                                            ((input_source_b0 == "LOOPBACK") ? datab_int[(3*int_width_b) - 1: 2*int_width_b] :
                                                            datab_int[(4*int_width_b)-1:3*int_width_b]) :
                                                            (input_source_b3 == "SCANB")?
                                                            (stratixiii_block == 1 || stratixv_block == 1) ? mult_b_wire[(3*int_width_b)-1:2*int_width_b] :
                                                            ((mult3_source_scanin_en == 1'b0)? mult_b_wire[(3*int_width_b)-1:2*int_width_b] : datab_int[(4*int_width_b)-1:3*int_width_b]):
                                                            (sourceb_wire[3] == 1)? mult_b_wire[(3*int_width_b)-1:2*int_width_b] :
                                                            datab_int[(4*int_width_b)-1:3*int_width_b];

    assign mult_c_pre[int_width_c-1:0] =    (stratixv_block == 1 && (preadder_mode =="INPUT"))? datac_int[int_width_c-1:0]: 0;


    // clock in all the control signals
    assign addsub1_int =    ((port_addnsub1 == "PORT_CONNECTIVITY")?
                            ((multiplier1_direction != "UNUSED") && (addnsub1 ===1'b0 /* converted x or z to 1'b0 */) ? (multiplier1_direction == "ADD" ? 1'b1 : 1'b0) : addnsub1_z) :
                            ((port_addnsub1 == "PORT_USED")? addnsub1_z :
                            (port_addnsub1 == "PORT_UNUSED")? (multiplier1_direction == "ADD" ? 1'b1 : 1'b0) : addnsub1_z));

    assign addsub3_int =    ((port_addnsub3 == "PORT_CONNECTIVITY")?
                            ((multiplier3_direction != "UNUSED") && (addnsub3 ===1'b0 /* converted x or z to 1'b0 */) ? (multiplier3_direction == "ADD" ? 1'b1 : 1'b0) : addnsub3_z) :
                            ((port_addnsub3 == "PORT_USED")? addnsub3_z :
                            (port_addnsub3 == "PORT_UNUSED")?  (multiplier3_direction == "ADD" ? 1'b1 : 1'b0) : addnsub3_z));

    assign sign_a_int = ((port_signa == "PORT_CONNECTIVITY")?
                        ((representation_a != "UNUSED") && (signa ===1'b0 /* converted x or z to 1'b0 */) ? (representation_a == "SIGNED" ? 1'b1 : 1'b0) : signa_z) :
                        (port_signa == "PORT_USED")? signa_z :
                        (port_signa == "PORT_UNUSED")? (representation_a == "SIGNED" ? 1'b1 : 1'b0) : signa_z);

    assign sign_b_int = ((port_signb == "PORT_CONNECTIVITY")?
                        ((representation_b != "UNUSED") && (signb ===1'b0 /* converted x or z to 1'b0 */) ? (representation_b == "SIGNED" ? 1'b1 : 1'b0) : signb_z) :
                        (port_signb == "PORT_USED")? signb_z :
                        (port_signb == "PORT_UNUSED")? (representation_b == "SIGNED" ? 1'b1 : 1'b0) : signb_z);

    assign outround_int = ((output_rounding == "VARIABLE") ? (output_round)
                            : ((output_rounding == "YES") ? 1'b1 : 1'b0));

    assign chainout_round_int = ((chainout_rounding == "VARIABLE") ? chainout_round : ((chainout_rounding == "YES") ? 1'b1 : 1'b0));

    assign outsat_int = ((output_saturation == "VARIABLE") ? output_saturate : ((output_saturation == "YES") ? 1'b1 : 1'b0));

    assign chainout_sat_int = ((chainout_saturation == "VARIABLE") ? chainout_saturate : ((chainout_saturation == "YES") ? 1'b1 : 1'b0));

    assign zerochainout_int = (chainout_adder == "YES")? zero_chainout : 1'b0;

    assign rotate_int = (shift_mode == "VARIABLE") ? rotate : 1'b0;

    assign shiftr_int = (shift_mode == "VARIABLE") ? shift_right : 1'b0;

    assign zeroloopback_int = (input_source_b0 == "LOOPBACK") ? zero_loopback : 1'b0;

    assign accumsload_int = (stratixv_block == 1)? accum_sload :
    						(accumulator == "YES") ?
                            (((output_rounding == "VARIABLE") && (chainout_adder == "NO")) ? output_round : accum_sload)
                            : 1'b0;

    assign chainin_int = chainin;

    assign coeffsel_a_int =  (stratixv_block == 1) ?coefsel0: 3'bx;

    assign coeffsel_b_int =  (stratixv_block == 1) ?coefsel1: 3'bx;

    assign coeffsel_c_int =  (stratixv_block == 1) ?coefsel2: 3'bx;

    assign coeffsel_d_int =  (stratixv_block == 1) ?coefsel3: 3'bx;

    // -----------------------------------------------------------------
    // This is the main block that performs the addition and subtraction
    // -----------------------------------------------------------------

    // need to do MSB extension for cases where the result width is > width_a + width_b
    // for Stratix III family only
    assign result_stxiii_temp = ((width_result - 1 + int_mult_diff_bit) > int_width_result)? ((sign_a_pipe_wire|sign_b_pipe_wire)?
                            {{(result_pad){temp_sum_reg[2*int_width_result - 1]}}, temp_sum_reg[int_width_result + 1:int_mult_diff_bit]}:
                            {{(result_pad){1'b0}}, temp_sum_reg[int_width_result + 1:int_mult_diff_bit]}):
                            temp_sum_reg[width_result - 1 + int_mult_diff_bit:int_mult_diff_bit];

    assign result_stxiii_temp2 = ((width_result - 1 + int_mult_diff_bit) > int_width_result)? ((sign_a_pipe_wire|sign_b_pipe_wire)?
                            {{(result_pad){temp_sum_reg[2*int_width_result - 1]}}, temp_sum_reg[int_width_result:int_mult_diff_bit]}:
                            {{(result_pad){1'b0}}, temp_sum_reg[int_width_result:int_mult_diff_bit]}):
                            temp_sum_reg[width_result - 1 + int_mult_diff_bit:int_mult_diff_bit];

    assign result_stxiii_temp3 = ((width_result - 1 + int_mult_diff_bit) > int_width_result)? ((sign_a_pipe_wire|sign_b_pipe_wire)?
                            {{(result_pad){round_sat_blk_res[2*int_width_result - 1]}}, round_sat_blk_res[int_width_result:int_mult_diff_bit]}:
                            {{(result_pad){1'b0}}, round_sat_blk_res[int_width_result :int_mult_diff_bit]}):
                            round_sat_blk_res[width_result - 1 + int_mult_diff_bit : int_mult_diff_bit];

    assign result_stxiii =  (stratixiii_block == 1 || stratixv_block == 1) ?
                            ((shift_mode != "NO") ? shift_rot_result[`SHIFT_MODE_WIDTH:0] :
                            (chainout_adder == "YES") ? chainout_final_out[width_result - 1 + int_mult_diff_bit: int_mult_diff_bit] :
                            ((((width_a < 36 && width_b < 36) || ((width_a >= 36 || width_b >= 36) && extra_latency == 0)) && output_register == "UNREGISTERED")?
                            ((input_source_b0 == "LOOPBACK") ? loopback_out_wire[int_width_result - 1 : 0] :
                            result_stxiii_temp3[width_result - 1 : 0]) :
                            (extra_latency != 0 && output_register == "UNREGISTERED" && (width_a > 36 || width_b > 36))?
                            result_stxiii_temp2[width_result - 1 : 0] :
                            (input_source_b0 == "LOOPBACK") ? loopback_out_wire[int_width_result - 1 : 0] :
                            result_stxiii_temp[width_result - 1 : 0])) : {(width_result){1'b0}};


    assign result_stxiii_ext = (stratixiii_block == 1 || stratixv_block == 1) ?
                                (((chainout_adder == "YES") || (accumulator == "YES") || (input_source_b0 == "LOOPBACK")) ?
                                result_stxiii :
                                ((number_of_multipliers == 1) && (width_result > width_a + width_b)) ?
                                (((representation_a == "UNSIGNED") && (representation_b == "UNSIGNED") && (unsigned_sub1_overflow_wire == 0 && unsigned_sub3_overflow_wire == 0)) ?
                                {{(result_stxiii_pad){1'b0}}, result_stxiii[result_msb_stxiii : 0]} :
                                {{(result_stxiii_pad){result_stxiii[result_msb_stxiii]}}, result_stxiii[result_msb_stxiii : 0]}) :
                                (((number_of_multipliers == 2) || (input_source_b0 == "LOOPBACK")) && (width_result > width_a + width_b + 1)) ?
                                ((((representation_a == "UNSIGNED") && (representation_b == "UNSIGNED")) && (unsigned_sub1_overflow_wire == 0 && unsigned_sub3_overflow_wire == 0)) ?
                                {{(result_stxiii_pad){1'b0}}, result_stxiii[result_msb_stxiii : 0]} :
                                {{(result_stxiii_pad){result_stxiii[result_msb_stxiii]}}, result_stxiii[result_msb_stxiii : 0]}):
                                ((number_of_multipliers > 2) && (width_result > width_a + width_b + 2)) ?
                                ((((representation_a == "UNSIGNED") && (representation_b == "UNSIGNED")) && (unsigned_sub1_overflow_wire == 0 && unsigned_sub3_overflow_wire == 0)) ?
                                {{(result_stxiii_pad){1'b0}}, result_stxiii[result_msb_stxiii : 0]} :
                                {{(result_stxiii_pad){result_stxiii[result_msb_stxiii]}}, result_stxiii[result_msb_stxiii : 0]}) :
                                result_stxiii) : {width_result {1'b0}};

    assign result_ext = (output_register == "UNREGISTERED")?
                        temp_sum[width_result - 1 :0]: temp_sum_reg[width_result - 1 : 0];


    assign result_stxii_ext_temp = ((width_result - 1 + int_mult_diff_bit) > int_width_result)? ((sign_a_pipe_wire|sign_b_pipe_wire)?
                            {{(result_pad){temp_sum[int_width_result]}}, temp_sum[int_width_result - 1:int_mult_diff_bit]}:
                            {{(result_pad){1'b0}}, temp_sum[int_width_result - 1 :int_mult_diff_bit]}):
                            temp_sum[width_result - 1 + int_mult_diff_bit : int_mult_diff_bit];

    assign result_stxii_ext_temp2 = ((width_result - 1 + int_mult_diff_bit) > int_width_result)? ((sign_a_pipe_wire|sign_b_pipe_wire)?
                            {{(result_pad){temp_sum_reg[int_width_result]}}, temp_sum_reg[int_width_result - 1:int_mult_diff_bit]}:
                            {{(result_pad){1'b0}}, temp_sum_reg[int_width_result - 1:int_mult_diff_bit]}):
                            temp_sum_reg[width_result - 1 + int_mult_diff_bit:int_mult_diff_bit];

    assign result_stxii_ext = (stratixii_block == 0)? result_ext:
                            ( adder3_rounding != "NO" | multiplier01_rounding != "NO" | multiplier23_rounding != "NO" | output_rounding != "NO"| adder1_rounding != "NO" )?
                            (output_register == "UNREGISTERED")?
                            result_stxii_ext_temp[width_result - 1 : 0] :
                            result_stxii_ext_temp2[width_result - 1 : 0] : result_ext;

    assign result = (stratixv_block == 1 ) ? result_stxiii:
                    (stratixiii_block == 1) ?  result_stxiii_ext :
                    (width_result > (width_a + width_b))? result_stxii_ext :
                    (output_register == "UNREGISTERED")?
                    temp_sum[width_result - 1 + int_mult_diff_bit : int_mult_diff_bit]:
                    temp_sum_reg[width_result - 1 + int_mult_diff_bit:int_mult_diff_bit];

    assign mult_is_saturate_vec =   (output_register == "UNREGISTERED")?
                                    mult_saturate_overflow_vec: mult_saturate_overflow_pipe_reg;

    always@(posedge input_reg_a0_wire_clk or posedge multiplier_reg0_wire_clk)
    begin
    if(stratixiii_block == 1)
        if (extra_latency !=0 && output_register == "UNREGISTERED" && (width_a > 36 || width_b > 36))
        begin
            if ((multiplier_register0 != "UNREGISTERED") || (input_register_a0 !="UNREGISTERED"))
                if (((multiplier_reg0_wire_clk  == 1) && (multiplier_reg0_wire_en == 1)) ||  ((input_reg_a0_wire_clk === 1'b1) && (input_reg_a0_wire_en == 1)))
                begin
                    result_pipe [head_result] <= round_sat_blk_res[2*int_width_result - 1 :0];
                    overflow_stat_pipe_reg [head_result] <= overflow_status;
                    unsigned_sub1_overflow_pipe_reg [head_result] <= unsigned_sub1_overflow_mult_reg;
                    unsigned_sub3_overflow_pipe_reg [head_result] <= unsigned_sub1_overflow_mult_reg;
                    head_result <= (head_result +1) % (extra_latency);
                end
        end
    end

    always @(posedge output_reg_wire_clk or posedge output_reg_wire_clr)
    begin
        if (stratixiii_block == 0 && stratixv_block == 0)
        begin
            if (output_reg_wire_clr == 1)
            begin
                temp_sum_reg <= {(2*int_width_result){1'b0}};

                for ( num_stor = extra_latency; num_stor >= 0; num_stor = num_stor - 1 )
                begin
                    result_pipe[num_stor] <= {int_width_result{1'b0}};
                end

                mult_saturate_overflow_pipe_reg <= {4{1'b0}};

                head_result <= 0;
            end
            else if ((output_reg_wire_clk ==1) && (output_reg_wire_en ==1))
            begin

                if (extra_latency == 0)
                begin
                    temp_sum_reg[int_width_result :0] <= temp_sum[int_width_result-1 :0];
                    temp_sum_reg[2*int_width_result - 1 :int_width_result] <= {(2*int_width_result - int_width_result){temp_sum[int_width_result]}};
                end
                else
                begin
                    result_pipe [head_result] <= temp_sum[2*int_width_result-1 :0];
                    head_result <= (head_result +1) % (extra_latency + 1);
                end
                mult_saturate_overflow_pipe_reg <= mult_saturate_overflow_vec;
            end
        end
        else // Stratix III
        begin
            if (chainout_adder == "NO" && shift_mode == "NO") // if chainout and shift block is not used, this will be the output stage
            begin
                if (output_reg_wire_clr == 1)
                begin
                    temp_sum_reg <= {(2*int_width_result){1'b0}};
                    overflow_stat_reg <= 1'b0;
                    unsigned_sub1_overflow_reg <= 1'b0;
                    unsigned_sub3_overflow_reg <= 1'b0;
                    for ( num_stor = extra_latency; num_stor >= 0; num_stor = num_stor - 1 )
                    begin
                        result_pipe[num_stor] <= {int_width_result{1'b0}};
                        result_pipe1[num_stor] <= {int_width_result{1'b0}};
                        overflow_stat_pipe_reg <= 1'b0;
                        unsigned_sub1_overflow_pipe_reg <= 1'b0;
                        unsigned_sub3_overflow_pipe_reg <= 1'b0;
                    end
                    head_result <= 0;

                    if (accumulator == "YES")
                        acc_feedback_reg <= {2*int_width_result{1'b0}};

                    if (input_source_b0 == "LOOPBACK")
                        loopback_wire_reg <= {int_width_result {1'b0}};

                end

                else if ((output_reg_wire_clk ==1) && (output_reg_wire_en ==1))
                begin
                    if (extra_latency == 0)
                    begin
                        temp_sum_reg[2*int_width_result - 1 :0] <= round_sat_blk_res[2*int_width_result - 1 :0];
                        loopback_wire_reg <= round_sat_blk_res[int_width_result + (int_width_b - width_b) - 1 : int_width_b - width_b];
                        overflow_stat_reg <= overflow_status;
                        if(multiplier_register0 != "UNREGISTERED")
                            unsigned_sub1_overflow_reg <= unsigned_sub1_overflow_mult_reg;
                        else
                            unsigned_sub1_overflow_reg <= unsigned_sub1_overflow;
                        if(multiplier_register2 != "UNREGISTERED")
                            unsigned_sub3_overflow_reg <= unsigned_sub3_overflow_mult_reg;
                        else
                            unsigned_sub3_overflow_reg <= unsigned_sub3_overflow;

                        if(stratixv_block)
                        begin
                            if (accumulator == "YES") //|| accum_wire == 1)
                            begin
                    	        acc_feedback_reg <= round_sat_in_result[2*int_width_result-1 : 0];
                            end
                        end

                    end
                    else
                    begin
                        result_pipe [head_result] <= round_sat_blk_res[2*int_width_result - 1 :0];
                        result_pipe1 [head_result] <= round_sat_blk_res[int_width_result + (int_width_b - width_b) - 1 : int_width_b - width_b];
                        overflow_stat_pipe_reg [head_result] <= overflow_status;
                        if(multiplier_register0 != "UNREGISTERED")
                            unsigned_sub1_overflow_pipe_reg [head_result] <= unsigned_sub1_overflow_mult_reg;
                        else
                            unsigned_sub1_overflow_pipe_reg [head_result] <= unsigned_sub1_overflow;

                        if(multiplier_register2 != "UNREGISTERED")
                            unsigned_sub3_overflow_pipe_reg [head_result] <= unsigned_sub3_overflow_mult_reg;
                        else
                            unsigned_sub3_overflow_pipe_reg [head_result] <= unsigned_sub3_overflow;

                        head_result <= (head_result +1) % (extra_latency + 1);
                    end
                    if (accumulator == "YES") //|| accum_wire == 1)
                    begin
                    	acc_feedback_reg <= round_sat_blk_res[2*int_width_result-1 : 0];
                    end

                    loopback_wire_reg <= round_sat_blk_res[int_width_result + (int_width_b - width_b) - 1 : int_width_b - width_b];

                end
            end
            else  // chainout/shift block is used, this is the 2nd stage, chainout/shift block will be the final stage
            begin
                if (output_reg_wire_clr == 1)
                begin
                    chout_shftrot_reg <= {(int_width_result + 1) {1'b0}};
                    if (accumulator == "YES")
                        acc_feedback_reg <= {2*int_width_result{1'b0}};

                end
                else if ((output_reg_wire_clk == 1) && (output_reg_wire_en == 1))
                begin
                    chout_shftrot_reg[(int_width_result - 1) : 0] <= round_sat_blk_res[(int_width_result - 1) : 0];
                    if (accumulator == "YES")
                    begin
                        acc_feedback_reg <= round_sat_blk_res[2*int_width_result-1 : 0];
                    end
                end

                if (output_reg_wire_clr == 1 )
                begin
                    temp_sum_reg <= {(2*int_width_result){1'b0}};
                    overflow_stat_reg <= 1'b0;
                    unsigned_sub1_overflow_reg <= 1'b0;
                    unsigned_sub3_overflow_reg <= 1'b0;
                    for ( num_stor = extra_latency; num_stor >= 0; num_stor = num_stor - 1 )
                    begin
                        result_pipe[num_stor] <= {int_width_result{1'b0}};
                        overflow_stat_pipe_reg <= 1'b0;
                        unsigned_sub1_overflow_pipe_reg <= 1'b0;
                        unsigned_sub3_overflow_pipe_reg <= 1'b0;
                    end
                    head_result <= 0;

                    if (accumulator == "YES" )
                        acc_feedback_reg <= {2*int_width_result{1'b0}};

                    if (input_source_b0 == "LOOPBACK")
                        loopback_wire_reg <= {int_width_result {1'b0}};
                end
                else if ((output_reg_wire_clk ==1) && (output_reg_wire_en ==1))
                begin
                    if (extra_latency == 0)
                    begin
                        temp_sum_reg[2*int_width_result - 1 :0] <= round_sat_blk_res[2*int_width_result - 1 :0];
                        overflow_stat_reg <= overflow_status;
                        if(multiplier_register0 != "UNREGISTERED")
                            unsigned_sub1_overflow_reg <= unsigned_sub1_overflow_mult_reg;
                        else
                            unsigned_sub1_overflow_reg <= unsigned_sub1_overflow;

                        if(multiplier_register2 != "UNREGISTERED")
                        unsigned_sub3_overflow_reg <= unsigned_sub3_overflow_mult_reg;
                        else
                            unsigned_sub3_overflow_reg <= unsigned_sub3_overflow;
                    end
                    else
                    begin
                        result_pipe [head_result] <= round_sat_blk_res[2*int_width_result - 1 :0];
                        overflow_stat_pipe_reg [head_result] <= overflow_status;
                        if(multiplier_register0 != "UNREGISTERED")
                            unsigned_sub1_overflow_pipe_reg <= unsigned_sub1_overflow_mult_reg;
                        else
                            unsigned_sub1_overflow_pipe_reg <= unsigned_sub1_overflow;

                        if(multiplier_register2 != "UNREGISTERED")
                            unsigned_sub3_overflow_pipe_reg <= unsigned_sub1_overflow_mult_reg;
                        else
                            unsigned_sub3_overflow_pipe_reg <= unsigned_sub1_overflow;

                        head_result <= (head_result +1) % (extra_latency + 1);
                    end
                end

            end
        end
    end

    assign head_result_wire = head_result[31:0];

    always @(head_result_wire or result_pipe[head_result_wire])
    begin
        if (extra_latency != 0)
            temp_sum_reg[2*int_width_result - 1 :0] <= result_pipe[head_result_wire];
    end

    always @(head_result_wire or result_pipe1[head_result_wire])
    begin
        if (extra_latency != 0)
            loopback_wire_latency <= result_pipe1[head_result_wire];
    end

    always @(head_result_wire or overflow_stat_pipe_reg[head_result_wire])
    begin
        if (extra_latency != 0)
            overflow_stat_reg <= overflow_stat_pipe_reg[head_result_wire];
    end

    always @(head_result_wire or accum_overflow_stat_pipe_reg[head_result_wire])
    begin
        if (extra_latency != 0)
            accum_overflow_reg <= accum_overflow_stat_pipe_reg[head_result_wire];
    end

    always @(head_result_wire or unsigned_sub1_overflow_pipe_reg[head_result_wire])
    begin
        if (extra_latency != 0)
            unsigned_sub1_overflow_reg <= unsigned_sub1_overflow_pipe_reg[head_result_wire];
    end

    always @(head_result_wire or unsigned_sub3_overflow_pipe_reg[head_result_wire])
    begin
        if (extra_latency != 0)
            unsigned_sub3_overflow_reg <= unsigned_sub3_overflow_pipe_reg;
    end


    always @(mult_res_wire [4 * (int_width_a + int_width_b) -1:0] or
            addsub1_pipe_wire or  addsub3_pipe_wire or
            sign_a_pipe_wire  or  sign_b_pipe_wire or addnsub1_round_pipe_wire or
            addnsub3_round_pipe_wire or sign_a_wire or sign_b_wire)
    begin
        if (stratixiii_block == 0 && stratixv_block == 0)
        begin
            temp_sum =0;
            for (num_mult = 0; num_mult < number_of_multipliers; num_mult = num_mult +1)
            begin

                mult_res_temp = mult_res_wire >> (num_mult * (int_width_a + int_width_b));
                mult_res_ext = ((int_width_result > (int_width_a + int_width_b))?
                                {{(mult_res_pad)
                                {mult_res_temp [int_width_a + int_width_b - 1] &
                                (sign_a_pipe_wire | sign_b_pipe_wire)}}, mult_res_temp}:mult_res_temp);

                if (num_mult == 0)
                    temp_sum = do_add1_level1(0, sign_a_wire, sign_b_wire);

                else if (num_mult == 1)
                begin
                    if (addsub1_pipe_wire)
                        temp_sum = do_add1_level1(0, sign_a_wire, sign_b_wire);
                    else
                        temp_sum = do_sub1_level1(0, sign_a_wire, sign_b_wire);

                    if (stratixii_block == 1)
                    begin
                        // -------------------------------------------------------
                        // Stratix II Rounding support
                        // This block basically carries out the rounding for the
                        // temp_sum. The equation to get the roundout for adder1 and
                        // adder3 is obtained from the Stratix II Mac FFD which is below:
                        // round_adder_constant = (1 << (wfraction - wfraction_round - 1))
                        // roundout[] = datain[] + round_adder_constant
                        // For Stratix II rounding, we round up the bits to 15 bits
                        // or in another word wfraction_round = 15.
                        // --------------------------------------------------------

                        if ((adder1_rounding == "YES") ||
                            ((adder1_rounding == "VARIABLE") && (addnsub1_round_pipe_wire == 1)))
                        begin
                            adder1_round_out = temp_sum + ( 1 << (`ADDER_ROUND_BITS - 1));

                            for (j = (`ADDER_ROUND_BITS - 1); j >= 0; j = j - 1)
                            begin
                                adder1_round_out[j] = 1'b0;
                            end

                        end
                        else
                        begin
                            adder1_round_out = temp_sum;
                        end

                            adder1_result = adder1_round_out;
                    end

                    if (stratixii_block)
                    begin
                        temp_sum = adder1_result;
                    end

                end

                else if (num_mult == 2)
                begin
                    if (stratixii_block == 1)
                    begin
                        adder2_result = mult_res_ext;
                        temp_sum = adder2_result;
                    end
                    else
                        temp_sum = do_add1_level1(0, sign_a_wire, sign_b_wire);
                end
                else if (num_mult == 3 || ((number_of_multipliers == 3) && ((adder3_rounding == "YES") ||
                ((adder3_rounding == "VARIABLE") && (addnsub3_round_pipe_wire == 1)))))
                begin
                    if (addsub3_pipe_wire && num_mult == 3)
                        temp_sum = do_add1_level1(0, sign_a_wire, sign_b_wire);
                    else
                        temp_sum = do_sub1_level1(0, sign_a_wire, sign_b_wire);

                    if (stratixii_block == 1)
                    begin
                        // StratixII rounding support
                        // Please see the description for rounding support in adder1

                        if ((adder3_rounding == "YES") ||
                            ((adder3_rounding == "VARIABLE") && (addnsub3_round_pipe_wire == 1)))
                        begin

                            adder3_round_out = temp_sum + ( 1 << (`ADDER_ROUND_BITS - 1));

                            for (j = (`ADDER_ROUND_BITS - 1); j >= 0; j = j - 1)
                                begin
                                adder3_round_out[j] = 1'b0;
                                end

                        end
                        else
                        begin
                            adder3_round_out = temp_sum;
                            end

                            adder3_result = adder3_round_out;
                    end

                    if (stratixii_block)
                    begin
                        temp_sum = adder1_result + adder3_result;
                        if ((addsub3_pipe_wire == 0) && (sign_a_wire == 0) && (sign_b_wire == 0))
                        begin
                            for (j = int_width_a + int_width_b + 2; j < int_width_result; j = j +1)
                            begin
                                temp_sum[j] = 0;
                            end
                            temp_sum [int_width_a + int_width_b + 1:0] = temp_sum [int_width_a + int_width_b + 1:0];
                        end
                    end
                end
            end

            if ((number_of_multipliers == 3 || number_of_multipliers == 2) && (stratixii_block == 1))
            begin
                temp_sum = adder1_result;
                mult_res_ext = adder2_result;
                temp_sum = (number_of_multipliers == 3)? do_add1_level1(0, sign_a_wire, sign_b_wire) : adder1_result;
                if ((addsub1_pipe_wire == 0) && (sign_a_wire == 0) && (sign_b_wire == 0))
                begin
                    if (number_of_multipliers == 3)
                    begin
                        for (j = int_width_a + int_width_b + 2; j < int_width_result; j = j +1)
                        begin
                            temp_sum[j] = 0;
                        end
                    end
                    else
                    begin
                        for (j = int_width_a + int_width_b + 1; j < int_width_result; j = j +1)
                        begin
                            temp_sum[j] = 0;
                        end
                    end
                end
            end
        end
    end

    // this block simulates the 1st level adder in Stratix III
    always @(mult_res_wire [4 * (int_width_a + int_width_b) -1:0] or sign_a_wire or sign_b_wire)
    begin
        if (stratixiii_block || stratixv_block)
        begin
            adder1_sum = 0;
            adder3_sum = 0;
            for (num_mult = 0; num_mult < number_of_multipliers; num_mult = num_mult +1)
            begin

                mult_res_temp = mult_res_wire >> (num_mult * (int_width_a + int_width_b));
                mult_res_ext = ((int_width_result > (int_width_a + int_width_b))?
                                {{(mult_res_pad)
                                {mult_res_temp [int_width_a + int_width_b - 1] &
                                (sign_a_wire | sign_b_wire)}}, mult_res_temp}:mult_res_temp);

                if (num_mult == 0)
                begin
                    adder1_sum = mult_res_ext;
                    if((sign_a_wire == 0) && (sign_b_wire == 0))
                        adder1_sum = {{(2*int_width_result - int_width_a - int_width_b){1'b0}}, adder1_sum[int_width_a + int_width_b - 1:0]};
                    else
                        adder1_sum = {{(2*int_width_result - int_width_a - int_width_b){adder1_sum[int_width_a + int_width_b - 1]}}, adder1_sum[int_width_a + int_width_b - 1:0]};
                end
                else if (num_mult == 1)
                begin
                    if (multiplier1_direction == "ADD")
                        adder1_sum = do_add1_level1 (0, sign_a_wire, sign_b_wire);
                    else
                        adder1_sum = do_sub1_level1  (0, sign_a_wire, sign_b_wire);
                end
                else if (num_mult == 2)
                begin
                    adder3_sum = mult_res_ext;
                    if((sign_a_wire == 0) && (sign_b_wire == 0))
                        adder3_sum = {{(2*int_width_result - int_width_a - int_width_b){1'b0}}, adder3_sum[int_width_a + int_width_b - 1:0]};
                    else
                        adder3_sum = {{(2*int_width_result - int_width_a - int_width_b){adder3_sum[int_width_a + int_width_b - 1]}}, adder3_sum[int_width_a + int_width_b - 1:0]};
                end
                else if (num_mult == 3)
                begin
                    if (multiplier3_direction == "ADD")
                        adder3_sum = do_add3_level1 (0, sign_a_wire, sign_b_wire);
                    else
                        adder3_sum = do_sub3_level1  (0, sign_a_wire, sign_b_wire);
                end
            end
        end
    end

    // figure out which signal feeds into the 2nd adder/accumulator for Stratix III
    assign adder1_res_wire = (multiplier_register0 == "UNREGISTERED")? adder1_sum: adder1_reg;
    assign adder3_res_wire = (multiplier_register2 == "UNREGISTERED")? adder3_sum: adder3_reg;
    assign unsigned_sub1_overflow_wire = (output_register == "UNREGISTERED")? (multiplier_register0 != "UNREGISTERED")?
                                                        unsigned_sub1_overflow_mult_reg : unsigned_sub1_overflow
                                                        : unsigned_sub1_overflow_reg;
    assign unsigned_sub3_overflow_wire = (output_register == "UNREGISTERED")? (multiplier_register2 != "UNREGISTERED")?
                                                        unsigned_sub3_overflow_mult_reg : unsigned_sub3_overflow
                                                        : unsigned_sub3_overflow_reg;
    assign acc_feedback[(2*int_width_result - 1) : 0] = (accumulator == "YES") ?
                                                        ((output_register == "UNREGISTERED") ? (round_sat_blk_res[2*int_width_result - 1 : 0] & ({2*int_width_result{~accumsload_pipe_wire}})) :
                                                        ((stratixv_block)?(acc_feedback_reg[2*int_width_result - 1 : 0] & ({2*int_width_result{~accumsload_wire}})):(acc_feedback_reg[2*int_width_result - 1 : 0] & ({2*int_width_result{~accumsload_pipe_wire}})))) :
                                                        0;

	assign load_const_value = ((loadconst_value > 63) ||(loadconst_value < 0) ) ?   0: (1 << loadconst_value);

    assign accumsload_sel = (accumsload_wire) ? load_const_value : acc_feedback ;

    assign adder1_systolic_register0 = (systolic_delay3 == "UNREGISTERED")? adder1_res_wire
                                : adder1_res_reg_0;
    always @(posedge systolic3_reg_wire_clk or posedge systolic3_reg_wire_clr)
    begin
        if (stratixv_block == 1)
        begin
            if (systolic3_reg_wire_clr == 1)
            begin
                adder1_res_reg_0[2*int_width_result - 1: 0] <= 0;
            end
            else if ((systolic3_reg_wire_clk == 1) && (systolic3_reg_wire_en == 1))
            begin
                adder1_res_reg_0[2*int_width_result - 1: 0] <= adder1_res_wire;
            end
        end
	end

	assign adder1_systolic_register1 = (systolic_delay3 == "UNREGISTERED")? adder1_res_wire
                                : adder1_res_reg_1;
    always @(posedge output_reg_wire_clk or posedge output_reg_wire_clr)
    begin
        if (stratixv_block == 1)
        begin
            if (output_reg_wire_clr == 1)
            begin
                adder1_res_reg_1[2*int_width_result - 1: 0] <= 0;
            end
            else if ((output_reg_wire_clk == 1) && (output_reg_wire_en == 1))
            begin
                adder1_res_reg_1[2*int_width_result - 1: 0] <= adder1_systolic_register0;
            end
        end
	end

	assign adder1_systolic = (number_of_multipliers == 2)? adder1_res_wire : adder1_systolic_register1;

    // 2nd stage adder/accumulator in Stratix III
    always @(adder1_res_wire[int_width_result - 1 : 0] or adder3_res_wire[int_width_result - 1 : 0] or sign_a_wire or sign_b_wire or accumsload_sel or adder1_systolic or
                acc_feedback[2*int_width_result - 1 : 0] or adder1_res_wire or adder3_res_wire or mult_res_0 or mult_res_1 or mult_res_2 or mult_res_3)
    begin
        if (stratixiii_block || stratixv_block)
        begin
            adder1_res_ext = adder1_res_wire;
            adder3_res_ext = adder3_res_wire;

            if (stratixv_block)
            begin
                if(accumsload_wire)
                begin
            	    round_sat_in_result = adder1_systolic + adder3_res_ext + accumsload_sel;
            	end
            	else
            	begin
            	    if(accumulator == "YES")
            	        round_sat_in_result = adder1_systolic + adder3_res_ext + accumsload_sel;
            	    else
            	        round_sat_in_result = adder1_systolic + adder3_res_ext ;
            	end
            end
            else if (accumulator == "NO")
            begin
                round_sat_in_result =  adder1_res_wire + adder3_res_ext;
            end
            else if ((accumulator == "YES") && (accum_direction == "ADD"))
            begin
                round_sat_in_result = acc_feedback + adder1_res_wire + adder3_res_ext;
            end
            else  // minus mode
            begin
                round_sat_in_result = acc_feedback - adder1_res_wire - adder3_res_ext;
            end
        end
    end

    always @(adder1_res_wire[int_width_result - 1 : 0] or adder3_res_wire[int_width_result - 1 : 0] or sign_a_pipe_wire or sign_b_pipe_wire or
                acc_feedback[2*int_width_result - 1 : 0] or adder1_res_ext or adder3_res_ext)
    begin
        if(accum_width < 2*int_width_result - 1)
            for(i = accum_width; i >= 0; i = i - 1)
                acc_feedback_temp[i] = acc_feedback[i];
        else
        begin
            for(i = 2*int_width_result - 1; i >= 0; i = i - 1)
                acc_feedback_temp[i] = acc_feedback[i];

            for(i = accum_width - 1; i >= 2*int_width_result; i = i - 1)
                acc_feedback_temp[i] = acc_feedback[2*int_width_result - 1];
        end

        if(accum_width + int_mult_diff_bit < 2*int_width_result - 1)
            for(i = accum_width + int_mult_diff_bit; i >= 0; i = i - 1)
            begin
                adder1_res_ext[i] = adder1_res_wire[i];
                adder3_res_temp[i] = adder3_res_wire[i];
            end
        else
        begin
            for(i = 2*int_width_result - 1; i >= 0; i = i - 1)
            begin
                adder1_res_ext[i] = adder1_res_wire[i];
                adder3_res_temp[i] = adder3_res_wire[i];
            end

            for(i = accum_width + int_mult_diff_bit - 1; i >= 2*int_width_result; i = i - 1)
            begin
                if(sign_a_pipe_wire == 1'b1 || sign_b_pipe_wire == 1'b1)
                begin
                    adder1_res_ext[i] = adder1_res_wire[2*int_width_result - 1];
                    adder3_res_temp[i] = adder3_res_wire[2*int_width_result - 1];
                end
                else
                begin
                    adder1_res_ext[i] = 0;
                    adder3_res_temp[i] = 0;
                end
            end
        end


        if(sign_a_pipe_wire == 1'b1 || sign_b_pipe_wire == 1'b1)
        begin
            if(acc_feedback_temp[accum_width - 1 + int_mult_diff_bit] == 1'b1)
                acc_feedback_temp[accum_width + int_mult_diff_bit ] = 1'b1;
            else
                acc_feedback_temp[accum_width + int_mult_diff_bit ] = 1'b0;
        end
        else
        begin
            acc_feedback_temp[accum_width + int_mult_diff_bit ] = 1'b0;
        end

        if(accum_direction == "ADD")
            accum_res_temp[accum_width + int_mult_diff_bit : 0] = adder1_res_ext[accum_width - 1 + int_mult_diff_bit : 0]  + adder3_res_temp[accum_width - 1 + int_mult_diff_bit : 0] ;
        else
            accum_res_temp = acc_feedback_temp[accum_width - 1 + int_mult_diff_bit : 0]  - adder1_res_ext[accum_width - 1 + int_mult_diff_bit : 0] ;

        if(sign_a_pipe_wire == 1'b1 || sign_b_pipe_wire == 1'b1)
        begin
            if(accum_res_temp[accum_width - 1 + int_mult_diff_bit] == 1'b1)
                accum_res_temp[accum_width + int_mult_diff_bit ] = 1'b1;
            else
                accum_res_temp[accum_width + int_mult_diff_bit ] = 1'b0;

            if(adder3_res_temp[accum_width - 1 + int_mult_diff_bit] == 1'b1)
                adder3_res_temp[accum_width + int_mult_diff_bit ] = 1'b1;
            else
                adder3_res_temp[accum_width + int_mult_diff_bit ] = 1'b0;
        end
        /*else
        begin
            accum_res_temp[accum_width + int_mult_diff_bit ] = 1'b0;
        end*/

        if(accum_direction == "ADD")
            accum_res = acc_feedback_temp[accum_width + int_mult_diff_bit  : 0] + accum_res_temp[accum_width + int_mult_diff_bit : 0 ];
        else
            accum_res = accum_res_temp[accum_width + int_mult_diff_bit  : 0] - adder3_res_temp[accum_width + int_mult_diff_bit : 0 ];

        or_sign_wire = 1'b0;
        and_sign_wire = 1'b0;

        if(extra_sign_bit_width >= 1)
        begin
            and_sign_wire = 1'b1;

            for(i = accum_width -lsb_position - 1; i >= accum_width -lsb_position - extra_sign_bit_width; i = i - 1)
            begin
                if(accum_res[i] == 1'b1)
                    or_sign_wire = 1'b1;

                if(accum_res[i] == 1'b0)
                    and_sign_wire = 1'b0;
            end
        end

        if(port_signa == "PORT_USED" || port_signb == "PORT_USED")
        begin
            if(sign_a_pipe_wire == 1'b1 || sign_b_pipe_wire == 1'b1)
            begin
            //signed data
                if(accum_res[44] != accum_res[43])
                    accum_overflow_int = 1'b1;
                else
                    accum_overflow_int = 1'b0;
            end
            else
            begin
            // unsigned data
                if(accum_direction == "ADD")    // addition
                begin
                    if(accum_res[44] == 1'b1)
                        accum_overflow_int = 1'b1;
                    else
                        accum_overflow_int = 1'b0;
                end
                else    // subtraction
                begin
                    if(accum_res[44] == 1'b0)
                        accum_overflow_int = 1'b0;
                    else
                        accum_overflow_int = 1'b0;
                end
            end

            // dynamic sign input

            if(accum_res[bit_position] == 1'b1)
                msb = 1'b1;
            else
                msb = 1'b0;

            if(extra_sign_bit_width >= 1)
            begin
                if((and_sign_wire == 1'b1) && ((!(sign_a_pipe_wire == 1'b1 || sign_b_pipe_wire == 1'b1)) || ((sign_a_pipe_wire == 1'b1 || sign_b_pipe_wire == 1'b1) && (msb == 1'b1))))
                    and_sign_wire = 1'b1;
                else
                    and_sign_wire = 1'b0;

                if ((sign_a_pipe_wire == 1'b1 || sign_b_pipe_wire == 1'b1) && (msb == 1'b1))
                    or_sign_wire = 1'b1;
            end

            //operation XOR
            if ((or_sign_wire != and_sign_wire) || accum_overflow_int == 1'b1)
                accum_overflow = 1'b1;
            else
                accum_overflow = 1'b0;
        end
        else if(representation_a == "SIGNED" || representation_b == "SIGNED")
        begin
        //signed data
            if (accum_res[44] != accum_res[43])
                accum_overflow_int = 1'b1;
            else
                accum_overflow_int = 1'b0;

        //operation XOR
            if ((or_sign_wire != and_sign_wire) || accum_overflow_int == 1'b1)
                accum_overflow = 1'b1;
            else
                accum_overflow = 1'b0;
        end
        else
        begin
        // unsigned data
            if(accum_direction == "ADD")
            begin
            // addition
                if (accum_res[44] == 1'b1)
                    accum_overflow_int = 1'b1;
                else
                    accum_overflow_int = 1'b0;
            end
            else
            begin
            // subtraction
                if (accum_res[44] == 1'b0)
                    accum_overflow_int = 1'b1;
                else
                    accum_overflow_int = 1'b0;
            end

            if(or_sign_wire == 1'b1 || accum_overflow_int == 1'b1)
                accum_overflow = 1'b1;
            else
                accum_overflow = 1'b0;
        end
    end

    always @(posedge output_reg_wire_clk or posedge output_reg_wire_clr)
    begin
        if (stratixiii_block == 1 || stratixv_block == 1)
        begin
            if (output_reg_wire_clr == 1)
            begin
                for ( num_stor = extra_latency; num_stor >= 0; num_stor = num_stor - 1 )
                begin
                    accum_overflow_stat_pipe_reg <= 1'b0;
                    accum_overflow_reg <= 1'b0;
                end
                head_result <= 0;
            end
            else if ((output_reg_wire_clk ==1) && (output_reg_wire_en ==1))
            begin
                if (extra_latency == 0)
                begin
                    accum_overflow_reg <= accum_overflow;
                end
                else
                begin
                    accum_overflow_stat_pipe_reg [head_result] <= accum_overflow;
                    head_result <= (head_result +1) % (extra_latency + 1);
                end
            end
        end
    end

    // model the saturation and rounding block in Stratix III
    // the rounding block feeds into the saturation block
    always @(round_sat_in_result[int_width_result : 0] or outround_pipe_wire or outsat_pipe_wire or sign_a_int or sign_b_int or adder3_res_ext or adder1_res_ext or acc_feedback or round_sat_in_result)
    begin
        if (stratixiii_block || stratixv_block)
        begin
            round_happen = 0;
            // Rounding part
            if (output_rounding == "NO")
            begin
                round_block_result = round_sat_in_result;
            end
            else
            begin
                if (((output_rounding == "VARIABLE") && (outround_pipe_wire == 1)) || (output_rounding == "YES"))
                begin
                    if (round_sat_in_result[round_position - 1] == 1'b1) // guard bit
                    begin
                        if (output_round_type == "NEAREST_INTEGER") // round to nearest integer
                        begin
                            round_block_result = round_sat_in_result + (1 << (round_position));
                        end
                        else
                        begin // round to nearest even
                            stick_bits_or = 0;
                            for (rnd_bit_cnt = (round_position - 2); rnd_bit_cnt >= 0; rnd_bit_cnt = rnd_bit_cnt - 1)
                            begin
                                stick_bits_or = (stick_bits_or | round_sat_in_result[rnd_bit_cnt]);
                            end
                            // if any sticky bits = 1, then do the rounding
                            if (stick_bits_or == 1'b1)
                            begin
                                round_block_result = round_sat_in_result + (1 << (round_position));
                            end
                            else // all sticky bits are 0, look at the LSB to determine rounding
                            begin
                                if (round_sat_in_result[round_position] == 1'b1) // LSB is 1, odd number, so round
                                begin
                                    round_block_result = round_sat_in_result + ( 1 << (round_position));
                                end
                                else
                                    round_block_result = round_sat_in_result;
                            end
                        end
                    end
                    else // guard bit is 0, don't round
                        round_block_result = round_sat_in_result;

                    // if unsigned number comes into the rounding & saturation block, X the entire output since unsigned numbers
                    // are invalid
                    if ((sign_a_int == 0) && (sign_b_int == 0) &&
                        (((port_signa == "PORT_USED") && (port_signb == "PORT_USED" )) ||
                        ((representation_a != "UNUSED") && (representation_b != "UNUSED"))))
                    begin
                        for (sat_all_bit_cnt = 0; sat_all_bit_cnt <= int_width_result; sat_all_bit_cnt = sat_all_bit_cnt + 1)
                        begin
                            round_block_result[sat_all_bit_cnt] = 1'b0 /* converted x or z to 1'b0 */;
                        end
                    end

                    // force the LSBs beyond the rounding position to "X"
                    if(accumulator == "NO" && input_source_b0 != "LOOPBACK")
                    begin
                        for (rnd_bit_cnt = (round_position - 1); rnd_bit_cnt >= 0; rnd_bit_cnt = rnd_bit_cnt - 1)
                        begin
                            round_block_result[rnd_bit_cnt] = 1'b0 /* converted x or z to 1'b0 */;
                        end
                    end

                    round_happen = 1;
                end
                else
                    round_block_result = round_sat_in_result;
            end

            // prevent the previous overflow_status being taken into consideration when determining the overflow
			if ((overflow_status == 1'b0) && (port_output_is_overflow == "PORT_UNUSED") && (chainout_adder == "NO"))
                overflow_status_bit_pos = int_width_result + int_mult_diff_bit - 1;
            else
                overflow_status_bit_pos = int_width_result + 1;


            // Saturation part
            if (output_saturation == "NO")
                sat_block_result = round_block_result;
            else
            begin
                overflow_status = 0;
                if (((output_saturation == "VARIABLE") && (outsat_pipe_wire == 1)) || (output_saturation == "YES"))
                begin
                    overflow_status = 0;
                    if (round_block_result[2*int_width_result - 1] == 1'b0) // carry bit is 0 - positive number
                    begin
                        for (sat_bit_cnt = (int_width_result); sat_bit_cnt >= (saturation_position); sat_bit_cnt = sat_bit_cnt - 1)
                        begin
                            if (sat_bit_cnt != overflow_status_bit_pos)
                            begin
                                overflow_status = overflow_status | round_block_result[sat_bit_cnt];
                            end
                        end
                    end

                    else // carry bit is 1 - negative number
                    begin
                        for (sat_bit_cnt = (int_width_result); sat_bit_cnt >= (saturation_position); sat_bit_cnt = sat_bit_cnt - 1)
                        begin
                            if (sat_bit_cnt != overflow_status_bit_pos)
                            begin
                                overflow_status = overflow_status | (~round_block_result[sat_bit_cnt]);
                            end
                        end

                        if ((output_saturate_type == "SYMMETRIC") && (overflow_status == 1'b0))
                        begin
                            overflow_status = 1'b1;
                            if (round_happen == 1)
                                for (sat_bit_cnt = (saturation_position - 1); sat_bit_cnt >= (round_position); sat_bit_cnt = sat_bit_cnt - 1)
                                begin
                                    overflow_status = overflow_status & (~(round_block_result [sat_bit_cnt]));
                                end
                            else
                                for (sat_bit_cnt = (saturation_position - 1); sat_bit_cnt >= 0 ; sat_bit_cnt = sat_bit_cnt - 1)
                            begin
                                    overflow_status = overflow_status & (~(round_block_result [sat_bit_cnt]));
                            end
                        end
                    end

                    if (overflow_status == 1'b1)
                    begin
                        if (round_block_result[2*int_width_result - 1] == 1'b0) // positive number
                        begin
                            if (port_output_is_overflow == "PORT_UNUSED") // set the overflow status to the MSB of the results
                                sat_block_result[int_width_a + int_width_b - 1] = overflow_status;
                            else if (accumulator == "NO")
                                sat_block_result[int_width_a + int_width_b - 1] = 1'b0 /* converted x or z to 1'b0 */;

                            for (sat_bit_cnt = (int_width_a + int_width_b); sat_bit_cnt >= (saturation_position); sat_bit_cnt = sat_bit_cnt - 1)
                            begin
                                sat_block_result[sat_bit_cnt] = 1'b0;  // set the leading bits on the left of the saturation position to 0
                            end

                            // if rounding is used, the LSBs after the rounding position should be "X-ed", from above
                            if ((round_happen == 1))
                            begin
                                for (sat_bit_cnt = (saturation_position - 1); sat_bit_cnt >= round_position; sat_bit_cnt = sat_bit_cnt - 1)
                                begin
                                    sat_block_result[sat_bit_cnt] = 1'b1; // set the trailing bits on the right of the saturation position to 1
                                end
                            end
                            else // rounding not used
                            begin
                                for (sat_bit_cnt = (saturation_position - 1); sat_bit_cnt >= 0; sat_bit_cnt = sat_bit_cnt - 1)
                                begin
                                    sat_block_result[sat_bit_cnt] = 1'b1; // set the trailing bits on the right of the saturation position to 1
                                end
                            end
                            sat_block_result = {{(2*int_width_result - int_width_a - int_width_b){1'b0}}, sat_block_result[int_width_a + int_width_b : 0]};
                        end
                        else // negative number
                        begin
                            if (port_output_is_overflow == "PORT_UNUSED") // set the overflow status to the MSB of the results
                                sat_block_result[int_width_a + int_width_b - 1] = overflow_status;
                            else if (accumulator == "NO")
                                sat_block_result[int_width_a + int_width_b - 1] = 1'b0 /* converted x or z to 1'b0 */;

                            for (sat_bit_cnt = (int_width_a + int_width_b); sat_bit_cnt >= saturation_position; sat_bit_cnt = sat_bit_cnt - 1)
                            begin
                                sat_block_result[sat_bit_cnt] = 1'b1; // set the sign bits to 1
                            end

                            // if rounding is used, the LSBs after the rounding position should be "X-ed", from above
                            if ((output_rounding != "NO") && (output_saturate_type == "SYMMETRIC"))
                            begin
                                for (sat_bit_cnt = (saturation_position - 1); sat_bit_cnt >= round_position; sat_bit_cnt = sat_bit_cnt - 1)
                                begin
                                    sat_block_result[sat_bit_cnt] = 1'b0; // set all bits to 0
                                end

                                if (accumulator == "NO")
                                    for (sat_bit_cnt = (round_position - 1); sat_bit_cnt >= 0; sat_bit_cnt = sat_bit_cnt - 1)
                                    begin
                                        sat_block_result[sat_bit_cnt] = 1'b0 /* converted x or z to 1'b0 */;
                                    end
                                else
                                    for (sat_bit_cnt = (round_position - 1); sat_bit_cnt >= 0; sat_bit_cnt = sat_bit_cnt - 1)
                                    begin
                                        sat_block_result[sat_bit_cnt] = 1'b0;
                                end
                            end
                            else
                            begin
                                for (sat_bit_cnt = (saturation_position - 1); sat_bit_cnt >= 0; sat_bit_cnt = sat_bit_cnt - 1)
                                begin
                                    sat_block_result[sat_bit_cnt] = 1'b0; // set all bits to 0
                                end
                            end

                            if ((output_rounding != "NO") && (output_saturate_type == "SYMMETRIC"))
                                sat_block_result[round_position] = 1'b1;
                            else if (output_saturate_type == "SYMMETRIC")
                                sat_block_result[int_mult_diff_bit] = 1'b1;

                            sat_block_result = {{(2*int_width_result - int_width_a - int_width_b){1'b1}}, sat_block_result[int_width_a + int_width_b : 0]};

                        end
                    end
                    else
                    begin
                        sat_block_result = round_block_result;

                        if (port_output_is_overflow == "PORT_UNUSED" && chainout_adder == "NO" && (output_saturation == "VARIABLE") && (outsat_pipe_wire == 1)) // set the overflow status to the MSB of the results
                            sat_block_result[int_width_result + int_mult_diff_bit - 1] = overflow_status;

                        if (sat_block_result[sat_msb] == 1'b1) // negative number - checking for a special case
                        begin
                            if (output_saturate_type == "SYMMETRIC")
                            begin
                                sat_bits_or = 0;

                                for (sat_bit_cnt = (int_width_a + int_width_b - 2); sat_bit_cnt >= round_position; sat_bit_cnt = sat_bit_cnt - 1)
                                begin
                                    sat_bits_or = sat_bits_or | sat_block_result[sat_bit_cnt];
                                end

                            end
                        end
                    end

                    // if unsigned number comes into the rounding & saturation block, X the entire output since unsigned numbers
                    // are invalid
                    if ((sign_a_int == 0) && (sign_b_int == 0) &&
                        (((port_signa == "PORT_USED") && (port_signb == "PORT_USED" )) ||
                        ((representation_a != "UNUSED") && (representation_b != "UNUSED"))))
                    begin
                        for (sat_all_bit_cnt = 0; sat_all_bit_cnt <= int_width_result; sat_all_bit_cnt = sat_all_bit_cnt + 1)
                        begin
                            sat_block_result[sat_all_bit_cnt] = 1'b0 /* converted x or z to 1'b0 */;
                        end
                    end
                end
                else if ((output_saturation == "VARIABLE") && (outsat_pipe_wire == 0))
                begin
                    sat_block_result = round_block_result;
                    overflow_status = 0;
                end
                else
                    sat_block_result = round_block_result;
            end
        end
    end

    always @(sat_block_result)
    begin
        round_sat_blk_res <= sat_block_result;
    end

    assign overflow = (accumulator !="NO" && output_saturation =="NO")?
                                (output_register == "UNREGISTERED")?
                                accum_overflow : accum_overflow_reg :
                                (output_register == "UNREGISTERED")? overflow_status : overflow_stat_reg;

    // model the chainout mode of Stratix III
    assign chainout_adder_in_wire[int_width_result - 1 : 0] =   (chainout_adder == "YES") ?
                                                                ((output_register == "UNREGISTERED") ?
                                                                    round_sat_blk_res[int_width_result - 1 : 0] : chout_shftrot_reg[int_width_result - 1 : 0]) : 0;

    assign chainout_add_result[int_width_result : 0] = (chainout_adder == "YES") ? ((chainout_adder_in_wire[int_width_result - 1 : 0] + chainin_int[width_chainin-1 : 0])) : 0;

    // model the chainout saturation and chainout rounding block in Stratix III
    // the rounding block feeds into the saturation block
    always @(chainout_add_result[int_width_result : 0] or chainout_round_out_wire or chainout_sat_out_wire or sign_a_int or sign_b_int)
    begin
        if (stratixiii_block || stratixv_block)
        begin
            cho_round_happen = 0;
            // Rounding part
            if (chainout_rounding == "NO")
                chainout_round_block_result = chainout_add_result;
            else
            begin
                if (((chainout_rounding == "VARIABLE") && (chainout_round_out_wire == 1)) || (chainout_rounding == "YES"))
                begin
                    overflow_checking = chainout_add_result[int_width_result - 1];
                    if (chainout_add_result[chainout_round_position - 1] == 1'b1) // guard bit
                    begin
                        if (output_round_type == "NEAREST_INTEGER") // round to nearest integer
                        begin
                            round_checking = 1'b1;
                            chainout_round_block_result = chainout_add_result + (1 << (chainout_round_position));
                        end
                        else
                        begin // round to nearest even
                            cho_stick_bits_or = 0;
                            for (cho_rnd_bit_cnt = (chainout_round_position - 2); cho_rnd_bit_cnt >= 0; cho_rnd_bit_cnt = cho_rnd_bit_cnt - 1)
                            begin
                                cho_stick_bits_or = (cho_stick_bits_or | chainout_add_result[cho_rnd_bit_cnt]);
                            end
                            round_checking = cho_stick_bits_or;
                            // if any sticky bits = 1, then do the rounding
                            if (cho_stick_bits_or == 1'b1)
                            begin
                                chainout_round_block_result = chainout_add_result + (1 << (chainout_round_position));
                            end
                            else // all sticky bits are 0, look at the LSB to determine rounding
                            begin
                                if (chainout_add_result[chainout_round_position] == 1'b1) // LSB is 1, odd number, so round
                                begin
                                    chainout_round_block_result = chainout_add_result + ( 1 << (chainout_round_position));
                                end
                                else
                                    chainout_round_block_result = chainout_add_result;
                            end
                        end
                    end
                    else // guard bit is 0, don't round
                        chainout_round_block_result = chainout_add_result;

                    // if unsigned number comes into the rounding & saturation block, X the entire output since unsigned numbers
                    // are invalid
                    if ((sign_a_int == 0) && (sign_b_int == 0) &&
                        (((port_signa == "PORT_USED") && (port_signb == "PORT_USED" )) ||
                        ((representation_a != "UNUSED") && (representation_b != "UNUSED"))))
                    begin
                        for (cho_sat_all_bit_cnt = 0; cho_sat_all_bit_cnt <= int_width_result; cho_sat_all_bit_cnt = cho_sat_all_bit_cnt + 1)
                        begin
                            chainout_round_block_result[cho_sat_all_bit_cnt] = 1'b0 /* converted x or z to 1'b0 */;
                        end
                    end

                    // force the LSBs beyond the rounding position to "X"
                    if(accumulator == "NO")
                        for (cho_rnd_bit_cnt = (chainout_round_position - 1); cho_rnd_bit_cnt >= 0; cho_rnd_bit_cnt = cho_rnd_bit_cnt - 1)
                        begin
                            chainout_round_block_result[cho_rnd_bit_cnt] = 1'b0 /* converted x or z to 1'b0 */;
                        end
                    else
                        for (cho_rnd_bit_cnt = (chainout_round_position - 1); cho_rnd_bit_cnt >= 0; cho_rnd_bit_cnt = cho_rnd_bit_cnt - 1)
                        begin
                            chainout_round_block_result[cho_rnd_bit_cnt] = 1'b1;
                        end

                    cho_round_happen = 1;
                end
                else
                    chainout_round_block_result = chainout_add_result;
            end

            // Saturation part
            if (chainout_saturation == "NO")
                chainout_sat_block_result = chainout_round_block_result;
            else
            begin
            chainout_overflow_status = 0;
                if (((chainout_saturation == "VARIABLE") && (chainout_sat_out_wire == 1)) || (chainout_saturation == "YES"))
                begin
                    if((((chainout_rounding == "VARIABLE") && (chainout_round_out_wire == 1)) || (chainout_rounding == "YES")) && round_checking == 1'b1 && width_saturate_sign == 1 && width_result == `RESULT_WIDTH)
                        if(chainout_round_block_result[int_width_result - 1] != overflow_checking)
                            chainout_overflow_status = 1'b1;
                        else
                            chainout_overflow_status = 1'b0;
                    else if (chainout_round_block_result[chainout_sat_msb] == 1'b0) // carry bit is 0 - positive number
                    begin
                            for (cho_sat_bit_cnt = int_width_result - 1; cho_sat_bit_cnt >= (chainout_saturation_position); cho_sat_bit_cnt = cho_sat_bit_cnt - 1)
                        begin
                            chainout_overflow_status = chainout_overflow_status | chainout_round_block_result[cho_sat_bit_cnt];
                        end
                    end
                    else // carry bit is 1 - negative number
                    begin
                            for (cho_sat_bit_cnt = int_width_result - 1; cho_sat_bit_cnt >= (chainout_saturation_position); cho_sat_bit_cnt = cho_sat_bit_cnt - 1)
                        begin
                            chainout_overflow_status = chainout_overflow_status | (~chainout_round_block_result[cho_sat_bit_cnt]);
                        end

                        if ((output_saturate_type == "SYMMETRIC") && (chainout_overflow_status == 1'b0))
                        begin
                            chainout_overflow_status = 1'b1;
                            if (cho_round_happen)
                            begin
                                for (cho_sat_bit_cnt = (chainout_saturation_position - 1); cho_sat_bit_cnt >= (chainout_round_position); cho_sat_bit_cnt = cho_sat_bit_cnt - 1)
                                begin
                                    chainout_overflow_status = chainout_overflow_status & (~(chainout_round_block_result [cho_sat_bit_cnt]));
                                end
                            end
                            else
                        begin
                                for (cho_sat_bit_cnt = (chainout_saturation_position - 1); cho_sat_bit_cnt >= 0 ; cho_sat_bit_cnt = cho_sat_bit_cnt - 1)
                            begin
                                    chainout_overflow_status = chainout_overflow_status & (~(chainout_round_block_result [cho_sat_bit_cnt]));
                                end
                            end
                        end
                    end

                    if (chainout_overflow_status == 1'b1)
                    begin
                        if((((chainout_rounding == "VARIABLE") && (chainout_round_out_wire == 1)) || (chainout_rounding == "YES")) && round_checking == 1'b1 && width_saturate_sign == 1 && width_result == `RESULT_WIDTH)
                        begin
                            if (chainout_round_block_result[chainout_sat_msb] == 1'b1) // positive number
                        begin
                            if (port_chainout_sat_is_overflow == "PORT_UNUSED") // set the overflow status to the MSB of the results
                                    chainout_sat_block_result[int_width_result - 1] = chainout_overflow_status;
                                else
                                chainout_sat_block_result[int_width_result - 1] = chainout_overflow_status;

                                for (cho_sat_bit_cnt = (int_width_result - 1); cho_sat_bit_cnt >= (chainout_saturation_position); cho_sat_bit_cnt = cho_sat_bit_cnt - 1)
                                begin
                                    chainout_sat_block_result[cho_sat_bit_cnt] = 1'b0;  // set the leading bits on the left of the saturation position to 0
                                end

                                // if rounding is used, the LSBs after the rounding position should be "X-ed", from above
                                if ((cho_round_happen))
                                begin
                                    for (cho_sat_bit_cnt = (chainout_saturation_position - 1); cho_sat_bit_cnt >= 0; cho_sat_bit_cnt = cho_sat_bit_cnt - 1)
                                    begin
                                        chainout_sat_block_result[cho_sat_bit_cnt] = 1'b1; // set the trailing bits on the right of the saturation position to 1
                                    end
                                end
                                else
                                begin
                                    for (cho_sat_bit_cnt = (chainout_saturation_position - 1); cho_sat_bit_cnt >= 0; cho_sat_bit_cnt = cho_sat_bit_cnt - 1)
                                    begin
                                        chainout_sat_block_result[cho_sat_bit_cnt] = 1'b1; // set the trailing bits on the right of the saturation position to 1
                                    end
                                end
                            end
                            else // negative number
                            begin
                                if (port_chainout_sat_is_overflow == "PORT_UNUSED") // set the overflow status to the MSB of the results
                                chainout_sat_block_result[int_width_result - 1] = chainout_overflow_status;
                            else
                                    chainout_sat_block_result[int_width_result - 1] = chainout_overflow_status;

                                for (cho_sat_bit_cnt = (int_width_result - 2); cho_sat_bit_cnt >= chainout_saturation_position; cho_sat_bit_cnt = cho_sat_bit_cnt - 1)
                                begin
                                    chainout_sat_block_result[cho_sat_bit_cnt] = 1'b1; // set the sign bits to 1
                                end

                                // if rounding is used, the LSBs after the rounding position should be "X-ed", from above
                                if ((chainout_rounding != "NO") && (output_saturate_type == "SYMMETRIC"))
                                begin
                                    for (cho_sat_bit_cnt = (chainout_saturation_position - 1); cho_sat_bit_cnt >= chainout_round_position; cho_sat_bit_cnt = cho_sat_bit_cnt - 1)
                                    begin
                                        chainout_sat_block_result[cho_sat_bit_cnt] = 1'b0;
                                    end

                                    if(accumulator == "NO")
                                        for (cho_sat_bit_cnt = (chainout_round_position - 1); cho_sat_bit_cnt >= 0; cho_sat_bit_cnt = cho_sat_bit_cnt - 1)
                                        begin
                                            chainout_sat_block_result[cho_sat_bit_cnt] = 1'b0 /* converted x or z to 1'b0 */;
                                        end
                                    else
                                        for (cho_sat_bit_cnt = (chainout_round_position - 1); cho_sat_bit_cnt >= 0; cho_sat_bit_cnt = cho_sat_bit_cnt - 1)
                                        begin
                                            chainout_sat_block_result[cho_sat_bit_cnt] = 1'b0;
                                        end

                                end
                                else
                                begin
                                    for (cho_sat_bit_cnt = (chainout_saturation_position - 1); cho_sat_bit_cnt >= 0; cho_sat_bit_cnt = cho_sat_bit_cnt - 1)
                                    begin
                                        chainout_sat_block_result[cho_sat_bit_cnt] = 1'b0;
                                    end
                                end

                                if ((chainout_rounding != "NO") && (output_saturate_type == "SYMMETRIC"))
                                    chainout_sat_block_result[chainout_round_position] = 1'b1;
                                else if (output_saturate_type == "SYMMETRIC")
                                    chainout_sat_block_result[int_mult_diff_bit] = 1'b1;
                            end
                        end
                        else
                        begin
                        if (chainout_round_block_result[chainout_sat_msb] == 1'b0) // positive number
                        begin
                            if (port_chainout_sat_is_overflow == "PORT_UNUSED") // set the overflow status to the MSB of the results
                                chainout_sat_block_result[int_width_result - 1] = chainout_overflow_status;
                            else
                                chainout_sat_block_result[int_width_result - 1] = chainout_overflow_status;

                                for (cho_sat_bit_cnt = (int_width_result - 1); cho_sat_bit_cnt >= (chainout_saturation_position); cho_sat_bit_cnt = cho_sat_bit_cnt - 1)
                            begin
                                chainout_sat_block_result[cho_sat_bit_cnt] = 1'b0;  // set the leading bits on the left of the saturation position to 0
                            end

                            // if rounding is used, the LSBs after the rounding position should be "X-ed", from above
                            if ((cho_round_happen))
                            begin
                                for (cho_sat_bit_cnt = (chainout_saturation_position - 1); cho_sat_bit_cnt >= 0; cho_sat_bit_cnt = cho_sat_bit_cnt - 1)
                                begin
                                    chainout_sat_block_result[cho_sat_bit_cnt] = 1'b1; // set the trailing bits on the right of the saturation position to 1
                                end
                            end
                            else
                            begin
                                for (cho_sat_bit_cnt = (chainout_saturation_position - 1); cho_sat_bit_cnt >= 0; cho_sat_bit_cnt = cho_sat_bit_cnt - 1)
                                begin
                                    chainout_sat_block_result[cho_sat_bit_cnt] = 1'b1; // set the trailing bits on the right of the saturation position to 1
                                end
                            end
                        end
                        else // negative number
                        begin
                            if (port_chainout_sat_is_overflow == "PORT_UNUSED") // set the overflow status to the MSB of the results
                                chainout_sat_block_result[int_width_result - 1] = chainout_overflow_status;
                            else
                                chainout_sat_block_result[int_width_result - 1] = chainout_overflow_status;

                            for (cho_sat_bit_cnt = (int_width_result - 2); cho_sat_bit_cnt >= chainout_saturation_position; cho_sat_bit_cnt = cho_sat_bit_cnt - 1)
                            begin
                                chainout_sat_block_result[cho_sat_bit_cnt] = 1'b1; // set the sign bits to 1
                            end

                            // if rounding is used, the LSBs after the rounding position should be "X-ed", from above
                            if ((cho_round_happen) || (output_saturate_type == "SYMMETRIC"))
                            begin
                                for (cho_sat_bit_cnt = (chainout_saturation_position - 1); cho_sat_bit_cnt >= chainout_round_position; cho_sat_bit_cnt = cho_sat_bit_cnt - 1)
                                begin
                                    chainout_sat_block_result[cho_sat_bit_cnt] = 1'b0;
                                end

                                for (cho_sat_bit_cnt = (chainout_round_position - 1); cho_sat_bit_cnt >= 0; cho_sat_bit_cnt = cho_sat_bit_cnt - 1)
                                begin
                                    chainout_sat_block_result[cho_sat_bit_cnt] = 1'b0;
                                end
                            end
                            else
                            begin
                                for (cho_sat_bit_cnt = (chainout_saturation_position - 1); cho_sat_bit_cnt >= 0; cho_sat_bit_cnt = cho_sat_bit_cnt - 1)
                                begin
                                    chainout_sat_block_result[cho_sat_bit_cnt] = 1'b0;
                                end
                            end

                            if ((chainout_rounding != "NO") && (output_saturate_type == "SYMMETRIC"))
                                chainout_sat_block_result[chainout_round_position] = 1'b1;
                            else if (output_saturate_type == "SYMMETRIC")
                                chainout_sat_block_result[int_mult_diff_bit] = 1'b1;
                        end
                    end
                    end
                    else
                    begin
                        chainout_sat_block_result = chainout_round_block_result;
                        if (chainout_sat_block_result[chainout_sat_msb] == 1'b1) // negative number - checking for a special case
                        begin
                            if (output_saturate_type == "SYMMETRIC")
                            begin
                                cho_sat_bits_or = 0;

                                for (cho_sat_bit_cnt = (int_width_result - 2); cho_sat_bit_cnt >= chainout_round_position; cho_sat_bit_cnt = cho_sat_bit_cnt - 1)
                                begin
                                    cho_sat_bits_or = cho_sat_bits_or | chainout_sat_block_result[cho_sat_bit_cnt];
                                end

                                if ((cho_sat_bits_or == 1'b0) && (chainout_sat_block_result[int_width_result - 1] == 1'b1)) // this means all bits are 0
                                begin
                                    chainout_sat_block_result[chainout_round_position] = 1'b1;
                                end
                            end
                        end
                    end
                    // if unsigned number comes into the rounding & saturation block, X the entire output since unsigned numbers
                    // are invalid
                    if ((sign_a_int == 0) && (sign_b_int == 0) &&
                        (((port_signa == "PORT_USED") && (port_signb == "PORT_USED" )) ||
                        ((representation_a != "UNUSED") && (representation_b != "UNUSED"))))
                    begin
                        for (cho_sat_all_bit_cnt = 0; cho_sat_all_bit_cnt <= int_width_result; cho_sat_all_bit_cnt = cho_sat_all_bit_cnt + 1)
                        begin
                            chainout_sat_block_result[cho_sat_all_bit_cnt] = 1'b0 /* converted x or z to 1'b0 */;
                        end
                    end
                end
                else
                    chainout_sat_block_result = chainout_round_block_result;
            end
        end
    end

    always @(chainout_sat_block_result)
    begin
        chainout_rnd_sat_blk_res <= chainout_sat_block_result;
    end

    assign chainout_sat_overflow = (chainout_register == "UNREGISTERED")? chainout_overflow_status : chainout_overflow_stat_reg;

    // model the chainout stage in Stratix III
    always @(posedge chainout_reg_wire_clk or posedge chainout_reg_wire_clr)
    begin
        if (chainout_reg_wire_clr == 1)
        begin
            chainout_output_reg <= {int_width_result{1'b0}};
            chainout_overflow_stat_reg <= 1'b0;
        end
        else if ((chainout_reg_wire_clk == 1) && (chainout_reg_wire_en == 1))
        begin
            chainout_output_reg <= chainout_rnd_sat_blk_res;
            chainout_overflow_stat_reg <= chainout_overflow_status;
        end
    end

    assign chainout_output_wire[int_width_result:0] = (chainout_register == "UNREGISTERED") ?
                                                        chainout_rnd_sat_blk_res[int_width_result-1:0] : chainout_output_reg[int_width_result-1:0];

    always @(zerochainout_wire or chainout_output_wire[int_width_result:0])
    begin
        chainout_final_out <= chainout_output_wire & {(int_width_result){~zerochainout_wire}};
    end

    // model the shift & rotate block in Stratix III
    assign shift_rot_blk_in_wire[int_width_result - 1: 0] = (shift_mode != "NO") ? ((output_register == "UNREGISTERED") ?
                                                            round_sat_blk_res[int_width_result - 1 : 0] : chout_shftrot_reg[int_width_result - 1: 0]) : 0;


    always @(shift_rot_blk_in_wire[int_width_result - 1:0] or shiftr_out_wire or rotate_out_wire)
    begin
        if (stratixiii_block )
        begin
            // left shifting
            if ((shift_mode == "LEFT") || ((shift_mode == "VARIABLE") && (shiftr_out_wire == 0) && (rotate_out_wire == 0)))
            begin
                shift_rot_result <= shift_rot_blk_in_wire[shift_partition - 1:0];
            end
            // right shifting
            else if ((shift_mode == "RIGHT") || ((shift_mode == "VARIABLE") && (shiftr_out_wire == 1) && (rotate_out_wire == 0)))
            begin
                shift_rot_result <= shift_rot_blk_in_wire[shift_msb : shift_partition];
            end
            // rotate mode
            else if ((shift_mode == "ROTATION") || ((shift_mode == "VARIABLE") && (shiftr_out_wire == 0) && (rotate_out_wire == 1)))
            begin
                shift_rot_result <= (shift_rot_blk_in_wire[shift_msb : shift_partition] | shift_rot_blk_in_wire[shift_partition - 1:0]);
            end
        end
    end

    // loopback path
    assign loopback_out_wire[int_width_result - 1:0] = (output_register == "UNREGISTERED") ?
                                round_sat_blk_res[int_width_result + (int_width_b - width_b) - 1 : int_width_b - width_b] :
                                (extra_latency == 0)? loopback_wire_reg[int_width_result - 1 : 0] : loopback_wire_latency[int_width_result - 1 : 0];

    assign loopback_out_wire_feedback [int_width_result - 1:0] = (output_register == "UNREGISTERED") ?
                                round_sat_blk_res[int_width_result + (int_width_b - width_b) - 1 : int_width_b - width_b] : loopback_wire_reg[int_width_result - 1 : 0];

    always @(loopback_out_wire_feedback[int_width_result - 1:0] or zeroloopback_out_wire)
    begin
        loopback_wire[int_width_result -1:0] <= {(int_width_result){~zeroloopback_out_wire}} & loopback_out_wire_feedback[int_width_result - 1:0];
    end

endmodule  // end of ALTMULT_ADD

