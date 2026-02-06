module load_data(
    input [31:0] dm_rdata,
    input [2:0] funct3,
    input [31:0] alu_result,

    output logic [31:0] load_data_final
);

localparam LW = 3'b010;
localparam LB = 3'b000;
localparam LH = 3'b001;
localparam LBU = 3'b100;
localparam LHU = 3'b101;

always_comb begin
    load_data_final = dm_rdata;

    case (funct3)
        LW: load_data_final = dm_rdata;
        LB: begin
            case (alu_result[1:0]) 
                2'b00: load_data_final = {{24{dm_rdata[7]}}, dm_rdata[7:0]};
                2'b01: load_data_final = {{24{dm_rdata[15]}}, dm_rdata[15:8]};
                2'b10: load_data_final = {{24{dm_rdata[23]}}, dm_rdata[23:16]};
                2'b11: load_data_final = {{24{dm_rdata[31]}}, dm_rdata[31:24]};
            endcase
        end
        LH: begin
            case (alu_result[1])
                1'b0: load_data_final = {{16{dm_rdata[15]}}, dm_rdata[15:0]};
                1'b1: load_data_final = {{16{dm_rdata[31]}}, dm_rdata[31:16]};
            endcase
        end
        LBU: begin
            case (alu_result[1:0])
                2'b00: load_data_final = {24'b0, dm_rdata[7:0]};
                2'b01: load_data_final = {24'b0, dm_rdata[15:8]};
                2'b10: load_data_final = {24'b0, dm_rdata[23:16]};
                2'b11: load_data_final = {24'b0, dm_rdata[31:24]};
            endcase
        end 
        LHU: begin
            case(alu_result[1])
                1'b0: load_data_final = {16'b0, dm_rdata[15:0]};
                1'b1: load_data_final = {16'b0, dm_rdata[31:16]};
            endcase
        end
    endcase
end

endmodule