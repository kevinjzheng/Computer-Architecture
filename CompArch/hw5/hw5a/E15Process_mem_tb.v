`default_nettype none
`timescale 1ns/100ps
`include "E15Process_mem.v"

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

   integer i;
   initial begin
      // the linked list, starting at address 0
      proc.MMU.memory[0] = 0;
      proc.MMU.memory[1] = 4;
      proc.MMU.memory[2] = 15;
      proc.MMU.memory[3] = 3;
      proc.MMU.memory[4] = 1;
      proc.MMU.memory[5] = 14;
      proc.MMU.memory[6] = 6;
      proc.MMU.memory[7] = 15;
      proc.MMU.memory[8] = 0;
      proc.MMU.memory[9] = 0;
      proc.MMU.memory[10] = 2;
      proc.MMU.memory[11] = 6;
      proc.MMU.memory[12] = 4;
      proc.MMU.memory[13] = 14;
      proc.MMU.memory[14] = 0;
      proc.MMU.memory[15] = 10;
      $dumpfile("E15Process_tb.vcd");
      $dumpvars(0, E15Process_TB);
      #1000

      $display("Final state of register file:\n\tr0=%d\n\tr1=%d\n\tr2=%d\n\tr3=%d", r0, r1, r2, r3);

      $write("Final state of memory:");
      for (i=0; i< 16; i=i+1) begin
        if (i % 4 == 0) begin
          $write("\n");
        end
        $write("\t%b", proc.MMU.memory[i]);
      end
      $write("\n");

      $finish;
   end

endmodule // E15ProcessTB

              
