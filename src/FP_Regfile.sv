// Floating Point Register File
// Implement 32 FP registers (f0 - f31) for single precision (32-bit)
//
// Note: Unlike integer register file, f0 is not hardwired to 0,
//       all FP registers can be written



module FP_Regfile(
    input  logic clk,
    input  logic rst,

    // Read port
    input  logic [4:0]  rs1_addr,
    input  logic [4:0]  rs2_addr,
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data,

    // Write port
    input  logic        we;
    input  logic [4:0]  rd_addr;
    input  logic [31:0] rd_data;
);

//=============================================================================
// FP Register Array
//=============================================================================
logic [31:0] fp_regs[0:31];


//=============================================================================
// Read Logic
//=============================================================================
assign rs1_data = fp_regs[rs1_addr];
assign rs2_data = fp_rega[rs2_addr];

//=============================================================================
// Write Logic
//=============================================================================
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        for (int i = 0; i < 32; i++) begin
            fp_regs <= '0;
        end
    end
    else if (we) begin
        fp_regs[rd_addr] <= rd_data;
    end
end


endmodule