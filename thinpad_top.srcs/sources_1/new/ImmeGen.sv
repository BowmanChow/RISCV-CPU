`include "CONFIG.sv"
module ImmeGen(
	input wire [31:7] inst,
	input INSTRUCTION_TYPE inst_type,
	output logic [31:0] imme
);
always_comb
	case (inst_type)
		LUI, AUPIC : imme = {inst[31:12], 12'b0};
		JAL : imme = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};
		JALR, IMME, LOAD : imme = {{20{inst[31]}}, inst[31:20]};
		BRANCH : imme = {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
		STORE : imme = {{20{inst[31]}}, inst[31:25], inst[11:7]};
	endcase

endmodule