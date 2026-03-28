`timescale 1ns / 1ps

module pwm_generator (
    input wire clk,
    input wire reset,
    input wire [7:0] audio_input,      // 0-255 scaled audio
    output reg pwm_out
);

    // Threshold value - adjust this as needed
    // Lower = more sensitive, Higher = less sensitive
    parameter THRESHOLD = 8'd200;
    
    // Simple threshold comparison
    always @(posedge clk) begin
        if (reset) begin
            pwm_out <= 1'b0;
        end else begin
            // Output HIGH when audio input is above threshold
            pwm_out <= (audio_input > THRESHOLD);
        end
    end

endmodule