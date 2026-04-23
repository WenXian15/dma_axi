class dma_memrd_seq extends uvm_sequence;
    `uvm_object_utils(dma_memrd_seq)

    rand logic [31:0] src;
    rand logic [31:0] dest;
    rand logic [9:0]  len;  // number of beats (matches dma_program_seq.len)

    // Explicit sequencer handle — set by vseq_base before calling start().
    // Avoids relying on an m_sequencer downcast.
    axi_s_sequencer seqr;

    extern function new(string name = "dma_memrd_seq");
    extern task body();

endclass : dma_memrd_seq

function dma_memrd_seq::new(string name = "dma_memrd_seq");
    super.new(name);
endfunction : new

task dma_memrd_seq::body();
    axi_mem_item req;

    if (seqr == null)
        `uvm_fatal(get_type_name(), "dma_memrd_seq: seqr handle is null — set memrd_seq.seqr before start()")

    req = axi_mem_item::type_id::create("req");
    req.op   = axi_mem_item::MEM_WRITE;
    req.addr = src;
    req.len  = len * 8;
    req.data = new[len * 8];
    foreach (req.data[i]) req.data[i] = i[7:0]; // known incrementing pattern

    // Put request into sequencer's mem_req_fifo for the driver to service
    seqr.mem_req_fifo.analysis_export.write(req);

    `uvm_info(get_type_name(), $sformatf("Pre-loaded %8h of %0d bytes at src=0x%08h", req.data, req.len, req.addr), UVM_LOW)

endtask : body