`include "CONFIG.sv"
module ImmeGen(
	input wire [31:7] inst,
	input INSTRUCTION_TYPE inst_type,
	output wire [31:0] imme
);
assign imme = 
	(inst_type == LUI || inst_type == AUPIC) ? {inst[31:12], 12'b0} :
	(inst_type == JAL) ? {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0} :
	(inst_type == JALR || inst_type == IMME || inst_type == LOAD) ? {{20{inst[31]}}, inst[31:20]} :
	(inst_type == BRANCH) ? {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0} :
	(inst_type == STORE) ? {{20{inst[31]}}, inst[31:25], inst[11:7]} : imme;

endmodule