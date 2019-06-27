module E15Mem(input clk, 
              input wire write_enable,
              input wire [3:0] address,
              input wire [3:0] valueIn,
              output reg [7:0] valueOut 
                  );
   reg [3:0] memory [15:0];
   
   always @(posedge clk)
   begin

      if (write_enable) 
        memory[address] = valueIn;
      valueOut <= #40 {memory[address & ~4'b0001], memory[address | 4'b0001]};
   end

endmodule