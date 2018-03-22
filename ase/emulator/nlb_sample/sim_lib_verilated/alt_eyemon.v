// Created by altera_lib_mf.pl from altera_mf.v



//-------------------------------------------------------------------
// Filename    : alt_eyemon.v
//
// Description : Simulation model for Stratix IV Eye Monitor (EyeQ)
//
// Limitation  : Currently, only apllies for Stratix IV
//
// Copyright (c) Altera Corporation 1997-2009
// All rights reserved
//
//-------------------------------------------------------------------
/*verilator lint_off CASEX*/
/*verilator lint_off COMBDLY*/
/*verilator lint_off INITIALDLY*/
/*verilator lint_off LITENDIAN*/
/*verilator lint_off MULTIDRIVEN*/
/*verilator lint_off UNOPTFLAT*/
/*verilator lint_off BLKANDNBLK*/
module alt_eyemon
#(
  parameter channel_address_width = 3,
  parameter lpm_type = "alt_eyemon",
  parameter lpm_hint = "UNUSED",

  parameter avmm_slave_addr_width = 16, // tbd
  parameter avmm_slave_rdata_width = 16,
  parameter avmm_slave_wdata_width = 16,

  parameter avmm_master_addr_width = 16,
  parameter avmm_master_rdata_width = 16,
  parameter avmm_master_wdata_width = 16,

  parameter dprio_addr_width = 16,
  parameter dprio_data_width = 16,
  parameter ireg_chaddr_width = channel_address_width,
  parameter ireg_wdaddr_width = 2, // width of 2 - only need to address 4 registers
  parameter ireg_data_width   = 16,

  parameter ST_IDLE  = 2'd0,
  parameter ST_WRITE = 2'd1,
  parameter ST_READ  = 2'd2
)
(
  input                               i_resetn,
  input                               i_avmm_clk,

  // avalon slave ports
  input  [avmm_slave_addr_width-1:0]  i_avmm_saddress,
  input                               i_avmm_sread,
  input                               i_avmm_swrite,
  input  [avmm_slave_wdata_width-1:0] i_avmm_swritedata,
  output [avmm_slave_rdata_width-1:0] o_avmm_sreaddata,
  output reg                              o_avmm_swaitrequest,

  input        i_remap_phase,
  input [11:0] i_remap_address, // from address_pres_reg
  output [8:0] o_quad_address, // output to altgx_reconfig
  output       o_reconfig_busy,

  // alt_dprio interface
  input                         i_dprio_busy,
  input  [dprio_data_width-1:0] i_dprio_in,
  output                        o_dprio_wren,
  output                        o_dprio_rden,
  output [dprio_addr_width-1:0] o_dprio_addr,
  output [dprio_data_width-1:0] o_dprio_data
);

//********************************************************************************
// DECLARATIONS
//********************************************************************************
  reg [1:0]  state, state0q;
  reg        reg_read, reg_write;
  reg [5:0] busy_counter;

// register file regs
  reg [ireg_chaddr_width-1:0] reg_chaddress, reg_chaddress0q;
  reg [ireg_data_width-1:0] reg_data, reg_data0q;
  reg [ireg_data_width-1:0] reg_ctrlstatus, reg_ctrlstatus0q;
  reg [ireg_wdaddr_width-1:0] reg_wdaddress, reg_wdaddress0q;

  reg [6:0] dprio_reg [(1 << channel_address_width)-1:0];
  reg [6:0] dprio_reg0q [(1 << channel_address_width)-1:0]; // make this scale with the channel width - 6 bits for phase step, one for enable

  wire invalid_channel_address, invalid_word_address;
  integer i;

// synopsys translate_off
initial begin
  state            = 'b0;
  state0q          = 'b0;
  busy_counter     = 'b0;
  reg_chaddress0q  = 'b0;
  reg_data0q       = 'b0;
  reg_ctrlstatus0q = 'b0;
  reg_wdaddress0q  = 'b0;
  reg_chaddress    = 'b0;
  reg_data         = 'b0;
  reg_ctrlstatus   = 'b0;
  reg_wdaddress    = 'b0;
end
// synopsys translate_on

  assign
    o_dprio_wren = 1'b0,
    o_dprio_rden = 1'b0,
    o_dprio_addr = {dprio_addr_width{1'b0}},
    o_dprio_data = {dprio_data_width{1'b0}},
    o_quad_address = 9'b0,
    o_reconfig_busy = reg_ctrlstatus0q[15];



//********************************************************************************
// Sequential Logic - Avalon Slave
//********************************************************************************
  // state flops
  always @ (posedge i_avmm_clk) begin
    if (~i_resetn) begin
      state0q <= ST_IDLE;
    end else begin
      state0q <= state;
    end
  end


  always @ (posedge i_avmm_clk) begin
    if (~i_resetn) begin
      busy_counter <= 6'h0;
    end else if ((reg_ctrlstatus[0] && ~reg_ctrlstatus0q[0]) && ~reg_ctrlstatus[1]) begin // write op (takes longer to simulate read-modify-write)
      busy_counter <= 6'h3f;
    end else if ((reg_ctrlstatus[0] && ~reg_ctrlstatus0q[0]) && reg_ctrlstatus[1]) begin // read op
      busy_counter <= 6'h1f;
    end else if (|busy_counter) begin // if not 0, keep decrementing
      busy_counter <= busy_counter - 1'b1;
    end
  end

//********************************************************************************
// Combinational Logic - Avalon Slave
//********************************************************************************

  always @ (*) begin
    // avoid latches
    o_avmm_swaitrequest = 1'b0;
    reg_write = 1'b0;
    reg_read = 1'b0;

    case (state0q)
      ST_WRITE: begin
        // check busy and discard the write data if we are busy
        o_avmm_swaitrequest = 1'b0;
//        if (reg_ctrlstatus0q[15]) begin // don't commit the write if we are busy
        state = ST_IDLE; // single cycle write - always return to idle
      end
      ST_READ: begin
        o_avmm_swaitrequest = 1'b0;
        reg_read = 1'b1;
        state = ST_IDLE; // single cycle read - always return to idle
      end
      default: begin //ST_IDLE: begin
        // effectively priority encoded - if read and write both asserted (error condition), reads will take precedence
        // this ensures non-destructive behaviour
        if (i_avmm_sread) begin
          o_avmm_swaitrequest = 1'b1;
          reg_read = 1'b1;
          state = ST_READ;
        end else if (i_avmm_swrite) begin
          o_avmm_swaitrequest = 1'b1;
          if (reg_ctrlstatus0q[15]) begin // don't commit the write if we are busy
            reg_write = 1'b0;
          end else begin
            reg_write = 1'b1;
          end
          state = ST_WRITE;
        end else begin
          o_avmm_swaitrequest = 1'b0;
          state = ST_IDLE;
        end
      end
    endcase
  end



//********************************************************************************
// Sequential Logic - Register File
//********************************************************************************
  // register file
  always @ (posedge i_avmm_clk) begin
    if (~i_resetn) begin
      reg_chaddress0q  <= 'b0;
      reg_data0q       <= 'b0;
      reg_ctrlstatus0q <= 'b0;
      reg_wdaddress0q  <= 'b0;
      for (i = 0; i < (1 << channel_address_width); i = i + 1) begin
        dprio_reg0q[i] <= 7'b0;
      end
    end else begin
      reg_chaddress0q  <= reg_chaddress;
      reg_data0q       <= reg_data;
      reg_ctrlstatus0q <= reg_ctrlstatus;
      reg_wdaddress0q  <= reg_wdaddress;
      for (i = 0; i < (1 << channel_address_width); i = i + 1) begin
        dprio_reg0q[i] <= dprio_reg[i];
      end
    end
  end

//********************************************************************************
// Combinational Logic - Register File
//********************************************************************************
  // read mux
  assign o_avmm_sreaddata = reg_read ? (({ireg_data_width{(i_avmm_saddress == 'h0)}} & reg_ctrlstatus0q) |
                                        ({ireg_data_width{(i_avmm_saddress == 'h1)}} & reg_chaddress0q)  |
                                        ({ireg_data_width{(i_avmm_saddress == 'h2)}} & reg_wdaddress0q)  |
                                        ({ireg_data_width{(i_avmm_saddress == 'h3)}} & reg_data0q)) : {ireg_data_width{1'b0}};

  assign invalid_channel_address = (i_remap_address == 12'hfff);
  assign invalid_word_address    = (reg_wdaddress0q > 'h1);

  always @ (*) begin
    reg_chaddress    = reg_chaddress0q;
    reg_data         = reg_data0q;
    reg_ctrlstatus   = reg_ctrlstatus0q;
    reg_wdaddress    = reg_wdaddress0q;
    for (i = 0; i < (1 << channel_address_width); i = i + 1) begin
      dprio_reg0q[i] <= dprio_reg[i];
    end


  // handle busy condition - if mdone is raised, we clear reg_busy bit
    if (busy_counter == 'b1) begin // counter is 1 - simulate the 1 cycle done pulse
      reg_ctrlstatus[15] = 1'b0; // set busy to 0
      reg_ctrlstatus[0]  = 1'b0; // clear the 'start' bit as well
      if (reg_ctrlstatus0q[1]) begin// read operation
        if (reg_wdaddress0q == 'b0) begin
          reg_data[0] = dprio_reg0q[reg_chaddress0q][0];
          reg_data[15:1] = 15'b0;
        end else if (reg_wdaddress0q == 'b1) begin
          reg_data[5:0] = dprio_reg0q[reg_chaddress0q][6:1];
          reg_data[15:6] = 10'b0;
        end
      end
    end

  // write select for register file
    if (reg_write) begin
      if (i_avmm_saddress == 'h0) begin
        reg_ctrlstatus[1] = i_avmm_swritedata[1];
        if (i_avmm_swritedata[0]) begin // writing to the start command bit
          if (invalid_channel_address || invalid_word_address) begin // invalid channel address
            reg_ctrlstatus[15] = 1'b0; // not busy - don't start the operation due to invalid address
            reg_ctrlstatus[14] = invalid_word_address;
            reg_ctrlstatus[13] = invalid_channel_address;
          end else begin // no error condition, start the operation, auto-clear any existing errors
            if (~i_avmm_swritedata[1]) begin // write operation
              if (reg_wdaddress0q == 'd0) begin
                dprio_reg[reg_chaddress0q][0] = reg_data0q[0];
              end else if (reg_wdaddress0q == 'd1) begin
                dprio_reg[reg_chaddress0q][6:1] = reg_data0q[5:0];
              end
            end
            reg_ctrlstatus[0]  = 1'b1; // start bit asserted
            reg_ctrlstatus[15] = 1'b1; // assert busy
            reg_ctrlstatus[14] = 1'b0; // clear errors
            reg_ctrlstatus[13] = 1'b0; // clear errors
          end
        end else begin
          reg_ctrlstatus[15] = 1'b0; // do not assert busy
          reg_ctrlstatus[14] = i_avmm_swritedata[14] ? 1'b0 : reg_ctrlstatus0q[14]; // clear error
          reg_ctrlstatus[13] = i_avmm_swritedata[13] ? 1'b0 : reg_ctrlstatus0q[13]; // clear error
        end
      end else if (i_avmm_saddress == 'h1) begin
        reg_chaddress = i_avmm_swritedata;
      end else if (i_avmm_saddress == 'h2) begin
        reg_wdaddress = i_avmm_swritedata[ireg_wdaddr_width-1:0];
      end else if (i_avmm_saddress == 'h3) begin
        reg_data = i_avmm_swritedata[ireg_data_width-1:0];
      end

      // do nothing if not a valid address
    end
  end

endmodule

