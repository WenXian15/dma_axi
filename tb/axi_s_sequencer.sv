class axi_s_sequencer extends uvm_sequencer #(axi_sequence_item);
    `uvm_component_utils(axi_s_sequencer)

    // TLM FIFOs for memory pre-load/read requests from sequences
    uvm_tlm_analysis_fifo #(axi_mem_item) mem_req_fifo;     // sequences PUT here
    uvm_tlm_analysis_fifo #(axi_mem_item) mem_rsp_fifo;     // seqeunces GET from here 

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mem_req_fifo = new("mem_req_fifo", this);
        mem_rsp_fifo = new("mem_rsp_fifo", this);
    endfunction

endclass : axi_s_sequencer