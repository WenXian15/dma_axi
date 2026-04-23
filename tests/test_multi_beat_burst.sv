class test_multi_beat_burst extends test_base;
    `uvm_component_utils(test_multi_beat_burst)

    vseq_multi_beat_burst vseq;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction //build_phase()

    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Starting test_multi_beat_burst", UVM_LOW)
        vseq = vseq_multi_beat_burst::type_id::create("vseq");
        phase.raise_objection(this);
        vseq.start(env.vseqr_base_inst);
        phase.drop_objection(this);
    endtask //run_phase()

endclass //uvm_test