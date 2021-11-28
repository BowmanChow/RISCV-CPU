`include "CONFIG.sv"
module InstructionType(
    input wire [6:0] opcode,
    output INSTRUCTION_TYPE type_
    );
always_comb
    case (opcode)
        7'b0110111 : type_ <= LUI;
        7'b0010111 : type_ <= AUPIC;
        7'b1101111 : type_ <= JAL;
        7'b1100111 : type_ <= JALR;
        7'b1100011 : type_ <= BRANCH;
        7'b0000011 : type_ <= LOAD;
        7'b0100011 : type_ <= STORE;
        7'b0010011 : type_ <= IMME;
        7'b0110011 : type_ <= REG;
        default : type_ <= SYSTEM;
    endcase
endmodule