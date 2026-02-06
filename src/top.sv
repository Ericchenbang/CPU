//////////////////////////////////////////////////////////////////////
//          ██╗       ██████╗   ██╗  ██╗    ██████╗            		//
//          ██║       ██╔══█║   ██║  ██║    ██╔══█║            		//
//          ██║       ██████║   ███████║    ██████║            		//
//          ██║       ██╔═══╝   ██╔══██║    ██╔═══╝            		//
//          ███████╗  ██║  	    ██║  ██║    ██║  	           		//
//          ╚══════╝  ╚═╝  	    ╚═╝  ╚═╝    ╚═╝  	           		//
//                                                             		//
// 	2025 Advanced VLSI System Design, Advisor: Lih-Yih, Chiou		//
//                                                             		//
//////////////////////////////////////////////////////////////////////
//                                                             		//
// 	Author: 		                           				  	    //
//	Filename:		top.sv		                                    //
//	Description:	top module for AVSD HW1                     	//
// 	Date:			2025/XX/XX								   		//
// 	Version:		1.0	    								   		//
//////////////////////////////////////////////////////////////////////
`include "SRAM_wrapper.sv"

module top(
input clk,
input rst
);

logic [31:0] im_addr;
logic [31:0] im_rdata;

logic [31:0] dm_addr;
logic [31:0] dm_wdata;
logic [3:0] dm_web;
logic [31:0] dm_rdata;

// --------------------------//
//   Instance Your CPU Here  //
// --------------------------//
CPU u_cpu(
    .clk(clk),
    .rst(rst),
    .im_addr(im_addr),
    .im_rdata(im_rdata),
    .dm_addr(dm_addr),
    .dm_wdata(dm_wdata),
    .dm_web(dm_web),
    .dm_rdata(dm_rdata)
);

SRAM_wrapper IM1(
    .CLK(clk),
    .RST(rst),
    .CEB(1'b0),
    .WEB(1'b1),
    .BWEB(32'b0),
    .A(im_addr[15:2]),      // byte addressable -> word addressable
    .DI(32'b0),
    .DO(im_rdata)
);

SRAM_wrapper DM1(
    .CLK(clk),
    .RST(rst),
    .CEB(1'b0),
    .WEB(1'b0),     // when BWEB = '1, it means Read
    .BWEB({{8{dm_web[3]}}, {8{dm_web[2]}}, {8{dm_web[1]}}, {8{dm_web[0]}}}),
    .A(dm_addr[15:2]),
    .DI(dm_wdata),
    .DO(dm_rdata)
);

endmodule