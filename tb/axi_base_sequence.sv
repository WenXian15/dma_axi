class axi_base_sequence extends uvm_sequence #(axi_sequence_item);
    `uvm_object_utils(axi_base_sequence)

    axi_sequence_item tr;

    extern function new(string name = "axi_base_sequence");
    extern task body();

endclass : axi_base_sequence

    function axi_base_sequence::new(string name = "axi_base_sequence");
        super.new(name);
    endfunction

    task apb_base_sequence::body();
        `uvm_info(get_type_name(), "APB Base Sequence Started", UVM_LOW)
        tr = apb_sequence_item::type_id::create("tr");
        `uvm_info(get_type_name(), "APB Base Sequence Completed", UVM_LOW)
    endtask : body