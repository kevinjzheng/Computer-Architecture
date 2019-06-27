`include "alu.v"
module calc(clk, Reset , B, Op, Result);
  input clk;
  input Reset;
  input [3:0] B;
  input [2:0] Op;
  output [3:0] Result;

  wire[3:0] AluOut;
  reg[3:0] state;
  
  alu alu1(state, B, Op, AluOut);

  always @(posedge clk) begin
    if (Reset)
      state <= 4'b0000;
    else
      state <= AluOut;
  end

  assign Result = state;


endmodule // calc
