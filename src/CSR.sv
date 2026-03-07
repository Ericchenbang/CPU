// CSR module
// Implement CYCLE, CYCLEH, INSTRET, INSTRETH

module CSR(
    input logic clk,
    input logic rst,

    // Instruction commit signal (from WB stage)
    input logic instret_inc,    // High when instruction commits

    // CSR read interface
    input  logic [11:0] csr_addr,   // CSR address (from immediate)
    output logic [31:0] csr_rdata,  // CSR read data

    // Debug outputs
    output logic [63:0] cycle_count,
    output logic [63:0] instret_count   
);

logic [63:0] cycle_counter;
logic [63:0] instret_counter;

// CYCLE Counter: Increments every clock cycle
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        cycle_counter <= 64'b0;
    end
    else begin
        cycle_counter <= cycle_counter + 64'b1;
    end
end

// INSTRET Counter: Increments when instruction commits (retires)
// An instruction "commits" when it reaches WB stage and writes to register file
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        instret_counter <= 64'b0;
    end
    else if (instret_inc) begin
        instret_counter <= instret_counter + 64'b1;
    end
end


always_comb begin
    case (csr_addr)
        12'hC00: csr_rdata = cycle_counter[31:0];     // CYCLE
        12'hC80: csr_rdata = cycle_counter[63:32];    // CYCLEH
        12'hC02: csr_rdata = instret_counter[31:0];   // INSTRET
        12'hC82: csr_rdata = instret_counter[63:32];  // INSTRETH
        default: csr_rdata = 32'b0;
    endcase
end 

assign cycle_count = cycle_counter;
assign instret_count = instret_counter;

endmodule