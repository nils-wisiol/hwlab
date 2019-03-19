`timescale 1ns / 1ps
`define STATE_READY 2'd0
`define STATE_REC_START_BIT 2'd1
`define STATE_REC_DATA 2'd2
`define STATE_REC_STOP_BIT 2'd3

module Receiver(
	input wire clk,
	input wire rst,
	input wire din,
	output reg [7:0] data_rx,
	output reg [2:0] index, // exposted just for debugging
	output reg [1:0] state, // exposted just for debugging
	output reg [8:0] counter, // exposted just for debugging
	output reg valid
	);
    
always @(posedge clk)
begin
	if (rst) begin
		state <= `STATE_READY;
		counter <= 9'd0;
		index <= 3'd0;
		if (din) begin
			valid <= 1;
		end else begin
			valid <= 0;
		end 
		data_rx <= 8'd0;
	end else begin
		
		case (state)
			`STATE_READY: begin
				counter <= 9'd0;
				valid <= valid;
				data_rx <= data_rx;
				index <= 3'd0;
				if (~din) begin
					state <= `STATE_REC_START_BIT;
				end else begin
					state <= `STATE_READY;
				end
			end
			`STATE_REC_START_BIT: begin
				data_rx <= 8'd0;
				index <= 3'd0;
            valid <= 0;
				if (counter < 278) begin
					counter <= counter + 9'd1;
					if (counter == 139 && din) begin
						state <= `STATE_READY;
					end else begin
						state <= `STATE_REC_START_BIT; 
					end
				end else begin
					counter <= 9'd0;
					state <= `STATE_REC_DATA;
				end
			end
			`STATE_REC_DATA: begin
            valid <= 0;
				if (counter < 278) begin
					counter <= counter + 9'd1;
					if (counter == 139) begin
						data_rx[index] <= din;
					end else begin
						data_rx <= data_rx;
					end
					state <= state;
				end else begin
					counter <= 9'd0;
					if (index < 7) begin
						index <= index + 3'd1;
						state <= `STATE_REC_DATA;
					end else begin
						index <= 0;
						state <= `STATE_REC_STOP_BIT;
					end
				end
			end
			`STATE_REC_STOP_BIT: begin
				index <= 3'd0;
				data_rx <= data_rx;
				if (counter < 278) begin
					counter <= counter + 9'd1;
					valid <= 0;
					if (counter == 139 && ~din) begin
						state <= `STATE_READY;
					end else begin
						state <= `STATE_REC_STOP_BIT; 
					end
				end else begin
					counter <= 9'd0;
					valid <= 1;
					state <= `STATE_READY;
				end
			end
		endcase
		
	end
end

endmodule
