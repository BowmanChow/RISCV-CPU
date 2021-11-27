module ReadWriteData(
    input wire [31:0] read_data_in, write_data_in,
    input wire [2:0] funct3,
    input wire [1:0] address,
    output reg [31:0] read_data_out,
    output wire [31:0] write_data_out
    );
wire [31:0] read_data_shift;
assign read_data_shift = read_data_in >> {address, 3'b0};
always_comb
    case (funct3)
        3'b000 : read_data_out <= {{24{read_data_shift[7]}}, read_data_shift[7:0]};
        3'b001 : read_data_out <= {{16{read_data_shift[15]}}, read_data_shift[15:0]};
        3'b100 : read_data_out <= {24'h0, read_data_shift[7:0]};
        3'b101 : read_data_out <= {16'h0, read_data_shift[15:0]};
        default : read_data_out <= read_data_shift;
    endcase
reg [31:0] write_data_trunc;
always_comb
    case (funct3)
        3'b000 : write_data_trunc <= {24'h0, write_data_in[7:0]};
        3'b001 : write_data_trunc <= {16'h0, write_data_in[15:0]};
        default : write_data_trunc <= write_data_in;
    endcase
assign write_data_out = write_data_trunc << {address, 3'b0};
endmodule
