module Multiplier(
    input  logic [31:0] rs1,
    input  logic [31:0] rs2,
    input  logic [2:0]  funct3,

    output logic [31:0] result
);

// Extend operands to 64 bits based on operation
logic signed [63:0] multiplicand;
logic signed [63:0] multiplier;
logic signed [63:0] product;

localparam MUL    = 3'b000;
localparam MULH   = 3'b001;
localparam MULHSU = 3'b010;
localparam MULHU  = 3'b011;

always_comb begin
    case (funct3) 
        MUL: begin      // dosen't matter if (un)signed
            multiplicand = {32'b0, rs1};
            multiplier = {32'b0, rs2};
        end
        MULH: begin     // signed * signed
            multiplicand = {{32{rs1[31]}}, rs1};
            multiplier = {{32{rs2[31]}}, rs2};
        end
        MULHSU: begin   // signed * unsigned
            multiplicand = {{32{rs1[31]}}, rs1};
            multiplier = {32'b0, rs2};
        end
        MULHU: begin    // unsigned * unsigned
            multiplicand = {32'b0, rs1};
            multiplier = {32'b0, rs2};
        end
        default: begin
            multiplicand = {32'b0, rs1};
            multiplier = {32'b0, rs2};
        end
    endcase

    product = multiplicand * multiplier;

    if (funct3 == MUL) begin
        result = product[31:0];
    end
    else begin
        result = product[63:32];
    end
end

endmodule