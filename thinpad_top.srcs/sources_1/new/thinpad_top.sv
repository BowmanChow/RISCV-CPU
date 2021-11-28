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

    //图像输出信号
    output wire[2:0] video_red,    //红色像素，3位
    output wire[2:0] video_green,  //绿色像素，3位
    output wire[1:0] video_blue,   //蓝色像素，2位
    output wire video_hsync,       //行同步（水平同步）信号
    output wire video_vsync,       //场同步（垂直同步）信号
    output wire video_clk,         //像素时钟输出
    output wire video_de           //行数据有效信号，用于区分消隐区
);

/* =========== Demo code begin =========== */

// PLL分频示例
wire locked, clk_10M, clk_20M;
pll_example clock_gen 
 (
  // Clock in ports
  .clk_in1(clk_50M),  // 外部时钟输入
  // Clock out ports
  .clk_out1(clk_10M), // 时钟输出1，频率在IP配置界面中设置
  .clk_out2(clk_20M), // 时钟输出2，频率在IP配置界面中设置
  // Status and control signals
  .reset(reset_btn), // PLL复位输入
  .locked(locked)    // PLL锁定指示输出，"1"表示时钟稳定，
                     // 后级电路复位信号应当由它生成（见下）
 );

reg reset_of_clk10M;
// 异步复位，同步释放，将locked信号转为后级电路的复位reset_of_clk10M
always@(posedge clk_10M or negedge locked) begin
    if(~locked) reset_of_clk10M <= 1'b1;
    else        reset_of_clk10M <= 1'b0;
end

wire [7:0] uart_status;
assign uart_status = {2'b0, uart_tsre, 4'b0, uart_dataready};
reg uart_read = 0;
assign uart_rdn = ~uart_read;
reg uart_write = 0;
assign uart_wrn = ~uart_write;

reg ram_enable = 1;
reg [31:0] PC = 32'h80000000;
reg read = 1;
reg write = 0;
wire [31:0] instruction;
reg inst_lock = 0;
assign instruction = inst_lock ? instruction : ram.data_read;
reg ram_addr_PC = 1;
reg stall = 0;
always@(posedge clk_10M or posedge reset_of_clk10M or negedge clk_10M) begin
    if(reset_of_clk10M)begin
        // Your Code
    end
    else if (clk_10M) begin
        if (stall) begin
            PC <= PC;
            if (ram.addr[31:28] == 1 && ram.addr[3:0] == 0)
                uart_write <= 1;
            else
                write <= 1;
        end
        else begin
            inst_lock <= 0;
            PC <= (branch_jump_control.PC_select == PC_ALU) ? alu.out : PC + 4;
            ram_addr_PC <= 1;
            read <= 1;
            uart_read <= 0;
        end
    end
    else begin
        if (rw_control.rw == READ) begin
            inst_lock <= 1;
            ram_addr_PC <= 0;
            read <= 1;
            if (ram.addr[31:28] == 1 && ram.addr[3:0] == 0)
                uart_read <= 1;
        end
        else if (rw_control.rw == WRITE) begin
            inst_lock <= 1;
            ram_addr_PC <= 0;
            read <= 0;
            stall <= ~stall;
        end
        write <= 0;
        uart_write <= 0;
    end
end

Sram ram(
    .enable(ram.addr[31:28] == 1 ? 0 : ram_enable),
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
        (ram.addr[3:0] == 5 ? uart_status : base_ram_data[7:0]) :
        ram.data_read),
    .write_data_in(reg_file.rdata2),
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
    .clk(clk_10M),
    .rst(reset_of_clk10M),
    .waddr(instruction[11:7]),
    .wdata(
        (write_back_ctrl.ctrl == WRITE_BACK_ALU) ? alu.out :
        (write_back_ctrl.ctrl == WRITE_BACK_PC_4) ? PC + 4 :
        (write_back_ctrl.ctrl == WRITE_BACK_IMME) ? imme_gen.imme : rw_data.read_data_out
    ),
    .raddr1(instruction[19:15]),
    .raddr2(instruction[24:20])
);
RegWriteGen reg_write_gen(
    .inst_type(instruction_type.type_),
    .regwrite(reg_file.we)
);
BranchJumpControl branch_jump_control(
    .inst_type(instruction_type.type_),
    .a(reg_file.rdata1),
    .b(reg_file.rdata2),
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
    .a(alu_control.a_select ? reg_file.rdata1 : PC),
    .b(alu_control.b_select ? reg_file.rdata2 : imme_gen.imme),
    .control(alu_control_if)
);

// 不使用内存、串口时，禁用其使能信号


assign uart_rdn = 1'b1;
assign uart_wrn = 1'b1;

// 7段数码管译码器演示，将number用16进制显示在数码管上面
wire[7:0] number;
SEG7_LUT segL(.oSEG1(dpy0), .iDIG(number[3:0])); //dpy0是低位数码管
SEG7_LUT segH(.oSEG1(dpy1), .iDIG(number[7:4])); //dpy1是高位数码管
/* =========== Demo code end =========== */

endmodule
