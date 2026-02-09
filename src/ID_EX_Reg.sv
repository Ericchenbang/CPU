module ID_EX_Reg(
    input clk,
    input rst,
    input flush,

    // Data inputs from ID stage
    input [31:0] ID_PC,
    input [31:0] ID_pc4,
    input [31:0] ID_rs1_data,
    input [31:0] ID_rs2_data,
    input [31:0] ID_imm,

    // Register addresses (for forwarding)
    input [4:0] ID_rs1,
    input [4:0] ID_rs2,
    input [4:0] ID_rd,
    input [2:0] ID_funct3,

    // Control signals from ID
    input [3:0] ID_ALUControl,
    input [1:0] ID_ALUSrcA,
    input       ID_ALUSrcB,
    input       ID_MemWrite,
    input       ID_MemRead,
    input       ID_RegWrite,
    input [1:0] ID_ResultSrc,

    // Data outputs to EX stage
    output logic [31:0] EX_PC,
    output logic [31:0] EX_pc4,
    output logic [31:0] EX_rs1_data,
    output logic [31:0] EX_rs2_data,
    output logic [31:0] EX_imm,

    // Register addresses
    output logic [4:0] EX_rs1,
    output logic [4:0] EX_rs2,
    output logic [4:0] EX_rd,
    output logic [2:0] EX_funct3,

    // Control signals to EX
    output logic [3:0] EX_ALUControl,
    output logic [1:0] EX_ALUSrcA,
    output logic       EX_ALUSrcB,
    output logic       EX_MemWrite,
    output logic       EX_MemRead,
    output logic       EX_RegWrite,
    output logic [1:0] EX_ResultSrc
);


always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        EX_PC       <= 32'b0;
        EX_pc4      <= 32'b0;
        EX_rs1_data <= 32'b0;
        EX_rs2_data <= 32'b0;
        EX_imm      <= 32'b0;

        EX_rs1      <= 5'b0;
        EX_rs2      <= 5'b0;
        EX_rd       <= 5'b0;
        EX_funct3   <= 3'b0;

        EX_ALUControl <= 4'b0;
        EX_ALUSrcA  <= 2'b0;
        EX_ALUSrcB  <= 1'b0;

        EX_MemWrite <= 1'b0;
        EX_MemRead  <= 1'b0;
        EX_RegWrite <= 1'b0;
        EX_ResultSrc <= 2'b0;
    end
    else if (flush) begin
        EX_PC       <= 32'b0;
        EX_pc4      <= 32'b0;
        EX_rs1_data <= 32'b0;
        EX_rs2_data <= 32'b0;
        EX_imm      <= 32'b0;

        EX_rs1      <= 5'b0;
        EX_rs2      <= 5'b0;
        EX_rd       <= 5'b0;
        EX_funct3   <= 3'b0;

        EX_ALUControl <= 4'b0;
        EX_ALUSrcA  <= 2'b0;
        EX_ALUSrcB  <= 1'b0;

        EX_MemWrite <= 1'b0;
        EX_MemRead  <= 1'b0;
        EX_RegWrite <= 1'b0;
        EX_ResultSrc <= 2'b0;
    end
    else begin
        EX_PC       <= ID_PC;
        EX_pc4      <= ID_pc4;
        EX_rs1_data <= ID_rs1_data;
        EX_rs2_data <= ID_rs2_data;
        EX_imm      <= ID_imm;

        EX_rs1      <= ID_rs1;
        EX_rs2      <= ID_rs2;
        EX_rd       <= ID_rd;
        EX_funct3   <= ID_funct3;

        EX_ALUControl <= ID_ALUControl;
        EX_ALUSrcA  <= ID_ALUSrcA;
        EX_ALUSrcB  <= ID_ALUSrcB;

        EX_MemWrite <= ID_MemWrite;
        EX_MemRead  <= ID_MemRead;
        EX_RegWrite <= ID_RegWrite;
        EX_ResultSrc <= ID_ResultSrc;
    end
end

endmodule