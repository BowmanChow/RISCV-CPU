`ifndef CONFIG
typedef enum logic [2:0] {
    ADD,
    SLL,
    SLT,
    SLTU,
    XOR,
    SRL,
    OR,
    AND
} ALU_CONTROL_TYPE;

typedef enum logic [3:0] {
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

typedef enum logic [0:0] {
    PC_ALU,
    PC_4
} PC_CONTROL;

typedef enum logic [1:0] {
    WRITE_BACK_ALU,
    WRITE_BACK_PC_4,
    WRITE_BACK_MEM,
    WRITE_BACK_IMME
} WRITE_BACK_CONTROL;

typedef enum logic [1:0] {
    NONE,
    READ,
    WRITE
} READ_WRITE_CONTROL;

`define CONFIG
`endif