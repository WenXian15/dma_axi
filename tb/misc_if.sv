interface dma_if (input logic clk, input logic rstn);

   logic                 scan_en;

   logic                 idle;
   logic [1-1:0]                INT;
   
   logic [31:1]             periph_tx_req;
   logic [31:1]             periph_tx_clr;
   logic [31:1]             periph_rx_req;
   logic [31:1]             periph_rx_clr;
   
    logic [`ID_BITS-1:0]               AWID0;
    logic [32-1:0]             AWADDR0;
    logic [`LEN_BITS-1:0]              AWLEN0;
    logic [`SIZE_BITS-1:0]      AWSIZE0;
    logic                              AWVALID0;
    logic                               AWREADY0;
    logic [`ID_BITS-1:0]               WID0;
    logic [64-1:0]             WDATA0;
    logic [64/8-1:0]           WSTRB0;
    logic                              WLAST0;
    logic                              WVALID0;
    logic                               WREADY0;
    logic [`ID_BITS-1:0]                BID0;
    logic [1:0]                         BRESP0;
    logic                               BVALID0;
    logic                              BREADY0;
    logic [`ID_BITS-1:0]               ARID0;
    logic [32-1:0]             ARADDR0;
    logic [`LEN_BITS-1:0]              ARLEN0;
    logic [`SIZE_BITS-1:0]      ARSIZE0;
    logic                              ARVALID0;
    logic                               ARREADY0;
    logic [`ID_BITS-1:0]                RID0;
    logic [64-1:0]              RDATA0;
    logic [1:0]                         RRESP0;
    logic                               RLAST0;
    logic                               RVALID0;
    logic                              RREADY0;

    clocking tb_cb @(posedge clk);
        default input #1step output #1ns;
        
    endclocking

    modport DRV_MP (
        input clk, rstn,
        clocking tb_cb,
        output scan_en,
        output periph_tx_req,
        output periph_rx_req,
        output AWREADY0,
        output WREADY0,
        output BID0,
        output BRESP0,
        output BVALID0,
        output ARREADY0,
        output RID0,
        output RDATA0,
        output RRESP0,
        output RLAST0,
        output RVALID0
    );

    /*
    modport MON_MP (
        input clk, rstn,
        clocking tb_cb,
        input scan_en,
        output idle,
        output INT,
        input periph_tx_req,
        output periph_tx_clr,
        input periph_rx_req,
        output periph_rx_clr,
        input pclken,

   
        output AWID0,
        output AWADDR0,
        output AWLEN0,
        output AWSIZE0,
        output AWVALID0,
        input AWREADY0,
        output WID0,
        output WDATA0,
        output WSTRB0,
        output WLAST0,
        output WVALID0,
        input WREADY0,
        input BID0,
        input BRESP0,
        input BVALID0,
        output BREADY0,
        output ARID0,
        output ARADDR0,
        output ARLEN0,
        output ARSIZE0,
        output ARVALID0,
        input ARREADY0,
        input RID0,
        input RDATA0,
        input RRESP0,
        input RLAST0,
        input RVALID0,
        output RREADY0
    );
    */

endinterface