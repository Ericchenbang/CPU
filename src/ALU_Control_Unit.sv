module ALU_Control_Unit(
    input [1:0] ALUOp,
    input [6:0] funct7,
    input [2:0] funct3,

    output logic [3:0] ALUControl
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

always_comb begin
    unique case (ALUOp) 
        2'b00: begin
            ALUControl = ADD;
        end
        2'b01: begin
            ALUControl = SUB;
        end
        2'b10: begin
            ALUControl = {funct7[5], funct3};
        end
        2'b11: begin
            ALUControl = {1'b0, funct3};
        end
        default: begin
            ALUControl = ADD;
        end
    endcase
end
endmodule