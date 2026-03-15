class apb_monitor extends uvm_monitor;
    `uvm_component_utils(apb_monitor)

    virtual apb_if apb_vif;
    uvm_analysis_port#(apb_sequence_item) apb_ap;


    function new(string name, uvm_component parent);
        super.new(name, parent);
        apb_ap = new("apb_ap", this);
    endfunction : new

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        //if(!uvm_config_db#(apb_if)::get(this, "", "apb_vif", apb_vif)) begin
        //    `uvm_fatal("APB_MON", "apb_vif not found in configuration database")
        //end
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        
    endtask : run_phase

endclass : apb_monitor