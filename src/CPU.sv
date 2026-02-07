module CPU(
    input clk,
    input rst,

    // instruction memory
    output logic [31:0] im_addr,
    input logic [31:0] im_rdata,    // read data

    // data memory
    output logic [31:0] dm_addr,
    output logic [31:0] dm_wdata,   // write data
    output logic [3:0] dm_web,      // write enable mask
    input logic [31:0] dm_rdata     // read data
);

//////////////////////////////////////////
// Signal Declaration                   //
//////////////////////////////////////////

//----------------------//
// IF                   //
//----------------------//
logic [31:0] PC;

logic [31:0] PC_next;

logic [31:0] pc4;

logic [31:0] pc_imm;

logic eq;
logic lt;
logic ltu;

logic take_branch;

logic [1:0] PCSel;

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

logic RegWrite;
logic [31:0] write_data;

/** immediate generator */
logic [31:0] imm;

//----------------------//
// EX                   //
//----------------------//
/** Control Unit */
logic [1:0] ALUOp;
logic [1:0] ALUSrcA;
logic ALUSrcB;
logic Branch;
logic Jal;
logic Jalr;
logic MemWrite;
logic MemRead;
logic [1:0] ResultSrc;
// logic FALUEnable;

/** ALU Control Unit */
logic [3:0] ALUControl;

/** ALU */
/* ALU operand mux */
logic [31:0] alu_in1;
logic [31:0] alu_in2;

logic [31:0] alu_result;

//----------------------//
// MEM                  //
//----------------------//

//----------------------//
// WB                   //
//----------------------//
logic [31:0] load_data_final;

//////////////////////////////////////////////////
// Logic                                        //
//////////////////////////////////////////////////

//----------------------//
// IF                   //
//----------------------//

assign im_addr = PC;
assign pc4 = PC + 32'd4;
assign pc_imm = PC + imm;

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
    .we(RegWrite),
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
    .ALUSrcA(ALUSrcA),
    .ALUSrcB(ALUSrcB),
    .Branch(Branch),
    .Jal(Jal),
    .Jalr(Jalr),
    .MemWrite(MemWrite),
    .MemRead(MemRead),
    .ResultSrc(ResultSrc),
    .RegWrite(RegWrite),
    .FALUEnable()
);

ALU_Control_Unit u_aluctrl(
    .ALUOp(ALUOp),
    .funct7(funct7),
    .funct3(funct3),
    .ALUControl(ALUControl)
);


always_comb begin
    case (ALUSrcA) 
        2'b00: alu_in1 = rs1_data;
        2'b01: alu_in1 = PC;
        2'b10: alu_in1 = 32'b0;
        default: alu_in1 = rs1_data;
    endcase
end

assign alu_in2 = (ALUSrcB) ? imm : rs2_data;

ALU u_alu(
    .rs1(alu_in1),
    .rs2(alu_in2),
    .ALUControl(ALUControl),
    .rd(alu_result)
);

//----------------------//
// MEM                  //
//----------------------//
/** data memory */
assign dm_addr = alu_result;

store_data u_store_data(
    .funct3(funct3),
    .MemWrite(MemWrite),
    .rs2_data(rs2_data),
    .alu_result(alu_result),
    .dm_web(dm_web),
    .dm_wdata(dm_wdata)
);

//----------------------//
// WB                   //
//----------------------//

load_data u_load_data(
    .dm_rdata(dm_rdata),
    .funct3(funct3),
    .alu_result(alu_result),
    .load_data_final(load_data_final)
);

// writeback mux 
always_comb begin
    case (ResultSrc)
        2'b00: write_data = alu_result;
        2'b01: write_data = load_data_final;
        2'b10: write_data = pc4;
        default: write_data = 32'b0;
    endcase
end

endmodule