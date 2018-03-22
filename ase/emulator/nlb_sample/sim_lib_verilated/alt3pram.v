// Created by altera_lib_mf.pl from altera_mf.v

// END OF MODULE

//-----------------------------------------------------------------------------+
// Module Name      : alt3pram
//
// Description      : Triple-Port RAM megafunction. This megafunction implements
//                    RAM with 1 write port and 2 read ports.
//
// Limitation       : This megafunction is provided only for backward
//                    compatibility in Stratix designs; instead, Altera®
//                    recommends using the altsyncram megafunction.
//
//                    In MAX 3000, and MAX 7000 devices,
//                    or if the USE_EAB paramter is set to "OFF", uses one
//                    logic cell (LCs) per memory bit.
//
//
// Results expected : The alt3pram function represents asynchronous memory
//                    or memory with synchronous inputs and/or outputs.
//                    (note: ^ below indicates posedge)
//
//                    [ Synchronous Write to Memory (all inputs registered) ]
//                    inclock    inclocken    wren    Function
//                      X           L           L     No change.
//                     not ^        H           H     No change.
//                      ^           L           X     No change.
//                      ^           H           H     The memory location
//                                                    pointed to by wraddress[]
//                                                    is loaded with data[].
//
//                    [ Synchronous Read from Memory ]
//                    inclock  inclocken  rden_a/rden_b  Function
//                       X         L            L        No change.
//                     not ^       H            H        No change.
//                       ^         L            X        No change.
//                       ^         H            H        The q_a[]/q_b[]port
//                                                       outputs the contents of
//                                                       the memory location.
//
//                   [ Asynchronous Memory Operations ]
//                   wren     Function
//                    L       No change.
//                    H       The memory location pointed to by wraddress[] is
//                            loaded with data[] and controlled by wren.
//                            The output q_a[] is asynchronous and reflects
//                            the memory location pointed to by rdaddress_a[].
//
//-----------------------------------------------------------------------------+

`timescale 1 ps / 1 ps

/*verilator lint_off CASEX*/
/*verilator lint_off COMBDLY*/
/*verilator lint_off INITIALDLY*/
/*verilator lint_off LITENDIAN*/
/*verilator lint_off MULTIDRIVEN*/
/*verilator lint_off UNOPTFLAT*/
/*verilator lint_off BLKANDNBLK*/
module alt3pram (wren, data, wraddress, inclock, inclocken,
                rden_a, rden_b, rdaddress_a, rdaddress_b,
                outclock, outclocken, aclr, qa, qb);

    // ---------------------
    // PARAMETER DECLARATION
    // ---------------------

    parameter width            = 1;             // data[], qa[] and qb[]
    parameter widthad          = 1;             // rdaddress_a,rdaddress_b,wraddress
    parameter numwords         = 0;             // words stored in memory
    parameter lpm_file         = "UNUSED";      // name of hex file
    parameter lpm_hint         = "USE_EAB=ON";  // non-LPM parameters (Altera)
    parameter indata_reg       = "UNREGISTERED";// clock used by data[] port
    parameter indata_aclr      = "ON";         // aclr affects data[]?
    parameter write_reg        = "UNREGISTERED";// clock used by wraddress & wren
    parameter write_aclr       = "ON";         // aclr affects wraddress?
    parameter rdaddress_reg_a  = "UNREGISTERED";// clock used by readdress_a
    parameter rdaddress_aclr_a = "ON";         // aclr affects rdaddress_a?
    parameter rdcontrol_reg_a  = "UNREGISTERED";// clock used by rden_a
    parameter rdcontrol_aclr_a = "ON";         // aclr affects rden_a?
    parameter rdaddress_reg_b  = "UNREGISTERED";// clock used by readdress_b
    parameter rdaddress_aclr_b = "ON";         // aclr affects rdaddress_b?
    parameter rdcontrol_reg_b  = "UNREGISTERED";// clock used by rden_b
    parameter rdcontrol_aclr_b = "ON";         // aclr affects rden_b?
    parameter outdata_reg_a    = "UNREGISTERED";// clock used by qa[]
    parameter outdata_aclr_a   = "ON";         // aclr affects qa[]?
    parameter outdata_reg_b    = "UNREGISTERED";// clock used by qb[]
    parameter outdata_aclr_b   = "ON";         // aclr affects qb[]?
    parameter intended_device_family = "Stratix";
    parameter ram_block_type   = "AUTO";        // ram block type to be used
    parameter maximum_depth    = 0;             // maximum segmented value of the RAM
    parameter lpm_type               = "alt3pram";

    // -------------
    // the following behaviour come in effect when RAM is implemented in EAB/ESB

    // This is the flag to indicate if the memory is constructed using EAB/ESB:
    //     A write request requires both rising and falling edge of the clock
    //     to complete. First the data will be clocked in (registered) at the
    //     rising edge and will not be written into the ESB/EAB memory until
    //     the falling edge appears on the the write clock.
    //     No such restriction if the memory is constructed using LCs.
    reg write_at_low_clock; // initialize at initial block


    // The read ports will not hold any value (zero) if rden is low. This
    //     behavior only apply to memory constructed using EAB/ESB, but not LCs.
    reg rden_low_output_0;

    // ----------------
    // PORT DECLARATION
    // ----------------

    // data input ports
    input [width-1:0]      data;

    // control signals
    input [widthad-1:0]    wraddress;
    input [widthad-1:0]    rdaddress_a;
    input [widthad-1:0]    rdaddress_b;

    input                  wren;
    input                  rden_a;
    input                  rden_b;

    // clock ports
    input                  inclock;
    input                  outclock;

    // clock enable ports
    input                  inclocken;
    input                  outclocken;

    // clear ports
    input                  aclr;

    // OUTPUT PORTS
    output [width-1:0]     qa;
    output [width-1:0]     qb;

    // ---------------
    // REG DECLARATION
    // ---------------
    reg  [width-1:0]       mem_data [(1<<widthad)-1:0];
    wire [width-1:0]       i_data_reg;
    wire [width-1:0]       i_data_tmp;
    reg  [width-1:0]       i_qa_reg;
    reg  [width-1:0]       i_qa_tmp;
    reg  [width-1:0]       i_qb_reg;
    reg  [width-1:0]       i_qb_tmp;

    wire [width-1:0]       i_qa_stratix;  // qa signal for Stratix families
    wire [width-1:0]       i_qb_stratix;  // qa signal for Stratix families

    reg  [width-1:0]       i_data_hi;
    reg  [width-1:0]       i_data_lo;

    wire [widthad-1:0]     i_wraddress_reg;
    wire [widthad-1:0]     i_wraddress_tmp;

    reg  [widthad-1:0]     i_wraddress_hi;
    reg  [widthad-1:0]     i_wraddress_lo;

    reg  [widthad-1:0]     i_rdaddress_reg_a;
    reg  [widthad-1:0]     i_rdaddress_reg_a_dly;
    wire [widthad-1:0]     i_rdaddress_tmp_a;

    reg  [widthad-1:0]     i_rdaddress_reg_b;
    reg  [widthad-1:0]     i_rdaddress_reg_b_dly;
    wire [widthad-1:0]     i_rdaddress_tmp_b;

    wire                   i_wren_reg;
    wire                   i_wren_tmp;
    reg                    i_rden_reg_a;
    wire                   i_rden_tmp_a;
    reg                    i_rden_reg_b;
    wire                   i_rden_tmp_b;

    reg                    i_wren_hi;
    reg                    i_wren_lo;

    reg [8*256:1]          ram_initf;       // max RAM size 8*256=2048

    wire                   i_stratix_inclock;  // inclock signal for Stratix families
    wire                   i_stratix_outclock; // inclock signal for Stratix families

    wire                   i_non_stratix_inclock;  // inclock signal for non-Stratix families
    wire                   i_non_stratix_outclock; // inclock signal for non-Stratix families

    reg                    feature_family_stratix;

    // -------------------
    // INTEGER DECLARATION
    // -------------------
    integer                i;
    integer                i_numwords;
    integer                new_data;
    integer                tmp_new_data;


    // --------------------------------
    // Tri-State and Buffer DECLARATION
    // --------------------------------
    logic                   inclock; // -- converted tristate to logic
    logic                   inclocken; // -- converted tristate to logic
    logic                   outclock; // -- converted tristate to logic
    logic                   outclocken; // -- converted tristate to logic
    logic                   wren; // -- converted tristate to logic
    logic                   rden_a; // -- converted tristate to logic
    logic                   rden_b; // -- converted tristate to logic
    logic                   aclr; // -- converted tristate to logic

    // ------------------------
    // COMPONENT INSTANTIATIONS
    // ------------------------
    ALTERA_DEVICE_FAMILIES dev ();
    ALTERA_MF_MEMORY_INITIALIZATION mem ();
    ALTERA_MF_HINT_EVALUATION eva();

    // The alt3pram for Stratix/Stratix II/ Stratix GX and Cyclone device families
    // are basically consists of 2 instances of altsyncram with write port of each
    // instance been tied together.

    altsyncram u0 (
                    .wren_a(wren),
                    .wren_b(),
                    .rden_a(),
                    .rden_b(rden_a),
                    .data_a(data),
                    .data_b(),
                    .address_a(wraddress),
                    .address_b(rdaddress_a),
                    .clock0(i_stratix_inclock),
                    .clock1(i_stratix_outclock),
                    .clocken0(inclocken),
                    .clocken1(outclocken),
                    .clocken2(),
                    .clocken3(),
                    .aclr0(aclr),
                    .aclr1(),
                    .byteena_a(),
                    .byteena_b(),
                    .addressstall_a(),
                    .addressstall_b(),
                    .q_a(),
                    .q_b(i_qa_stratix),
                    .eccstatus());

    defparam
        u0.width_a          = width,
        u0.widthad_a        = widthad,
        u0.numwords_a       = (numwords == 0) ? (1<<widthad) : numwords,
        u0.address_aclr_a   = (write_aclr == "ON") ? "CLEAR0" : "NONE",
        u0.indata_aclr_a    = (indata_aclr == "ON") ? "CLEAR0" : "NONE",
        u0.wrcontrol_aclr_a   = (write_aclr == "ON") ? "CLEAR0" : "NONE",

        u0.width_b                   = width,
        u0.widthad_b                 = widthad,
        u0.numwords_b                =  (numwords == 0) ? (1<<widthad) : numwords,
        u0.rdcontrol_reg_b           =  (rdcontrol_reg_a == "INCLOCK")  ? "CLOCK0" :
                                        (rdcontrol_reg_a == "OUTCLOCK") ? "CLOCK1" :
                                        "UNUSED",
        u0.address_reg_b             =  (rdaddress_reg_a == "INCLOCK")  ? "CLOCK0" :
                                        (rdaddress_reg_a == "OUTCLOCK") ? "CLOCK1" :
                                        "UNUSED",
        u0.outdata_reg_b             =  (outdata_reg_a == "INCLOCK")  ? "CLOCK0" :
                                        (outdata_reg_a == "OUTCLOCK") ? "CLOCK1" :
                                        "UNREGISTERED",
        u0.outdata_aclr_b            =  (outdata_aclr_a == "ON") ? "CLEAR0" : "NONE",
        u0.rdcontrol_aclr_b          =  (rdcontrol_aclr_a == "ON") ? "CLEAR0" : "NONE",
        u0.address_aclr_b            =  (rdaddress_aclr_a == "ON") ? "CLEAR0" : "NONE",
        u0.operation_mode                     = "DUAL_PORT",
        u0.read_during_write_mode_mixed_ports = (ram_block_type == "AUTO") ?    "OLD_DATA" :
                                                                                "DONT_CARE",
        u0.ram_block_type                     = ram_block_type,
        u0.init_file                          = lpm_file,
        u0.init_file_layout                   = "PORT_B",
        u0.maximum_depth                      = maximum_depth,
        u0.intended_device_family             = intended_device_family;

    altsyncram u1 (
                    .wren_a(wren),
                    .wren_b(),
                    .rden_a(),
                    .rden_b(rden_b),
                    .data_a(data),
                    .data_b(),
                    .address_a(wraddress),
                    .address_b(rdaddress_b),
                    .clock0(i_stratix_inclock),
                    .clock1(i_stratix_outclock),
                    .clocken0(inclocken),
                    .clocken1(outclocken),
                    .clocken2(),
                    .clocken3(),
                    .aclr0(aclr),
                    .aclr1(),
                    .byteena_a(),
                    .byteena_b(),
                    .addressstall_a(),
                    .addressstall_b(),
                    .q_a(),
                    .q_b(i_qb_stratix),
                    .eccstatus());

    defparam
        u1.width_a          = width,
        u1.widthad_a        = widthad,
        u1.numwords_a       = (numwords == 0) ? (1<<widthad) : numwords,
        u1.address_aclr_a   = (write_aclr == "ON") ? "CLEAR0" : "NONE",
        u1.indata_aclr_a    = (indata_aclr == "ON") ? "CLEAR0" : "NONE",
        u1.wrcontrol_aclr_a   = (write_aclr == "ON") ? "CLEAR0" : "NONE",

        u1.width_b                   = width,
        u1.widthad_b                 = widthad,
        u1.numwords_b                =  (numwords == 0) ? (1<<widthad) : numwords,
        u1.rdcontrol_reg_b           = (rdcontrol_reg_b == "INCLOCK")  ? "CLOCK0" :
                                        (rdcontrol_reg_b == "OUTCLOCK") ? "CLOCK1" :
                                        "UNUSED",
        u1.address_reg_b             = (rdaddress_reg_b == "INCLOCK")  ? "CLOCK0" :
                                        (rdaddress_reg_b == "OUTCLOCK") ? "CLOCK1" :
                                        "UNUSED",
        u1.outdata_reg_b             = (outdata_reg_b == "INCLOCK")  ? "CLOCK0" :
                                        (outdata_reg_b == "OUTCLOCK") ? "CLOCK1" :
                                        "UNREGISTERED",
        u1.outdata_aclr_b            = (outdata_aclr_b == "ON") ? "CLEAR0" : "NONE",
        u1.rdcontrol_aclr_b          = (rdcontrol_aclr_b == "ON") ? "CLEAR0" : "NONE",
        u1.address_aclr_b            = (rdaddress_aclr_b == "ON") ? "CLEAR0" : "NONE",

        u1.operation_mode                     = "DUAL_PORT",
        u1.read_during_write_mode_mixed_ports = (ram_block_type == "AUTO") ? "OLD_DATA" :
                                                                            "DONT_CARE",
        u1.ram_block_type                     = ram_block_type,
        u1.init_file                          = lpm_file,
        u1.init_file_layout                   = "PORT_B",
        u1.maximum_depth                      = maximum_depth,
        u1.intended_device_family             = intended_device_family;

    // -----------------------------------------------------------
    // Initialization block for all internal signals and registers
    // -----------------------------------------------------------
    initial
    begin
        feature_family_stratix = dev.FEATURE_FAMILY_STRATIX(intended_device_family);

        // Check for invalid parameters

        write_at_low_clock = ((write_reg == "INCLOCK") &&
                                    (eva.GET_PARAMETER_VALUE(lpm_hint, "USE_EAB") == "ON")) ? 1 : 0;

        if (width <= 0)
        begin
            $display("Error: width parameter must be greater than 0.");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        if (widthad <= 0)
        begin
            $display("Error: widthad parameter must be greater than 0.");
            $display("Time: %0t  Instance: %m", $time);
            $stop;
        end

        // Initialize mem_data to '0' if no RAM init file is specified
        i_numwords = (numwords) ? numwords : 1<<widthad;
        if (lpm_file == "UNUSED")
            if (write_reg == "UNREGISTERED")
                for (i=0; i<i_numwords; i=i+1)
                    mem_data[i] = {width{1'b0 /* converted x or z to 1'b0 */}};
            else
                for (i=0; i<i_numwords; i=i+1)
                    mem_data[i] = 0;
        else
        begin

	mem.convert_to_ver_file(lpm_file, width, ram_initf);
        $readmemh(ram_initf, mem_data);

        end

        // Initialize registers
        i_data_hi          = 0;
        i_data_lo          = 0;
        i_rdaddress_reg_a  = 0;
        i_rdaddress_reg_b  = 0;
        i_rdaddress_reg_a_dly = 0;
        i_rdaddress_reg_b_dly = 0;
        i_qa_reg           = 0;
        i_qb_reg           = 0;

        // Initialize integer
        new_data = 0;
        tmp_new_data = 0;

        rden_low_output_0 = 0;

    end

    // ------------------------
    // ALWAYS CONSTRUCT BLOCK
    // ------------------------

    // The following always blocks are used to implement the alt3pram behavior for
    // device families other than Stratix/Stratix II/Stratix GX and Cyclone.

    //=========
    // Clocks
    //=========

    // At posedge of the write clock:
    // All input ports values (data, address and control) are
    // clocked in from physical ports to internal variables
    //     Write Cycle: i_*_hi
    //     Read  Cycle: i_*_reg
    always @(posedge i_non_stratix_inclock)
    begin
        if (indata_reg == "INCLOCK")
        begin
            if ((aclr == 1) && (indata_aclr == "ON"))
                i_data_hi <= 0;
            else if (inclocken == 1)
                i_data_hi <= data;
        end

        if (write_reg == "INCLOCK")
        begin
            if ((aclr == 1) && (write_aclr == "ON"))
            begin
                i_wraddress_hi <= 0;
                i_wren_hi <= 0;
            end
            else if (inclocken == 1)
            begin
                i_wraddress_hi <= wraddress;
                i_wren_hi <= wren;
            end
        end

        if (rdaddress_reg_a == "INCLOCK")
        begin
            if ((aclr == 1) && (rdaddress_aclr_a == "ON"))
                i_rdaddress_reg_a <= 0;
            else if (inclocken == 1)
                i_rdaddress_reg_a <= rdaddress_a;
        end

        if (rdcontrol_reg_a == "INCLOCK")
        begin
            if ((aclr == 1) && (rdcontrol_aclr_a == "ON"))
                i_rden_reg_a <= 0;
            else if (inclocken == 1)
                i_rden_reg_a <= rden_a;
        end

        if (rdaddress_reg_b == "INCLOCK")
        begin
            if ((aclr == 1) && (rdaddress_aclr_b == "ON"))
                i_rdaddress_reg_b <= 0;
            else if (inclocken == 1)
                i_rdaddress_reg_b <= rdaddress_b;
        end

        if (rdcontrol_reg_b == "INCLOCK")
        begin
            if ((aclr == 1) && (rdcontrol_aclr_b == "ON"))
                i_rden_reg_b <= 0;
            else if (inclocken == 1)
                i_rden_reg_b <= rden_b;
        end
    end  // End of always block: @(posedge inclock)


    // At negedge of the write clock:
    // Write Cycle: since internally data only completed written on memory
    //              at the falling edge of write clock, the "write" related
    //              data, address and controls need to be shift to another
    //              varibles (i_*_hi -> i_*_lo) during falling edge.
    always @(negedge i_non_stratix_inclock)
    begin
        if (indata_reg == "INCLOCK")
        begin
            if ((aclr == 1) && (indata_aclr == "ON"))
                i_data_lo <= 0;
            else
                i_data_lo <= i_data_hi;
        end

        if (write_reg == "INCLOCK")
        begin
            if ((aclr == 1) && (write_aclr == "ON"))
            begin
                i_wraddress_lo <= 0;
                i_wren_lo <= 0;
            end
            else
            begin
                i_wraddress_lo <= i_wraddress_hi;
                i_wren_lo <= i_wren_hi;
            end
        end
    end  // End of always block: @(negedge inclock)


    // At posedge of read clock:
    // Read Cycle: This block is valid only if the operating mode is
    //             in "Seperate Clock Mode". All read data, address
    //             and control are clocked out from internal vars
    //             (i_*_reg) to output port.
    always @(posedge i_non_stratix_outclock)
    begin
        if (outdata_reg_a == "OUTCLOCK")
        begin
            if ((aclr == 1) && (outdata_aclr_a == "ON"))
                i_qa_reg <= 0;
            else if (outclocken == 1)
                i_qa_reg <= i_qa_tmp;
        end

        if (outdata_reg_b == "OUTCLOCK")
        begin
            if ((aclr == 1) && (outdata_aclr_b == "ON"))
                i_qb_reg <= 0;
            else if (outclocken == 1)
                i_qb_reg <= i_qb_tmp;
        end

        if (rdaddress_reg_a == "OUTCLOCK")
        begin
            if ((aclr == 1) && (rdaddress_aclr_a == "ON"))
                i_rdaddress_reg_a <= 0;
            else if (outclocken == 1)
                i_rdaddress_reg_a <= rdaddress_a;
        end

        if (rdcontrol_reg_a == "OUTCLOCK")
        begin
            if ((aclr == 1) && (rdcontrol_aclr_a == "ON"))
                i_rden_reg_a <= 0;
            else if (outclocken == 1)
                i_rden_reg_a <= rden_a;
        end

        if (rdaddress_reg_b == "OUTCLOCK")
        begin
            if ((aclr == 1) && (rdaddress_aclr_b == "ON"))
                i_rdaddress_reg_b <= 0;
            else if (outclocken == 1)
                i_rdaddress_reg_b <= rdaddress_b;
        end

        if (rdcontrol_reg_b == "OUTCLOCK")
        begin
            if ((aclr == 1) && (rdcontrol_aclr_b == "ON"))
                i_rden_reg_b <= 0;
            else if (outclocken == 1)
                i_rden_reg_b <= rden_b;
        end
    end  // End of always block: @(posedge outclock)

    always @(i_rdaddress_reg_a)
    begin
        i_rdaddress_reg_a_dly <= i_rdaddress_reg_a;
    end

    always @(i_rdaddress_reg_b)
    begin
        i_rdaddress_reg_b_dly <= i_rdaddress_reg_b;
    end

    //=========
    // Memory
    //=========

    always @(i_data_tmp or i_wren_tmp or i_wraddress_tmp)
    begin
        new_data <= 1;
    end

    always @(posedge new_data or negedge new_data)
    begin
        if (new_data == 1)
    begin
        //
        // This is where data is being write to the internal memory: mem_data[]
        //
            if (i_wren_tmp == 1)
            begin
                mem_data[i_wraddress_tmp] <= i_data_tmp;
            end

        tmp_new_data <= ~tmp_new_data;

        end
    end

    always @(tmp_new_data)
    begin

        new_data <= 0;
    end

        // Triple-Port Ram (alt3pram) has one write port and two read ports (a and b)
        // Below is the operation to read data from internal memory (mem_data[])
        // to the output port (i_qa_tmp or i_qb_tmp)
        // Note: i_q*_tmp will serve as the var directly link to the physical
        //       output port q* if alt3pram is operate in "Shared Clock Mode",
        //       else data read from i_q*_tmp will need to be latched to i_q*_reg
        //       through outclock before it is fed to the output port q* (qa or qb).

    always @(posedge new_data or negedge new_data or
            posedge i_rden_tmp_a or negedge i_rden_tmp_a or
            i_rdaddress_tmp_a)
    begin

        if (i_rden_tmp_a == 1)
            i_qa_tmp <= mem_data[i_rdaddress_tmp_a];
        else if (rden_low_output_0 == 1)
            i_qa_tmp <= 0;

    end

    always @(posedge new_data or negedge new_data or
            posedge i_rden_tmp_b or negedge i_rden_tmp_b or
            i_rdaddress_tmp_b)
    begin

        if (i_rden_tmp_b == 1)
            i_qb_tmp <= mem_data[i_rdaddress_tmp_b];
        else if (rden_low_output_0 == 1)
            i_qb_tmp <= 0;

    end


    //=======
    // Sync
    //=======

    assign  i_wraddress_reg   = ((aclr == 1) && (write_aclr == "ON")) ?
                                    {widthad{1'b0}} : (write_at_low_clock ?
                                        i_wraddress_lo : i_wraddress_hi);

    assign  i_wren_reg        = ((aclr == 1) && (write_aclr == "ON")) ?
                                    1'b0 : ((write_at_low_clock) ?
                                        i_wren_lo : i_wren_hi);

    assign  i_data_reg        = ((aclr == 1) && (indata_aclr == "ON")) ?
                                    {width{1'b0}} : ((write_at_low_clock) ?
                                        i_data_lo : i_data_hi);

    assign  i_wraddress_tmp   = ((aclr == 1) && (write_aclr == "ON")) ?
                                    {widthad{1'b0}} : ((write_reg == "INCLOCK") ?
                                        i_wraddress_reg : wraddress);

    assign  i_rdaddress_tmp_a = ((aclr == 1) && (rdaddress_aclr_a == "ON")) ?
                                    {widthad{1'b0}} : (((rdaddress_reg_a == "INCLOCK") ||
                                        (rdaddress_reg_a == "OUTCLOCK")) ?
                                        i_rdaddress_reg_a_dly : rdaddress_a);

    assign  i_rdaddress_tmp_b = ((aclr == 1) && (rdaddress_aclr_b == "ON")) ?
                                    {widthad{1'b0}} : (((rdaddress_reg_b == "INCLOCK") ||
                                        (rdaddress_reg_b == "OUTCLOCK")) ?
                                        i_rdaddress_reg_b_dly : rdaddress_b);

    assign  i_wren_tmp        = ((aclr == 1) && (write_aclr == "ON")) ?
                                    1'b0 : ((write_reg == "INCLOCK") ?
                                        i_wren_reg : wren);

    assign  i_rden_tmp_a      = ((aclr == 1) && (rdcontrol_aclr_a == "ON")) ?
                                    1'b0 : (((rdcontrol_reg_a == "INCLOCK") ||
                                        (rdcontrol_reg_a == "OUTCLOCK")) ?
                                        i_rden_reg_a : rden_a);

    assign  i_rden_tmp_b      = ((aclr == 1) && (rdcontrol_aclr_b == "ON")) ?
                                    1'b0 : (((rdcontrol_reg_b == "INCLOCK") ||
                                        (rdcontrol_reg_b == "OUTCLOCK")) ?
                                        i_rden_reg_b : rden_b);

    assign  i_data_tmp        = ((aclr == 1) && (indata_aclr == "ON")) ?
                                    {width{1'b0}} : ((indata_reg == "INCLOCK") ?
                                        i_data_reg : data);

    assign  qa                = (feature_family_stratix == 1) ?
                                i_qa_stratix :
                                (((aclr == 1) && (outdata_aclr_a == "ON")) ?
                                    {widthad{1'b0}} : ((outdata_reg_a == "OUTCLOCK") ?
                                        i_qa_reg : i_qa_tmp));

    assign  qb                = (feature_family_stratix == 1) ?
                                i_qb_stratix :
                                (((aclr == 1) && (outdata_aclr_b == "ON")) ?
                                    {widthad{1'b0}} : ((outdata_reg_b == "OUTCLOCK") ?
                                        i_qb_reg : i_qb_tmp));

    assign   i_non_stratix_inclock    = (feature_family_stratix == 0) ?
                                inclock : 1'b0;

    assign   i_non_stratix_outclock   = (feature_family_stratix == 0) ?
                                outclock : 1'b0;

    assign   i_stratix_inclock = (feature_family_stratix == 1) ?
                                inclock : 1'b0;

    assign   i_stratix_outclock = (feature_family_stratix == 1) ?
                                outclock : 1'b0;


endmodule // end of ALT3PRAM

