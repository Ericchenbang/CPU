module comparator(
    input [31:0] rs1,
    input [31:0] rs2,

    output logic eq,
    output logic lt,
    output logic ltu
);

assign eq = (rs1 == rs2);
assign lt = ($signed(rs1) < $signed(rs2));
assign ltu = (rs1 < rs2);

endmodule