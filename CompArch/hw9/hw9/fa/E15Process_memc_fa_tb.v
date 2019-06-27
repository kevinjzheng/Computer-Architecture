`default_nettype none
`timescale 1ns/100ps
`include "E15Process_memc_fa.v"

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
      proc.CachedMMU.main_memory.memory[0] = 0;
      proc.CachedMMU.main_memory.memory[1] = 4;
      proc.CachedMMU.main_memory.memory[2] = 15;
      proc.CachedMMU.main_memory.memory[3] = 3;
      proc.CachedMMU.main_memory.memory[4] = 1;
      proc.CachedMMU.main_memory.memory[5] = 14;
      proc.CachedMMU.main_memory.memory[6] = 6;
      proc.CachedMMU.main_memory.memory[7] = 15;
      proc.CachedMMU.main_memory.memory[8] = 0;
      proc.CachedMMU.main_memory.memory[9] = 0;
      proc.CachedMMU.main_memory.memory[10] = 2;
      proc.CachedMMU.main_memory.memory[11] = 6;
      proc.CachedMMU.main_memory.memory[12] = 4;
      proc.CachedMMU.main_memory.memory[13] = 14;
      proc.CachedMMU.main_memory.memory[14] = 0;
      proc.CachedMMU.main_memory.memory[15] = 10;

      $dumpfile("E15Process_memc_tb.vcd");
      $dumpvars(0, E15Process_TB);
      #1000

      $display("Final state of register file:\n\tr0=%d\n\tr1=%d\n\tr2=%d\n\tr3=%d", r0, r1, r2, r3);

      $write("Final state of memory:");
      for (i=0; i< 16; i=i+1) begin
        if (i % 4 == 0) begin
          $write("\n");
        end
        $write("\t%b", proc.CachedMMU.main_memory.memory[i]);
      end
      $write("\n");

      $write("Final state of cache:\n");
      for (i=0; i< 4; i=i+1) begin
        $write("\tLine:%1d  Valid:%b  Tag:%b  Timestamp:%5d  Data:%b\n",i,
            proc.CachedMMU.cache[i][27],
            proc.CachedMMU.cache[i][26:24],
            proc.CachedMMU.cache[i][23:8],
            proc.CachedMMU.cache[i][7:0]
            );
      end

      $finish;
   end

endmodule // E15ProcessTB
