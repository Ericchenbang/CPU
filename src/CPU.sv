module CPU(
    input logic clk,
    input logic rst,

    // instruction memory
    output logic [31:0] im_addr,
    input  logic [31:0] im_rdata,    // read data

    // data memory
    output logic [31:0] dm_addr,
    output logic [31:0] dm_wdata,   // write data
    output logic [3:0]  dm_web,      // write enable mask
    input  logic [31:0] dm_rdata     // read data
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
// ID/EX Pipeline Reg   //
//----------------------//
logic ID_EX_flush;

logic [31:0] EX_PC;
logic [31:0] EX_pc4;
logic [31:0] EX_rs1_data;
logic [31:0] EX_rs2_data;
logic [31:0] EX_imm;

logic [4:0] EX_rs1;
logic [4:0] EX_rs2;
logic [4:0] EX_rd;
logic [2:0] EX_funct3;

logic [3:0] EX_ALUControl;
logic [1:0] EX_ALUSrcA;
logic EX_ALUSrcB;
logic EX_MemWrite;
logic EX_MemRead;
logic EX_RegWrite;
logic [1:0] EX_ResultSrc;


//----------------------//
// EX State Signals     //
//----------------------//
/* ALU operand mux */
logic [31:0] EX_alu_in1;
logic [31:0] EX_alu_in2;
logic [31:0] EX_alu_result;

// Forwarding signals
logic [1:0] ForwardA;
logic [1:0] ForwardB;
logic [31:0] EX_forward_rs1;
logic [31:0] EX_forward_rs2;


//----------------------//
// EX/MEM Pipeline Reg  //
//----------------------//
logic [31:0] MEM_pc4;
logic [31:0] MEM_alu_result;
logic [31:0] MEM_rs2_data;
logic [4:0] MEM_rd;
logic [2:0] MEM_funct3;
logic MEM_MemWrite;
logic MEM_MemRead;
logic MEM_RegWrite;
logic [1:0] MEM_ResultSrc;

//----------------------//
// MEM Stage Signals    //
//----------------------//
logic [31:0] MEM_load_data;


//----------------------//
// MEM/WB Pipeline Reg  //
//----------------------//
logic [31:0] WB_pc4;
logic [31:0] WB_alu_result;
logic [31:0] WB_load_data;
logic [4:0] WB_rd;
logic WB_RegWrite;
logic [1:0] WB_ResultSrc;

//----------------------//
// WB                   //
//----------------------//
logic [31:0] WB_write_data;






//////////////////////////////////////////////////
// Logic                                        //
//////////////////////////////////////////////////
//----------------------//
// IF State Logic       //
//----------------------//
assign im_addr = IF_PC;
assign IF_instr = im_rdata;
assign IF_pc4 = IF_PC + 32'd4;

pc_mux u_pc_mux(
    .PCSel(ID_PCSel),
    .pc4(IF_pc4),
    .pc_imm(ID_pc_imm),
    .ALU_Result(EX_alu_result),
    .pc_next(IF_PC_next)
);

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

    .we(WB_RegWrite),
    .rd_addr(WB_rd),
    .rd_data(WB_write_data)
);

imm_gen u_imm(
    .instr(ID_instr),

    .imm(ID_imm)
);

assign ID_pc_imm = ID_PC + ID_imm;

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
// ID/EX Pipeline Reg   //
//----------------------//
// For now, no flush (we'all add branch logic later)
assign ID_EX_flush = 1'b0;

ID_EX_Reg u_ID_EX_Reg(
    .clk(clk),
    .rst(rst),
    .flush(ID_EX_flush),

    .ID_PC(ID_PC),
    .ID_pc4(ID_pc4),
    .ID_rs1_data(ID_rs1_data),
    .ID_rs2_data(ID_rs2_data),
    .ID_imm(ID_imm),

    .ID_rs1(ID_rs1),
    .ID_rs2(ID_rs2),
    .ID_rd(ID_rd),
    .ID_funct3(ID_funct3),

    .ID_ALUControl(ID_ALUControl),
    .ID_ALUSrcA(ID_ALUSrcA),
    .ID_ALUSrcB(ID_ALUSrcB),
    .ID_MemWrite(ID_MemWrite),
    .ID_MemRead(ID_MemRead),
    .ID_RegWrite(ID_RegWrite),
    .ID_ResultSrc(ID_ResultSrc),

    .EX_PC(EX_PC),
    .EX_pc4(EX_pc4),
    .EX_rs1_data(EX_rs1_data),
    .EX_rs2_data(EX_rs2_data),
    .EX_imm(EX_imm),

    .EX_rs1(EX_rs1),
    .EX_rs2(EX_rs2),
    .EX_rd(EX_rd),
    .EX_funct3(EX_funct3),

    .EX_ALUControl(EX_ALUControl),
    .EX_ALUSrcA(EX_ALUSrcA),
    .EX_ALUSrcB(EX_ALUSrcB),
    .EX_MemWrite(EX_MemWrite),
    .EX_MemRead(EX_MemRead),
    .EX_RegWrite(EX_RegWrite),
    .EX_ResultSrc(EX_ResultSrc)
);

//----------------------//
// Forwarding Unit      //
//----------------------//
Forwarding_Unit u_forwarding(
    .EX_rs1(EX_rs1),
    .EX_rs2(EX_rs2),

    .MEM_rd(MEM_rd),
    .MEM_RegWrite(MEM_RegWrite),

    .WB_rd(WB_rd),
    .WB_RegWrite(WB_RegWrite),

    .ForwardA(ForwardA),
    .ForwardB(ForwardB)
);

//----------------------//
// EX Stage             //
//----------------------//

/** Apply Forwarding to rs1 and rs2 */
always_comb begin
    case (ForwardA)
        2'b00: EX_forward_rs1 = EX_rs1_data;
        2'b01: EX_forward_rs1 = MEM_alu_result;
        2'b10: EX_forward_rs1 = WB_write_data;
        default: EX_forward_rs1 = EX_rs1_data;
    endcase
end
always_comb begin
    case (ForwardB)
        2'b00: EX_forward_rs2 = EX_rs2_data;
        2'b01: EX_forward_rs2 = MEM_alu_result;
        2'b10: EX_forward_rs2 = WB_write_data;
        default: EX_forward_rs2 = EX_rs2_data;
    endcase
end


always_comb begin
    case (EX_ALUSrcA) 
        2'b00: EX_alu_in1 = EX_forward_rs1;
        2'b01: EX_alu_in1 = EX_PC;
        2'b10: EX_alu_in1 = 32'b0;
        default: EX_alu_in1 = EX_forward_rs1;
    endcase
end

assign EX_alu_in2 = (EX_ALUSrcB) ? EX_imm : EX_forward_rs2;

ALU u_alu(
    .rs1(EX_alu_in1),
    .rs2(EX_alu_in2),
    .ALUControl(EX_ALUControl),

    .rd(EX_alu_result)
);


//----------------------//
// EX/MEM Pipeline Reg  //
//----------------------//
EX_MEM_Reg u_EX_MEM_Reg(
    .clk(clk),
    .rst(rst),

    .EX_pc4(EX_pc4),
    .EX_alu_result(EX_alu_result),
    .EX_rs2_data(EX_forward_rs2),
    .EX_rd(EX_rd),
    .EX_funct3(EX_funct3),
    .EX_MemWrite(EX_MemWrite),
    .EX_MemRead(EX_MemRead),
    .EX_RegWrite(EX_RegWrite),
    .EX_ResultSrc(EX_ResultSrc),

    .MEM_pc4(MEM_pc4),
    .MEM_alu_result(MEM_alu_result),
    .MEM_rs2_data(MEM_rs2_data),
    .MEM_rd(MEM_rd),
    .MEM_funct3(MEM_funct3),
    .MEM_MemWrite(MEM_MemWrite),
    .MEM_MemRead(MEM_MemRead),
    .MEM_RegWrite(MEM_RegWrite),
    .MEM_ResultSrc(MEM_ResultSrc)
);


//----------------------//
// MEM Stage            //
//----------------------//
/** data memory */
assign dm_addr = MEM_alu_result;

store_data u_store_data(
    .funct3(MEM_funct3),
    .MemWrite(MEM_MemWrite),
    .rs2_data(MEM_rs2_data),
    .alu_result(MEM_alu_result),

    .dm_web(dm_web),
    .dm_wdata(dm_wdata)
);

load_data u_load_data(
    .dm_rdata(dm_rdata),
    .funct3(MEM_funct3),
    .alu_result(MEM_alu_result),
    
    .load_data_final(MEM_load_data)
);


//----------------------//
// MEM/WB Pipeline Reg  //
//----------------------//
MEM_WB_Reg u_MEM_WB_Reg(
    .clk(clk),
    .rst(rst),

    .MEM_pc4(MEM_pc4),
    .MEM_alu_result(MEM_alu_result),
    .MEM_load_data(MEM_load_data),
    .MEM_rd(MEM_rd),
    .MEM_RegWrite(MEM_RegWrite),
    .MEM_ResultSrc(MEM_ResultSrc),

    .WB_pc4(WB_pc4),
    .WB_alu_result(WB_alu_result),
    .WB_load_data(WB_load_data),
    .WB_rd(WB_rd),
    .WB_RegWrite(WB_RegWrite),
    .WB_ResultSrc(WB_ResultSrc)
);

//----------------------//
// WB Stage             //
//----------------------//
// writeback mux 
always_comb begin
    case (WB_ResultSrc)
        2'b00: WB_write_data = WB_alu_result;
        2'b01: WB_write_data = WB_load_data;
        2'b10: WB_write_data = WB_pc4;
        default: WB_write_data = 32'b0;
    endcase
end

endmodule