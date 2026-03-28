`timescale 1ns / 1ps

module square_wave_gen (
    input wire clk,          // 100kHz clock
    input wire reset,
    output reg signed [7:0] sq_out   // 8-bit signed output (-128 to 127)
);
    
    // For EXACT 1kHz square at 100kHz clock: 100 samples per cycle
    // 50 samples HIGH, 50 samples LOW
    reg [6:0] counter;  // 0 to 99 (7-bit for 100 values)
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 7'd0;
            sq_out <= -8'd128;  // Start LOW (negative)
        end else begin
            // Count from 0 to 99 (100 values)
            if (counter == 7'd99)
                counter <= 7'd0;
            else
                counter <= counter + 7'd1;
            
            // Generate 1kHz square wave
            // First 50 cycles: HIGH (+127)
            // Next 50 cycles: LOW (-128)
            if (counter < 7'd50)
                sq_out <= 8'd127;    // Positive half
            else
                sq_out <= -8'd128;   // Negative half
        end
    end
    
endmodule