`timescale 1ns / 1ps

module dds_sine_generator (
    input wire clk,                    // 1MHz master clock
    input wire reset,                  // Active high reset
    input wire [9:0] freq_word,        // 10-bit frequency control word
    output reg signed [7:0] sine_out   // 8-bit signed sine wave output (-128 to 127)
);
    
    // INTERNAL REGISTERS
    reg [9:0] phase_accum;             // 10-bit phase accumulator
    reg [9:0] phase_reg;               // 10-bit phase register
    
    // 64-entry × 8-bit Signed Sine LUT (-128 to 127 range)
    reg signed [7:0] sine_lut [0:63];
    
    // SINE LUT INITIALIZATION - Scaled to 8-bit signed range (-128 to 127)
    initial begin
        // Quarter sine wave scaled to 8-bit signed
        sine_lut[0] = 8'd0;      sine_lut[1] = 8'd12;     sine_lut[2] = 8'd25;
        sine_lut[3] = 8'd37;     sine_lut[4] = 8'd49;     sine_lut[5] = 8'd60;
        sine_lut[6] = 8'd71;     sine_lut[7] = 8'd81;     sine_lut[8] = 8'd90;
        sine_lut[9] = 8'd98;     sine_lut[10] = 8'd106;   sine_lut[11] = 8'd112;
        sine_lut[12] = 8'd117;   sine_lut[13] = 8'd121;   sine_lut[14] = 8'd124;
        sine_lut[15] = 8'd126;   sine_lut[16] = 8'd127;   sine_lut[17] = 8'd126;
        sine_lut[18] = 8'd124;   sine_lut[19] = 8'd121;   sine_lut[20] = 8'd117;
        sine_lut[21] = 8'd112;   sine_lut[22] = 8'd106;   sine_lut[23] = 8'd98;
        sine_lut[24] = 8'd90;    sine_lut[25] = 8'd81;    sine_lut[26] = 8'd71;
        sine_lut[27] = 8'd60;    sine_lut[28] = 8'd49;    sine_lut[29] = 8'd37;
        sine_lut[30] = 8'd25;    sine_lut[31] = 8'd12;    sine_lut[32] = 8'd0;
        sine_lut[33] = -8'd12;   sine_lut[34] = -8'd25;   sine_lut[35] = -8'd37;
        sine_lut[36] = -8'd49;   sine_lut[37] = -8'd60;   sine_lut[38] = -8'd71;
        sine_lut[39] = -8'd81;   sine_lut[40] = -8'd90;   sine_lut[41] = -8'd98;
        sine_lut[42] = -8'd106;  sine_lut[43] = -8'd112;  sine_lut[44] = -8'd117;
        sine_lut[45] = -8'd121;  sine_lut[46] = -8'd124;  sine_lut[47] = -8'd126;
        sine_lut[48] = -8'd127;  sine_lut[49] = -8'd126;  sine_lut[50] = -8'd124;
        sine_lut[51] = -8'd121;  sine_lut[52] = -8'd117;  sine_lut[53] = -8'd112;
        sine_lut[54] = -8'd106;  sine_lut[55] = -8'd98;   sine_lut[56] = -8'd90;
        sine_lut[57] = -8'd81;   sine_lut[58] = -8'd71;   sine_lut[59] = -8'd60;
        sine_lut[60] = -8'd49;   sine_lut[61] = -8'd37;   sine_lut[62] = -8'd25;
        sine_lut[63] = -8'd12;
    end
    
    // MAIN CLOCKED PROCESS
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            phase_accum <= 10'b0;
            phase_reg   <= 10'b0;
            sine_out    <= 8'b0;
        end else begin
            // Phase accumulation
            phase_accum <= phase_accum + freq_word;
            phase_reg <= phase_accum;
            
            // Sine lookup using top 6 bits for 64-entry LUT
            sine_out <= sine_lut[phase_reg[9:4]];
        end
    end
    
endmodule