`timescale 1ns / 1ps

module tone_rom (
    input wire clk,                // 100kHz clock
    input wire reset,              // Active high reset
    input wire tone_select,        // 0 = 2kHz, 1 = 6kHz
    output reg signed [7:0] audio_out  // 8-bit signed audio output
);

    // Internal counters
    reg [5:0] counter_2khz;  // 0 to 63 (64 samples)
    reg [3:0] counter_6khz;  // 0 to 15 (16 samples)
    
    // ROM for 2kHz tone (64 samples of one sine wave cycle)
    reg signed [7:0] rom_2khz [0:63];
    
    // ROM for 6kHz tone (16 samples of one sine wave cycle)
    reg signed [7:0] rom_6khz [0:15];
    
    // ================================================
    // ROM INITIALIZATION - ALREADY FILLED VALUES
    // ================================================
    initial begin
        // 2kHz Tone ROM (64 samples) - Already calculated values
        rom_2khz[0] = 8'd0;      rom_2khz[32] = 8'd0;
        rom_2khz[1] = 8'd12;     rom_2khz[33] = -8'd12;
        rom_2khz[2] = 8'd25;     rom_2khz[34] = -8'd25;
        rom_2khz[3] = 8'd37;     rom_2khz[35] = -8'd37;
        rom_2khz[4] = 8'd49;     rom_2khz[36] = -8'd49;
        rom_2khz[5] = 8'd60;     rom_2khz[37] = -8'd60;
        rom_2khz[6] = 8'd71;     rom_2khz[38] = -8'd71;
        rom_2khz[7] = 8'd81;     rom_2khz[39] = -8'd81;
        rom_2khz[8] = 8'd90;     rom_2khz[40] = -8'd90;
        rom_2khz[9] = 8'd98;     rom_2khz[41] = -8'd98;
        rom_2khz[10] = 8'd106;   rom_2khz[42] = -8'd106;
        rom_2khz[11] = 8'd112;   rom_2khz[43] = -8'd112;
        rom_2khz[12] = 8'd117;   rom_2khz[44] = -8'd117;
        rom_2khz[13] = 8'd121;   rom_2khz[45] = -8'd121;
        rom_2khz[14] = 8'd124;   rom_2khz[46] = -8'd124;
        rom_2khz[15] = 8'd126;   rom_2khz[47] = -8'd126;
        rom_2khz[16] = 8'd127;   rom_2khz[48] = -8'd127;
        rom_2khz[17] = 8'd126;   rom_2khz[49] = -8'd126;
        rom_2khz[18] = 8'd124;   rom_2khz[50] = -8'd124;
        rom_2khz[19] = 8'd121;   rom_2khz[51] = -8'd121;
        rom_2khz[20] = 8'd117;   rom_2khz[52] = -8'd117;
        rom_2khz[21] = 8'd112;   rom_2khz[53] = -8'd112;
        rom_2khz[22] = 8'd106;   rom_2khz[54] = -8'd106;
        rom_2khz[23] = 8'd98;    rom_2khz[55] = -8'd98;
        rom_2khz[24] = 8'd90;    rom_2khz[56] = -8'd90;
        rom_2khz[25] = 8'd81;    rom_2khz[57] = -8'd81;
        rom_2khz[26] = 8'd71;    rom_2khz[58] = -8'd71;
        rom_2khz[27] = 8'd60;    rom_2khz[59] = -8'd60;
        rom_2khz[28] = 8'd49;    rom_2khz[60] = -8'd49;
        rom_2khz[29] = 8'd37;    rom_2khz[61] = -8'd37;
        rom_2khz[30] = 8'd25;    rom_2khz[62] = -8'd25;
        rom_2khz[31] = 8'd12;    rom_2khz[63] = -8'd12;
        
        // 6kHz Tone ROM (16 samples)
        rom_6khz[0] = 8'd0;      rom_6khz[8] = 8'd0;
        rom_6khz[1] = 8'd49;     rom_6khz[9] = -8'd49;
        rom_6khz[2] = 8'd90;     rom_6khz[10] = -8'd90;
        rom_6khz[3] = 8'd117;    rom_6khz[11] = -8'd117;
        rom_6khz[4] = 8'd127;    rom_6khz[12] = -8'd127;
        rom_6khz[5] = 8'd117;    rom_6khz[13] = -8'd117;
        rom_6khz[6] = 8'd90;     rom_6khz[14] = -8'd90;
        rom_6khz[7] = 8'd49;     rom_6khz[15] = -8'd49;
    end
    
    // ================================================
    // MAIN PROCESS: Read from ROM
    // ================================================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter_2khz <= 0;
            counter_6khz <= 0;
            audio_out <= 0;
        end else begin
            if (tone_select == 1'b0) begin
                // 2kHz tone - read from 64-entry ROM
                counter_2khz <= counter_2khz + 1;
                audio_out <= rom_2khz[counter_2khz];
            end else begin
                // 6kHz tone - read from 16-entry ROM
                counter_6khz <= counter_6khz + 1;
                audio_out <= rom_6khz[counter_6khz];
            end
        end
    end
endmodule