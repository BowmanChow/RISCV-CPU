module RegFile(
    input wire          clk,
    input wire          rst,
    input wire          we,
    input wire[4:0]     waddr,
    input wire[31:0]    wdata,
    
    input wire[4:0]     raddr1,
    output reg[31:0]    rdata1,
    input wire[4:0]     raddr2,
    output reg[31:0]    rdata2
    );
    
reg[31:0] registers[0:31];

always @(posedge clk or posedge rst) begin
    if (rst) begin
        integer i = 0;
        for (i = 0; i < 32; i=i+1) begin
            registers[i] <= 32'h00000000;
        end
    end
    else if (we && waddr != 0) begin
        registers[waddr] <= wdata;
    end
end

assign rdata1 = registers[raddr1];
assign rdata2 = registers[raddr2];

endmodule
