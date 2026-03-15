class axi_s_driver extends uvm_driver #(axi_sequence_item);
    `uvm_component_utils(axi_s_driver)

    parameter int D_WIDTH = 64;
    parameter int A_WIDTH = 32;
    
    // Components
    // Note: modports cannot be used with virtual interfaces; use the base interface type
    // virtual axi_if.slave vif - incorrect
    // virtual axi_if vif  - correct
    virtual axi_if#(.D_WIDTH(D_WIDTH), .A_WIDTH(A_WIDTH)) vif;

    // Typed sequencer handle — assigned by the agent in connect_phase
    axi_s_sequencer seqr;

    // Variables
    axi_sequence_item#(D_WIDTH, A_WIDTH) s_wtrans, s_rtrans;
    bit [7:0] mem [bit[A_WIDTH-1:0]];
    bit [A_WIDTH-1:0] w_addr, r_addr;
    bit w_done, r_done;
    

    // Methods
    extern task drive();
    extern task read_write_address();
    extern task read_read_address();
    extern task read_write_data();
    extern task send_read_data();

    function new(string name, uvm_component parent);
        super.new(name, parent);
        w_done = 1;
        r_done = 1;
    endfunction //new()

    //  Function: build_phase
    extern function void build_phase(uvm_phase phase);
    
    //  Function: run_phase
    extern task run_phase(uvm_phase phase);
    
endclass //axi_s_driver extends uvm_driver

function void axi_s_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);
    s_wtrans = new("s_wtrans");
    s_rtrans = new("s_rtrans");
    if(!uvm_config_db#(virtual axi_if#(.D_WIDTH(D_WIDTH),.A_WIDTH(A_WIDTH)))::get(this, "", "axi_vif", vif))
        `uvm_fatal("NO_VIF", "axi_s_driver: failed to get vif from config_db")
endfunction: build_phase

task axi_s_driver::run_phase(uvm_phase phase);
    `uvm_info("DEBUG_S", "Inside AXI Slave Driver Run Phase", UVM_LOW)

    if (seqr == null)
        `uvm_fatal("NULL_SEQR", "axi_s_driver: seqr handle is null — not assigned by agent connect_phase")

    // Wait for one clock edge before driving to avoid time-0 race
    @(vif.s_drv_cb);

    // Initialise all slave-driven signals
    vif.s_drv_cb.AWREADY    <= 1;
    vif.s_drv_cb.ARREADY    <= 1;
    vif.s_drv_cb.WREADY     <= 1;
    vif.s_drv_cb.BVALID     <= 0;
    vif.s_drv_cb.RVALID     <= 0;
    vif.s_drv_cb.RLAST      <= 0;
    vif.s_drv_cb.RDATA      <= 'b0;
    vif.s_drv_cb.BID        <= 'b0;
    vif.s_drv_cb.BRESP      <= 'b0;
    vif.s_drv_cb.RID        <= 'b0;
    vif.s_drv_cb.RRESP      <= 'b0;

    // Wait for reset deassertion once before spawning AXI channel threads.
    // Use the raw interface signal (not the clocking-block sampled version) so
    // the posedge event fires reliably regardless of when this code is reached.
    // The `if` guard handles the case where rstn is already high at this point.
    //if (!vif.rstn) @(posedge vif.rstn);
    @(vif.s_drv_cb);  // re-align to the next clock edge after reset release

    fork
        // Thread 1: TLM backdoor — service mem pre-load / scoreboard read requests from sequences
        forever begin
            axi_mem_item req, rsp;
            seqr.mem_req_fifo.get(req);
            rsp = axi_mem_item::type_id::create("rsp");
            rsp.op   = req.op;
            rsp.addr = req.addr;
            rsp.len  = req.len;
            if (req.op == axi_mem_item::MEM_WRITE) begin
                foreach (req.data[i]) mem[req.addr + i] = req.data[i];
                `uvm_info("DEBUG_S", $sformatf("TLM pre-load: wrote %0d bytes at 0x%08h", req.len, req.addr), UVM_LOW)
            end else begin
                rsp.data = new[req.len];
                foreach (rsp.data[i]) rsp.data[i] = mem.exists(req.addr+i) ? mem[req.addr+i] : 8'h0;
                `uvm_info("DEBUG_S", $sformatf("TLM read: read %0d bytes from 0x%08h", req.len, req.addr), UVM_LOW)
            end
            seqr.mem_rsp_fifo.write(rsp);
        end

        // Thread 2: AXI write channel — runs continuously, one burst at a time.
        // No per-iteration reset guard needed: reset was waited once above.
        forever begin
            `uvm_info("DEBUG_S", "Waiting for AXI write transaction...", UVM_LOW)
            read_write_address();
            read_write_data();
        end

        // Thread 3: AXI read channel — runs continuously, one burst at a time.
        forever begin
            `uvm_info("DEBUG_S", "Waiting for AXI read transaction...", UVM_LOW)
            read_read_address();
            send_read_data();
        end

    join_none

endtask: run_phase

task axi_s_driver::drive();
    // drive() is no longer used — AXI channels are handled by
    // persistent threads in run_phase directly
endtask: drive

task axi_s_driver::read_write_address();
    // Use the raw interface wire for the wait() so it reacts to combinatorial
    // changes between clock edges.  Then re-align to a clock edge before
    // sampling the clocking-block inputs.
    wait(vif.AWVALID);
    `uvm_info("DEBUG_S", "Inside read_write_address", UVM_LOW)
    @(vif.s_drv_cb);
    s_wtrans.id     = vif.s_drv_cb.AWID;
    s_wtrans.addr   = vif.s_drv_cb.AWADDR;
    s_wtrans.b_size = vif.s_drv_cb.AWSIZE;
    s_wtrans.b_type = B_TYPE'(vif.s_drv_cb.AWBURST);
    s_wtrans.b_len  = vif.s_drv_cb.AWLEN;

    s_wtrans.print();
endtask: read_write_address

task axi_s_driver::read_write_data();
    int addr_1, addr_n, addr_align;
    int lower_byte_lane, upper_byte_lane, upper_wrap_boundary, lower_wrap_boundary;
    int no_bytes, total_bytes;
    bit isAligned;
    int c;
    bit err, align_err;
    `uvm_info("DEBUG_S", "Inside read_write_data", UVM_LOW)
    vif.s_drv_cb.BVALID     <= 0;
    
    // Initial values and calculations
    addr_1 = s_wtrans.addr;
    no_bytes = 2**s_wtrans.b_size;
    total_bytes = no_bytes * (s_wtrans.b_len+1);
    addr_align = int'(addr_1/no_bytes)*no_bytes;
    `uvm_info("DEBUG_S", $sformatf("Calculated write aligned addr %0h", addr_align), UVM_LOW)
    isAligned = addr_1 == addr_align;

    // Calculate boundaries for WRAP Burst
    if(s_wtrans.b_type == WRAP) begin
        lower_wrap_boundary = int'(addr_1/total_bytes)*total_bytes; // Basically to round down/Remove decimal
        upper_wrap_boundary = lower_wrap_boundary + total_bytes;
        `uvm_info("DEBUG_S", $sformatf("Calculated Lower Wrap Boundary: %0d", lower_wrap_boundary), UVM_LOW)
        `uvm_info("DEBUG_S", $sformatf("Calculated Upper Wrap Boundary: %0d", upper_wrap_boundary), UVM_LOW)
    end

    // AXI spec requires WRAP bursts to be naturally aligned.
    // Flag an error if the master violated this — does NOT prevent data transfer.
    if (s_wtrans.b_type == WRAP && !isAligned)
        align_err = 1;

    // Store data — executes unconditionally for all burst types
    err = 0;
    for (int i=0; i<s_wtrans.b_len+1; i++) begin
        `uvm_info("DEBUG_S", "Inside read_data_loop", UVM_LOW)

        // Beat-0 lane calculation is used:
        //   a) on the very first beat of any burst (i==0), because the start
        //      address may be unaligned and the valid byte lanes are narrower, and
        //   b) on EVERY beat of a FIXED burst, because the address never advances
        //      so the same lane calculation applies each time.
        // Note: b_type == FIXED and b_type == WRAP are mutually exclusive (enum),
        //       so the FIXED branch here never fires during a WRAP burst.
        if(i==0 || s_wtrans.b_type == FIXED) begin
                lower_byte_lane = addr_1-int'(addr_1/(D_WIDTH/8))*(D_WIDTH/8);
                upper_byte_lane = addr_align+no_bytes-1-int'(addr_1/(D_WIDTH/8))*(D_WIDTH/8);
                addr_n = addr_1;
                c = isAligned ? 0 : lower_byte_lane;
                while (c>=no_bytes) begin
                    c -= no_bytes;
                end
            end
            // For 2nd and all other transfers the address is always alligned and thus can read the entire 
            // valid byte lane, i.e, [0:8*2**b_size]; and thus c always start with 0
            else begin
                lower_byte_lane = addr_n-int'(addr_n/(D_WIDTH/8))*(D_WIDTH/8);
                upper_byte_lane = lower_byte_lane + no_bytes-1;
                c = 0;
            end


            `uvm_info("DEBUG_S", $sformatf("lower_byte_lane is %0d", lower_byte_lane), UVM_LOW)
            `uvm_info("DEBUG_S", $sformatf("upper_byte_lane is %0d", upper_byte_lane), UVM_LOW)
            `uvm_info("DEBUG_S", $sformatf("addr_n is %0h", addr_n), UVM_LOW)
            wait(vif.WVALID);
            @(vif.s_drv_cb);
            // Check WLAST on the final beat
            if (i == s_wtrans.b_len && !vif.s_drv_cb.WLAST)
                `uvm_error("WLAST", $sformatf("Expected WLAST on beat %0d but not asserted", i))
            // Follows little endian; gate each byte write with its WSTRB bit
            err = 0;
            for (int j=lower_byte_lane; j<=upper_byte_lane; j++) begin
                longint unsigned full_addr = longint'(unsigned'(addr_n)) + j - lower_byte_lane;
                bit[A_WIDTH-1:0] addr = full_addr[A_WIDTH-1:0];
                if(full_addr >= longint'(2)**A_WIDTH) begin
                    err = 1;
                    continue;
                end
                if (!vif.s_drv_cb.WSTRB[j]) begin
                    `uvm_info("DEBUG_S", $sformatf("c is %0d, addr is %0h, byte masked by WSTRB", c, addr), UVM_LOW)
                    c++;
                    c = c>=no_bytes ? 0:c;
                    continue;
                end
                mem[addr] = vif.s_drv_cb.WDATA[8*c+:8];
                `uvm_info("DEBUG_S", $sformatf("c is %0d, addr is %0h, stored value is %h", c, addr, mem[addr]), UVM_LOW)
                c++;
                c = c>=no_bytes ? 0:c;
            end

        // Update address
        if(s_wtrans.b_type != FIXED) begin
            if(isAligned) begin
                addr_n = addr_n+no_bytes;
                if(s_wtrans.b_type == WRAP) begin
                    `uvm_info("DEBUG_S", $sformatf("Updated addrn before boundary check: %0h", addr_n), UVM_LOW)
                    addr_n = addr_n>=upper_wrap_boundary ? lower_wrap_boundary : addr_n;
                    `uvm_info("DEBUG_S", $sformatf("Updated addrn after boundary check: %0h", addr_n), UVM_LOW)
                end
            end
            else begin
                addr_n = addr_align + no_bytes;
                isAligned = 1;
            end
        end
        @(vif.s_drv_cb);
    end
    vif.s_drv_cb.BID        <= s_wtrans.id;
    if(err || align_err)
        vif.s_drv_cb.BRESP  <= 2'b01;
    else
        vif.s_drv_cb.BRESP  <= 2'b00;
    @(vif.s_drv_cb);
    vif.s_drv_cb.BVALID <= 1;
    @(vif.s_drv_cb);
    wait(vif.BREADY);
    @(vif.s_drv_cb);
    vif.s_drv_cb.BVALID <= 0;
endtask: read_write_data

task axi_s_driver::read_read_address();
    `uvm_info("DEBUG_S", "Inside read_read_address", UVM_LOW)
    // Use the raw interface wire for the wait() — same reasoning as
    // read_write_address above.
    wait(vif.ARVALID);
    @(vif.s_drv_cb);
    s_rtrans.id     = vif.s_drv_cb.ARID;
    s_rtrans.addr   = vif.s_drv_cb.ARADDR;
    s_rtrans.b_size = vif.s_drv_cb.ARSIZE;
    s_rtrans.b_type = B_TYPE'(vif.s_drv_cb.ARBURST);
    s_rtrans.b_len  = vif.s_drv_cb.ARLEN;

    s_rtrans.print();
endtask: read_read_address

task axi_s_driver::send_read_data();
    int addr_1, addr_n, addr_align;
    int lower_byte_lane, upper_byte_lane, upper_wrap_boundary, lower_wrap_boundary;
    int no_bytes, total_bytes;
    bit isAligned;
    int c;
    bit err;
    `uvm_info("DEBUG_S", "Inside send_write_data", UVM_LOW)
    addr_1 = s_rtrans.addr;
    no_bytes = 2**s_rtrans.b_size;
    total_bytes = no_bytes * (s_rtrans.b_len+1);

    // Calculate align address
    addr_align = int'(addr_1/no_bytes)*no_bytes;
    `uvm_info("DEBUG_S", $sformatf("Calculated read aligned addr %0h", addr_align), UVM_LOW)
    isAligned = addr_1 == addr_align;

    // If WRAP Burst then calculate the wrap boundary
    if(s_rtrans.b_type == WRAP) begin
        lower_wrap_boundary = int'(addr_1/total_bytes)*total_bytes;
        upper_wrap_boundary = lower_wrap_boundary + total_bytes;
        `uvm_info("DEBUG_S", $sformatf("Calculated Lower Wrap Boundary: %0h", lower_wrap_boundary), UVM_LOW)
        `uvm_info("DEBUG_S", $sformatf("Calculated Upper Wrap Boundary: %0h", upper_wrap_boundary), UVM_LOW)
    end

    // Initial signals
    vif.s_drv_cb.RLAST  <= 0;
    vif.s_drv_cb.RVALID <=0;
    vif.s_drv_cb.RID    <= s_rtrans.id;

    // Store data
    for (int i=0; i<s_rtrans.b_len+1; i++) begin
        `uvm_info("DEBUG_S", "Inside send_data_loop", UVM_LOW)

        // Beat-0 lane calculation is used:
        //   a) on the very first beat of any burst (i==0), because the start
        //      address may be unaligned and the valid byte lanes are narrower, and
        //   b) on EVERY beat of a FIXED burst, because the address never advances
        //      so the same lane calculation applies each time.
        // Note: b_type == FIXED and b_type == WRAP are mutually exclusive (enum),
        //       so the FIXED branch here never fires during a WRAP burst.
        if(i==0 || s_rtrans.b_type == FIXED) begin
            lower_byte_lane = addr_1-int'(addr_1/(D_WIDTH/8))*(D_WIDTH/8);
            upper_byte_lane = addr_align+no_bytes-1-int'(addr_1/(D_WIDTH/8))*(D_WIDTH/8);
            addr_n = addr_1;
            c = isAligned ? 0 : lower_byte_lane;
            while (c>=no_bytes) begin
                c -= no_bytes;
            end
        end
        // For 2nd and all other transfers the address is always alligned and thus can read the entire 
        // valid byte lane, i.e, [0:8*2**b_size]; and thus c always start with 0
        else begin
            lower_byte_lane = addr_n-int'(addr_n/(D_WIDTH/8))*(D_WIDTH/8);
            upper_byte_lane = lower_byte_lane + no_bytes-1;
            c = 0;
        end

        // @(vif.s_drv_cb);
        `uvm_info("DEBUG_S", $sformatf("lower_byte_lane is %0h", lower_byte_lane), UVM_LOW)
        `uvm_info("DEBUG_S", $sformatf("upper_byte_lane is %0h", upper_byte_lane), UVM_LOW)
        `uvm_info("DEBUG_S", $sformatf("addr_n is %0h", addr_n), UVM_LOW)
        // Follows little endian
        err = 0;
        for (int j=lower_byte_lane; j<=upper_byte_lane; j++) begin
            longint unsigned full_addr = longint'(unsigned'(addr_n)) + j - lower_byte_lane;
            bit[A_WIDTH-1:0] addr = full_addr[A_WIDTH-1:0];
            if(full_addr >= longint'(2)**A_WIDTH) begin
                err = 1;
                vif.s_drv_cb.RDATA[8*c+:8] <= 'b0;
                `uvm_info("DEBUG_S", $sformatf("c is %0d, addr is %0h, Out of bounds", c, addr), UVM_LOW)
                continue;
            end
            if(!mem.exists(addr)) begin
                mem[addr] = 'b0;  // Initialize memory if it doesn't exist
            end
            vif.s_drv_cb.RDATA[8*c+:8] <= mem[addr];
            `uvm_info("DEBUG_S", $sformatf("c is %0d, addr is %0h, stored value is %h", c, addr, mem[addr]), UVM_LOW)
            c++;
            c = c>=no_bytes ? 0:c;
        end

        if(i == s_rtrans.b_len) begin
            vif.s_drv_cb.RLAST <= 1;
        end
            

        if(err)
            vif.s_drv_cb.RRESP <= 2'b01;
        else
            vif.s_drv_cb.RRESP <= 2'b00;
        
        @(vif.s_drv_cb);
        vif.s_drv_cb.RVALID <= 1;

        // Update address
        if(s_rtrans.b_type != FIXED) begin
            if(isAligned) begin
                addr_n = addr_n+no_bytes;
                if(s_rtrans.b_type == WRAP) begin
                    `uvm_info("DEBUG_S", $sformatf("Updated addrn before boundary check: %0h", addr_n), UVM_LOW)
                    addr_n = addr_n>=upper_wrap_boundary ? lower_wrap_boundary : addr_n;
                    `uvm_info("DEBUG_S", $sformatf("Updated addrn after boundary check: %0h", addr_n), UVM_LOW)
                end
            end
            else begin
                addr_n = addr_align + no_bytes;
                isAligned = 1;
            end
        end
        @(vif.s_drv_cb);
        wait(vif.RREADY);
        @(vif.s_drv_cb);
        vif.s_drv_cb.RVALID <= 0;
        vif.s_drv_cb.RLAST  <= 0;  // deassert RLAST after final beat handshake
    end
endtask: send_read_data