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
// IF Stage Signals     //
//----------------------//
logic [31:0] IF_PC;
logic [31:0] IF_pc4;
logic [31:0] IF_PC_next;
logic [31:0] IF_instr;

//----------------------//
// IF/ID Pipeline Reg   //
//----------------------//
logic [31:0] ID_PC;
logic [31:0] ID_pc4;
logic [31:0] ID_instr;

// Hazard control signals (add logic later)
logic IF_ID_stall;
logic IF_ID_flush;


//----------------------//
// ID Stage Signals     //
//----------------------//
logic [6:0] ID_opcode;
logic [4:0] ID_rd;
logic [2:0] ID_funct3;
logic [4:0] ID_rs1;
logic [4:0] ID_rs2;
logic [6:0] ID_funct7;

/** register file */
logic [31:0] ID_rs1_data;
logic [31:0] ID_rs2_data;

/** immediate generator */
logic [31:0] ID_imm;

/** Control Unit */
logic [1:0] ID_ALUOp;
logic [1:0] ID_ALUSrcA;
logic ID_ALUSrcB;
logic ID_Branch;
logic ID_Jal;
logic ID_Jalr;
logic ID_MemWrite;
logic ID_MemRead;
logic ID_RegWrite;
logic [1:0] ID_ResultSrc;
// logic ID_FALUEnable;

/** ALU Control Unit */
logic [3:0] ID_ALUControl;

/** Branch decision signals */
logic [31:0] ID_pc_imm;
logic ID_eq;
logic ID_lt;
logic ID_ltu;
logic ID_take_branch;
logic [1:0] ID_PCSel;

//----------------------//
// EX                   //
//----------------------//
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
logic WB_RegWrite;
logic [5:0] WB_rd;
logic [31:0] WB_write_data;
logic [31:0] load_data_final;

//////////////////////////////////////////////////
// Logic                                        //
//////////////////////////////////////////////////

//----------------------//
// IF State Logic       //
//----------------------//
assign im_addr = IF_PC;
assign IF_instr = im_rdata;
assign IF_pc4 = IF_PC + 32'd4;

/** PC update logic (simplified for now, we'll improve it) */
assign IF_PC_next = IF_pc4;

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        IF_PC <= 32'b0;
    end
    else if (!IF_ID_stall) begin
        IF_PC <= IF_PC_next;
    end
end


//----------------------//
// IF/ID Pipeline Reg   //
//----------------------//
// For now, set stall and flush to 0
assign IF_ID_stall = 1'b0;
assign IF_ID_flush = 1'b0;

IF_ID_Reg u_IF_ID_Reg(
    .clk(clk),
    .rst(rst),
    .stall(IF_ID_stall),
    .flush(IF_ID_flush),
    .IF_PC(IF_PC),
    .IF_pc4(IF_pc4),
    .IF_instr(IF_instr),
    .ID_PC(ID_PC),
    .ID_pc4(ID_pc4),
    .ID_instr(ID_instr)
);


//----------------------//
// ID Stage Logic       //
//----------------------//
assign ID_opcode = ID_instr[6:0];
assign ID_rd = ID_instr[11:7];
assign ID_funct3 = ID_instr[14:12];
assign ID_rs1 = ID_instr[19:15];
assign ID_rs2 = ID_instr[24:20];
assign ID_funct7 = ID_instr[31:25];

regfile u_regfile(
    .clk(clk),
    .rs1_addr(ID_rs1),
    .rs2_addr(ID_rs2),
    .rs1_data(ID_rs1_data),
    .rs2_data(ID_rs2_data),

    // We'll add these signals later
    .we(WB_RegWrite),
    .rd_addr(WB_rd),
    .rd_data(WB_write_data)
);

imm_gen u_imm(
    .instr(ID_instr),
    .imm(ID_imm)
);


Control_Unit u_ctrl(
    .opcode(ID_opcode),
    .ALUOp(ID_ALUOp),
    .ALUSrcA(ID_ALUSrcA),
    .ALUSrcB(ID_ALUSrcB),
    .Branch(ID_Branch),
    .Jal(ID_Jal),
    .Jalr(ID_Jalr),
    .MemWrite(ID_MemWrite),
    .MemRead(ID_MemRead),
    .ResultSrc(ID_ResultSrc),
    .RegWrite(ID_RegWrite),
    .FALUEnable()
);

ALU_Control_Unit u_aluctrl(
    .ALUOp(ID_ALUOp),
    .funct7(ID_funct7),
    .funct3(ID_funct3),
    .ALUControl(ID_ALUControl)
);

assign ID_pc_imm = ID_PC + ID_imm;

comparator u_com(
    .rs1(ID_rs1_data),
    .rs2(ID_rs2_data),
    .eq(ID_eq),
    .lt(ID_lt),
    .ltu(ID_ltu)
);

branch_decision u_br_dec(
    .Branch(ID_Branch),
    .funct3(ID_funct3),
    .eq(ID_eq),
    .lt(ID_lt),
    .ltu(ID_ltu),
    .take_branch(ID_take_branch)
);

pc_select u_pc_sel(
    .Branch(ID_Branch),
    .take_branch(ID_take_branch),
    .Jal(ID_Jal),
    .Jalr(ID_Jalr),
    .PCSel(ID_PCSel)
);

//----------------------//
// EX                   //
//----------------------//

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

pc_mux u_pc_mux(
    .PCSel(PCSel),
    .pc4(pc4),
    .pc_imm(pc_imm),
    .ALU_Result(alu_result),
    .pc_next(PC_next)
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