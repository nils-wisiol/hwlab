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
	output reg [2:0] index, // exposted just for debugging
	output reg [1:0] state, // exposted just for debugging
	output reg [8:0] counter, // exposted just for debugging
	output reg rdy,
	output reg dout
	);
	
always @(posedge clk)
begin
	if (rst) begin
		state <= `STATE_READY;
		counter <= 0;
		rdy <= 1;
		dout <= 1;
	end else begin
		
		case (state)
			`STATE_READY: begin
				counter <= 0;
				rdy <= 1;
				dout <= 1;
				index <= 0;
				if (en) begin
					state <= `STATE_SEND_START_BIT;
				end else begin
					state <= `STATE_READY;
				end
			end
			`STATE_SEND_START_BIT: begin
				rdy <= 0;
				dout <= 0;
				index <= 0;
				if (counter < 278) begin
					counter <= counter + 1;
					state <= `STATE_SEND_START_BIT;
				end else begin
					counter <= 0;
					state <= `STATE_SEND_DATA;
				end
			end
			`STATE_SEND_DATA: begin
				rdy <= 0;
				dout <= data_tx[index];
				if (counter < 278) begin
					counter <= counter + 1;
					index <= index;
					state <= `STATE_SEND_DATA;
				end else begin
					if (index < 7) begin
						index <= index + 1;
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
					counter <= counter + 1;
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
