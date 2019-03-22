`timescale 1ns / 1ps
module Codegen(
    input wire clk,
    output reg counter
    );

initial begin
	counter <= 32; // chars 32 to 126
end


always @(posedge clk)
begin
    if (en) begin
        counter <= counter +1;
    end
end

endmodule
