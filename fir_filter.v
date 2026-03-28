`timescale 1ns / 1ps

module fir_filter (
    output reg signed [15:0] Data_out,
    input  signed [7:0] Data_in,
    input clk,
    input reset
);

    parameter order = 51;
    parameter word_size_in  = 8;
    parameter word_size_out = 16;     
    
    parameter signed [7:0] b0  = 8'd6;
    parameter signed [7:0] b1  = 8'd7;
    parameter signed [7:0] b2  = 8'd8;
    parameter signed [7:0] b3  = 8'd10;
    parameter signed [7:0] b4  = 8'd13;
    parameter signed [7:0] b5  = 8'd16;
    parameter signed [7:0] b6  = 8'd20;
    parameter signed [7:0] b7  = 8'd25;
    parameter signed [7:0] b8  = 8'd31;
    parameter signed [7:0] b9  = 8'd37;
    parameter signed [7:0] b10 = 8'd43;
    parameter signed [7:0] b11 = 8'd50;
    parameter signed [7:0] b12 = 8'd58;
    parameter signed [7:0] b13 = 8'd66;
    parameter signed [7:0] b14 = 8'd73;
    parameter signed [7:0] b15 = 8'd81;
    parameter signed [7:0] b16 = 8'd89;
    parameter signed [7:0] b17 = 8'd96;
    parameter signed [7:0] b18 = 8'd102;
    parameter signed [7:0] b19 = 8'd109;
    parameter signed [7:0] b20 = 8'd114;
    parameter signed [7:0] b21 = 8'd119;
    parameter signed [7:0] b22 = 8'd122;
    parameter signed [7:0] b23 = 8'd125;
    parameter signed [7:0] b24 = 8'd126;
    parameter signed [7:0] b25 = 8'd127;
    parameter signed [7:0] b26 = 8'd126;
    parameter signed [7:0] b27 = 8'd125;
    parameter signed [7:0] b28 = 8'd122;
    parameter signed [7:0] b29 = 8'd119;
    parameter signed [7:0] b30 = 8'd114;
    parameter signed [7:0] b31 = 8'd109;
    parameter signed [7:0] b32 = 8'd102;
    parameter signed [7:0] b33 = 8'd96;
    parameter signed [7:0] b34 = 8'd89;
    parameter signed [7:0] b35 = 8'd81;
    parameter signed [7:0] b36 = 8'd73;
    parameter signed [7:0] b37 = 8'd66;
    parameter signed [7:0] b38 = 8'd58;
    parameter signed [7:0] b39 = 8'd50;
    parameter signed [7:0] b40 = 8'd43;
    parameter signed [7:0] b41 = 8'd37;
    parameter signed [7:0] b42 = 8'd31;
    parameter signed [7:0] b43 = 8'd25;
    parameter signed [7:0] b44 = 8'd20;
    parameter signed [7:0] b45 = 8'd16;
    parameter signed [7:0] b46 = 8'd13;
    parameter signed [7:0] b47 = 8'd10;
    parameter signed [7:0] b48 = 8'd8;
    parameter signed [7:0] b49 = 8'd7;
    parameter signed [7:0] b50 = 8'd6;

    reg signed [7:0] Samples [0:order-1];
    integer k;
    
    wire signed [15:0] prod [0:order-1];
    wire signed [23:0] accumulator;

    assign prod[0]  = b0  * Samples[0];
    assign prod[1]  = b1  * Samples[1];
    assign prod[2]  = b2  * Samples[2];
    assign prod[3]  = b3  * Samples[3];
    assign prod[4]  = b4  * Samples[4];
    assign prod[5]  = b5  * Samples[5];
    assign prod[6]  = b6  * Samples[6];
    assign prod[7]  = b7  * Samples[7];
    assign prod[8]  = b8  * Samples[8];
    assign prod[9]  = b9  * Samples[9];
    assign prod[10] = b10 * Samples[10];
    assign prod[11] = b11 * Samples[11];
    assign prod[12] = b12 * Samples[12];
    assign prod[13] = b13 * Samples[13];
    assign prod[14] = b14 * Samples[14];
    assign prod[15] = b15 * Samples[15];
    assign prod[16] = b16 * Samples[16];
    assign prod[17] = b17 * Samples[17];
    assign prod[18] = b18 * Samples[18];
    assign prod[19] = b19 * Samples[19];
    assign prod[20] = b20 * Samples[20];
    assign prod[21] = b21 * Samples[21];
    assign prod[22] = b22 * Samples[22];
    assign prod[23] = b23 * Samples[23];
    assign prod[24] = b24 * Samples[24];
    assign prod[25] = b25 * Samples[25];
    assign prod[26] = b26 * Samples[26];
    assign prod[27] = b27 * Samples[27];
    assign prod[28] = b28 * Samples[28];
    assign prod[29] = b29 * Samples[29];
    assign prod[30] = b30 * Samples[30];
    assign prod[31] = b31 * Samples[31];
    assign prod[32] = b32 * Samples[32];
    assign prod[33] = b33 * Samples[33];
    assign prod[34] = b34 * Samples[34];
    assign prod[35] = b35 * Samples[35];
    assign prod[36] = b36 * Samples[36];
    assign prod[37] = b37 * Samples[37];
    assign prod[38] = b38 * Samples[38];
    assign prod[39] = b39 * Samples[39];
    assign prod[40] = b40 * Samples[40];
    assign prod[41] = b41 * Samples[41];
    assign prod[42] = b42 * Samples[42];
    assign prod[43] = b43 * Samples[43];
    assign prod[44] = b44 * Samples[44];
    assign prod[45] = b45 * Samples[45];
    assign prod[46] = b46 * Samples[46];
    assign prod[47] = b47 * Samples[47];
    assign prod[48] = b48 * Samples[48];
    assign prod[49] = b49 * Samples[49];
    assign prod[50] = b50 * Samples[50];

    assign accumulator = 
        {{8{prod[0][15]}}, prod[0]} + {{8{prod[1][15]}}, prod[1]} +
        {{8{prod[2][15]}}, prod[2]} + {{8{prod[3][15]}}, prod[3]} +
        {{8{prod[4][15]}}, prod[4]} + {{8{prod[5][15]}}, prod[5]} +
        {{8{prod[6][15]}}, prod[6]} + {{8{prod[7][15]}}, prod[7]} +
        {{8{prod[8][15]}}, prod[8]} + {{8{prod[9][15]}}, prod[9]} +
        {{8{prod[10][15]}}, prod[10]} + {{8{prod[11][15]}}, prod[11]} +
        {{8{prod[12][15]}}, prod[12]} + {{8{prod[13][15]}}, prod[13]} +
        {{8{prod[14][15]}}, prod[14]} + {{8{prod[15][15]}}, prod[15]} +
        {{8{prod[16][15]}}, prod[16]} + {{8{prod[17][15]}}, prod[17]} +
        {{8{prod[18][15]}}, prod[18]} + {{8{prod[19][15]}}, prod[19]} +
        {{8{prod[20][15]}}, prod[20]} + {{8{prod[21][15]}}, prod[21]} +
        {{8{prod[22][15]}}, prod[22]} + {{8{prod[23][15]}}, prod[23]} +
        {{8{prod[24][15]}}, prod[24]} + {{8{prod[25][15]}}, prod[25]} +
        {{8{prod[26][15]}}, prod[26]} + {{8{prod[27][15]}}, prod[27]} +
        {{8{prod[28][15]}}, prod[28]} + {{8{prod[29][15]}}, prod[29]} +
        {{8{prod[30][15]}}, prod[30]} + {{8{prod[31][15]}}, prod[31]} +
        {{8{prod[32][15]}}, prod[32]} + {{8{prod[33][15]}}, prod[33]} +
        {{8{prod[34][15]}}, prod[34]} + {{8{prod[35][15]}}, prod[35]} +
        {{8{prod[36][15]}}, prod[36]} + {{8{prod[37][15]}}, prod[37]} +
        {{8{prod[38][15]}}, prod[38]} + {{8{prod[39][15]}}, prod[39]} +
        {{8{prod[40][15]}}, prod[40]} + {{8{prod[41][15]}}, prod[41]} +
        {{8{prod[42][15]}}, prod[42]} + {{8{prod[43][15]}}, prod[43]} +
        {{8{prod[44][15]}}, prod[44]} + {{8{prod[45][15]}}, prod[45]} +
        {{8{prod[46][15]}}, prod[46]} + {{8{prod[47][15]}}, prod[47]} +
        {{8{prod[48][15]}}, prod[48]} + {{8{prod[49][15]}}, prod[49]} +
        {{8{prod[50][15]}}, prod[50]};

    always @(posedge clk) begin
        if (reset) begin
            Data_out <= 0;
        end else begin
            Data_out <= accumulator[23:8];
        end
    end

    always @(posedge clk) begin
        if (reset) begin
            for (k = 0; k < order; k = k + 1)
                Samples[k] <= 0;
        end else begin
            for (k = order-1; k > 0; k = k - 1)
                Samples[k] <= Samples[k-1];
            Samples[0] <= Data_in;
        end
    end
endmodule