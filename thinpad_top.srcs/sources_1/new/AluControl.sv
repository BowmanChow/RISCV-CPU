`include "CONFIG.sv"
`include "INTERFACE.sv"
module AluControl(
    input INSTRUCTION_TYPE inst_type,
    input wire [14:12] funct3,
    input wire [31:25] funct7,
    AluControlIf control,
    output logic a_select,
    output logic b_select
    );
always_comb
    case (inst_type)
        AUPIC, JAL, JALR, BRANCH, LOAD, STORE :
            control.alu_option <= ADD;
        REG, IMME : control.alu_option <= ALU_CONTROL_TYPE'(funct3[14:12]);
    endcase
assign control.ctrl2 = ((inst_type == REG) || (inst_type == IMME && funct3 == 3'b101)) ? funct7[30] : 0;
always_comb
    case (inst_type)
        AUPIC, JAL, BRANCH : a_select = 0;
        default : a_select = 1;
    endcase
always_comb
    b_select = (inst_type == REG) ? 1 : 0;
endmodule