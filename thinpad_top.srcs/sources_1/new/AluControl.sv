`include "CONFIG.sv"
`include "INTERFACE.sv"
module AluControl(
    input INSTRUCTION_TYPE inst_type,
    input wire [14:12] funct3,
    input wire [31:25] funct7,
    AluControlIf control,
    output wire a_select,
    output wire b_select
    );
always_comb
    case (inst_type)
        AUPIC, JAL, JALR, BRANCH, LOAD, STORE :
            control.alu_option <= ADD;
        REG, IMME : control.alu_option <= ALU_CONTROL_TYPE'(funct3[14:12]);
    endcase
assign control.ctrl2 = (inst_type == IMME && funct3[14] == 0) ? 0 : funct7[30];
assign a_select = 
    (inst_type == AUPIC ||
     inst_type == JAL ||
     inst_type == BRANCH) ? 0 : 1;
assign b_select = 
    (inst_type == REG) ? 1 : 0;
endmodule