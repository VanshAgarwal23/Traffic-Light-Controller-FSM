`timescale 1ns/1ps

module traffic_fsm (
    input  wire clk,
    input  wire reset,
    input  wire timer_done,

    output reg NS_RED,
    output reg NS_YELLOW,
    output reg NS_GREEN,

    output reg EW_RED,
    output reg EW_YELLOW,
    output reg EW_GREEN,

    output reg [2:0] current_state
);

    // ------------------------------------------------------------
    // FSM State Encoding
    // ------------------------------------------------------------
    localparam [2:0]
        ST_NS_GREEN  = 3'b000,
        ST_NS_YELLOW = 3'b001,
        ST_ALL_RED_1 = 3'b010,
        ST_EW_GREEN  = 3'b011,
        ST_EW_YELLOW = 3'b100,
        ST_ALL_RED_2 = 3'b101;

    reg [2:0] next_state;

    // ------------------------------------------------------------
    // Sequential State Register
    // ------------------------------------------------------------
    always @(posedge clk) begin
        if (reset)
            current_state <= ST_NS_GREEN;
        else
            current_state <= next_state;
    end

    // ------------------------------------------------------------
    // Next-State Logic
    // ------------------------------------------------------------
    always @(*) begin

        // Default: remain in current state
        next_state = current_state;

        case (current_state)

            ST_NS_GREEN: begin
                if (timer_done)
                    next_state = ST_NS_YELLOW;
            end

            ST_NS_YELLOW: begin
                if (timer_done)
                    next_state = ST_ALL_RED_1;
            end

            ST_ALL_RED_1: begin
                if (timer_done)
                    next_state = ST_EW_GREEN;
            end

            ST_EW_GREEN: begin
                if (timer_done)
                    next_state = ST_EW_YELLOW;
            end

            ST_EW_YELLOW: begin
                if (timer_done)
                    next_state = ST_ALL_RED_2;
            end

            ST_ALL_RED_2: begin
                if (timer_done)
                    next_state = ST_NS_GREEN;
            end

            // Recovery from an invalid/unused state
            default: begin
                next_state = ST_NS_GREEN;
            end

        endcase
    end

    // ------------------------------------------------------------
    // Moore Output Logic
    // Outputs depend only on current_state
    // ------------------------------------------------------------
    always @(*) begin

        // Default outputs
        NS_RED    = 1'b0;
        NS_YELLOW = 1'b0;
        NS_GREEN  = 1'b0;

        EW_RED    = 1'b0;
        EW_YELLOW = 1'b0;
        EW_GREEN  = 1'b0;

        case (current_state)

            // North-South GREEN
            ST_NS_GREEN: begin
                NS_GREEN = 1'b1;
                EW_RED   = 1'b1;
            end

            // North-South YELLOW
            ST_NS_YELLOW: begin
                NS_YELLOW = 1'b1;
                EW_RED    = 1'b1;
            end

            // Safety interval
            ST_ALL_RED_1: begin
                NS_RED = 1'b1;
                EW_RED = 1'b1;
            end

            // East-West GREEN
            ST_EW_GREEN: begin
                NS_RED   = 1'b1;
                EW_GREEN = 1'b1;
            end

            // East-West YELLOW
            ST_EW_YELLOW: begin
                NS_RED    = 1'b1;
                EW_YELLOW = 1'b1;
            end

            // Safety interval
            ST_ALL_RED_2: begin
                NS_RED = 1'b1;
                EW_RED = 1'b1;
            end

            // Safe recovery output
            default: begin
                NS_RED = 1'b1;
                EW_RED = 1'b1;
            end

        endcase
    end

endmodule
