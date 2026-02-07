module store_data(
    input [2:0] funct3,
    input MemWrite,
    input [31:0] rs2_data,
    input [31:0] alu_result,

    output logic [3:0] dm_web,
    output logic [31:0] dm_wdata
);

localparam SW = 3'b010;
localparam SB = 3'b000;
localparam SH = 3'b001;

always_comb begin
    dm_wdata = 32'b0;
    dm_web = 4'b1111;

    if (MemWrite) begin
        case(funct3)
            SB: begin
                dm_wdata = {4{rs2_data[7:0]}};
                case (alu_result[1:0]) 
                    2'b00: dm_web = 4'b1110;
                    2'b01: dm_web = 4'b1101;
                    2'b10: dm_web = 4'b1011;
                    2'b11: dm_web = 4'b0111;
                endcase
            end
            SH: begin
                dm_wdata = {2{rs2_data[15:0]}};
                case (alu_result[1:0]) 
                    2'b00: dm_web = 4'b1100;
                    2'b10: dm_web = 4'b0011;
                    default: dm_web = 4'b1111;
                endcase
            end
            SW: begin
                dm_wdata = rs2_data;
                dm_web = 4'b0;
            end
            default: begin
                dm_wdata = rs2_data;
                dm_web = 4'b1111;
            end
        endcase
    end
end

endmodule