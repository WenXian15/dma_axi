import uvm_pkg::*;

class apb_sequence_item#() extends uvm_sequence_item;
  `uvm_object_utils(apb_sequence_item)
  
    //  Group: Variables
    bit pclken;
    bit psel;
    bit penable;
    bit [12:0] paddr;
    bit pwrite;
    bit [31:0] pwdata;
    bit [31:0] prdata;  // captured read data from driver

  // Constructor: new
  function new(string name = "apb_sequence_item");
    // super.new() calls the constructor of the parent class. 
    // Since axi_transaction extends uvm_sequence_item, it calls uvm_sequence_item::new().
    super.new(name);  
  endfunction: new

endclass: apb_sequence_item