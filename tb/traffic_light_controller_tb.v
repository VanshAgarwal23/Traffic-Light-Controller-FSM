`timescale 1ns/1ps

module traffic_light_controller_tb;

    // ============================================================
    // Testbench Signals
    // ============================================================

    reg clk;
    reg reset;

    wire NS_RED;
    wire NS_YELLOW;
    wire NS_GREEN;

    wire EW_RED;
    wire EW_YELLOW;
    wire EW_GREEN;

    // Internal DUT signals accessed for verification
    wire [2:0] current_state;
    wire       timer_done;

    // ============================================================
    // State Definitions
    // ============================================================

    localparam [2:0]
        ST_NS_GREEN  = 3'b000,
        ST_NS_YELLOW = 3'b001,
        ST_ALL_RED_1 = 3'b010,
        ST_EW_GREEN  = 3'b011,
        ST_EW_YELLOW = 3'b100,
        ST_ALL_RED_2 = 3'b101;

    // ============================================================
    // Test Counters
    // ============================================================

    integer total_tests;
    integer passed_tests;
    integer failed_tests;

    // ============================================================
    // DUT
    // ============================================================

    traffic_light_controller DUT (
        .clk       (clk),
        .reset     (reset),

        .NS_RED    (NS_RED),
        .NS_YELLOW (NS_YELLOW),
        .NS_GREEN  (NS_GREEN),

        .EW_RED    (EW_RED),
        .EW_YELLOW (EW_YELLOW),
        .EW_GREEN  (EW_GREEN)
    );

    // ============================================================
    // Access Internal DUT Signals
    // ============================================================

    assign current_state = DUT.u_traffic_fsm.current_state;
    assign timer_done    = DUT.u_traffic_timer.timer_done;

    // ============================================================
    // Clock Generation
    // 10 ns period = 100 MHz
    // ============================================================

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // ============================================================
    // State Name Task
    // ============================================================

    task print_state_name;
        input [2:0] state;
        begin
            case (state)
                ST_NS_GREEN:
                    $write("NS_GREEN");

                ST_NS_YELLOW:
                    $write("NS_YELLOW");

                ST_ALL_RED_1:
                    $write("ALL_RED_1");

                ST_EW_GREEN:
                    $write("EW_GREEN");

                ST_EW_YELLOW:
                    $write("EW_YELLOW");

                ST_ALL_RED_2:
                    $write("ALL_RED_2");

                default:
                    $write("INVALID_STATE");
            endcase
        end
    endtask

    // ============================================================
    // State Checking Task
    // ============================================================

    task check_state;
        input [2:0] expected_state;

        begin
            total_tests = total_tests + 1;

            if (current_state === expected_state) begin
                passed_tests = passed_tests + 1;

                $display(
                    "[PASS] State check: expected=",
                    expected_state,
                    " actual=",
                    current_state
                );
            end
            else begin
                failed_tests = failed_tests + 1;

                $display(
                    "[FAIL] State check: expected=",
                    expected_state,
                    " actual=",
                    current_state
                );
            end
        end
    endtask

    // ============================================================
    // Output Checking Task
    // ============================================================

    task check_outputs;
        input exp_ns_red;
        input exp_ns_yellow;
        input exp_ns_green;

        input exp_ew_red;
        input exp_ew_yellow;
        input exp_ew_green;

        begin

            total_tests = total_tests + 1;

            if ((NS_RED    === exp_ns_red)    &&
                (NS_YELLOW === exp_ns_yellow) &&
                (NS_GREEN  === exp_ns_green)  &&
                (EW_RED    === exp_ew_red)    &&
                (EW_YELLOW === exp_ew_yellow) &&
                (EW_GREEN  === exp_ew_green)) begin

                passed_tests = passed_tests + 1;

                $display("[PASS] Output check");

            end
            else begin

                failed_tests = failed_tests + 1;

                $display("[FAIL] Output check");
                $display(
                    "       Actual: NS=%b%b%b EW=%b%b%b",
                    NS_RED, NS_YELLOW, NS_GREEN,
                    EW_RED, EW_YELLOW, EW_GREEN
                );

                $display(
                    "       Expected: NS=%b%b%b EW=%b%b%b",
                    exp_ns_red, exp_ns_yellow, exp_ns_green,
                    exp_ew_red, exp_ew_yellow, exp_ew_green
                );

            end
        end
    endtask

    // ============================================================
    // Safety Check
    // ============================================================

    task check_safety;

        begin

            total_tests = total_tests + 1;

            // Both roads must never be GREEN simultaneously.
            if ((NS_GREEN === 1'b1) &&
                (EW_GREEN === 1'b1)) begin

                failed_tests = failed_tests + 1;

                $display(
                    "[FAIL] SAFETY: NS_GREEN and EW_GREEN active simultaneously"
                );

            end

            // NS GREEN and NS YELLOW cannot be active together.
            else if ((NS_GREEN === 1'b1) &&
                     (NS_YELLOW === 1'b1)) begin

                failed_tests = failed_tests + 1;

                $display(
                    "[FAIL] SAFETY: NS_GREEN and NS_YELLOW active simultaneously"
                );

            end

            // EW GREEN and EW YELLOW cannot be active together.
            else if ((EW_GREEN === 1'b1) &&
                     (EW_YELLOW === 1'b1)) begin

                failed_tests = failed_tests + 1;

                $display(
                    "[FAIL] SAFETY: EW_GREEN and EW_YELLOW active simultaneously"
                );

            end

            else begin

                passed_tests = passed_tests + 1;

                $display("[PASS] Safety condition");

            end

        end
    endtask

    // ============================================================
    // Unknown Output Check
    // ============================================================

    task check_no_unknown_outputs;

        begin

            total_tests = total_tests + 1;

            if ((NS_RED    === 1'bx) || (NS_RED    === 1'bz) ||
                (NS_YELLOW === 1'bx) || (NS_YELLOW === 1'bz) ||
                (NS_GREEN  === 1'bx) || (NS_GREEN  === 1'bz) ||
                (EW_RED    === 1'bx) || (EW_RED    === 1'bz) ||
                (EW_YELLOW === 1'bx) || (EW_YELLOW === 1'bz) ||
                (EW_GREEN  === 1'bx) || (EW_GREEN  === 1'bz)) begin

                failed_tests = failed_tests + 1;

                $display("[FAIL] Unknown or high-impedance output detected");

            end
            else begin

                passed_tests = passed_tests + 1;

                $display("[PASS] No unknown outputs");

            end

        end
    endtask

    // ============================================================
    // Monitor
    // ============================================================

    always @(posedge clk) begin

        $display(
            "[TIME %0t ns] State=",
            $time
        );

        print_state_name(current_state);

        $display(
            " TimerDone=%b | NS=%b%b%b | EW=%b%b%b",
            timer_done,
            NS_RED, NS_YELLOW, NS_GREEN,
            EW_RED, EW_YELLOW, EW_GREEN
        );

    end

    // ============================================================
    // Main Test Sequence
    // ============================================================

    initial begin
        $dumpfile("sim/traffic_light_controller.vcd");
        $dumpvars(0, traffic_light_controller_tb);

        total_tests  = 0;
        passed_tests = 0;
        failed_tests = 0;

        // --------------------------------------------------------
        // Test 1: Initial Reset
        // --------------------------------------------------------

        $display("");
        $display("============================================================");
        $display("TEST 1: RESET");
        $display("============================================================");

        reset = 1'b1;

        repeat (2)
            @(posedge clk);

        #1;

        check_state(ST_NS_GREEN);

        check_outputs(
            1'b0, 1'b0, 1'b1,   // NS
            1'b1, 1'b0, 1'b0    // EW
        );

        check_safety;
        check_no_unknown_outputs;

        reset = 1'b0;

        // --------------------------------------------------------
        // Test 2: NS GREEN
        // --------------------------------------------------------

        $display("");
        $display("============================================================");
        $display("TEST 2: NORTH-SOUTH GREEN");
        $display("============================================================");

        #1;

        check_state(ST_NS_GREEN);

        check_outputs(
            1'b0, 1'b0, 1'b1,
            1'b1, 1'b0, 1'b0
        );

        check_safety;
        check_no_unknown_outputs;

        // --------------------------------------------------------
        // Test 3: NS YELLOW
        // --------------------------------------------------------

        $display("");
        $display("============================================================");
        $display("TEST 3: NORTH-SOUTH YELLOW");
        $display("============================================================");

        // NS_GREEN = 10 cycles.
        repeat (10)
            @(posedge clk);

        #1;

        check_state(ST_NS_YELLOW);

        check_outputs(
            1'b0, 1'b1, 1'b0,
            1'b1, 1'b0, 1'b0
        );

        check_safety;
        check_no_unknown_outputs;

        // --------------------------------------------------------
        // Test 4: ALL RED 1
        // --------------------------------------------------------

        $display("");
        $display("============================================================");
        $display("TEST 4: ALL RED 1");
        $display("============================================================");

        repeat (3)
            @(posedge clk);

        #1;

        check_state(ST_ALL_RED_1);

        check_outputs(
            1'b1, 1'b0, 1'b0,
            1'b1, 1'b0, 1'b0
        );

        check_safety;
        check_no_unknown_outputs;

        // --------------------------------------------------------
        // Test 5: EW GREEN
        // --------------------------------------------------------

        $display("");
        $display("============================================================");
        $display("TEST 5: EAST-WEST GREEN");
        $display("============================================================");

        repeat (2)
            @(posedge clk);

        #1;

        check_state(ST_EW_GREEN);

        check_outputs(
            1'b1, 1'b0, 1'b0,
            1'b0, 1'b0, 1'b1
        );

        check_safety;
        check_no_unknown_outputs;

        // --------------------------------------------------------
        // Test 6: EW YELLOW
        // --------------------------------------------------------

        $display("");
        $display("============================================================");
        $display("TEST 6: EAST-WEST YELLOW");
        $display("============================================================");

        repeat (10)
            @(posedge clk);

        #1;

        check_state(ST_EW_YELLOW);

        check_outputs(
            1'b1, 1'b0, 1'b0,
            1'b0, 1'b1, 1'b0
        );

        check_safety;
        check_no_unknown_outputs;

        // --------------------------------------------------------
        // Test 7: ALL RED 2
        // --------------------------------------------------------

        $display("");
        $display("============================================================");
        $display("TEST 7: ALL RED 2");
        $display("============================================================");

        repeat (3)
            @(posedge clk);

        #1;

        check_state(ST_ALL_RED_2);

        check_outputs(
            1'b1, 1'b0, 1'b0,
            1'b1, 1'b0, 1'b0
        );

        check_safety;
        check_no_unknown_outputs;

        // --------------------------------------------------------
        // Test 8: Return to NS GREEN
        // --------------------------------------------------------

        $display("");
        $display("============================================================");
        $display("TEST 8: RETURN TO NORTH-SOUTH GREEN");
        $display("============================================================");

        repeat (2)
            @(posedge clk);

        #1;

        check_state(ST_NS_GREEN);

        check_outputs(
            1'b0, 1'b0, 1'b1,
            1'b1, 1'b0, 1'b0
        );

        check_safety;
        check_no_unknown_outputs;

        // --------------------------------------------------------
        // Test 9: Reset During EW GREEN
        // --------------------------------------------------------

        $display("");
        $display("============================================================");
        $display("TEST 9: RESET DURING OPERATION");
        $display("============================================================");

        // Move through NS_GREEN, NS_YELLOW, ALL_RED_1.
        repeat (10)
            @(posedge clk);

        repeat (3)
            @(posedge clk);

        repeat (2)
            @(posedge clk);

        #1;

        check_state(ST_EW_GREEN);

        reset = 1'b1;

        @(posedge clk);

        #1;

        check_state(ST_NS_GREEN);

        check_outputs(
            1'b0, 1'b0, 1'b1,
            1'b1, 1'b0, 1'b0
        );

        check_safety;
        check_no_unknown_outputs;

        reset = 1'b0;

        // --------------------------------------------------------
        // Test 10: Three Complete Cycles
        // --------------------------------------------------------

        $display("");
        $display("============================================================");
        $display("TEST 10: THREE COMPLETE FSM CYCLES");
        $display("============================================================");

        repeat (90)
            @(posedge clk);

        #1;

        check_state(ST_NS_GREEN);

        check_outputs(
            1'b0, 1'b0, 1'b1,
            1'b1, 1'b0, 1'b0
        );

        check_safety;
        check_no_unknown_outputs;

        // --------------------------------------------------------
        // Test 11: Final Safety Check
        // --------------------------------------------------------

        $display("");
        $display("============================================================");
        $display("TEST 11: FINAL SAFETY VERIFICATION");
        $display("============================================================");

        check_safety;
        check_no_unknown_outputs;

        // --------------------------------------------------------
        // Final Summary
        // --------------------------------------------------------

        $display("");
        $display("============================================================");
        $display("TRAFFIC LIGHT CONTROLLER TEST SUMMARY");
        $display("============================================================");

        $display("Total Tests  : %0d", total_tests);
        $display("Passed       : %0d", passed_tests);
        $display("Failed       : %0d", failed_tests);

        if (failed_tests == 0) begin

            $display("");
            $display("========================================");
            $display("          ALL TESTS PASSED");
            $display("========================================");

        end
        else begin

            $display("");
            $display("========================================");
            $display("          TESTS FAILED");
            $display("========================================");

        end

        $display("");

        $finish;

    end

endmodule
