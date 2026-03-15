class test_base extends uvm_test;
    `uvm_component_utils(test_base)

    // Environment instantiation
    my_environment env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction //new()

    function void build_phase(uvm_phase phase);
        env = my_environment::type_id::create("env", this);
    endfunction: build_phase

endclass : test_base