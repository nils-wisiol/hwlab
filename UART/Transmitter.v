`timescale 1ns / 1ps
`define STATE_READY 2'd0
`define STATE_SEND_START_BIT 2'd1
`define STATE_SEND_DATA 2'd2
`define STATE_SEND_STOP_BIT 2'd3

module Transmitter(
	input wire clk,
	input wire rst,
	input wire en,
	input wire [7:0] data_tx,
	output reg rdy,
	output reg dout
	);

reg [2:0] index;
reg [1:0] state;
reg [8:0] counter;

	
initial begin
	state <= `STATE_READY;
	counter <= 9'd0;
	rdy <= 1;
	dout <= 1;
end

always @(posedge clk)
begin
	if (rst) begin
		state <= `STATE_READY;
		counter <= 9'd0;
		rdy <= 1;
		dout <= 1;
	end else begin
		
		case (state)
			`STATE_READY: begin
				counter <= 9'd0;
				rdy <= 1;
				dout <= 1;
				index <= 3'd0;
				if (en) begin
					state <= `STATE_SEND_START_BIT;
				end else begin
					state <= `STATE_READY;
				end
			end
			`STATE_SEND_START_BIT: begin
				rdy <= 0;
				dout <= 0;
				index <= 3'd0;
				if (counter < 278) begin
					counter <= counter + 9'd1;
					state <= `STATE_SEND_START_BIT;
				end else begin
					counter <= 0;
					state <= `STATE_SEND_DATA;
				end
			end
			`STATE_SEND_DATA: begin
				rdy <= 0;
				if (counter == 0) begin
					dout <= data_tx[index];
				end else begin
					dout <= dout;
				end
				if (counter < 278) begin
					counter <= counter + 9'd1;
					index <= index;
					state <= `STATE_SEND_DATA;
				end else begin
					if (index < 7) begin
						index <= index + 3'd1;
						counter <= 0;
						state <= `STATE_SEND_DATA;
					end else begin
						index <= 0;
						counter <= 0;
						state <= `STATE_SEND_STOP_BIT;
					end
				end
			end
			`STATE_SEND_STOP_BIT: begin
				rdy <= 0;
				dout <= 1;
				index <= 0;
				if (counter < 278) begin
					counter <= counter + 9'd1;
					state <= `STATE_SEND_STOP_BIT;
				end else begin
					counter <= 0;
					state <= `STATE_READY;
				end
			end
		endcase
		
	end
end


endmodule
