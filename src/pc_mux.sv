module pc_mux(
    input [1:0] PCSel,
    input [31:0] pc4,
    input [31:0] pc_imm,
    input [31:0] ALU_Result,

    output logic [31:0] pc_next
);

always_comb begin
    case (PCSel)
        2'b00: begin
            pc_next = pc4;
        end
        // JAL
        2'b01: begin
            pc_next = pc_imm;
        end
        // JALR
        2'b10: begin
            pc_next = {ALU_Result[31:1], 1'b0};
        end
        default: begin
            pc_next = pc4;
        end
    endcase
end

endmodule