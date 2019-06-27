/* OPCODE SRC DST IMMDATA */
myROM[0]  = {movi, RXX, Rg0, 4'b0111 };
myROM[1]  = {movi, RXX, Rg1, 4'b0010 };
myROM[2]  = {mov,  Rg1, Rg3, 4'b0000 };
myROM[3]  = {subi, RXX, Rg3, 4'b0001 };
myROM[4]  = {jz,   RXX, RXX, 4'b0011 };
myROM[5]  = {add,  Rg0, Rg0, 4'b0000 };
myROM[6]  = {jnz,  RXX, RXX, 4'b1101 };
myROM[7]  = {mov,  Rg0, Rg2, 4'b0000 };
myROM[8]  = {jmp,  RXX, RXX, 4'b0000 };
myROM[9]  = {jmp,  RXX, RXX, 4'b0000};
myROM[10]  = {jmp,  RXX, RXX, 4'b0000};
myROM[11] = {jmp,  RXX, RXX, 4'b0000};
myROM[12] = {jmp,  RXX, RXX, 4'b0000};
myROM[13] = {jmp,  RXX, RXX, 4'b0000};
myROM[14] = {jmp,  RXX, RXX, 4'b0000};
myROM[15] = {jmp,  RXX, RXX, 4'b0000};
