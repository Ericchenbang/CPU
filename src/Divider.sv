// Simple Divider - Uses SystemVerilog / and % operators

module Divider(
    input  logic [31:0] rs1,
    input  logic [31:0] rs2,
    input  logic [2:0]  funct3,

    output logic [31:0] result
);

localparam DIV  = 3'b100;
localparam DIVU = 3'b101;
localparam REM  = 3'b110;
localparam REMU = 3'b111;

always_comb begin
    // Handle division by zero (RISC-V specification)
    if (rs2 == 32'b0) begin
        case (funct3)
            DIV, DIVU: begin
                result = 32'hFFFF_FFFF;
            end
            REM, REMU: begin
                result = rs1;
            end
            default: begin
                result = 32'b0;
            end
        endcase
    end

    // Handle overflow case: -2^31 / -1 (RISV-V specification)
    // This is the only signed division that overflows in 32-bit
    else if (funct3 == DIV && rs1 == 32'h8000_0000 && rs2 == 32'hFFFF_FFFF) begin
        result = 32'h8000_0000;
    end

    // Normal division operations
    else begin
        case (funct3) 
            DIV: begin
                result = $signed(rs1) / $signed(rs2);
            end
            DIVU: begin
                result = $unsigned(rs1) / $unsigned(rs2);
            end
            REM: begin
                result = $signed(rs1) % $signed(rs2);
            end
            REMU: begin
                result = $unsigned(rs1) % $unsigned(rs2);
            end
            default: begin
                result = 32'b0; 
            end
        endcase
    end
end

endmodule