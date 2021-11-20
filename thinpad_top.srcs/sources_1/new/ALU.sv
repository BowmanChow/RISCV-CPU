`include "ALU_Control.sv"
module ALU(
    input wire [31:0] a, b,
    input wire [3:0] control,
    output wire [31:0] out
    );
assign out = (control == ADD) ? a + b :
             (control == SUB) ? a - b :
             (control == AND) ? a & b :
             (control == OR) ? a | b :
             (control == XOR) ? a ^ b :
             (control == NOT) ? ~a :
             (control == SLL) ? a << b :
             (control == SRL) ? a >> b :
             (control == SRA) ? $signed($signed(a) >>> b) :
             (control == ROL) ? (a << b) | (a >> (32 - b)) : 0;
endmodule
