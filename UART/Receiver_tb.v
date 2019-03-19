`timescale 1ns / 1ps

module Receiver_tb();

reg clk_tb;
reg rst_tb;
reg din_tb;
reg [7:0] data_tx_tb;
integer i;
wire [7:0] data_rx_tb;
wire [2:0] index_tb; // exposted just for debugging
wire [1:0] state_tb; // exposted just for debugging
wire [8:0] counter_tb; // exposted just for debugging
wire valid_tb;

Receiver foobar(
	.clk(clk_tb),
	.rst(rst_tb),
	.din(din_tb),
	.data_rx(data_rx_tb),
	.index(index_tb),
	.state(state_tb),
	.counter(counter_tb),
	.valid(valid_tb)
	);

always begin
	#15.625 clk_tb <= ~clk_tb; // 32MHz
end

initial begin
    clk_tb <= 0;
    din_tb <= 1;
    #20 rst_tb <= 1;
    data_tx_tb <= 8'd42;
    #40 rst_tb <= 0;
    #135 din_tb <= 8'd0; // start bit
    for (i=0; i<8; i = i+1) begin
        #8680.5 din_tb <= data_tx_tb[i];
    end 
    #8680.5 din_tb <= 1;
end

endmodule
