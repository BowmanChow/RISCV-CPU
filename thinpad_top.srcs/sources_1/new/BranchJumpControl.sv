`include "CONFIG.sv"
module BranchJumpControl(
    input INSTRUCTION_TYPE inst_type,
    input unsigned [31:0] a, b,
    input [2:0] funct3,
    output PC_CONTROL PC_select
    );
wire compare;
assign compare = 
    (funct3 == 3'b000) ? (a == b ? 1 : 0) :
    (funct3 == 3'b001) ? (a != b ? 1 : 0) :
    (funct3 == 3'b100) ? ($signed(a) < $signed(b) ? 1 : 0) :
    (funct3 == 3'b101) ? ($signed(a) >= $signed(b) ? 1 : 0) :
    (funct3 == 3'b110) ? (a < b ? 1 : 0) :
    (funct3 == 3'b111) ? (a >= b ? 1 : 0) : compare;
always_comb
    case (inst_type)
        JAL, JALR : PC_select <= PC_ALU;
        BRANCH : PC_select <= compare ? PC_ALU : PC_4;
        default : PC_select <= PC_4;
    endcase

endmodule
