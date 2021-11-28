`include "CONFIG.sv"
module BranchJumpControl(
    input INSTRUCTION_TYPE inst_type,
    input unsigned [31:0] a, b,
    input wire [2:0] funct3,
    output PC_CONTROL PC_select
    );
reg compare;
always_comb
    case (funct3)
        3'b000 : compare <= a == b ? 1 : 0;
        3'b001 : compare <= a != b ? 1 : 0;
        3'b100 : compare <= $signed(a) < $signed(b) ? 1 : 0;
        3'b101 : compare <= $signed(a) >= $signed(b) ? 1 : 0;
        3'b110 : compare <= a < b ? 1 : 0;
        3'b111 : compare <= a >= b ? 1 : 0;
    endcase
always_comb
    case (inst_type)
        JAL, JALR : PC_select <= PC_ALU;
        BRANCH : PC_select <= compare ? PC_ALU : PC_4;
        default : PC_select <= PC_4;
    endcase

endmodule
