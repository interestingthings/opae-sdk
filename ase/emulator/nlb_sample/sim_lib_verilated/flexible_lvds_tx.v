// Created by altera_lib_mf.pl from altera_mf.v
// END OF MODULE


//START_MODULE_NAME----------------------------------------------------
//
// Module Name     :   flexible_lvds_tx
//
// Description     :   flexible lvds transmitter
//
// Limitation      :   Only available to Cyclone and Cyclone II
//                     families.
//
// Results expected:   Serialized output data.
//
//END_MODULE_NAME----------------------------------------------------

// BEGINNING OF MODULE
`timescale 1 ps / 1 ps

// MODULE DECLARATION
/*verilator lint_off CASEX*/
/*verilator lint_off COMBDLY*/
/*verilator lint_off INITIALDLY*/
/*verilator lint_off LITENDIAN*/
/*verilator lint_off MULTIDRIVEN*/
/*verilator lint_off UNOPTFLAT*/
/*verilator lint_off BLKANDNBLK*/
module flexible_lvds_tx (
    tx_in,          // input serial data
    tx_fastclk,     // fast clock from pll
    tx_slowclk,     // slow clock from pll
    tx_regclk,      // clock for registering input data
    tx_locked,      // locked signal from PLL
    pll_areset,     // Reset signal to clear the registers
    pll_outclock,   // output clock from pll for generating tx_outclock
    tx_out,          // deserialized output data
    tx_outclock
);

// GLOBAL PARAMETER DECLARATION
    parameter number_of_channels = 1;
    parameter deserialization_factor = 4;
    parameter registered_input = "ON";
    parameter use_new_coreclk_ckt = "FALSE";
    parameter outclock_multiply_by = 1;
    parameter outclock_duty_cycle = 50;
    parameter outclock_divide_by = 1;
    parameter use_self_generated_outclock = "FALSE";

// LOCAL PARAMETER DECLARATION
    parameter REGISTER_WIDTH = deserialization_factor*number_of_channels;
    parameter DOUBLE_DESER = deserialization_factor*2;
    parameter LOAD_CNTR_MODULUS = (deserialization_factor % 2 == 1) ?
                                    deserialization_factor : (deserialization_factor/2);

// INPUT PORT DECLARATION
    input [REGISTER_WIDTH -1: 0] tx_in;
    input tx_fastclk;
    input tx_slowclk;
    input tx_regclk;
    input tx_locked;
    input pll_areset;
    input pll_outclock;

// OUTPUT PORT DECLARATION
    output [number_of_channels -1 :0] tx_out;
    output tx_outclock;

// INTERNAL REGISTERS DECLARATION
    reg [REGISTER_WIDTH -1 : 0]     tx_reg;
    reg [(REGISTER_WIDTH*2) -1 : 0] tx_reg2;
    reg [REGISTER_WIDTH -1 : 0]     tx_shift_reg;
    reg [(REGISTER_WIDTH*2) -1 : 0] tx_shift_reg2;
    reg [REGISTER_WIDTH -1 :0] h_sync_a;
    reg [(REGISTER_WIDTH*2) -1 :0] sync_b_reg;
    reg [number_of_channels -1 :0] tx_in_chn;
    reg [number_of_channels -1 :0] dataout_h;
    reg [number_of_channels -1 :0] dataout_l;
    reg [number_of_channels -1 :0] dataout_tmp;
    reg [number_of_channels -1 :0] tx_ddio_out;
    reg [(number_of_channels*2) -1:0] stage1_a;
    reg [(number_of_channels*2) -1:0] stage1_b;
    reg [(number_of_channels*2) -1:0] stage2;
    reg [number_of_channels-1:0] tx_reg_2ary [deserialization_factor-1:0];
    reg [number_of_channels-1:0] tx_in_2ary [deserialization_factor-1:0];
    reg tx_slowclk_dly;
    reg start_sm_p2s;
    reg tx_outclock_tmp;
    reg [deserialization_factor -1 :0] outclk_shift_l;
    reg [deserialization_factor -1 :0] outclk_shift_h;
    reg [deserialization_factor -1 :0] outclk_data_l;
    reg [deserialization_factor -1 :0] outclk_data_h;
    reg outclock_l;
    reg outclock_h;
    reg sync_dffe;
    reg load_enable;

// INTERNAL WIRE DECLARATION
    wire [REGISTER_WIDTH -1 : 0] tx_in_int;
    wire [(REGISTER_WIDTH*2) -1 : 0] tx_in_int2;


// LOCAL INTEGER DECLARATION
    integer i;
    integer i1;
    integer i2;
    integer i3;
    integer i4;
    integer x;
    integer x2;
    integer x3;
    integer sm_p2s;
    integer outclk_load_cntr;
    integer load_cntr;
    integer h_ff;
    integer h_us_ff;
    integer l_s_ff;
    integer l_ff;
    integer l_us_ff;
    integer h_s_ff;

// INITIAL CONSTRUCT BLOCK
    initial
    begin : INITIALIZATION
        tx_reg = {REGISTER_WIDTH{1'b0}};
        tx_reg2 = {(REGISTER_WIDTH*2){1'b0}};

        tx_shift_reg = {REGISTER_WIDTH{1'b0}};
        tx_shift_reg2 = {(REGISTER_WIDTH*2){1'b0}};

        dataout_h = {number_of_channels{1'b0}};
        dataout_l = {number_of_channels{1'b0}};
        dataout_tmp = {number_of_channels{1'b0}};
        tx_ddio_out = {number_of_channels{1'b0}};
        stage1_a = {number_of_channels{1'b0}};
        stage1_b = {number_of_channels{1'b0}};
        stage2 = {number_of_channels{1'b0}};
        h_sync_a = {REGISTER_WIDTH{1'b0}};
        sync_b_reg = {(REGISTER_WIDTH*2){1'b0}};

        for (i = 0;  i < deserialization_factor; i = i +1)
        begin
            tx_reg_2ary[i] = {number_of_channels {1'b0}};
            tx_in_2ary[i] = {number_of_channels {1'b0}};
        end

        load_cntr = 0;
        h_ff = 0;
        h_us_ff = 0;
        l_s_ff = 0;
        l_ff = 0;
        l_us_ff = 0;
        h_s_ff = 0;
        sm_p2s = 0;
        tx_outclock_tmp = 1'b0;
        outclk_load_cntr = 0;
        outclock_l = 1'b0;
        outclock_h = 1'b0;
        sync_dffe = 1'b0;
        load_enable = 1'b0;

        if ((deserialization_factor%2 == 1) ||
            (((deserialization_factor == 6) ||
            (deserialization_factor == 10)) &&
            (outclock_multiply_by == 2) &&
            (outclock_divide_by == deserialization_factor)))
        begin
            if (outclock_multiply_by == 2)
            begin
                outclk_data_l = (deserialization_factor == 5) ? ((use_new_coreclk_ckt == "TRUE") ? 22 : 13) :
                                (deserialization_factor == 7) ? ((use_new_coreclk_ckt == "TRUE") ? 102 : 27) :
                                (deserialization_factor == 9) ? ((use_new_coreclk_ckt == "TRUE") ? 206 : 115) :
                                (deserialization_factor == 6) ? 9 :
                                (deserialization_factor == 10) ? 99 : 0;
                outclk_data_h = (deserialization_factor == 5) ? ((use_new_coreclk_ckt == "TRUE") ? 21 : 11) :
                                (deserialization_factor == 7) ? ((use_new_coreclk_ckt == "TRUE") ? 108 : 51) :
                                (deserialization_factor == 9) ? ((use_new_coreclk_ckt == "TRUE") ? 460 : 103) :
                                (deserialization_factor == 6) ? 27 :
                                (deserialization_factor == 10) ? 231 : 0;
            end
            else
            begin
                if (outclock_duty_cycle != 50)
                begin
                    outclk_data_l = (deserialization_factor == 5) ? ((use_new_coreclk_ckt == "TRUE") ? 25 : 28) :
                                    (deserialization_factor == 7) ? ((use_new_coreclk_ckt == "TRUE") ? 113 : 120) :
                                    (deserialization_factor == 9) ? ((use_new_coreclk_ckt == "TRUE") ? 124 : 31) : 0;
                    outclk_data_h = (deserialization_factor == 5) ? ((use_new_coreclk_ckt == "TRUE") ? 25: 25) :
                                    (deserialization_factor == 7) ? ((use_new_coreclk_ckt == "TRUE") ? 113 : 113) :
                                    (deserialization_factor == 9) ? ((use_new_coreclk_ckt == "TRUE") ? 124 : 31) : 0;
                end
                else
                begin
                    outclk_data_l = (deserialization_factor == 5) ? ((use_new_coreclk_ckt == "TRUE") ? 24 : 28) :
                                    (deserialization_factor == 7) ? ((use_new_coreclk_ckt == "TRUE") ? 112 : 120) :
                                    (deserialization_factor == 9) ? ((use_new_coreclk_ckt == "TRUE") ? 60 : 15) :
                                    (deserialization_factor == 6) ? 54 :
                                    (deserialization_factor == 10) ? 924 : 0;
                    outclk_data_h = (deserialization_factor == 5) ? ((use_new_coreclk_ckt == "TRUE") ? 25 : 24) :
                                    (deserialization_factor == 7) ? ((use_new_coreclk_ckt == "TRUE") ? 113 : 112) :
                                    (deserialization_factor == 9) ? ((use_new_coreclk_ckt == "TRUE") ? 124 : 31) :
                                    (deserialization_factor == 6) ? 36 :
                                    (deserialization_factor == 10) ? 792 : 0;
                end
            end
        end
        else
        begin
            if (deserialization_factor == 4)
                outclk_data_l = (outclock_divide_by == 2) ? 5 : (outclock_divide_by == 4) ? 12 : 0;
            else if (deserialization_factor == 6)
                outclk_data_l = (outclock_divide_by == 2) ? 42 : (outclock_divide_by == 6) ? 56 : 0;
            else if (deserialization_factor == 8)
                outclk_data_l = (outclock_divide_by == 2) ? 170 : (outclock_divide_by == 4) ? 51 : (outclock_divide_by == 8) ? 240 : 0 ;
            else if (deserialization_factor == 10)
                outclk_data_l = (outclock_divide_by == 2) ? 682 : (outclock_divide_by == 10) ? 992 : 0;
            else if (deserialization_factor == 5)
                outclk_data_l = (outclock_divide_by == 5) ? 19 : 0;
            else if (deserialization_factor == 7)
                outclk_data_l = (outclock_divide_by == 7) ? 120 : 0;
            else if (deserialization_factor == 9)
                outclk_data_l = (outclock_divide_by == 9) ? 391 : 0;

            outclk_data_h = outclk_data_l;
        end
        outclk_shift_l = outclk_data_l;
        outclk_shift_h = outclk_data_h;

    end //INITIALIZATION


// ALWAYS CONSTRUCT BLOCK

    // For each data channel, input data are separated into 2 data
    // stream which will be transmitted on different edge of input clock.
    always @ (posedge tx_fastclk or posedge pll_areset)
    begin : DDIO_OUT_POS
        if (pll_areset)
        begin
            dataout_h <= {number_of_channels{1'b0}};
            dataout_l <= {number_of_channels{1'b0}};
            dataout_tmp <= {number_of_channels{1'b0}};
        end
        else
        begin
            if ((deserialization_factor % 2) == 0)
            begin
                for (i1 = 0;  i1 < number_of_channels; i1 = i1 +1)
                begin
                    dataout_h[i1] <= tx_shift_reg[(i1+1)*deserialization_factor-1];
                    dataout_l[i1] <= tx_shift_reg[(i1+1)*deserialization_factor-2];
                    dataout_tmp[i1] <= tx_shift_reg[(i1+1)*deserialization_factor-1];
                end
            end
            else
            begin
                if (use_new_coreclk_ckt == "FALSE")
                begin
                    for (i1 = 0;  i1 < number_of_channels; i1 = i1 +1)
                    begin
                        dataout_h[i1] <= tx_shift_reg2[(i1+1)*DOUBLE_DESER-1];
                        dataout_l[i1] <= tx_shift_reg2[(i1+1)*DOUBLE_DESER-2];
                        dataout_tmp[i1] <= tx_shift_reg2[(i1+1)*DOUBLE_DESER-1];
                    end
                end
                else
                begin
                    dataout_h <= stage2[number_of_channels*2-1 : number_of_channels];
                    dataout_l <= stage2[number_of_channels-1 : 0];
                    dataout_tmp <= stage2[number_of_channels*2-1 : number_of_channels];
                end
            end
        end
    end // DDIO_OUT_POS

    always @ (negedge tx_fastclk or posedge pll_areset)
    begin : DDIO_OUT_NEG
        if (pll_areset)
            dataout_tmp = {number_of_channels{1'b0}};
        else
            dataout_tmp <= dataout_l;
    end // DDIO_OUT_NEG

    always @ (tx_in_int)
    begin
        for (x3=0; x3 < deserialization_factor; x3 = x3+1)
        begin
            for (i4=0; i4 < number_of_channels; i4 = i4+1)
                tx_in_chn[i4] = tx_in_int[i4*deserialization_factor + x3];

            tx_in_2ary[x3] = tx_in_chn;
        end
    end


    // Loading input data to shift register
    always @ (posedge tx_fastclk or posedge pll_areset)
    begin  : SHIFTREG
        if (pll_areset)
        begin
            tx_shift_reg <= {REGISTER_WIDTH{1'b0}};
            tx_shift_reg2 <= {(REGISTER_WIDTH*2){1'b0}};
            sm_p2s <= 0;
            stage1_a <= {number_of_channels{1'b0}};
            stage1_b <= {number_of_channels{1'b0}};
            stage2 <= {number_of_channels{1'b0}};

            for (i = 0;  i < deserialization_factor; i = i +1)
            begin
                tx_reg_2ary[i] <= {number_of_channels {1'b0}};
            end
        end
        else
        begin
            // Implementation for even deserialization factor.
            if ((deserialization_factor % 2) == 0)
            begin

                if(load_enable == 1'b1)
                    tx_shift_reg <= tx_in_int;
                else
                begin
                    for (i2= 0; i2 < number_of_channels; i2 = i2+1)
                    begin
                        for (x=deserialization_factor-1; x >1; x=x-1)
                            tx_shift_reg[x + (i2 * deserialization_factor)] <=
                                tx_shift_reg [x-2 + (i2 * deserialization_factor)];
                    end
                end
            end
            else // Implementation for odd deserialization factor.
            begin
                if (use_new_coreclk_ckt == "FALSE")
                begin

                    if(load_enable == 1'b1)
                        tx_shift_reg2 <= tx_in_int2;
                    else
                    begin
                        for (i2= 0; i2 < number_of_channels; i2 = i2+1)
                        begin
                            for (x=DOUBLE_DESER-1; x >1; x=x-1)
                                tx_shift_reg2[x + (i2 * DOUBLE_DESER)] <=
                                    tx_shift_reg2 [x-2 + (i2 * DOUBLE_DESER)];
                        end
                    end
                end
                else
                begin
                    // state machine counter
                    if (((sm_p2s == 0) && start_sm_p2s) || (sm_p2s != 0))
                        sm_p2s <= (sm_p2s + 1) % deserialization_factor;

                    // synchronization register
                    if (((sm_p2s == 0) && start_sm_p2s) || (sm_p2s == deserialization_factor/2 + 1))
                    begin
                        for (x=0; x < deserialization_factor; x = x+1)
                            tx_reg_2ary[x] <= tx_in_2ary[x];
                    end

                    // stage 1a register
                    if ((sm_p2s > 0) && (sm_p2s < deserialization_factor/2 +1))
                        stage1_a <= {tx_reg_2ary[deserialization_factor - 2*sm_p2s + 1], tx_reg_2ary[deserialization_factor - 2*sm_p2s]};
                    else if (sm_p2s == deserialization_factor/2 + 1)
                        stage1_a <= {tx_reg_2ary[0], {number_of_channels{1'b0}}};

                    // stage 1b register
                    if (((sm_p2s == 0) && start_sm_p2s))
                        stage1_b <= {tx_reg_2ary[1], tx_reg_2ary[0]};
                    else if ((sm_p2s > deserialization_factor /2 + 1) && (sm_p2s < deserialization_factor))
                        stage1_b <= {tx_reg_2ary[(deserialization_factor - sm_p2s)*2 + 1], tx_reg_2ary[(deserialization_factor - sm_p2s)*2]};

                    // stage 2 register
                    if ((sm_p2s > 1) && (sm_p2s < deserialization_factor/2 +2))
                        stage2 <= stage1_a;
                    else if (((sm_p2s == 0) && start_sm_p2s) || (sm_p2s == 1) ||
                        ((sm_p2s > deserialization_factor/2 + 2) && (sm_p2s < deserialization_factor)))
                        stage2 <= stage1_b;
                    else if (sm_p2s == deserialization_factor/2 + 2)
                        stage2 <= {stage1_a[number_of_channels*2-1 : number_of_channels], tx_reg_2ary[deserialization_factor - 1]};

                end
            end
        end
    end // SHIFTREG

    // register the tx_slowclk
    always @ (posedge tx_fastclk)
    begin
        tx_slowclk_dly <= tx_slowclk;
    end

    always @ (tx_slowclk or tx_slowclk_dly)
    begin
        if ((tx_slowclk_dly == 1'b0) && (tx_slowclk == 1'b1))
            start_sm_p2s <= 1'b1;
        else start_sm_p2s <= 1'b0;
    end

    // loading data to synchronization register
    always @ (posedge tx_slowclk or posedge pll_areset)
    begin : SYNC_REG_POS
        if (pll_areset)
        begin
            h_sync_a <= {REGISTER_WIDTH{1'b0}};
//            tx_outclock_tmp <= 1'b0;
        end
        else
        begin
            h_sync_a <= tx_in;
//            tx_outclock_tmp <= 1'b1;
        end
    end // SYNC_REG_POS

    always @ (negedge tx_slowclk or posedge pll_areset)
    begin : SYNC_REG_NEG
        if (pll_areset)
        begin
            sync_b_reg <= {(REGISTER_WIDTH*2){1'b0}};
        end
        else
        begin
            for (i3= 0; i3 < number_of_channels; i3 = i3+1)
            begin
                for (x2=0; x2 < deserialization_factor; x2=x2+1)
                begin
                    sync_b_reg[x2 + (((i3 * 2) + 1) * deserialization_factor)] <=
                        h_sync_a[x2 + (i3 * deserialization_factor)];
                    sync_b_reg[x2 + (i3 * DOUBLE_DESER)] <=
                        tx_in[x2 + (i3 * deserialization_factor)];
                end
            end
        end
//        tx_outclock_tmp <= 1'b0;
    end // SYNC_REG_NEG

    // loading data to input register
    always @ (posedge tx_regclk or posedge pll_areset)
    begin : IN_REG
        if (pll_areset)
        begin
            tx_reg = {REGISTER_WIDTH{1'b0}};
            tx_reg2 = {(REGISTER_WIDTH*2){1'b0}};
        end
        else
        begin
            if (((deserialization_factor % 2) == 0) || (use_new_coreclk_ckt == "TRUE"))
                tx_reg  <= tx_in;
            else
                tx_reg2 <= sync_b_reg;
        end
    end // IN_REG

    // generate outclock
    always @ (posedge tx_fastclk or posedge pll_areset)
    begin
        if (pll_areset)
            outclk_load_cntr <= 0;
        else
            outclk_load_cntr <= (outclk_load_cntr + 1) % deserialization_factor;

    end

    // generate outclock
    always @ (posedge pll_outclock or posedge pll_areset)
    begin
        if (pll_areset)
        begin
            outclk_shift_l <= {deserialization_factor {1'b0}};
            outclk_shift_h <= {deserialization_factor {1'b0}};
        end
        else
        begin
            if (outclk_load_cntr == 0)
            begin
                outclk_shift_l <= outclk_data_l;
                outclk_shift_h <= outclk_data_h;
            end
            else
            begin
                outclk_shift_l <= outclk_shift_l >> 1;
                outclk_shift_h <= outclk_shift_h >> 1;
            end
        end
    end

    always @ (posedge pll_outclock or posedge pll_areset)
    begin
        if (pll_areset)
        begin
            outclock_h <= 1'b0;
            outclock_l <= 1'b0;
            tx_outclock_tmp <= 1'b0;
        end
        else
        begin
            if (outclock_divide_by == 1)
            begin
                outclock_h <= 1'b1;
                outclock_l <= 1'b0;
                tx_outclock_tmp <= 1'b1;
            end
            else
            begin
                outclock_h <= outclk_shift_h[0];
                outclock_l <= outclk_shift_l[0];
                tx_outclock_tmp <= outclk_shift_h;
            end
        end
    end

    always @ (negedge pll_outclock or posedge pll_areset)
    begin
        if (pll_areset)
            tx_outclock_tmp <= 1'b0;
        else
            tx_outclock_tmp <= outclock_l;
    end

    // new synchronization circuit to generate the load enable pulse
    always @ (posedge tx_slowclk)
    begin
        sync_dffe <= !sync_dffe;
    end

    always @ (posedge tx_fastclk or posedge pll_areset)
    begin
        if (pll_areset)
        begin
            load_cntr <= 0;
        end
        else
        begin
            if (sync_dffe)
                load_cntr <= (load_cntr +1) % LOAD_CNTR_MODULUS;
            else
                load_cntr <= (LOAD_CNTR_MODULUS + load_cntr - 1) % LOAD_CNTR_MODULUS;
        end
    end

    always @ (posedge tx_fastclk)
    begin
        if (sync_dffe)
        begin
            h_ff <= load_cntr;
            h_us_ff <= h_ff;
            l_s_ff <= l_us_ff;

        end
        else
        begin
            l_ff <= load_cntr;
            l_us_ff <= l_ff;
            h_s_ff <= h_us_ff;

        end

        load_enable <= (((h_ff == h_s_ff) & sync_dffe) | ((l_ff == l_s_ff) & !sync_dffe));
    end

// CONTINOUS ASSIGNMENT
    assign tx_in_int  = (registered_input == "OFF") ? tx_in : tx_reg;
    assign tx_in_int2 = (registered_input == "OFF") ? sync_b_reg : tx_reg2;
    assign tx_out = dataout_tmp;
    assign tx_outclock = (use_self_generated_outclock == "TRUE") ? tx_outclock_tmp : pll_outclock;


endmodule // flexible_lvds_tx

