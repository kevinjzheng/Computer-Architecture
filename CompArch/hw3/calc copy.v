`include "alu.v"
module calc(clk, Reset , B, Op, Result);
  input clk;
  input Reset;
  input [3:0] B;
  output [3:0] Result;
  reg[3:0] state;
  assign B = state ^ 4'b1010;

  alu alu1(state, B, Op, Result)

  always @(posedge clk)
    if (reset)
      state <= 4'b0000;
    else
      state <= Result;
endmodule // calc
