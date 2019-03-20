`timescale 1ns / 1ps

module Passthrough(
	input wire CLK,
	
	input wire RX,
	output wire TX,
	
	output wire C4, // BS
	output wire C5, // copy of TX
	
	input wire C6, // BS
	output wire C8, // target reset
	
	output reg LED1
);

reg [7:0] data1_buffer;
reg data1_buffer_en;
reg data1_buffer_valid;
reg [7:0] data2_buffer;
reg data2_buffer_en;
reg data2_buffer_valid;

reg rst = 0;
wire [7:0] data1;
wire data1_trigger;

wire [7:0] data2;
wire data2_trigger;

wire t_usb_rdy;
wire t_bs_rdy;

reg target_reset;

Receiver r_usb(
	.clk(CLK),
	.rst(rst),
	.din(RX),
	.data_rx(data1),
	.valid(data1_trigger)
	);

Transmitter t_usb(
	.clk(CLK),
	.rst(rst),
	.rdy(t_usb_rdy),
	.en(data2_buffer_en),
	.data_tx(data2_buffer),
	.dout(TX)
	);

Transmitter t_bs(
	.clk(CLK),
	.rst(rst),
	.rdy(t_bs_rdy),
	.en(data1_buffer_en),
	.data_tx(data1_buffer),
	.dout(C4)
	);
	
Receiver r_bs(
	.clk(CLK),
	.rst(rst),
	.din(C6),
	.data_rx(data2),
	.valid(data2_trigger)
	);

assign C8 = target_reset;
assign C5 = TX;

always @(posedge CLK) begin
	data1_buffer_en <= 0;
	data2_buffer_en <= 0;
	target_reset = 1;
	
	if (data1_trigger) begin
		if (data1 == 8'd65) begin
			LED1 <= ~LED1;
			target_reset = 0;
		end
	end
	
	if (data1_trigger) begin
		data1_buffer <= data1;
		data1_buffer_valid <= 1;
	end
	if (t_bs_rdy && data1_buffer_valid) begin
		data1_buffer_en <= 1;
		data1_buffer_valid <= 0;
	end
	
	if (data2_trigger) begin
		data2_buffer <= data2;
		data2_buffer_valid <= 1;
	end
	if (t_usb_rdy && data2_buffer_valid) begin
		data2_buffer_en <= 1;
		data2_buffer_valid <= 0;
	end	
	
end

endmodule