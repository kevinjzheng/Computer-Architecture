/*          OPCODE SRC  DST  IMMDATA */
myROM[0]  = {movi, RXX, Rg0, 4'b1001};
myROM[1]  = {movi, RXX, Rg1, 4'b0101};
myROM[2]  = {sw,   Rg1, Rg0,  4'b0000}; // miss, it's a write

myROM[3]  = {lw,   Rg1, Rg0, 4'b0000}; // hit

myROM[4]  = {addi, RXX, Rg1, 4'b0010};
myROM[5]  = {lw,   Rg1, Rg2, 4'b0000}; //miss at address 7

myROM[6]  = {addi, RXX, Rg1, 4'b0010};
myROM[7]  = {lw,   Rg1, Rg2, 4'b0000}; //miss at address 9

myROM[8]  = {addi, RXX, Rg1, 4'b0010};
myROM[9]  = {lw,   Rg1, Rg2, 4'b0000}; //miss at address 11; cache is now full

myROM[10] = {movi, RXX, Rg1, 4'b0101};
myROM[11] = {lw,   Rg1, Rg2, 4'b0000}; // hit at addres 5: lru is now in address 7

myROM[12] = {movi, RXX, Rg1, 4'b1111};
myROM[13] = {lw,   Rg1, Rg2, 4'b0000}; // miss at address 15, line 1 (address 7) is evicted

myROM[14]  = {jmp,  RXX, RXX, 4'b0000}; // fini

/*
Miss! address:0101
Hit!  address:0101 value:1001
Miss! address:0111
Miss! address:1001
Miss! address:1011
Hit!  address:0101 value:1001
Miss! address:1111
Program halted normally after   168 cycles
Final state of register file:
    r0= 9
    r1=15
    r2=10
    r3= x
Final state of memory:
    0000    0100    1111    0011
    0001    1001    0110    1111
    0000    0000    0010    0110
    0100    1110    0000    1010
Final state of cache:
    Line:0  Valid:1  Tag:010  Timestamp:  135  Data:00011001
    Line:1  Valid:1  Tag:111  Timestamp:  165  Data:00001010
    Line:2  Valid:1  Tag:100  Timestamp:   96  Data:00000000
    Line:3  Valid:1  Tag:101  Timestamp:  126  Data:00100110

*/
