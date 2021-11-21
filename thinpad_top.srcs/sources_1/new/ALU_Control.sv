`include "Config.sv"
`include "interface.sv"
module ALU_Control(
    input wire [2:0] instruction_type,
    input wire [14:12] funct3,
    input wire [31:25] funct7,
    ALU_Control_if control
    );
assign control.ALU_option =
    (instruction_type == LOAD ||
     instruction_type == BRANCH ||
     instruction_type == STORE) ? ADD :
    (instruction_type == REG ||
     instruction_type == IMME) ? funct3[14:12] : 0;
assign control.ctrl2 = (instruction_type == IMME && funct3[14] == 0) ? 0 : funct7[30];
endmodule