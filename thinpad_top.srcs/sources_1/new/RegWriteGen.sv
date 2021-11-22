`include "CONFIG.sv"
module RegWriteGen(
    input INSTRUCTION_TYPE inst_type,
    output wire regwrite
);
assign regwrite = 
    (inst_type == LUI || inst_type == AUPIC ||
     inst_type == JAL || inst_type == JALR ||
     inst_type == LOAD || inst_type == IMME ||
     inst_type == REG) ? 1 : 0;
endmodule