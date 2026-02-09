module EX_MEM_Reg(
    input clk,
    input rst,

    // Data inputs from EX stage
    input [31:0] EX_pc4,
    input [31:0] EX_alu_result,
    input [31:0] EX_rs2_data,

    // Metadata
    input [4:0]  EX_rd,
    input [2:0]  EX_funct3,

    // Control signals from EX
    input        EX_MemWrite,
    input        EX_MemRead,
    input        EX_RegWrite,
    input [1:0]  EX_ResultSrc,

    // Data outputs to MEM stage
    output logic [31:0] MEM_pc4,
    output logic [31:0] MEM_alu_result,
    output logic [31:0] MEM_rs2_data,

    // Metadata
    output logic [4:0]  MEM_rd,
    output logic [2:0]  MEM_funct3,

    // Control signals to MEM
    output logic        MEM_MemWrite,
    output logic        MEM_MemRead,
    output logic        MEM_RegWrite,
    output logic [1:0]  MEM_ResultSrc
);

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        MEM_pc4         <= 32'b0;
        MEM_alu_result  <= 32'b0;
        MEM_rs2_data    <= 32'b0;
        
        MEM_rd          <= 5'b0;
        MEM_funct3      <= 3'b0;
        
        MEM_MemWrite    <= 1'b0;
        MEM_MemRead     <= 1'b0;
        MEM_RegWrite    <= 1'b0;
        MEM_ResultSrc   <= 2'b0;
    end
    else begin
        MEM_pc4         <= EX_pc4;
        MEM_alu_result  <= EX_alu_result;
        MEM_rs2_data    <= EX_rs2_data;
        
        MEM_rd          <= EX_rd;
        MEM_funct3      <= EX_funct3;
        
        MEM_MemWrite    <= EX_MemWrite;
        MEM_MemRead     <= EX_MemRead;
        MEM_RegWrite    <= EX_RegWrite;
        MEM_ResultSrc   <= EX_ResultSrc;
    end
end

endmodule