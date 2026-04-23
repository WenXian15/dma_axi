class test_end_to_end extends test_base;
    `uvm_component_utils(dma_test)

    vseq_base vseq;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction //build_phase()

    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Starting dma_test", UVM_LOW)
        vseq = vseq_base::type_id::create("vseq");
        phase.raise_objection(this);
        vseq.start(env.vseqr_base_inst);
        phase.drop_objection(this);
    endtask //run_phase()

endclass //uvm_test

/*
class dma_apb_test extends dma_test;
    `uvm_component_utils(dma_apb_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction //new()

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(), "Starting dma_apb_test", UVM_LOW)
        // Start APB specific test sequences or stimulus here
        apb_seq.start(env.apb_agent_inst.apb_seqr);
        phase.drop_objection(this);
        `uvm_info(get_type_name(), "dma_apb_test Completed", UVM_LOW)

    endtask //run_phase()
endclass : dma_apb_test
*/