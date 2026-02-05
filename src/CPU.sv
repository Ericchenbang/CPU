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

/** PC */
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


/** register file */
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

/** immediate generator */
logic [31:0] imm;

imm_gen u_imm(
    .instr(instr),
    .imm(imm)
);


/** Control Unit */
logic [1:0] ALUOp;
logic ALUSrc;
logic Branch;
logic MemWrite;
logic MemRead;
logic MemToReg;
// logic FALUEnable;

Control_Unit u_ctrl(
    .opcode(opcode),
    .ALUOp(ALUOp),
    .ALUSrc(ALUSrc),
    .Branch(Branch),
    .MemWrite(MemWrite),
    .MemRead(MemRead),
    .MemToReg(MemToReg),
    .RegWrite(reg_write),
    .FALUEnable()
);

/** ALU Control Unit */
logic [31:0] ALUControl;

ALU_Control_Unit u_aluctrl(
    .ALUOp(ALUOp),
    .funct7(funct7),
    .funct3(funct3),
    .ALUControl(ALUControl)
);


/** ALU */
// ALU operand mux
logic [31:0] alu_in2;
assign alu_in2 = (ALUSrc) ? imm : rs2_data;

logic [31:0] alu_result;
logic zero;

ALU u_alu(
    .rs1(rs1_data),
    .rs2(alu_in2),
    .ALUControl(ALUControl),
    .rd(alu_result),
    .zero(zero)
);

/** data memory */
assign dm_addr = alu_result;
assign dm_wdata = rs2_data;
assing dm_we = MemWrite;

// writeback mux 
assign write_data = (MemToReg) ? dm_rdata : alu_result;

endmodule