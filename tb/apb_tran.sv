import uvm_pkg::*;

class apb_tran#() extends uvm_sequence_item;
  typedef apb_tran#(d_width, a_width) this_type_t;
  `uvm_object_param_utils(apb_tran#(d_width, a_width));
  
    //  Group: Variables
    bit pclken;
    bit psel;
    bit penable;
    rand bit [a_width-1:0] paddr;
    bit pwrite;
    rand bit [d_width-1:0] pwdata;
  
  // Constructor: new
  function new(string name = "apb_tran");
    // super.new() calls the constructor of the parent class. 
    // Since axi_transaction extends uvm_sequence_item, it calls uvm_sequence_item::new().
    super.new(name);  
  endfunction: new

endclass: apb_tran
