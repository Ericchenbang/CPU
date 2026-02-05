module CPU(
    input clk,
    input rst,

    // instruction memory
    output logic [31:0] im_addr;
    input logic [31:0] im_rdata;    // read data

    // data memory
    output logic [31:0] dm_addr;
    output logic [31:0] dm_wdata;   // write data
    output logic dm_we,             // write enable
    input logic [31:0] dm_rdata;    // read data
);

// PC
logic [31:0] PC;
assign im_addr = PC;

always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        PC <= 0;
    end
    else begin
        PC <= PC + 4;   // ?
    end
end


endmodule