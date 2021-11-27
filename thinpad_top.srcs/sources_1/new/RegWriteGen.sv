`include "CONFIG.sv"
module RegWriteGen(
    input INSTRUCTION_TYPE inst_type,
    output reg regwrite
);
always_comb
    case (inst_type)
        LUI, AUPIC, JAL, JALR, LOAD, IMME, REG : regwrite <= 1;
        default : regwrite <= 0;
    endcase
endmodule