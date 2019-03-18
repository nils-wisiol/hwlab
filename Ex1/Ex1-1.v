`timescale 1ns / 1ps

module Ex11(
    input wire A,
    input wire B,
    output wire S,
    output wire C
    );

assign S = A ^ B;
assign C = A & B;

endmodule
