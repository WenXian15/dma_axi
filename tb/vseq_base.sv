// Small inline APB write sequence — writes one register
class apb_write_seq extends apb_base_sequence;
    `uvm_object_utils(apb_write_seq)
    logic [12:0] wr_addr;
    logic [31:0] wr_data;
    function new(string name = "apb_write_seq");
        super.new(name);
    endfunction
    task body();
        apb_write(wr_addr, wr_data);
    endtask
endclass : apb_write_seq

// Virtual sequence
class vseq_base extends uvm_sequence #(uvm_sequence_item);
    `uvm_object_utils(vseq_base)
    `uvm_declare_p_sequencer(vseqr_base)

    // Parameters
    parameter int POLL_TIMEOUT = 10000; // max poll iterations before timeout
    parameter int A_WIDTH = 32;

    dma_program_seq program_seq;
    dma_memrd_seq   memrd_seq;
    apb_poll_seq    poll_seq;

    // APB virtual interface — fetched once in body() for clock-wait purposes only.
    // Sequences that drive the bus (dma_program_seq etc.) do NOT hold this handle.
    virtual apb_if apb_vif;

    function new(string name = "vseq_base");
        super.new(name);
    endfunction : new

    // apb_rd — thin wrapper around apb_poll_seq so vseq_base can issue APB
    // reads without inheriting from apb_base_sequence.
    task apb_rd(input logic [12:0] addr, output logic [31:0] rdata);
        apb_poll_seq rd_seq = apb_poll_seq::type_id::create("rd_seq");
        rd_seq.poll_addr = addr;
        rd_seq.start(p_sequencer.apb_seqr);
        rdata = rd_seq.rdata;
    endtask : apb_rd

    // Hook - child classes override this to control randomization
    virtual task do_randomize();
        assert(program_seq.randomize()); // default: fully rnadom
    endtask : do_randomize

    task body();
        int          poll_count;
        logic [31:0] rawstat;
        logic [31:0] readback;

        // Fetch apb_vif for clock waits — p_sequencer is vseqr_base
        if (!uvm_config_db#(virtual apb_if)::get(p_sequencer, "", "apb_vif", apb_vif))
            `uvm_fatal("VSEQ", "Cannot get apb_vif from uvm_config_db")

        // Step 1: Create sequences
        program_seq = dma_program_seq::type_id::create("program_seq");
        memrd_seq   = dma_memrd_seq::type_id::create("memrd_seq");
        poll_seq    = apb_poll_seq::type_id::create("poll_seq");

        // Step 2: Randomize transfer params with constraints to ensure valid transfer
        // Add constraints to make debugging easier: fixed values for first runs
        // Comment out the line below and uncomment the fixed values for debugging
        do_randomize();
        // Uncomment the next 3 lines for fixed-value debugging
        //program_seq.src = 32'h1000_1000;
        //program_seq.dest = 32'h2000_1000;
        //program_seq.len = 8; // 8 beats = 64 bytes

        // Step 3: Sync src/dest/len to memrd_seq
        memrd_seq.src  = program_seq.src;
        memrd_seq.dest = program_seq.dest;
        memrd_seq.len  = program_seq.len;

        `uvm_info("VSEQ", $sformatf("DMA Transfer Configuration: src=0x%0h dest=0x%0h len=%0d beats (%0d bytes)", 
                         program_seq.src, program_seq.dest, program_seq.len, program_seq.len*8), UVM_LOW)

        // Step 4: Pre-load source memory — pass seqr explicitly (no m_sequencer cast needed)
        // dma_memrd_seq only uses the TLM FIFO, not start_item/finish_item,
        // so it does not need a real sequencer; start on null.
        memrd_seq.seqr = p_sequencer.axi_s_seqr;
        memrd_seq.start(null);

        // Step 5: Wait for reset to settle then program + start DMA via APB
        `uvm_info("VSEQ", "Waiting for reset to settle...", UVM_LOW)
        repeat(10) @(posedge apb_vif.clk);
        `uvm_info("VSEQ", "Starting DMA programming sequence...", UVM_LOW)
        program_seq.start(p_sequencer.apb_seqr);
        `uvm_info("VSEQ", "DMA programming sequence completed", UVM_LOW)
        // Allow a few cycles for the DMA to begin issuing AXI transactions
        repeat(40) @(posedge apb_vif.clk);

        /*
        // DIAGNOSTICS: Read back key registers to verify programming
        `uvm_info("VSEQ", "--- Register readback diagnostics ---", UVM_LOW)
        apb_rd(`CMD_REG0_ADDR,       readback);
        `uvm_info("VSEQ", $sformatf("CMD_REG0  (src):     expected=0x%08h got=0x%08h %s",
            program_seq.src,    readback, readback==program_seq.src    ? "OK" : "MISMATCH"), UVM_LOW)
        apb_rd(`CMD_REG1_ADDR,       readback);
        `uvm_info("VSEQ", $sformatf("CMD_REG1  (dest):    expected=0x%08h got=0x%08h %s",
            program_seq.dest,   readback, readback==program_seq.dest   ? "OK" : "MISMATCH"), UVM_LOW)
        apb_rd(`CMD_REG2_ADDR,       readback);
        `uvm_info("VSEQ", $sformatf("CMD_REG2  (len):     expected=%0d got=%0d %s",
            program_seq.len, readback[9:0], readback[9:0]==program_seq.len ? "OK" : "MISMATCH"), UVM_LOW)
        apb_rd(`CMD_REG3_ADDR,       readback);
        `uvm_info("VSEQ", $sformatf("CMD_REG3  (ctrl):    expected=0x00000003 got=0x%08h %s",
            readback, readback==32'h3 ? "OK" : "MISMATCH"), UVM_LOW)
        apb_rd(`CH_ENABLE_REG_ADDR,  readback);
        `uvm_info("VSEQ", $sformatf("CH_ENABLE:           expected=0x00000001 got=0x%08h %s",
            readback, readback[0] ? "OK" : "MISMATCH"), UVM_LOW)
        apb_rd(`INT_ENABLE_REG_ADDR, readback);
        `uvm_info("VSEQ", $sformatf("INT_ENABLE:          expected=0x00001FFF got=0x%08h %s",
            readback, readback==32'h1FFF ? "OK" : "MISMATCH"), UVM_LOW)
        apb_rd(`INT_RAWSTAT_REG_ADDR, readback);
        `uvm_info("VSEQ", $sformatf("INT_RAWSTAT (pre-poll): got=0x%08h", readback), UVM_LOW)
        `uvm_info("VSEQ", "--- End register readback ---", UVM_LOW)
        */

        // Step 6: Poll INT_RAWSTAT[0] (ch_end) until set or timeout
        `uvm_info("VSEQ", "Polling for DMA completion (INT_RAWSTAT[0])...", UVM_LOW)
        poll_count = 0;
        poll_seq.poll_addr = `INT_RAWSTAT_REG_ADDR;
        do begin
            poll_seq.start(p_sequencer.apb_seqr);
            rawstat = poll_seq.rdata;
            poll_count++;
            if (poll_count % 1000 == 0) begin
                `uvm_info("VSEQ", $sformatf("Still polling... count=%0d INT_RAWSTAT=0x%0h", 
                             poll_count, rawstat), UVM_LOW)
            end
            if (poll_count >= POLL_TIMEOUT) begin
                `uvm_error("VSEQ", $sformatf("DMA completion timeout after %0d polls", poll_count))
                apb_rd(`INT_RAWSTAT_REG_ADDR, readback);
                `uvm_error("VSEQ", $sformatf("Timeout: INT_RAWSTAT=0x%0h", readback))
                apb_rd(`CH_ACTIVE_REG_ADDR, readback);
                `uvm_error("VSEQ", $sformatf("Timeout: CH_ACTIVE_REG=0x%0h", readback))
                apb_rd(`COUNT_REG_ADDR, readback);
                `uvm_error("VSEQ", $sformatf("Timeout: COUNT_REG=0x%0h", readback))
                apb_rd(`INT_STATUS_REG_ADDR, readback);
                `uvm_error("VSEQ", $sformatf("Timeout: INT_STATUS=0x%0h", readback))
                `uvm_fatal("VSEQ", "DMA timeout - see errors above")
            end
        end while (!rawstat[0]);

        `uvm_info("VSEQ", $sformatf("DMA completed after %0d polls", poll_count), UVM_LOW)
        
        // Clear the ch_end interrupt by writing 1 to INT_CLEAR[0]
        `uvm_info("VSEQ", "Clearing ch_end interrupt...", UVM_LOW)
        begin
            apb_write_seq clr_seq = apb_write_seq::type_id::create("clr_seq");
            clr_seq.wr_addr = `INT_CLEAR_REG_ADDR;
            clr_seq.wr_data = 32'h0000_0001;
            clr_seq.start(p_sequencer.apb_seqr);
        end
        // Verify interrupt cleared
        apb_rd(`INT_RAWSTAT_REG_ADDR, readback);
        `uvm_info("VSEQ", $sformatf("INT_RAWSTAT after clear: 0x%0h", readback), UVM_LOW)

        `uvm_info("SCBD", "Scoreboard testing...", UVM_LOW)

        // Step 7: Scoreboard — build expected pattern then delegate to dma_scoreboard
        begin
            int        nbytes = program_seq.len * 8;
            bit [7:0]  expected [];
            expected = new[nbytes];
            foreach (expected[i]) expected[i] = i[7:0]; // same pattern as dma_memrd_seq
            p_sequencer.scbd.check_transfer(program_seq.dest, program_seq.len, expected);
        end

    endtask : body

endclass : vseq_base
