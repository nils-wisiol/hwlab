`timescale 1ns / 1ps
`define STATE_OFF 2'd0
`define STATE_ALL_GREEN 2'd1
`define STATE_NORMAL 2'd2

module Mitm(
	input wire CLK,
	
	input wire RX,
	output wire TX,
	
	output wire C4, // BS
	output wire C5, // BG
	
	input wire C6, // BS
	input wire C7, // BG
	
	output reg LED1
);

reg [1:0] state = 2'd0;

reg rst = 0;
wire [7:0] data;
wire usb_data_trigger;

wire [7:0] bs_data_rx;
reg [7:0] bs_data_tx;
reg bs_en;
wire bs_data_trigger;

wire [7:0] bg_data_rx;
reg [7:0] bg_data_tx;
reg bg_en;
wire bg_data_trigger;

Receiver r_usb(
	.clk(CLK),
	.rst(rst),
	.din(RX),
	.data_rx(data),
	.valid(usb_data_trigger)
	);

Transmitter t_usb(
	.clk(CLK),
	.rst(rst),
	.en(usb_data_trigger),
	.data_tx(data),
	.dout(TX)
	);

Transmitter t_bs(
	.clk(CLK),
	.rst(rst),
	.en(bs_en),
	.data_tx(bs_data_tx),
	.dout(C4)
	);
	
Receiver r_bs(
	.clk(CLK),
	.rst(rst),
	.din(C6),
	.data_rx(bs_data_rx),
	.valid(bs_data_trigger)
	);

Transmitter t_bg(
	.clk(CLK),
	.rst(rst),
	.en(bg_en),
	.data_tx(bg_data_tx),
	.dout(C5)
	);
	
Receiver r_bg(
	.clk(CLK),
	.rst(rst),
	.din(C7),
	.data_rx(bg_data_rx),
	.valid(bg_data_trigger)
	);


always @(posedge CLK) begin
	if (usb_data_trigger) begin
		if (data == 8'd71) begin // G
			LED1 <= ~LED1;
			state <= `STATE_ALL_GREEN;
		end else if (data == 8'd78) begin // N
			LED1 <= ~LED1;
			state <= `STATE_NORMAL;
		end else if (data == 8'd79) begin // O
			LED1 <= ~LED1;
			state <= `STATE_OFF;
		end
	end
	
	case (state)
	`STATE_ALL_GREEN: begin
		bg_data_tx <= 8'd71;
		bg_en <= 1;
		bs_data_tx <= 8'd71;
		bs_en <= 1;
	end
	`STATE_NORMAL: begin
		bs_data_tx <= bs_data_tx;
		bg_data_tx <= bg_data_tx;
		bs_en <= 0;
		bg_en <= 0;
		if (bs_data_trigger) begin
			bg_data_tx <= bs_data_rx;
			bg_en <= 1;
		end else if (bg_data_trigger) begin
			bs_data_tx <= bg_data_rx;
			bs_en <= 1;
		end
	end
	`STATE_OFF: begin
		bs_data_tx <= 8'd0;
		bg_data_tx <= 8'd0;
		bs_en <= 0;
		bg_en <= 0;
	end
	endcase
	
end

endmodule