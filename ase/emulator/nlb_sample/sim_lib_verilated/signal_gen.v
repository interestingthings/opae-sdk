// Created by altera_lib_mf.pl from altera_mf.v


// VIRTUAL JTAG MODULE CONSTANTS

// the default bit length for time and value
`define DEFAULT_BIT_LENGTH 32

// the bit length for type
`define TYPE_BIT_LENGTH 4

// the bit length for delay time
`define TIME_BIT_LENGTH 64

// the number of selection bits + width of hub instructions(3)
`define NUM_SELECTION_BITS 4

// the states for the parser state machine
`define STARTSTATE    3'b000
`define LENGTHSTATE   3'b001
`define VALUESTATE    3'b011
`define TYPESTATE     3'b111
`define TIMESTATE     3'b101

`define V_DR_SCAN_TYPE 4'b0010
`define V_IR_SCAN_TYPE 4'b0001

// specify time scale
`define CLK_PERIOD 100000

`define DELAY_RESOLUTION 10000

// the states for the tap controller state machine
`define TLR_ST  5'b00000
`define RTI_ST  5'b00001
`define DRS_ST  5'b00011
`define CDR_ST  5'b00111
`define SDR_ST  5'b01111
`define E1DR_ST 5'b01011
`define PDR_ST  5'b01101
`define E2DR_ST 5'b01000
`define UDR_ST  5'b01001
`define IRS_ST  5'b01100
`define CIR_ST  5'b01010
`define SIR_ST  5'b00101
`define E1IR_ST 5'b00100
`define PIR_ST  5'b00010
`define E2IR_ST 5'b00110
`define UIR_ST  5'b01110
`define INIT_ST 5'b10000

// usr1 instruction for tap controller
`define JTAG_USR1_INSTR 10'b0000001110



//START_MODULE_NAME------------------------------------------------------------
// Module Name         : signal_gen
//
// Description         : Simulates customizable actions on a JTAG input
//
// Limitation          : Zero is not a valid length and causes simulation to halt with
// an error message.
// Values with more bits than specified length will be truncated.
// Length for IR scans are ignored. They however should be factored in when
// calculating SLD_NODE_TOTAl_LENGTH.
//
// Results expected    :
//
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
module signal_gen (tck,tms,tdi,jtag_usr1,tdo);


    // GLOBAL PARAMETER DECLARATION
    parameter sld_node_ir_width = 1;
    parameter sld_node_n_scan = 0;
    parameter sld_node_total_length = 0;
    parameter sld_node_sim_action = "()";

    // INPUT PORTS
    input     jtag_usr1;
    input     tdo;

    // OUTPUT PORTS
    output    tck;
    output    tms;
    output    tdi;

    // CONSTANT DECLARATIONS
`define DECODED_SCANS_LENGTH (sld_node_total_length + ((sld_node_n_scan * `DEFAULT_BIT_LENGTH) * 2) + (sld_node_n_scan * `TYPE_BIT_LENGTH) - 1)
`define DEFAULT_SCAN_LENGTH (sld_node_n_scan * `DEFAULT_BIT_LENGTH)
`define TYPE_SCAN_LENGTH (sld_node_n_scan * `TYPE_BIT_LENGTH) - 1

    // INTEGER DECLARATION
    integer   char_idx;       // character_loop index
    integer   value_idx;      // decoding value index
    integer   value_idx_old;  // previous decoding value index
    integer   value_idx_cur;  // reading/outputing value index
    integer   length_idx;     // decoding length index
    integer   length_idx_old; // previous decoding length index
    integer   length_idx_cur; // reading/outputing length index
    integer   last_length_idx;// decoding previous length index
    integer   type_idx;       // decoding type index
    integer   type_idx_old;   // previous decoding type index
    integer   type_idx_cur;   // reading/outputing type index
    integer   time_idx;       // decoding time index
    integer   time_idx_old;   // previous decoding time index
    integer   time_idx_cur;   // reading/outputing time index

    // REGISTERS
    reg [ `DEFAULT_SCAN_LENGTH - 1 : 0 ]    scan_length;
    // register for the 32-bit length values
    reg [ sld_node_total_length  - 1 : 0 ]  scan_values;
    // register for values
    reg [ `TYPE_SCAN_LENGTH : 0 ]           scan_type;
    // register for 4-bit type
    reg [ `DEFAULT_SCAN_LENGTH - 1 : 0 ]    scan_time;
    // register to hold time values
    reg [15 : 0]                            two_character;
    // two ascii characters. Used in decoding
    reg [2 : 0]                             c_state;
    // the current state register
    reg [3 : 0]                             hex_value;
    // temporary value to hold hex value of ascii character
    reg [31 : 0]                             last_length;
    // register to hold the previous length value read
    reg                                     tms_reg;
    // register to hold tms value before its clocked
    reg                                     tdi_reg;
    // register to hold tdi vale before its clocked

    // OUTPUT REGISTERS
    reg    tms;
    reg    tck;
    reg    tdi;

    // input registers

    // LOCAL TIME DECLARATION

    // FUNCTION DECLARATION

    // hexToBits - takes in a hexadecimal character and
    // returns the 4-bit value of the character.
    // Returns 0 if character is not a hexadeciaml character
    function [3 : 0]  hexToBits;
        input [7 : 0] character;
        begin
            case ( character )
                "0" : hexToBits = 4'b0000;
                "1" : hexToBits = 4'b0001;
                "2" : hexToBits = 4'b0010;
                "3" : hexToBits = 4'b0011;
                "4" : hexToBits = 4'b0100;
                "5" : hexToBits = 4'b0101;
                "6" : hexToBits = 4'b0110;
                "7" : hexToBits = 4'b0111;
                "8" : hexToBits = 4'b1000;
                "9" : hexToBits = 4'b1001;
                "A" : hexToBits = 4'b1010;
                "a" : hexToBits = 4'b1010;
                "B" : hexToBits = 4'b1011;
                "b" : hexToBits = 4'b1011;
                "C" : hexToBits = 4'b1100;
                "c" : hexToBits = 4'b1100;
                "D" : hexToBits = 4'b1101;
                "d" : hexToBits = 4'b1101;
                "E" : hexToBits = 4'b1110;
                "e" : hexToBits = 4'b1110;
                "F" : hexToBits = 4'b1111;
                "f" : hexToBits = 4'b1111;
                default :
                    begin
                        hexToBits = 4'b0000;
                        $display("%s is not a hexadecimal value",character);
                    end
            endcase
        end
    endfunction

    // TASK DECLARATIONS

    // clocks tck
    task clock_tck;
        input in_tms;
        input in_tdi;
        begin : clock_tck_tsk
            #(`CLK_PERIOD/2) tck <= ~tck;
            tms <= in_tms;
            tdi <= in_tdi;
            #(`CLK_PERIOD/2) tck <= ~tck;
        end // clock_tck_tsk
    endtask // clock_tck

    // move tap controller from dr/ir shift state to ir/dr update state
    task goto_update_state;
        begin : goto_update_state_tsk
            // get into e1(i/d)r state
            tms_reg = 1'b1;
            clock_tck(tms_reg,tdi_reg);
            // get into u(i/d)r state
            tms_reg = 1'b1;
            clock_tck(tms_reg,tdi_reg);
        end // goto_update_state_tsk
    endtask // goto_update_state

    // resets the jtag TAP controller by holding tms high
    // for 6 tck cycles
    task reset_jtag;
        integer idx;
        begin
            for (idx = 0; idx < 6; idx= idx + 1)
                begin
                    tms_reg = 1'b1;
                    clock_tck(tms_reg,tdi_reg);
                end
            // get into rti state
            tms_reg = 1'b0;
            clock_tck(tms_reg,tdi_reg);
            jtag_ir_usr1;
        end
    endtask // reset_jtag

    // sends a jtag_usr0 intsruction
    task jtag_ir_usr0;
        integer i;
        begin : jtag_ir_usr0_tsk
            // get into drs state
            tms_reg = 1'b1;
            clock_tck(tms_reg,tdi_reg);
            // get into irs state
            tms_reg = 1'b1;
            clock_tck(tms_reg,tdi_reg);
            // get into cir state
            tms_reg = 1'b0;
            clock_tck(tms_reg,tdi_reg);
            // get into sir state
            tms_reg = 1'b0;
            clock_tck(tms_reg,tdi_reg);
            // shift in data i.e usr0 instruction
            // usr1 = 0x0E = 0b00 0000 1100
            for ( i = 0; i < 2; i = i + 1)
                begin :ir_usr0_loop1
                    tdi_reg = 1'b0;
                    tms_reg = 1'b0;
                    clock_tck(tms_reg,tdi_reg);
                end // ir_usr0_loop1
            for ( i = 0; i < 2; i = i + 1)
                begin :ir_usr0_loop2
                    tdi_reg = 1'b1;
                    tms_reg = 1'b0;
                    clock_tck(tms_reg,tdi_reg);
                end // ir_usr0_loop2
            // done with 1100
            for ( i = 0; i < 6; i = i + 1)
                begin :ir_usr0_loop3
                    tdi_reg = 1'b0;
                    tms_reg = 1'b0;
                    clock_tck(tms_reg,tdi_reg);
                end // ir_usr0_loop3
            // done  with 00 0000
            // get into e1ir state
            tms_reg = 1'b1;
            clock_tck(tms_reg,tdi_reg);
            // get into uir state
            tms_reg = 1'b1;
            clock_tck(tms_reg,tdi_reg);
        end // jtag_ir_usr0_tsk
    endtask // jtag_ir_usr0

    // sends a jtag_usr1 intsruction
    task jtag_ir_usr1;
        integer i;
        begin : jtag_ir_usr1_tsk
            // get into drs state
            tms_reg = 1'b1;
            clock_tck(tms_reg,tdi_reg);
            // get into irs state
            tms_reg = 1'b1;
            clock_tck(tms_reg,tdi_reg);
            // get into cir state
            tms_reg = 1'b0;
            clock_tck(tms_reg,tdi_reg);
            // get into sir state
            tms_reg = 1'b0;
            clock_tck(tms_reg,tdi_reg);
            // shift in data i.e usr1 instruction
            // usr1 = 0x0E = 0b00 0000 1110
            tdi_reg = 1'b0;
            tms_reg = 1'b0;
            clock_tck(tms_reg,tdi_reg);
            for ( i = 0; i < 3; i = i + 1)
                begin :ir_usr1_loop1
                    tdi_reg = 1'b1;
                    tms_reg = 1'b0;
                    clock_tck(tms_reg,tdi_reg);
                end // ir_usr1_loop1
            // done with 1110
            for ( i = 0; i < 5; i = i + 1)
                begin :ir_usr1_loop2
                    tdi_reg = 1'b0;
                    tms_reg = 1'b0;
                    clock_tck(tms_reg,tdi_reg);
                end // ir_sur1_loop2
            tdi_reg = 1'b0;
            tms_reg = 1'b1;
            clock_tck(tms_reg,tdi_reg);
            // done  with 00 0000
            // now in e1ir state
            // get into uir state
            tms_reg = 1'b1;
            clock_tck(tms_reg,tdi_reg);
        end // jtag_ir_usr1_tsk
    endtask // jtag_ir_usr1

    // sends a force_ir_capture instruction to the node
    task send_force_ir_capture;
        integer i;
        begin : send_force_ir_capture_tsk
            goto_dr_shift_state;
            // start shifting in the instruction
            tdi_reg = 1'b1;
            tms_reg = 1'b0;
            clock_tck(tms_reg,tdi_reg);
            tdi_reg = 1'b1;
            tms_reg = 1'b0;
            clock_tck(tms_reg,tdi_reg);
            tdi_reg = 1'b0;
            tms_reg = 1'b0;
            clock_tck(tms_reg,tdi_reg);
            // done with 011
            tdi_reg = 1'b0;
            tms_reg = 1'b0;
            clock_tck(tms_reg,tdi_reg);
            // done with select bit
            // fill up with zeros up to ir_width
            for ( i = 0; i < sld_node_ir_width - 4; i = i + 1 )
                begin
                    tdi_reg = 1'b0;
                    tms_reg = 1'b0;
                    clock_tck(tms_reg,tdi_reg);
                end
            goto_update_state;
        end // send_force_ir_capture_tsk
    endtask // send_forse_ir_capture

    // puts the JTAG tap controller in DR shift state
    task goto_dr_shift_state;
        begin : goto_dr_shift_state_tsk
            // get into drs state
            tms_reg = 1'b1;
            clock_tck(tms_reg,tdi_reg);
            // get into cdr state
            tms_reg = 1'b0;
            clock_tck(tms_reg,tdi_reg);
            // get into sdr state
            tms_reg = 1'b0;
            clock_tck(tms_reg,tdi_reg);
        end // goto_dr_shift_state_tsk
    endtask // goto_dr_shift_state

    // performs a virtual_ir_scan
    task v_ir_scan;
        input [`DEFAULT_BIT_LENGTH - 1 : 0] length;
        integer i;
        begin : v_ir_scan_tsk
            // if we are not in usr1 then go to usr1 state
            if (jtag_usr1 == 1'b0)
                begin
                    jtag_ir_usr1;
                end
            // send force_ir_capture
            send_force_ir_capture;
            // shift in the ir value
            goto_dr_shift_state;
            value_idx_cur = value_idx_cur - length;
            for ( i = 0; i < length; i = i + 1)
                begin
                    tms_reg = 1'b0;
                    tdi_reg = scan_values[value_idx_cur + i];
                    clock_tck(tms_reg,tdi_reg);
                end
            // pad with zeros if necessary
            for(i = length; i < sld_node_ir_width; i = i + 1)
                begin : zero_padding
                    tdi_reg = 1'b0;
                    tms_reg = 1'b0;
                    clock_tck(tms_reg,tdi_reg);
                end //zero_padding
            tdi_reg = 1'b1;
            goto_update_state;
        end // v_ir_scan_tsk
    endtask // v_ir_scan

    // performs a virtual dr scan
    task v_dr_scan;
        input [`DEFAULT_BIT_LENGTH - 1 : 0] length;
        integer                             i;
        begin : v_dr_scan_tsk
            // if we are in usr1 then go to usr0 state
            if (jtag_usr1 == 1'b1)
                begin
                    jtag_ir_usr0;
                end
            // shift in the dr value
            goto_dr_shift_state;
            value_idx_cur = value_idx_cur - length;
            for ( i = 0; i < length - 1; i = i + 1)
                begin
                    tms_reg = 1'b0;
                    tdi_reg = scan_values[value_idx_cur + i];
                    clock_tck(tms_reg,tdi_reg);
                end
            // last bit is clocked together with state transition
            tdi_reg = scan_values[value_idx_cur + i];
            goto_update_state;
        end // v_dr_scan_tsk
    endtask // v_dr_scan

    initial
        begin : sim_model
            // initialize output registers
            tck = 1'b1;
            tms = 1'b0;
            tdi = 1'b0;
            // initialize variables
            tms_reg = 1'b0;
            tdi_reg = 1'b0;
            two_character = 'b0;
            last_length_idx = 0;
            value_idx = 0;
            value_idx_old = 0;
            length_idx = 0;
            length_idx_old = 0;
            type_idx = 0;
            type_idx_old = 0;
            time_idx = 0;
            time_idx_old = 0;
            scan_length = 'b0;
            scan_values = 'b0;
            scan_type = 'b0;
            scan_time = 'b0;
            last_length = 'b0;
            hex_value = 'b0;
            c_state = `STARTSTATE;
            // initialize current indices
            value_idx_cur = sld_node_total_length;
            type_idx_cur = `TYPE_SCAN_LENGTH;
            time_idx_cur = `DEFAULT_SCAN_LENGTH;
            length_idx_cur = `DEFAULT_SCAN_LENGTH;
            for(char_idx = 0;two_character != "((";char_idx = char_idx + 8)
                begin : character_loop
                    // convert two characters to equivalent 16-bit value
                    two_character[0]  = sld_node_sim_action[char_idx];
                    two_character[1]  = sld_node_sim_action[char_idx+1];
                    two_character[2]  = sld_node_sim_action[char_idx+2];
                    two_character[3]  = sld_node_sim_action[char_idx+3];
                    two_character[4]  = sld_node_sim_action[char_idx+4];
                    two_character[5]  = sld_node_sim_action[char_idx+5];
                    two_character[6]  = sld_node_sim_action[char_idx+6];
                    two_character[7]  = sld_node_sim_action[char_idx+7];
                    two_character[8]  = sld_node_sim_action[char_idx+8];
                    two_character[9]  = sld_node_sim_action[char_idx+9];
                    two_character[10] = sld_node_sim_action[char_idx+10];
                    two_character[11] = sld_node_sim_action[char_idx+11];
                    two_character[12] = sld_node_sim_action[char_idx+12];
                    two_character[13] = sld_node_sim_action[char_idx+13];
                    two_character[14] = sld_node_sim_action[char_idx+14];
                    two_character[15] = sld_node_sim_action[char_idx+15];
                    // use state machine to decode
                    case (c_state)
                        `STARTSTATE :
                            begin
                                if (two_character[15 : 8] != ")")
                                    begin
                                        c_state = `LENGTHSTATE;
                                    end
                            end
                        `LENGTHSTATE :
                            begin
                                if (two_character[7 : 0] == ",")
                                    begin
                                        length_idx = length_idx_old + 32;
                                        length_idx_old = length_idx;
                                        c_state = `VALUESTATE;
                                    end
                                else
                                    begin
                                        hex_value = hexToBits(two_character[7:0]);
                                        scan_length [ length_idx] = hex_value[0];
                                        scan_length [ length_idx + 1] = hex_value[1];
                                        scan_length [ length_idx + 2] = hex_value[2];
                                        scan_length [ length_idx + 3] = hex_value[3];
                                        last_length [ last_length_idx] = hex_value[0];
                                        last_length [ last_length_idx + 1] = hex_value[1];
                                        last_length [ last_length_idx + 2] = hex_value[2];
                                        last_length [ last_length_idx + 3] = hex_value[3];
                                        length_idx = length_idx + 4;
                                        last_length_idx = last_length_idx + 4;
                                    end
                            end
                        `VALUESTATE :
                            begin
                                if (two_character[7 : 0] == ",")
                                    begin
                                        value_idx = value_idx_old + last_length;
                                        value_idx_old = value_idx;
                                        last_length = 'b0; // reset the last length value
                                        last_length_idx = 0; // reset index for length
                                        c_state = `TYPESTATE;
                                    end
                                else
                                    begin
                                        hex_value = hexToBits(two_character[7:0]);
                                        scan_values [ value_idx] = hex_value[0];
                                        scan_values [ value_idx + 1] = hex_value[1];
                                        scan_values [ value_idx + 2] = hex_value[2];
                                        scan_values [ value_idx + 3] = hex_value[3];
                                        value_idx = value_idx + 4;
                                    end
                            end
                        `TYPESTATE :
                            begin
                                if (two_character[7 : 0] == ",")
                                    begin
                                        type_idx = type_idx + 4;
                                        c_state = `TIMESTATE;
                                    end
                                else
                                    begin
                                        hex_value = hexToBits(two_character[7:0]);
                                        scan_type [ type_idx] = hex_value[0];
                                        scan_type [ type_idx + 1] = hex_value[1];
                                        scan_type [ type_idx + 2] = hex_value[2];
                                        scan_type [ type_idx + 3] = hex_value[3];
                                    end
                            end
                        `TIMESTATE :
                            begin
                                if (two_character[7 : 0] == "(")
                                    begin
                                        time_idx = time_idx_old + 32;
                                        time_idx_old = time_idx;
                                        c_state = `STARTSTATE;
                                    end
                                else
                                    begin
                                        hex_value = hexToBits(two_character[7:0]);
                                        scan_time [ time_idx] = hex_value[0];
                                        scan_time [ time_idx + 1] = hex_value[1];
                                        scan_time [ time_idx + 2] = hex_value[2];
                                        scan_time [ time_idx + 3] = hex_value[3];
                                        time_idx = time_idx + 4;
                                    end
                            end
                        default :
                            c_state = `STARTSTATE;
                    endcase
                end // block: character_loop
            # (`CLK_PERIOD/2);
            begin : execute
                integer write_scan_idx;
                integer tempLength_idx;
                reg [`TYPE_BIT_LENGTH - 1 : 0] tempType;
                reg [`DEFAULT_BIT_LENGTH - 1 : 0 ] tempLength;
                reg [`DEFAULT_BIT_LENGTH - 1 : 0 ] tempTime;
                reg [`TIME_BIT_LENGTH - 1 : 0 ] delayTime;
                reset_jtag;
                for (write_scan_idx = 0; write_scan_idx < sld_node_n_scan; write_scan_idx = write_scan_idx + 1)
                    begin : all_scans_loop
                        tempType[3] = scan_type[type_idx_cur];
                        tempType[2] = scan_type[type_idx_cur - 1];
                        tempType[1] = scan_type[type_idx_cur - 2];
                        tempType[0] = scan_type[type_idx_cur - 3];
                        time_idx_cur = time_idx_cur - `DEFAULT_BIT_LENGTH;
                        length_idx_cur = length_idx_cur - `DEFAULT_BIT_LENGTH;
                        for (tempLength_idx = 0; tempLength_idx < `DEFAULT_BIT_LENGTH; tempLength_idx = tempLength_idx + 1)
                            begin : get_scan_time
                                tempTime[tempLength_idx] = scan_time[time_idx_cur + tempLength_idx];
                            end // get_scan_time
                            delayTime =(`DELAY_RESOLUTION * `CLK_PERIOD * tempTime);
                            # delayTime;
                        if (tempType == `V_IR_SCAN_TYPE)
                            begin
                                for (tempLength_idx = 0; tempLength_idx < `DEFAULT_BIT_LENGTH; tempLength_idx = tempLength_idx + 1)
                                    begin : ir_get_length
                                        tempLength[tempLength_idx] = scan_length[length_idx_cur + tempLength_idx];
                                    end // ir_get_length
                                v_ir_scan(tempLength);
                            end
                        else
                            begin
                                if (tempType == `V_DR_SCAN_TYPE)
                                    begin
                                        for (tempLength_idx = 0; tempLength_idx < `DEFAULT_BIT_LENGTH; tempLength_idx = tempLength_idx + 1)
                                            begin : dr_get_length
                                                tempLength[tempLength_idx] = scan_length[length_idx_cur + tempLength_idx];
                                            end // dr_get_length
                                        v_dr_scan(tempLength);
                                    end
                                else
                                    begin
                                        $display("Invalid scan type");
                                    end
                            end
                        type_idx_cur = type_idx_cur - 4;
                    end // all_scans_loop
                //get into tlr state
                for (tempLength_idx = 0; tempLength_idx < 6; tempLength_idx= tempLength_idx + 1)
                    begin
                        tms_reg = 1'b1;
                        clock_tck(tms_reg,tdi_reg);
                    end
            end //execute
        end // block: sim_model
endmodule // signal_gen

