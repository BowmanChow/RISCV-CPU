`ifndef INTERFACE
`include "CONFIG.sv"
interface AluControlIf;
    ALU_CONTROL_TYPE alu_option;
    wire ctrl2;
endinterface

`define INTERFACE
`endif