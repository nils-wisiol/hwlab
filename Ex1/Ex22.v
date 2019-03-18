`timescale 1ns / 1ps

module Ex22(
    input wire clk,
    input wire rst,
	 input wire en,
    output reg [7:0] cnt
    );

always @(posedge clk)
begin
	if (rst)
	begin
		cnt <= 8'd0;
	end
	
	else
	begin
		if (en)
		begin
			cnt <= cnt + 1;
		end
	end
end

endmodule
