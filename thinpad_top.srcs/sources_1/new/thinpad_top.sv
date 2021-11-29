`default_nettype none
`include "INTERFACE.sv"

module thinpad_top(
    input wire clk_50M,           //50MHz 时钟输入
    input wire clk_11M0592,       //11.0592MHz 时钟输入（备用，可不用）

    input wire clock_btn,         //BTN5手动时钟按钮开关，带消抖电路，按下时为1
    input wire reset_btn,         //BTN6手动复位按钮开关，带消抖电路，按下时为1

    input  wire[3:0]  touch_btn,  //BTN1~BTN4，按钮开关，按下时为1
    input  wire[31:0] dip_sw,     //32位拨码开关，拨到“ON”时为1
    output wire[15:0] leds,       //16位LED，输出时1点亮
    output wire[7:0]  dpy0,       //数码管低位信号，包括小数点，输出1点亮
    output wire[7:0]  dpy1,       //数码管高位信号，包括小数点，输出1点亮

    //CPLD串口控制器信号
    output wire uart_rdn,         //读串口信号，低有效
    output wire uart_wrn,         //写串口信号，低有效
    input wire uart_dataready,    //串口数据准备好
    input wire uart_tbre,         //发送数据标志
    input wire uart_tsre,         //数据发送完毕标志

    //BaseRAM信号
    inout wire[31:0] base_ram_data,  //BaseRAM数据，低8位与CPLD串口控制器共享
    output wire[19:0] base_ram_addr, //BaseRAM地址
    output wire[3:0] base_ram_be_n,  //BaseRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output wire base_ram_ce_n,       //BaseRAM片选，低有效
    output wire base_ram_oe_n,       //BaseRAM读使能，低有效
    output wire base_ram_we_n,       //BaseRAM写使能，低有效

    //ExtRAM信号
    inout wire[31:0] ext_ram_data,  //ExtRAM数据
    output wire[19:0] ext_ram_addr, //ExtRAM地址
    output wire[3:0] ext_ram_be_n,  //ExtRAM字节使能，低有效。如果不使用字节使能，请保持为0
    output wire ext_ram_ce_n,       //ExtRAM片选，低有效
    output wire ext_ram_oe_n,       //ExtRAM读使能，低有效
    output wire ext_ram_we_n,       //ExtRAM写使能，低有效

    //直连串口信号
    output wire txd,  //直连串口发送端
    input  wire rxd,  //直连串口接收端

    //Flash存储器信号，参考 JS28F640 芯片手册
    output wire [22:0]flash_a,      //Flash地址，a0仅在8bit模式有效，16bit模式无意义
    inout  wire [15:0]flash_d,      //Flash数据
    output wire flash_rp_n,         //Flash复位信号，低有效
    output wire flash_vpen,         //Flash写保护信号，低电平时不能擦除、烧写
    output wire flash_ce_n,         //Flash片选信号，低有效
    output wire flash_oe_n,         //Flash读使能信号，低有效
    output wire flash_we_n,         //Flash写使能信号，低有效
    output wire flash_byte_n,       //Flash 8bit模式选择，低有效。在使用flash的16位模式时请设为1

    //USB 控制器信号，参考 SL811 芯片手册
    output wire sl811_a0,
    //inout  wire[7:0] sl811_d,     //USB数据线与网络控制器的dm9k_sd[7:0]共享
    output wire sl811_wr_n,
    output wire sl811_rd_n,
    output wire sl811_cs_n,
    output wire sl811_rst_n,
    output wire sl811_dack_n,
    input  wire sl811_intrq,
    input  wire sl811_drq_n,

    //网络控制器信号，参考 DM9000A 芯片手册
    output wire dm9k_cmd,
    inout  wire[15:0] dm9k_sd,
    output wire dm9k_iow_n,
    output wire dm9k_ior_n,
    output wire dm9k_cs_n,
    output wire dm9k_pwrst_n,
    input  wire dm9k_int,

// `define debug
`ifdef debug
	output wire [31:0] __PC,
	output wire [31:0] __PC_plus_4,
	output wire [31:0] __instruction,
	output wire [31:0] __immediate,
	output wire [31:0] __alu_a,
	output wire [31:0] __alu_b,
	output wire [31:0] __alu_out,
	output ALU_CONTROL_TYPE __alu_control_alu_option,
	output wire __alu_control_ctrl2,
	output wire [31:0] __reg_a_data,
	output wire [31:0] __reg_b_data,
	output wire [4:0] __reg_a_addr,
	output wire [4:0] __reg_b_addr,
	output wire __reg_we,
	output wire [31:0] __ram_addr,
	output wire [31:0] __ram_data_write,
	output wire [31:0] __ram_data_read,
    output wire __inst_lock,
	output wire __ram_addr_PC,
	output wire __ram_enable,
	output wire __read,
	output wire __write,
    output wire __uart_read,
    output wire __uart_write,
	output wire [1:0] __stall,
	output PC_CONTROL __branch_jump_control_PC_select,
    output INSTRUCTION_TYPE __instruction_type,
	output WRITE_BACK_CONTROL __write_back_ctrl,
	output READ_WRITE_CONTROL __rw_control,
	output wire [1023:0] __registers,
`endif

    //图像输出信号
    output wire[2:0] video_red,    //红色像素，3位
    output wire[2:0] video_green,  //绿色像素，3位
    output wire[1:0] video_blue,   //蓝色像素，2位
    output wire video_hsync,       //行同步（水平同步）信号
    output wire video_vsync,       //场同步（垂直同步）信号
    output wire video_clk,         //像素时钟输出
    output wire video_de           //行数据有效信号，用于区分消隐区
);
`ifdef debug
assign __PC = PC;
assign __PC_plus_4 = PC_plus_4;
assign __instruction = instruction;
assign __immediate = imme_gen.imme;
assign __alu_a = alu.a;
assign __alu_b = alu.b;
assign __alu_out = alu.out;
assign __alu_control_alu_option = alu_control.control.alu_option;
assign __alu_control_ctrl2 = alu_control.control.ctrl2;
assign __reg_a_data = reg_file.a_data;
assign __reg_b_data = reg_file.b_data;
assign __reg_a_addr = reg_file.a_addr;
assign __reg_b_addr = reg_file.b_addr;
assign __reg_we = reg_file.we;
assign __ram_addr = ram.addr;
assign __ram_data_write = ram.data_write;
assign __ram_data_read = ram.data_read;
assign __inst_lock = inst_lock;
assign __ram_addr_PC = ram_addr_PC;
assign __ram_enable = ram.enable;
assign __read = read;
assign __write = write;
assign __uart_read = uart_read;
assign __uart_write = uart_write;
assign __stall = stall;
assign __branch_jump_control_PC_select = branch_jump_control.PC_select;
assign __instruction_type = instruction_type.type_;
assign __write_back_ctrl = write_back_ctrl.ctrl;
assign __rw_control = rw_control.rw;
assign __registers = {
    reg_file.regs[31],reg_file.regs[30],reg_file.regs[29],reg_file.regs[28],reg_file.regs[27],reg_file.regs[26],
    reg_file.regs[25],reg_file.regs[24],reg_file.regs[23],reg_file.regs[22],reg_file.regs[21],reg_file.regs[20],
    reg_file.regs[19],reg_file.regs[18],reg_file.regs[17],reg_file.regs[16],reg_file.regs[15],reg_file.regs[14],
    reg_file.regs[13],reg_file.regs[12],reg_file.regs[11],reg_file.regs[10],reg_file.regs[9], reg_file.regs[8],
    reg_file.regs[7], reg_file.regs[6], reg_file.regs[5], reg_file.regs[4], reg_file.regs[3], reg_file.regs[2],
    reg_file.regs[1], reg_file.regs[0]
};
`endif


/* =========== Demo code begin =========== */

reg clk_12_5M = 0;
reg counter = 0;
always @(posedge clk_50M) begin
        counter <= counter + 1;
        if (counter == 0)
            clk_12_5M <= ~clk_12_5M;
end


wire [7:0] uart_status;
assign uart_status = {2'b0, uart_tsre, 4'b0, uart_dataready};
reg uart_read = 0;
assign uart_rdn = ~uart_read;
reg uart_write = 0;
assign uart_wrn = ~uart_write;

reg [31:0] PC = 32'h80000000;
wire [31:0] PC_plus_4;
assign PC_plus_4 = PC + 4;
reg read = 1;
reg write = 0;
logic [31:0] instruction;
reg inst_lock = 0;
always_latch
    if (!inst_lock)
        instruction = ram.data_read;
reg ram_addr_PC = 1;
reg [1:0] stall = 2'b00;
always_ff @(posedge clk_12_5M or posedge reset_btn) begin
    if (reset_btn) begin
        PC <= 32'h80000000;
    end
    else begin
        if (stall != 0)
            PC <= PC;
        else
            PC <= (branch_jump_control.PC_select == PC_ALU) ? alu.out : PC_plus_4;
    end
end
always_ff @(posedge clk_12_5M or posedge reset_btn) begin
    if (reset_btn) begin
		ram_addr_PC <= 1;
		read <= 1;
    end
    else begin
        read <=
            (stall == 0) ? 1 :
            (rw_control.rw == WRITE) ? 0 : 1;
        ram_addr_PC <= (stall == 0) ? 1 : 0;
    end
end
always_ff @(negedge clk_12_5M or posedge reset_btn) begin
    if (reset_btn) begin
		write <= 0;
        uart_read <= 0;
		uart_write <= 0;
		stall <= 0;
    end
    else begin
        if (stall[1]) begin
            stall <= 2'b01;
            write <= (rw_control.rw == WRITE && ram.addr[31:28] != 1) ? 1 : 0;
            uart_read <= (rw_control.rw == READ && ram.addr[31:28] == 1 && ram.addr[3:0] == 0) ? 1 : 0;
            uart_write <= (rw_control.rw == WRITE && ram.addr[31:28] == 1 && ram.addr[3:0] == 0) ? 1 : 0;
        end
        else if (stall == 2'b01) begin
            stall <= 0;
            write <= 0;
            uart_read <= 0;
            uart_write <= 0;
        end
        else begin
            stall <= (rw_control.rw == READ || rw_control.rw == WRITE) ? 2'b10 : 0;
            write <= 0;
            uart_read <= 0;
            uart_write <= 0;
        end
    end
end
always_ff @(posedge clk_12_5M or posedge reset_btn or negedge clk_12_5M) begin
    if (reset_btn) begin
        inst_lock <= 0;
    end
    else if (clk_12_5M) begin
        if (stall != 0) begin
            inst_lock <= 1;
        end
        else begin
            inst_lock <= 0;
        end
    end
    else begin
        inst_lock <= (rw_control.rw == READ || rw_control.rw == WRITE) ? 1 : 0;
    end
end

Sram ram(
    .enable(ram.addr[31:28] == 1 ? 0 : 1),
    .read(read),
    .write(write),
    .addr(ram_addr_PC ? PC : alu.out),
    .data_write(rw_data.write_data_out),

    .base_ram_data(base_ram_data),
    .base_ram_addr(base_ram_addr),
    .base_ram_be_n(base_ram_be_n),
    .base_ram_ce_n(base_ram_ce_n),
    .base_ram_oe_n(base_ram_oe_n),
    .base_ram_we_n(base_ram_we_n),

    .ext_ram_data(ext_ram_data),
    .ext_ram_addr(ext_ram_addr),
    .ext_ram_be_n(ext_ram_be_n),
    .ext_ram_ce_n(ext_ram_ce_n),
    .ext_ram_oe_n(ext_ram_oe_n),
    .ext_ram_we_n(ext_ram_we_n)
);
ReadWriteData rw_data(
    .read_data_in(ram.addr[31:28] == 1 ?
        (ram.addr[3:0] == 5 ? {24'h0, uart_status} : {24'h0, base_ram_data[7:0]}) :
        ram.data_read),
    .write_data_in(reg_file.b_data),
    .funct3(instruction[14:12]),
    .address(ram.addr[1:0])
);
InstructionType instruction_type(
    .opcode(instruction[6:0])
);
ReadWriteControl rw_control(
    .inst_type(instruction_type.type_)
);
WriteBackControl write_back_ctrl(
    .inst_type(instruction_type.type_)
);
ImmeGen imme_gen(
    .inst(instruction[31:7]),
    .inst_type(instruction_type.type_)
);
RegFile reg_file(
    .clk(clk_12_5M),
    .rst(reset_btn),
    .write_addr(instruction[11:7]),
    .write_data(
        (write_back_ctrl.ctrl == WRITE_BACK_ALU) ? alu.out :
        (write_back_ctrl.ctrl == WRITE_BACK_PC_4) ? PC_plus_4 :
        (write_back_ctrl.ctrl == WRITE_BACK_IMME) ? imme_gen.imme : rw_data.read_data_out
    ),
    .a_addr(instruction[19:15]),
    .b_addr(instruction[24:20])
);
RegWriteGen reg_write_gen(
    .inst_type(instruction_type.type_),
    .regwrite(reg_file.we)
);
BranchJumpControl branch_jump_control(
    .inst_type(instruction_type.type_),
    .a(reg_file.a_data),
    .b(reg_file.b_data),
    .funct3(instruction[14:12])
);
AluControlIf alu_control_if();
AluControl alu_control(
    .inst_type(instruction_type.type_),
    .funct3(instruction[14:12]),
    .funct7(instruction[31:25]),
    .control(alu_control_if)
);
Alu alu(
    .a(alu_control.a_select ? reg_file.a_data : PC),
    .b(alu_control.b_select ? reg_file.b_data : imme_gen.imme),
    .control(alu_control_if)
);

// 7段数码管译码器演示，将number用16进制显示在数码管上面
wire[7:0] number;
assign number = reg_file.regs[30][7:0];
SEG7_LUT segL(.oSEG1(dpy0), .iDIG(number[3:0])); //dpy0是低位数码管
SEG7_LUT segH(.oSEG1(dpy1), .iDIG(number[7:4])); //dpy1是高位数码管
/* =========== Demo code end =========== */
assign leds = reg_file.regs[31][15:0];

endmodule
