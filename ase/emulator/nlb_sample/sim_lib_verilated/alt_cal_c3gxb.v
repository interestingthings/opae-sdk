// Created by altera_lib_mf.pl from altera_mf.v
//VALID FILE



/*verilator lint_off CASEX*/
/*verilator lint_off COMBDLY*/
/*verilator lint_off INITIALDLY*/
/*verilator lint_off LITENDIAN*/
/*verilator lint_off MULTIDRIVEN*/
/*verilator lint_off UNOPTFLAT*/
/*verilator lint_off BLKANDNBLK*/
module  alt_cal_c3gxb
        (
        busy,
        cal_error,
        clock,
        dprio_addr,
        dprio_busy,
        dprio_datain,
        dprio_dataout,
        dprio_rden,
        dprio_wren,
        quad_addr,
        remap_addr,
        reset,
        retain_addr,
        start,
        testbuses) /* synthesis synthesis_clearbox=1 */;

        parameter number_of_channels = 1;
        parameter channel_address_width = 1;
        parameter sim_model_mode = "TRUE";
        parameter lpm_type = "alt_cal_c3gxb";
        parameter lpm_hint = "UNUSED";

        output   busy;
        output   [(number_of_channels-1):0]  cal_error;
        input   clock;
        output   [15:0]  dprio_addr;
        input   dprio_busy;
        input   [15:0]  dprio_datain;
        output   [15:0]  dprio_dataout;
        output   dprio_rden;
        output   dprio_wren;
        output   [8:0]  quad_addr;
        input   [11:0]  remap_addr;
        input   reset;
        output   [0:0]  retain_addr;
        input   start;
        input   [(number_of_channels)-1:0]  testbuses;

        (* ALTERA_ATTRIBUTE = {"PRESERVE_REGISTER=ON;POWER_UP_LEVEL=LOW"} *)
        reg     [0:0]   p0addr_sim;
        (* ALTERA_ATTRIBUTE = {"PRESERVE_REGISTER=ON;POWER_UP_LEVEL=LOW"} *)
        reg     [3:0]   sim_counter_reg;
        (* ALTERA_ATTRIBUTE = {"PRESERVE_REGISTER=ON;POWER_UP_LEVEL=HIGH"} *)
	reg     [0:0]   first_run;
        wire    [3:0]   wire_next_scount_num_dataa;
        wire    [3:0]   wire_next_scount_num_datab;
        wire    [3:0]   wire_next_scount_num_result;
        wire  [0:0]  busy_sim;
        wire  [0:0]  sim_activator;
        wire  [0:0]  sim_counter_and;
        wire  [3:0]  sim_counter_next;
        wire  [0:0]  sim_counter_or;

        // synopsys translate_off
        initial begin
                p0addr_sim[0:0] = 0;
		first_run = 1;
	end
        // synopsys translate_on
        always @ ( posedge clock)
                p0addr_sim[0:0] <= 1'b1;
        // synopsys translate_off
        initial
                sim_counter_reg = 0;
        // synopsys translate_on
        always @ ( posedge clock) begin
                sim_counter_reg <= ({4{(~start & sim_activator)}} & (({4{(p0addr_sim | ((~ sim_counter_and) & sim_counter_or))}} & sim_counter_next) | ({4{sim_counter_and}} & sim_counter_reg)) & {4{~(first_run & reset)}}) | ({4{reset & ~first_run}});
                if (first_run == 1'b1) begin
                        first_run <= ~sim_counter_and;
                end else begin
                        first_run <= 1'b0;
                end
        end

        assign
                wire_next_scount_num_result = wire_next_scount_num_dataa + wire_next_scount_num_datab;
        assign
                wire_next_scount_num_dataa = sim_counter_reg,
                wire_next_scount_num_datab = 4'b0001;
        assign
                busy = busy_sim,
                busy_sim = (~reset & p0addr_sim & (~ sim_counter_and)),
                cal_error = 1'b0,
                dprio_addr = {16{1'b0}},
                dprio_dataout = {16{1'b0}},
                dprio_rden = 1'b0,
                dprio_wren = 1'b0,
                quad_addr = {9{1'b0}},
                retain_addr = 1'b0,
                sim_activator = p0addr_sim,
                sim_counter_and = (((sim_counter_reg[0] & sim_counter_reg[1]) & sim_counter_reg[2]) & sim_counter_reg[3]),
                sim_counter_next = wire_next_scount_num_result,
                sim_counter_or = (((sim_counter_reg[0] | sim_counter_reg[1]) | sim_counter_reg[2]) | sim_counter_reg[3]);
endmodule

