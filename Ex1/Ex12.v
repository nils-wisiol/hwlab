`timescale 1ns / 1ps

module Ex12(
    input wire A,
    input wire B,
	 input wire Cin,
    output wire S,
    output wire Cout
    );

assign S = A ^ B ^ Cin;
assign Cout = (Cin & (A | B)) | (~Cin & A & B);

endmodule
