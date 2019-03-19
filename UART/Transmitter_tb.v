`timescale 1ns / 1ps

module Transmitter_tb();

reg clk_tb;
reg rst_tb;
reg en_tb;
reg [7:0] data_tx_tb;
wire [2:0] index_tb;
wire [1:0] state_tb;
wire [8:0] counter_tb;
wire rdy_tb;
wire dout_tb;

Transmitter foobar(
	.clk(clk_tb),
	.rst(rst_tb),
	.en(en_tb),
	.data_tx(data_tx_tb),
	.index(index_tb),
	.state(state_tb),
	.counter(counter_tb),
	.rdy(rdy_tb),
	.dout(dout_tb)
	);

always begin
	#15.625 clk_tb <= ~clk_tb;
end

initial begin
   clk_tb <= 0;
	rst_tb <= 0;
	data_tx_tb <= 8'd255;
	#40 rst_tb <= 1;
	#40 rst_tb <= 0;
	#50 en_tb <= 1;
	#70 en_tb <= 0;
end

endmodule
