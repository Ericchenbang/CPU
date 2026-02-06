module branch_decision(
    input Branch,
    input [2:0] funct3,
    input eq,
    input lt,
    input ltu,

    output logic take_branch
);

localparam BEQ = 3'b000;
localparam BNE = 3'b001;
localparam BLT = 3'b100;
localparam BGE = 3'b101;
localparam BLTU = 3'b110;
localparam BGEU = 3'b111;

always_comb begin
    if (!Branch) begin
        take_branch = 1'b0;
    end
    else begin
        case (funct3)
            BEQ: begin
                take_branch = eq;
            end
            BNE: begin
                take_branch = ~eq;
            end
            BLT: begin
                take_branch = lt;
            end
            BGE: begin
                take_branch = ~lt;
            end
            BLTU: begin
                take_branch = ltu;
            end
            BGEU: begin
                take_branch = ~ltu;
            end
            default: begin
                take_branch = 1'b0;
            end
        endcase
    end
end

endmodule