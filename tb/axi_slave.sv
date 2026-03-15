class axi_slave extends uvm_agent;
    `uvm_component_utils(axi_slave)
    
    // Components
    axi_s_driver s_drv;
    axi_s_sequencer s_seqr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction //new()

    //  Function: build_phase
    extern function void build_phase(uvm_phase phase);
    
    //  Function: connect_phase
    extern function void connect_phase(uvm_phase phase);
    
endclass //axi_slave extends uvm_agent


function void axi_slave::build_phase(uvm_phase phase);
    
    s_drv = axi_s_driver::type_id::create("s_drv", this);  // What is the differences between create("drv") and create("s_drv")
    s_seqr = axi_s_sequencer::type_id::create("s_seqr", this);

endfunction: build_phase

function void axi_slave::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    s_drv.seq_item_port.connect(s_seqr.seq_item_export);
    // Give the driver a typed handle to the sequencer for direct FIFO access
    s_drv.seqr = s_seqr;
endfunction: connect_phase
