import uvm_pkg::*;

class axi_tran#() extends uvm_sequence_item;
  typedef axi_tran#(d_width, a_width) this_type_t;
  `uvm_object_param_utils(axi_tran#(d_width, a_width));
  
    //  Group: Variables
    bit [8:0] id;
    rand bit [a_width-1:0] addr;
    rand bit [7:0] data [][];
    rand bit [2:0] b_size;
    rand bit [3:0] b_len;
    rand B_TYPE b_type;
    bit b_last;
    bit [1:0] b_resp;
    bit [1:0] r_resp [];

  // Constructor: new
  function new(string name = "axi_tran");
    // super.new() calls the constructor of the parent class. 
    // Since axi_transaction extends uvm_sequence_item, it calls uvm_sequence_item::new().
    super.new(name);  
  endfunction: new

endclass: axi_transaction
