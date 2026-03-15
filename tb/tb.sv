import uvm_pkg::*;
`include "uvm_macros.svh"

`include "tb/registers.svh"
`include "tb/defines.svh"
`include "tb/axi_mem_item.sv"
`include "tb/axi_if.sv"
`include "tb/apb_if.sv"
//`include "bfm/axi_slave_mem_bfm.sv"
//`include "tb/dma_reg.sv"
`include "tb/apb_sequence_item.sv"
`include "tb/apb_base_sequence.sv"
`include "tb/apb_poll_seq.sv"
`include "tb/apb_sequencer.sv"
`include "tb/apb_monitor.sv"
`include "tb/apb_driver.sv"
`include "tb/apb_agent.sv"
`include "tb/axi_sequence_item.sv"
//`include "tb/axi_sequence.sv"
//`include "tb/axi_sequencer.sv"
`include "tb/axi_s_sequencer.sv"
`include "tb/axi_s_driver.sv"
`include "tb/axi_slave.sv"
`include "tb/scoreboard.sv"
`include "tb/dma_program_seq.sv"
`include "tb/dma_memrd_seq.sv"
`include "tb/vseqr_base.sv"
`include "tb/vseq_base.sv"
`include "tb/my_environment.sv"
`include "tests/test_base.sv"
`include "tests/dma_test.sv"

module tb;
    bit clk;
    bit rst;
    bit rstn;

    always #5 clk = ~clk;

    // APB interface
    apb_if u0_apb_if (.clk(clk), .rstn(rstn));

    // DMA interface
    axi_if #(.A_WIDTH(32), .D_WIDTH(64)) u0_axi_if (.clk(clk), .rstn(rst));

    dma_axi64 u0_dma_axi (
        .clk        (clk),
        .reset      (rst),
        .scan_en    (1'b0),

        .idle       (),
        .INT        (),
        .periph_tx_req (),  // Input
        .periph_tx_clr (),  // Output
        .periph_rx_req (),  // Input 
        .periph_rx_clr (),  // Output

        .pclken     (1'b1), // Input
        .psel       (u0_apb_if.psel), // Input
        .penable    (u0_apb_if.penable), // Input
        .paddr      (u0_apb_if.paddr), // Input
        .pwrite     (u0_apb_if.pwrite), // Input
        .pwdata     (u0_apb_if.pwdata), // Input
        .prdata     (u0_apb_if.prdata),  // Output
        .pslverr    (u0_apb_if.pslverr), // Output
        .pready     (u0_apb_if.pready), // Output

        // --------------------
        // WRITE ADDRESS
        // --------------------
        .AWID0      (u0_axi_if.AWID),
        .AWADDR0    (u0_axi_if.AWADDR),
        .AWLEN0     (u0_axi_if.AWLEN),
        .AWSIZE0    (u0_axi_if.AWSIZE),
        .AWVALID0   (u0_axi_if.AWVALID),
        .AWREADY0   (u0_axi_if.AWREADY),

        // --------------------
        // WRITE DATA
        // --------------------
        .WID0       (u0_axi_if.WID),     // optional: reuse AWID if DUT has WID
        .WDATA0     (u0_axi_if.WDATA),
        .WSTRB0     (u0_axi_if.WSTRB),
        .WLAST0     (u0_axi_if.WLAST),
        .WVALID0    (u0_axi_if.WVALID),
        .WREADY0    (u0_axi_if.WREADY),

        // --------------------
        // WRITE RESPONSE
        // --------------------
        .BID0       (u0_axi_if.BID),
        .BRESP0     (u0_axi_if.BRESP),
        .BVALID0    (u0_axi_if.BVALID),
        .BREADY0    (u0_axi_if.BREADY),

        // --------------------
        // READ ADDRESS
        // --------------------
        .ARID0      (u0_axi_if.ARID),
        .ARADDR0    (u0_axi_if.ARADDR),
        .ARLEN0     (u0_axi_if.ARLEN),
        .ARSIZE0    (u0_axi_if.ARSIZE),
        .ARVALID0   (u0_axi_if.ARVALID),
        .ARREADY0   (u0_axi_if.ARREADY),

        // --------------------
        // READ DATA
        // --------------------
        .RID0       (u0_axi_if.RID),
        .RDATA0     (u0_axi_if.RDATA),
        .RRESP0     (u0_axi_if.RRESP),
        .RLAST0     (u0_axi_if.RLAST),
        .RVALID0    (u0_axi_if.RVALID),
        .RREADY0    (u0_axi_if.RREADY)
    );

    /*
    axi_slave_mem_bfm #(
        .ADDR_W(32),
        .DATA_W(64),
        .ID_W(4),
        .MEM_BYTES(1<<20),
        .EN_WAIT(0)
    ) u0_axi_slave_bfm (
        .axi(u0_axi_if)
    );
    */

    initial begin
        rst = 1;
        rstn = 0;
        #5 
        rst = 0;
        rstn = 1;
    end


    // uvm_config_db#(virtual apb_if)::get(cntxt, inst_name, field_name, value)
    // The final lookup path is formed by concatenating cntxt.get_full_name() + "." + inst_name

    // inst_name (the scope path):"uvm_test_top.*"
    // This is matched against the path that was used in the corresponding set call.  The * is a glob wildcard that matches
    // exactly one component name at that level - it is not a recursive wildcard.
    
    /*
    Path in set	Matches "uvm_test_top.*"?
    "uvm_test_top.env"	Yes
    "uvm_test_top.my_seq"	Yes
    "uvm_test_top.env.apb_agent_inst.apb_drv"	No — too deep
    "uvm_test_top"	No — missing the .* level
    */

    initial begin
        //uvm_config_db#(virtual apb_if)::set(this, "uvm_test_top.apb_agt", "apb_vif", u0_apb_if);
        // This not allowed to use outside of class scope
        uvm_config_db#(virtual apb_if)::set(null, "uvm_test_top.env.apb_agent_inst.apb_drv",  "apb_vif", u0_apb_if);
        uvm_config_db#(virtual axi_if#(.A_WIDTH(32), .D_WIDTH(64)))::set(null, "uvm_test_top.env.axi_slave_agent_inst.s_drv", "axi_vif", u0_axi_if);
        uvm_config_db#(virtual apb_if)::set(null, "uvm_test_top.env.apb_agent_inst.apb_seqr", "apb_vif", u0_apb_if);
        // Broad set so vseq_base (running on vseqr_base) can also fetch apb_vif for clock waits
        uvm_config_db#(virtual apb_if)::set(null, "uvm_test_top.env.vseqr_base_inst",         "apb_vif", u0_apb_if);

        run_test("dma_test");
    end

    initial begin
        forever begin
            @(posedge u0_apb_if.pwrite);
            `uvm_info("TB", $sformatf("APB Address Accessed: ADDR=0x%h, WRITE=%0b, WDATA=0x%h", u0_apb_if.paddr, u0_apb_if.pwrite, u0_apb_if.pwdata), UVM_LOW);    
        end
    end

endmodule : tb