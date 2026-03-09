// CSR module with Write Support
// Supports CSRRW, CSRRS, CSRRC

module CSR(
    input logic clk,
    input logic rst,

    // Instruction commit signal (from WB stage)
    input logic instret_inc,    // High when instruction commits

    // CSR read interface
    input  logic [11:0] csr_addr,   // CSR address (from immediate)
    output logic [31:0] csr_rdata,  // CSR read data

    // CSR write interface
    input logic        csr_we,      // CSR write enable
    input logic [2:0]  csr_op,      // CSR operation (funct3)
    input logic [31:0] csr_wdata,   // CSR write data (rs1 value)

    // Debug outputs
    output logic [63:0] cycle_count,
    output logic [63:0] instret_count   
);

logic [63:0] cycle_counter;
logic [63:0] instret_counter;

//=============================================================================
// CYCLE Counter: Increments every clock cycle
//=============================================================================
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        cycle_counter <= 64'b0;
    end
    else begin
        cycle_counter <= cycle_counter + 64'b1;
    end
end

//=============================================================================
// INSTRET Counter: Increments when instruction commits
// An instruction "commits" when it reaches WB stage and writes to register file
//=============================================================================
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        instret_counter <= 64'b0;
    end
    else if (instret_inc) begin
        instret_counter <= instret_counter + 64'b1;
    end
end

//=============================================================================
// CSR Read Logic
//=============================================================================
always_comb begin
    case (csr_addr)
        12'hC00: csr_rdata = cycle_counter[31:0];     // CYCLE
        12'hC80: csr_rdata = cycle_counter[63:32];    // CYCLEH
        12'hC02: csr_rdata = instret_counter[31:0];   // INSTRET
        12'hC82: csr_rdata = instret_counter[63:32];  // INSTRETH
        default: csr_rdata = 32'b0;
    endcase
end 


//=============================================================================
// CSR Write Logic
//=============================================================================
// CSR operations:
// 001 (CSRRW): CSR = rs1
// 010 (CSRRS): CSR = CSR | rs1 (only if rs1 != 0)
// 011 (CSRRC): CSR = CSR & ~rs1 (only if rs1 != 0)

localparam CSRRW = 3'b001;
localparam CSRRS = 3'b010;
localparam CSRRC = 3'b011;

// Calculate new CSR value
logic [31:0] csr_new_value;

always_comb begin
    case (csr_op)
        CSRRW: csr_new_value = csr_wdata;                   // Write
        CSRRS: csr_new_value = csr_rdata | csr_wdata;       // Set bits
        CSRRC: csr_new_value = csr_rdata & ~csr_wdata;      // Clear bits
        default: csr_new_value = csr_rdata;
    endcase
end

assign cycle_count = cycle_counter;
assign instret_count = instret_counter;

endmodule