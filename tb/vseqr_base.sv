class vseqr_base extends uvm_sequencer #(uvm_sequence_item);
    `uvm_component_utils(vseqr_base)
            
    apb_sequencer   apb_seqr;
    axi_s_sequencer axi_s_seqr;
    dma_scoreboard  scbd;       // set by environment in connect_phase

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

endclass : vseqr_base

    