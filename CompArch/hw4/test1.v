/* OPCODE SRC DST IMMDATA */
myROM[0]  = {movi, RXX, Rg0, 4'b0011 };
myROM[1]  = {movi, RXX, Rg1, 4'b0110 };
myROM[2]  = {movi, RXX, Rg2, 4'b0001 };
myROM[3]  = {add,  Rg0, Rg0, 4'b0000 };
myROM[4]  = {add,  Rg1, Rg0, 4'b0000 };
myROM[5]  = {sub,  Rg2, Rg0, 4'b0000 };
myROM[6]  = {jmp,  RXX, RXX, 4'b0000 };
myROM[7]  = {jmp,  RXX, RXX, 4'b0000};
myROM[8]  = {jmp,  RXX, RXX, 4'b0000};
myROM[9]  = {jmp,  RXX, RXX, 4'b0000};
myROM[10] = {jmp,  RXX, RXX, 4'b0000};
myROM[11] = {jmp,  RXX, RXX, 4'b0000};
myROM[12] = {jmp,  RXX, RXX, 4'b0000};
myROM[13] = {jmp,  RXX, RXX, 4'b0000};
myROM[14] = {jmp,  RXX, RXX, 4'b0000};
myROM[15] = {jmp,  RXX, RXX, 4'b0000};
