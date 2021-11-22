`include "CONFIG.sv"
module InstructionType(
    input wire [6:0] opcode,
    output INSTRUCTION_TYPE type_
    );
assign type_ = 
    (opcode == 7'b0110111) ? LUI :
    (opcode == 7'b0010111) ? AUPIC :
    (opcode == 7'b1101111) ? JAL :
    (opcode == 7'b1100111) ? JALR :
    (opcode == 7'b1100011) ? BRANCH :
    (opcode == 7'b0000011) ? LOAD :
    (opcode == 7'b0100011) ? STORE :
    (opcode == 7'b0010011) ? IMME :
    (opcode == 7'b0110011) ? REG : SYSTEM;
endmodule