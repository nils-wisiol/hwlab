`timescale 1ns / 1ps
`define STATE_WAIT_FOR_TARGET 3'd0
`define STATE_SEND_BYTE 3'd1 // x16
`define STATE_WAIT_FOR_RDY 3'd2 //x16 begin measure
`define STATE_WAIT_FOR_RESPONSE 3'd3 // end measurement check maximum store index of char
`define STATE_SEND_BYTE_GRACE_PERIOD 3'd4


module Passthrough(
	input wire CLK,
	
	//input wire RX,
	output wire TX,
	
	output wire C4, // BS
	output wire C5, // copy of TX
	
	input wire C6, // BS
	output wire C8, // target reset
	
	output reg LED1,
	
	output wire C15
);

reg rst;
reg [7:0] bs_send_char;
reg bs_send_char_en;
reg bs_send_char_valid;
reg [7:0] usb_send_char;
reg usb_send_char_en;
reg usb_send_char_valid;


wire [7:0] data1;
wire data1_trigger;

wire [7:0] data2;
wire data2_trigger;

wire t_usb_rdy;
wire t_bs_rdy;

reg target_reset;
//wire incorrect;

reg [2:0] state; // exposted just for debugging
reg [3:0] num_bytes = 4'd0; // length of password
reg [12:0] resp_time =13'd0; // measurement of resonse time
reg [12:0] max_resp = 13'd0; // max measurement 
reg [7:0] max_char = 8'd0; // max char 
reg [16:0] timeout; // wait after reset for target to receive password
reg [16:0] grace_timeout; // wait after reset for target to receive password
reg [7:0] current_char;

reg debug;

/*Receiver r_usb(
	.clk(CLK),
	.rst(rst),
	.din(RX),
	.data_rx(data1),
	.valid(data1_trigger)
	);*/

Transmitter t_usb(
	.clk(CLK),
	.rst(rst),
	.rdy(t_usb_rdy),
	.en(usb_send_char_en),
	.data_tx(usb_send_char),
	.dout(TX)
	);

Transmitter t_bs(
	.clk(CLK),
	.rst(rst),
	.rdy(t_bs_rdy),
	.en(bs_send_char_en),
	.data_tx(bs_send_char),
	.dout(C4)
	);
	
/*Receiver r_bs(
	.clk(CLK),
	.rst(rst),
	.din(C6),
	.data_rx(data2),
	.valid(data2_trigger)
	);*/
/*
Shift check_reset(
    .clk(CLK),
    .en(usb_send_char_en),
    .data(usb_send_char),
    .do_reset(incorrect)
    );*/

assign C8 = target_reset;
assign C5 = debug;
assign C15 = t_bs_rdy;

initial begin
    state <= `STATE_WAIT_FOR_TARGET;
    bs_send_char <= 8'd32;
    timeout <= 17'd0;
    num_bytes <=4'd0;
    max_resp <= 13'd0;
    LED1 <=0;
    debug <= 0;
	 rst <= 0;
	 current_char <= 8'd32;
end


always @(posedge CLK) begin
	bs_send_char_en <= 0;  
	usb_send_char_en <= 0;
	target_reset <= 1;
    bs_send_char <= bs_send_char;
	 current_char <= current_char;
    
    case (state)
        `STATE_WAIT_FOR_TARGET: begin
            timeout <= timeout + 17'd1;
            state <= `STATE_WAIT_FOR_TARGET;
            
            //num_bytes <= 8'd16;
            if (timeout == 17'd110000) begin
                state <= `STATE_SEND_BYTE;
					 num_bytes <= 4'd0;
                resp_time <= 13'd0;
                if (current_char == 8'd126) begin
                    current_char <= 8'd32;
                    max_resp <= 0;
                    usb_send_char_en <=1;
                end else begin
                    current_char <= current_char +8'd1;
                end
            end
        end
        `STATE_SEND_BYTE: begin
				if (num_bytes == 8'd0) begin
					bs_send_char <= 8'd72; // H
				end else if (num_bytes == 8'd1) begin
					bs_send_char <= 8'd52; // 4
				end else if (num_bytes == 8'd2) begin
					bs_send_char <= 8'd114; // r
				end else if (num_bytes == 8'd3) begin
					bs_send_char <= 8'd100; // d
				end else if (num_bytes == 8'd4) begin
					bs_send_char <= 8'd99; // c
				end else if (num_bytes == 8'd5) begin
					bs_send_char <= 8'd48; // 0
				end else if (num_bytes == 8'd6) begin
					bs_send_char <= 8'd114; // r
				end else if (num_bytes == 8'd7) begin
					bs_send_char <= 8'd51; // 3
				end else begin
					bs_send_char <= current_char;
				end
            bs_send_char_en <= 1;
            num_bytes <= num_bytes + 5'd1;
            state <= `STATE_SEND_BYTE_GRACE_PERIOD;
				grace_timeout <= 16'd0;
        end
		  `STATE_SEND_BYTE_GRACE_PERIOD: begin
				if (grace_timeout == 16'd1000) begin
					state <= `STATE_WAIT_FOR_RDY;
				end else begin
					grace_timeout <= grace_timeout + 16'd1;
				end
		  end
        `STATE_WAIT_FOR_RDY: begin
            state <= state;
            if (t_bs_rdy && !(num_bytes == 4'd0)) begin
                state <= `STATE_SEND_BYTE;
                num_bytes <= num_bytes;
                //LED1 <= ~LED1;
            end else if (t_bs_rdy) begin
                //LED1 <= ~LED1;
                num_bytes <= 4'd0;
                state <= `STATE_WAIT_FOR_RESPONSE;    
                resp_time <= 13'd0;//begin measurement
					 debug <= 1;
            end
        end
        `STATE_WAIT_FOR_RESPONSE: begin
            //LED1 <= ~LED1;
            state <= state;
            bs_send_char <= bs_send_char;
            resp_time <= resp_time +13'd1;
            if (~C6) begin
					debug <= 0;
                if (resp_time > max_resp) begin
                    LED1 <= 1;
                    max_char <= current_char;
                    max_resp <= resp_time;
                end
                resp_time <=13'd0;
                num_bytes <= 4'd0;
                timeout <= 17'd0;
					 timeout <= timeout + 64 * max_char;
                usb_send_char <= max_char;
                //usb_send_char <= 8'd62;
                state <= `STATE_WAIT_FOR_TARGET;
                target_reset <= 0;
                //LED1 <= ~LED1;
                //usb_send_char_en <=1;
            end
        end
    endcase 
/*	
    if (incorrect) begin
        LED1 <= ~LED1;
        target_reset <= 0;
	end
*/	
/*	if (data1_trigger) begin
        data1_trigger <= 0;
		bs_send_char <= data1;
		bs_send_char_valid <= 1;
	end
	if (t_bs_rdy && bs_send_char_valid) begin
		bs_send_char_en <= 1;
		bs_send_char_valid <= 0;
	end
	
	if (data2_trigger) begin
		usb_send_char <= data2;
		usb_send_char_valid <= 1;
	end
 
	if (t_usb_rdy && usb_send_char_valid) begin
		usb_send_char_en <= 1;
		usb_send_char_valid <= 0;
	end	
*/	
end

endmodule