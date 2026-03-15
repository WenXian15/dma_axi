class dma_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(dma_scoreboard)

    // Handle to the AXI slave sequencer — set by environment in connect_phase.
    // Used to issue MEM_READ requests through the TLM FIFO path into axi_s_driver.
    axi_s_sequencer seqr;

    // Cumulative counters — reported at check_phase
    int total_checks;
    int total_errors;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        total_checks = 0;
        total_errors = 0;
    endfunction

    // check_transfer()
    //
    //   dest     — byte address of the DMA destination region
    //   len      — number of bytes to verify
    //   expected — caller-supplied expected pattern (same size as len)
    //
    // Issues a MEM_READ request to axi_s_driver via the TLM FIFO, blocks until
    // the driver responds, then compares every byte against expected[].
    // Emits a per-transfer PASS/FAIL message and accumulates errors for
    // the check_phase summary.
    //
    // Named check_transfer (not check) to avoid conflicting with the
    // uvm_object::check() function inherited through uvm_scoreboard.
    task check_transfer(
        input bit  [31:0] dest,
        input int         len,
        input bit  [7:0]  expected []
    );
        axi_mem_item req, rsp;
        int          errors;

        if (seqr == null)
            `uvm_fatal("SCBD", "dma_scoreboard.check_transfer(): seqr handle is null — not set by environment")

        if (expected.size() != len) begin
            `uvm_error("SCBD", $sformatf(
                "check_transfer(): expected[] size (%0d) != len (%0d)",
                expected.size(), len))
            return;
        end

        // Build and issue the MEM_READ request to the driver
        req       = axi_mem_item::type_id::create("scbd_req");
        req.op    = axi_mem_item::MEM_READ;
        req.addr  = dest;
        req.len   = len;
        seqr.mem_req_fifo.analysis_export.write(req);

        // Block until driver services the request and responds
        seqr.mem_rsp_fifo.get(rsp);

        // Byte-by-byte comparison
        errors = 0;
        for (int i = 0; i < len; i++) begin
            if (rsp.data[i] !== expected[i]) begin
                `uvm_error("SCBD", $sformatf(
                    "Mismatch at dest+%0d (0x%08h): got 0x%02h, expected 0x%02h",
                    i, dest + i, rsp.data[i], expected[i]))
                errors++;
            end
        end

        total_errors += errors;
        total_checks++;

        if (errors == 0)
            `uvm_info("SCBD", $sformatf(
                "PASS [check #%0d]: all %0d bytes match at dest=0x%08h",
                total_checks, len, dest), UVM_LOW)
        else
            `uvm_error("SCBD", $sformatf(
                "FAIL [check #%0d]: %0d/%0d bytes mismatched at dest=0x%08h",
                total_checks, errors, len, dest))

    endtask : check_transfer

    // check_phase — emit overall pass/fail summary
    function void check_phase(uvm_phase phase);
        super.check_phase(phase);
        if (total_checks == 0) begin
            `uvm_warning("SCBD", "check_phase: no checks were performed")
            return;
        end
        if (total_errors == 0)
            `uvm_info("SCBD", $sformatf(
                "SCOREBOARD PASS: %0d check(s) completed, 0 errors",
                total_checks), UVM_NONE)
        else
            `uvm_error("SCBD", $sformatf(
                "SCOREBOARD FAIL: %0d error(s) across %0d check(s)",
                total_errors, total_checks))
    endfunction : check_phase

endclass : dma_scoreboard
