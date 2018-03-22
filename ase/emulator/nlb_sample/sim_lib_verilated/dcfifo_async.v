// Created by altera_lib_mf.pl from altera_mf.v
// END OF MODULE

//START_MODULE_NAME------------------------------------------------------------
//
// Module Name     :  dcfifo_async
//
// Description     :  Asynchronous Dual Clocks FIFO
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
module dcfifo_async (data, rdclk, wrclk, aclr, rdreq, wrreq,
                    rdfull, wrfull, rdempty, wrempty, rdusedw, wrusedw, q);

// GLOBAL PARAMETER DECLARATION
    parameter lpm_width = 1;
    parameter lpm_widthu = 1;
    parameter lpm_numwords = 2;
    parameter delay_rdusedw = 1;
    parameter delay_wrusedw = 1;
    parameter rdsync_delaypipe = 0;
    parameter wrsync_delaypipe = 0;
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
    input wrreq;
    input rdreq;

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
    reg [lpm_width-1:0] mem_data2 [(1<<lpm_widthu)-1:0];
    reg data_ready [(1<<lpm_widthu)-1:0];
    reg [2:0] data_delay_count [(1<<lpm_widthu)-1:0];
    reg [lpm_width-1:0] i_data_tmp;
    reg [lpm_widthu-1:0] i_rdptr;
    reg [lpm_widthu-1:0] i_wrptr;
    reg [lpm_widthu-1:0] i_wrptr_tmp;
    reg i_rdenclock;
    reg i_wren_tmp;
    reg i_showahead_flag;
    reg i_showahead_flag1;
    reg i_showahead_flag2;
    reg i_showahead_flag3;
    reg [lpm_widthu-1:0] i_wr_udwn;
    reg [lpm_widthu-1:0] i_rd_udwn;
    reg [lpm_widthu:0] i_rdusedw;
    reg [lpm_widthu-1:0] i_wrusedw;
    reg [lpm_width-1:0] i_q_tmp;
    reg feature_family_base_stratix;
    reg feature_family_base_cyclone;

// INTERNAL WIRE DECLARATION
    wire i_rden;
    wire i_wren;
    wire w_rdempty;
    wire w_wrempty;
    wire w_rdfull;
    wire w_wrfull;
    wire [lpm_widthu-1:0] w_rdptrrg;
    wire [lpm_widthu-1:0] w_wrdelaycycle;
    wire [lpm_widthu-1:0] w_ws_nbrp;
    wire [lpm_widthu-1:0] w_rs_nbwp;
    wire [lpm_widthu-1:0] w_ws_dbrp;
    wire [lpm_widthu-1:0] w_rs_dbwp;
    wire [lpm_widthu-1:0] w_rd_dbuw;
    wire [lpm_widthu-1:0] w_wr_dbuw;
    wire [lpm_widthu-1:0] w_rdusedw;
    wire [lpm_widthu-1:0] w_wrusedw;

// INTERNAL TRI DECLARATION
    logic aclr; // -- converted tristate to logic

// LOCAL INTEGER DECLARATION
    integer i;
    integer j;
    integer k;

// COMPONENT INSTANTIATION
    ALTERA_DEVICE_FAMILIES dev ();

// INITIAL CONSTRUCT BLOCK
    initial
    begin

    feature_family_base_stratix = dev.FEATURE_FAMILY_BASE_STRATIX(intended_device_family);
    feature_family_base_cyclone = dev.FEATURE_FAMILY_BASE_CYCLONE(intended_device_family);

        if((lpm_showahead != "ON") && (lpm_showahead != "OFF"))
            $display ("Error! lpm_showahead must be ON or OFF.");
        if((underflow_checking != "ON") && (underflow_checking != "OFF"))
            $display ("Error! underflow_checking must be ON or OFF.");
        if((overflow_checking != "ON") && (overflow_checking != "OFF"))
            $display ("Error! overflow_checking must be ON or OFF.");
        if((use_eab != "ON") && (use_eab != "OFF"))
            $display ("Error! use_eab must be ON or OFF.");
        if((add_ram_output_register != "ON") && (add_ram_output_register != "OFF"))
            $display ("Error! add_ram_output_register must be ON or OFF.");
        if (dev.IS_VALID_FAMILY(intended_device_family) == 0)
            $display ("Error! Unknown INTENDED_DEVICE_FAMILY=%s.", intended_device_family);

        for (i = 0; i < (1 << lpm_widthu); i = i + 1)
        begin
            mem_data[i] <= 0;
            mem_data2[i] <= 0;
            data_ready[i] <= 1'b0;
            data_delay_count[i] <= 0;
        end

        if ((add_ram_output_register == "OFF") &&
            ((feature_family_base_stratix == 1) || (feature_family_base_cyclone == 1)))
        begin
            for (i = 0; i < (1 << lpm_widthu); i = i + 1)
            begin
                mem_data2[i] <= {lpm_width{1'b0 /* converted x or z to 1'b0 */}};
            end
        end
        else
        begin
            for (i = 0; i < (1 << lpm_widthu); i = i + 1)
            begin
                mem_data2[i] <= 0;
            end
        end

        i_data_tmp <= 0;
        i_rdptr <= 0;
        i_wrptr <= 0;
        i_wrptr_tmp <= 0;
        i_wren_tmp <= 0;
        i_wr_udwn <= 0;
        i_rd_udwn <= 0;
        i_rdusedw <= 0;
        i_wrusedw <= 0;
        i_q_tmp <= 0;
    end

// COMPONENT INSTANTIATIONS
    // Delays & DFF Pipes
    dcfifo_dffpipe DP_RDPTR_D (
        .d (i_rdptr),
        .clock (i_rdenclock),
        .aclr (aclr),
        .q (w_rdptrrg));
    dcfifo_dffpipe DP_WRPTR_D (
        .d (i_wrptr),
        .clock (wrclk),
        .aclr (aclr),
        .q (w_wrdelaycycle));
    defparam
        DP_RDPTR_D.lpm_delay = 0,
        DP_RDPTR_D.lpm_width = lpm_widthu,
        DP_WRPTR_D.lpm_delay = 1,
        DP_WRPTR_D.lpm_width = lpm_widthu;

    dcfifo_dffpipe DP_WS_NBRP (
        .d (w_rdptrrg),
        .clock (wrclk),
        .aclr (aclr),
        .q (w_ws_nbrp));
    dcfifo_dffpipe DP_RS_NBWP (
        .d (w_wrdelaycycle),
        .clock (rdclk),
        .aclr (aclr),
        .q (w_rs_nbwp));
    dcfifo_dffpipe DP_WS_DBRP (
        .d (w_ws_nbrp),
        .clock (wrclk),
        .aclr (aclr),
        .q (w_ws_dbrp));
    dcfifo_dffpipe DP_RS_DBWP (
        .d (w_rs_nbwp),
        .clock (rdclk),
        .aclr (aclr),
        .q (w_rs_dbwp));
    defparam
        DP_WS_NBRP.lpm_delay = wrsync_delaypipe,
        DP_WS_NBRP.lpm_width = lpm_widthu,
        DP_RS_NBWP.lpm_delay = rdsync_delaypipe,
        DP_RS_NBWP.lpm_width = lpm_widthu,
        DP_WS_DBRP.lpm_delay = 1,              // gray_delaypipe
        DP_WS_DBRP.lpm_width = lpm_widthu,
        DP_RS_DBWP.lpm_delay = 1,              // gray_delaypipe
        DP_RS_DBWP.lpm_width = lpm_widthu;

    dcfifo_dffpipe DP_WRUSEDW (
        .d (i_wr_udwn),
        .clock (wrclk),
        .aclr (aclr),
        .q (w_wrusedw));
    dcfifo_dffpipe DP_RDUSEDW (
        .d (i_rd_udwn),
        .clock (rdclk),
        .aclr (aclr),
        .q (w_rdusedw));
    dcfifo_dffpipe DP_WR_DBUW (
        .d (i_wr_udwn),
        .clock (wrclk),
        .aclr (aclr),
        .q (w_wr_dbuw));
    dcfifo_dffpipe DP_RD_DBUW (
        .d (i_rd_udwn),
        .clock (rdclk),
        .aclr (aclr),
        .q (w_rd_dbuw));
    defparam
        DP_WRUSEDW.lpm_delay = delay_wrusedw,
        DP_WRUSEDW.lpm_width = lpm_widthu,
        DP_RDUSEDW.lpm_delay = delay_rdusedw,
        DP_RDUSEDW.lpm_width = lpm_widthu,
        DP_WR_DBUW.lpm_delay = 1,              // wrusedw_delaypipe
        DP_WR_DBUW.lpm_width = lpm_widthu,
        DP_RD_DBUW.lpm_delay = 1,              // rdusedw_delaypipe
        DP_RD_DBUW.lpm_width = lpm_widthu;

    // Empty/Full
    dcfifo_fefifo WR_FE (
        .usedw_in (w_wr_dbuw),
        .wreq (wrreq),
        .rreq (rdreq),
        .clock (wrclk),
        .aclr (aclr),
        .empty (w_wrempty),
        .full (w_wrfull));
    dcfifo_fefifo RD_FE (
        .usedw_in (w_rd_dbuw),
        .rreq (rdreq),
        .wreq(wrreq),
        .clock (rdclk),
        .aclr (aclr),
        .empty (w_rdempty),
        .full (w_rdfull));
    defparam
        WR_FE.lpm_widthad = lpm_widthu,
        WR_FE.lpm_numwords = lpm_numwords,
        WR_FE.underflow_checking = underflow_checking,
        WR_FE.overflow_checking = overflow_checking,
        WR_FE.lpm_mode = "WRITE",
        RD_FE.lpm_widthad = lpm_widthu,
        RD_FE.lpm_numwords = lpm_numwords,
        RD_FE.underflow_checking = underflow_checking,
        RD_FE.overflow_checking = overflow_checking,
        RD_FE.lpm_mode = "READ";

// ALWAYS CONSTRUCT BLOCK
    always @(posedge aclr)
    begin
        i_rdptr <= 0;
        i_wrptr <= 0;
        if (!((feature_family_base_stratix == 1) ||
        (feature_family_base_cyclone == 1)) ||
        (use_eab == "OFF"))
        begin
            if (lpm_showahead == "ON")
                i_q_tmp <= mem_data[0];
            else
                i_q_tmp <= 0;
        end
        else if ((add_ram_output_register == "ON") &&
                ((feature_family_base_stratix == 1) ||
                (feature_family_base_cyclone == 1)))
        begin
            if (lpm_showahead == "OFF")
                i_q_tmp <= 0;
            else
            begin
                i_q_tmp <= {lpm_width{1'b0 /* converted x or z to 1'b0 */}};

                for (j = 0; j < (1<<lpm_widthu); j = j + 1)
                begin
                    data_ready[i_wrptr_tmp] <= 1'b0;
                    data_delay_count[k] <= 0;
                end
            end
        end
    end // @(posedge aclr)

    always @(posedge wrclk)
    begin
        if (aclr && (!((feature_family_base_stratix == 1) ||
            (feature_family_base_cyclone == 1)) ||
            (add_ram_output_register == "ON") || (use_eab == "OFF")))
        begin
            i_data_tmp <= 0;
            i_wrptr_tmp <= 0;
            i_wren_tmp <= 0;
        end
        else if (wrclk && ($time > 0))
        begin
            i_data_tmp <= data;
            i_wrptr_tmp <= i_wrptr;
            i_wren_tmp <= i_wren;

            if (i_wren)
            begin
                if (~aclr && ((i_wrptr < (1<<lpm_widthu)-1) || (overflow_checking == "OFF")))
                    i_wrptr <= i_wrptr + 1;
                else
                    i_wrptr <= 0;

                if (use_eab == "OFF")
                begin
                    mem_data[i_wrptr] <= data;

                    if (lpm_showahead == "ON")
                        i_showahead_flag3 <= 1'b1;
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
                data_ready[i_wrptr_tmp] <= 1'b0;
            end

            if ((lpm_showahead == "ON") &&
                (!((feature_family_base_stratix == 1) ||
                (feature_family_base_cyclone == 1))))
                i_showahead_flag3 <= 1'b1;
        end
    end // @(negedge wrclk)

    always @(posedge rdclk)
    begin

        if (rdclk && ($time > 0))
        begin
            if ((lpm_showahead == "ON") && (add_ram_output_register == "ON") &&
                ((feature_family_base_stratix == 1) ||
                (feature_family_base_cyclone == 1)))
            begin
                for (k = 0; k < (1<<lpm_widthu); k = k + 1)
                begin
                    if (data_ready[k] == 1'b0)
                        data_delay_count[k] <= data_delay_count[k] + 1;

                    if (data_delay_count[k] == (rdsync_delaypipe+2))
                    begin
                        data_ready[k] <= 1'b1;
                        data_delay_count[k] <= 0;
                    end
                end

                if (~aclr)
                begin
                    i_showahead_flag3 <= 1'b1;
                end
            end

        end

        if (aclr && (!((feature_family_base_stratix == 1) ||
        (feature_family_base_cyclone == 1)) ||
        (use_eab == "OFF")))
        begin
            if (lpm_showahead == "ON")
                i_q_tmp <= mem_data[0];
            else
                i_q_tmp <= 0;
        end
        else if (aclr && (add_ram_output_register == "ON") &&
                ((feature_family_base_stratix == 1) ||
                (feature_family_base_cyclone == 1)))
        begin
            if (lpm_showahead == "ON")
                i_q_tmp <= {lpm_width{1'b0 /* converted x or z to 1'b0 */}};
            else
                i_q_tmp <= 0;
        end
        else if (rdclk && i_rden && ($time > 0))
        begin
            if (~aclr && ((i_rdptr < (1<<lpm_widthu)-1) || (underflow_checking == "OFF")))
                i_rdptr <= i_rdptr + 1;
            else
                i_rdptr <= 0;

            if (lpm_showahead == "ON")
                i_showahead_flag3 <= 1'b1;
            else
                i_q_tmp <= mem_data[i_rdptr];
        end
    end // @(posedge rdclk)

    always @(i_showahead_flag3)
    begin
        i_showahead_flag2 <= i_showahead_flag3;
    end

    always @(i_showahead_flag2)
    begin
        i_showahead_flag1 <= i_showahead_flag2;
    end

    always @(i_showahead_flag1)
    begin
        i_showahead_flag <= i_showahead_flag1;
    end


    always @(posedge i_showahead_flag)
    begin
        if ((lpm_showahead == "ON") && (add_ram_output_register == "ON") &&
            ((feature_family_base_stratix == 1) ||
            (feature_family_base_cyclone == 1)))
        begin
            if (w_rdempty == 1'b0)
            begin
                if (data_ready[i_rdptr] == 1'b1)
                begin
                    i_q_tmp <= mem_data[i_rdptr];
                    mem_data2[i_rdptr] <= mem_data[i_rdptr];
                end
                else
                i_q_tmp <= mem_data2[i_rdptr];
            end
        end
        else
            i_q_tmp <= mem_data[i_rdptr];
        i_showahead_flag3 <= 1'b0;
    end // @(posedge i_showahead_flag)

    // Delays & DFF Pipes
    always @(negedge rdclk)
    begin
        i_rdenclock <= 0;
    end // @(negedge rdclk)

    always @(posedge rdclk)
    begin
        if (i_rden)
            i_rdenclock <= 1;
    end // @(posedge rdclk)

    always @(i_wrptr or w_ws_dbrp)
    begin
        i_wr_udwn = i_wrptr - w_ws_dbrp;
    end // @(i_wrptr or w_ws_dbrp)

    always @(i_rdptr or w_rs_dbwp)
    begin
        i_rd_udwn = w_rs_dbwp - i_rdptr;
    end // @(i_rdptr or w_rs_dbwp)


// CONTINOUS ASSIGNMENT
    assign i_rden = (underflow_checking == "OFF") ? rdreq : (rdreq && !w_rdempty);
    assign i_wren = (overflow_checking == "OFF")  ? wrreq : (wrreq && !w_wrfull);
    assign q = i_q_tmp;
    assign wrfull = w_wrfull;
    assign rdfull = w_rdfull;
    assign wrempty = w_wrempty;
    assign rdempty = w_rdempty;
    assign wrusedw = w_wrusedw;
    assign rdusedw = w_rdusedw;

endmodule // dcfifo_async

