module CPU(
    input clk,
    input rst,

    // instruction memory
    output logic [31:0] im_addr;
    input logic [31:0] im_rdata;    // read data

    // data memory
    output logic [31:0] dm_addr;
    output logic [31:0] dm_wdata;   // write data
    output logic dm_we,             // write enable
    input logic [31:0] dm_rdata;    // read data
);

// PC
logic [31:0] PC;
assign im_addr = PC;

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        PC <= 0;
    end
    else begin
        PC <= PC + 4;   // ?
    end
end

//------------------------------------//
// ID
//------------------------------------//
logic [31:0] instr;
assign instr = im_rdata;

logic [6:0] opcode;
logic [4:0] rd;
logic [2:0] funct3;
logic [4:0] rs1;
logic [4:0] rs2;
logic [6:0] funct7;

assign opcode = instr[6:0];
assign rd = instr[11:7];
assign funct3 = instr[14:12];
assign rs1 = instr[19:15];
assign rs2 = instr[24:20];
assign funct7 = instr[31:25];


// register file
logic [31:0] rs1_data;
logic [31:0] rs2_data;

logic reg_write;
logic [31:0] write_data;

regfile u_regfile(
    .clk(clk),
    .rs1_addr(rs1),
    .rs2_addr(rs2),
    .rs1_data(rs1_data),
    .rs2_data(rs2_data),
    .we(reg_write),
    .rd_addr(rd),
    .rd_data(write_data)
);

// immediate generator
logic [31:0] imm;

imm_gen u_imm(
    .instr(instr),
    .imm(imm)
);




endmodule