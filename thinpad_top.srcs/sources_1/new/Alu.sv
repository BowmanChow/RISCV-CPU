`include "CONFIG.sv"
`include "INTERFACE.sv"
module Alu(
    input wire unsigned [31:0] a, b,
    AluControlIf control,
    output reg [31:0] out
    );
always_comb
    case (control.alu_option)
        ADD : out <= a + (control.ctrl2 ? -b : b);
        SLL : out <= a << b[4:0];
        SLT : out <= ($signed(a) < $signed(b) ? 1 : 0);
        SLTU : out <= (a < b ? 1 : 0);
        XOR : out <= a ^ b;
        SRL : out <= (control.ctrl2 ? $signed($signed(a) >>> b[4:0]) : (a >> b[4:0]));
        OR : out <= a | b;
        AND : out <= a & b;
    endcase
endmodule
