`ifndef CONFIG
typedef enum {
    ADD,
    SLL,
    SLT,
    SLTU,
    XOR,
    SRL,
    OR,
    AND
} ALU_CONTROL_TYPE;

typedef enum {
    LUI,
    AUPIC,
    JAL,
    JALR,
    BRANCH,
    LOAD,
    STORE,
    IMME,
    REG,
    SYSTEM
} INSTRUCTION_TYPE;

`define CONFIG
`endif