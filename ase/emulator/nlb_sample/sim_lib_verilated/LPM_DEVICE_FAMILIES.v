// Created by altera_lib_lpm.pl from 220model.v

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
module LPM_DEVICE_FAMILIES;

function IS_FAMILY_CYCLONE;
    input[8*20:1] device;
    reg is_cyclone;
begin
    if ((device == "Cyclone") || (device == "CYCLONE") || (device == "cyclone") || (device == "ACEX2K") || (device == "acex2k") || (device == "ACEX 2K") || (device == "acex 2k") || (device == "Tornado") || (device == "TORNADO") || (device == "tornado"))
        is_cyclone = 1;
    else
        is_cyclone = 0;

    IS_FAMILY_CYCLONE  = is_cyclone;
end
endfunction //IS_FAMILY_CYCLONE

function IS_FAMILY_MAX3000A;
    input[8*20:1] device;
    reg is_max3000a;
begin
    if ((device == "MAX3000A") || (device == "max3000a") || (device == "MAX 3000A") || (device == "max 3000a"))
        is_max3000a = 1;
    else
        is_max3000a = 0;

    IS_FAMILY_MAX3000A  = is_max3000a;
end
endfunction //IS_FAMILY_MAX3000A

function IS_FAMILY_MAX7000A;
    input[8*20:1] device;
    reg is_max7000a;
begin
    if ((device == "MAX7000A") || (device == "max7000a") || (device == "MAX 7000A") || (device == "max 7000a"))
        is_max7000a = 1;
    else
        is_max7000a = 0;

    IS_FAMILY_MAX7000A  = is_max7000a;
end
endfunction //IS_FAMILY_MAX7000A

function IS_FAMILY_MAX7000AE;
    input[8*20:1] device;
    reg is_max7000ae;
begin
    if ((device == "MAX7000AE") || (device == "max7000ae") || (device == "MAX 7000AE") || (device == "max 7000ae"))
        is_max7000ae = 1;
    else
        is_max7000ae = 0;

    IS_FAMILY_MAX7000AE  = is_max7000ae;
end
endfunction //IS_FAMILY_MAX7000AE

function IS_FAMILY_MAX7000B;
    input[8*20:1] device;
    reg is_max7000b;
begin
    if ((device == "MAX7000B") || (device == "max7000b") || (device == "MAX 7000B") || (device == "max 7000b"))
        is_max7000b = 1;
    else
        is_max7000b = 0;

    IS_FAMILY_MAX7000B  = is_max7000b;
end
endfunction //IS_FAMILY_MAX7000B

function IS_FAMILY_MAX7000S;
    input[8*20:1] device;
    reg is_max7000s;
begin
    if ((device == "MAX7000S") || (device == "max7000s") || (device == "MAX 7000S") || (device == "max 7000s"))
        is_max7000s = 1;
    else
        is_max7000s = 0;

    IS_FAMILY_MAX7000S  = is_max7000s;
end
endfunction //IS_FAMILY_MAX7000S

function IS_FAMILY_STRATIXGX;
    input[8*20:1] device;
    reg is_stratixgx;
begin
    if ((device == "Stratix GX") || (device == "STRATIX GX") || (device == "stratix gx") || (device == "Stratix-GX") || (device == "STRATIX-GX") || (device == "stratix-gx") || (device == "StratixGX") || (device == "STRATIXGX") || (device == "stratixgx") || (device == "Aurora") || (device == "AURORA") || (device == "aurora"))
        is_stratixgx = 1;
    else
        is_stratixgx = 0;

    IS_FAMILY_STRATIXGX  = is_stratixgx;
end
endfunction //IS_FAMILY_STRATIXGX

function IS_FAMILY_STRATIX;
    input[8*20:1] device;
    reg is_stratix;
begin
    if ((device == "Stratix") || (device == "STRATIX") || (device == "stratix") || (device == "Yeager") || (device == "YEAGER") || (device == "yeager"))
        is_stratix = 1;
    else
        is_stratix = 0;

    IS_FAMILY_STRATIX  = is_stratix;
end
endfunction //IS_FAMILY_STRATIX

function FEATURE_FAMILY_BASE_STRATIX;
    input[8*20:1] device;
    reg var_family_base_stratix;
begin
    if (IS_FAMILY_STRATIX(device) || IS_FAMILY_STRATIXGX(device) )
        var_family_base_stratix = 1;
    else
        var_family_base_stratix = 0;

    FEATURE_FAMILY_BASE_STRATIX  = var_family_base_stratix;
end
endfunction //FEATURE_FAMILY_BASE_STRATIX

function FEATURE_FAMILY_BASE_CYCLONE;
    input[8*20:1] device;
    reg var_family_base_cyclone;
begin
    if (IS_FAMILY_CYCLONE(device) )
        var_family_base_cyclone = 1;
    else
        var_family_base_cyclone = 0;

    FEATURE_FAMILY_BASE_CYCLONE  = var_family_base_cyclone;
end
endfunction //FEATURE_FAMILY_BASE_CYCLONE

function FEATURE_FAMILY_MAX;
    input[8*20:1] device;
    reg var_family_max;
begin
    if ((device == "MAX5000") || IS_FAMILY_MAX3000A(device) || (device == "MAX7000") || IS_FAMILY_MAX7000A(device) || IS_FAMILY_MAX7000AE(device) || (device == "MAX7000E") || IS_FAMILY_MAX7000S(device) || IS_FAMILY_MAX7000B(device) || (device == "MAX9000") )
        var_family_max = 1;
    else
        var_family_max = 0;

    FEATURE_FAMILY_MAX  = var_family_max;
end
endfunction //FEATURE_FAMILY_MAX

function IS_VALID_FAMILY;
    input[8*20:1] device;
    reg is_valid;
begin
    if (((device == "Arria 10") || (device == "ARRIA 10") || (device == "arria 10") || (device == "Arria10") || (device == "ARRIA10") || (device == "arria10") || (device == "Arria VI") || (device == "ARRIA VI") || (device == "arria vi") || (device == "ArriaVI") || (device == "ARRIAVI") || (device == "arriavi") || (device == "Night Fury") || (device == "NIGHT FURY") || (device == "night fury") || (device == "nightfury") || (device == "NIGHTFURY") || (device == "Arria 10 (GX/SX/GT)") || (device == "ARRIA 10 (GX/SX/GT)") || (device == "arria 10 (gx/sx/gt)") || (device == "Arria10(GX/SX/GT)") || (device == "ARRIA10(GX/SX/GT)") || (device == "arria10(gx/sx/gt)") || (device == "Arria 10 (GX)") || (device == "ARRIA 10 (GX)") || (device == "arria 10 (gx)") || (device == "Arria10(GX)") || (device == "ARRIA10(GX)") || (device == "arria10(gx)") || (device == "Arria 10 (SX)") || (device == "ARRIA 10 (SX)") || (device == "arria 10 (sx)") || (device == "Arria10(SX)") || (device == "ARRIA10(SX)") || (device == "arria10(sx)") || (device == "Arria 10 (GT)") || (device == "ARRIA 10 (GT)") || (device == "arria 10 (gt)") || (device == "Arria10(GT)") || (device == "ARRIA10(GT)") || (device == "arria10(gt)"))
    || ((device == "Arria GX") || (device == "ARRIA GX") || (device == "arria gx") || (device == "ArriaGX") || (device == "ARRIAGX") || (device == "arriagx") || (device == "Stratix II GX Lite") || (device == "STRATIX II GX LITE") || (device == "stratix ii gx lite") || (device == "StratixIIGXLite") || (device == "STRATIXIIGXLITE") || (device == "stratixiigxlite"))
    || ((device == "Arria II GX") || (device == "ARRIA II GX") || (device == "arria ii gx") || (device == "ArriaIIGX") || (device == "ARRIAIIGX") || (device == "arriaiigx") || (device == "Arria IIGX") || (device == "ARRIA IIGX") || (device == "arria iigx") || (device == "ArriaII GX") || (device == "ARRIAII GX") || (device == "arriaii gx") || (device == "Arria II") || (device == "ARRIA II") || (device == "arria ii") || (device == "ArriaII") || (device == "ARRIAII") || (device == "arriaii") || (device == "Arria II (GX/E)") || (device == "ARRIA II (GX/E)") || (device == "arria ii (gx/e)") || (device == "ArriaII(GX/E)") || (device == "ARRIAII(GX/E)") || (device == "arriaii(gx/e)") || (device == "PIRANHA") || (device == "piranha"))
    || ((device == "Arria II GZ") || (device == "ARRIA II GZ") || (device == "arria ii gz") || (device == "ArriaII GZ") || (device == "ARRIAII GZ") || (device == "arriaii gz") || (device == "Arria IIGZ") || (device == "ARRIA IIGZ") || (device == "arria iigz") || (device == "ArriaIIGZ") || (device == "ARRIAIIGZ") || (device == "arriaiigz"))
    || ((device == "Arria V GZ") || (device == "ARRIA V GZ") || (device == "arria v gz") || (device == "ArriaVGZ") || (device == "ARRIAVGZ") || (device == "arriavgz"))
    || ((device == "Arria V") || (device == "ARRIA V") || (device == "arria v") || (device == "Arria V (GT/GX)") || (device == "ARRIA V (GT/GX)") || (device == "arria v (gt/gx)") || (device == "ArriaV(GT/GX)") || (device == "ARRIAV(GT/GX)") || (device == "arriav(gt/gx)") || (device == "ArriaV") || (device == "ARRIAV") || (device == "arriav") || (device == "Arria V (GT/GX/ST/SX)") || (device == "ARRIA V (GT/GX/ST/SX)") || (device == "arria v (gt/gx/st/sx)") || (device == "ArriaV(GT/GX/ST/SX)") || (device == "ARRIAV(GT/GX/ST/SX)") || (device == "arriav(gt/gx/st/sx)") || (device == "Arria V (GT)") || (device == "ARRIA V (GT)") || (device == "arria v (gt)") || (device == "ArriaV(GT)") || (device == "ARRIAV(GT)") || (device == "arriav(gt)") || (device == "Arria V (GX)") || (device == "ARRIA V (GX)") || (device == "arria v (gx)") || (device == "ArriaV(GX)") || (device == "ARRIAV(GX)") || (device == "arriav(gx)") || (device == "Arria V (ST)") || (device == "ARRIA V (ST)") || (device == "arria v (st)") || (device == "ArriaV(ST)") || (device == "ARRIAV(ST)") || (device == "arriav(st)") || (device == "Arria V (SX)") || (device == "ARRIA V (SX)") || (device == "arria v (sx)") || (device == "ArriaV(SX)") || (device == "ARRIAV(SX)") || (device == "arriav(sx)"))
    || ((device == "BS") || (device == "bs"))
    || ((device == "Cyclone II") || (device == "CYCLONE II") || (device == "cyclone ii") || (device == "Cycloneii") || (device == "CYCLONEII") || (device == "cycloneii") || (device == "Magellan") || (device == "MAGELLAN") || (device == "magellan") || (device == "CycloneII") || (device == "CYCLONEII") || (device == "cycloneii"))
    || ((device == "Cyclone III LS") || (device == "CYCLONE III LS") || (device == "cyclone iii ls") || (device == "CycloneIIILS") || (device == "CYCLONEIIILS") || (device == "cycloneiiils") || (device == "Cyclone III LPS") || (device == "CYCLONE III LPS") || (device == "cyclone iii lps") || (device == "Cyclone LPS") || (device == "CYCLONE LPS") || (device == "cyclone lps") || (device == "CycloneLPS") || (device == "CYCLONELPS") || (device == "cyclonelps") || (device == "Tarpon") || (device == "TARPON") || (device == "tarpon") || (device == "Cyclone IIIE") || (device == "CYCLONE IIIE") || (device == "cyclone iiie"))
    || ((device == "Cyclone III") || (device == "CYCLONE III") || (device == "cyclone iii") || (device == "CycloneIII") || (device == "CYCLONEIII") || (device == "cycloneiii") || (device == "Barracuda") || (device == "BARRACUDA") || (device == "barracuda") || (device == "Cuda") || (device == "CUDA") || (device == "cuda") || (device == "CIII") || (device == "ciii"))
    || ((device == "Cyclone IV E") || (device == "CYCLONE IV E") || (device == "cyclone iv e") || (device == "CycloneIV E") || (device == "CYCLONEIV E") || (device == "cycloneiv e") || (device == "Cyclone IVE") || (device == "CYCLONE IVE") || (device == "cyclone ive") || (device == "CycloneIVE") || (device == "CYCLONEIVE") || (device == "cycloneive"))
    || ((device == "Cyclone IV GX") || (device == "CYCLONE IV GX") || (device == "cyclone iv gx") || (device == "Cyclone IVGX") || (device == "CYCLONE IVGX") || (device == "cyclone ivgx") || (device == "CycloneIV GX") || (device == "CYCLONEIV GX") || (device == "cycloneiv gx") || (device == "CycloneIVGX") || (device == "CYCLONEIVGX") || (device == "cycloneivgx") || (device == "Cyclone IV") || (device == "CYCLONE IV") || (device == "cyclone iv") || (device == "CycloneIV") || (device == "CYCLONEIV") || (device == "cycloneiv") || (device == "Cyclone IV (GX)") || (device == "CYCLONE IV (GX)") || (device == "cyclone iv (gx)") || (device == "CycloneIV(GX)") || (device == "CYCLONEIV(GX)") || (device == "cycloneiv(gx)") || (device == "Cyclone III GX") || (device == "CYCLONE III GX") || (device == "cyclone iii gx") || (device == "CycloneIII GX") || (device == "CYCLONEIII GX") || (device == "cycloneiii gx") || (device == "Cyclone IIIGX") || (device == "CYCLONE IIIGX") || (device == "cyclone iiigx") || (device == "CycloneIIIGX") || (device == "CYCLONEIIIGX") || (device == "cycloneiiigx") || (device == "Cyclone III GL") || (device == "CYCLONE III GL") || (device == "cyclone iii gl") || (device == "CycloneIII GL") || (device == "CYCLONEIII GL") || (device == "cycloneiii gl") || (device == "Cyclone IIIGL") || (device == "CYCLONE IIIGL") || (device == "cyclone iiigl") || (device == "CycloneIIIGL") || (device == "CYCLONEIIIGL") || (device == "cycloneiiigl") || (device == "Stingray") || (device == "STINGRAY") || (device == "stingray"))
    || ((device == "Cyclone V") || (device == "CYCLONE V") || (device == "cyclone v") || (device == "CycloneV") || (device == "CYCLONEV") || (device == "cyclonev") || (device == "Cyclone V (GT/GX/E/SX)") || (device == "CYCLONE V (GT/GX/E/SX)") || (device == "cyclone v (gt/gx/e/sx)") || (device == "CycloneV(GT/GX/E/SX)") || (device == "CYCLONEV(GT/GX/E/SX)") || (device == "cyclonev(gt/gx/e/sx)") || (device == "Cyclone V (E/GX/GT/SX/SE/ST)") || (device == "CYCLONE V (E/GX/GT/SX/SE/ST)") || (device == "cyclone v (e/gx/gt/sx/se/st)") || (device == "CycloneV(E/GX/GT/SX/SE/ST)") || (device == "CYCLONEV(E/GX/GT/SX/SE/ST)") || (device == "cyclonev(e/gx/gt/sx/se/st)") || (device == "Cyclone V (E)") || (device == "CYCLONE V (E)") || (device == "cyclone v (e)") || (device == "CycloneV(E)") || (device == "CYCLONEV(E)") || (device == "cyclonev(e)") || (device == "Cyclone V (GX)") || (device == "CYCLONE V (GX)") || (device == "cyclone v (gx)") || (device == "CycloneV(GX)") || (device == "CYCLONEV(GX)") || (device == "cyclonev(gx)") || (device == "Cyclone V (GT)") || (device == "CYCLONE V (GT)") || (device == "cyclone v (gt)") || (device == "CycloneV(GT)") || (device == "CYCLONEV(GT)") || (device == "cyclonev(gt)") || (device == "Cyclone V (SX)") || (device == "CYCLONE V (SX)") || (device == "cyclone v (sx)") || (device == "CycloneV(SX)") || (device == "CYCLONEV(SX)") || (device == "cyclonev(sx)") || (device == "Cyclone V (SE)") || (device == "CYCLONE V (SE)") || (device == "cyclone v (se)") || (device == "CycloneV(SE)") || (device == "CYCLONEV(SE)") || (device == "cyclonev(se)") || (device == "Cyclone V (ST)") || (device == "CYCLONE V (ST)") || (device == "cyclone v (st)") || (device == "CycloneV(ST)") || (device == "CYCLONEV(ST)") || (device == "cyclonev(st)"))
    || ((device == "Cyclone") || (device == "CYCLONE") || (device == "cyclone") || (device == "ACEX2K") || (device == "acex2k") || (device == "ACEX 2K") || (device == "acex 2k") || (device == "Tornado") || (device == "TORNADO") || (device == "tornado"))
    || ((device == "HardCopy II") || (device == "HARDCOPY II") || (device == "hardcopy ii") || (device == "HardCopyII") || (device == "HARDCOPYII") || (device == "hardcopyii") || (device == "Fusion") || (device == "FUSION") || (device == "fusion"))
    || ((device == "HardCopy III") || (device == "HARDCOPY III") || (device == "hardcopy iii") || (device == "HardCopyIII") || (device == "HARDCOPYIII") || (device == "hardcopyiii") || (device == "HCX") || (device == "hcx"))
    || ((device == "HardCopy IV") || (device == "HARDCOPY IV") || (device == "hardcopy iv") || (device == "HardCopyIV") || (device == "HARDCOPYIV") || (device == "hardcopyiv") || (device == "HardCopy IV (GX)") || (device == "HARDCOPY IV (GX)") || (device == "hardcopy iv (gx)") || (device == "HardCopy IV (E)") || (device == "HARDCOPY IV (E)") || (device == "hardcopy iv (e)") || (device == "HardCopyIV(GX)") || (device == "HARDCOPYIV(GX)") || (device == "hardcopyiv(gx)") || (device == "HardCopyIV(E)") || (device == "HARDCOPYIV(E)") || (device == "hardcopyiv(e)") || (device == "HCXIV") || (device == "hcxiv") || (device == "HardCopy IV (GX/E)") || (device == "HARDCOPY IV (GX/E)") || (device == "hardcopy iv (gx/e)") || (device == "HardCopy IV (E/GX)") || (device == "HARDCOPY IV (E/GX)") || (device == "hardcopy iv (e/gx)") || (device == "HardCopyIV(GX/E)") || (device == "HARDCOPYIV(GX/E)") || (device == "hardcopyiv(gx/e)") || (device == "HardCopyIV(E/GX)") || (device == "HARDCOPYIV(E/GX)") || (device == "hardcopyiv(e/gx)"))
    || ((device == "MAX 10") || (device == "max 10") || (device == "MAX 10 FPGA") || (device == "max 10 fpga") || (device == "Zippleback") || (device == "ZIPPLEBACK") || (device == "zippleback") || (device == "MAX10") || (device == "max10") || (device == "MAX 10 (DA/DF/DC/SA/SC)") || (device == "max 10 (da/df/dc/sa/sc)") || (device == "MAX10(DA/DF/DC/SA/SC)") || (device == "max10(da/df/dc/sa/sc)") || (device == "MAX 10 (DA)") || (device == "max 10 (da)") || (device == "MAX10(DA)") || (device == "max10(da)") || (device == "MAX 10 (DF)") || (device == "max 10 (df)") || (device == "MAX10(DF)") || (device == "max10(df)") || (device == "MAX 10 (DC)") || (device == "max 10 (dc)") || (device == "MAX10(DC)") || (device == "max10(dc)") || (device == "MAX 10 (SA)") || (device == "max 10 (sa)") || (device == "MAX10(SA)") || (device == "max10(sa)") || (device == "MAX 10 (SC)") || (device == "max 10 (sc)") || (device == "MAX10(SC)") || (device == "max10(sc)"))
    || ((device == "MAX II") || (device == "max ii") || (device == "MAXII") || (device == "maxii") || (device == "Tsunami") || (device == "TSUNAMI") || (device == "tsunami"))
    || ((device == "MAX V") || (device == "max v") || (device == "MAXV") || (device == "maxv") || (device == "Jade") || (device == "JADE") || (device == "jade"))
    || ((device == "MAX3000A") || (device == "max3000a") || (device == "MAX 3000A") || (device == "max 3000a"))
    || ((device == "MAX7000A") || (device == "max7000a") || (device == "MAX 7000A") || (device == "max 7000a"))
    || ((device == "MAX7000AE") || (device == "max7000ae") || (device == "MAX 7000AE") || (device == "max 7000ae"))
    || ((device == "MAX7000B") || (device == "max7000b") || (device == "MAX 7000B") || (device == "max 7000b"))
    || ((device == "MAX7000S") || (device == "max7000s") || (device == "MAX 7000S") || (device == "max 7000s"))
    || ((device == "Stratix 10") || (device == "STRATIX 10") || (device == "stratix 10") || (device == "Stratix10") || (device == "STRATIX10") || (device == "stratix10") || (device == "nadder") || (device == "NADDER") || (device == "Stratix 10 (GX/SX)") || (device == "STRATIX 10 (GX/SX)") || (device == "stratix 10 (gx/sx)") || (device == "Stratix10(GX/SX)") || (device == "STRATIX10(GX/SX)") || (device == "stratix10(gx/sx)") || (device == "Stratix 10 (GX)") || (device == "STRATIX 10 (GX)") || (device == "stratix 10 (gx)") || (device == "Stratix10(GX)") || (device == "STRATIX10(GX)") || (device == "stratix10(gx)") || (device == "Stratix 10 (SX)") || (device == "STRATIX 10 (SX)") || (device == "stratix 10 (sx)") || (device == "Stratix10(SX)") || (device == "STRATIX10(SX)") || (device == "stratix10(sx)"))
    || ((device == "Stratix GX") || (device == "STRATIX GX") || (device == "stratix gx") || (device == "Stratix-GX") || (device == "STRATIX-GX") || (device == "stratix-gx") || (device == "StratixGX") || (device == "STRATIXGX") || (device == "stratixgx") || (device == "Aurora") || (device == "AURORA") || (device == "aurora"))
    || ((device == "Stratix II GX") || (device == "STRATIX II GX") || (device == "stratix ii gx") || (device == "StratixIIGX") || (device == "STRATIXIIGX") || (device == "stratixiigx"))
    || ((device == "Stratix II") || (device == "STRATIX II") || (device == "stratix ii") || (device == "StratixII") || (device == "STRATIXII") || (device == "stratixii") || (device == "Armstrong") || (device == "ARMSTRONG") || (device == "armstrong"))
    || ((device == "Stratix III") || (device == "STRATIX III") || (device == "stratix iii") || (device == "StratixIII") || (device == "STRATIXIII") || (device == "stratixiii") || (device == "Titan") || (device == "TITAN") || (device == "titan") || (device == "SIII") || (device == "siii"))
    || ((device == "Stratix IV") || (device == "STRATIX IV") || (device == "stratix iv") || (device == "TGX") || (device == "tgx") || (device == "StratixIV") || (device == "STRATIXIV") || (device == "stratixiv") || (device == "Stratix IV (GT)") || (device == "STRATIX IV (GT)") || (device == "stratix iv (gt)") || (device == "Stratix IV (GX)") || (device == "STRATIX IV (GX)") || (device == "stratix iv (gx)") || (device == "Stratix IV (E)") || (device == "STRATIX IV (E)") || (device == "stratix iv (e)") || (device == "StratixIV(GT)") || (device == "STRATIXIV(GT)") || (device == "stratixiv(gt)") || (device == "StratixIV(GX)") || (device == "STRATIXIV(GX)") || (device == "stratixiv(gx)") || (device == "StratixIV(E)") || (device == "STRATIXIV(E)") || (device == "stratixiv(e)") || (device == "StratixIIIGX") || (device == "STRATIXIIIGX") || (device == "stratixiiigx") || (device == "Stratix IV (GT/GX/E)") || (device == "STRATIX IV (GT/GX/E)") || (device == "stratix iv (gt/gx/e)") || (device == "Stratix IV (GT/E/GX)") || (device == "STRATIX IV (GT/E/GX)") || (device == "stratix iv (gt/e/gx)") || (device == "Stratix IV (E/GT/GX)") || (device == "STRATIX IV (E/GT/GX)") || (device == "stratix iv (e/gt/gx)") || (device == "Stratix IV (E/GX/GT)") || (device == "STRATIX IV (E/GX/GT)") || (device == "stratix iv (e/gx/gt)") || (device == "StratixIV(GT/GX/E)") || (device == "STRATIXIV(GT/GX/E)") || (device == "stratixiv(gt/gx/e)") || (device == "StratixIV(GT/E/GX)") || (device == "STRATIXIV(GT/E/GX)") || (device == "stratixiv(gt/e/gx)") || (device == "StratixIV(E/GX/GT)") || (device == "STRATIXIV(E/GX/GT)") || (device == "stratixiv(e/gx/gt)") || (device == "StratixIV(E/GT/GX)") || (device == "STRATIXIV(E/GT/GX)") || (device == "stratixiv(e/gt/gx)") || (device == "Stratix IV (GX/E)") || (device == "STRATIX IV (GX/E)") || (device == "stratix iv (gx/e)") || (device == "StratixIV(GX/E)") || (device == "STRATIXIV(GX/E)") || (device == "stratixiv(gx/e)"))
    || ((device == "Stratix V") || (device == "STRATIX V") || (device == "stratix v") || (device == "StratixV") || (device == "STRATIXV") || (device == "stratixv") || (device == "Stratix V (GS)") || (device == "STRATIX V (GS)") || (device == "stratix v (gs)") || (device == "StratixV(GS)") || (device == "STRATIXV(GS)") || (device == "stratixv(gs)") || (device == "Stratix V (GT)") || (device == "STRATIX V (GT)") || (device == "stratix v (gt)") || (device == "StratixV(GT)") || (device == "STRATIXV(GT)") || (device == "stratixv(gt)") || (device == "Stratix V (GX)") || (device == "STRATIX V (GX)") || (device == "stratix v (gx)") || (device == "StratixV(GX)") || (device == "STRATIXV(GX)") || (device == "stratixv(gx)") || (device == "Stratix V (GS/GX)") || (device == "STRATIX V (GS/GX)") || (device == "stratix v (gs/gx)") || (device == "StratixV(GS/GX)") || (device == "STRATIXV(GS/GX)") || (device == "stratixv(gs/gx)") || (device == "Stratix V (GS/GT)") || (device == "STRATIX V (GS/GT)") || (device == "stratix v (gs/gt)") || (device == "StratixV(GS/GT)") || (device == "STRATIXV(GS/GT)") || (device == "stratixv(gs/gt)") || (device == "Stratix V (GT/GX)") || (device == "STRATIX V (GT/GX)") || (device == "stratix v (gt/gx)") || (device == "StratixV(GT/GX)") || (device == "STRATIXV(GT/GX)") || (device == "stratixv(gt/gx)") || (device == "Stratix V (GX/GS)") || (device == "STRATIX V (GX/GS)") || (device == "stratix v (gx/gs)") || (device == "StratixV(GX/GS)") || (device == "STRATIXV(GX/GS)") || (device == "stratixv(gx/gs)") || (device == "Stratix V (GT/GS)") || (device == "STRATIX V (GT/GS)") || (device == "stratix v (gt/gs)") || (device == "StratixV(GT/GS)") || (device == "STRATIXV(GT/GS)") || (device == "stratixv(gt/gs)") || (device == "Stratix V (GX/GT)") || (device == "STRATIX V (GX/GT)") || (device == "stratix v (gx/gt)") || (device == "StratixV(GX/GT)") || (device == "STRATIXV(GX/GT)") || (device == "stratixv(gx/gt)") || (device == "Stratix V (GS/GT/GX)") || (device == "STRATIX V (GS/GT/GX)") || (device == "stratix v (gs/gt/gx)") || (device == "Stratix V (GS/GX/GT)") || (device == "STRATIX V (GS/GX/GT)") || (device == "stratix v (gs/gx/gt)") || (device == "Stratix V (GT/GS/GX)") || (device == "STRATIX V (GT/GS/GX)") || (device == "stratix v (gt/gs/gx)") || (device == "Stratix V (GT/GX/GS)") || (device == "STRATIX V (GT/GX/GS)") || (device == "stratix v (gt/gx/gs)") || (device == "Stratix V (GX/GS/GT)") || (device == "STRATIX V (GX/GS/GT)") || (device == "stratix v (gx/gs/gt)") || (device == "Stratix V (GX/GT/GS)") || (device == "STRATIX V (GX/GT/GS)") || (device == "stratix v (gx/gt/gs)") || (device == "StratixV(GS/GT/GX)") || (device == "STRATIXV(GS/GT/GX)") || (device == "stratixv(gs/gt/gx)") || (device == "StratixV(GS/GX/GT)") || (device == "STRATIXV(GS/GX/GT)") || (device == "stratixv(gs/gx/gt)") || (device == "StratixV(GT/GS/GX)") || (device == "STRATIXV(GT/GS/GX)") || (device == "stratixv(gt/gs/gx)") || (device == "StratixV(GT/GX/GS)") || (device == "STRATIXV(GT/GX/GS)") || (device == "stratixv(gt/gx/gs)") || (device == "StratixV(GX/GS/GT)") || (device == "STRATIXV(GX/GS/GT)") || (device == "stratixv(gx/gs/gt)") || (device == "StratixV(GX/GT/GS)") || (device == "STRATIXV(GX/GT/GS)") || (device == "stratixv(gx/gt/gs)") || (device == "Stratix V (GS/GT/GX/E)") || (device == "STRATIX V (GS/GT/GX/E)") || (device == "stratix v (gs/gt/gx/e)") || (device == "StratixV(GS/GT/GX/E)") || (device == "STRATIXV(GS/GT/GX/E)") || (device == "stratixv(gs/gt/gx/e)") || (device == "Stratix V (E)") || (device == "STRATIX V (E)") || (device == "stratix v (e)") || (device == "StratixV(E)") || (device == "STRATIXV(E)") || (device == "stratixv(e)"))
    || ((device == "Stratix") || (device == "STRATIX") || (device == "stratix") || (device == "Yeager") || (device == "YEAGER") || (device == "yeager"))
    || ((device == "eFPGA 28 HPM") || (device == "EFPGA 28 HPM") || (device == "efpga 28 hpm") || (device == "eFPGA28HPM") || (device == "EFPGA28HPM") || (device == "efpga28hpm") || (device == "Bedrock") || (device == "BEDROCK") || (device == "bedrock")))
        is_valid = 1;
    else
        is_valid = 0;

    IS_VALID_FAMILY = is_valid;
end
endfunction // IS_VALID_FAMILY


endmodule // LPM_DEVICE_FAMILIES

