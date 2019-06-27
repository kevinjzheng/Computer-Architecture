module E15Process(input clk, 
                  output reg [3:0] pc,             // Program Counter
                  output reg [3:0] opCode,         // op code
                  output reg [1:0] src, dst,       // src and dst register
                  output reg [3:0] immData,        // "Immediate" data
                  output reg [3:0] r0, r1, r2, r3, // Registers
                  output tri [3:0] mBus, dstBus    // Buses
                  );

   parameter fetch=2'd0, decode=2'd1, exec=2'd2, store=2'd3;

   parameter Rg0 = 2'b00, Rg1 = 2'b01, Rg2 = 2'b10, Rg3 = 2'b11, 
             RXX = 2'b00;

   parameter
     jmp  = 4'b0000, jz   = 4'b0010,  jnz  = 4'b0011,
     movi = 4'b1001, mov  = 4'b1000,  muli = 4'b0101,
     addi = 4'b1011, add  = 4'b1010,  mul  = 4'b0111,
     subi = 4'b1101, sub  = 4'b1100,
     cmpi = 4'b1111, cmp  = 4'b1110;
   
   parameter   hiZ = 4'bz;

   parameter   bEn_R0 = 3'd0, bEn_R1 = 3'd1, 
     bEn_R2 = 3'd2, bEn_R3 = 3'd3, 
     bEn_ALU = 3'd4, bEn_Imm = 3'd5;

   reg  [3:0] pcIncr; // Program Counter Increment
   wire [3:0] pcRes;  // Output of pc ALU
   wire       pcz;    // Unused - zero flag for pc ALU
   
   reg [1:0]  myState;      // State (phase of excution)
   reg [11:0] myROM [15:0]; // ROM (holds program)
   reg [3:0]  mbEn, dbEn;   // Used to determine which tri-state buffers are 
                            // enabled for master bus and destination bus.

   reg [1:0]  aluOperation; // Determines if ALU adds or subtracts or multiplies
   reg [3:0]  aluOut;    // Register to hold output of main ALU
   reg        zFlag;     // Zero flag
   wire [3:0] resVal;    // Output (combinational) of ALU
   wire       zVal;      // Output (combinational) of ALU zero flag

   initial
     begin

        `include "program1.v"
        
        pc = 4'b0000;
        myState = fetch;
        
     end
   
   always @(posedge clk)
     case(myState)
       fetch:
         begin
            {opCode, src, dst, immData} = myROM[pc];
            myState <= decode;
         end

       decode:
         begin
            case(opCode)
              movi, addi, subi, cmpi, muli:
                begin
                   mbEn <= bEn_Imm;
                end
              mov, add, sub, cmp, mul:
                case(src)
                  Rg0: mbEn <= bEn_R0;
                  Rg1: mbEn <= bEn_R1;
                  Rg2: mbEn <= bEn_R2;
                  Rg3: mbEn <= bEn_R3;
                endcase
            endcase 
            
            case(dst)
              Rg0: dbEn <= bEn_R0;
              Rg1: dbEn <= bEn_R1;
              Rg2: dbEn <= bEn_R2;
              Rg3: dbEn <= bEn_R3;
            endcase

            aluOperation <= ((opCode == add) | (opCode == addi)) ? 1 :
                            ((opCode == sub) | (opCode == subi)) ? 0 :
                            2;
            myState <= exec;
         end
       
       exec:
         begin
            case(opCode)
              addi, add, subi, sub, cmpi, cmp, muli, mul:
                begin
                   pcIncr <= 4'd1;
                   mbEn <= bEn_ALU;
                   aluOut <= resVal;
                   zFlag <= zVal;
                end
              jmp: pcIncr <= immData;
              jz:  pcIncr <= zFlag ? immData : 4'd1;
              jnz: pcIncr <= zFlag ? 4'd1 : immData;
              default: pcIncr <= 4'd1; 
            endcase
            myState <= store;
         end
       
       store:
         begin
            case(opCode)
              movi, mov, add, addi, sub, subi, mul, muli:
                case(dst)
                  Rg0: r0 <= mBus;
                  Rg1: r1 <= mBus;
                  Rg2: r2 <= mBus;
                  Rg3: r3 <= mBus;
                endcase
            endcase
            pc <= pcRes;
            myState <= fetch;
         end
       
     endcase
   
   assign mBus = (mbEn==bEn_R0)  ? r0      : hiZ;
   assign mBus = (mbEn==bEn_R1)  ? r1      : hiZ;
   assign mBus = (mbEn==bEn_R2)  ? r2      : hiZ;
   assign mBus = (mbEn==bEn_R3)  ? r3      : hiZ;
   assign mBus = (mbEn==bEn_Imm) ? immData : hiZ;
   assign mBus = (mbEn==bEn_ALU) ? aluOut  : hiZ;

   assign dstBus = (dbEn==bEn_R0)  ? r0 : hiZ;
   assign dstBus = (dbEn==bEn_R1)  ? r1 : hiZ;
   assign dstBus = (dbEn==bEn_R2)  ? r2 : hiZ;
   assign dstBus = (dbEn==bEn_R3)  ? r3 : hiZ;

   fancyALU dataALU(aluOperation, mBus, dstBus, zVal, resVal);
   fancyALU pcALU(2'b01, pc, pcIncr, pcz, pcRes);

endmodule


module fancyALU(
    input [1:0] operation,
    input [3:0] src, dst,
    output zFlag,
    output [3:0] res);
    assign res = (operation==1) ? (dst + src) : (operation==0) ? (dst - src) : (dst*src);
    assign zFlag = !(res);

endmodule