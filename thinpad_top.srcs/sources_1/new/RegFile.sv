module RegFile(
    input wire          clk,
    input wire          rst,
    input wire          we,
    input wire[4:0]     write_addr,
    input wire[31:0]    write_data,
    
    input wire[4:0]     a_addr,
    output wire[31:0]    a_data,
    input wire[4:0]     b_addr,
    output wire[31:0]    b_data,

    output reg[31:0] regs[0:31]
    );

always @(posedge clk or posedge rst) begin
    if (rst) begin
        integer i = 0;
        for (i = 0; i < 32; i=i+1) begin
            regs[i] <= 32'h00000000;
        end
    end
    else if (we && (write_addr != 0)) begin
        regs[write_addr] <= write_data;
    end
end

assign a_data = regs[a_addr];
assign b_data = regs[b_addr];

endmodule
