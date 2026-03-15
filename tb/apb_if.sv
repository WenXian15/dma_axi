interface apb_if (input logic clk, input logic rstn);

    logic                                pclken;
    logic                                psel;
    logic                                penable;
    logic [12:0]                         paddr;
    logic                                pwrite;
    logic [31:0]                         pwdata;
    logic [31:0]                        prdata;
    logic                               pslverr;
    logic                               pready;

    clocking master_cb @(posedge clk);
        output pclken;
        output psel;
        output penable;
        output paddr;
        output pwrite;
        output pwdata;
        input  prdata;
        input  pslverr;
        input  pready;
    endclocking


    modport DRV_MP(
        output pclken,
        output psel,
        output penable,
        output paddr,
        output pwrite,
        output pwdata
    );

    modport MON_MP(
        input psel,
        input penable,
        input paddr,
        input pwrite,
        input pwdata
    );

endinterface

/*
property pwrite_handshake;
    @(posedge u0_apb_if.clk) $rose(u0_apb_if.pwrite) |-> ##[1:$] $rose(u0_apb_if.pready);
endproperty 

assert property (pwrite_handshake);
*/

//task automatic write_w ( 
//input [ADDR_W-1:0] addr, 
//input [] data, 
//input strb='hff);
//@(posedge pclk);
//paddr <= addr;
//pwdata <= data;
//pstrb <= strb;
//pwrite <= 1'b1;
//psel <= 1'b1;
//penable <= 1'b0;
//@(posedge pclk);
//penable <= 1'b1;
//wait (pready == 1'b1);
//@(posedge pclk);
//psel <= 1'b0;
//penable <= 1'b0;
//pwrite <= 1'b0;
//paddr <= '0;
//pwdata <= '0;
//pstrb <= 4'b0000;

//task automatic read_w (
//input [ADDR_W-1:0] addr, 
//output [DATA_W-1:0] data
//);
//@(posedge pclk);
//paddr <= addr;
//pwrite <= 1'b0;
//psel <= 1'b1;
//penable <= 1'b0;
//@(posedge pclk);
//penable <= 1'b1;
//wait (pready == 1'b1);
//@(posedge pclk);
//data <= prdata;
//psel <= 1'b0;
//penable <= 1'b0;
//paddr <= '0;
//endtask

//task automatic write_b (
//input logic [ADDR_W-1:0] addr, 
//input logic [DATA_W-1:0] data_byte
//);
//logic [DATA_W-1:0] aligned_data;
//logic [3:0] strobe;
//logic [1:0] byte_offset;
//byte_offset = addr[1:0];
//aligned_data = data_byte << (byte_offset * 8);
//strobe = 4'b0001 << byte_offset;
//apb write sequence
//@(posedge pclk);
//paddr <= addr & 32'hFFFF_FFFC; // word-aligned address
//pwrite <= 1'b1;
//psel <= 1'b1;
//penable <= 1'b0;
//pwdata <= aligned_data;
//pstrb <= strobe;
//@(posedge pclk);
//penable <= 1'b1;
//wait for ready
//do @(posedge pclk); while (pready == 1'b0);
//deassert signals
//psel <= 1'b0;
//penable <= 1'b0;
//pwrite <= 1'b0;
//pstrb <= 4'b0000;
//pwdata <= '0;
//endtask

//task automatic read_b (
//input logic [ADDR_W-1:0] addr,
//output logic [7:0] data_byte
//);
//logic [1:0] byte_offset;
//logic [DATA_W-1:0] read_data;
//byte_offset = addr[1:0];
//@(posedge pclk);
//paddr <= addr & 32'hFFFF_FFFC; // word-aligned address
//pwrite <= 1'b0;
//psel <= 1'b1;
//penable <= 1'b0;
//@(posedge pclk);
//penable <= 1'b1;
//wait for ready
//do @(posedge pclk); while (pready == 1'b0);
//read_data = prdata;
//data_byte = read_data >> (byte_offset * 8);
//deassert signals
//psel <= 1'b0;
//penable <= 1'b0;
//endtask
