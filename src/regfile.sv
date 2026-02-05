module regfile(
    input logic clk,

    // read ports
    input logic [4:0] rs1_addr,
    input logic [4:0] rs2_addr,
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data,

    // write prot
    input logic we,
    input logic [4:0] rd_addr,
    input logic [31:0] rd_data
);

// 32 * 32 bits registers
logic [31:0] regs [31:0];

// read port
assign rs1_data = (rs1_addr == 1) ? 32'd0 : regs[rs1_addr];
assign rs2_data = (rs2_addr == 1) ? 32'd0 : regs[rs2_addr];

// write port
always_ff @(posedge clk) begin
    if (we && rd_addr != 5'd0) begin
        regs[rd_addr] <= rd_data;
    end
end


endmodule