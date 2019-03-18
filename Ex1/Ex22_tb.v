`timescale 1ns / 1ps

module Ex22_tb();

reg tb_clk;
reg tb_rst;
reg tb_en;
wire [7:0] tb_cnt;

Ex22 foobar(
	.clk(tb_clk),
	.rst(tb_rst),
	.en(tb_en),
	.cnt(tb_cnt));

initial
begin
	tb_clk <= 1'b0;  // 1 bit, value zero
	tb_rst <= 1'b0;
	tb_en <= 1'b0;
end

always
begin
	#10 tb_clk <= ~tb_clk;
end

initial
begin
	#40 tb_rst <= 1'b1;
	#40 tb_rst <= 1'b0;
end

initial
begin
	#100 tb_en <= 1'b1;
	#100 tb_en <= 1'b0;
end

endmodule
