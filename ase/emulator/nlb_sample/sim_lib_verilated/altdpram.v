// Created by altera_lib_mf.pl from altera_mf.v
// END MODULE ALTDDIO_BIDIR

//--------------------------------------------------------------------------
// Module Name      : altdpram
//
// Description      : Parameterized Dual Port RAM megafunction
//
// Limitation       : This megafunction is provided only for backward
//                    compatibility in Cyclone, Stratix, and Stratix GX
//                    designs.
//
// Results expected : RAM having dual ports (separate Read and Write)
//                    behaviour
//
//--------------------------------------------------------------------------
`timescale 1 ps / 1 ps

// MODULE DECLARATION
/*verilator lint_off CASEX*/
/*verilator lint_off COMBDLY*/
/*verilator lint_off INITIALDLY*/
/*verilator lint_off LITENDIAN*/
/*verilator lint_off MULTIDRIVEN*/
/*verilator lint_off UNOPTFLAT*/
/*verilator lint_off BLKANDNBLK*/
module altdpram (wren, data, wraddress, inclock, inclocken, rden, rdaddress,
                wraddressstall, rdaddressstall, byteena,
                outclock, outclocken, aclr, sclr, q);

// PARAMETER DECLARATION
    parameter width = 1;
    parameter widthad = 1;
    parameter numwords = 0;
    parameter lpm_file = "UNUSED";
    parameter lpm_hint = "USE_EAB=ON";
    parameter use_eab = "ON";
    parameter lpm_type = "altdpram";
    parameter indata_reg = "INCLOCK";
    parameter indata_aclr = "ON";
    parameter wraddress_reg = "INCLOCK";
    parameter wraddress_aclr = "ON";
    parameter wrcontrol_reg = "INCLOCK";
    parameter wrcontrol_aclr = "ON";
    parameter rdaddress_reg = "OUTCLOCK";
    parameter rdaddress_aclr = "ON";
    parameter rdcontrol_reg = "OUTCLOCK";
    parameter rdcontrol_aclr = "ON";
    parameter outdata_reg = "UNREGISTERED";
    parameter outdata_aclr = "ON";
    parameter outdata_sclr = "ON";
    parameter maximum_depth = 2048;
    parameter intended_device_family = "Stratix";
    parameter ram_block_type = "AUTO";
    parameter width_byteena = 1;
    parameter byte_size = 0;
    parameter read_during_write_mode_mixed_ports = "DONT_CARE";

// LOCAL_PARAMETERS_BEGIN

    parameter i_byte_size = ((byte_size == 0) && (width_byteena != 0)) ?
                            ((((width / width_byteena) == 5) || (width / width_byteena == 10) || (width / width_byteena == 8) || (width / width_byteena == 9)) ? width / width_byteena : 5 )
                            : byte_size;
    parameter is_lutram = ((ram_block_type == "LUTRAM") || (ram_block_type == "MLAB"))? 1 : 0;
    parameter i_width_byteena = ((width_byteena == 0) && (i_byte_size != 0)) ? width / byte_size : width_byteena;
    parameter i_read_during_write = ((rdaddress_reg == "INCLOCK") && (wrcontrol_reg == "INCLOCK") && (outdata_reg == "INCLOCK")) ?
                                    read_during_write_mode_mixed_ports : "NEW_DATA";

// LOCAL_PARAMETERS_END

// INPUT PORT DECLARATION
    input  wren;                 // Write enable input
    input  [width-1:0] data;     // Data input to the memory
    input  [widthad-1:0] wraddress; // Write address input to the memory
    input  inclock;              // Input or write clock
    input  inclocken;            // Clock enable for inclock
    input  rden;                 // Read enable input. Disable reading when low
    input  [widthad-1:0] rdaddress; // Write address input to the memory
    input  outclock;             // Output or read clock
    input  outclocken;           // Clock enable for outclock
    input  aclr;                 // Asynchronous clear input
    input  sclr;                 // Synchronous clear input
    input  wraddressstall;              // Address stall input for write port
    input  rdaddressstall;              // Address stall input for read port
    input  [i_width_byteena-1:0] byteena; // Byteena mask input

// OUTPUT PORT DECLARATION
    output [width-1:0] q;        // Data output from the memory

// INTERNAL SIGNAL/REGISTER DECLARATION
    reg [width-1:0] mem_data [0:(1<<widthad)-1];
    reg [8*256:1] ram_initf;
    reg [width-1:0] data_write_at_high;
    reg [width-1:0] data_write_at_low;
    reg [widthad-1:0] wraddress_at_high;
    reg [widthad-1:0] wraddress_at_low;
    reg [width-1:0] mem_output;
    reg [width-1:0] mem_output_at_outclock;
    reg [width-1:0] mem_output_at_inclock;
    reg [widthad-1:0] rdaddress_at_inclock;
    reg [widthad-1:0] rdaddress_at_inclock_low;
    reg [widthad-1:0] rdaddress_at_outclock;
    reg wren_at_high;
    reg wren_at_low;
    reg rden_at_inclock;
    reg rden_at_outclock;
    reg [width-1:0] i_byteena_mask;
    reg [width-1:0] i_byteena_mask_at_low;
    reg [width-1:0] i_byteena_mask_out;
    reg [width-1:0] i_byteena_mask_x;
    reg [width-1:0] i_lutram_output_reg_inclk;
    reg [width-1:0] i_lutram_output_reg_outclk;
    reg [width-1:0] i_old_data;
    reg rden_low_output_0;
    reg first_clk_rising_edge;
    reg is_stxiii_style_ram;
    reg is_stxv_style_ram;
    reg is_rising_edge_write_ena;
    reg is_write_at_low_clock;

// INTERNAL WIRE DECLARATION
    wire aclr_on_wraddress;
    wire aclr_on_wrcontrol;
    wire aclr_on_rdaddress;
    wire aclr_on_rdcontrol;
    wire aclr_on_indata;
    wire aclr_on_outdata;
    wire sclr_on_outdata;
    wire [width-1:0] data_tmp;
    wire [width-1:0] previous_read_data;
    wire [width-1:0] new_read_data;
    wire [widthad-1:0] wraddress_tmp;
    wire [widthad-1:0] rdaddress_tmp;
    wire wren_tmp;
    wire rden_tmp;
    wire [width-1:0] byteena_tmp;
    wire [width-1:0] i_lutram_output;
    wire [width-1:0] i_lutram_output_unreg;

// INTERNAL TRI DECLARATION
    logic inclock; // -- converted tristate to logic
    logic inclocken; // -- converted tristate to logic
    logic outclock; // -- converted tristate to logic
    logic outclocken; // -- converted tristate to logic
    logic rden; // -- converted tristate to logic
    logic aclr; // -- converted tristate to logic
    logic sclr; // -- converted tristate to logic
    logic wraddressstall; // -- converted tristate to logic
    logic rdaddressstall; // -- converted tristate to logic
    logic [i_width_byteena-1:0] i_byteena; // -- converted tristate to logic

// LOCAL INTEGER DECLARATION
    integer i;
    integer i_numwords;
    integer iter_byteena;

// COMPONENT INSTANTIATIONS
    ALTERA_DEVICE_FAMILIES dev ();
    ALTERA_MF_MEMORY_INITIALIZATION mem ();

// INITIAL CONSTRUCT BLOCK
    initial
    begin

        // Check for invalid parameters
        if (width <= 0)
        begin
            $display("Error! width parameter must be greater than 0.");
            $display ("Time: %0t  Instance: %m", $time);
            $stop;
        end
        if (widthad <= 0)
        begin
            $display("Error! widthad parameter must be greater than 0.");
            $display ("Time: %0t  Instance: %m", $time);
            $stop;
        end

        is_stxiii_style_ram = dev.FEATURE_FAMILY_STRATIXIII(intended_device_family);
        is_stxv_style_ram = dev.FEATURE_FAMILY_STRATIXV(intended_device_family);
	is_rising_edge_write_ena = dev.FEATURE_FAMILY_STRATIXV(intended_device_family)
			|| dev.FEATURE_FAMILY_ARRIAV(intended_device_family)
			|| dev.FEATURE_FAMILY_ARRIA10(intended_device_family);

        is_write_at_low_clock = ((wrcontrol_reg == "INCLOCK") &&
				(((lpm_hint == "USE_EAB=ON") && (use_eab != "OFF")) ||
				(use_eab == "ON") ||
				(is_lutram == 1))) &&
				(is_rising_edge_write_ena != 1)?
				1 : 0;
        if ((indata_aclr == "ON") && ((is_stxv_style_ram == 1) || (is_stxiii_style_ram == 1)))
        begin
            $display("Warning: %s device family does not support aclr on input data. Aclr on this port will be ignored.", intended_device_family);
            $display ("Time: %0t  Instance: %m", $time);
        end

        if ((wraddress_aclr == "ON") && ((is_stxv_style_ram == 1) || (is_stxiii_style_ram == 1)))
        begin
            $display("Warning: %s device family does not support aclr on write address. Aclr on this port will be ignored.", intended_device_family);
            $display ("Time: %0t  Instance: %m", $time);
        end

        if ((wrcontrol_aclr == "ON") && ((is_stxv_style_ram == 1) || (is_stxiii_style_ram == 1)))
        begin
            $display("Warning: %s device family does not support aclr on write control. Aclr on this port will be ignored.", intended_device_family);
            $display ("Time: %0t  Instance: %m", $time);
        end
        if ((rdcontrol_aclr == "ON") && ((is_stxv_style_ram == 1) || (is_stxiii_style_ram == 1)))
        begin
            $display("Warning: %s device family does not have read control (rden). Parameter rdcontrol_aclr will be ignored.", intended_device_family);
            $display ("Time: %0t  Instance: %m", $time);
        end

        if ((rdaddress_aclr == "ON") && ((is_stxv_style_ram == 1) || (is_stxiii_style_ram == 1)) && (read_during_write_mode_mixed_ports == "OLD_DATA"))
        begin
            $display("Warning: rdaddress_aclr cannot be turned on when it is %s with read_during_write_mode_mixed_ports = OLD_DATA", intended_device_family);
            $display ("Time: %0t  Instance: %m", $time);
        end

        if (((is_stxv_style_ram == 1) || (is_stxiii_style_ram == 1)) && (wrcontrol_reg != "INCLOCK"))
        begin
            $display("Warning: wrcontrol_reg can only be INCLOCK for %s device family", intended_device_family);
            $display ("Time: %0t  Instance: %m", $time);
        end

        if (((((width / width_byteena) == 5) || (width / width_byteena == 10) || (width / width_byteena == 8) || (width / width_byteena == 9)) && (byte_size == 0)) && ((is_stxv_style_ram == 1) || (is_stxiii_style_ram == 1)))
        begin
            $display("Warning : byte_size (width / width_byteena) should be in 5,8,9 or 10. It will be default to 5.");
            $display ("Time: %0t  Instance: %m", $time);
        end

        // Initialize mem_data
        i_numwords = (numwords) ? numwords : 1<<widthad;
        if (lpm_file == "UNUSED")
            for (i=0; i<i_numwords; i=i+1)
                mem_data[i] = 0;
        else
        begin
            mem.convert_to_ver_file(lpm_file, width, ram_initf);
            $readmemh(ram_initf, mem_data);
        end

        // Power-up conditions
        mem_output = 0;
        mem_output_at_outclock = 0;
        mem_output_at_inclock = 0;
        data_write_at_high = 0;
        data_write_at_low = 0;
        rdaddress_at_inclock = 0;
        rdaddress_at_inclock_low = 0;
        rdaddress_at_outclock = 0;
        rden_at_outclock = 1;
        rden_at_inclock = 1;
        i_byteena_mask = {width{1'b1}};
        i_byteena_mask_at_low = {width{1'b1}};
        i_byteena_mask_x = {width{1'b0 /* converted x or z to 1'b0 */}};
        wren_at_low = 0;
        wren_at_high = 0;
        i_lutram_output_reg_inclk = 0;
        i_lutram_output_reg_outclk = 0;
        wraddress_at_low = 0;
        wraddress_at_high = 0;
        i_old_data = 0;

        rden_low_output_0 = 0;
        first_clk_rising_edge = 1;
    end


// ALWAYS CONSTRUCT BLOCKS

    // Set up logics that respond to the postive edge of inclock
    // some logics may be affected by Asynchronous Clear
    always @(posedge inclock)
    begin
        if ((is_stxv_style_ram == 1) || (is_stxiii_style_ram == 1))
        begin
                if (inclocken == 1)
                begin
                    data_write_at_high <= data;
                    wren_at_high <= wren;

                    if (wraddressstall == 0)
                            wraddress_at_high <= wraddress;
                end
        end
        else
        begin
                if ((aclr == 1) && (indata_aclr == "ON") && (indata_reg != "UNREGISTERED") )
                    data_write_at_high <= 0;
                else if (inclocken == 1)
                    data_write_at_high <= data;

                if ((aclr == 1) && (wraddress_aclr == "ON") && (wraddress_reg != "UNREGISTERED") )
                    wraddress_at_high <= 0;
                else if ((inclocken == 1) && (wraddressstall == 0))
                    wraddress_at_high <= wraddress;

                if ((aclr == 1) && (wrcontrol_aclr == "ON") && (wrcontrol_reg != "UNREGISTERED")  )
                    wren_at_high <= 0;
                else if (inclocken == 1)
                    wren_at_high <= wren;
        end

        if (aclr_on_rdaddress)
            rdaddress_at_inclock <= 0;
        else if ((inclocken == 1) && (rdaddressstall == 0))
            rdaddress_at_inclock <= rdaddress;

        if ((aclr == 1) && (rdcontrol_aclr == "ON") && (rdcontrol_reg != "UNREGISTERED") )
            rden_at_inclock <= 0;
        else if (inclocken == 1)
            rden_at_inclock <= rden;

        if ((aclr == 1) && (outdata_aclr == "ON") && (outdata_reg == "INCLOCK") )
            mem_output_at_inclock <= 0;
        else if (inclocken == 1)
        begin
            mem_output_at_inclock <= mem_output;
        end

        if (inclocken == 1)
        begin
            if (i_width_byteena == 1)
            begin
                i_byteena_mask <= {width{i_byteena[0]}};
                i_byteena_mask_out <= (i_byteena[0]) ? {width{1'b0}} : {width{1'b0 /* converted x or z to 1'b0 */}};
                i_byteena_mask_x <= ((i_byteena[0]) || (i_byteena[0] == 1'b0)) ? {width{1'b0 /* converted x or z to 1'b0 */}} : {width{1'b0}};
            end
            else
            begin
                for (iter_byteena = 0; iter_byteena < width; iter_byteena = iter_byteena + 1)
                begin
                    i_byteena_mask[iter_byteena] <= i_byteena[iter_byteena/i_byte_size];
                    i_byteena_mask_out[iter_byteena] <= (i_byteena[iter_byteena/i_byte_size])? 1'b0 : 1'b0 /* converted x or z to 1'b0 */;
                    i_byteena_mask_x[iter_byteena] <= ((i_byteena[iter_byteena/i_byte_size]) || (i_byteena[iter_byteena/i_byte_size] == 1'b0)) ? 1'b0 /* converted x or z to 1'b0 */ : 1'b0;
                end
            end

        end

        if ((aclr == 1) && (outdata_aclr == "ON") && (outdata_reg == "INCLOCK") )
            i_lutram_output_reg_inclk <= 0;
        else
            if (inclocken == 1)
            begin
                if ((wren_tmp == 1) && (wraddress_tmp == rdaddress_tmp))
                begin
                    if (i_read_during_write == "NEW_DATA")
                        i_lutram_output_reg_inclk <=  (i_read_during_write == "NEW_DATA") ? mem_data[rdaddress_tmp] :
                                        ((rdaddress_tmp == wraddress_tmp) && wren_tmp) ?
                                        mem_data[rdaddress_tmp] ^ i_byteena_mask_x : mem_data[rdaddress_tmp];
                    else if (i_read_during_write == "OLD_DATA")
                        i_lutram_output_reg_inclk <= i_old_data;
                    else
                        i_lutram_output_reg_inclk <= {width{1'b0 /* converted x or z to 1'b0 */}};
                end
                else if ((!first_clk_rising_edge) || (i_read_during_write != "OLD_DATA"))
                    i_lutram_output_reg_inclk <= mem_data[rdaddress_tmp];

                first_clk_rising_edge <= 0;
            end
    end

    // Set up logics that respond to the negative edge of inclock
    // some logics may be affected by Asynchronous Clear
    always @(negedge inclock)
    begin
        if ((is_stxv_style_ram == 1) || (is_stxiii_style_ram == 1))
        begin
                if (inclocken == 1)
                begin
                    data_write_at_low <= data_write_at_high;
                    wraddress_at_low <= wraddress_at_high;
                    wren_at_low <= wren_at_high;
                end

        end
        else
        begin
                if ((aclr == 1) && (indata_aclr == "ON")  && (indata_reg != "UNREGISTERED")  )
                    data_write_at_low <= 0;
                else if (inclocken == 1)
                    data_write_at_low <= data_write_at_high;

                if ((aclr == 1) && (wraddress_aclr == "ON") && (wraddress_reg != "UNREGISTERED")  )
                    wraddress_at_low <= 0;
                else if (inclocken == 1)
                    wraddress_at_low <= wraddress_at_high;

                if ((aclr == 1) && (wrcontrol_aclr == "ON") && (wrcontrol_reg != "UNREGISTERED")  )
                    wren_at_low <= 0;
                else if (inclocken == 1)
                    wren_at_low <= wren_at_high;

        end

        if (inclocken == 1)
            begin
            i_byteena_mask_at_low <= i_byteena_mask;
        end

        if (inclocken == 1)
            rdaddress_at_inclock_low <= rdaddress_at_inclock;


    end

    // Set up logics that respond to the positive edge of outclock
    // some logics may be affected by Asynchronous Clear
    always @(posedge outclock)
    begin
        if (aclr_on_rdaddress)
            rdaddress_at_outclock <= 0;
        else if ((outclocken == 1) && (rdaddressstall == 0))
            rdaddress_at_outclock <= rdaddress;

        if ((aclr == 1) && (rdcontrol_aclr == "ON") && (rdcontrol_reg != "UNREGISTERED") )
            rden_at_outclock <= 0;
        else if (outclocken == 1)
            rden_at_outclock <= rden;

        if ((aclr == 1) && (outdata_aclr == "ON") && (outdata_reg == "OUTCLOCK") )
        begin
            mem_output_at_outclock <= 0;
            i_lutram_output_reg_outclk <= 0;
        end
        else if (outclocken == 1)
        begin
           if ((sclr == 1) && (outdata_sclr == "ON") && (outdata_reg == "OUTCLOCK"))
           begin
               mem_output_at_outclock <= 0;
               i_lutram_output_reg_outclk <= 0;
           end
           else
           begin
               mem_output_at_outclock <= mem_output;
               i_lutram_output_reg_outclk <= mem_data[rdaddress_tmp];
           end
       end
    end

    // Asynchronous Logic
    // Update memory with the latest data
    always @(data_tmp or wraddress_tmp or wren_tmp or byteena_tmp)
    begin
        if (wren_tmp == 1)
        begin
            if ((is_stxv_style_ram == 1) || (is_stxiii_style_ram == 1))
            begin
                i_old_data <= mem_data[wraddress_tmp];
                mem_data[wraddress_tmp] <= ((data_tmp & byteena_tmp) | (mem_data[wraddress_tmp] & ~byteena_tmp));
            end
            else
                mem_data[wraddress_tmp] <= data_tmp;
        end
    end

    always @(new_read_data)
    begin
        mem_output <= new_read_data;
    end

// CONTINUOUS ASSIGNMENT

    assign i_byteena = byteena;

    // The following circuits will select for appropriate connections based on
    // the given parameter values

    assign aclr_on_wraddress = ((wraddress_aclr == "ON") ?
                                aclr : 1'b0);

    assign aclr_on_wrcontrol = ((wrcontrol_aclr == "ON") ?
                                aclr : 1'b0);

    assign aclr_on_rdaddress = (((rdaddress_aclr == "ON") && (rdaddress_reg != "UNREGISTERED") &&
                                !(((is_stxv_style_ram == 1) || (is_stxiii_style_ram == 1)) && (read_during_write_mode_mixed_ports == "OLD_DATA"))) ?
                                aclr : 1'b0);

    assign aclr_on_rdcontrol = (((rdcontrol_aclr == "ON") && (is_stxv_style_ram != 1) && (is_stxiii_style_ram != 1)) ?
                                aclr : 1'b0);

    assign aclr_on_indata = ((indata_aclr == "ON") ?
                                aclr : 1'b0);

    assign aclr_on_outdata = ((outdata_aclr == "ON") ?
                                aclr : 1'b0);

    assign sclr_on_outdata = ((outdata_sclr == "ON") ?
                                sclr : 1'b0);

    assign data_tmp = ((indata_reg == "INCLOCK") ?
                            ((is_write_at_low_clock == 1) ?
                            ((aclr_on_indata == 1) ?
                            {width{1'b0}} : data_write_at_low)
                            : ((aclr_on_indata == 1) ?
                            {width{1'b0}} : data_write_at_high))
                            : data);

    assign wraddress_tmp = ((wraddress_reg == "INCLOCK") ?
                            ((is_write_at_low_clock == 1) ?
                            ((aclr_on_wraddress == 1) ?
                            {widthad{1'b0}} : wraddress_at_low)
                            : ((aclr_on_wraddress == 1) ?
                            {widthad{1'b0}} : wraddress_at_high))
                            : wraddress);

    assign wren_tmp = ((wrcontrol_reg == "INCLOCK") ?
                        ((is_write_at_low_clock == 1) ?
                        ((aclr_on_wrcontrol == 1) ?
                        1'b0 : wren_at_low)
                        : ((aclr_on_wrcontrol == 1) ?
                        1'b0 : wren_at_high))
                        : wren);

    assign rdaddress_tmp = ((rdaddress_reg == "INCLOCK") ?
                            ((((is_stxv_style_ram == 1) || (is_stxiii_style_ram == 1)) && (i_read_during_write == "OLD_DATA")) ?
                            rdaddress_at_inclock_low :
                            ((aclr_on_rdaddress == 1) ?
                            {widthad{1'b0}} : rdaddress_at_inclock))
                            : ((rdaddress_reg == "OUTCLOCK") ?
                            ((aclr_on_rdaddress == 1) ? {widthad{1'b0}} : rdaddress_at_outclock)
                            : rdaddress));

    assign rden_tmp =  ((is_stxv_style_ram == 1) || (is_stxiii_style_ram == 1)) ?
                        1'b1 : ((rdcontrol_reg == "INCLOCK") ?
                        ((aclr_on_rdcontrol == 1) ?
                        1'b0 : rden_at_inclock)
                        : ((rdcontrol_reg == "OUTCLOCK") ?
                        ((aclr_on_rdcontrol == 1) ? 1'b0 : rden_at_outclock)
                        : rden));

    assign byteena_tmp = (is_write_at_low_clock)? i_byteena_mask_at_low : i_byteena_mask;

    assign previous_read_data = mem_output;

    assign new_read_data = ((rden_tmp == 1) ?
                                mem_data[rdaddress_tmp]
                                : ((rden_low_output_0) ?
                                {width{1'b0}} : previous_read_data));

    assign i_lutram_output_unreg = mem_data[rdaddress_tmp];

    assign i_lutram_output = ((outdata_reg == "INCLOCK")) ?
                                i_lutram_output_reg_inclk :
                                ((outdata_reg == "OUTCLOCK") ? i_lutram_output_reg_outclk : i_lutram_output_unreg);

    assign q = (aclr_on_outdata == 1) ? {width{1'b0}} :
                ((is_stxv_style_ram) || (is_stxiii_style_ram == 1)) ?  i_lutram_output :
                ((outdata_reg == "OUTCLOCK") ? mem_output_at_outclock : ((outdata_reg == "INCLOCK") ?
                mem_output_at_inclock : mem_output));

endmodule // altdpram

