// Created by altera_lib_mf.pl from altera_mf.v
// END OF MODULE

//START_MODULE_NAME----------------------------------------------------
//
// Module Name     :   flexible_lvds_rx
//
// Description     :   flexible lvds receiver
//
// Limitation      :   Only available to Cyclone and Cyclone II
//                     families.
//
// Results expected:   Deserialized output data.
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
module flexible_lvds_rx (
    rx_in,          // input serial data
    rx_fastclk,     // fast clock from PLL
    rx_slowclk,     // slow clock from PLL
    rx_syncclk,     // sync clock from PLL
    pll_areset,     // Reset signal to clear the registers
    rx_data_align,  // Data align control signal
    rx_cda_reset,   // reset for the bitslip logic
    rx_locked,      // lock signal from PLL
    rx_out          // deserialized output data
);

// GLOBAL PARAMETER DECLARATION
    parameter number_of_channels = 1;
    parameter deserialization_factor = 4;
    parameter use_extra_ddio_register = "YES";
    parameter use_extra_pll_clk = "NO";
    parameter buffer_implementation = "RAM";
    parameter registered_data_align_input = "OFF";
    parameter use_external_pll = "OFF";
    parameter registered_output = "ON";
    parameter add_latency = "YES";

// LOCAL PARAMETER DECLARATION
    parameter REGISTER_WIDTH = deserialization_factor*number_of_channels;
    parameter LATENCY = (deserialization_factor % 2 == 1) ? (deserialization_factor / 2 + 1) : (deserialization_factor / 2);
    parameter NUM_OF_SYNC_STAGES = ((deserialization_factor == 4 && (add_latency == "YES")) ? 1 : (LATENCY - 3) + ((add_latency == "NO") ? 1 : 0) ) +
                (((deserialization_factor % 2 == 1) && !(buffer_implementation == "RAM" || buffer_implementation == "LES")) ? deserialization_factor/2: 0);

// INPUT PORT DECLARATION
    input [number_of_channels -1 :0] rx_in;
    input rx_fastclk;
    input rx_slowclk;
    input rx_syncclk;
    input pll_areset;
    input rx_locked;
    input [number_of_channels -1 :0] rx_data_align;
    input [number_of_channels -1 :0]  rx_cda_reset;

// OUTPUT PORT DECLARATION
    output [REGISTER_WIDTH -1: 0] rx_out;

// INTERNAL REGISTERS DECLARATION
    reg [REGISTER_WIDTH -1 : 0] rx_shift_reg;
    reg [REGISTER_WIDTH -1 : 0] rx_shift_reg1;
    reg [REGISTER_WIDTH -1 : 0] rx_shift_reg2;
    reg [REGISTER_WIDTH -1 : 0] rx_sync_reg1;
    reg [REGISTER_WIDTH -1 : 0] rx_sync_reg2;
    reg [REGISTER_WIDTH -1 : 0] rx_sync_reg1_buf1;
    reg [REGISTER_WIDTH -1 : 0] rx_sync_reg1_buf1_pipe;
    reg [REGISTER_WIDTH -1 : 0] rx_sync_reg2_buf1;
    reg [REGISTER_WIDTH -1 : 0] rx_sync_reg1_buf2;
    reg [REGISTER_WIDTH -1 : 0] rx_sync_reg1_buf2_pipe;
    reg [REGISTER_WIDTH -1 : 0] rx_sync_reg2_buf2;
    reg [REGISTER_WIDTH -1 : 0] rx_out_odd;
    reg [REGISTER_WIDTH -1 : 0] rx_out_odd_mode;
    reg [REGISTER_WIDTH -1 : 0] rx_out_reg;
    reg [REGISTER_WIDTH -1 : 0] h_int_reg;
    reg [REGISTER_WIDTH -1 : 0] l_int_reg;
    reg [number_of_channels -1 :0] ddio_h_reg;
    reg [number_of_channels -1 :0] ddio_l_reg;
    reg [number_of_channels -1 :0] datain_h_reg;
    reg [number_of_channels -1 :0] datain_l_reg;
    reg[number_of_channels -1 :0] datain_h_reg_int [NUM_OF_SYNC_STAGES:0];
    reg[number_of_channels -1 :0] datain_l_reg_int [NUM_OF_SYNC_STAGES:0];
    reg [number_of_channels -1 :0] datain_l_latch;
    reg select_bit;
    reg sync_clock;
    reg [number_of_channels -1 :0] rx_data_align_reg;
    reg [number_of_channels -1 :0] int_bitslip_reg;
    reg[4:0] bitslip_count [number_of_channels -1 :0];
    reg rx_slowclk_pre;

// INTERNAL WIRE DECLARATION
    wire [REGISTER_WIDTH -1 : 0] rx_out;
    wire [REGISTER_WIDTH -1 : 0] rx_out_int;
    wire rx_data_align_clk;
    wire [number_of_channels -1 :0] rx_data_align_int;

// LOCAL INTEGER DECLARATION
    integer i;
    integer i1;
    integer i2;
    integer i3;
    integer i4;
    integer j;
    integer x;
    integer pipe_ptr;

// INITIAL CONSTRUCT BLOCK
    initial
    begin : INITIALIZATION

        rx_shift_reg  = {REGISTER_WIDTH{1'b0}};
        rx_shift_reg1  = {REGISTER_WIDTH{1'b0}};
        rx_shift_reg2  = {REGISTER_WIDTH{1'b0}};
        rx_sync_reg1  = {REGISTER_WIDTH{1'b0}};
        rx_sync_reg2  = {REGISTER_WIDTH{1'b0}};
        rx_sync_reg1_buf1  = {REGISTER_WIDTH{1'b0}};
        rx_sync_reg1_buf1_pipe  = {REGISTER_WIDTH{1'b0}};
        rx_sync_reg2_buf1  = {REGISTER_WIDTH{1'b0}};
        rx_sync_reg1_buf2  = {REGISTER_WIDTH{1'b0}};
        rx_sync_reg1_buf2_pipe  = {REGISTER_WIDTH{1'b0}};
        rx_sync_reg2_buf2  = {REGISTER_WIDTH{1'b0}};
        rx_out_odd = {REGISTER_WIDTH{1'b0}};
        rx_out_odd_mode = {REGISTER_WIDTH{1'b0}};
        rx_out_reg = {REGISTER_WIDTH{1'b0}};
        h_int_reg = {REGISTER_WIDTH{1'b0}};
        l_int_reg = {REGISTER_WIDTH{1'b0}};
        ddio_h_reg     = {number_of_channels{1'b0}};
        ddio_l_reg     = {number_of_channels{1'b0}};
        datain_h_reg = {number_of_channels{1'b0}};
        datain_l_reg = {number_of_channels{1'b0}};
        datain_l_latch = {number_of_channels{1'b0}};

        select_bit = 1'b0;
        sync_clock = 1'b0;
        rx_data_align_reg = {number_of_channels{1'b0}};
        int_bitslip_reg = {number_of_channels{1'b0}};

        for (i3= 0; i3 < number_of_channels; i3 = i3+1)
            bitslip_count[i3] = 0;

        for (i3= 0; i3 <= NUM_OF_SYNC_STAGES; i3 = i3+1)
        begin
            datain_h_reg_int[i3] = {number_of_channels{1'b0}};
            datain_l_reg_int[i3] = {number_of_channels{1'b0}};
        end
        pipe_ptr = 0;
    end //INITIALIZATION


// ALWAYS CONSTRUCT BLOCK

    // This always block implements the altddio_in that takes in the input serial
    // data of each channel and deserialized it into two parallel data stream
    // (ddio_h_reg and ddio_l_reg). Each parallel data stream will be registered
    // before send to shift registers.
    always @(posedge rx_fastclk or posedge pll_areset)
    begin : DDIO_IN
        if (pll_areset)
        begin
            ddio_h_reg <= {number_of_channels{1'b0}};
            datain_h_reg <= {number_of_channels{1'b0}};
            datain_l_reg <= {number_of_channels{1'b0}};

            for (i4= 0; i4 <= NUM_OF_SYNC_STAGES; i4 = i4+1)
            begin
                datain_h_reg_int[i4] = {number_of_channels{1'b0}};
                datain_l_reg_int[i4] = {number_of_channels{1'b0}};
            end

            pipe_ptr <= 0;
        end
        else
        begin
            if (NUM_OF_SYNC_STAGES > 0)
            begin
                if (use_extra_ddio_register == "YES")
                begin
                    ddio_h_reg <= rx_in;
                    datain_h_reg_int[pipe_ptr] <= ddio_h_reg;
                end
                else
                    datain_h_reg_int[pipe_ptr] <= rx_in;

                datain_l_reg_int[pipe_ptr] <= datain_l_latch;

                if (NUM_OF_SYNC_STAGES > 1)
                    pipe_ptr <= (pipe_ptr + 1) % NUM_OF_SYNC_STAGES;

                datain_h_reg <= datain_h_reg_int[pipe_ptr];
                datain_l_reg <= datain_l_reg_int[pipe_ptr];
            end
            else
            begin
                if (use_extra_ddio_register == "YES")
                begin
                    ddio_h_reg <= rx_in;
                    datain_h_reg <= ddio_h_reg;
                end
                else
                    datain_h_reg <= rx_in;

                datain_l_reg <= datain_l_latch;
            end
        end
    end // DDIO_IN

    always @(negedge rx_fastclk or posedge pll_areset)
    begin : DDIO_IN_LATCH
        if (pll_areset)
        begin
            ddio_l_reg <= {number_of_channels{1'b0}};
            datain_l_latch <= {number_of_channels{1'b0}};
        end
        else
        begin
            if (use_extra_ddio_register == "YES")
            begin
                ddio_l_reg <= rx_in;
                datain_l_latch <= ddio_l_reg;
            end
            else
                datain_l_latch <= rx_in;
        end
    end // DDIO_IN_LATCH

    // bitslip counter reset
    always @(rx_cda_reset)
    begin
        for (i2= 0; i2 < number_of_channels; i2 = i2+1)
        begin
            if (rx_cda_reset[i2] == 1'b1)
                bitslip_count[i2] <= 0;
        end
    end

    // bitslip counter
    always @(posedge rx_fastclk)
    begin : BITSLIP_CNT
        for (i1= 0; i1 < number_of_channels; i1 = i1+1)
        begin
            if (~rx_cda_reset[i1] && ~int_bitslip_reg[i1] && rx_data_align_int[i1])
                bitslip_count[i1] <= (bitslip_count[i1] + 1) % deserialization_factor;
        end
    end // BITSLIP_CNT

    always @(posedge rx_data_align_clk)
    begin : DATA_ALIGN_REG
        rx_data_align_reg <= rx_data_align;
    end // DATA_ALIGN_REG

    always @(posedge rx_fastclk)
    begin : BITSLIP_REG
        int_bitslip_reg <= rx_data_align_int;
    end // BITSLIP_REG

    // Loading input data to shift register
    always @ (posedge rx_fastclk or posedge pll_areset)
    begin  : SHIFTREG
        if (pll_areset)
        begin
            rx_shift_reg  <= {REGISTER_WIDTH{1'b0}};
            rx_shift_reg1 <= {REGISTER_WIDTH{1'b0}};
            rx_shift_reg2 <= {REGISTER_WIDTH{1'b0}};
            h_int_reg <= {REGISTER_WIDTH{1'b0}};
            l_int_reg <= {REGISTER_WIDTH{1'b0}};
        end
        else
        begin
            // Implementation for even deserialization factor.
            if ((deserialization_factor % 2) == 0)
            begin
                for (i= 0; i < number_of_channels; i = i+1)
                begin
                    for (x=deserialization_factor-1; x >1; x=x-1)
                        rx_shift_reg[x + (i * deserialization_factor)] <=
                            rx_shift_reg [x-2 + (i * deserialization_factor)];

                    for (x=deserialization_factor-1; x >0; x=x-1)
                    begin
                        h_int_reg[x + (i * deserialization_factor)] <=
                            h_int_reg [x-1 + (i * deserialization_factor)];

                        l_int_reg[x + (i * deserialization_factor)] <=
                            l_int_reg [x-1 + (i * deserialization_factor)];
                    end

                    h_int_reg [i * deserialization_factor] <= datain_h_reg[i];
                    l_int_reg [i * deserialization_factor] <= datain_l_reg[i];

                    if (bitslip_count[i] == 0)
                    begin
                        rx_shift_reg[i * deserialization_factor] <= datain_h_reg[i];
                        rx_shift_reg[(i * deserialization_factor)+1] <= datain_l_reg[i];
                    end
                    else if (bitslip_count[i] == 1)
                    begin
                        rx_shift_reg[i * deserialization_factor] <= datain_l_reg[i];
                        rx_shift_reg[(i * deserialization_factor)+1] <= h_int_reg[i * deserialization_factor];
                    end
                    else
                    begin
                        if (bitslip_count[i] % 2 == 1)
                        begin
                            rx_shift_reg[i * deserialization_factor] <= l_int_reg[(bitslip_count[i]/2) -1 + (i * deserialization_factor)];
                            rx_shift_reg[(i * deserialization_factor)+1] <= h_int_reg[(bitslip_count[i]/2) + (i * deserialization_factor)];
                        end
                        else
                        begin
                            rx_shift_reg[i * deserialization_factor] <= h_int_reg[(bitslip_count[i]/2) -1 + (i * deserialization_factor)];
                            rx_shift_reg[(i * deserialization_factor)+1] <= l_int_reg[(bitslip_count[i]/2) -1 + (i * deserialization_factor)];
                        end
                    end
                end
            end
            else // Implementation for odd deserialization factor.
            begin
                for (i= 0; i < number_of_channels; i = i+1)
                begin
                    for (x=deserialization_factor-1; x >1; x=x-1)
                    begin
                        rx_shift_reg1[x + (i * deserialization_factor)] <=
                            rx_shift_reg1[x-2 + (i * deserialization_factor)];

                        rx_shift_reg2[x + (i * deserialization_factor)] <=
                            rx_shift_reg2[x-2 + (i * deserialization_factor)];
                    end

                    for (x=deserialization_factor-1; x >0; x=x-1)
                    begin
                        h_int_reg[x + (i * deserialization_factor)] <=
                            h_int_reg [x-1 + (i * deserialization_factor)];

                        l_int_reg[x + (i * deserialization_factor)] <=
                            l_int_reg [x-1 + (i * deserialization_factor)];
                    end

                    h_int_reg [i * deserialization_factor] <= datain_h_reg[i];
                    l_int_reg [i * deserialization_factor] <= datain_l_reg[i];

                    if (bitslip_count[i] == 0)
                    begin
                        rx_shift_reg1[i * deserialization_factor] <= datain_h_reg[i];
                        rx_shift_reg1[(i * deserialization_factor)+1] <= datain_l_reg[i];
                    end

                    else if (bitslip_count[i] == 1)
                    begin
                        rx_shift_reg1[i * deserialization_factor] <= datain_l_reg[i];
                        rx_shift_reg1[(i * deserialization_factor)+1] <= h_int_reg[i*deserialization_factor];
                    end

                    else if (bitslip_count[i] % 2 ==0)
                    begin
                        rx_shift_reg1[i * deserialization_factor] <= h_int_reg[bitslip_count[i]/2 -1 + (i * deserialization_factor)];
                        rx_shift_reg1[(i * deserialization_factor)+1] <= l_int_reg[bitslip_count[i]/2 -1 + (i * deserialization_factor)];
                    end

                    else
                    begin
                        rx_shift_reg1[i * deserialization_factor] <= l_int_reg[bitslip_count[i]/2 -1 + (i * deserialization_factor)];
                        rx_shift_reg1[(i * deserialization_factor)+1] <= h_int_reg[bitslip_count[i]/2 + (i * deserialization_factor)];
                    end

                    rx_shift_reg2[i * deserialization_factor] <=  rx_shift_reg1[((i+1)* deserialization_factor)-2];
                    rx_shift_reg2[(i * deserialization_factor)+1] <= rx_shift_reg1[((i+1)* deserialization_factor)-1];
                end
            end
        end
    end // SHIFTREG

    always @ (posedge rx_slowclk or posedge pll_areset)
    begin  : BIT_SELECT
        if (pll_areset)
        begin
            rx_sync_reg1  <= {REGISTER_WIDTH{1'b0}};
            rx_sync_reg2  <= {REGISTER_WIDTH{1'b0}};
            rx_sync_reg1_buf2_pipe  <= {REGISTER_WIDTH{1'b0}};
            rx_out_odd <= {REGISTER_WIDTH{1'b0}};
            rx_out_odd_mode <= {REGISTER_WIDTH{1'b0}};
        end
        else
        begin
            rx_sync_reg1 <= rx_shift_reg1;
            rx_sync_reg2 <= rx_shift_reg2;
            rx_sync_reg1_buf2_pipe <= rx_sync_reg1_buf2;

            if(use_extra_pll_clk == "NO")
            begin
                if (select_bit)
                    rx_out_odd_mode <= rx_sync_reg1_buf1_pipe;
                else
                    rx_out_odd_mode <= rx_sync_reg2_buf1;
            end
            else
            begin
                if (select_bit)
                    rx_out_odd_mode <= rx_sync_reg1_buf2_pipe;
                else
                    rx_out_odd_mode <= rx_sync_reg2_buf2;
            end

            rx_out_odd <= rx_out_odd_mode;
        end
    end // BIT_SELECT

    always @ (posedge rx_slowclk)
    begin
        if (rx_slowclk_pre == 1'b0)
        begin
            sync_clock <= ~sync_clock;
            select_bit <= ~select_bit;
        end
    end

    always @(rx_slowclk)
    begin
        rx_slowclk_pre <= rx_slowclk;
    end

    always @ (posedge sync_clock or posedge pll_areset)
    begin  : SYNC_REG
        if (pll_areset)
        begin
            rx_sync_reg1_buf1  <= {REGISTER_WIDTH{1'b0}};
            rx_sync_reg2_buf1  <= {REGISTER_WIDTH{1'b0}};
            rx_sync_reg1_buf1_pipe  <= {REGISTER_WIDTH{1'b0}};
        end
        else
        begin
            rx_sync_reg1_buf1 <= rx_sync_reg1;
            rx_sync_reg2_buf1 <= rx_sync_reg2;
            rx_sync_reg1_buf1_pipe <= rx_sync_reg1_buf1;
        end
    end // SYNC_REG

    always @ (posedge rx_syncclk or posedge pll_areset)
    begin : SYNC_REG2
        if (pll_areset)
        begin
            rx_sync_reg1_buf2  <= {REGISTER_WIDTH{1'b0}};
            rx_sync_reg2_buf2  <= {REGISTER_WIDTH{1'b0}};
        end
        else
        begin
            rx_sync_reg1_buf2 <= rx_sync_reg1;
            rx_sync_reg2_buf2 <= rx_sync_reg2;
        end
    end // SYNC_REG2

    always @ (posedge rx_slowclk or posedge pll_areset)
    begin : OUTPUT_REGISTER
        if (pll_areset)
            rx_out_reg <= {REGISTER_WIDTH{1'b0}};
        else
            rx_out_reg <= rx_out_int;
    end // OUTPUT_REGISTER

// CONTINOUS ASSIGNMENT
    assign rx_out_int = ((deserialization_factor % 2) == 0) ? rx_shift_reg :
                    (buffer_implementation == "MUX") ? ((!select_bit) ? rx_sync_reg1_buf1 : rx_sync_reg2_buf1) :
                    rx_out_odd;
    assign rx_out = ((registered_output == "ON") && (use_external_pll == "OFF")) ? rx_out_reg : rx_out_int;
    assign rx_data_align_clk = ((deserialization_factor % 2) == 0) ? rx_slowclk :
                                (use_extra_pll_clk == "NO") ? sync_clock : rx_syncclk;
    assign rx_data_align_int = (registered_data_align_input == "ON") && (use_external_pll == "OFF") ? rx_data_align_reg : rx_data_align;

endmodule // flexible_lvds_rx

