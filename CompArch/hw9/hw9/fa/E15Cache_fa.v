`include "E15Mem.v"

// fully-associative cache
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
             27    valid
           26-24   tag
           23-8    timestamp
            7-0    data
     Initially, all cache lines are invalid
     (i.e. empty).
   */
   reg [27:0] cache [3:0];
   initial begin
        state = idle;
        cache[0][27] = 0;
        cache[1][27] = 0;
        cache[2][27] = 0;
        cache[3][27] = 0;
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
   // Because this is a fully-associative cache, you'll have
   // to check each cache line, resulting in a long, kinda
   // repetitive expression. That's okay!
   // You'll need to use these values:
   //    cache: the cache memory itself
   //    address: the address that was requested by the program.
   //        This tells you which cache line to use.
   // For example:
   //     assign cacheHit = cache[address ...] || cache[address ...] || ... ;
   // assign cacheHit = 0;
   assign cacheHit = cache[0][26:24] == address[3:1] ||
                     cache[1][26:24] == address[3:1] ||
                     cache[2][26:24] == address[3:1] ||
                     cache[3][26:24] == address[3:1];

   wire [3:0] cachedValue;
   // TODO2: if the address is in the cache, get its value
   // Write a Verilog expression on the right-hand side of the
   // equals sign that will evaluate to the cached value at
   // the requested address. If the requested address is
   // not in the cache, the value of this wire is ignored.
   // Because this is a fully-associative cache, you'll have
   // to check each cache line, resulting in a long, kinda
   // repetitive expression. That's okay!
   // You'll need to use these values:
   //    cache: the cache memory itself
   //    address: the address that was requested by the program.
   //        This tells you which cache line to use.
   // Note that cachedValue is a 4-bit value, even though
   // each block is 8 bits. You'll need to decide which half
   // of the block to return.
   // For example:
   //     assign cacheValue = cache[address ...] == ... ? cache[address ...] :
   //                         cache[address ...] == ... ? cache[address ...] : ...;
   assign cachedValue = cache[0][26:24] == address[3:1] ? address[0] ? cache[0][3:0] : cache[0][7:4] :
                        cache[1][26:24] == address[3:1] ? address[0] ? cache[1][3:0] : cache[1][7:4] :
                        cache[2][26:24] == address[3:1] ? address[0] ? cache[2][3:0] : cache[2][7:4] :
                        cache[3][26:24] == address[3:1] ? address[0] ? cache[3][3:0] : cache[3][7:4] : 0;


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
                    // TODO4: Update timestamp on a hit
                    // This code is executed when a cache hit occurs, which means
                    // we need to update the timestamp on the cacheline that
                    // was just used. This ensures that the least-recently
                    // used line will be evicted when a miss happens.
                    // Use the values cache, address, and cycleCount.
                    // You don't need to modify any of the code here, just
                    // add code that will update the timestamp for
                    // For example:
                    //    if (cache[....]==address[....])
                    //       cache[...] <= cycleCount;
                    //    else if (cahce[....]==address[....])
                    //       cache[...] <= cycleCount;
                    //    else ...
                    // YOUR CODE HERE
                    if (cache[0][26:24] == address[3:1])
                      cache[0][23:8] <= cycleCount;
                    else if (cache[1][26:24] == address[3:1])
                      cache[1][23:8] <= cycleCount;
                    else if (cache[2][26:24] == address[3:1])
                       cache[2][23:8] <= cycleCount;
                    else cache[3][23:8] <= cycleCount;
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
                // TODO3: save value into a cache line
                // In the event of a cache miss, this code will store the value
                // returned from main memory into the appropriate cache line.
                // Since this is a fully-associative cache, we should prefer
                // to store the value into an empty cache line (i.e. a cache line
                // whose valid bit is 0). If there is no empty cache line, then
                // we have to evict the cache line that was least recently used,
                // (i.e. the one with the lowest timestamp), so you'll need to
                // compare, sequentially, the timestamp of each of the four
                // cache lines with that of the others, until we can find the
                // lowest. Your code doesn't need to be pretty, repetitive
                // is fine.
                // You'll need to use these values:
                //   cache: the cache itself
                //   saved_address: the address that was requested. This will
                //      tell you which cache line to use.
                //   main_memory_out: this is the 8-bit block returned by
                //      the main memory unit.
                //   cycleCount: the number of cycles elapsed in the CPU
                //      since it was turned on. Use this as the timestamp
                //      in the cacheline.
                // For example:
                //   if (cache...)
                //     cache[...] <= ...;
                //   else if (cache....)
                //     cache[....] <= ...;
                // You are given code that will send the value from main memory
                // back to the CPU. You don't need to change that, only to add
                // code that will update the cache.
                // YOUR CODE HERE
                valueOut <= (saved_address[0])?main_memory_out[3:0]:main_memory_out[7:4];
                if (cache[0][27] == 0)
                  begin
                    cache[0][27] <= 1;
  		   			      cache[0][26:24] <= saved_address[3:1];
  		   			      cache[0][23:8] <= cycleCount;
                    cache[0][7:0] <= main_memory_out;
		   		        end
				        else if (cache[1][27] == 0)
                  begin
                    cache[1][27] <= 1;
                    cache[1][26:24] <= saved_address[3:1];
                    cache[1][23:8] <= cycleCount;
                    cache[1][7:0] <= main_memory_out;
				          end
				        else if (cache[2][27] == 0)
                  begin
                    cache[2][27] <= 1;
                    cache[2][26:24] <= saved_address[3:1];
                    cache[2][23:8] <= cycleCount;
                    cache[2][7:0] <= main_memory_out;
				          end
        				else if (cache[3][27]==0)
                  begin
                    cache[3][27] <= 1;
                    cache[3][26:24] <= saved_address[3:1];
                    cache[3][23:8] <= cycleCount;
                    cache[3][7:0] <= main_memory_out;
        				  end
        				else
                  begin
          					if (cache[0][23:8] < cache[1][23:8] &&
                        cache[0][23:8] < cache[2][23:8] &&
          						  cache[0][23:8] < cache[3][23:8])
                      begin
          							cache[0][26:24] <= saved_address[3:1];
          							cache[0][23:8] <= cycleCount;
                        cache[0][7:0] <= main_memory_out;
          				    end
          					else if (cache[1][23:8] < cache[0][23:8] &&
          						       cache[1][23:8] < cache[2][23:8] &&
          						       cache[1][23:8] < cache[3][23:8])
                      begin
          							cache[1][26:24] <= saved_address[3:1];
          							cache[1][23:8] <= cycleCount;
                        cache[1][7:0] <= main_memory_out;
          						end
          					else if (cache[2][23:8] < cache[0][23:8] &&
          						       cache[2][23:8] < cache[1][23:8] &&
          						       cache[2][23:8] < cache[3][23:8])
                      begin
          							cache[2][26:24] <= saved_address[3:1];
          							cache[2][23:8] <= cycleCount;
                        cache[2][7:0] <= main_memory_out;
          						end
          					else
                      begin
          						  cache[3][26:24] <= saved_address[3:1];
          						  cache[3][23:8] <= cycleCount;
                        cache[3][7:0] <= main_memory_out;
          					  end
        				  end
                state <= ready;
            end
        ready:
            // wait for CPU to read the result and then start waiting again
            begin
                state <= idle;
            end
   endcase

endmodule
