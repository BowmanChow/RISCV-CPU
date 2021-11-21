`include "Config.sv"
module instruction_type(
    input wire [6:0] opcode,
    output wire [2:0] type_
    );
assign type_ = (opcode == 7'b0110111) ? UPPER :
               (opcode == 7'b1100011) ? BRANCH :
               (opcode == 7'b0000011) ? LOAD :
               (opcode == 7'b0100011) ? STORE :
               (opcode == 7'b0010011) ? IMME :
               (opcode == 7'b0110011) ? REG : SYSTEM;
endmodule