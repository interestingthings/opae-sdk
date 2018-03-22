// Created by altera_lib_lpm.pl from 220model.v
// Created by altera_lib_lpm.pl from 220model.v
//-------------------------------------------------------------------------
// This Verilog file was developed by Altera Corporation.  It may be
// freely copied and/or distributed at no cost.  Any persons using this
// file for any purpose do so at their own risk, and are responsible for
// the results of such use.  Altera Corporation does not guarantee that
// this file is complete, correct, or fit for any particular purpose.
// NO WARRANTY OF ANY KIND IS EXPRESSED OR IMPLIED.  This notice must
// accompany any copy of this file.
//------------------------------------------------------------------------
//
// Quartus Prime 16.1.0 Build 196 10/24/2016
//
//------------------------------------------------------------------------
// LPM Synthesizable Models (Support string type generic)
// These models are based on LPM version 220 (EIA-IS103 October 1998).
//------------------------------------------------------------------------
//
//-----------------------------------------------------------------------------
// Assumptions:
//
// 1. The default value for LPM_SVALUE, LPM_AVALUE, LPM_PVALUE, and
//    LPM_STRENGTH is string UNUSED.
//
//-----------------------------------------------------------------------------
// Verilog Language Issues:
//
// Two dimensional ports are not supported. Modules with two dimensional
// ports are implemented as one dimensional signal of (LPM_SIZE * LPM_WIDTH)
// bits wide.
//
//-----------------------------------------------------------------------------
//START_MODULE_NAME------------------------------------------------------------
//
// Module Name     :  LPM_MEMORY_INITIALIZATION
//
// Description     :  Common function to read intel-hex format data file with
//                    extension .hex and creates the equivalent verilog format
//                    data file with extension .ver.
//
// Limitation      :  Supports only record type '00'(data record), '01'(end of
//                     file record) and '02'(extended segment address record).
//
// Results expected:  Creates the verilog format data file with extension .ver
//                     and return the name of the file.
//
//END_MODULE_NAME--------------------------------------------------------------

// BEGINNING OF MODULE
`timescale 1 ps / 1 ps

`define LPM_TRUE 1
`define LPM_FALSE 0
`define LPM_NULL 0
`define LPM_EOF -1
`define LPM_MAX_NAME_SZ     128
`define LPM_MAX_WIDTH       256
`define LPM_COLON           ":"
`define LPM_DOT             "."
`define LPM_NEWLINE         "\n"
`define LPM_CARRIAGE_RETURN  8'h0D
`define LPM_SPACE           " "
`define LPM_TAB             "\t"
`define LPM_OPEN_BRACKET    "["
`define LPM_CLOSE_BRACKET   "]"
`define LPM_OFFSET          9
`define LPM_H10             8'h10
`define LPM_H10000          20'h10000
`define LPM_AWORD           8
`define LPM_MASK15          32'h000000FF
`define LPM_EXT_STR         "ver"
`define LPM_PERCENT         "%"
`define LPM_MINUS           "-"
`define LPM_SEMICOLON       ";"
`define LPM_EQUAL           "="

// MODULE DECLARATION
/*verilator lint_off CASEX*/
/*verilator lint_off COMBDLY*/
/*verilator lint_off INITIALDLY*/
/*verilator lint_off LITENDIAN*/
/*verilator lint_off MULTIDRIVEN*/
/*verilator lint_off UNOPTFLAT*/
/*verilator lint_off BLKANDNBLK*/
module LPM_MEMORY_INITIALIZATION;

/****************************************************************/
/* convert uppercase character values to lowercase.             */
/****************************************************************/
function [8:1] tolower;
    input [8:1] given_character;
    reg [8:1] conv_char;

begin
    if ((given_character >= 65) && (given_character <= 90)) // ASCII number of 'A' is 65, 'Z' is 90
    begin
        conv_char = given_character + 32; // 32 is the difference in the position of 'A' and 'a' in the ASCII char set
        tolower = conv_char;
    end
    else
        tolower = given_character;
end
endfunction

/****************************************************************/
/* Read in Altera-mif format data to verilog format data.       */
/****************************************************************/
task convert_mif2ver;
    input[`LPM_MAX_NAME_SZ*8 : 1] in_file;
    input width;
    output [`LPM_MAX_NAME_SZ*8 : 1] out_file;
    reg [`LPM_MAX_NAME_SZ*8 : 1] in_file;
    reg [`LPM_MAX_NAME_SZ*8 : 1] out_file;
    reg [`LPM_MAX_NAME_SZ*8 : 1] buffer;
    reg [`LPM_MAX_WIDTH : 0] memory_data1, memory_data2;
    reg [8 : 1] c;
    reg [3 : 0] hex, tmp_char;
    reg [24 : 1] address_radix, data_radix;
    reg get_width;
    reg get_depth;
    reg get_data_radix;
    reg get_address_radix;
    reg width_found;
    reg depth_found;
    reg data_radix_found;
    reg address_radix_found;
    reg get_address_data_pairs;
    reg get_address;
    reg get_data;
    reg display_address;
    reg invalid_address;
    reg get_start_address;
    reg get_end_address;
    reg done;
    reg error_status;
    reg first_rec;
    reg last_rec;

    integer width;
    integer memory_width, memory_depth;
    integer value;
    integer ifp, ofp, r, r2;
    integer i, j, k, m, n;

    integer off_addr, nn, address, tt, cc, aah, aal, dd, sum ;
    integer start_address, end_address;
    integer line_no;
    integer character_count;
    integer comment_with_percent_found;
    integer comment_with_double_minus_found;

begin
        done = `LPM_FALSE;
        error_status = `LPM_FALSE;
        first_rec = `LPM_FALSE;
        last_rec = `LPM_FALSE;
        comment_with_percent_found = `LPM_FALSE;
        comment_with_double_minus_found = `LPM_FALSE;

        off_addr= 0;
        nn= 0;
        address = 0;
        start_address = 0;
        end_address = 0;
        tt= 0;
        cc= 0;
        aah= 0;
        aal= 0;
        dd= 0;
        sum = 0;
        line_no = 1;
        c = 0;
        hex = 0;
        value = 0;
        buffer = "";
        character_count = 0;
        memory_width = 0;
        memory_depth = 0;
        memory_data1 = {(`LPM_MAX_WIDTH+1) {1'b0}};
        memory_data2 = {(`LPM_MAX_WIDTH+1) {1'b0}};
        address_radix = "hex";
        data_radix = "hex";
        get_width = `LPM_FALSE;
        get_depth = `LPM_FALSE;
        get_data_radix = `LPM_FALSE;
        get_address_radix = `LPM_FALSE;
        width_found = `LPM_FALSE;
        depth_found = `LPM_FALSE;
        data_radix_found = `LPM_FALSE;
        address_radix_found = `LPM_FALSE;
        get_address_data_pairs = `LPM_FALSE;
        display_address = `LPM_FALSE;
        invalid_address = `LPM_FALSE;
        get_start_address = `LPM_FALSE;
        get_end_address = `LPM_FALSE;

        if((in_file[4*8 : 1] == ".dat") || (in_file[4*8 : 1] == ".DAT"))
            out_file = in_file;
        else
        begin
            ifp = $fopen(in_file, "r");

            if (ifp == `LPM_NULL)
            begin
                $display("ERROR: cannot read %0s.", in_file);
                $display("Time: %0t  Instance: %m", $time);
                done = `LPM_TRUE;
            end

            out_file = in_file;

            if((out_file[4*8 : 1] == ".mif") || (out_file[4*8 : 1] == ".MIF"))
                out_file[3*8 : 1] = `LPM_EXT_STR;
            else
            begin
                $display("ERROR: Invalid input file name %0s. Expecting file with .mif extension and Altera-mif data format.", in_file);
                $display("Time: %0t  Instance: %m", $time);
                done = `LPM_TRUE;
            end

            if (!done)
            begin
                ofp = $fopen(out_file, "w");

                if (ofp == `LPM_NULL)
                begin
                    $display("ERROR : cannot write %0s.", out_file);
                    $display("Time: %0t  Instance: %m", $time);
                    done = `LPM_TRUE;
                end
            end

            while((!done) && (!error_status))
            begin : READER

                r = $fgetc(ifp);

                if (r == `LPM_EOF)
                begin
                // to do : add more checking on whether a particular assigment(width, depth, memory/address) are mising
                    if(!first_rec)
                    begin
                        error_status = `LPM_TRUE;
                        $display("WARNING: %0s, Intel-hex data file is empty.", in_file);
                        $display ("Time: %0t  Instance: %m", $time);
                    end
                    else if (!get_address_data_pairs)
                    begin
                        error_status = `LPM_TRUE;
                        $display("ERROR: %0s, line %0d, Missing `content begin` statement.", in_file, line_no);
                        $display("Time: %0t  Instance: %m", $time);
                    end
                    else if(!last_rec)
                    begin
                        error_status = `LPM_TRUE;
                        $display("ERROR: %0s, line %0d, Missing `end` statement.", in_file, line_no);
                        $display("Time: %0t  Instance: %m", $time);
                    end
                    done = `LPM_TRUE;
                end
                else if ((r == `LPM_NEWLINE) || (r == `LPM_CARRIAGE_RETURN))
                begin
                    if ((buffer == "contentbegin") && (get_address_data_pairs == `LPM_FALSE))
                    begin
                        get_address_data_pairs = `LPM_TRUE;
                        get_address = `LPM_TRUE;
                        buffer = "";
                    end
                    else if (buffer == "content")
                    begin
                        // continue to next character
                    end
                    else
                    if (buffer != "")
                    begin
                        // found invalid syntax in the particular line.
                        error_status = `LPM_TRUE;
                        $display("ERROR: %0s, line %0d, Invalid Altera-mif record.", in_file, line_no);
                        $display("Time: %0t  Instance: %m", $time);
                        disable READER;
                    end
                    line_no = line_no +1;

                end
                else if ((r == `LPM_SPACE) || (r == `LPM_TAB))
                begin
                    // continue to next character;
                end
                else if (r == `LPM_PERCENT)
                begin
                    // Ignore all the characters which which is part of comment.
                    r = $fgetc(ifp);

                    while ((r != `LPM_PERCENT) && (r != `LPM_NEWLINE) && (r != `LPM_CARRIAGE_RETURN))
                    begin
                        r = $fgetc(ifp);
                    end

                    if ((r == `LPM_NEWLINE) || (r == `LPM_CARRIAGE_RETURN))
                    begin
                        line_no = line_no +1;

                        if ((buffer == "contentbegin") && (get_address_data_pairs == `LPM_FALSE))
                        begin
                            get_address_data_pairs = `LPM_TRUE;
                            get_address = `LPM_TRUE;
                            buffer = "";
                        end
                    end
                end
                else if (r == `LPM_MINUS)
                begin
                    r = $fgetc(ifp);
                    if (r == `LPM_MINUS)
                    begin
                        // Ignore all the characters which which is part of comment.
                        r = $fgetc(ifp);

                        while ((r != `LPM_NEWLINE) && (r != `LPM_CARRIAGE_RETURN))
                        begin
                            r = $fgetc(ifp);

                        end

                        if ((r == `LPM_NEWLINE) || (r == `LPM_CARRIAGE_RETURN))
                        begin
                            line_no = line_no +1;

                            if ((buffer == "contentbegin") && (get_address_data_pairs == `LPM_FALSE))
                            begin
                                get_address_data_pairs = `LPM_TRUE;
                                get_address = `LPM_TRUE;
                                buffer = "";
                            end
                        end
                    end
                    else
                    begin
                        error_status = `LPM_TRUE;
                        $display("ERROR: %0s, line %0d, Invalid Altera-mif record.", in_file, line_no);
                        $display("Time: %0t  Instance: %m", $time);
                        done = `LPM_TRUE;
                        disable READER;
                    end
                end
                else if (r == `LPM_EQUAL)
                begin
                    if (buffer == "width")
                    begin
                        if (width_found == `LPM_FALSE)
                        begin
                            get_width = `LPM_TRUE;
                            buffer = "";
                        end
                        else
                        begin
                            error_status = `LPM_TRUE;
                            $display("ERROR: %0s, line %0d, Width has already been specified once.", in_file, line_no);
                            $display("Time: %0t  Instance: %m", $time);
                        end
                    end
                    else if (buffer == "depth")
                    begin
                        get_depth = `LPM_TRUE;
                        buffer = "";
                    end
                    else if (buffer == "data_radix")
                    begin
                        get_data_radix = `LPM_TRUE;
                        buffer = "";
                    end
                    else if (buffer == "address_radix")
                    begin
                        get_address_radix = `LPM_TRUE;
                        buffer = "";
                    end
                    else
                    begin
                        error_status = `LPM_TRUE;
                        $display("ERROR: %0s, line %0d, Unknown setting (%0s).", in_file, line_no, buffer);
                        $display("Time: %0t  Instance: %m", $time);
                    end
                end
                else if (r == `LPM_COLON)
                begin
                    if (!get_address_data_pairs)
                    begin
                        error_status = `LPM_TRUE;
                        $display("ERROR: %0s, line %0d, Missing `content begin` statement.", in_file, line_no);
                        $display("Time: %0t  Instance: %m", $time);
                    end
                    else if (invalid_address == `LPM_TRUE)
                    begin
                        error_status = `LPM_TRUE;
                        $display("ERROR: %0s, line %0d, Invalid data record.", in_file, line_no);
                        $display("Time: %0t  Instance: %m", $time);
                    end
                    begin
                        get_address = `LPM_FALSE;
                        get_data = `LPM_TRUE;
                        display_address = `LPM_TRUE;
                    end
                end
                else if (r == `LPM_DOT)
                begin
                    r = $fgetc(ifp);
                    if (r == `LPM_DOT)
                    begin
                        if (get_start_address == `LPM_TRUE)
                        begin
                            start_address = address;
                            address = 0;
                            get_start_address = `LPM_FALSE;
                            get_end_address = `LPM_TRUE;
                        end
                        else
                        begin
                            error_status = `LPM_TRUE;
                            $display("ERROR: %0s, line %0d, Invalid Altera-mif record.", in_file, line_no);
                            $display("Time: %0t  Instance: %m", $time);
                            done = `LPM_TRUE;
                            disable READER;
                        end
                    end
                    else
                    begin
                        error_status = `LPM_TRUE;
                        $display("ERROR: %0s, line %0d, Invalid Altera-mif record.", in_file, line_no);
                        $display("Time: %0t  Instance: %m", $time);
                        done = `LPM_TRUE;
                        disable READER;
                    end
                end
                else if (r == `LPM_OPEN_BRACKET)
                begin
                    get_start_address = `LPM_TRUE;
                end
                else if (r == `LPM_CLOSE_BRACKET)
                begin
                    if (get_end_address == `LPM_TRUE)
                    begin
                        end_address = address;
                        address = 0;
                        get_end_address = `LPM_FALSE;
                    end
                    else
                    begin
                        error_status = `LPM_TRUE;
                        $display("ERROR: %0s, line %0d, Invalid Altera-mif record.", in_file, line_no);
                        $display("Time: %0t  Instance: %m", $time);
                        done = `LPM_TRUE;
                        disable READER;
                    end
                end
                else if (r == `LPM_SEMICOLON)
                begin
                    if (get_width == `LPM_TRUE)
                    begin
                        width_found = `LPM_TRUE;
                        memory_width = value;
                        value = 0;
                        get_width = `LPM_FALSE;
                    end
                    else if (get_depth == `LPM_TRUE)
                    begin
                        depth_found = `LPM_TRUE;
                        memory_depth = value;
                        value = 0;
                        get_depth = `LPM_FALSE;
                    end
                    else if (get_data_radix == `LPM_TRUE)
                    begin
                        data_radix_found = `LPM_TRUE;
                        get_data_radix = `LPM_FALSE;

                        if ((buffer == "bin") || (buffer == "oct") || (buffer == "dec") || (buffer == "uns") ||
                            (buffer == "hex"))
                        begin
                            data_radix = buffer[24 : 1];
                        end
                        else
                        begin
                            error_status = `LPM_TRUE;
                            $display("ERROR: %0s, line %0d, Invalid assignment (%0s) to data_radix.", in_file, line_no, buffer);
                            $display("Time: %0t  Instance: %m", $time);
                        end
                        buffer = "";
                    end
                    else if (get_address_radix == `LPM_TRUE)
                    begin
                        address_radix_found = `LPM_TRUE;
                        get_address_radix = `LPM_FALSE;

                        if ((buffer == "bin") || (buffer == "oct") || (buffer == "dec") || (buffer == "uns") ||
                            (buffer == "hex"))
                        begin
                            address_radix = buffer[24 : 1];
                        end
                        else
                        begin
                            error_status = `LPM_TRUE;
                            $display("ERROR: %0s, line %0d, Invalid assignment (%0s) to address radix.", in_file, line_no, buffer);
                            $display("Time: %0t  Instance: %m", $time);
                        end
                        buffer = "";
                    end
                    else if (buffer == "end")
                    begin
                        if (get_address_data_pairs == `LPM_TRUE)
                        begin
                            last_rec = `LPM_TRUE;
                            buffer = "";
                        end
                        else
                        begin
                            error_status = `LPM_TRUE;
                            $display("ERROR: %0s, line %0d, Missing `content begin` statement.", in_file, line_no);
                            $display("Time: %0t  Instance: %m", $time);
                        end
                    end
                    else if (get_data == `LPM_TRUE)
                    begin
                        get_address = `LPM_TRUE;
                        get_data = `LPM_FALSE;
                        buffer = "";
                        character_count = 0;

                        if (start_address != end_address)
                        begin
                            for (address = start_address; address <= end_address; address = address+1)
                            begin
                                $fdisplay(ofp,"@%0h", address);

                                for (i = memory_width -1; i >= 0; i = i-1 )
                                begin
                                    hex[(i % 4)] =  memory_data1[i];

                                    if ((i % 4) == 0)
                                    begin
                                        $fwrite(ofp, "%0h", hex);
                                        hex = 0;
                                    end
                                end

                                $fwrite(ofp, "\n");
                            end
                            start_address = 0;
                            end_address = 0;
                            address = 0;
                            hex = 0;
                            memory_data1 = {(`LPM_MAX_WIDTH+1) {1'b0}};
                        end
                        else
                        begin
                            if (display_address == `LPM_TRUE)
                            begin
                                $fdisplay(ofp,"@%0h", address);
                                display_address = `LPM_FALSE;
                            end

                            for (i = memory_width -1; i >= 0; i = i-1 )
                            begin
                                hex[(i % 4)] =  memory_data1[i];

                                if ((i % 4) == 0)
                                begin
                                    $fwrite(ofp, "%0h", hex);
                                    hex = 0;
                                end
                            end

                            $fwrite(ofp, "\n");
                            address = 0;
                            hex = 0;
                            memory_data1 = {(`LPM_MAX_WIDTH+1) {1'b0}};
                        end
                    end
                    else
                    begin
                        error_status = `LPM_TRUE;
                        $display("ERROR: %0s, line %0d, Invalid assigment.", in_file, line_no);
                        $display("Time: %0t  Instance: %m", $time);
                    end
                end
                else if ((get_width == `LPM_TRUE) || (get_depth == `LPM_TRUE))
                begin
                    if ((r >= "0") && (r <= "9"))
                        value = (value * 10) + (r - 'h30);
                    else
                    begin
                        error_status = `LPM_TRUE;
                        $display("ERROR: %0s, line %0d, Invalid assignment to width/depth.", in_file, line_no);
                        $display("Time: %0t  Instance: %m", $time);
                    end
                end
                else if (get_address == `LPM_TRUE)
                begin
                    if (address_radix == "hex")
                    begin
                        if ((r >= "0") && (r <= "9"))
                            value = (r - 'h30);
                        else if ((r >= "A") && (r <= "F"))
                            value = 10 + (r - 'h41);
                        else if ((r >= "a") && (r <= "f"))
                            value = 10 + (r - 'h61);
                        else
                        begin
                            invalid_address = `LPM_TRUE;
                        end

                        address = (address * 16) + value;
                    end
                    else if ((address_radix == "dec"))
                    begin
                        if ((r >= "0") && (r <= "9"))
                            value = (r - 'h30);
                        else
                        begin
                            invalid_address = `LPM_TRUE;
                        end

                        address = (address * 10) + value;
                    end
                    else if (address_radix == "uns")
                    begin
                        if ((r >= "0") && (r <= "9"))
                            value = (r - 'h30);
                        else
                        begin
                            invalid_address = `LPM_TRUE;
                        end

                        address = (address * 10) + value;
                    end
                    else if (address_radix == "bin")
                    begin
                        if ((r >= "0") && (r <= "1"))
                            value = (r - 'h30);
                        else
                        begin
                            invalid_address = `LPM_TRUE;
                        end

                        address = (address * 2) + value;
                    end
                    else if (address_radix == "oct")
                    begin
                        if ((r >= "0") && (r <= "7"))
                            value = (r - 'h30);
                        else
                        begin
                            invalid_address = `LPM_TRUE;
                        end

                        address = (address * 8) + value;
                    end

                    if ((r >= 65) && (r <= 90))
                        c = tolower(r);
                    else
                        c = r;

                    {tmp_char,buffer} = {buffer, c};
                end
                else if (get_data == `LPM_TRUE)
                begin
                    character_count = character_count +1;

                    if (data_radix == "hex")
                    begin
                        if ((r >= "0") && (r <= "9"))
                            value = (r - 'h30);
                        else if ((r >= "A") && (r <= "F"))
                            value = 10 + (r - 'h41);
                        else if ((r >= "a") && (r <= "f"))
                            value = 10 + (r - 'h61);
                        else
                        begin
                            error_status = `LPM_TRUE;
                            $display("ERROR: %0s, line %0d, Invalid data record.", in_file, line_no);
                            $display("Time: %0t  Instance: %m", $time);
                            done = `LPM_TRUE;
                            disable READER;
                        end

                        memory_data1 = (memory_data1 * 16) + value;
                    end
                    else if ((data_radix == "dec"))
                    begin
                        if ((r >= "0") && (r <= "9"))
                            value = (r - 'h30);
                        else
                        begin
                            error_status = `LPM_TRUE;
                            $display("ERROR: %0s, line %0d, Invalid data record.", in_file, line_no);
                            $display("Time: %0t  Instance: %m", $time);
                            done = `LPM_TRUE;
                            disable READER;
                        end

                        memory_data1 = (memory_data1 * 10) + value;
                    end
                    else if (data_radix == "uns")
                    begin
                        if ((r >= "0") && (r <= "9"))
                            value = (r - 'h30);
                        else
                        begin
                            error_status = `LPM_TRUE;
                            $display("ERROR: %0s, line %0d, Invalid data record.", in_file, line_no);
                            $display("Time: %0t  Instance: %m", $time);
                            done = `LPM_TRUE;
                            disable READER;
                        end

                        memory_data1 = (memory_data1 * 10) + value;
                    end
                    else if (data_radix == "bin")
                    begin
                        if ((r >= "0") && (r <= "1"))
                            value = (r - 'h30);
                        else
                        begin
                            error_status = `LPM_TRUE;
                            $display("ERROR: %0s, line %0d, Invalid data record.", in_file, line_no);
                            $display("Time: %0t  Instance: %m", $time);
                            done = `LPM_TRUE;
                            disable READER;
                        end

                        memory_data1 = (memory_data1 * 2) + value;
                    end
                    else if (data_radix == "oct")
                    begin
                        if ((r >= "0") && (r <= "7"))
                            value = (r - 'h30);
                        else
                        begin
                            error_status = `LPM_TRUE;
                            $display("ERROR: %0s, line %0d, Invalid data record.", in_file, line_no);
                            $display("Time: %0t  Instance: %m", $time);
                            done = `LPM_TRUE;
                            disable READER;
                        end

                        memory_data1 = (memory_data1 * 8) + value;
                    end
                end
                else
                begin
                    first_rec = `LPM_TRUE;

                    if ((r >= 65) && (r <= 90))
                        c = tolower(r);
                    else
                        c = r;

                    {tmp_char,buffer} = {buffer, c};
                end
            end
            $fclose(ifp);
            $fclose(ofp);
        end
end
endtask // convert_mif2ver

/****************************************************************/
/* Read in Intel-hex format data to verilog format data.        */
/*  Intel-hex format    :nnaaaaattddddcc                        */
/****************************************************************/
task convert_hex2ver;
    input[`LPM_MAX_NAME_SZ*8 : 1] in_file;
    input width;
    output [`LPM_MAX_NAME_SZ*8 : 1] out_file;
    reg [`LPM_MAX_NAME_SZ*8 : 1] in_file;
    reg [`LPM_MAX_NAME_SZ*8 : 1] out_file;
    reg [8:1] c;
    reg [3:0] hex, tmp_char;
    reg done;
    reg error_status;
    reg first_rec;
    reg last_rec;

    integer width;
    integer ifp, ofp, r, r2;
    integer i, j, k, m, n;

    integer off_addr, nn, aaaa, tt, cc, aah, aal, dd, sum ;
    integer line_no;

begin
        done = `LPM_FALSE;
        error_status = `LPM_FALSE;
        first_rec = `LPM_FALSE;
        last_rec = `LPM_FALSE;

        off_addr= 0;
        nn= 0;
        aaaa= 0;
        tt= 0;
        cc= 0;
        aah= 0;
        aal= 0;
        dd= 0;
        sum = 0;
        line_no = 1;
        c = 0;
        hex = 0;

        if((in_file[4*8 : 1] == ".dat") || (in_file[4*8 : 1] == ".DAT"))
            out_file = in_file;
        else
        begin
            ifp = $fopen(in_file, "r");
            if (ifp == `LPM_NULL)
            begin
                $display("ERROR: cannot read %0s.", in_file);
                $display("Time: %0t  Instance: %m", $time);
                done = `LPM_TRUE;
            end

            out_file = in_file;

            if((out_file[4*8 : 1] == ".hex") || (out_file[4*8 : 1] == ".HEX"))
                out_file[3*8 : 1] = `LPM_EXT_STR;
            else
            begin
                $display("ERROR: Invalid input file name %0s. Expecting file with .hex extension and Intel-hex data format.", in_file);
                $display("Time: %0t  Instance: %m", $time);
                done = `LPM_TRUE;
            end

            if (!done)
            begin
                ofp = $fopen(out_file, "w");
                if (ofp == `LPM_NULL)
                begin
                    $display("ERROR : cannot write %0s.", out_file);
                    $display("Time: %0t  Instance: %m", $time);
                    done = `LPM_TRUE;
                end
            end

            while((!done) && (!error_status))
            begin : READER

                r = $fgetc(ifp);

                if (r == `LPM_EOF)
                begin
                    if(!first_rec)
                    begin
                        error_status = `LPM_TRUE;
                        $display("WARNING: %0s, Intel-hex data file is empty.", in_file);
                        $display ("Time: %0t  Instance: %m", $time);
                    end
                    else if(!last_rec)
                    begin
                        error_status = `LPM_TRUE;
                        $display("ERROR: %0s, line %0d, Missing the last record.", in_file, line_no);
                        $display("Time: %0t  Instance: %m", $time);
                    end
                end
                else if (r == `LPM_COLON)
                begin
                    first_rec = `LPM_TRUE;
                    nn= 0;
                    aaaa= 0;
                    tt= 0;
                    cc= 0;
                    aah= 0;
                    aal= 0;
                    dd= 0;
                    sum = 0;

                    // get record length bytes
                    for (i = 0; i < 2; i = i+1)
                    begin
                        r = $fgetc(ifp);

                        if ((r >= "0") && (r <= "9"))
                            nn = (nn * 16) + (r - 'h30);
                        else if ((r >= "A") && (r <= "F"))
                            nn = (nn * 16) + 10 + (r - 'h41);
                        else if ((r >= "a") && (r <= "f"))
                            nn = (nn * 16) + 10 + (r - 'h61);
                        else
                        begin
                            error_status = `LPM_TRUE;
                            $display("ERROR: %0s, line %0d, Invalid INTEL HEX record.", in_file, line_no);
                            $display("Time: %0t  Instance: %m", $time);
                            done = `LPM_TRUE;
                            disable READER;
                        end
                    end

                    // get address bytes
                    for (i = 0; i < 4; i = i+1)
                    begin
                        r = $fgetc(ifp);

                        if ((r >= "0") && (r <= "9"))
                            hex = (r - 'h30);
                        else if ((r >= "A") && (r <= "F"))
                            hex = 10 + (r - 'h41);
                        else if ((r >= "a") && (r <= "f"))
                            hex = 10 + (r - 'h61);
                        else
                        begin
                            error_status = `LPM_TRUE;
                            $display("ERROR: %0s, line %0d, Invalid INTEL HEX record.", in_file, line_no);
                            $display("Time: %0t  Instance: %m", $time);
                            done = `LPM_TRUE;
                            disable READER;
                        end

                        aaaa = (aaaa * 16) + hex;

                        if (i < 2)
                            aal = (aal * 16) + hex;
                        else
                            aah = (aah * 16) + hex;
                    end

                    // get record type bytes
                    for (i = 0; i < 2; i = i+1)
                    begin
                        r = $fgetc(ifp);

                        if ((r >= "0") && (r <= "9"))
                            tt = (tt * 16) + (r - 'h30);
                        else if ((r >= "A") && (r <= "F"))
                            tt = (tt * 16) + 10 + (r - 'h41);
                        else if ((r >= "a") && (r <= "f"))
                            tt = (tt * 16) + 10 + (r - 'h61);
                        else
                        begin
                            error_status = `LPM_TRUE;
                            $display("ERROR: %0s, line %0d, Invalid INTEL HEX record.", in_file, line_no);
                            $display("Time: %0t  Instance: %m", $time);
                            done = `LPM_TRUE;
                            disable READER;
                        end
                    end

                    if((tt == 2) && (nn != 2) )
                    begin
                        error_status = `LPM_TRUE;
                        $display("ERROR: %0s, line %0d, Invalid data record.", in_file, line_no);
                        $display("Time: %0t  Instance: %m", $time);
                    end
                    else
                    begin

                        // get the sum of all the bytes for record length, address and record types
                        sum = nn + aah + aal + tt ;

                        // check the record type
                        case(tt)
                            // normal_record
                            8'h00 :
                            begin
                                first_rec = `LPM_TRUE;
                                i = 0;
                                k = width / `LPM_AWORD;
                                if ((width % `LPM_AWORD) != 0)
                                    k = k + 1;

                                // k = no. of bytes per entry.
                                while (i < nn)
                                begin
                                    $fdisplay(ofp,"@%0h", (aaaa + off_addr));
                                    for (j = 1; j <= k; j = j +1)
                                    begin
                                        if ((k - j +1) > nn)
                                        begin
                                            for(m = 1; m <= 2; m= m+1)
                                            begin
                                                if((((k-j)*8) + ((3-m)*4) - width) < 4)
                                                    $fwrite(ofp, "0");
                                            end
                                        end
                                        else
                                        begin
                                            // get the data bytes
                                            for(m = 1; m <= 2; m= m+1)
                                            begin
                                                r = $fgetc(ifp);

                                                if ((r >= "0") && (r <= "9"))
                                                    hex = (r - 'h30);
                                                else if ((r >= "A") && (r <= "F"))
                                                    hex = 10 + (r - 'h41);
                                                else if ((r >= "a") && (r <= "f"))
                                                    hex = 10 + (r - 'h61);
                                                else
                                                begin
                                                    error_status = `LPM_TRUE;
                                                    $display("ERROR: %0s, line %0d, Invalid INTEL HEX record.", in_file, line_no);
                                                    $display("Time: %0t  Instance: %m", $time);
                                                    done = `LPM_TRUE;
                                                    disable READER;
                                                end

                                                if((((k-j)*8) + ((3-m)*4) - width) < 4)
                                                    $fwrite(ofp, "%h", hex);
                                                dd = (dd * 16) + hex;

                                                if(m % 2 == 0)
                                                begin
                                                    sum = sum + dd;
                                                    dd = 0;
                                                end
                                            end
                                        end
                                    end
                                    $fwrite(ofp, "\n");

                                    i = i + k;
                                    aaaa = aaaa + 1;
                                end // end of while (i < nn)
                            end
                            // last record
                            8'h01:
                            begin
                                last_rec = `LPM_TRUE;
                                done = `LPM_TRUE;
                            end
                            // address base record
                            8'h02:
                            begin
                                off_addr= 0;

                                // get the extended segment address record
                                for(i = 1; i <= (nn*2); i= i+1)
                                begin
                                    r = $fgetc(ifp);

                                    if ((r >= "0") && (r <= "9"))
                                        hex = (r - 'h30);
                                    else if ((r >= "A") && (r <= "F"))
                                        hex = 10 + (r - 'h41);
                                    else if ((r >= "a") && (r <= "f"))
                                        hex = 10 + (r - 'h61);
                                    else
                                    begin
                                        error_status = `LPM_TRUE;
                                        $display("ERROR: %0s, line %0d, Invalid INTEL HEX record.", in_file, line_no);
                                        $display("Time: %0t  Instance: %m", $time);
                                        done = `LPM_TRUE;
                                        disable READER;
                                    end

                                    off_addr = (off_addr * `LPM_H10) + hex;
                                    dd = (dd * 16) + hex;

                                    if(i % 2 == 0)
                                    begin
                                        sum = sum + dd;
                                        dd = 0;
                                    end
                                end

                                off_addr = off_addr * `LPM_H10;
                            end
                            // address base record
                            8'h03:
                                // get the start segment address record
                                for(i = 1; i <= (nn*2); i= i+1)
                                begin
                                    r = $fgetc(ifp);

                                    if ((r >= "0") && (r <= "9"))
                                        hex = (r - 'h30);
                                    else if ((r >= "A") && (r <= "F"))
                                        hex = 10 + (r - 'h41);
                                    else if ((r >= "a") && (r <= "f"))
                                        hex = 10 + (r - 'h61);
                                    else
                                    begin
                                        error_status = `LPM_TRUE;
                                        $display("ERROR: %0s, line %0d, Invalid INTEL HEX record.", in_file, line_no);
                                        $display("Time: %0t  Instance: %m", $time);
                                        done = `LPM_TRUE;
                                        disable READER;
                                    end
                                    dd = (dd * 16) + hex;

                                    if(i % 2 == 0)
                                    begin
                                        sum = sum + dd;
                                        dd = 0;
                                    end
                                end
                            // address base record
                            8'h04:
                            begin
                                off_addr= 0;

                                // get the extended linear address record
                                for(i = 1; i <= (nn*2); i= i+1)
                                begin
                                    r = $fgetc(ifp);

                                    if ((r >= "0") && (r <= "9"))
                                        hex = (r - 'h30);
                                    else if ((r >= "A") && (r <= "F"))
                                        hex = 10 + (r - 'h41);
                                    else if ((r >= "a") && (r <= "f"))
                                        hex = 10 + (r - 'h61);
                                    else
                                    begin
                                        error_status = `LPM_TRUE;
                                        $display("ERROR: %0s, line %0d, Invalid INTEL HEX record.", in_file, line_no);
                                        $display("Time: %0t  Instance: %m", $time);
                                        done = `LPM_TRUE;
                                        disable READER;
                                    end

                                    off_addr = (off_addr * `LPM_H10) + hex;
                                    dd = (dd * 16) + hex;

                                    if(i % 2 == 0)
                                    begin
                                        sum = sum + dd;
                                        dd = 0;
                                    end
                                end

                                off_addr = off_addr * `LPM_H10000;
                            end
                            // address base record
                            8'h05:
                                // get the start linear address record
                                for(i = 1; i <= (nn*2); i= i+1)
                                begin
                                    r = $fgetc(ifp);

                                    if ((r >= "0") && (r <= "9"))
                                        hex = (r - 'h30);
                                    else if ((r >= "A") && (r <= "F"))
                                        hex = 10 + (r - 'h41);
                                    else if ((r >= "a") && (r <= "f"))
                                        hex = 10 + (r - 'h61);
                                    else
                                    begin
                                        error_status = `LPM_TRUE;
                                        $display("ERROR: %0s, line %0d, Invalid INTEL HEX record.", in_file, line_no);
                                        $display("Time: %0t  Instance: %m", $time);
                                        done = `LPM_TRUE;
                                        disable READER;
                                    end
                                    dd = (dd * 16) + hex;

                                    if(i % 2 == 0)
                                    begin
                                        sum = sum + dd;
                                        dd = 0;
                                    end
                                end
                            default:
                            begin
                                error_status = `LPM_TRUE;
                                $display("ERROR: %0s, line %0d, Unknown record type.", in_file, line_no);
                                $display("Time: %0t  Instance: %m", $time);
                            end
                        endcase

                        // get the checksum bytes
                        for (i = 0; i < 2; i = i+1)
                        begin
                            r = $fgetc(ifp);

                            if ((r >= "0") && (r <= "9"))
                                cc = (cc * 16) + (r - 'h30);
                            else if ((r >= "A") && (r <= "F"))
                                cc = 10 + (cc * 16) + (r - 'h41);
                            else if ((r >= "a") && (r <= "f"))
                                cc = 10 + (cc * 16) + (r - 'h61);
                            else
                            begin
                                error_status = `LPM_TRUE;
                                $display("ERROR: %0s, line %0d, Invalid INTEL HEX record.", in_file, line_no);
                                $display("Time: %0t  Instance: %m", $time);
                                done = `LPM_TRUE;
                                disable READER;
                            end
                        end

                        // Perform check sum.
                        if(((~sum+1)& `LPM_MASK15) != cc)
                        begin
                            error_status = `LPM_TRUE;
                            $display("ERROR: %0s, line %0d, Invalid checksum.", in_file, line_no);
                            $display("Time: %0t  Instance: %m", $time);
                        end
                    end
                end
                else if ((r == `LPM_NEWLINE) || (r == `LPM_CARRIAGE_RETURN))
                begin
                    line_no = line_no +1;
                end
                else if (r == `LPM_SPACE)
                begin
                    // continue to next character;
                end
                else
                begin
                    error_status = `LPM_TRUE;
                    $display("ERROR:%0s, line %0d, Invalid INTEL HEX record.", in_file, line_no);
                    $display("Time: %0t  Instance: %m", $time);
                    done = `LPM_TRUE;
                end
            end
            $fclose(ifp);
            $fclose(ofp);
        end
end
endtask // convert_hex2ver

task convert_to_ver_file;
    input[`LPM_MAX_NAME_SZ*8 : 1] in_file;
    input width;
    output [`LPM_MAX_NAME_SZ*8 : 1] out_file;
    reg [`LPM_MAX_NAME_SZ*8 : 1] in_file;
    reg [`LPM_MAX_NAME_SZ*8 : 1] out_file;
    integer width;
begin

        if((in_file[4*8 : 1] == ".hex") || (in_file[4*8 : 1] == ".HEX") ||
            (in_file[4*8 : 1] == ".dat") || (in_file[4*8 : 1] == ".DAT"))
            convert_hex2ver(in_file, width, out_file);
        else if((in_file[4*8 : 1] == ".mif") || (in_file[4*8 : 1] == ".MIF"))
            convert_mif2ver(in_file, width, out_file);
        else
        begin
            $display("ERROR: Invalid input file name %0s. Expecting file with .hex extension (with Intel-hex data format) or .mif extension (with Altera-mif data format).", in_file);
            $display("Time: %0t  Instance: %m", $time);
        end
end
endtask // convert_to_ver_file

endmodule // LPM_MEMORY_INITIALIZATION

