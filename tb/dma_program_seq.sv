class dma_program_seq extends apb_base_sequence;
    `uvm_object_utils(dma_program_seq)

    rand logic [31:0] src;
    rand logic [31:0] dest;
    rand logic [9:0]  len;

    // len must be at least 1 beat so the DMA actually transfers something
    constraint c_len_nonzero { len > 0; }

    // Both addresses must be 8-byte aligned (64-bit bus, one beat = 8 bytes)
    constraint c_aligned {
        src  % 8 == 0;
        dest % 8 == 0;
    }

    // Keep src in the lower quarter and dest in a non-overlapping upper quarter
    // of the address space so the two regions can never overlap regardless of len.
    // Each region is 256 MB, large enough for any len (max 1023 beats * 8 B = ~8 kB).
    constraint c_addr_range {
        src  inside {[32'h0000_1000 : 32'h0FFF_F000]};
        dest inside {[32'h1000_0000 : 32'h1FFF_F000]};
    }

    apb_sequence_item tr;

    extern function new(string name = "dma_program_seq");
    extern task body();
    extern task read_registers();
    extern task configure_static_registers();
    extern task configure_interrupt_controller();
    extern task configure_command_list();
    extern task enable_channel();
    extern task start_channel();
    extern task dma_verify_dma_config();

endclass : dma_program_seq

function dma_program_seq::new(string name = "dma_program_seq");
    super.new(name);
endfunction : new

task dma_program_seq::read_registers();
    logic [31:0] rdata;
    // Example of reading multiple registers
    apb_read(`CMD_REG0_ADDR,                  rdata);
    apb_read(`CMD_REG1_ADDR,                  rdata);
    apb_read(`CMD_REG2_ADDR,                  rdata);
    apb_read(`CMD_REG3_ADDR,                  rdata);
    apb_read(`STATIC_REG0_ADDR,               rdata);
    apb_read(`STATIC_REG1_ADDR,               rdata);
    apb_read(`STATIC_REG2_ADDR,               rdata);
    apb_read(`STATIC_REG3_ADDR,               rdata);
    apb_read(`STATIC_REG4_ADDR,               rdata);
    apb_read(`READ_OFFSET_REG_ADDR,           rdata);
    apb_read(`WRITE_OFFSET_REG_ADDR,          rdata);
    apb_read(`FULLNESS_REG_ADDR,              rdata);
    apb_read(`CMD_OUTS_REG_ADDR,              rdata);
    apb_read(`CH_ENABLE_REG_ADDR,             rdata);
    apb_read(`CH_START_REG_ADDR,              rdata);
    apb_read(`CH_ACTIVE_REG_ADDR,             rdata);
    apb_read(`COUNT_REG_ADDR,                 rdata);
    apb_read(`INT_RAWSTAT_REG_ADDR,           rdata);
    apb_read(`INT_CLEAR_REG_ADDR,             rdata);
    apb_read(`INT_ENABLE_REG_ADDR,            rdata);
    apb_read(`INT_STATUS_REG_ADDR,            rdata);
    apb_read(`INT0_STATUS_ADDR,               rdata);
    apb_read(`CORE0_JOIN_MODE_ADDR,           rdata);
    apb_read(`CORE0_PRIORITY_ADDR,            rdata);
    apb_read(`CORE0_CLKDIV_ADDR,              rdata);
    apb_read(`CORE0_CH_START_ADDR,            rdata);
    apb_read(`PERIPH_RX_CTRL_ADDR,            rdata);
    apb_read(`PERIPH_TX_CTRL_ADDR,            rdata);
    apb_read(`IDLE_ADDR,                      rdata);
    apb_read(`USER_DEF_STATUS_ADDR,           rdata);
    apb_read(`USER_CORE0_DEF_STATUS0_ADDR,    rdata);
    apb_read(`USER_CORE0_DEF_STATUS1_ADDR,    rdata);
    `uvm_info(get_type_name(), $sformatf("%h", `USER_CORE0_DEF_STATUS1_ADDR), UVM_LOW);

endtask : read_registers


task dma_program_seq::configure_static_registers();
    // STATIC_LINE0 (0x10): read-side burst parameters
    //   [7:0]  rd_burst_max_size = 8'hFF (max 256-beat burst)
    //   [21:16] rd_tokens        = 6'h01
    //   [27:24] rd_outs_max      = 4'hF  (up to 16 outstanding reads)
    //   [31]   rd_incr           = 1     (INCR addressing)
    apb_write(`STATIC_REG0_ADDR, 32'h8F01_00FF);

    // STATIC_LINE1 (0x14): write-side burst parameters
    //   [7:0]  wr_burst_max_size = 8'hFF (max 256-beat burst)
    //   [21:16] wr_tokens        = 6'h01
    //   [27:24] wr_outs_max      = 4'hF  (up to 16 outstanding writes)
    //   [31]   wr_incr           = 1     (INCR addressing)
    apb_write(`STATIC_REG1_ADDR, 32'h8F01_00FF);

    // STATIC_LINE2 (0x18): transfer mode
    //   [16] joint = 1 (enable joint read/write mode for simple memory transfers)
    apb_write(`STATIC_REG2_ADDR, 32'h0001_0000);

    `uvm_info(get_type_name(), "Static Registers Configured", UVM_LOW)
endtask : configure_static_registers

task dma_program_seq::configure_interrupt_controller();
    // INT_ENABLE (0xA8): enable all 13 interrupt sources (INT_NUM=13)
    //   Bit 0  : ch_end
    //   Bit 1  : rd_slverr
    //   Bit 2  : wr_slverr
    //   Bit 3  : rd_decerr
    //   Bit 4  : wr_decerr
    //   Bit 5  : fifo_overflow
    //   Bit 6  : fifo_underflow
    //   Bit 7  : timeout_r
    //   Bit 8  : timeout_ar
    //   Bit 9  : timeout_b
    //   Bit 10 : timeout_w
    //   Bit 11 : timeout_aw
    //   Bit 12 : wdt_timeout
    apb_write(`INT_ENABLE_REG_ADDR, 32'h0000_1FFF); // Enable all 13 interrupt sources
    `uvm_info(get_type_name(), "Interrupt Controller Configured", UVM_LOW)
endtask : configure_interrupt_controller

task dma_program_seq::configure_command_list();
    // CMD_LINE0 (0x00): read (source) start address
    apb_write(`CMD_REG0_ADDR, {src});

    // CMD_LINE1 (0x04): write (destination) start address
    apb_write(`CMD_REG1_ADDR, {dest});

    // CMD_LINE2 (0x08): transfer size in buff_size[9:0] (number of data beats)
    apb_write(`CMD_REG2_ADDR, {22'h0, len[9:0]});

    // CMD_LINE3 (0x0C): command control
    //   [0]    cmd_set_int  = 1 (assert interrupt on completion)
    //   [1]    cmd_last     = 1 (this is the last command in the list)
    //   [31:2] cmd_next_addr = 0 (no next command)
    apb_write(`CMD_REG3_ADDR, 32'h0000_0003);

    `uvm_info(get_type_name(), $sformatf("DMA Command List Configured: src=0x%08h dest=0x%08h len=%0d", src, dest, len[9:0]), UVM_LOW)
endtask : configure_command_list

task dma_program_seq::enable_channel();
    apb_write(`CH_ENABLE_REG_ADDR, 32'h0000_0001); // Enable channel 0
    `uvm_info(get_type_name(), "DMA Channel Enabled", UVM_LOW)
endtask : enable_channel

task dma_program_seq::start_channel();
    // CH_START (0x44) is the per-channel start register.
    // Writing here triggers wr_ch_start which resets counters and kicks off
    // the transfer. CORE0_CH_START is not written to avoid double-triggering.
    apb_write(`CH_START_REG_ADDR, 32'h0000_0001); // Start channel 0
    `uvm_info(get_type_name(), "DMA Channel Started", UVM_LOW)
endtask : start_channel

task dma_program_seq::dma_verify_dma_config();
        logic [31:0] readback;

        // ADDITIONAL DIAGNOSTICS: Read back key registers to verify programming
        `uvm_info("VSEQ", "Reading back DMA registers to verify programming...", UVM_LOW)
        apb_read(`CMD_REG0_ADDR, readback);
        `uvm_info("VSEQ", $sformatf("CMD_REG0 (src addr): expected=0x%0h actual=0x%0h", 
                         src, readback), UVM_LOW)
        apb_read(`CMD_REG1_ADDR, readback);
        `uvm_info("VSEQ", $sformatf("CMD_REG1 (dest addr): expected=0x%0h actual=0x%0h", 
                         dest, readback), UVM_LOW)
        apb_read(`CMD_REG2_ADDR, readback);
        `uvm_info("VSEQ", $sformatf("CMD_REG2 (length): expected=%0d actual=%0d", 
                         len, readback[9:0]), UVM_LOW)
        apb_read(`CMD_REG3_ADDR, readback);
        `uvm_info("VSEQ", $sformatf("CMD_REG3 (control): expected=0x%0h actual=0x%0h", 
                         32'h0000_0003, readback), UVM_LOW) // cmd_set_int=1, cmd_last=1
        apb_read(`CH_ENABLE_REG_ADDR, readback);
        `uvm_info("VSEQ", $sformatf("CH_ENABLE_REG: expected=0x%0h actual=0x%0h", 
                         32'h0000_0001, readback), UVM_LOW)
        apb_read(`CH_START_REG_ADDR, readback);
        `uvm_info("VSEQ", $sformatf("CH_START_REG: expected=0x%0h actual=0x%0h", 
                         32'h0000_0001, readback), UVM_LOW)
        apb_read(`INT_ENABLE_REG_ADDR, readback);
        `uvm_info("VSEQ", $sformatf("INT_ENABLE_REG: expected=0x%0h actual=0x%0h", 
                         32'h0000_1FFF, readback), UVM_LOW) // all interrupts enabled
        apb_read(`INT_RAWSTAT_REG_ADDR, readback);
        `uvm_info("VSEQ", $sformatf("INT_RAWSTAT_REG (pre-poll): actual=0x%0h", 
                         readback), UVM_LOW)
endtask : dma_verify_dma_config

task dma_program_seq::body();
    super.body();

    `uvm_info(get_type_name(), "DMA Program Sequence Started", UVM_LOW)

    configure_static_registers();
    configure_interrupt_controller();
    configure_command_list();
    enable_channel();
    start_channel();
    dma_verify_dma_config();

    `uvm_info(get_type_name(), "DMA Program Sequence Completed", UVM_LOW)
endtask : body
