module Control_Unit(
    input [6:0] opcode,

    output logic [1:0] ALUOp,       // 0: add for lw/sw, 1: sub for branch, 
                                    // 2: R-type, 3: Second prat I-type
    
    
    
    output logic ALUSrc,            // 0: rs2, 1: imm
    output logic Branch,
    output logic Jal,
    output logic Jalr,
    output logic MemWrite,
    output logic MemRead,
    output logic MemToReg,     
    output logic RegWrite,
    output logic FALUEnable         // 0: not float operation, 1: need Float ALU
);
 

always_comb begin
    Jal = 1'b0;
    Jalr = 1'b0;
    unique case (opcode)
        // R-type
        7'b0110011: begin
            ALUOp = 2'b10;
            ALUSrc = 1'b0;
            Branch = 1'b0;
            MemWrite = 1'b0;
            MemRead = 1'b0;
            MemToReg = 1'b0;
            RegWrite = 1'b1;
            FALUEnable = 1'b0;
        end
        // First part I-type
        7'b0000011: begin
            ALUOp = 2'b00;
            ALUSrc = 1'b1;
            Branch = 1'b0;
            MemWrite = 1'b0;
            MemRead = 1'b1;
            MemToReg = 1'b1;
            RegWrite = 1'b1;
            FALUEnable = 1'b0;
        end
        // Second part I-type
        7'b0010011: begin
            ALUOp = 2'b11;
            ALUSrc = 1'b1;
            Branch = 1'b0;
            MemWrite = 1'b0;
            MemRead = 1'b0;
            MemToReg = 1'b0;
            RegWrite = 1'b1;
            FALUEnable = 1'b0;
        end
        // JALR
        7'b1100111: begin
            ALUOp = 2'b00;
            ALUSrc = 1'b0;
            Branch = 1'b1;
            Jalr = 1'b1;
            MemWrite = 1'b0;
            MemRead = 1'b0;
            MemToReg = 1'b0;
            RegWrite = 1'b1;
            FALUEnable = 1'b0;
        end
        // S-type
        7'b0100011: begin
            ALUOp = 2'b00;
            ALUSrc = 1'b1;
            Branch = 1'b0;
            MemWrite = 1'b1;
            MemRead = 1'b0;
            MemToReg = 1'x;
            RegWrite = 1'b0;
            FALUEnable = 1'b0;
        end
        // B-type: begin
        7'b1100011: begin
            ALUOp = 2'b01;
            ALUSrc = 1'b0;
            Branch = 1'b1;
            MemWrite = 1'b0;
            MemRead = 1'b0;
            MemToReg = 1'x;
            RegWrite = 1'b0;
            FALUEnable = 1'b0;
        end
        // AUIPC
        7'b0010111: begin
            ALUOp = 2'b00;
            ALUSrc = 1'b1;
            Branch = 1'b0;
            MemWrite = 1'b0;
            MemRead = 1'b0;
            MemToReg = 1'b0;
            RegWrite = 1'b1;
            FALUEnable = 1'b0;
        end
        // LUI
        7'b0110111: begin
            ALUOp = 2'b00;
            ALUSrc = 1'b1;
            Branch = 1'b0;
            MemWrite = 1'b0;
            MemRead = 1'b0;
            MemToReg = 1'b0;
            RegWrite = 1'b1;
            FALUEnable = 1'b0;
        end
        // JAL
        7'b1101111: begin
            ALUOp = 2'b00;
            ALUSrc = 1'b0;
            Branch = 1'b1;
            Jal = 1'b1;
            MemWrite = 1'b0;
            MemRead = 1'b0;
            MemToReg = 1'b0;
            RegWrite = 1'b1;
            FALUEnable = 1'b0;
        end
        // FADD.S, FSUB.S
        7'b1010011: begin
            ALUOp = 2'b10;
            ALUSrc = 1'b0;
            Branch = 1'b0;
            MemWrite = 1'b0;
            MemRead = 1'b0;
            MemToReg = 1'b0;
            RegWrite = 1'b1;
            FALUEnable = 1'b1;
        end
        // FLW
        7'b0000111: begin
            ALUOp = 2'b00;
            ALUSrc = 1'b1;
            Branch = 1'b0;
            MemWrite = 1'b0;
            MemRead = 1'b1;
            MemToReg = 1'b1;
            RegWrite = 1'b1;
            FALUEnable = 1'b0;
        end
        // FSW
        7'b0100111: begin
            ALUOp = 2'b00;
            ALUSrc = 1'b1;
            Branch = 1'b0;
            MemWrite = 1'b1;
            MemRead = 1'b0;
            MemToReg = 1'x;
            RegWrite = 1'b0;
            FALUEnable = 1'b0;
        end
        // CSR


    endcase
end


endmodule