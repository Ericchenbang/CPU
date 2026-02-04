module ALU(
    input [31:0] x,
    input [31:0] y,
    input [3:0] ALUControl,

    output logic [31:0] ALU_Result,
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


always_comb begin
    unique case (ALUControl) 


    endcase
end

endmodule