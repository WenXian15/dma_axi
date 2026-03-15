class apb_base_sequence extends uvm_sequence #(apb_sequence_item);
    `uvm_object_utils(apb_base_sequence)
    
    apb_sequence_item tr;

    extern function new(string name = "apb_base_sequence");
    extern task apb_write(logic [12:0] addr, logic [31:0] data);
    extern task apb_read(logic [12:0] addr, output logic [31:0] rdata);
    extern task apb_rmw(logic [12:0] addr, int lsb,  int width, logic [31:0] field_val);
    extern task body();

endclass : apb_base_sequence

    function apb_base_sequence::new(string name = "apb_base_sequence");
        super.new(name);
    endfunction

    /*
    `uvm_do_with(ITEM, CONSTRAINTS)

    is equivalent to:

    ITEM = ITEM::type_id::create("ITEM");
    start_item(ITEM);
    assert(ITEM.randomize() with { CONSTRAINTS; });
    finish_item(ITEM);
    */


    // Write helper
    task apb_base_sequence::apb_write(logic [12:0] addr, logic [31:0] data);
        tr = apb_sequence_item::type_id::create("tr");
        start_item(tr);
        tr.psel = 1;
        tr.paddr = addr;
        tr.pwrite = 1;
        tr.pwdata = data;

        /*
        `uvm_do_with(tr, {
            paddr == addr; 
            pwrite == 1; 
            pwdata == data;
        });
        */

        `uvm_info(get_type_name(), $sformatf("Generated APB Transaction: ADDR=0x%0h, WRITE=%0b, WDATA=0x%0h", 
                                              tr.paddr, 
                                              tr.pwrite, 
                                              tr.pwdata), 
                                              UVM_LOW)
        finish_item(tr);
        
    endtask : apb_write

    // Read helper — returns read data via output argument
    task apb_base_sequence::apb_read(logic [12:0] addr, output logic [31:0] rdata);
        tr = apb_sequence_item::type_id::create("tr");
        start_item(tr);
        tr.paddr  = addr;
        tr.pwrite = 0;
        tr.pwdata = '0;
        `uvm_info(get_type_name(), $sformatf("Generated APB Transaction: ADDR=0x%h, WRITE=%0b, WDATA=0x%0h",
                                              tr.paddr,
                                              tr.pwrite,
                                              tr.pwdata),
                                              UVM_LOW)
        finish_item(tr);
        rdata = tr.prdata;  // populated by driver via item_done(req)
    endtask : apb_read

    task apb_base_sequence::apb_rmw(input logic [12:0] addr, input int lsb, input int width, input logic [31:0] field_val );
        logic [31:0] rdata;
        logic [31:0] mask;
        apb_read(addr, rdata);
        mask = ((1 << width) - 1) << lsb;
        rdata = (rdata & ~mask) | ((field_val << lsb) & mask);
        apb_write(addr, rdata);
    endtask : apb_rmw

    task apb_base_sequence::body();
        `uvm_info(get_type_name(), "APB Base Sequence Started", UVM_LOW)
        tr = apb_sequence_item::type_id::create("tr");
        `uvm_info(get_type_name(), "APB Base Sequence Completed", UVM_LOW)
    endtask : body