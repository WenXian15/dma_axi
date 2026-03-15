// Small inline APB poll sequence — reads one register and returns its data
class apb_poll_seq extends apb_base_sequence;
    `uvm_object_utils(apb_poll_seq)
    logic [12:0] poll_addr;
    logic [31:0] rdata;
    function new(string name = "apb_poll_seq");
        super.new(name);
    endfunction
    task body();
        apb_read(poll_addr, rdata);
    endtask
endclass : apb_poll_seq