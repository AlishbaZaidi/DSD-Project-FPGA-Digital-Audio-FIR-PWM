`timescale 1ns / 1ps

module clock_divider (
    input wire clk_100MHz,     // 100MHz input clock
    input wire reset,
    output reg clk_100kHz      // 100kHz output clock
);

    reg [9:0] counter;  // Need to count to 500 (100MHz/100kHz = 1000, but we toggle every 500)
    
    always @(posedge clk_100MHz or posedge reset) begin
        if (reset) begin
            counter <= 10'b0;
            clk_100kHz <= 1'b0;
        end else begin
            if (counter == 10'd499) begin  // 100MHz / (2*500) = 100kHz
                counter <= 10'b0;
                clk_100kHz <= ~clk_100kHz;
            end else begin
                counter <= counter + 1'b1;
            end
        end
    end

endmodule