module MEM_WB_Reg(
    input clk,
    input rst,

    // Data inputs from MEM stage
    input [31:0] MEM_pc4,
    input [31:0] MEM_alu_result,
    input [31:0] MEM_load_data,

    // CSR
    input [31:0] MEM_csr_rdata,

    // Metadata
    input [4:0]  MEM_rd,

    // Control signals from MEM
    input        MEM_RegWrite,
    input [1:0]  MEM_ResultSrc,

    // FP signal
    input [31:0] MEM_fp_load_data,
    input [31:0] MEM_fp_result,
    input        MEM_FPRegWrite,

    // Data outputs to WB stage
    output logic [31:0] WB_pc4,
    output logic [31:0] WB_alu_result,
    output logic [31:0] WB_load_data,

    // CSR
    output logic [31:0] WB_csr_rdata,

    // Metadata
    output logic [4:0]  WB_rd,

    // Control signals to WB
    output logic        WB_RegWrite,
    output logic [1:0]  WB_ResultSrc,

    // FP signal
    output logic [31:0] WB_fp_load_data,
    output logic [31:0] WB_fp_result,
    output logic        WB_FPRegWrite
);

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        WB_pc4          <= 32'b0;
        WB_alu_result   <= 32'b0;
        WB_load_data    <= 32'b0;

        WB_csr_rdata    <= 32'b0;

        WB_rd           <= 5'b0;

        WB_RegWrite     <= 1'b0;
        WB_ResultSrc    <= 2'b0;

        WB_fp_load_data <= 32'b0;
        WB_fp_result    <= 32'b0;
        WB_FPRegWrite   <= 1'b0;
    end
    else begin
        WB_pc4          <= MEM_pc4;
        WB_alu_result   <= MEM_alu_result;
        WB_load_data    <= MEM_load_data;

        WB_csr_rdata    <= MEM_csr_rdata;

        WB_rd           <= MEM_rd;

        WB_RegWrite     <= MEM_RegWrite;
        WB_ResultSrc    <= MEM_ResultSrc;

        WB_fp_load_data <= MEM_fp_load_data;
        WB_fp_result    <= MEM_fp_result;
        WB_FPRegWrite   <= MEM_FPRegWrite;
    end
end

endmodule