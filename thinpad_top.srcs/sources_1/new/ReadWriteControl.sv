`include "CONFIG.sv"
module ReadWriteControl(
    input INSTRUCTION_TYPE inst_type,
    output READ_WRITE_CONTROL rw
    );
always_comb
    case (inst_type)
        LOAD : rw <= READ;
        STORE : rw <= WRITE;
        default : rw <= NONE;
    endcase
endmodule
