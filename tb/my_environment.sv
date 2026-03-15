class my_environment extends uvm_env;
    `uvm_component_utils(my_environment)

    //dma_top_reg_block regmodel;
    apb_agent      apb_agent_inst;
    axi_slave      axi_slave_agent_inst;
    vseqr_base     vseqr_base_inst;
    dma_scoreboard scbd;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "This is my ENV", UVM_LOW)
        apb_agent_inst       = apb_agent::type_id::create("apb_agent_inst", this);
        axi_slave_agent_inst = axi_slave::type_id::create("axi_slave_agent_inst", this);
        vseqr_base_inst      = vseqr_base::type_id::create("vseqr_base_inst", this);
        scbd                 = dma_scoreboard::type_id::create("scbd", this);
        //regmodel = dma_top_reg_block::type_id::create("regmodel", this);
        //regmodel.build();
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        // APB driver <-> sequencer
        apb_agent_inst.apb_drv.seq_item_port.connect(apb_agent_inst.apb_seqr.seq_item_export);
        // axi_slave driver<->sequencer connection is done inside axi_slave::connect_phase
        // Virtual sequencer: give handles to the real sequencers and scoreboard
        vseqr_base_inst.apb_seqr   = apb_agent_inst.apb_seqr;
        vseqr_base_inst.axi_s_seqr = axi_slave_agent_inst.s_seqr;
        vseqr_base_inst.scbd       = scbd;
        // Scoreboard: needs the AXI slave sequencer to issue TLM mem read requests
        scbd.seqr                  = axi_slave_agent_inst.s_seqr;
    endfunction

endclass