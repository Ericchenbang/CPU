module Branch_Predictor_Bimodal #(
    parameter INDEX_BITS = 8 // 256 entries
)(
    input logic clk,
    input logic rst,

    // Prediction interface (in IF stage)
    input logic [31:0] IF_PC,
    output logic predict_taken,

    // Updata interface (in EX stage, after solution)
    input logic update_enable,      // EX_Branch || EX_Jal || EX_Jalr
    input logic [31:0] update_PC,   // EX_PC
    input logic actual_taken        // EX_take_branch || EX_Jal || EX_Jalr
);

// Pattern History Table - 2 bit saturating counters
logic [1:0] PHT [0 : (2**INDEX_BITS) - 1];

// Extract index from PC (use low-order bits)
logic [INDEX_BITS - 1 : 0] predict_index;
logic [INDEX_BITS - 1 : 0] update_index;

// PC[1:0] is always 0 (aligned), so use PC[INDEX_BITS+1 : 2]
assign predict_index = IF_PC[INDEX_BITS + 1 : 2];
assign update_index = update_PC[INDEX_BITS + 1 : 2];

// Prediction: Taken if counter >= 2 (10 or 11)
assign predict_taken = PHT[predict_index][1];

// Update: Increment if taken, decrement if not taken
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        // Initialize to weakly not taken (01)
        for (int i = 0; i < (2**INDEX_BITS); i++) begin
            PHT[i] <= 2'b01;
        end
    end
    else if (update_enable) begin
        case (PHT[update_index])
            2'b00: PHT[update_index] <= actual_taken ? 2'b01 : 2'b00;
            2'b01: PHT[update_index] <= actual_taken ? 2'b10 : 2'b00;
            2'b10: PHT[update_index] <= actual_taken ? 2'b11 : 2'b01;
            2'b11: PHT[update_index] <= actual_taken ? 2'b11 : 2'b10;
        endcase
    end
end

endmodule