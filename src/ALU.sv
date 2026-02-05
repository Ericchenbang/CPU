module ALU(
    input [31:0] rs1,
    input [31:0] rs2,
    input [3:0] ALUControl,

    output logic [31:0] rd,
    output logic zero
);

localparam ADD = 4'b0000;
localparam SUB = 4'b1000;
localparam SLL = 4'b0001;
localparam SLT = 4'b0010;
localparam SLTU = 4'b0011;
localparam XOR = 4'b0100;
localparam SRL = 4'b0101;
localparam SRA = 4'b1101;
localparam OR = 4'b0110;
localparam AND = 4'b0111;

assign zero = (rs1 == rs2);

always_comb begin
    unique case (ALUControl) 
        ADD: begin
            rd = rs1 + rs2;
        end
        SUB: begin
            rd = rs1 - rs2;
        end
        SLL: begin
            rd = $unsigned(rs1) << rs2[4:0];
        end
        SLT: begin
            rd = $signed(rs1) < $signed(rs2) ? 1 : 0;
        end
        SLTU: begin
            rd = $unsigned(rs1) < $unsigned(rs2) ? 1 : 0;
        end
        XOR: begin
            rd = rs1 ^ rs2;
        end
        SRL: begin
            rd = $unsigned(rs1) >> rs2[4:0];
        end
        SRA: begin
            rd = $signed(rs1) >> rs2[4:0];
        end
        OR: begin
            rd = rs1 | rs2;
        end
        AND: begin
            rd = rs1 & rs2;
        end
    endcase
end

endmodule