// Created by altera_lib_mf.pl from altera_mf.v
// END OF MODULE

//START_MODULE_NAME-------------------------------------------------------------
//
// Module Name     :   stratixiii_lvds_rx_dpa
//
// Description     :   Simulation model for Stratix III DPA block.
//
// Limitation      :   Only available to Stratix III.
//
// Results expected:   Retimed data, dpa clock, enable and lock signal with the selected phase.
//
//
//END_MODULE_NAME---------------------------------------------------------------

/*verilator lint_off CASEX*/
/*verilator lint_off COMBDLY*/
/*verilator lint_off INITIALDLY*/
/*verilator lint_off LITENDIAN*/
/*verilator lint_off MULTIDRIVEN*/
/*verilator lint_off UNOPTFLAT*/
/*verilator lint_off BLKANDNBLK*/
module stratixiii_lvds_rx_dpa (
    rx_in,
    rx_fastclk,
    rx_enable,
    rx_dpa_reset,
    rx_dpa_hold,
    rx_out,
    rx_dpa_clk,
    rx_dpa_loaden,
    rx_dpa_locked
);

// GLOBAL PARAMETER DECLARATION
    parameter enable_soft_cdr_mode = "OFF";
    parameter sim_dpa_is_negative_ppm_drift = "OFF";
    parameter sim_dpa_net_ppm_variation = 0;
    parameter enable_dpa_align_to_rising_edge_only = "OFF";
    parameter enable_dpa_initial_phase_selection = "OFF";
    parameter dpa_initial_phase_value = 0;

// LOCAL PARAMETER DECLARATION
    parameter INITIAL_PHASE_SELECT = (enable_dpa_initial_phase_selection == "ON") &&
                                    (dpa_initial_phase_value > 0) &&
                                    (dpa_initial_phase_value <= 7)
                                    ? dpa_initial_phase_value : 0;
    parameter PHASE_NUM = 8;

// INPUT PORT DECLARATION
    input rx_in;
    input rx_fastclk;
    input rx_enable;
    input rx_dpa_reset;
    input rx_dpa_hold;

// OUTPUT PORT DECLARATION
    output rx_out;
    output rx_dpa_clk;
    output rx_dpa_loaden;
    output rx_dpa_locked;


// INTERNAL REGISTERS DECLARATION
    reg  first_clkin_edge_detect;
    reg [PHASE_NUM-1 : 0] dpa_clk_tmp;
    reg [PHASE_NUM-1 : 0] dpa_loaden;
    reg rx_dpa_clk;
    reg rx_dpa_locked;
    reg rx_in_reg0;
    reg rx_in_reg1;
    reg [PHASE_NUM-1 : 0] dpa_dataout_tmp;
    reg dpa_locked_tmp;
    reg rx_out;
    reg rx_out_int;



// LOCAL INTEGER/REAL DECLARATION
    integer count_value;
    integer count;
    integer ppm_offset;
    real clk_period, last_clk_period;
    real last_clkin_edge;
    real counter_reset_value;


// INITIAL CONSTRUCT BLOCK
    initial
    begin
        first_clkin_edge_detect = 1'b0;

        if(sim_dpa_net_ppm_variation != 0)
        begin
            counter_reset_value = 1000000/(sim_dpa_net_ppm_variation  * 8);
            count_value =  counter_reset_value;
        end

        rx_dpa_locked    = 1'b0;
        dpa_locked_tmp   = 1'b0;
        dpa_clk_tmp      = {PHASE_NUM{1'b0}};
        dpa_loaden       = {PHASE_NUM{1'b0}};

        count = 0;
        ppm_offset = 0;
        dpa_dataout_tmp = 1'b0;

        dpa_dataout_tmp = {PHASE_NUM{1'b0}};
    end

// ALWAYS CONSTRUCT BLOCK

    always @(posedge rx_fastclk)
    begin
    // Determine the clock frequency
        if (first_clkin_edge_detect == 1'b0)
            begin
                first_clkin_edge_detect = 1'b1;
            end
        else
            begin
                last_clk_period = clk_period;
                clk_period = $realtime - last_clkin_edge;
            end
        last_clkin_edge = $realtime;

        //assign dpa lock
        if(((clk_period ==last_clk_period) ||(clk_period == last_clk_period-1) || (clk_period ==last_clk_period +1)) && (clk_period != 0) && (last_clk_period != 0))
            dpa_locked_tmp = 1'b1;
        else
            dpa_locked_tmp = 1'b0;
    end

    //assign phase shifted clock
    always @ (rx_fastclk)
    begin
        dpa_clk_tmp[0] <= rx_fastclk;
        dpa_clk_tmp[1] <= #(clk_period * 0.125) rx_fastclk;
        dpa_clk_tmp[2] <= #(clk_period * 0.25)  rx_fastclk;
        dpa_clk_tmp[3] <= #(clk_period * 0.375) rx_fastclk;
        dpa_clk_tmp[4] <= #(clk_period * 0.5)   rx_fastclk;
        dpa_clk_tmp[5] <= #(clk_period * 0.625) rx_fastclk;
        dpa_clk_tmp[6] <= #(clk_period * 0.75)  rx_fastclk;
        dpa_clk_tmp[7] <= #(clk_period * 0.875) rx_fastclk;
    end

    //assign phase shifted enable
    always @ (rx_enable)
    begin
        dpa_loaden[0] <= rx_enable;
        dpa_loaden[1] <= #(clk_period * 0.125) rx_enable;
        dpa_loaden[2] <= #(clk_period * 0.25)  rx_enable;
        dpa_loaden[3] <= #(clk_period * 0.375) rx_enable;
        dpa_loaden[4] <= #(clk_period * 0.5)   rx_enable;
        dpa_loaden[5] <= #(clk_period * 0.625) rx_enable;
        dpa_loaden[6] <= #(clk_period * 0.75)  rx_enable;
        dpa_loaden[7] <= #(clk_period * 0.875) rx_enable;
    end

    //assign phase shifted data
    always @ (rx_in_reg1)
    begin
        dpa_dataout_tmp[0] <= rx_in_reg1;
        dpa_dataout_tmp[1] <= #(clk_period * 0.125) rx_in_reg1;
        dpa_dataout_tmp[2] <= #(clk_period * 0.25)  rx_in_reg1;
        dpa_dataout_tmp[3] <= #(clk_period * 0.375) rx_in_reg1;
        dpa_dataout_tmp[4] <= #(clk_period * 0.5)   rx_in_reg1;
        dpa_dataout_tmp[5] <= #(clk_period * 0.625) rx_in_reg1;
        dpa_dataout_tmp[6] <= #(clk_period * 0.75)  rx_in_reg1;
        dpa_dataout_tmp[7] <= #(clk_period * 0.875) rx_in_reg1;
    end

    always @(posedge dpa_clk_tmp[INITIAL_PHASE_SELECT])
    begin
        rx_in_reg0 <= rx_in;
        rx_in_reg1 <= rx_in_reg0;
    end

    always @ (dpa_dataout_tmp or ppm_offset or rx_dpa_reset)
    begin

        if (enable_soft_cdr_mode == "OFF")
            rx_out_int <= dpa_dataout_tmp[0];
        else
        begin
            if (rx_dpa_reset == 1'b1)
                rx_out_int <= {1'b0};
            else
                if (sim_dpa_is_negative_ppm_drift == "ON")
                    rx_out_int <= dpa_dataout_tmp[ppm_offset % PHASE_NUM];
                else if (ppm_offset == 0)
                    rx_out_int <= dpa_dataout_tmp[0];
                else
                    rx_out_int <= #(clk_period * 0.125 * ppm_offset) dpa_dataout_tmp[0];
        end
    end

    always @ (rx_out_int)
    begin
        rx_out <= rx_out_int;
    end

    always @ (dpa_clk_tmp or ppm_offset or rx_dpa_reset)
    begin

        if (enable_soft_cdr_mode == "OFF")
            rx_dpa_clk <= dpa_clk_tmp[INITIAL_PHASE_SELECT];
        else
        begin
            if (rx_dpa_reset == 1'b1)
                rx_dpa_clk <= 1'b0;
            else
                if (sim_dpa_is_negative_ppm_drift == "ON")
                    rx_dpa_clk <= dpa_clk_tmp[(INITIAL_PHASE_SELECT + ppm_offset) % PHASE_NUM];
                else if (ppm_offset == 0)
                    rx_dpa_clk <= dpa_clk_tmp[0];
                else
                    rx_dpa_clk <= #(clk_period * 0.125 * (INITIAL_PHASE_SELECT + ppm_offset)) dpa_clk_tmp[0];
        end
    end

    always @ (dpa_locked_tmp or rx_dpa_reset)
    begin
        if (rx_dpa_reset == 1'b1)
            rx_dpa_locked = 1'b0;
        else
            rx_dpa_locked = dpa_locked_tmp;
    end

    always@(posedge rx_fastclk or posedge rx_dpa_reset or posedge rx_dpa_hold)
    begin
        if (enable_soft_cdr_mode == "ON")
        begin
            if (sim_dpa_net_ppm_variation == 0)
                ppm_offset <= 0;
            else
            begin
                if(rx_dpa_reset == 1'b1)
                begin
                    count <= 0;
                    ppm_offset <= 0;
                end
                else
                begin
                    if(rx_dpa_hold == 1'b0)
                    begin
                        if(count  < count_value)
                            count <= count + 1;
                        else
                        begin
                            if (sim_dpa_is_negative_ppm_drift == "ON")
                                ppm_offset <= (ppm_offset - 1 + PHASE_NUM) % PHASE_NUM;
                            else
                                ppm_offset <= ppm_offset + 1;
                            count <= 0;
                        end
                    end
                end
            end
        end
    end

    // CONTINOUS ASSIGNMENT
    assign rx_dpa_loaden = (enable_soft_cdr_mode == "ON") ? 1'b0 : dpa_loaden[INITIAL_PHASE_SELECT];

endmodule // stratixiii_lvds_rx_dpa

