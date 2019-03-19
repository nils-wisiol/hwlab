`timescale 1ns / 1ps

module Echo_tb();

integer i;

reg clk_tb;
reg rst_tb;
wire [7:0] data;
wire rdy_tb;
reg rx_tb;
wire tx_tb;
wire valid_tb;

wire [1:0] tx_state_tb;

reg [7:0] data_to_be_sent;

Receiver r(
	.clk(clk_tb),
	.rst(rst_tb),
	.din(rx_tb),
	.data_rx(data),
	.valid(valid_tb)
	);

Transmitter t(
	.clk(clk_tb),
	.rst(rst_tb),
	.en(valid_tb),
	.data_tx(data),
	.rdy(rdy_tb),
	.dout(tx_tb),
	.state(tx_state_tb)
	);

always begin
	#15.625 clk_tb <= ~clk_tb;
end

initial begin
    clk_tb <= 0;
    rx_tb <= 1;
    #20 rst_tb <= 1;
  	 #40 rst_tb <= 0;
	 
    data_to_be_sent <= 8'd42;
	 #135 rx_tb <= 8'd0; // start bit
    for (i=0; i<8; i = i+1) begin
        #8680.5 rx_tb <= data_to_be_sent[i];
    end 
    #8680.5 rx_tb <= 1; // stop bit
	 
	 data_to_be_sent <= 8'd88;
    #8680.5 rx_tb <= 8'd0; // start bit
    for (i=0; i<8; i = i+1) begin
        #8680.5 rx_tb <= data_to_be_sent[i];
    end 
    #8680.5 rx_tb <= 1; // stop bit	 
end

endmodule