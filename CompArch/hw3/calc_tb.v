`timescale 1ns/100ps
`default_nettype none

`include "calc.v"

module calc_tb();

   reg signed [3:0]  A = 4'b0;
   reg [2:0] Op;
   reg reset = 1'b1;
   wire signed [3:0] S_actual;
   reg clk = 1'b0;

   always #10
      clk <= ~clk;

   task test;
      input signed[3:0] val;
      input[2:0] op;
      input signed[3:0] expected;
      begin
        reset <= 1'b0;
        A <= val;
        Op <= op;
        #20 if (S_actual !== expected) begin
          $display("When doing operation %b, value %d, got unexpected result %d", Op, val, S_actual);
        end
      end
   endtask

   calc my_calc(clk, reset, A, Op, S_actual);

   initial begin

      $dumpfile("calc_tb.vcd");
      $dumpvars(0, my_calc);

      #20
      test(5, 3'b010, 5);    // +5 = 5
      test(2, 3'b010, 7);    // +2 = 7
      test(1, 3'b100, 6);    // &~1 = 6
      test(-2, 3'b001, -2);  // |-2 = -2
      test(1, 3'b010, -1);   // +1 = -1
      test(1, 3'b010, 0);    // +1 = 0
      test(1, 3'b010, 1);    // +1 = 1
      test(1, 3'b010, 2);    // +1 = 2
      test(4, 3'b111, 1);    // <4 = 1
      test(3, 3'b110, -2);    // -3 = -2


      #20 $finish;

   end

endmodule
