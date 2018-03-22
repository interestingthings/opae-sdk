// Created by altera_lib_mf.pl from altera_mf.v
// END OF MODULE

//START_MODULE_NAME-------------------------------------------------------------
//
// Module Name     :   stratixii_lvds_rx
//
// Description     :   Stratix II lvds receiver. Support both the dpa and non-dpa
//                     mode.
//
// Limitation      :   Only available to Stratix II.
//
// Results expected:   Deserialized output data, dpa lock signal and status bit
//                     indicating whether maximum bitslip has been reached.
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
module stratixii_lvds_rx (
    rx_in,
    rx_reset,
    rx_fastclk,
    rx_enable,
    rx_locked,
    rx_dpll_reset,
    rx_dpll_hold,
    rx_dpll_enable,
    rx_fifo_reset,
    rx_channel_data_align,
    rx_cda_reset,
    rx_out,
    rx_dpa_locked,
    rx_cda_max
);

// GLOBAL PARAMETER DECLARATION
    parameter number_of_channels = 1;
    parameter deserialization_factor = 4;
    parameter enable_dpa_mode = "OFF";
    parameter data_align_rollover = deserialization_factor;
    parameter lose_lock_on_one_change = "OFF";
    parameter reset_fifo_at_first_lock = "ON";
    parameter x_on_bitslip = "ON";
    parameter show_warning = "OFF";

// LOCAL PARAMETER DECLARATION
    parameter REGISTER_WIDTH = deserialization_factor*number_of_channels;
    parameter MUX_WIDTH = 12;
    parameter RAM_WIDTH = 6;

// INPUT PORT DECLARATION
    input [number_of_channels -1 :0] rx_in;
    input rx_fastclk;
    input rx_enable;
    input rx_locked;
    input [number_of_channels -1 :0] rx_reset;
    input [number_of_channels -1 :0] rx_dpll_reset;
    input [number_of_channels -1 :0] rx_dpll_hold;
    input [number_of_channels -1 :0] rx_dpll_enable;
    input [number_of_channels -1 :0] rx_fifo_reset;
    input [number_of_channels -1 :0] rx_channel_data_align;
    input [number_of_channels -1 :0] rx_cda_reset;

// OUTPUT PORT DECLARATION
    output [REGISTER_WIDTH -1: 0] rx_out;
    output [number_of_channels -1: 0] rx_dpa_locked;
    output [number_of_channels -1: 0] rx_cda_max;


// INTERNAL REGISTERS DECLARATION
    reg [REGISTER_WIDTH -1 : 0] rx_shift_reg;
    reg [REGISTER_WIDTH -1 : 0] rx_out;
    reg [number_of_channels -1 : 0] rx_in_reg;
    reg [number_of_channels -1 : 0] fifo_in_sync_reg;
    reg [number_of_channels -1 : 0] fifo_out_sync_reg;
    reg [number_of_channels -1 : 0] bitslip_mux_out;
    reg [number_of_channels -1 : 0] dpa_in;
    reg [number_of_channels -1 : 0] retime_data;
    reg [number_of_channels -1 : 0] rx_dpa_locked;
    reg [number_of_channels -1 : 0] dpll_first_lock;
    reg [number_of_channels -1 : 0] rx_channel_data_align_pre;
    reg [number_of_channels -1 : 0] write_side_sync_reset;
    reg [number_of_channels -1 : 0] read_side_sync_reset;

    reg [(RAM_WIDTH*number_of_channels) -1 : 0] ram_array;
    reg [2 : 0] wrPtr [number_of_channels -1 : 0];
    reg [2 : 0] rdPtr [number_of_channels -1 : 0];
    reg [3 : 0] bitslip_count [number_of_channels -1 : 0];
    reg [number_of_channels -1 : 0] start_corrupt_bits;
    reg [1 : 0] num_corrupt_bits [number_of_channels -1 : 0];
    reg [number_of_channels -1 : 0] rx_cda_max;
    reg [(MUX_WIDTH*number_of_channels) -1 : 0] shift_reg_chain;
    reg [deserialization_factor -1 : 0] tmp_reg;
    reg enable0_reg;
    reg tmp_bit;

// INTERNAL WIRE DECLARATION

// INTERNAL TRI DECLARATION
    logic[number_of_channels -1 :0] rx_reset; // -- converted tristate to logic
    logic[number_of_channels -1 :0] rx_dpll_reset; // -- converted tristate to logic
    logic[number_of_channels -1 :0] rx_dpll_hold; // -- converted tristate to logic
    logic[number_of_channels -1 :0] rx_dpll_enable; // -- converted tristate to logic
    logic[number_of_channels -1 :0] rx_fifo_reset; // -- converted tristate to logic
    logic[number_of_channels -1 :0] rx_channel_data_align; // -- converted tristate to logic
    logic[number_of_channels -1 :0] rx_cda_reset; // -- converted tristate to logic

// LOCAL INTEGER DECLARATION
    integer i;
    integer i2;
    integer i3;
    integer i4;
    integer i6;
    integer j2;
    integer dpll_clk_count[number_of_channels -1: 0];

// INITIAL CONSTRUCT BLOCK
    initial
    begin
        enable0_reg=0;
        rx_in_reg = {number_of_channels{1'b0}};
        rx_cda_max = {number_of_channels{1'b0}};
        fifo_in_sync_reg = {number_of_channels{1'b0}};
        fifo_out_sync_reg = {number_of_channels{1'b0}};
        bitslip_mux_out = {number_of_channels{1'b0}};
        dpa_in = {number_of_channels{1'b0}};
        retime_data = {number_of_channels{1'b0}};
        rx_dpa_locked = {number_of_channels{1'b0}};
        dpll_first_lock = {number_of_channels{1'b0}};
        ram_array = {(RAM_WIDTH*number_of_channels){1'b0}};
        shift_reg_chain = {(MUX_WIDTH*number_of_channels){1'b0}};

        for (i = 0; i < number_of_channels; i = i + 1)
        begin
            wrPtr[i] = 0;
            rdPtr[i] = 3;
            bitslip_count[i] = 0;
            dpll_clk_count[i] = 0;
            start_corrupt_bits[i] = 0;
            num_corrupt_bits[i] = 0;
        end

        rx_shift_reg = {REGISTER_WIDTH{1'b0}};
        rx_out = {REGISTER_WIDTH{1'b0}};

        if ((enable_dpa_mode == "ON") && (show_warning == "ON"))
        begin
            $display("Warning : DPA Phase tracking is not modeled and once locked, DPA will continue to lock until the next reset is asserted. Please refer to the device handbook for further details.");
            $display("Time: %0t  Instance: %m", $time);
        end
    end

// ALWAYS CONSTRUCT BLOCK

    // Stratix II bitslip logic
    always @ (posedge rx_cda_reset)
    begin
        for (i2 = 0; i2 <= number_of_channels-1; i2 = i2 + 1)
        begin
            if (rx_cda_reset[i2] == 1'b1)
            begin
                // reset the bitslipping circuitry.
                bitslip_count[i2] <= 0;
                rx_cda_max[i2] <= 1'b0;
            end
        end
    end

    always @ (posedge rx_fastclk)
    begin
        // Registering enable0 signal
        enable0_reg <= rx_enable;

        if (enable0_reg == 1)
            rx_out <= rx_shift_reg;

        if (enable_dpa_mode == "ON")
        begin
            dpa_in <= rx_in;
            retime_data <= dpa_in;
        end

        rx_in_reg <= rx_in;

        {tmp_reg, rx_shift_reg} <= {rx_shift_reg, 1'b0};

        for (i3 = 0; i3 <= number_of_channels-1; i3 = i3 + 1)
        begin
            rx_shift_reg[i3 * deserialization_factor] <= bitslip_mux_out[i3];
        end

        {tmp_reg, shift_reg_chain} <= {shift_reg_chain, 1'b0};

        for (i3 = 0; i3 <= number_of_channels-1; i3 = i3 + 1)
        begin
            if (rx_cda_reset[i3] !== 1'b1)
            begin
                if ((rx_channel_data_align[i3] === 1'b1) &&
                    (rx_channel_data_align_pre[i3] === 1'b0))
                begin
                    // slipped data byte is corrupted.
                    start_corrupt_bits[i3] <= 1;
                    num_corrupt_bits[i3] <= 1;

                    // Rollover has occurred. Serial data stream is reset back to 0 latency.
                    if (bitslip_count[i3] == data_align_rollover)
                    begin
                        bitslip_count[i3] <= 0;
                        rx_cda_max[i3] <= 1'b0;
                    end
                    else
                    begin
                        // increase the bit slip count.
                        bitslip_count[i3] <= bitslip_count[i3] + 1;

                        // if maximum of bitslip limit has been reach, set rx_cda_max to high.
                        // Rollover will occur on the next bit slip.
                        if (bitslip_count[i3] == data_align_rollover - 1)
                            rx_cda_max[i3] <= 1'b1;
                    end
                end
                else if ((rx_channel_data_align[i3] === 1'b0) &&
                        (rx_channel_data_align_pre[i3] === 1'b1))
                begin
                    start_corrupt_bits[i3] <= 0;
                    num_corrupt_bits[i3] <= 0;
                end
            end

            if (start_corrupt_bits[i3] == 1'b1)
            begin
                if (num_corrupt_bits[i3]+1 == 3)
                    start_corrupt_bits[i3] <= 0;
                else
                    num_corrupt_bits[i3] <= num_corrupt_bits[i3] + 1;
            end

            // load serial data stream into the shift register chain.
            if ((enable_dpa_mode == "ON") && (rx_dpll_enable[i3] == 1'b1))
                shift_reg_chain[(i3*MUX_WIDTH) + 0] <= fifo_out_sync_reg[i3];
            else
                shift_reg_chain[(i3*MUX_WIDTH) + 0] <= rx_in_reg[i3];

            // set the output to 'X' for 3 fast clock cycles after receiving the bitslip signal.
            if ((((rx_channel_data_align[i3] === 1'b1) && (rx_channel_data_align_pre[i3] === 1'b0)) ||
                ((start_corrupt_bits[i3] == 1'b1) && (num_corrupt_bits[i3] < 3) &&
                (rx_channel_data_align[i3] === 1'b1))) && (x_on_bitslip == "ON"))
                bitslip_mux_out[i3] <= 1'b0 /* converted x or z to 1'b0 */;
            else
                bitslip_mux_out[i3] <= shift_reg_chain[(i3*MUX_WIDTH) + bitslip_count[i3]];

            rx_channel_data_align_pre[i3] <= rx_channel_data_align[i3];
        end
    end

    // Stratix II Phase Compensation FIFO
    always @ (posedge rx_fastclk or posedge rx_reset or posedge rx_fifo_reset)
    begin
        if (enable_dpa_mode == "ON")
        begin
            for (i4 = 0; i4 <= number_of_channels-1; i4 = i4 + 1)
            begin
                if ((rx_reset[i4] == 1'b1) || (rx_fifo_reset[i4] == 1'b1) ||
                    ((reset_fifo_at_first_lock == "ON") &&
                    (dpll_first_lock[i4] == 1'b0)))
                begin
                    wrPtr[i4] <= 0;
                    for (j2 = 0; j2 < RAM_WIDTH; j2 = j2 + 1)
                        ram_array[(i4*RAM_WIDTH) + j2] <= 1'b0;
                    fifo_in_sync_reg[i4] <= 1'b0;
                    write_side_sync_reset[i4] <= 1'b1;

                    rdPtr[i4] <= 3;
                    fifo_out_sync_reg[i4] <= 1'b0;
                    read_side_sync_reset[i4] <= 1'b1;

                end
                else
                begin
                    if (write_side_sync_reset[i4] <= 1'b0)
                    begin
                        wrPtr[i4] <= wrPtr[i4] + 1;
                        fifo_in_sync_reg[i4] <= retime_data[i4];
                        ram_array[(i4*RAM_WIDTH) + wrPtr[i4]] <= fifo_in_sync_reg[i4];
                        if (wrPtr[i4] == 5)
                            wrPtr[i4] <= 0;
                    end
                    write_side_sync_reset[i4] <= 1'b0;

                    if (read_side_sync_reset[i4] == 1'b0)
                    begin
                        rdPtr[i4] <= rdPtr[i4] + 1;
                        fifo_out_sync_reg[i4] <= ram_array[(i4*RAM_WIDTH) + rdPtr[i4]];
                        if (rdPtr[i4] == 5)
                            rdPtr[i4] <= 0;
                    end
                    read_side_sync_reset[i4] <= 1'b0;
                end
            end
        end
    end

    // Stratix II DPA Block
    always @ (posedge rx_fastclk or posedge rx_reset)
    begin
        for (i6 = 0; i6 <= number_of_channels-1; i6 = i6 + 1)
        begin
            if (rx_reset[i6] == 1'b1)
            begin
                dpll_clk_count[i6] <= 0;
                rx_dpa_locked[i6] <= 1'b0;
            end
            else if (rx_dpa_locked[i6] == 1'b0)
            begin
                if (dpll_clk_count[i6] == 2)
                begin
                    rx_dpa_locked[i6] <= 1'b1;
                    dpll_first_lock[i6] <= 1'b1;
                end
                else
                    dpll_clk_count[i6] <= dpll_clk_count[i6] + 1;
            end
        end
    end
endmodule // stratixii_lvds_rx

