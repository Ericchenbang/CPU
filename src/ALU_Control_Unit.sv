module ALU_Control_Unit(
    input [1:0] ALUOp,
    input [6:0] funct7,
    input [2:0] funct3,

    output logic [3:0] ALUControl
);


always_comb begin
    unique case (ALUOp) 
        2'b00: begin
            
        end
        2'b01: begin
            
        end
        2'b10: begin
            
        end


    endcase
end





endmodule