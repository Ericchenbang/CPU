// ID Stage Forwarding Logic
// Problem: Branch comparator in ID stage needs correct register values,
//          but those values might not be written to register file yet.
//
// When to forward:
// - Branch instructions: Need values for comparison in ID stage
// - JALR: Needs rs1 value to calculate jump target in ID stage
//
// When to stall:
// - Value is in EX stage
// - Load instruction in EX/MEM stage


module ID_Forwarding_Unit(
    input [4:0] ID_rs1,
    input [4:0] ID_rs2,
    input       ID_Branch,      // branch and JALR need to get data in ID
    input       ID_Jalr,

    input [4:0] EX_rd,
    input       EX_RegWrite,
    input       EX_MemRead,

    input [4:0] MEM_rd,
    input       MEM_RegWrite,
    input       MEM_MemRead,

    input [4:0] WB_rd,
    input       WB_RegWrite,

    // 00: regfile, 01: MEM, 10: WB
    output logic [1:0] ID_ForwardA,
    output logic [1:0] ID_ForwardB,

    output logic ID_Branch_Stall
);

// Only perform forwarding checks if ID stage has branch or JALR
logic need_forwarding;
assign need_forwarding = ID_Branch || ID_Jalr;

//================================//
// 1. ID stage Forwarding Logic   //
//================================//

always_comb begin
    ID_ForwardA = 2'b00;

    if (need_forwarding) begin

        if (MEM_RegWrite && (MEM_rd != 5'b0) && (MEM_rd == ID_rs1)) begin
            ID_ForwardA = 2'b01;
        end
        else if (WB_RegWrite && (WB_rd != 5'b0) && (WB_rd == ID_rs1)) begin
            ID_ForwardA = 2'b10;
        end
    end
end

always_comb begin
    ID_ForwardB = 2'b00;

    if (need_forwarding) begin

        if (MEM_RegWrite && (MEM_rd != 5'b0) && (MEM_rd == ID_rs2)) begin
            ID_ForwardB = 2'b01;
        end
        else if (WB_RegWrite && (WB_rd != 5'b0) && (WB_rd == ID_rs2)) begin
            ID_ForwardB = 2'b10;
        end
    end
end


//=============================//
// 2. Branch/Jalr Stall Logic  //
//=============================//
// Stall if:
// 1. ID stage has branch or JALR (needs register values)
// 2. AND needed value is in EX or MEM stage
//
// Case 1: Value being computed in EX
// -> stall 1 cycle
// Case 2: Load in EX 
// -> stall 2 cycle
// Case 3: Load in MEM 
// -> stall 1 cycle


always_comb begin
    ID_Branch_Stall = 1'b0;

    if (need_forwarding) begin

        // Case 1: EX stage has the value we need
        // - For regular instructions: value ready at END ofEX
        // - For loads: value not ready until END of MEM
        if (EX_RegWrite && (EX_rd != 5'b0)) begin
            if ((EX_rd == ID_rs1) || (EX_rd == ID_rs2)) begin
                ID_Branch_Stall = 1'b1;
            end
        end
        
        // Case 2: MEM stage has a LOAD with the value we need
        if (MEM_MemRead && MEM_RegWrite && (MEM_rd != 5'b0)) begin
            if ((MEM_rd == ID_rs1) || (MEM_rd == ID_rs2)) begin
                ID_Branch_Stall = 1'b1;
            end
        end
    end
end

endmodule