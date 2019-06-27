`include "E15Mem.v"

// direct-mapped cache
module E15Cache(input clk,
              input wire [15:0] cycleCount, // number of cycles elapsed so far
              input wire newRequest,        // true to signal a new memory request
              input wire write_enable,      // true if we are writing
              input wire [3:0] address,     // the address in question
              input wire [3:0] valueIn,     // the value to write
              output reg [3:0] valueOut,    // the value read
              output wire memResultReady    // true when it's safe to read valueOut
                  );

   /*
    This stores the content of the cache.
        Structure of a cache line:
          bit #    content
             9     valid
             8     tag
            7-0    data
     Initially, all cache lines are invalid
     (i.e. empty).
   */
   reg [9:0] cache [3:0];
   initial begin
        state = idle;
        cache[0][9] = 0;
        cache[1][9] = 0;
        cache[2][9] = 0;
        cache[3][9] = 0;
   end

   reg [3:0] saved_address;

   // If a read isn't in the cache, we have to consult main memory
   wire [7:0] main_memory_out;
   E15Mem main_memory(clk, write_enable, address, valueIn, main_memory_out);

   // If we have a cache miss, we need to stall until memory
   // is ready. The output memResultReady will tell the CPU
   // when it's safe to use valueOut.
   reg [7:0] stall;
   assign memResultReady = (state == ready);

   reg [1:0] state;
   parameter idle = 2'b0,
             stalling = 2'b1,
             access = 2'b10,
             ready = 2'b11;


   wire cacheHit;
   // TODO1: determine if the requested address is in the cache.
   // Write a Verilog expression on the right-hand side of the
   // equals sign that will evaluate to 1 if and only if
   // the requested address is in the cache.
   // You'll need to use these values:
   //    cache: the cache memory itself
   //    address: the address that was requested by the program.
   //        This tells you which cache line to use.
   // For example:
   //     assign cacheHit = cache[address ...] ... ;
   // assign cacheHit = 0;
   assign cacheHit = (cache[address[2:1]][9]) & (cache[address[2:1]][8] == address[3]) ? 1 : 0;

   wire [3:0] cachedValue;
   // TODO2: if the address is in the cache, get its value
   // Write a Verilog expression on the right-hand side of the
   // equals sign that will evaluate to the cached value at
   // the requested address. If the requested address is
   // not in the cache, the value of this wire is ignored.
   // You'll need to use these values:
   //    cache: the cache memory itself
   //    address: the address that was requested by the program.
   //        This tells you which cache line to use.
   // Note that cachedValue is a 4-bit value, even though
   // each block is 8 bits. You'll need to decide which half
   // of the block to return.
   // For example:
   // assign cacheValue = cache[address ...] ... ;
   // assign cachedValue = 0;
   assign cachedValue = (address[0] == 0) ? cache[address[2:1]][7:4] :
                        (address[0] == 1) ? cache[address[2:1]][3:0] : 0;

   always @(posedge clk)
   case (state)
        idle:
            if (newRequest) begin
                saved_address <= address;
                if (~write_enable && cacheHit)
                begin
                    // we have the value in cache, return it ASAP
                    $display("Hit!  address:%b value:%b",address,cachedValue);
                    valueOut <= cachedValue;
                    state <= ready;
                end
                else begin
                    // all writes have to go to main memory, so we treat them as misses
                    $display("Miss! address:%b", address);
                    stall <= 19;
                    state <= stalling;
                end
            end
        stalling:
            // wait for main memory to complete
            if (stall == 0)
                state <= access;
            else
                stall <= stall - 1;
        access:
            // memory access is done: get the value, return it, and cache the result
            begin
                // TODO3: save value into a cache line.
                // You'll need to use these values:
                //    cache: the cache memory itself
                //    saved_address: the address that was requested by the program.
                //        This tells you which cache line to use.
                //    main_memory_out: the 8-bit value returned by the main memory
                //        unit.
                // Below, you are given code returns the correct memory cell,
                // retrieved from the main memory unit, to the CPU. You don't
                // need to change this code. You only need to add that will
                // store that value in the appropriate cache line, with the
                // appropriate tag. For example:
                //    cache[saved_address .... ] <= ....;
                valueOut <= (saved_address[0])?main_memory_out[3:0]:main_memory_out[7:4];
                cache[saved_address[2:1]][9] <= 1;
                cache[saved_address[2:1]][8] <= main_memory_out[1];
                cache[saved_address[2:1]][7:0] <= main_memory_out;
                state <= ready;
            end
        ready:
            // wait for CPU to read the result and then start waiting again
            begin
                state <= idle;
            end
   endcase

endmodule
