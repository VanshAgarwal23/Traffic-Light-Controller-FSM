`timescale 1ns/1ps

module traffic_timer #(
    parameter WIDTH = 8
)(
    input  wire             clk,
    input  wire             reset,
    input  wire [WIDTH-1:0] timer_limit,

    output wire             timer_done
);

    reg [WIDTH-1:0] counter;

    // ------------------------------------------------------------
    // Timer Done
    //
    // timer_done becomes HIGH when the counter reaches the final
    // count of the configured state duration.
    // ------------------------------------------------------------

    assign timer_done =
        (timer_limit == {WIDTH{1'b0}}) ||
        (counter == timer_limit - 1'b1);

    // ------------------------------------------------------------
    // Timer Counter
    // ------------------------------------------------------------

    always @(posedge clk) begin

        if (reset) begin
            counter <= {WIDTH{1'b0}};
        end

        else if (timer_done) begin
            counter <= {WIDTH{1'b0}};
        end

        else begin
            counter <= counter + 1'b1;
        end

    end

endmodule
