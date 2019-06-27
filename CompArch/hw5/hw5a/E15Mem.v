module E15Mem(input clk, 
              input wire write_enable,
              input wire [3:0] address,
              input wire [3:0] valueIn,
              output wire [3:0] valueOut 
                  );
   reg [3:0] memory [15:0];

   assign valueOut = memory[address];
   
   always @(posedge clk)
     if (write_enable)
      begin
        memory[address] <= valueIn;
      end

endmodule