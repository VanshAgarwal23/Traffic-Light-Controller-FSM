module traffic_light_controller #(
    parameter [7:0] NS_GREEN_TIME   = 8'd10,
    parameter [7:0] NS_YELLOW_TIME  = 8'd3,
    parameter [7:0] ALL_RED_TIME    = 8'd2,
    parameter [7:0] EW_GREEN_TIME   = 8'd10,
    parameter [7:0] EW_YELLOW_TIME  = 8'd3
)(
    input wire clk,
    input wire reset,

    // North-South traffic lights
    output wire NS_RED,
    output wire NS_YELLOW,
    output wire NS_GREEN,

    // East-West traffic lights
    output wire EW_RED,
    output wire EW_YELLOW,
    output wire EW_GREEN
);

    // ------------------------------------------------------------
    // Internal Signals
    // ------------------------------------------------------------

    wire [2:0] current_state;
    wire       timer_done;

    reg [7:0] timer_limit;

    // ------------------------------------------------------------
    // FSM State Encoding
    // Must match traffic_fsm.v
    // ------------------------------------------------------------

    localparam [2:0]
        ST_NS_GREEN  = 3'b000,
        ST_NS_YELLOW = 3'b001,
        ST_ALL_RED_1 = 3'b010,
        ST_EW_GREEN  = 3'b011,
        ST_EW_YELLOW = 3'b100,
        ST_ALL_RED_2 = 3'b101;

    // ------------------------------------------------------------
    // State-Dependent Timer Selection
    // ------------------------------------------------------------

    always @(*) begin

        case (current_state)

            ST_NS_GREEN:
                timer_limit = NS_GREEN_TIME;

            ST_NS_YELLOW:
                timer_limit = NS_YELLOW_TIME;

            ST_ALL_RED_1:
                timer_limit = ALL_RED_TIME;

            ST_EW_GREEN:
                timer_limit = EW_GREEN_TIME;

            ST_EW_YELLOW:
                timer_limit = EW_YELLOW_TIME;

            ST_ALL_RED_2:
                timer_limit = ALL_RED_TIME;

            default:
                timer_limit = ALL_RED_TIME;

        endcase

    end

    // ------------------------------------------------------------
    // Traffic Light FSM
    // ------------------------------------------------------------

    traffic_fsm u_traffic_fsm (
        .clk           (clk),
        .reset         (reset),
        .timer_done    (timer_done),

        .NS_RED        (NS_RED),
        .NS_YELLOW     (NS_YELLOW),
        .NS_GREEN      (NS_GREEN),

        .EW_RED        (EW_RED),
        .EW_YELLOW     (EW_YELLOW),
        .EW_GREEN      (EW_GREEN),

        .current_state (current_state)
    );

    // ------------------------------------------------------------
    // State Timer
    // ------------------------------------------------------------

    traffic_timer #(
        .WIDTH(8)
    ) u_traffic_timer (
        .clk         (clk),
        .reset       (reset),
        .timer_limit (timer_limit),
        .timer_done  (timer_done)
    );

endmodule
