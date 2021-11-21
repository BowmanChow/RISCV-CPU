`include "Config.sv"
`include "interface.sv"
module ALU(
    input wire unsigned [31:0] a, b,
    ALU_Control_if control,
    output wire [31:0] out
    );
assign out =
    (control.ALU_option == ADD) ? a + (control.ctrl2 ? -b : b) :
    (control.ALU_option == SLL) ? a << b :
    (control.ALU_option == SLT) ? ($signed(a) < $signed(b) ? 1 : 0) :
    (control.ALU_option == SLTU) ? (a < b ? 1 : 0) :
    (control.ALU_option == XOR) ? a ^ b :
    (control.ALU_option == SRL) ? (control.ctrl2 ? $signed($signed(a) >>> b) : (a >> b)) :
    (control.ALU_option == OR) ? a | b :
    (control.ALU_option == AND) ? a & b : 0;
endmodule
