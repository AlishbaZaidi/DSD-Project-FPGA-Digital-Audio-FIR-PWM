`timescale 1ns / 1ps

module audio_system_top (
    input wire clk,                    // 100kHz clock
    input wire reset,
    input wire [9:0] freq_word,
    input wire wave_select,            // NEW: 0 = Sine, 1 = Square (using W2 button)
    
    output wire signed [7:0] original_wave,
    output wire signed [15:0] filtered_wave,  
    output wire [7:0] pwm_audio_input_original,
    output wire [7:0] pwm_audio_input_filtered
);

    // Waveform generator outputs
    wire signed [7:0] dds_sine_out;
    wire signed [7:0] square_wave_out;
    wire signed [7:0] selected_wave;
    
    // Filter output
    wire signed [15:0] fir_filter_out;
    
    // ================================================
    // WAVEFORM GENERATORS
    // ================================================
    
    // DDS for sine wave
    dds_sine_generator dds_inst (
        .clk(clk),
        .reset(reset),
        .freq_word(freq_word),
        .sine_out(dds_sine_out)
    );
    
    // Square wave generator (fixed 1kHz)
    square_wave_gen square_inst (
        .clk(clk),
        .reset(reset),
        .sq_out(square_wave_out)
    );
    
    // Wave selection: Sine or Square
    assign selected_wave = (wave_select == 1'b0) ? dds_sine_out : square_wave_out;
    
    // ================================================
    // FIR FILTER
    // ================================================
    
    fir_filter fir_inst (
        .Data_out(fir_filter_out),
        .Data_in(selected_wave),
        .clk(clk),
        .reset(reset)
    );
    
    // ================================================
    // AMPLIFICATION & PWM PREPARATION
    // ================================================
    
    // Original wave -> PWM input
    wire [7:0] original_unsigned = selected_wave + 8'd128;  // Convert to 0-255
    wire [15:0] original_amplified = original_unsigned * 8'd4;
    
    // Filtered wave -> PWM input (with careful scaling)
    wire signed [15:0] abs_filtered = (fir_filter_out[15]) ? (~fir_filter_out + 1) : fir_filter_out;
    wire [7:0] filtered_scaled;
    
    // Frequency-dependent scaling (same as before)
    assign filtered_scaled = 
        (freq_word == 10'd5)   ? (abs_filtered[10:3]) :  // 500Hz
        (freq_word == 10'd10)  ? (abs_filtered[11:4]) :  // 1kHz
        (freq_word == 10'd41)  ? (abs_filtered[12:5]) :  // 4kHz
        (abs_filtered[13:6]);                            // 10kHz
    
    // Final PWM inputs (clipped to 0-255)
    assign pwm_audio_input_original = (original_amplified > 255) ? 8'd255 : original_amplified[7:0];
    assign pwm_audio_input_filtered = filtered_scaled;
    
    // Debug outputs
    assign original_wave = selected_wave;
    assign filtered_wave = fir_filter_out;
    
endmodule