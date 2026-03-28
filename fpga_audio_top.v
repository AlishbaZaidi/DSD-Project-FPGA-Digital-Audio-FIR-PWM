`timescale 1ns / 1ps

module fpga_audio_top (
    input wire clk,                    // 100MHz FPGA clock
    input wire reset,                  // Reset button
    input wire [1:0] freq_select,      // 2-bit frequency selection (T2, T3)
    input wire mode_select,            // R3 button: 0=Original, 1=Filtered
    input wire wave_select,            // NEW: W2 button: 0=Sine, 1=Square
    
    output wire pwm_speaker_out        // PWM output to speaker
);

    wire clk_100kHz;
    
    // Clock divider for 100kHz audio clock
    clock_divider clk_div (
        .clk_100MHz(clk),
        .reset(reset),
        .clk_100kHz(clk_100kHz)
    );

    // Frequency selection (same as before)
    wire [9:0] freq_word;
    assign freq_word = (freq_select == 2'b00) ? 10'd5 :    // ~300Hz: (5 * 100000)/1024 = 488Hz
                      (freq_select == 2'b01) ? 10'd41 :   // 4kHz: (41 * 100000)/1024 = 4004Hz
                      (freq_select == 2'b10) ? 10'd102 :  // 10kHz: (102 * 100000)/1024 = 9961Hz
                      10'd10;                             // Default ~1kHz

    // Internal signals
    wire signed [7:0] original_wave;
    wire signed [15:0] filtered_wave;  
    wire [7:0] pwm_audio_input_original;
    wire [7:0] pwm_audio_input_filtered;
    wire [7:0] final_pwm_audio_input;

    // Enhanced audio system with wave selection
    audio_system_top audio_system (
        .clk(clk_100kHz),
        .reset(reset),
        .freq_word(freq_word),
        .wave_select(wave_select),      // NEW: Sine/Square selection
        .original_wave(original_wave),
        .filtered_wave(filtered_wave),
        .pwm_audio_input_original(pwm_audio_input_original),
        .pwm_audio_input_filtered(pwm_audio_input_filtered)
    );

    // Mode selection: Choose between original and filtered audio
    assign final_pwm_audio_input = (mode_select == 1'b0) ? pwm_audio_input_original : pwm_audio_input_filtered;

    // High resolution PWM
    pwm_generator_high_res pwm_inst (
        .clk(clk),                     // 100MHz clock for PWM
        .reset(reset),
        .audio_input(final_pwm_audio_input),
        .pwm_out(pwm_speaker_out)
    );

endmodule