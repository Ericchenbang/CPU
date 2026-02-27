module IF_ID_Reg(
    input clk,
    input rst,
    input stall,
    input flush,

    input [31:0] IF_PC,
    input [31:0] IF_pc4,
    input [31:0] IF_instr,

    input logic IF_predicted_taken,

    output logic [31:0] ID_PC,
    output logic [31:0] ID_pc4,
    output logic [31:0] ID_instr,

    output logic ID_predicted_taken
);

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        ID_PC       <= 32'b0;
        ID_pc4      <= 32'b0;
        ID_instr    <= 32'h00000013; // NOP, but TSMC16 can't reset non-zero, need further check
        ID_predicted_taken <= 1'b0;
    end
    else if (flush) begin
        ID_PC       <= 32'b0;
        ID_pc4      <= 32'b0;
        ID_instr    <= 32'h00000013;
        ID_predicted_taken <= 1'b0;
    end
    else if (!stall) begin
        ID_PC       <= IF_PC;
        ID_pc4      <= IF_pc4;
        ID_instr    <= IF_instr;
        ID_predicted_taken <= IF_predicted_taken;
    end
    // IF stall = 1: hold current values
    // Stall is for load-use hazards to wait for data
end

endmodule