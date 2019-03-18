`timescale 1ns / 1ps

module Ex12_tb();

reg tb_a;
reg tb_b;
reg tb_cin;
wire tb_s;
wire tb_cout;

Ex12 foobar(
	.A(tb_a),
	.B(tb_b),
	.Cin(tb_cin),
	.S(tb_s),
	.Cout(tb_cout));

initial
begin
	tb_a <= 1'b0;  // 1 bit, value zero
	tb_b <= 1'b0;
	tb_cin <= 1'b0;
end

always
begin
	#50 tb_a <= ~tb_a;
end

always
begin
	#100 tb_b <= ~tb_b;
end

always
begin
	#200 tb_cin<= ~tb_cin;
end

endmodule
