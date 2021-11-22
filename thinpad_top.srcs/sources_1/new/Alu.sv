`include "CONFIG.sv"
`include "INTERFACE.sv"
module Alu(
    input wire unsigned [31:0] a, b,
    AluControlIf control,
    output wire [31:0] out
    );
assign out =
    (control.alu_option == ADD) ? a + (control.ctrl2 ? -b : b) :
    (control.alu_option == SLL) ? a << b[4:0] :
    (control.alu_option == SLT) ? ($signed(a) < $signed(b) ? 1 : 0) :
    (control.alu_option == SLTU) ? (a < b ? 1 : 0) :
    (control.alu_option == XOR) ? a ^ b :
    (control.alu_option == SRL) ? (control.ctrl2 ? $signed($signed(a) >>> b[4:0]) : (a >> b[4:0])) :
    (control.alu_option == OR) ? a | b :
    (control.alu_option == AND) ? a & b : 0;
endmodule
