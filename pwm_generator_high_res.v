`timescale 1ns / 1ps

module pwm_generator_high_res (
    input wire clk,              // 100MHz clock
    input wire reset,
    input wire [7:0] audio_input, // 0-255 scaled audio
    output reg pwm_out
);

    reg [7:0] pwm_counter;
    
    always @(posedge clk) begin
        if (reset) begin
            pwm_counter <= 8'b0;
            pwm_out <= 1'b0;
        end else begin
            pwm_counter <= pwm_counter + 1;
            // Proper PWM: output HIGH when counter < audio_input value
            pwm_out <= (pwm_counter < audio_input);
        end
    end

endmodule