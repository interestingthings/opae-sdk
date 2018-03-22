// Created by altera_lib_mf.pl from altera_mf.v
// END OF MODULE

//START_MODULE_NAME------------------------------------------------------------
//
// Module Name     :  dcfifo_sync
//
// Description     :  Synchronous Dual Clock FIFO
//
// Limitation      :
//
// Results expected:
//
//END_MODULE_NAME--------------------------------------------------------------

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
module dcfifo_sync (data, rdclk, wrclk, aclr, rdreq, wrreq,
                    rdfull, wrfull, rdempty, wrempty, rdusedw, wrusedw, q);

// GLOBAL PARAMETER DECLARATION
    parameter lpm_width = 1;
    parameter lpm_widthu = 1;
    parameter lpm_numwords = 2;
    parameter intended_device_family = "Stratix";
    parameter lpm_showahead = "OFF";
    parameter underflow_checking = "ON";
    parameter overflow_checking = "ON";
    parameter use_eab = "ON";
    parameter add_ram_output_register = "OFF";

// INPUT PORT DECLARATION
    input [lpm_width-1:0] data;
    input rdclk;
    input wrclk;
    input aclr;
    input rdreq;
    input wrreq;

// OUTPUT PORT DECLARATION
    output rdfull;
    output wrfull;
    output rdempty;
    output wrempty;
    output [lpm_widthu-1:0] rdusedw;
    output [lpm_widthu-1:0] wrusedw;
    output [lpm_width-1:0] q;

// INTERNAL REGISTERS DECLARATION
    reg [lpm_width-1:0] mem_data [(1<<lpm_widthu)-1:0];
    reg [lpm_width-1:0] i_data_tmp;
    reg [lpm_widthu:0] i_rdptr;
    reg [lpm_widthu:0] i_wrptr;
    reg [lpm_widthu-1:0] i_wrptr_tmp;
    reg i_wren_tmp;
    reg i_showahead_flag;
    reg i_showahead_flag2;
    reg [lpm_widthu:0] i_rdusedw;
    reg [lpm_widthu:0] i_wrusedw;
    reg [lpm_width-1:0] i_q_tmp;
    reg feature_family_base_stratix;
    reg feature_family_base_cyclone;
    reg feature_family_stratixii;
    reg feature_family_cycloneii;
    reg feature_family_stratixiii;
    reg feature_family_cycloneiii;

// INTERNAL WIRE DECLARATION
    wire [lpm_widthu:0] w_rdptr_s;
    wire [lpm_widthu:0] w_wrptr_s;
    wire [lpm_widthu:0] w_wrptr_r;
    wire i_rden;
    wire i_wren;
    wire i_rdempty;
    wire i_wrempty;
    wire i_rdfull;
    wire i_wrfull;

// LOCAL INTEGER DECLARATION
    integer cnt_mod;
    integer i;

// COMPONENT INSTANTIATION
    ALTERA_DEVICE_FAMILIES dev ();

// INITIAL CONSTRUCT BLOCK
    initial
    begin

    feature_family_base_stratix = dev.FEATURE_FAMILY_BASE_STRATIX(intended_device_family);
    feature_family_base_cyclone = dev.FEATURE_FAMILY_BASE_CYCLONE(intended_device_family);
    feature_family_stratixii = dev.FEATURE_FAMILY_STRATIXII(intended_device_family);
    feature_family_cycloneii = dev.FEATURE_FAMILY_CYCLONEII(intended_device_family);
    feature_family_stratixiii = dev.FEATURE_FAMILY_STRATIXIII(intended_device_family);
    feature_family_cycloneiii = dev.FEATURE_FAMILY_CYCLONEIII(intended_device_family);

        if ((lpm_showahead != "ON") && (lpm_showahead != "OFF"))
            $display ("Error! LPM_SHOWAHEAD must be ON or OFF.");
        if ((underflow_checking != "ON") && (underflow_checking != "OFF"))
            $display ("Error! UNDERFLOW_CHECKING must be ON or OFF.");
        if ((overflow_checking != "ON") && (overflow_checking != "OFF"))
            $display ("Error! OVERFLOW_CHECKING must be ON or OFF.");
        if ((use_eab != "ON") && (use_eab != "OFF"))
            $display ("Error! USE_EAB must be ON or OFF.");
        if (lpm_numwords > (1 << lpm_widthu))
            $display ("Error! LPM_NUMWORDS must be less than or equal to 2**LPM_WIDTHU.");
        if((add_ram_output_register != "ON") && (add_ram_output_register != "OFF"))
            $display ("Error! add_ram_output_register must be ON or OFF.");
        if (dev.IS_VALID_FAMILY(intended_device_family) == 0)
            $display ("Error! Unknown INTENDED_DEVICE_FAMILY=%s.", intended_device_family);

        for (i = 0; i < (1 << lpm_widthu); i = i + 1)
            mem_data[i] <= 0;
        i_data_tmp <= 0;
        i_rdptr <= 0;
        i_wrptr <= 0;
        i_wrptr_tmp <= 0;
        i_wren_tmp <= 0;

        i_rdusedw <= 0;
        i_wrusedw <= 0;
        i_q_tmp <= 0;

        if (lpm_numwords == (1 << lpm_widthu))
            cnt_mod <= 1 << (lpm_widthu + 1);
        else
            cnt_mod <= 1 << lpm_widthu;
    end

// COMPONENT INSTANTIATIONS
    dcfifo_dffpipe RDPTR_D (
        .d (i_rdptr),
        .clock (wrclk),
        .aclr (aclr),
        .q (w_rdptr_s));
    dcfifo_dffpipe WRPTR_D (
        .d (i_wrptr),
        .clock (wrclk),
        .aclr (aclr),
        .q (w_wrptr_r));
    dcfifo_dffpipe WRPTR_E (
        .d (w_wrptr_r),
        .clock (rdclk),
        .aclr (aclr),
        .q (w_wrptr_s));
    defparam
        RDPTR_D.lpm_delay = 1,
        RDPTR_D.lpm_width = lpm_widthu + 1,
        WRPTR_D.lpm_delay = 1,
        WRPTR_D.lpm_width = lpm_widthu + 1,
        WRPTR_E.lpm_delay = 1,
        WRPTR_E.lpm_width = lpm_widthu + 1;

// ALWAYS CONSTRUCT BLOCK
    always @(posedge aclr)
    begin
        i_rdptr <= 0;
        i_wrptr <= 0;
        if (!((feature_family_base_stratix == 1) ||
        (feature_family_base_cyclone == 1)) ||
        ((add_ram_output_register == "ON") && (use_eab == "OFF")))
            if (lpm_showahead == "ON")
            begin
                if ((feature_family_stratixii == 1) ||
                (feature_family_cycloneii == 1))
                    i_q_tmp <= {lpm_width{1'bX}};
                else
                    i_q_tmp <= mem_data[0];
            end
            else
                i_q_tmp <= 0;
    end // @(posedge aclr)

    always @(posedge wrclk)
    begin
        if (aclr && (!((feature_family_base_stratix == 1) ||
        (feature_family_base_cyclone == 1)) ||
        ((add_ram_output_register == "ON") && (use_eab == "OFF"))))
        begin
            i_data_tmp <= 0;
            i_wrptr_tmp <= 0;
            i_wren_tmp <= 0;
        end
        else if (wrclk && ($time > 0))
        begin
            i_data_tmp <= data;
            i_wrptr_tmp <= i_wrptr[lpm_widthu-1:0];
            i_wren_tmp <= i_wren;

            if (i_wren)
            begin
                if (~aclr && (i_wrptr < cnt_mod - 1))
                    i_wrptr <= i_wrptr + 1;
                else
                    i_wrptr <= 0;

                if (use_eab == "OFF")
                begin
                    mem_data[i_wrptr[lpm_widthu-1:0]] <= data;

                    if (lpm_showahead == "ON")
                        i_showahead_flag2 <= 1'b1;
                end
            end
        end
    end // @(posedge wrclk)

    always @(negedge wrclk)
    begin
        if ((~wrclk && (use_eab == "ON")) && ($time > 0))
        begin
            if (i_wren_tmp)
            begin
                mem_data[i_wrptr_tmp] <= i_data_tmp;
            end

            if ((lpm_showahead == "ON") &&
                (!((feature_family_base_stratix == 1) ||
                (feature_family_base_cyclone == 1))))
                i_showahead_flag2 <= 1'b1;
        end
    end // @(negedge wrclk)

    always @(posedge rdclk)
    begin
        if (aclr && (!((feature_family_base_stratix == 1) ||
        (feature_family_base_cyclone == 1)) ||
        ((add_ram_output_register == "ON") && (use_eab == "OFF"))))
        begin
            if (lpm_showahead == "ON")
            begin
                if ((feature_family_stratixii == 1) ||
                (feature_family_cycloneii == 1))
                    i_q_tmp <= {lpm_width{1'bX}};
                else
                    i_q_tmp <= mem_data[0];
            end
            else
                i_q_tmp <= 0;
        end
        else if (rdclk && i_rden && ($time > 0))
        begin
            if (~aclr && (i_rdptr < cnt_mod - 1))
                i_rdptr <= i_rdptr + 1;
            else
                i_rdptr <= 0;

            if ((lpm_showahead == "ON") && (!((use_eab == "ON") &&
                ((feature_family_base_stratix == 1) ||
                (feature_family_base_cyclone == 1)))))
                i_showahead_flag2 <= 1'b1;
            else
                i_q_tmp <= mem_data[i_rdptr[lpm_widthu-1:0]];
        end
    end // @(rdclk)

    always @(posedge i_showahead_flag)
    begin
        i_q_tmp <= mem_data[i_rdptr[lpm_widthu-1:0]];
        i_showahead_flag2 <= 1'b0;
    end // @(posedge i_showahead_flag)

    always @(i_showahead_flag2)
    begin
        i_showahead_flag <= i_showahead_flag2;
    end // @(i_showahead_flag2)

    // Usedw, Empty, Full
    always @(i_rdptr or w_wrptr_s or cnt_mod)
    begin
        if (w_wrptr_s >= i_rdptr)
            i_rdusedw <= w_wrptr_s - i_rdptr;
        else
            i_rdusedw <= w_wrptr_s + cnt_mod - i_rdptr;
    end // @(i_rdptr or w_wrptr_s)

    always @(i_wrptr or w_rdptr_s or cnt_mod)
    begin
        if (i_wrptr >= w_rdptr_s)
            i_wrusedw <= i_wrptr - w_rdptr_s;
        else
            i_wrusedw <= i_wrptr + cnt_mod - w_rdptr_s;
    end // @(i_wrptr or w_rdptr_s)


// CONTINOUS ASSIGNMENT
    assign i_rden = (underflow_checking == "OFF") ? rdreq : (rdreq && !i_rdempty);
    assign i_wren = (overflow_checking == "OFF")  ? wrreq : (wrreq && !i_wrfull);
    assign i_rdempty = (i_rdusedw == 0) ? 1'b1 : 1'b0;
    assign i_wrempty = (i_wrusedw == 0) ? 1'b1 : 1'b0;
    assign i_rdfull = (((lpm_numwords == (1 << lpm_widthu)) && i_rdusedw[lpm_widthu]) ||
                    ((lpm_numwords < (1 << lpm_widthu)) && (i_rdusedw == lpm_numwords)))
                    ? 1'b1 : 1'b0;
    assign i_wrfull = (((lpm_numwords == (1 << lpm_widthu)) && i_wrusedw[lpm_widthu]) ||
                    ((lpm_numwords < (1 << lpm_widthu)) && (i_wrusedw == lpm_numwords)))
                    ? 1'b1 : 1'b0;
    assign rdempty = i_rdempty;
    assign wrempty = i_wrempty;
    assign rdfull = i_rdfull;
    assign wrfull = i_wrfull;
    assign wrusedw = i_wrusedw[lpm_widthu-1:0];
    assign rdusedw = i_rdusedw[lpm_widthu-1:0];
    assign q = i_q_tmp;

endmodule // dcfifo_sync

