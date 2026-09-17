module traffic_timer #(
    parameter WIDTH = 8
)(
    input  wire             clk,
    input  wire             reset,
    input  wire [WIDTH-1:0] timer_limit,

    output reg              timer_done
);

    reg [WIDTH-1:0] counter;

    // ------------------------------------------------------------
    // Timer Counter
    //
    // The counter represents the number of completed clock cycles
    // spent in the current FSM state.
    //
    // For timer_limit = N:
    //   counter: 0, 1, 2, ... N-1
    //   timer_done asserted when N cycles have elapsed.
    // ------------------------------------------------------------
    always @(posedge clk) begin

        if (reset) begin
            counter    <= {WIDTH{1'b0}};
            timer_done <= 1'b0;
        end

        else begin

            if (timer_limit == {WIDTH{1'b0}}) begin
                // Protect against an invalid zero timer value.
                counter    <= {WIDTH{1'b0}};
                timer_done <= 1'b1;
            end

            else if (counter == timer_limit - 1'b1) begin
                // Required number of cycles completed.
                counter    <= {WIDTH{1'b0}};
                timer_done <= 1'b1;
            end

            else begin
                counter    <= counter + 1'b1;
                timer_done <= 1'b0;
            end

        end
    end

endmodule
