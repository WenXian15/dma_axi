class apb_driver extends uvm_driver #(apb_sequence_item);
    `uvm_component_utils(apb_driver)
    virtual apb_if apb_vif;
    apb_sequence_item req;

    extern function new(string name = "apb_driver", uvm_component parent);
    extern virtual function void build_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);
    extern virtual task init_signals();
    extern virtual task wait_for_reset();
    extern virtual task drive();

endclass  : apb_driver

    function apb_driver::new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void apb_driver::build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", apb_vif)) begin
            `uvm_fatal(get_type_name(), "Cannot get apb_vif from uvm_config_db")
        end
    endfunction: build_phase

    task apb_driver::run_phase(uvm_phase phase);
        req = apb_sequence_item::type_id::create("req");
        forever begin
            init_signals();
            wait_for_reset();
            drive();
        end
    endtask : run_phase

    task apb_driver::init_signals();
        apb_vif.psel    <= 0;
        apb_vif.penable <= 0;
        apb_vif.pwrite  <= 0;
    endtask :init_signals

    task apb_driver::wait_for_reset();
        @(!apb_vif.rstn);
    endtask : wait_for_reset

    task apb_driver::drive();
        forever begin
            seq_item_port.get_next_item(req);
            // Modport does not need posedge
            @(apb_vif.master_cb);
            apb_vif.psel <= 1;
            apb_vif.paddr  <= req.paddr;
            apb_vif.pwrite <= req.pwrite;
            apb_vif.pwdata <= req.pwdata;
            // @(apb_vif.clk); // This doesnt work
            @(apb_vif.master_cb);
            apb_vif.penable <= 1;
            wait(apb_vif.pready);
            req.prdata = apb_vif.prdata;  // capture read data back into item
            apb_vif.psel <= 0;
            apb_vif.penable <= 0;
            `uvm_info(get_type_name(), $sformatf("APB Transaction Completed: ADDR=0x%h, WRITE=%0b, WDATA=0x%h, RDATA=0x%h", req.paddr, req.pwrite, req.pwdata, req.prdata), UVM_LOW);
            seq_item_port.item_done(req);  // return item with prdata populated
            repeat(10) @(apb_vif.master_cb);
        end
    endtask