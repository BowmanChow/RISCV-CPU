enum [2:0] {
    ADD,
    SLL,
    SLT,
    SLTU,
    XOR,
    SRL,
    OR,
    AND
} ALU_option_type;

enum [2:0] {
    UPPER,
    REG,
    IMME,
    BRANCH,
    LOAD,
    STORE,
    SYSTEM
} Instruction_type;
