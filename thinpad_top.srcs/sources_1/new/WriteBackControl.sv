`include "CONFIG.sv"
module WriteBackControl(
    input INSTRUCTION_TYPE inst_type,
    output WRITE_BACK_CONTROL ctrl
    );
always_comb
    case (inst_type)
        LUI : ctrl <= WRITE_BACK_IMME;
        AUPIC, IMME, REG : ctrl <= WRITE_BACK_ALU;
        STORE : ctrl <= WRITE_BACK_MEM;
        JAL, JALR : ctrl <= WRITE_BACK_PC_4;
    endcase
endmodule
