class test_single_beat extends test_base;
    `uvm_component_utils(test_single_beat)

    vseq_single_beat vseq;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction //build_phase()

    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Starting test_single_beat", UVM_LOW)
        vseq = vseq_single_beat::type_id::create("vseq");
        phase.raise_objection(this);
        vseq.start(env.vseqr_base_inst);
        phase.drop_objection(this);
    endtask //run_phase()

endclass //uvm_test
