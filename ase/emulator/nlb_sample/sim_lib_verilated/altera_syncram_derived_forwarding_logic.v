// Created by altera_lib_mf.pl from altera_mf.v

/*verilator lint_off CASEX*/
/*verilator lint_off COMBDLY*/
/*verilator lint_off INITIALDLY*/
/*verilator lint_off LITENDIAN*/
/*verilator lint_off MULTIDRIVEN*/
/*verilator lint_off UNOPTFLAT*/
/*verilator lint_off BLKANDNBLK*/
module altera_syncram_derived_forwarding_logic (
                                    wrdata_reg,
                                    wren,
				    rden,
                                    wraddr,
				    rdaddr,
                                    wren_reg,
				    rden_reg,
                                    wraddr_reg,
                                    rdaddr_reg,
                                    clock,
                                    fwd_out,
                                    stage2_cmp_out
                                   );


parameter dwidth = 1;
parameter awidth = 1;
parameter fwd_stage1_enabled = 0;
parameter fwd_stage2_enabled = 0;

output  [dwidth - 1 : 0]    fwd_out;
output                      stage2_cmp_out;
input   [dwidth - 1 : 0]    wrdata_reg;
input                       clock;
input                       wren;
input                       wren_reg;
input 			    rden;
input			    rden_reg;
input   [awidth - 1 : 0]    wraddr;
input   [awidth - 1 : 0]    rdaddr;
input   [awidth - 1 : 0]    wraddr_reg;
input   [awidth - 1 : 0]    rdaddr_reg;


wire    stage1_cohr_chk;
wire    stage2_cohr_chk;
reg     stage1_cohr_chk_1;
wire    [dwidth - 1 : 0] stage1_mux_out;
reg     stage1_cmp_reg;
reg     stage2_cmp_reg;
reg     [dwidth - 1 : 0]    fwd_data_reg;

//stage-1 comparator
    assign stage1_cohr_chk  = (wraddr == rdaddr_reg && rden_reg) ? wren : 1'b0;
    assign stage1_mux_out   = (fwd_stage1_enabled && rden_reg) ? wrdata_reg : ((stage1_cmp_reg && rden_reg)? wrdata_reg :  fwd_data_reg);

//stage-2 comparator
    assign stage2_cohr_chk  = (stage1_cohr_chk && rden_reg)? 1'b1 : ((wraddr_reg == rdaddr_reg && rden_reg) ? wren_reg : 1'b0);

///output
    assign stage2_cmp_out   = (fwd_stage2_enabled) ? stage2_cmp_reg : stage1_cmp_reg;
    assign fwd_out          = stage1_mux_out;

always @ (posedge clock) begin
    //reset?
    stage1_cmp_reg  = stage1_cohr_chk;
    stage2_cmp_reg  = stage2_cohr_chk;
    fwd_data_reg    = wrdata_reg;
end

endmodule// END OF ALTERA_SYNCRAM_FORWARDING_LOGIC

