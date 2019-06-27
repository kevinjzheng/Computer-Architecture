/*          OPCODE SRC  DST  IMMDATA */
myROM[0]  = {movi, RXX, Rg0, 4'b1001};
myROM[1]  = {movi, RXX, Rg1, 4'b0101};

myROM[2]  = {sw,   Rg1, Rg0, 4'b0000}; // Any write requires going to memory
myROM[3]  = {lw,   Rg1, Rg2, 4'b0000}; // A read after a write should be a hit

myROM[4]  = {subi, RXX, Rg1, 4'b0001}; // A read from another cell in the same block
myROM[5]  = {lw,   Rg1, Rg2, 4'b0000}; // Should be a hit

myROM[6]  = {movi, RXX, Rg1, 4'b1101}; // Same cache line, different address
myROM[7]  = {lw,   Rg1, Rg2, 4'b0000}; // Should be a miss

myROM[8]  = {movi, RXX, Rg2, 4'b0101}; // back to the original address, now evicted
myROM[9]  = {lw,   Rg2, Rg3, 4'b0000}; // should be a miss

myROM[10] = {movi, RXX, Rg1, 4'b0000}; // different cache line
myROM[11] = {lw,   Rg1, Rg3, 4'b0000}; // miss

myROM[12] = {addi, RXX, Rg1, 4'b0001}; // same block
myROM[13] = {lw,   Rg1, Rg3, 4'b0000}; // hit

myROM[14] = {lw,   Rg2, Rg3, 4'b0000}; // hit

myROM[15]  = {jmp,  RXX, RXX, 4'b0000}; // fini

/*
Miss! address:0101
Hit!  address:0101 value:1001
Hit!  address:0100 value:0001
Miss! address:1101
Miss! address:0101
Miss! address:0000
Hit!  address:0001 value:0100
Hit!  address:0101 value:1001
Program halted normally after   152 cycles
Final state of register file:
    r0= 9
    r1= 1
    r2= 5
    r3= 9
Final state of memory:
    0000    0100    1111    0011
    0001    1001    0110    1111
    0000    0000    0010    0110
    0100    1110    0000    1010
Final state of cache:
    Line:0  Valid:1  Tag:0  Data:00000100
    Line:1  Valid:0  Tag:x  Data:xxxxxxxx
    Line:2  Valid:1  Tag:0  Data:00011001
    Line:3  Valid:0  Tag:x  Data:xxxxxxxx

*/
