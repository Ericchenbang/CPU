module Branch_Target_Buffer #(
    parameter INDEX_BITS = 8    // 256 entries
)(
    input logic clk,
    input logic rst,

    // Lookup interface (in IF stage)
    input  logic [31:0] IF_PC,
    output logic [31:0] predicted_target,
    output logic        hit,       // Is this PC in the BTB ?

    // Update interface (in EX stage)
    input logic        update_enable,
    input logic [31:0] update_PC,
    input logic [31:0] actual_target
);

// BTB entries
typedef struct packed {
    logic                           valid;
    logic [31:0 - INDEX_BITS - 2:0] tag;
    logic [31:0]                    target;
} btb_entry_t;

btb_entry_t BTB [0: (2**INDEX_BITS) - 1];

logic [INDEX_BITS - 1:0]        lookup_index;
logic [INDEX_BITS - 1:0]        update_index;
logic [31:0 - INDEX_BITS - 2:0] lookup_tag;
logic [31:0 - INDEX_BITS - 2:0] update_tag;

assign lookup_index = IF_PC[INDEX_BITS + 1:2];
assign update_index = update_PC[INDEX_BITS + 1:2];
assign lookup_tag   = IF_PC[31:INDEX_BITS + 2];
assign update_tag   = update_PC[31:INDEX_BITS + 2];

// Lookup
assign hit = BTB[lookup_index].valid && (BTB[lookup_index].tag == lookup_tag);
assign predicted_target = BTB[lookup_index].target;

// Update
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        for (int i = 0; i < (2**INDEX_BITS); i++) begin
            BTB[i].valid <= 1'b0;
            BTB[i].tag <= '0;
            BTB[i].target <= '0;
        end
    end
    else if (update_enable) begin
        BTB[update_index].valid <= 1'b1;
        BTB[update_index].tag <= update_tag;
        BTB[update_index].target <= actual_target;
    end
end

endmodule