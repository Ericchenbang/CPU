/* Handels two types of hazards:
/* 1. EX Hazard: Forward from EX/MEM register 
/* 2. MEM Hazard: Forward from MEM/WB register
/* Priority: EX Hazard takes precedence over MEM Hazard
*/
module Forwarding_Unit(
    // Source registers in EX stage
    input [4:0] EX_rs1,
    input [4:0] EX_rs2,

    // Destination register in MEM stage
    input [4:0] MEM_rd,
    input       MEM_RegWrite,

    // Destination register in WB stage
    input [4:0] WB_rd,
    input       WB_RegWrite,

    // Forwarding control outputs
    // 00: EX_rs*_data (no forwarding)
    // 01: Forward from MEM_alu_result (EX/MEM)
    // 10: Forward from WB_write_data (MEM/WB)
    output logic [1:0] ForwardA,
    output logic [1:0] ForwardB
);

// ForwardA: Controls forwarding for ALU operand A (from rs1)
always_comb begin
    ForwardA = 2'b00;

    // EX Hazard
    if (MEM_RegWrite && (MEM_rd != 5'b0) && (MEM_rd == EX_rs1)) begin
        ForwardA = 2'b01;
    end
    // MEM Hazard
    else if (WB_RegWrite && (WB_rd != 5'b0) && (WB_rd == EX_rs1)) begin
        ForwardA = 2'b10;
    end 
end

// ForwardB: Controls forwarding for ALU operand B (from rs2)
always_comb begin
    ForwardB = 2'b00;

    // EX Hazard
    if (MEM_RegWrite && (MEM_rd != 5'b0) && (MEM_rd == EX_rs2)) begin
        ForwardB = 2'b01;
    end
    // MEM Hazard
    else if (WB_RegWrite && (WB_rd != 5'b0) && (WB_rd == EX_rs2)) begin
        ForwardB = 2'b10;
    end 
end

endmodule