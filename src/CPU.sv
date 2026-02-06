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

//////////////////////////////////////////
// Signal Declaration                   //
//////////////////////////////////////////

//----------------------//
// IF                   //
//----------------------//
logic [31:0] PC;
assign im_addr = PC;

logic [31:0] PC_next;

logic [31:0] pc4;
assign pc4 = PC + 4;

logic [31:0] pc_imm;
assign pc_imm = PC + imm;

//----------------------//
// ID                   //
//----------------------//
logic [31:0] instr;
assign instr = im_rdata;

logic [6:0] opcode;
logic [4:0] rd;
logic [2:0] funct3;
logic [4:0] rs1;
logic [4:0] rs2;
logic [6:0] funct7;

/** register file */
logic [31:0] rs1_data;
logic [31:0] rs2_data;

logic reg_write;
logic [31:0] write_data;

/** immediate generator */
logic [31:0] imm;

//----------------------//
// EX                   //
//----------------------//
/** Control Unit */
logic [1:0] ALUOp;
logic ALUSrc;
logic Branch;
logic Jal;
logic Jalr;
logic MemWrite;
logic MemRead;
logic MemToReg;
// logic FALUEnable;

/** ALU Control Unit */
logic [3:0] ALUControl;

/** ALU */
// ALU operand mux
logic [31:0] alu_in2;

logic [31:0] alu_result;
logic zero;

//----------------------//
// MEM                  //
//----------------------//

//----------------------//
// WB                   //
//----------------------//


//////////////////////////////////////////////////
// Logic                                        //
//////////////////////////////////////////////////

//----------------------//
// IF                   //
//----------------------//

logic eq;
logic lt;
logic ltu;

logic take_branch;

logic [1:0] PCSel;

comparator u_com(
    .rs1(rs1_data),
    .rs2(rs2_data),
    .eq(eq),
    .lt(lt),
    .ltu(ltu)
);

branch_decision u_br_dec(
    .Branch(Branch),
    .funct3(funct3),
    .eq(eq),
    .lt(lt),
    .ltu(ltu),
    .take_branch(take_branch)
);

pc_select u_pc_sel(
    .Branch(Branch),
    .take_branch(take_branch),
    .Jal(Jal),
    .Jalr(Jalr),
    .PCSel(PCSel)
);

pc_mux u_pc_mux(
    .PCSel(PCSel),
    .pc4(pc4),
    .pc_imm(pc_imm),
    .ALU_Result(alu_result),
    .pc_next(PC_next)
);


always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        PC <= 0;
    end
    else begin
        PC <= PC_next;
    end
end

//----------------------//
// ID                   //
//----------------------//
assign opcode = instr[6:0];
assign rd = instr[11:7];
assign funct3 = instr[14:12];
assign rs1 = instr[19:15];
assign rs2 = instr[24:20];
assign funct7 = instr[31:25];

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

imm_gen u_imm(
    .instr(instr),
    .imm(imm)
);

//----------------------//
// EX                   //
//----------------------//
Control_Unit u_ctrl(
    .opcode(opcode),
    .ALUOp(ALUOp),
    .ALUSrc(ALUSrc),
    .Branch(Branch),
    .Jal(Jal),
    .Jalr(Jalr),
    .MemWrite(MemWrite),
    .MemRead(MemRead),
    .MemToReg(MemToReg),
    .RegWrite(reg_write),
    .FALUEnable()
);

ALU_Control_Unit u_aluctrl(
    .ALUOp(ALUOp),
    .funct7(funct7),
    .funct3(funct3),
    .ALUControl(ALUControl)
);

assign alu_in2 = (ALUSrc) ? imm : rs2_data;

ALU u_alu(
    .rs1(rs1_data),
    .rs2(alu_in2),
    .ALUControl(ALUControl),
    .rd(alu_result),
    .zero(zero)
);

//----------------------//
// MEM                  //
//----------------------//
/** data memory */
assign dm_addr = alu_result;
assign dm_wdata = rs2_data;
assign dm_we = MemWrite;

//----------------------//
// WB                   //
//----------------------//
// writeback mux 
assign write_data = (MemToReg) ? dm_rdata : alu_result;

endmodule