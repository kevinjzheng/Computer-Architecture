`default_nettype none

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
     jmp  = 4'b0000, jz   = 4'b0010,  jnz = 4'b0011,
     movi = 4'b1001, mov  = 4'b1000,
     addi = 4'b1011, add  = 4'b1010,
     subi = 4'b1101, sub  = 4'b1100,
     cmpi = 4'b1111, cmp  = 4'b1110,

     mul = 4'b0100,
     quadruple = 4'b0001,
     clearall = 4'b0101,
     increg = 4'b0111;

   parameter   hiZ = 4'bz;

   parameter   bEn_R0 = 3'd0, bEn_R1 = 3'd1,
     bEn_R2 = 3'd2, bEn_R3 = 3'd3,
     bEn_ALU = 3'd4, bEn_Imm = 3'd5;

   reg  [3:0] pcIncr; // Program Counter Increment
   wire [3:0] pcRes;  // Output of pc ALU
   wire [3:0] microcodePcRes;
   wire       pcz;    // Unused - zero flag for pc ALU
   wire [11:0] currentInstruction;

   reg [1:0]  myState;      // State (phase of excution)
   reg [11:0] myROM [15:0]; // ROM (holds program)
   reg [3:0]  mbEn, dbEn;   // Used to determine which tri-state buffers are
                            // enabled for master bus and destination bus.

   reg        addNotSub; // Determines if ALU adds or subtracts
   reg [3:0]  aluOut;    // Register to hold output of main ALU
   reg        zFlag;     // Zero flag
   wire [3:0] resVal;    // Output (combinational) of ALU
   wire       zVal;      // Output (combinational) of ALU zero flag

   reg [3:0] microcodePc;
   reg microcodeEnable = 1'b0;
   reg [11:0] microcodeBuffer [15:0]; // holds microcode, if applicable
   assign currentInstruction = microcodeEnable ? microcodeBuffer[microcodePc] : myROM[pc];
   parameter end_of_microcode = {jmp, RXX, RXX, 4'b0000};

   initial
     begin

        `include "muldemo.v"

        pc = 4'b0000;
        myState = fetch;

     end

   always @(posedge clk)
     case(myState)
       fetch:
         begin
            {opCode, src, dst, immData} = currentInstruction;

            if (microcodeEnable && currentInstruction == end_of_microcode)
              begin
                microcodeEnable <= 0;
                pc <= pcRes;
                pcIncr <= 4'd1;
              end
            else
              case (opCode)

                // multiply the value in src by dst and store result in dst
                mul:
                  begin
                    microcodePc <= 4'd0;
                    microcodeEnable <= 1'b1;
                    microcodeBuffer[0] <= {movi,RXX, Rg3, 4'b0000};
                    microcodeBuffer[1] <= {cmpi,RXX, src, 4'b0000};
                    microcodeBuffer[2] <= {jz,  RXX, RXX, 4'b0100};
                    microcodeBuffer[3] <= {add, dst, Rg3, 4'b0000};
                    microcodeBuffer[4] <= {subi,RXX, src, 4'b0001};
                    microcodeBuffer[5] <= {jnz, RXX, RXX, 4'b1110};
                    microcodeBuffer[6] <= {mov, Rg3, dst, 4'b0000};
                    microcodeBuffer[7] <= {movi,RXX, Rg3, 4'b0000};
                    microcodeBuffer[8] <= end_of_microcode;
                  end

                // set all registers to 0
                clearall:
                  begin
                    microcodePc <= 4'd0;
                    microcodeEnable <= 1'b1;
                    microcodeBuffer[0] <= {movi,RXX, Rg0, 4'b0000};
                    microcodeBuffer[1] <= {movi,RXX, Rg1, 4'b0000};
                    microcodeBuffer[2] <= {movi,RXX, Rg2, 4'b0000};
                    microcodeBuffer[3] <= {movi,RXX, Rg3, 4'b0000};
                    microcodeBuffer[4] <= end_of_microcode;
                  end

                // quadruple the value in src, storing the result in dst
                quadruple:
                  begin
                    microcodePc <= 4'd0;
                    microcodeEnable <= 1'b1;
                    microcodeBuffer[0] <= {mov, src, dst, 4'b0000};
                    microcodeBuffer[1] <= {add, dst, dst, 4'b0000};
                    microcodeBuffer[2] <= {add, dst, dst, 4'b0000};
                    microcodeBuffer[3] <= end_of_microcode;
                  end

                increg:
                  begin
                    microcodePc <= 4'd0;
                    microcodeEnable <= 1'b1;
                    microcodeBuffer[0] <= {cmpi, RXX, dst, 4'b0000};
                    microcodeBuffer[1] <= {jz,   RXX, RXX, 4'b0111};
                    microcodeBuffer[2] <= {cmpi, RXX, dst, 4'b0001};
                    microcodeBuffer[3] <= {jz,   RXX, RXX, 4'b0111};
                    microcodeBuffer[4] <= {cmpi, RXX, dst, 4'b0010};
                    microcodeBuffer[5] <= {jz,   RXX, RXX, 4'b0111};
                    microcodeBuffer[6] <= {addi, RXX, Rg3, 4'b0001};
                    microcodeBuffer[7] <= end_of_microcode;
                    microcodeBuffer[8] <= {addi, RXX, Rg0, 4'b0001};
                    microcodeBuffer[9] <= end_of_microcode;
                    microcodeBuffer[10] <= {addi, RXX, Rg1, 4'b0001};
                    microcodeBuffer[11] <= end_of_microcode;
                    microcodeBuffer[12] <= {addi, RXX, Rg2, 4'b0001};
                    microcodeBuffer[13] <= end_of_microcode;
                  end
                default:
                  myState <= decode;
              endcase
         end

       decode:
         begin
            case(opCode)
              movi, addi, subi, cmpi:
                begin
                   mbEn <= bEn_Imm;
                end
              mov, add, sub, cmp:
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

            addNotSub <= ((opCode == add) | (opCode == addi));
            myState <= exec;
         end

       exec:
         begin
            case(opCode)
              addi, add, subi, sub, cmpi, cmp:
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
              movi, mov, add, addi, sub, subi:
                case(dst)
                  Rg0: r0 <= mBus;
                  Rg1: r1 <= mBus;
                  Rg2: r2 <= mBus;
                  Rg3: r3 <= mBus;
                endcase
            endcase

            if (microcodeEnable)
              microcodePc <= microcodePcRes;
            else
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

   simpleALU dataALU(addNotSub, mBus, dstBus, zVal, resVal);
   simpleALU pcALU(1'b1, pc, pcIncr, pcz, pcRes);
   simpleALU microcodePcALU(1'b1, microcodePc, pcIncr, pcz, microcodePcRes);

endmodule


module simpleALU(
    input addNotSub,
    input [3:0] src, dst,
    output zFlag,
    output [3:0] res);
    assign res = addNotSub ? dst + src : dst - src;
    assign zFlag = !(res);

endmodule
