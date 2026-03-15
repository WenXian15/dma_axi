class apb_agent extends uvm_agent;
    `uvm_component_utils(apb_agent)

    apb_driver apb_drv;
    apb_monitor apb_mon;
    apb_sequencer apb_seqr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        apb_drv = apb_driver::type_id::create("apb_drv", this);
        apb_mon = apb_monitor::type_id::create("apb_mon", this);
        apb_seqr = apb_sequencer::type_id::create("apb_seqr", this);

    endfunction : build_phase

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        //apb_drv.seq_item_port.connect(apb_seqr.seq_item_export);
    endfunction : connect_phase

endclass : apb_agent