`timescale 1ns/100ps
`include "E15Process_mul.v"

module E15Process_TB;

   reg clk = 0;

   wire [3:0] pc;
   wire [3:0] opCode;
   wire [1:0] src, dst;
   wire [3:0] immData;
   wire [3:0] r0, r1, r2, r3;
   tri [3:0]  mBus, dstBus;

   E15Process proc(clk, pc, opCode, src, dst, immData, 
                   r0, r1, r2, r3, mBus, dstBus);

   always #1
     clk = ~clk;

   initial begin
      $dumpfile("E15Process_tb.vcd");
      $dumpvars(0, E15Process_TB);
      #1000

      $display("Final state of register file:\n\tr0=%d\n\tr1=%d\n\tr2=%d\n\tr3=%d", r0, r1, r2, r3);

      $finish;
   end

endmodule // E15ProcessTB

              
