`include "four_bit_adder.v"

module alu(A, B, Op, S);

   input [3:0]  A;
   input [3:0]  B;
   output [3:0] S;
   input [2:0]  Op;

   wire [3:0] adder_out;
   wire       adder_Cout;

   four_bit_adder the_adder(A, Op[2]?~B:B, Op[2], adder_out, adder_Cout);

   assign S =
      (Op==3'b000) ? A & B :
      (Op==3'b001) ? A | B :
      (Op==3'b010) ? adder_out :
      (Op==3'b100) ? A & ~B :
      (Op==3'b101) ? A | ~B :
      (Op==3'b110) ? adder_out :
      (Op==3'b111) ? { 1'b0,1'b0,1'b0,adder_out[3] } : 0;

endmodule