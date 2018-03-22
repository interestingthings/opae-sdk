// Created by altera_lib_mf.pl from altera_mf.v
// END OF MODULE


//START_MODULE_NAME-------------------------------------------------------------
//
// Module Name     :   stratixiii_lvds_rx_channel
//
// Description     :   Simulation model for each channel of Stratix III lvds receiver.
//                     Support both the dpa and non-dpa mode.
//
// Limitation      :   Only available to Stratix III.
//
// Results expected:   Deserialized output data, dpa lock signal, forwarded clock
//                     and status bit indicating whether maximum bitslip has been
//                     reached.
//
//END_MODULE_NAME---------------------------------------------------------------

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
module stratixiii_lvds_rx_channel (
    rx_in,
    rx_reset,
    rx_fastclk,
    rx_slowclk,
    rx_enable,
    rx_dpll_reset,
    rx_dpll_hold,
    rx_dpll_enable,
    rx_fifo_reset,
    rx_channel_data_align,
    rx_cda_reset,
    rx_out,
    rx_dpa_locked,
    rx_cda_max,
    rx_divfwdclk,
    rx_dpa_lock_reset,
    rx_locked,
    rx_dpaclock
);

// GLOBAL PARAMETER DECLARATION
    parameter deserialization_factor = 4;
    parameter enable_dpa_mode = "OFF";
    parameter data_align_rollover = deserialization_factor;
    parameter lose_lock_on_one_change = "OFF";
    parameter reset_fifo_at_first_lock = "ON";
    parameter x_on_bitslip = "ON";
    parameter rx_align_data_reg = "RISING_EDGE";
    parameter enable_soft_cdr_mode = "OFF";
    parameter sim_dpa_output_clock_phase_shift = 0;
    parameter sim_dpa_is_negative_ppm_drift = "OFF";
    parameter sim_dpa_net_ppm_variation = 0;
    parameter enable_dpa_align_to_rising_edge_only = "OFF";
    parameter enable_dpa_initial_phase_selection = "OFF";
    parameter dpa_initial_phase_value = 0;
    parameter registered_output = "ON";
    parameter use_external_pll = "OFF";
    parameter use_dpa_calibration = 0;
    parameter enable_clock_pin_mode = "UNUSED";

    parameter ARRIAII_RX_STYLE = 0;

parameter STRATIXV_RX_STYLE = 0;

// LOCAL PARAMETER DECLARATION
    parameter MUX_WIDTH = 12;
    parameter RAM_WIDTH = 6;

// INPUT PORT DECLARATION
    input rx_in;
    input rx_fastclk;
    input rx_slowclk;
    input rx_enable;
    input rx_reset;
    input rx_dpll_reset;
    input rx_dpll_hold;
    input rx_dpll_enable;
    input rx_fifo_reset;
    input rx_channel_data_align;
    input rx_cda_reset;
    input rx_locked;
    input rx_dpa_lock_reset;
    input rx_dpaclock;

// OUTPUT PORT DECLARATION
    output [deserialization_factor -1: 0] rx_out;
    output rx_dpa_locked;
    output rx_cda_max;
    output rx_divfwdclk;

// INTERNAL REGISTERS DECLARATION
    reg [deserialization_factor -1 : 0] rx_shift_reg;
    reg rx_in_reg_pos;
    reg rx_in_reg_neg;
    reg fifo_in_sync_reg;
    reg fifo_out_sync_reg;
    reg bitslip_mux_out;
    reg dpa_in;
    reg dpll_first_lock;
    reg rx_channel_data_align_pre;
    reg write_side_sync_reset;
    reg read_side_sync_reset;
    reg rx_divfwdclk_int;
    reg [RAM_WIDTH -1 : 0] ram_array;
    reg [2 : 0] wrPtr;
    reg [2 : 0] rdPtr;
    reg [3 : 0] bitslip_count;
    reg start_corrupt_bits;
    reg [1 : 0] num_corrupt_bits;
    reg rx_cda_max;
    reg [MUX_WIDTH -1 : 0] shift_reg_chain;
    reg tmp_reg;
    reg tmp_bit;
    reg enable0_reg;
    reg rx_enable_dly;
    reg load_enable_cdr;
    reg start_counter;
    reg [3 : 0] div_clk_count_pos;
    reg [3 : 0] div_clk_count_neg;
    reg rx_fastclk_dly;
    reg rx_fastclk_dly2;
    reg rx_fastclk_dly3;
    reg [deserialization_factor -1: 0]  rx_out_reg;
    reg [deserialization_factor -1 : 0] rx_out_int;
    reg [deserialization_factor -1 : 0] rx_dpa_sync_reg;
    reg [deserialization_factor -1 : 0] pad_regr;
    reg extra_regr;
    reg lock_out_regr;
    reg [8 : 0] accum_regr_temp;
    reg [deserialization_factor - 1 : 0] in_bus_add;
    reg lock_out_reg_dly;
    reg [1 : 0] lock_state_mc;
    reg rx_in_int;
    reg [1 : 0] lock_state_mc_d;
    reg dpa_locked_dly;
    reg reset_fifo;
    reg fifo_reset_regr_dly;
    reg fifo_reset_regr_dly2;
    reg fifo_reset_regr_dly3;

// INTERNAL WIRE DECLARATION
    wire fast_clk;
    wire dpa_loaden;
    wire dpa_locked;
    wire rx_dpa_locked;
    wire retime_data;
    wire dpa_clock;
    wire rx_reg_clk;
    wire rx_dpa_sync_reg_clk;
    wire int_pll_kick_reset;
    wire pll_locked;
    wire dpaswitch;
    wire [1:0] wire_lock_state_mc_ena;
    wire [1:0] wire_lock_state_mc_d;
    wire fifo_reset_regr;
    wire rx_in_wire;
    wire rx_dpaclock_wire;
    wire local_clk_div_lloaden;
    wire local_loaden;

// INTERNAL TRI DECLARATION
    logic rx_reset; // -- converted tristate to logic
    logic rx_dpll_reset; // -- converted tristate to logic
    logic rx_dpll_hold; // -- converted tristate to logic
    logic rx_dpll_enable; // -- converted tristate to logic
    logic rx_fifo_reset; // -- converted tristate to logic
    logic rx_channel_data_align; // -- converted tristate to logic
    logic rx_cda_reset; // -- converted tristate to logic

// LOCAL INTEGER DECLARATION
    integer j;
    integer i;

// INITIAL CONSTRUCT BLOCK
    initial
    begin
        enable0_reg = 1'b0;
        rx_in_reg_pos = 1'b0;
        rx_in_reg_neg = 1'b0;
        rx_cda_max = 1'b0;
        fifo_in_sync_reg = 1'b0;
        fifo_out_sync_reg = 1'b0;
        bitslip_mux_out = 1'b0;
        dpa_in = 1'b0;
        dpll_first_lock = 1'b0;
        rx_divfwdclk_int = 1'b0;
        load_enable_cdr = 1'b0;
        start_counter = 1'b0;

        ram_array = {RAM_WIDTH{1'b0}};
        shift_reg_chain = {MUX_WIDTH{1'b0}};

        wrPtr = 0;
        rdPtr = 3;
        bitslip_count = 0;
        start_corrupt_bits = 0;
        num_corrupt_bits = 0;
        div_clk_count_pos = 0;
        div_clk_count_neg = 0;

        rx_shift_reg = {deserialization_factor{1'b0}};
        rx_out_reg = {deserialization_factor{1'b0}};
        rx_out_int = {deserialization_factor{1'b0}};
        rx_dpa_sync_reg = {deserialization_factor{1'b0}};
        rx_enable_dly = 1'b0;
        rx_divfwdclk_int = 1'b0;
        pad_regr = {deserialization_factor{1'b0}};
        extra_regr = 1'b0;
        lock_out_regr = 1'b0;
        accum_regr_temp = 9'b0;
        in_bus_add = {deserialization_factor{1'b0}};
        lock_out_reg_dly = 1'b0;
        lock_state_mc = 2'b0;
        rx_in_int = 1'b0;
        lock_state_mc_d = 2'b0;

    end

// COMPONENT INSTANTIATIONS

    // Stratix III DPA block
    generate
    if (enable_dpa_mode == "ON")
    begin: stratixiii_lvds_rx_dpa
    stratixiii_lvds_rx_dpa dpa_block (
        .rx_in(rx_in_wire),
        .rx_fastclk(rx_dpaclock_wire),
        .rx_enable(rx_enable),
        .rx_dpa_reset(rx_reset),
        .rx_dpa_hold(rx_dpll_hold),
        .rx_out(retime_data),
        .rx_dpa_clk(dpa_clock),
        .rx_dpa_loaden(dpa_loaden),
        .rx_dpa_locked(dpa_locked));

    defparam
        dpa_block.enable_soft_cdr_mode           = enable_soft_cdr_mode,
        dpa_block.sim_dpa_is_negative_ppm_drift  = sim_dpa_is_negative_ppm_drift,
        dpa_block.sim_dpa_net_ppm_variation      = sim_dpa_net_ppm_variation,
        dpa_block.enable_dpa_align_to_rising_edge_only  = enable_dpa_align_to_rising_edge_only,
        dpa_block.enable_dpa_initial_phase_selection    = enable_dpa_initial_phase_selection,
        dpa_block.dpa_initial_phase_value        = dpa_initial_phase_value;
    end
    endgenerate


    // This module produces lloaden clock from local clock divider.
    generate
    if ((STRATIXV_RX_STYLE == 1) && (enable_clock_pin_mode == "ON") && (deserialization_factor > 2))
    begin: stratixv_local_clk_divider
    stratixv_local_clk_divider rx_local_clk_divider (
        .clkin(rx_fastclk),
        .lloaden(local_clk_div_lloaden));

    defparam
        rx_local_clk_divider.clk_divide_by = deserialization_factor;
    end
    endgenerate


// ALWAYS CONSTRUCT BLOCK


    always @ (rx_in)
    begin
        rx_in_int <= #120 rx_in;
    end

    always @ (negedge fast_clk)
    begin
        if (enable_soft_cdr_mode == "ON")
        begin
            div_clk_count_neg <= div_clk_count_pos;
        end
    end

    always @ (negedge rx_fastclk)
    begin
        rx_in_reg_neg <= rx_in;
    end

    // Generates the rx_divfwdclk
    always @ (div_clk_count_pos or div_clk_count_neg)
    begin
        if (enable_soft_cdr_mode == "ON")
        begin
            // even deser mode
            if (deserialization_factor %2 == 0)
            begin
                if (div_clk_count_pos == 1)
                    rx_divfwdclk_int = 1'b0;
                else if (div_clk_count_pos == ((deserialization_factor/2) + 1))
                    rx_divfwdclk_int = 1'b1;
            end
            else
            begin
                // old deser mode
                if (div_clk_count_pos == 1)
                    rx_divfwdclk_int = 1'b0;
                else if (div_clk_count_neg == ((deserialization_factor+1) / 2))
                    rx_divfwdclk_int = 1'b1;
            end

            if (div_clk_count_neg == (deserialization_factor -1))
                load_enable_cdr = 1'b1;
            else if (div_clk_count_neg == deserialization_factor)
                load_enable_cdr = 1'b0;
        end
    end

    // Stratix III bitslip logic
    always @ (posedge rx_cda_reset)
    begin
        if (rx_cda_reset == 1'b1)
        begin
            // reset the bitslipping circuitry.
            bitslip_count <= 0;
            rx_cda_max <= 1'b0;
        end
    end

    // add delta delay to rx_enable
    always @ (local_loaden)
    begin
        rx_enable_dly <= local_loaden;
    end


    always @ (posedge fast_clk)
    begin
        // Registering enable0 signal
        if (enable_dpa_mode == "ON")
        begin
            if (enable_soft_cdr_mode == "ON")
                enable0_reg <= load_enable_cdr;
            else
                enable0_reg <= dpa_loaden;
        end
        else
            enable0_reg <= rx_enable_dly;

        if (enable0_reg == 1'b1)
            rx_out_int <= rx_shift_reg;

        rx_in_reg_pos <= rx_in;

        {tmp_reg, rx_shift_reg} <= {rx_shift_reg, bitslip_mux_out};

        {tmp_reg, shift_reg_chain} <= {shift_reg_chain, 1'b0};

        if (rx_cda_reset !== 1'b1)
        begin
            if ((rx_channel_data_align === 1'b1) &&
                (rx_channel_data_align_pre === 1'b0))
            begin
                // slipped data byte is corrupted.
                start_corrupt_bits <= 1;
                num_corrupt_bits <= 1;

                // Rollover has occurred. Serial data stream is reset back to 0 latency.
                if (bitslip_count == data_align_rollover)
                begin
                    bitslip_count <= 0;
                    rx_cda_max <= 1'b0;
                end
                else
                begin
                    // increase the bit slip count.
                    bitslip_count <= bitslip_count + 1;

                    // if maximum of bitslip limit has been reach, set rx_cda_max to high.
                    // Rollover will occur on the next bit slip.
                    if (bitslip_count == data_align_rollover - 1)
                        rx_cda_max <= 1'b1;
                end
            end
            else if ((rx_channel_data_align === 1'b0) &&
                    (rx_channel_data_align_pre === 1'b1))
            begin
                start_corrupt_bits <= 0;
                num_corrupt_bits <= 0;
            end
        end

        if (start_corrupt_bits == 1'b1)
        begin
            if (num_corrupt_bits+1 == 3)
                start_corrupt_bits <= 0;
            else
                num_corrupt_bits <= num_corrupt_bits + 1;
        end

        // load serial data stream into the shift register chain.
        if ((enable_dpa_mode == "ON") && (enable_soft_cdr_mode == "ON"))
            shift_reg_chain[0] <= retime_data;
        else if ((enable_dpa_mode == "ON") && ((rx_dpll_enable == 1'b1) || (dpaswitch == 1'b1)))
            shift_reg_chain[0] <= fifo_out_sync_reg;
        else if (rx_align_data_reg == "RISING_EDGE")
            shift_reg_chain[0] <= rx_in_reg_pos;
        else
            shift_reg_chain[0] <= rx_in_reg_neg;

        // set the output to 'X' for 3 fast clock cycles after receiving the bitslip signal.
        if ((((rx_channel_data_align === 1'b1) && (rx_channel_data_align_pre === 1'b0)) ||
            ((start_corrupt_bits == 1'b1) && (num_corrupt_bits < 3) &&
            (rx_channel_data_align === 1'b1))) && (x_on_bitslip == "ON"))
            bitslip_mux_out <= 1'b0 /* converted x or z to 1'b0 */;
        else
            bitslip_mux_out <= shift_reg_chain[bitslip_count];

        rx_channel_data_align_pre <= rx_channel_data_align;

        if (enable_soft_cdr_mode == "ON")
        begin
            // get the number of positive edge of fast clock, which is used to determine
            // when the forwarded clock should toggle
            if (div_clk_count_pos == deserialization_factor)
                div_clk_count_pos <= 1;
            else
                div_clk_count_pos <= div_clk_count_pos + 1;
        end
    end

    // Stratix III Phase Compensation FIFO (write side)
    always @ (posedge rx_dpaclock_wire or posedge rx_reset)
    begin
        if ((enable_dpa_mode == "ON") && (enable_soft_cdr_mode == "OFF"))
        begin
            if ((rx_reset == 1'b1) || (fifo_reset_regr_dly3 == 1'b1) ||
                ((reset_fifo_at_first_lock == "ON") &&
                (dpa_locked == 1'b0)))
            begin
                wrPtr <= 0;
                ram_array = {RAM_WIDTH{1'b0}};
                fifo_in_sync_reg <= 1'b0;
                write_side_sync_reset <= 1'b1;
            end
            else
            begin
                if (write_side_sync_reset <= 1'b0)
                begin
                    wrPtr <= wrPtr + 1;
                    fifo_in_sync_reg <= retime_data;
                    ram_array[wrPtr] <= fifo_in_sync_reg;
                    if (wrPtr == 5)
                        wrPtr <= 0;
                end
                write_side_sync_reset <= 1'b0;
            end
        end
    end

    // Stratix III Phase Compensation FIFO (read side)
    always @ (posedge rx_dpaclock_wire or posedge rx_reset)
    begin
        if ((enable_dpa_mode == "ON") && (enable_soft_cdr_mode == "OFF"))
        begin
            if ((rx_reset == 1'b1) || (fifo_reset_regr_dly3 == 1'b1) ||
                ((reset_fifo_at_first_lock == "ON") &&
                (dpa_locked == 1'b0)))
            begin
                rdPtr <= 3;
                fifo_out_sync_reg <= 1'b0;
                read_side_sync_reset <= 1'b1;
            end
            else
            begin
                if (read_side_sync_reset == 1'b0)
                begin
                    rdPtr <= rdPtr + 1;
                    fifo_out_sync_reg <= ram_array[rdPtr];
                    if (rdPtr == 5)
                        rdPtr <= 0;
                end
                read_side_sync_reset <= 1'b0;
            end
        end
    end

    always @ (posedge rx_reg_clk)
    begin
        if ((enable_dpa_mode == "ON") && (enable_soft_cdr_mode == "ON"))
            rx_out_reg <= rx_dpa_sync_reg;
        else
            rx_out_reg <= rx_out_int;
    end

    always @ (posedge rx_dpa_sync_reg_clk)
    begin
        rx_dpa_sync_reg <= rx_out_int;
    end

    always @ (rx_fastclk)
    begin
        rx_fastclk_dly <= rx_fastclk;
    end

    always @ (rx_fastclk_dly)
    begin
        rx_fastclk_dly2 <= rx_fastclk_dly;
    end

    always @ (rx_fastclk_dly2)
    begin
        rx_fastclk_dly3 <= rx_fastclk_dly2;
    end

    always @ (fifo_reset_regr)
    begin
        fifo_reset_regr_dly <= fifo_reset_regr;
    end

    always @ (fifo_reset_regr_dly)
    begin
        fifo_reset_regr_dly2 <= fifo_reset_regr_dly;
    end

    always @ (fifo_reset_regr_dly2)
    begin
        fifo_reset_regr_dly3 <= fifo_reset_regr_dly2;
    end

    always @ (dpa_locked)
    begin
        dpa_locked_dly <= dpa_locked;
    end

    always @ (dpa_locked_dly)
    begin
        reset_fifo <= !dpa_locked_dly;
    end

    always @ (wire_lock_state_mc_d)
    begin
        lock_state_mc_d[1:0] <= wire_lock_state_mc_d[1:0];
    end



    always @ (posedge rx_slowclk or posedge rx_reset or posedge pll_locked or posedge int_pll_kick_reset)
    begin
        if (rx_reset == 1'b1 || ~pll_locked || int_pll_kick_reset== 1'b1)
        begin
            pad_regr <= 0;
            extra_regr <=0;
            lock_out_regr <= 0;
            in_bus_add <= 0;
        end
        else
        begin
            pad_regr <= rx_out;
            in_bus_add[0] <= extra_regr ^ pad_regr[0];
            extra_regr <= pad_regr[deserialization_factor-1];
            for (j =1; j < deserialization_factor; j=j+1)
            begin
                in_bus_add[j] <= pad_regr[j] ^ pad_regr[j-1];
            end
            if (accum_regr_temp >= 256)
            begin
                lock_out_regr <= 1'b1;
            end
        end

        if (rx_reset == 1'b1 || ~pll_locked)
            lock_out_reg_dly <= 1'b0;
        else
            lock_out_reg_dly <= lock_out_regr;

        if (use_dpa_calibration == 1)
        begin
            if (rx_reset == 1'b1 || ~pll_locked)
                lock_state_mc <= 0 ;
            else
                if (wire_lock_state_mc_ena[1] == 1)
                    lock_state_mc[1] <= lock_state_mc_d[1];
                if (wire_lock_state_mc_ena[0] == 1)
                    lock_state_mc[0] <= lock_state_mc_d[0];
        end
    end

    always @ (posedge rx_slowclk or posedge rx_reset or posedge pll_locked or posedge int_pll_kick_reset)
    begin
        if (rx_reset == 1'b1 || ~pll_locked || int_pll_kick_reset== 1'b1)
        begin
            accum_regr_temp = 0;
        end
        else
        for (i =0; i < deserialization_factor; i=i+1)
        begin
            if (in_bus_add[i] == 1'b1)
            begin
                accum_regr_temp  = accum_regr_temp + 1'b1 ;
            end
        end
    end

    // CONTINOUS ASSIGNMENT
    assign rx_divfwdclk = ~rx_divfwdclk_int;
    assign rx_out = (registered_output == "ON") ? rx_out_reg : rx_out_int;
    assign fast_clk = ((enable_dpa_mode == "ON") && (enable_soft_cdr_mode == "ON")) ? dpa_clock : rx_fastclk;
    assign rx_dpa_locked = (use_dpa_calibration == 1) ? ((lock_state_mc[0] & lock_state_mc[1]) & lock_out_reg_dly) : (use_external_pll == "ON") ? lock_out_reg_dly : lock_out_reg_dly;
    assign rx_reg_clk = ((enable_dpa_mode == "ON") && (enable_soft_cdr_mode == "ON")) ? ~rx_divfwdclk_int : rx_slowclk;
    assign rx_dpa_sync_reg_clk = ((enable_dpa_mode == "ON") && (enable_soft_cdr_mode == "ON")) ? rx_divfwdclk_int : 1'b0;
    assign int_pll_kick_reset = (use_dpa_calibration == 1) ? ((lock_state_mc[0] & (~ lock_state_mc[1])) | ((lock_state_mc[0] & lock_state_mc[1]) & rx_dpa_lock_reset)) : rx_dpa_lock_reset;
    assign pll_locked = rx_locked;
    assign wire_lock_state_mc_ena = {2{(((((lock_state_mc[0] & lock_state_mc[1]) & rx_dpa_lock_reset) | (((~ lock_state_mc[0]) & (~ lock_state_mc[1])) & lock_out_regr)) | ((lock_state_mc[0] & (~ lock_state_mc[1])) & lock_out_reg_dly)) | (((~ lock_state_mc[0]) & lock_state_mc[1]) & lock_out_regr))}};
    assign wire_lock_state_mc_d = {((((lock_state_mc[0] & (~ lock_state_mc[1])) & lock_out_reg_dly) | (((~ lock_state_mc[0]) & lock_state_mc[1]) & lock_out_regr)) & (~ (((lock_state_mc[0] & lock_state_mc[1]) & rx_dpa_lock_reset) | (((~ lock_state_mc[0]) & (~ lock_state_mc[1])) & lock_out_regr)))), (((((~ lock_state_mc[0]) & (~ lock_state_mc[1])) & lock_out_regr) | (((~ lock_state_mc[0]) & lock_state_mc[1]) & lock_out_regr)) & (~ (((lock_state_mc[0] & lock_state_mc[1]) & rx_dpa_lock_reset) | ((lock_state_mc[0] & (~ lock_state_mc[1])) & lock_out_reg_dly))))};
    assign dpaswitch = (use_dpa_calibration == 1) ? ((~ lock_state_mc[0]) & (~ lock_state_mc[1])) : 1'b1;
    assign fifo_reset_regr = ((use_dpa_calibration == 1) ?  (((~ lock_state_mc[0]) & lock_state_mc[1]) & (lock_out_regr ^ lock_out_reg_dly)) : (lock_out_regr ^ lock_out_reg_dly)) || reset_fifo || rx_fifo_reset;
    assign rx_in_wire = (use_dpa_calibration == 1) ? (dpaswitch == 1'b1) ? rx_in_int : rx_in : rx_in;
    assign rx_dpaclock_wire = (use_external_pll == "ON" && STRATIXV_RX_STYLE == 1'b1 && enable_dpa_mode == "ON") ? rx_dpaclock : rx_fastclk_dly3;
    assign local_loaden = ((STRATIXV_RX_STYLE == 1) && (enable_clock_pin_mode == "ON")) ?  local_clk_div_lloaden : rx_enable;
endmodule // stratixiii_lvds_rx_channel

