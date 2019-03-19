`timescale 1ns / 1ps

module Echo(
	input wire CLK,
	input wire RX,
	output wire TX
);

reg rst = 0;
wire [7:0] data;
wire rdy_tb;
wire valid_tb;

Receiver r(
	.clk(CLK),
	.rst(rst),
	.din(RX),
	.data_rx(data),
	.valid(valid_tb)
	);

Transmitter t(
	.clk(CLK),
	.rst(rst),
	.en(valid_tb),
	.data_tx(data),
	.rdy(rdy_tb),
	.dout(TX)
	);

initial begin
	
end

endmodule