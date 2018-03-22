// Created by altera_lib_mf.pl from altera_mf.v
// END OF MODULE

// START MODULE NAME -----------------------------------------------------------
//
// Module Name      : ALTCLKLOCK
//
// Description      : Phase-Locked Loop (PLL) behavioral model. Supports basic
//                    PLL features such as multiplication and division of input
//                    clock frequency and phase shift.
//
// Limitations      : Model supports NORMAL operation mode only. External
//                    feedback mode and zero-delay-buffer mode are not simulated.
//
// Expected results : Up to 4 clock outputs (clock0, clock1, clock2, clock_ext).
//                    locked output indicates when PLL locks.
//
//END MODULE NAME --------------------------------------------------------------

`timescale 1 ps / 1 ps

// MODULE DECLARATION
/*verilator lint_off CASEX*/
/*verilator lint_off COMBDLY*/
/*verilator lint_off INITIALDLY*/
/*verilator lint_off LITENDIAN*/
/*verilator lint_off MULTIDRIVEN*/
/*verilator lint_off UNOPTFLAT*/
/*verilator lint_off BLKANDNBLK*/
module altclklock (
    inclock,     // input reference clock
    inclocken,   // PLL enable signal
    fbin,        // feedback input for the PLL
    clock0,      // output clock 0
    clock1,      // output clock 1
    clock2,      // output clock 2
    clock_ext,   // external output clock
    locked       // PLL lock signal
);

// GLOBAL PARAMETER DECLARATION
parameter inclock_period = 10000;  // units in ps
parameter inclock_settings = "UNUSED";
parameter valid_lock_cycles = 5;
parameter invalid_lock_cycles = 5;
parameter valid_lock_multiplier = 5;
parameter invalid_lock_multiplier = 5;
parameter operation_mode = "NORMAL";
parameter clock0_boost = 1;
parameter clock0_divide = 1;
parameter clock0_settings = "UNUSED";
parameter clock0_time_delay = "0";
parameter clock1_boost = 1;
parameter clock1_divide = 1;
parameter clock1_settings = "UNUSED";
parameter clock1_time_delay = "0";
parameter clock2_boost = 1;
parameter clock2_divide = 1;
parameter clock2_settings = "UNUSED";
parameter clock2_time_delay = "0";
parameter clock_ext_boost = 1;
parameter clock_ext_divide = 1;
parameter clock_ext_settings = "UNUSED";
parameter clock_ext_time_delay = "0";
parameter outclock_phase_shift = 0;  // units in ps
parameter intended_device_family = "Stratix";
parameter lpm_type = "altclklock";
parameter lpm_hint = "UNUSED";

// INPUT PORT DECLARATION
input inclock;
input inclocken;
input fbin;

// OUTPUT PORT DECLARATION
output clock0;
output clock1;
output clock2;
output clock_ext;
output locked;

// INTERNAL VARIABLE/REGISTER DECLARATION
reg clock0;
reg clock1;
reg clock2;
reg clock_ext;

reg start_outclk;
reg clk0_tmp;
reg clk1_tmp;
reg clk2_tmp;
reg extclk_tmp;
reg pll_lock;
reg clk_last_value;
reg violation;
reg clk_check;
reg [1:0] next_clk_check;

reg init;

real pll_last_rising_edge;
real pll_last_falling_edge;
real actual_clk_cycle;
real expected_clk_cycle;
real pll_duty_cycle;
real inclk_period;
real expected_next_clk_edge;
integer pll_rising_edge_count;
integer stop_lock_count;
integer start_lock_count;
integer clk_per_tolerance;

time clk0_phase_delay;
time clk1_phase_delay;
time clk2_phase_delay;
time extclk_phase_delay;

ALTERA_DEVICE_FAMILIES dev ();

// variables for clock synchronizing
time last_synchronizing_rising_edge_for_clk0;
time last_synchronizing_rising_edge_for_clk1;
time last_synchronizing_rising_edge_for_clk2;
time last_synchronizing_rising_edge_for_extclk;
time clk0_synchronizing_period;
time clk1_synchronizing_period;
time clk2_synchronizing_period;
time extclk_synchronizing_period;
integer input_cycles_per_clk0;
integer input_cycles_per_clk1;
integer input_cycles_per_clk2;
integer input_cycles_per_extclk;
integer clk0_cycles_per_sync_period;
integer clk1_cycles_per_sync_period;
integer clk2_cycles_per_sync_period;
integer extclk_cycles_per_sync_period;
integer input_cycle_count_to_sync0;
integer input_cycle_count_to_sync1;
integer input_cycle_count_to_sync2;
integer input_cycle_count_to_sync_extclk;

// variables for shedule_clk0-2, clk_ext
reg schedule_clk0;
reg schedule_clk1;
reg schedule_clk2;
reg schedule_extclk;
reg output_value0;
reg output_value1;
reg output_value2;
reg output_value_ext;
time sched_time0;
time sched_time1;
time sched_time2;
time sched_time_ext;
integer rem0;
integer rem1;
integer rem2;
integer rem_ext;
integer tmp_rem0;
integer tmp_rem1;
integer tmp_rem2;
integer tmp_rem_ext;
integer clk_cnt0;
integer clk_cnt1;
integer clk_cnt2;
integer clk_cnt_ext;
integer cyc0;
integer cyc1;
integer cyc2;
integer cyc_ext;
integer inc0;
integer inc1;
integer inc2;
integer inc_ext;
integer cycle_to_adjust0;
integer cycle_to_adjust1;
integer cycle_to_adjust2;
integer cycle_to_adjust_ext;
time tmp_per0;
time tmp_per1;
time tmp_per2;
time tmp_per_ext;
time ori_per0;
time ori_per1;
time ori_per2;
time ori_per_ext;
time high_time0;
time high_time1;
time high_time2;
time high_time_ext;
time low_time0;
time low_time1;
time low_time2;
time low_time_ext;

// Default inclocken and fbin ports to 1 if unused
logic inclocken_int; // -- converted tristate to logic
logic fbin_int; // -- converted tristate to logic

assign inclocken_int = inclocken;
assign fbin_int = fbin;

//
// function time_delay - converts time_delay in string format to integer, and
// add result to outclock_phase_shift
//
function time time_delay;
input [8*16:1] s;

reg [8*16:1] reg_s;
reg [8:1] digit;
reg [8:1] tmp;
integer m;
integer outclock_phase_shift_adj;
integer sign;

begin
    // initialize variables
    sign = 1;
    outclock_phase_shift_adj = 0;
    reg_s = s;

    for (m = 1; m <= 16; m = m + 1)
    begin
        tmp = reg_s[128:121];
        digit = tmp & 8'b00001111;
        reg_s = reg_s << 8;
        // Accumulate ascii digits 0-9 only.
        if ((tmp >= 48) && (tmp <= 57))
            outclock_phase_shift_adj = outclock_phase_shift_adj * 10 + digit;
        if (tmp == 45)
            sign = -1;  // Found a '-' character, i.e. number is negative.
    end

    // add outclock_phase_shift to time delay
    outclock_phase_shift_adj = (sign*outclock_phase_shift_adj) + outclock_phase_shift;

    // adjust phase shift so that its value is between 0 and 1 full
    // inclock_period
    while (outclock_phase_shift_adj < 0)
        outclock_phase_shift_adj = outclock_phase_shift_adj + inclock_period;
    while (outclock_phase_shift_adj >= inclock_period)
        outclock_phase_shift_adj = outclock_phase_shift_adj - inclock_period;

    // assign result
    time_delay = outclock_phase_shift_adj;
end
endfunction

// INITIAL BLOCK
initial
begin

    // check for invalid parameters
    if (inclock_period <= 0)
    begin
        $display("ERROR: The period of the input clock (inclock_period) must be greater than 0");
        $stop;
    end

    if ((clock0_boost <= 0) || (clock0_divide <= 0)
        || (clock1_boost <= 0) || (clock1_divide <= 0)
        || (clock2_boost <= 0) || (clock2_divide <= 0)
        || (clock_ext_boost <= 0) || (clock_ext_divide <= 0))
    begin
        if ((clock0_boost <= 0) || (clock0_divide <= 0))
        begin
            $display("ERROR: The multiplication and division factors for clock0 must be greater than 0.");
        end

        if ((clock1_boost <= 0) || (clock1_divide <= 0))
        begin
            $display("ERROR: The multiplication and division factors for clock1 must be greater than 0.");
        end

        if ((clock2_boost <= 0) || (clock2_divide <= 0))
        begin
            $display("ERROR: The multiplication and division factors for clock2 must be greater than 0.");
        end

        if ((clock_ext_boost <= 0) || (clock_ext_divide <= 0))
        begin
            $display("ERROR: The multiplication and division factors for clock_ext must be greater than 0.");
        end
        $stop;
    end

    if (!dev.FEATURE_FAMILY_STRATIX(intended_device_family))
    begin
        $display("WARNING: Device family specified by the intended_device_family parameter, %s, may not be supported by altclklock", intended_device_family);
        $display ("Time: %0t  Instance: %m", $time);
    end

    stop_lock_count = 0;
    violation = 0;

    // clock synchronizing variables
    last_synchronizing_rising_edge_for_clk0 = 0;
    last_synchronizing_rising_edge_for_clk1 = 0;
    last_synchronizing_rising_edge_for_clk2 = 0;
    last_synchronizing_rising_edge_for_extclk = 0;
    clk0_synchronizing_period = 0;
    clk1_synchronizing_period = 0;
    clk2_synchronizing_period = 0;
    extclk_synchronizing_period = 0;
    input_cycles_per_clk0 = clock0_divide;
    input_cycles_per_clk1 = clock1_divide;
    input_cycles_per_clk2 = clock2_divide;
    input_cycles_per_extclk = clock_ext_divide;
    clk0_cycles_per_sync_period = clock0_boost;
    clk1_cycles_per_sync_period = clock1_boost;
    clk2_cycles_per_sync_period = clock2_boost;
    extclk_cycles_per_sync_period = clock_ext_boost;
    input_cycle_count_to_sync0 = 0;
    input_cycle_count_to_sync1 = 0;
    input_cycle_count_to_sync2 = 0;
    input_cycle_count_to_sync_extclk = 0;
    inc0 = 1;
    inc1 = 1;
    inc2 = 1;
    inc_ext = 1;
    cycle_to_adjust0 = 0;
    cycle_to_adjust1 = 0;
    cycle_to_adjust2 = 0;
    cycle_to_adjust_ext = 0;

    if ((clock0_boost % clock0_divide) == 0)
    begin
        clk0_cycles_per_sync_period = clock0_boost / clock0_divide;
        input_cycles_per_clk0 = 1;
    end

    if ((clock1_boost % clock1_divide) == 0)
    begin
        clk1_cycles_per_sync_period = clock1_boost / clock1_divide;
        input_cycles_per_clk1 = 1;
    end

    if ((clock2_boost % clock2_divide) == 0)
    begin
        clk2_cycles_per_sync_period = clock2_boost / clock2_divide;
        input_cycles_per_clk2 = 1;
    end

    if ((clock_ext_boost % clock_ext_divide) == 0)
    begin
        extclk_cycles_per_sync_period = clock_ext_boost / clock_ext_divide;
        input_cycles_per_extclk = 1;
    end

    // convert time delays from string to integer
    clk0_phase_delay = time_delay(clock0_time_delay);
    clk1_phase_delay = time_delay(clock1_time_delay);
    clk2_phase_delay = time_delay(clock2_time_delay);
    extclk_phase_delay = time_delay(clock_ext_time_delay);

    // 10% tolerance of input clock period variation
    clk_per_tolerance = 0.1 * inclock_period;
end

always @(next_clk_check)
begin
    if (next_clk_check == 1)
    begin
        if ((clk_check === 1'b1) || (clk_check === 1'b0))
            #((inclk_period+clk_per_tolerance)/2) clk_check = ~clk_check;
        else
            #((inclk_period+clk_per_tolerance)/2) clk_check = 1'b1;
    end
    else if (next_clk_check == 2)
    begin
        if ((clk_check === 1'b1) || (clk_check === 1'b0))
            #(expected_next_clk_edge - $realtime) clk_check = ~clk_check;
        else
            #(expected_next_clk_edge - $realtime) clk_check = 1'b1;
    end
    next_clk_check = 0;
end

always @(inclock or inclocken_int or clk_check)
begin

    if(init !== 1'b1)
    begin
        start_lock_count = 0;
        pll_rising_edge_count = 0;
        pll_last_rising_edge = 0;
        pll_last_falling_edge = 0;
        pll_lock = 0;
        init = 1'b1;
    end

    if (inclocken_int == 1'b0)
    begin
        pll_lock = 0;
        pll_rising_edge_count = 0;
    end
    else if ((inclock == 1'b1) && (clk_last_value !== inclock))
    begin
        if (pll_lock === 1)
            next_clk_check = 1;

        if (pll_rising_edge_count == 0)   // this is first rising edge
        begin
            inclk_period = inclock_period;
            pll_duty_cycle = inclk_period/2;
            start_outclk = 0;
        end
        else if (pll_rising_edge_count == 1) // this is second rising edge
        begin
            expected_clk_cycle = inclk_period;
            actual_clk_cycle = $realtime - pll_last_rising_edge;
            if (actual_clk_cycle < (expected_clk_cycle - clk_per_tolerance) ||
                actual_clk_cycle > (expected_clk_cycle + clk_per_tolerance))
            begin
                $display($realtime, "ps Warning: Inclock_Period Violation");
                $display ("Instance: %m");
                violation = 1;
                if (locked == 1'b1)
                begin
                    stop_lock_count = stop_lock_count + 1;
                    if ((locked == 1'b1) && (stop_lock_count == invalid_lock_cycles))
                    begin
                        pll_lock = 0;
                        $display ($realtime, "ps Warning: altclklock out of lock.");
                        $display ("Instance: %m");
                        start_lock_count = 1;

                        stop_lock_count = 0;
                        clk0_tmp = 1'b0 /* converted x or z to 1'b0 */;
                        clk1_tmp = 1'b0 /* converted x or z to 1'b0 */;
                        clk2_tmp = 1'b0 /* converted x or z to 1'b0 */;
                        extclk_tmp = 1'b0 /* converted x or z to 1'b0 */;
                    end
                end
                else begin
                    start_lock_count = 1;
                end
            end
            else
            begin
                if (($realtime - pll_last_falling_edge) < (pll_duty_cycle - clk_per_tolerance/2) ||
                    ($realtime - pll_last_falling_edge) > (pll_duty_cycle + clk_per_tolerance/2))
                begin
                    $display($realtime, "ps Warning: Duty Cycle Violation");
                    $display ("Instance: %m");
                    violation = 1;
                end
                else
                    violation = 0;
            end
        end
        else if (($realtime - pll_last_rising_edge) < (expected_clk_cycle - clk_per_tolerance) ||
                ($realtime - pll_last_rising_edge) > (expected_clk_cycle + clk_per_tolerance))
        begin
            $display($realtime, "ps Warning: Cycle Violation");
            $display ("Instance: %m");
            violation = 1;
            if (locked == 1'b1)
            begin
                stop_lock_count = stop_lock_count + 1;
                if (stop_lock_count == invalid_lock_cycles)
                begin
                    pll_lock = 0;
                    $display ($realtime, "ps Warning: altclklock out of lock.");
                    $display ("Instance: %m");

                    start_lock_count = 1;

                    stop_lock_count = 0;
                    clk0_tmp = 1'b0 /* converted x or z to 1'b0 */;
                    clk1_tmp = 1'b0 /* converted x or z to 1'b0 */;
                    clk2_tmp = 1'b0 /* converted x or z to 1'b0 */;
                    extclk_tmp = 1'b0 /* converted x or z to 1'b0 */;
                end
            end
            else
            begin
                start_lock_count = 1;
            end
        end
        else
        begin
            violation = 0;
            actual_clk_cycle = $realtime - pll_last_rising_edge;
        end
        pll_last_rising_edge = $realtime;
        pll_rising_edge_count = pll_rising_edge_count + 1;
        if (!violation)
        begin
            if (pll_lock == 1'b1)
            begin
                input_cycle_count_to_sync0 = input_cycle_count_to_sync0 + 1;
                if (input_cycle_count_to_sync0 == input_cycles_per_clk0)
                begin
                    clk0_synchronizing_period = $realtime - last_synchronizing_rising_edge_for_clk0;
                    last_synchronizing_rising_edge_for_clk0 = $realtime;
                    schedule_clk0 = 1;
                    input_cycle_count_to_sync0 = 0;
                end
                input_cycle_count_to_sync1 = input_cycle_count_to_sync1 + 1;
                if (input_cycle_count_to_sync1 == input_cycles_per_clk1)
                begin
                    clk1_synchronizing_period = $realtime - last_synchronizing_rising_edge_for_clk1;
                    last_synchronizing_rising_edge_for_clk1 = $realtime;
                    schedule_clk1 = 1;
                    input_cycle_count_to_sync1 = 0;
                end
                input_cycle_count_to_sync2 = input_cycle_count_to_sync2 + 1;
                if (input_cycle_count_to_sync2 == input_cycles_per_clk2)
                begin
                    clk2_synchronizing_period = $realtime - last_synchronizing_rising_edge_for_clk2;
                    last_synchronizing_rising_edge_for_clk2 = $realtime;
                    schedule_clk2 = 1;
                    input_cycle_count_to_sync2 = 0;
                end
                input_cycle_count_to_sync_extclk = input_cycle_count_to_sync_extclk + 1;
                if (input_cycle_count_to_sync_extclk == input_cycles_per_extclk)
                begin
                    extclk_synchronizing_period = $realtime - last_synchronizing_rising_edge_for_extclk;
                    last_synchronizing_rising_edge_for_extclk = $realtime;
                    schedule_extclk = 1;
                    input_cycle_count_to_sync_extclk = 0;
                end
            end
            else
            begin
                start_lock_count = start_lock_count + 1;
                if (start_lock_count >= valid_lock_cycles)
                begin
                    pll_lock = 1;
                    input_cycle_count_to_sync0 = 0;
                    input_cycle_count_to_sync1 = 0;
                    input_cycle_count_to_sync2 = 0;
                    input_cycle_count_to_sync_extclk = 0;
                    clk0_synchronizing_period = actual_clk_cycle * input_cycles_per_clk0;
                    clk1_synchronizing_period = actual_clk_cycle * input_cycles_per_clk1;
                    clk2_synchronizing_period = actual_clk_cycle * input_cycles_per_clk2;
                    extclk_synchronizing_period = actual_clk_cycle * input_cycles_per_extclk;
                    last_synchronizing_rising_edge_for_clk0 = $realtime;
                    last_synchronizing_rising_edge_for_clk1 = $realtime;
                    last_synchronizing_rising_edge_for_clk2 = $realtime;
                    last_synchronizing_rising_edge_for_extclk = $realtime;
                    schedule_clk0 = 1;
                    schedule_clk1 = 1;
                    schedule_clk2 = 1;
                    schedule_extclk = 1;
                end
            end
        end
        else
            start_lock_count = 1;
    end
    else if ((inclock == 1'b0) && (clk_last_value !== inclock))
    begin
        if (pll_lock == 1)
        begin
            next_clk_check = 1;
            if (($realtime - pll_last_rising_edge) < (pll_duty_cycle - clk_per_tolerance/2) ||
                ($realtime - pll_last_rising_edge) > (pll_duty_cycle + clk_per_tolerance/2))
            begin
                $display($realtime, "ps Warning: Duty Cycle Violation");
                $display ("Instance: %m");
                violation = 1;
                if (locked == 1'b1)
                begin
                    stop_lock_count = stop_lock_count + 1;
                    if (stop_lock_count == invalid_lock_cycles)
                    begin
                        pll_lock = 0;
                        $display ($realtime, "ps Warning: altclklock out of lock.");
                        $display ("Instance: %m");

                        start_lock_count = 1;

                        stop_lock_count = 0;
                        clk0_tmp = 1'b0 /* converted x or z to 1'b0 */;
                        clk1_tmp = 1'b0 /* converted x or z to 1'b0 */;
                        clk2_tmp = 1'b0 /* converted x or z to 1'b0 */;
                        extclk_tmp = 1'b0 /* converted x or z to 1'b0 */;
                    end
                end
            end
            else
                violation = 0;
        end
        else
            start_lock_count = start_lock_count + 1;
        pll_last_falling_edge = $realtime;
    end
    else if (pll_lock == 1)
    begin
    if (inclock == 1'b1)
        expected_next_clk_edge = pll_last_rising_edge + (inclk_period+clk_per_tolerance)/2;
    else if (inclock == 'b0)
        expected_next_clk_edge = pll_last_falling_edge + (inclk_period+clk_per_tolerance)/2;
    else
        expected_next_clk_edge = 0;
        violation = 0;
        if ($realtime < expected_next_clk_edge)
            next_clk_check = 2;
        else if ($realtime == expected_next_clk_edge)
            next_clk_check = 1;
        else
        begin
            $display($realtime, "ps Warning: Inclock_Period Violation");
            $display ("Instance: %m");
            violation = 1;

            if (locked == 1'b1)
            begin
                stop_lock_count = stop_lock_count + 1;
                expected_next_clk_edge = $realtime + (inclk_period/2);
                if (stop_lock_count == invalid_lock_cycles)
                begin
                    pll_lock = 0;
                    $display ($realtime, "ps Warning: altclklock out of lock.");
                    $display ("Instance: %m");

                    start_lock_count = 1;

                    stop_lock_count = 0;
                    clk0_tmp = 1'b0 /* converted x or z to 1'b0 */;
                    clk1_tmp = 1'b0 /* converted x or z to 1'b0 */;
                    clk2_tmp = 1'b0 /* converted x or z to 1'b0 */;
                    extclk_tmp = 1'b0 /* converted x or z to 1'b0 */;
                end
                else
                    next_clk_check = 2;
            end
        end
    end
    clk_last_value = inclock;
end

// clock0 output
always @(posedge schedule_clk0)
begin
    // initialise variables
    inc0 = 1;
    cycle_to_adjust0 = 0;
    output_value0 = 1'b1;
    sched_time0 = 0;
    rem0 = clk0_synchronizing_period % clk0_cycles_per_sync_period;
    ori_per0 = clk0_synchronizing_period / clk0_cycles_per_sync_period;

    // schedule <clk0_cycles_per_sync_period> number of clock0 cycles in this
    // loop - in order to synchronize the output clock always to the input clock
    // to get rid of clock drift for cases where the input clock period is
    // not evenly divisible
    for (clk_cnt0 = 1; clk_cnt0 <= clk0_cycles_per_sync_period;
        clk_cnt0 = clk_cnt0 + 1)
    begin
        tmp_per0 = ori_per0;
        if ((rem0 != 0) && (inc0 <= rem0))
        begin
            tmp_rem0 = (clk0_cycles_per_sync_period * inc0) % rem0;
            cycle_to_adjust0 = (clk0_cycles_per_sync_period * inc0) / rem0;
            if (tmp_rem0 != 0)
                cycle_to_adjust0 = cycle_to_adjust0 + 1;
        end

        // if this cycle is the one to adjust the output clock period, then
        // increment the period by 1 unit
        if (cycle_to_adjust0 == clk_cnt0)
        begin
            tmp_per0 = tmp_per0 + 1;
            inc0 = inc0 + 1;
        end

        // adjust the high and low cycle period
        high_time0 = tmp_per0 / 2;
        if ((tmp_per0 % 2) != 0)
            high_time0 = high_time0 + 1;

        low_time0 = tmp_per0 - high_time0;

        // schedule the high and low cycle of 1 output clock period
        for (cyc0 = 0; cyc0 <= 1; cyc0 = cyc0 + 1)
        begin
            // Avoid glitch in vcs when high_time0 and low_time0 is 0
            // (due to clk0_synchronizing_period is 0)
            if (clk0_synchronizing_period != 0)
                clk0_tmp = #(sched_time0) output_value0;
            else
                clk0_tmp = #(sched_time0) 1'b0;
            output_value0 = ~output_value0;
            if (output_value0 == 1'b0)
            begin
                sched_time0 = high_time0;
            end
            else if (output_value0 == 1'b1)
            begin
                sched_time0 = low_time0;
            end
        end
    end

    // drop the schedule_clk0 to 0 so that the "always@(inclock)" block can
    // trigger this block again when the correct time comes
    schedule_clk0 = #1 1'b0;
end

always @(clk0_tmp)
begin
    if (clk0_phase_delay == 0)
        clock0 <= clk0_tmp;
    else
        clock0 <= #(clk0_phase_delay) clk0_tmp;
end

// clock1 output
always @(posedge schedule_clk1)
begin
    // initialize variables
    inc1 = 1;
    cycle_to_adjust1 = 0;
    output_value1 = 1'b1;
    sched_time1 = 0;
    rem1 = clk1_synchronizing_period % clk1_cycles_per_sync_period;
    ori_per1 = clk1_synchronizing_period / clk1_cycles_per_sync_period;

    // schedule <clk1_cycles_per_sync_period> number of clock1 cycles in this
    // loop - in order to synchronize the output clock always to the input clock,
    // to get rid of clock drift for cases where the input clock period is
    // not evenly divisible
    for (clk_cnt1 = 1; clk_cnt1 <= clk1_cycles_per_sync_period;
        clk_cnt1 = clk_cnt1 + 1)
    begin
        tmp_per1 = ori_per1;
        if ((rem1 != 0) && (inc1 <= rem1))
        begin
            tmp_rem1 = (clk1_cycles_per_sync_period * inc1) % rem1;
            cycle_to_adjust1 = (clk1_cycles_per_sync_period * inc1) / rem1;
            if (tmp_rem1 != 0)
                cycle_to_adjust1 = cycle_to_adjust1 + 1;
        end

        // if this cycle is the one to adjust the output clock period, then
        // increment the period by 1 unit
        if (cycle_to_adjust1 == clk_cnt1)
        begin
            tmp_per1 = tmp_per1 + 1;
            inc1 = inc1 + 1;
        end

        // adjust the high and low cycle period
        high_time1 = tmp_per1 / 2;
        if ((tmp_per1 % 2) != 0)
            high_time1 = high_time1 + 1;

        low_time1 = tmp_per1 - high_time1;

        // schedule the high and low cycle of 1 output clock period
        for (cyc1 = 0; cyc1 <= 1; cyc1 = cyc1 + 1)
        begin
            // Avoid glitch in vcs when high_time1 and low_time1 is 0
            // (due to clk1_synchronizing_period is 0)
            if (clk1_synchronizing_period != 0)
                clk1_tmp = #(sched_time1) output_value1;
            else
                clk1_tmp = #(sched_time1) 1'b0;
            output_value1 = ~output_value1;
            if (output_value1 == 1'b0)
                sched_time1 = high_time1;
            else if (output_value1 == 1'b1)
                sched_time1 = low_time1;
        end
    end
    // drop the schedule_clk1 to 0 so that the "always@(inclock)" block can
    // trigger this block again when the correct time comes
    schedule_clk1 = #1 1'b0;
end

always @(clk1_tmp)
begin
    if (clk1_phase_delay == 0)
        clock1 <= clk1_tmp;
    else
        clock1 <= #(clk1_phase_delay) clk1_tmp;
end

// clock2 output
always @(posedge schedule_clk2)
begin
    if (dev.FEATURE_FAMILY_STRATIX(intended_device_family))
    begin
        // initialize variables
        inc2 = 1;
        cycle_to_adjust2 = 0;
        output_value2 = 1'b1;
        sched_time2 = 0;
        rem2 = clk2_synchronizing_period % clk2_cycles_per_sync_period;
        ori_per2 = clk2_synchronizing_period / clk2_cycles_per_sync_period;

        // schedule <clk2_cycles_per_sync_period> number of clock2 cycles in this
        // loop - in order to synchronize the output clock always to the input clock,
        // to get rid of clock drift for cases where the input clock period is
        // not evenly divisible
        for (clk_cnt2 = 1; clk_cnt2 <= clk2_cycles_per_sync_period;
            clk_cnt2 = clk_cnt2 + 1)
        begin
            tmp_per2 = ori_per2;
            if ((rem2 != 0) && (inc2 <= rem2))
            begin
                tmp_rem2 = (clk2_cycles_per_sync_period * inc2) % rem2;
                cycle_to_adjust2 = (clk2_cycles_per_sync_period * inc2) / rem2;
                if (tmp_rem2 != 0)
                    cycle_to_adjust2 = cycle_to_adjust2 + 1;
            end

            // if this cycle is the one to adjust the output clock period, then
            // increment the period by 1 unit
            if (cycle_to_adjust2 == clk_cnt2)
            begin
                tmp_per2 = tmp_per2 + 1;
                inc2 = inc2 + 1;
            end

            // adjust the high and low cycle period
            high_time2 = tmp_per2 / 2;
            if ((tmp_per2 % 2) != 0)
                high_time2 = high_time2 + 1;

            low_time2 = tmp_per2 - high_time2;

            // schedule the high and low cycle of 1 output clock period
            for (cyc2 = 0; cyc2 <= 1; cyc2 = cyc2 + 1)
            begin
                // Avoid glitch in vcs when high_time2 and low_time2 is 0
                // (due to clk2_synchronizing_period is 0)
                if (clk2_synchronizing_period != 0)
                    clk2_tmp = #(sched_time2) output_value2;
                else
                    clk2_tmp = #(sched_time2) 1'b0;
                output_value2 = ~output_value2;
                if (output_value2 == 1'b0)
                    sched_time2 = high_time2;
                else if (output_value2 == 1'b1)
                    sched_time2 = low_time2;
            end
        end
        // drop the schedule_clk2 to 0 so that the "always@(inclock)" block can
        // trigger this block again when the correct time comes
        schedule_clk2 = #1 1'b0;
    end
end

always @(clk2_tmp)
begin
    if (clk2_phase_delay == 0)
        clock2 <= clk2_tmp;
    else
        clock2 <= #(clk2_phase_delay) clk2_tmp;
end

// clock_ext output
always @(posedge schedule_extclk)
begin
    if (dev.FEATURE_FAMILY_STRATIX(intended_device_family))
    begin
        // initialize variables
        inc_ext = 1;
        cycle_to_adjust_ext = 0;
        output_value_ext = 1'b1;
        sched_time_ext = 0;
        rem_ext = extclk_synchronizing_period % extclk_cycles_per_sync_period;
        ori_per_ext = extclk_synchronizing_period/extclk_cycles_per_sync_period;

        // schedule <extclk_cycles_per_sync_period> number of clock_ext cycles in this
        // loop - in order to synchronize the output clock always to the input clock,
        // to get rid of clock drift for cases where the input clock period is
        // not evenly divisible
        for (clk_cnt_ext = 1; clk_cnt_ext <= extclk_cycles_per_sync_period;
            clk_cnt_ext = clk_cnt_ext + 1)
        begin
            tmp_per_ext = ori_per_ext;
            if ((rem_ext != 0) && (inc_ext <= rem_ext))
            begin
                tmp_rem_ext = (extclk_cycles_per_sync_period * inc_ext) % rem_ext;
                cycle_to_adjust_ext = (extclk_cycles_per_sync_period * inc_ext) / rem_ext;
                if (tmp_rem_ext != 0)
                    cycle_to_adjust_ext = cycle_to_adjust_ext + 1;
            end

            // if this cycle is the one to adjust the output clock period, then
            // increment the period by 1 unit
            if (cycle_to_adjust_ext == clk_cnt_ext)
            begin
                tmp_per_ext = tmp_per_ext + 1;
                inc_ext = inc_ext + 1;
            end

            // adjust the high and low cycle period
            high_time_ext = tmp_per_ext/2;
            if ((tmp_per_ext % 2) != 0)
                high_time_ext = high_time_ext + 1;

            low_time_ext = tmp_per_ext - high_time_ext;

            // schedule the high and low cycle of 1 output clock period
            for (cyc_ext = 0; cyc_ext <= 1; cyc_ext = cyc_ext + 1)
            begin
                // Avoid glitch in vcs when high_time_ext and low_time_ext is 0
                // (due to extclk_synchronizing_period is 0)
                if (extclk_synchronizing_period != 0)
                    extclk_tmp = #(sched_time_ext) output_value_ext;
                else
                    extclk_tmp = #(sched_time_ext) 1'b0;
                output_value_ext = ~output_value_ext;
                if (output_value_ext == 1'b0)
                    sched_time_ext = high_time_ext;
                else if (output_value_ext == 1'b1)
                    sched_time_ext = low_time_ext;
            end
        end
        // drop the schedule_extclk to 0 so that the "always@(inclock)" block
        // can trigger this block again when the correct time comes
        schedule_extclk = #1 1'b0;
    end
end

always @(extclk_tmp)
begin
    if (extclk_phase_delay == 0)
        clock_ext <= extclk_tmp;
    else
        clock_ext <= #(extclk_phase_delay) extclk_tmp;
end

// ACCELERATE OUTPUTS
assign locked = pll_lock; // -- converted buf to assign

endmodule // altclklock

