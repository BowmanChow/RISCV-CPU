module Sram(
    input wire enable, read, write,
    input wire [31:0] addr,
    input wire [31:0] data_write,
    output wire [31:0] data_read,

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
    output wire ext_ram_we_n      //ExtRAM写使能，低有效
    );
assign base_ram_be_n = 0;
assign ext_ram_be_n = 0;
wire ext_ram_enable = addr[22];
assign base_ram_ce_n = (enable && !ext_ram_enable) ? 1'b0 : 1'b1;
assign ext_ram_ce_n = (enable && ext_ram_enable) ? 1'b0 : 1'b1;
assign base_ram_oe_n = base_ram_ce_n ? 1'b1 : ~read;
assign ext_ram_oe_n = ext_ram_ce_n ? 1'b1 : ~read;
assign base_ram_we_n = (base_ram_ce_n || read) ? 1'b1 : ~write;
assign ext_ram_we_n = (ext_ram_ce_n || read) ? 1'b1 : ~write;
assign base_ram_addr = addr[21:2];
assign ext_ram_addr = addr[21:2];
assign base_ram_data = read ? 'bz : data_write;
assign ext_ram_data = read ? 'bz : data_write;
assign data_read = ext_ram_enable ? ext_ram_data : base_ram_data;
endmodule
