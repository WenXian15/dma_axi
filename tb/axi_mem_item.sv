class axi_mem_item extends uvm_object;
    `uvm_object_utils(axi_mem_item)

    typedef enum { MEM_WRITE, MEM_READ } mem_op_e;

    mem_op_e op;
    bit [31:0] addr;
    bit [31:0] len;     // number of bytes
    bit [7:0] data [];  // payload for WRITE; response data for READ

    function new(string name = "axi_mem_item");
        super.new(name);
    endfunction

endclass