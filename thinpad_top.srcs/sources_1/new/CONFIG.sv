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

typedef enum {
    PC_ALU,
    PC_4
} PC_CONTROL;

typedef enum {
    WRITE_BACK_ALU,
    WRITE_BACK_PC_4,
    WRITE_BACK_MEM,
    WRITE_BACK_IMME
} WRITE_BACK_CONTROL;

`define CONFIG
`endif