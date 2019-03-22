`timescale 1ns / 1ps

module Shift(
    input wire clk,
    input wire en,
    input wire [7:0] data,
    output reg [47:0] buffer, // shift register for "incorr" 6bytes
    output reg do_reset
    );

initial begin
	buffer <= 48'd0;
	do_reset <= 0;
end


always @(posedge clk)
begin
    if (en) begin
        buffer[47:40] <= buffer[39:32];
        buffer[39:32] <= buffer[31:24];
        buffer[31:24] <= buffer[23:16];
        buffer[23:16] <= buffer[15:8];
        buffer[15:8] <= buffer[7:0];
        buffer[7:0] <= data;
        
        if (buffer[47:40]==8'd73  //73 0 I; 105 = i 
            && buffer[39:32]==8'd110 //110 = n
            && buffer[31:24]==8'd99 //99 = c
            && buffer[23:16]==8'd111  //111 = o
            && buffer[15:8]==8'd114 //114 = r
            && buffer[7:0]==8'd114
            ) begin
            do_reset <= 1;
        end else begin
            do_reset <=0;
        end
               
    end
end

endmodule
