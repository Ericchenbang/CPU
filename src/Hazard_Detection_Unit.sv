// Detects hazards that forwarding cannot solve:
// 1. Load-Use Hazard: Next instruction needs load result immediately
// 2. Control Hazard: Branch/Jump changes PC, must flush pipeline
//
// Solutions:
// 1. Load-Use: Stall the pipeline for one cycle
// 2. Control: Flush incorrect instructions from pipeline

module Hazard_Detection_Unit(
    // Load-use hazard detection
    input [4:0] ID_rs1,
    input [4:0] ID_rs2,
    input [4:0] EX_rd,
    input       EX_MemRead,

    // Control Hazard Detection - Now from EX stage
    input       EX_Branch,
    input       EX_take_branch,
    input       EX_Jal,
    input       EX_Jalr,

    // Misprediction detection
    input       EX_predicted_taken,
    input [1:0] EX_PCSel,

    // Hazard control signals
    output logic Stall,
    output logic IF_ID_flush,
    output logic ID_EX_flush
);

//----------------------//
// Load-use hazard      //
//----------------------//
logic load_use_hazard;

always_comb begin
    load_use_hazard = 1'b0;

    if (EX_MemRead) begin
        if ((EX_rd == ID_rs1) || (EX_rd == ID_rs2)) begin
            if (EX_rd != 5'b0) begin
                load_use_hazard = 1'b1;
            end
        end
    end
end

//----------------------//
// Control Hazard       //
//----------------------//
// A control hazard occurs when 
// 1. Branch is taken (EX_Branch && EX_take_branch)
// 2. JAL instruction (EX_Jal)
// 3. JALR instruction (EX_Jalr)

logic control_hazard;
logic branch_hazard;    // Seperate signal for branches
logic jump_hazard;      // Seperate signal for JAL/JALR 

always_comb begin
    branch_hazard = 1'b0;
    jump_hazard = 1'b0;

    if (EX_Branch && EX_take_branch) begin
        branch_hazard = 1'b1;
    end

    if (EX_Jal || EX_Jalr) begin
        jump_hazard = 1'b1;
    end

    control_hazard = branch_hazard || jump_hazard;
end

//-------------------------//
// Misprediction Detection //
//-------------------------//
logic misprediction;

always_comb begin
    misprediction = 1'b0;

    // Case 1: Predicted taken, but branch not taken
    if (EX_predicted_taken && EX_Branch && !EX_take_branch) begin
        misprediction = 1'b1;
    end

    // Case 2: Predicted not taken, but branch taken
    if (!EX_predicted_taken && EX_Branch && EX_take_branch) begin
        misprediction = 1'b1;
    end

    // Case 3: Didn't predict jump, but JAL/JALR occurred
    if (!EX_predicted_taken && (EX_Jal || EX_Jalr)) begin
        misprediction = 1'b1;
    end

    // Case 4: Predicted jump, but no jump
    if (EX_predicted_taken && !EX_Branch && !EX_Jal && !EX_Jalr && (EX_PCSel != 2'b00)) begin
        misprediction = 1'b1;
    end
end


//----------------------//
// Output Logic         //
//----------------------//

// Stall: Only for load-use hazards
assign Stall = load_use_hazard;


// IF/ID Flush: Clear the instruction in IF/ID register
// Used for all control hazards (branch, JAL, JALR)
// This flushes the incorrectly fetched instruction
always_comb begin
    IF_ID_flush = 1'b0;

    if (control_hazard || misprediction) begin
        IF_ID_flush = 1'b1;
    end
end

// ID/EX Flush: Clear the instruction in ID/EX register
// Only flush for branches and load-use, Not for JAL/JALR
// Since JAL/JALR need to write pc4 back to rd
always_comb begin
    ID_EX_flush = 1'b0;

    if (load_use_hazard) begin
        ID_EX_flush = 1'b1;
    end

    // only branch, not JAL/JALR
    if (branch_hazard) begin
        ID_EX_flush = 1'b1;
    end

    if (misprediction) begin
        ID_EX_flush = 1'b1;
    end
end

endmodule