// Created by altera_lib_mf.pl from altera_mf.v
// END OF MODULE


//START_MODULE_NAME--------------------------------------------------------------
//
// Module Name     :  stratixv_local_clk_divider

// Description     :  This module is used to generate the local loaden signal from fast clock for StratixV
//                    family. To mimic local clock divider block.

// Limitation      :  Only available STRATIX V family.
//
// Results expected:  Loaden signal
//
//END_MODULE_NAME----------------------------------------------------------------

// BEGINNING OF MODULE
`timescale 1 ps / 1 ps
/*verilator lint_off CASEX*/
/*verilator lint_off COMBDLY*/
/*verilator lint_off INITIALDLY*/
/*verilator lint_off LITENDIAN*/
/*verilator lint_off MULTIDRIVEN*/
/*verilator lint_off UNOPTFLAT*/
/*verilator lint_off BLKANDNBLK*/
module stratixv_local_clk_divider (
                            clkin,
                            lloaden
                          );
parameter clk_divide_by =1;

input clkin;
output lloaden;

reg[4:0] cnt;
reg lloaden_tmp;
reg count;

initial
begin
    cnt = 5'b00000;

count = 1'b0;
    lloaden_tmp = 1'b0;
end

assign lloaden = lloaden_tmp;


always@(posedge clkin)
begin

count = 1'b1;
end



always@(negedge clkin)

begin
         if(count == 1'b1)


 begin



if(cnt < clk_divide_by-1)




cnt = cnt + 1;



else




cnt = 0;


 end

end




always@( cnt )
    begin
        if( cnt == clk_divide_by-1)
            lloaden_tmp = 1'b1;
        else
            lloaden_tmp = 1'b0;
    end

endmodule

