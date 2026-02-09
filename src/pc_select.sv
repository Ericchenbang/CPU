module pc_select(
    input Branch,
    input take_branch,
    input Jal,
    input Jalr,

    // 2'b00: PC + 4, 2'b01: PC + imm, 2'b10: ALU_result
    output logic [1:0] PCSel
);

always_comb begin
    if (Jalr) begin
        PCSel = 2'b10;
    end
    else if (Jal) begin
        PCSel = 2'b01;
    end
    else if (Branch && take_branch) begin
        PCSel = 2'b01;
    end
    else begin
        PCSel = 2'b00;
    end
end

endmodule