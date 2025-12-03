class proc0_status extends uvm_reg;
  `uvm_object_utils(intr)
   
  rand uvm_reg_field status;
  rand uvm_reg_field mask;

  function new (string name = "proc0_status");
    super.new(name,32,UVM_NO_COVERAGE);
  endfunction

  function void build; 
    
    // Create bitfield
    status = uvm_reg_field::type_id::create("status");   
    // Configure
    status.configure(.parent(this), 
                     .size(16), 
                     .lsb_pos(0), 
                     .access("RW"),  
                     .volatile(0), 
                     .reset(0), 
                     .has_reset(1), 
                     .is_rand(1), 
                     .individually_accessible(0)); 
    // Below line is equivalen to above one   
    // status.configure(this, 32,       0,   "RW",   0,        0,        1,        1,      0); 
    //                  reg, bitwidth, lsb, access, volatile, reselVal, hasReset, isRand, fieldAccess
    
    mask = uvm_reg_field::type_id::create("mask");   
    mask.configure(.parent(this), 
                     .size(16), 
                     .lsb_pos(16), 
                     .access("RW"),  
                     .volatile(0), 
                     .reset(0), 
                     .has_reset(1), 
                     .is_rand(1), 
                     .individually_accessible(0));    
    endfunction
endclass

class proc1_status extends uvm_reg;
  `uvm_object_utils(intr)
   
  rand uvm_reg_field status;
  rand uvm_reg_field mask;

  function new (string name = "proc1_status");
    super.new(name,32,UVM_NO_COVERAGE);
  endfunction

  function void build; 
    
    // Create bitfield
    status = uvm_reg_field::type_id::create("proc1_status");   
    // Configure
    status.configure(.parent(this), 
                     .size(16), 
                     .lsb_pos(0), 
                     .access("RW"),  
                     .volatile(0), 
                     .reset(0), 
                     .has_reset(1), 
                     .is_rand(1), 
                     .individually_accessible(0)); 
    // Below line is equivalen to above one   
    // status.configure(this, 32,       0,   "RW",   0,        0,        1,        1,      0); 
    //                  reg, bitwidth, lsb, access, volatile, reselVal, hasReset, isRand, fieldAccess
    
    mask = uvm_reg_field::type_id::create("mask");   
    mask.configure(.parent(this), 
                     .size(16), 
                     .lsb_pos(16), 
                     .access("RW"),  
                     .volatile(0), 
                     .reset(0), 
                     .has_reset(1), 
                     .is_rand(1), 
                     .individually_accessible(0));    
    endfunction
endclass

class core0_joint extends uvm_reg;
  `uvm_object_utils(intr)
   
  rand uvm_reg_field status;
  rand uvm_reg_field mask;

  function new (string name = "intr");
    super.new(name,32,UVM_NO_COVERAGE);
  endfunction

  function void build; 
    
    // Create bitfield
    status = uvm_reg_field::type_id::create("status");   
    // Configure
    status.configure(.parent(this), 
                     .size(16), 
                     .lsb_pos(0), 
                     .access("RW"),  
                     .volatile(0), 
                     .reset(0), 
                     .has_reset(1), 
                     .is_rand(1), 
                     .individually_accessible(0)); 
    // Below line is equivalen to above one   
    // status.configure(this, 32,       0,   "RW",   0,        0,        1,        1,      0); 
    //                  reg, bitwidth, lsb, access, volatile, reselVal, hasReset, isRand, fieldAccess
    
    mask = uvm_reg_field::type_id::create("mask");   
    mask.configure(.parent(this), 
                     .size(16), 
                     .lsb_pos(16), 
                     .access("RW"),  
                     .volatile(0), 
                     .reset(0), 
                     .has_reset(1), 
                     .is_rand(1), 
                     .individually_accessible(0));    
    endfunction
endclass

class core1_joint extends uvm_reg;
  `uvm_object_utils(intr)
   
  rand uvm_reg_field status;
  rand uvm_reg_field mask;

  function new (string name = "intr");
    super.new(name,32,UVM_NO_COVERAGE);
  endfunction

  function void build; 
    
    // Create bitfield
    status = uvm_reg_field::type_id::create("status");   
    // Configure
    status.configure(.parent(this), 
                     .size(16), 
                     .lsb_pos(0), 
                     .access("RW"),  
                     .volatile(0), 
                     .reset(0), 
                     .has_reset(1), 
                     .is_rand(1), 
                     .individually_accessible(0)); 
    // Below line is equivalen to above one   
    // status.configure(this, 32,       0,   "RW",   0,        0,        1,        1,      0); 
    //                  reg, bitwidth, lsb, access, volatile, reselVal, hasReset, isRand, fieldAccess
    
    mask = uvm_reg_field::type_id::create("mask");   
    mask.configure(.parent(this), 
                     .size(16), 
                     .lsb_pos(16), 
                     .access("RW"),  
                     .volatile(0), 
                     .reset(0), 
                     .has_reset(1), 
                     .is_rand(1), 
                     .individually_accessible(0));    
    endfunction
endclass

class core0_prio extends uvm_reg;
  `uvm_object_utils(intr)
   
  rand uvm_reg_field status;
  rand uvm_reg_field mask;

  function new (string name = "intr");
    super.new(name,32,UVM_NO_COVERAGE);
  endfunction

  function void build; 
    
    // Create bitfield
    status = uvm_reg_field::type_id::create("status");   
    // Configure
    status.configure(.parent(this), 
                     .size(16), 
                     .lsb_pos(0), 
                     .access("RW"),  
                     .volatile(0), 
                     .reset(0), 
                     .has_reset(1), 
                     .is_rand(1), 
                     .individually_accessible(0)); 
    // Below line is equivalen to above one   
    // status.configure(this, 32,       0,   "RW",   0,        0,        1,        1,      0); 
    //                  reg, bitwidth, lsb, access, volatile, reselVal, hasReset, isRand, fieldAccess
    
    mask = uvm_reg_field::type_id::create("mask");   
    mask.configure(.parent(this), 
                     .size(16), 
                     .lsb_pos(16), 
                     .access("RW"),  
                     .volatile(0), 
                     .reset(0), 
                     .has_reset(1), 
                     .is_rand(1), 
                     .individually_accessible(0));    
    endfunction
endclass

class core1_prio extends uvm_reg;
  `uvm_object_utils(intr)
   
  rand uvm_reg_field status;
  rand uvm_reg_field mask;

  function new (string name = "intr");
    super.new(name,32,UVM_NO_COVERAGE);
  endfunction

  function void build; 
    
    // Create bitfield
    status = uvm_reg_field::type_id::create("status");   
    // Configure
    status.configure(.parent(this), 
                     .size(16), 
                     .lsb_pos(0), 
                     .access("RW"),  
                     .volatile(0), 
                     .reset(0), 
                     .has_reset(1), 
                     .is_rand(1), 
                     .individually_accessible(0)); 
    // Below line is equivalen to above one   
    // status.configure(this, 32,       0,   "RW",   0,        0,        1,        1,      0); 
    //                  reg, bitwidth, lsb, access, volatile, reselVal, hasReset, isRand, fieldAccess
    
    mask = uvm_reg_field::type_id::create("mask");   
    mask.configure(.parent(this), 
                     .size(16), 
                     .lsb_pos(16), 
                     .access("RW"),  
                     .volatile(0), 
                     .reset(0), 
                     .has_reset(1), 
                     .is_rand(1), 
                     .individually_accessible(0));    
    endfunction
endclass


class core0_clkdiv extends uvm_reg;
  `uvm_object_utils(intr)
   
  rand uvm_reg_field status;
  rand uvm_reg_field mask;

  function new (string name = "intr");
    super.new(name,32,UVM_NO_COVERAGE);
  endfunction

  function void build; 
    
    // Create bitfield
    status = uvm_reg_field::type_id::create("status");   
    // Configure
    status.configure(.parent(this), 
                     .size(16), 
                     .lsb_pos(0), 
                     .access("RW"),  
                     .volatile(0), 
                     .reset(0), 
                     .has_reset(1), 
                     .is_rand(1), 
                     .individually_accessible(0)); 
    // Below line is equivalen to above one   
    // status.configure(this, 32,       0,   "RW",   0,        0,        1,        1,      0); 
    //                  reg, bitwidth, lsb, access, volatile, reselVal, hasReset, isRand, fieldAccess
    
    mask = uvm_reg_field::type_id::create("mask");   
    mask.configure(.parent(this), 
                     .size(16), 
                     .lsb_pos(16), 
                     .access("RW"),  
                     .volatile(0), 
                     .reset(0), 
                     .has_reset(1), 
                     .is_rand(1), 
                     .individually_accessible(0));    
    endfunction
endclass

class core1_clkdiv extends uvm_reg;
  `uvm_object_utils(intr)
   
  rand uvm_reg_field status;
  rand uvm_reg_field mask;

  function new (string name = "intr");
    super.new(name,32,UVM_NO_COVERAGE);
  endfunction

  function void build; 
    
    // Create bitfield
    status = uvm_reg_field::type_id::create("status");   
    // Configure
    status.configure(.parent(this), 
                     .size(16), 
                     .lsb_pos(0), 
                     .access("RW"),  
                     .volatile(0), 
                     .reset(0), 
                     .has_reset(1), 
                     .is_rand(1), 
                     .individually_accessible(0)); 
    // Below line is equivalen to above one   
    // status.configure(this, 32,       0,   "RW",   0,        0,        1,        1,      0); 
    //                  reg, bitwidth, lsb, access, volatile, reselVal, hasReset, isRand, fieldAccess
    
    mask = uvm_reg_field::type_id::create("mask");   
    mask.configure(.parent(this), 
                     .size(16), 
                     .lsb_pos(16), 
                     .access("RW"),  
                     .volatile(0), 
                     .reset(0), 
                     .has_reset(1), 
                     .is_rand(1), 
                     .individually_accessible(0));    
    endfunction
endclass


class core0_start extends uvm_reg;
  `uvm_object_utils(intr)
   
  rand uvm_reg_field status;
  rand uvm_reg_field mask;

  function new (string name = "intr");
    super.new(name,32,UVM_NO_COVERAGE);
  endfunction

  function void build; 
    
    // Create bitfield
    status = uvm_reg_field::type_id::create("status");   
    // Configure
    status.configure(.parent(this), 
                     .size(16), 
                     .lsb_pos(0), 
                     .access("RW"),  
                     .volatile(0), 
                     .reset(0), 
                     .has_reset(1), 
                     .is_rand(1), 
                     .individually_accessible(0)); 
    // Below line is equivalen to above one   
    // status.configure(this, 32,       0,   "RW",   0,        0,        1,        1,      0); 
    //                  reg, bitwidth, lsb, access, volatile, reselVal, hasReset, isRand, fieldAccess
    
    mask = uvm_reg_field::type_id::create("mask");   
    mask.configure(.parent(this), 
                     .size(16), 
                     .lsb_pos(16), 
                     .access("RW"),  
                     .volatile(0), 
                     .reset(0), 
                     .has_reset(1), 
                     .is_rand(1), 
                     .individually_accessible(0));    
    endfunction
endclass

class core1_start extends uvm_reg;
  `uvm_object_utils(intr)
   
  rand uvm_reg_field status;
  rand uvm_reg_field mask;

  function new (string name = "intr");
    super.new(name,32,UVM_NO_COVERAGE);
  endfunction

  function void build; 
    
    // Create bitfield
    status = uvm_reg_field::type_id::create("status");   
    // Configure
    status.configure(.parent(this), 
                     .size(16), 
                     .lsb_pos(0), 
                     .access("RW"),  
                     .volatile(0), 
                     .reset(0), 
                     .has_reset(1), 
                     .is_rand(1), 
                     .individually_accessible(0)); 
    // Below line is equivalen to above one   
    // status.configure(this, 32,       0,   "RW",   0,        0,        1,        1,      0); 
    //                  reg, bitwidth, lsb, access, volatile, reselVal, hasReset, isRand, fieldAccess
    
    mask = uvm_reg_field::type_id::create("mask");   
    mask.configure(.parent(this), 
                     .size(16), 
                     .lsb_pos(16), 
                     .access("RW"),  
                     .volatile(0), 
                     .reset(0), 
                     .has_reset(1), 
                     .is_rand(1), 
                     .individually_accessible(0));    
    endfunction
endclass

// PERIPH_RX_CTRL
class periph_rx_ctrl extends uvm_reg;
  `uvm_object_utils(intr)
   
  rand uvm_reg_field status;
  rand uvm_reg_field mask;

  function new (string name = "intr");
    super.new(name,32,UVM_NO_COVERAGE);
  endfunction

  function void build; 
    
    // Create bitfield
    status = uvm_reg_field::type_id::create("status");   
    // Configure
    status.configure(.parent(this), 
                     .size(16), 
                     .lsb_pos(0), 
                     .access("RW"),  
                     .volatile(0), 
                     .reset(0), 
                     .has_reset(1), 
                     .is_rand(1), 
                     .individually_accessible(0)); 
    // Below line is equivalen to above one   
    // status.configure(this, 32,       0,   "RW",   0,        0,        1,        1,      0); 
    //                  reg, bitwidth, lsb, access, volatile, reselVal, hasReset, isRand, fieldAccess
    
    mask = uvm_reg_field::type_id::create("mask");   
    mask.configure(.parent(this), 
                     .size(16), 
                     .lsb_pos(16), 
                     .access("RW"),  
                     .volatile(0), 
                     .reset(0), 
                     .has_reset(1), 
                     .is_rand(1), 
                     .individually_accessible(0));    
    endfunction
endclass

class periph_tx_ctrl extends uvm_reg;
  `uvm_object_utils(intr)
   
  rand uvm_reg_field status;
  rand uvm_reg_field mask;

  function new (string name = "intr");
    super.new(name,32,UVM_NO_COVERAGE);
  endfunction

  function void build; 
    
    // Create bitfield
    status = uvm_reg_field::type_id::create("status");   
    // Configure
    status.configure(.parent(this), 
                     .size(16), 
                     .lsb_pos(0), 
                     .access("RW"),  
                     .volatile(0), 
                     .reset(0), 
                     .has_reset(1), 
                     .is_rand(1), 
                     .individually_accessible(0)); 
    // Below line is equivalen to above one   
    // status.configure(this, 32,       0,   "RW",   0,        0,        1,        1,      0); 
    //                  reg, bitwidth, lsb, access, volatile, reselVal, hasReset, isRand, fieldAccess
    
    mask = uvm_reg_field::type_id::create("mask");   
    mask.configure(.parent(this), 
                     .size(16), 
                     .lsb_pos(16), 
                     .access("RW"),  
                     .volatile(0), 
                     .reset(0), 
                     .has_reset(1), 
                     .is_rand(1), 
                     .individually_accessible(0));    
    endfunction
endclass


// IDLE
class idle extends uvm_reg;
  `uvm_object_utils(intr)
   
  rand uvm_reg_field status;
  rand uvm_reg_field mask;

  function new (string name = "idle");
    super.new(name,32,UVM_NO_COVERAGE);
  endfunction

  function void build; 
    
    // Create bitfield
    status = uvm_reg_field::type_id::create("status");   
    // Configure
    status.configure(.parent(this), 
                     .size(16), 
                     .lsb_pos(0), 
                     .access("RW"),  
                     .volatile(0), 
                     .reset(0), 
                     .has_reset(1), 
                     .is_rand(1), 
                     .individually_accessible(0)); 
    // Below line is equivalen to above one   
    // status.configure(this, 32,       0,   "RW",   0,        0,        1,        1,      0); 
    //                  reg, bitwidth, lsb, access, volatile, reselVal, hasReset, isRand, fieldAccess
    
    mask = uvm_reg_field::type_id::create("mask");   
    mask.configure(.parent(this), 
                     .size(16), 
                     .lsb_pos(16), 
                     .access("RW"),  
                     .volatile(0), 
                     .reset(0), 
                     .has_reset(1), 
                     .is_rand(1), 
                     .individually_accessible(0));    
    endfunction
endclass


// USER_DEF_STAT
class user_def_stat extends uvm_reg;
  `uvm_object_utils(intr)
   
  rand uvm_reg_field status;
  rand uvm_reg_field mask;

  function new (string name = "intr");
    super.new(name,32,UVM_NO_COVERAGE);
  endfunction

  function void build; 
    
    // Create bitfield
    status = uvm_reg_field::type_id::create("status");   
    // Configure
    status.configure(.parent(this), 
                     .size(16), 
                     .lsb_pos(0), 
                     .access("RW"),  
                     .volatile(0), 
                     .reset(0), 
                     .has_reset(1), 
                     .is_rand(1), 
                     .individually_accessible(0)); 
    // Below line is equivalen to above one   
    // status.configure(this, 32,       0,   "RW",   0,        0,        1,        1,      0); 
    //                  reg, bitwidth, lsb, access, volatile, reselVal, hasReset, isRand, fieldAccess
    
    mask = uvm_reg_field::type_id::create("mask");   
    mask.configure(.parent(this), 
                     .size(16), 
                     .lsb_pos(16), 
                     .access("RW"),  
                     .volatile(0), 
                     .reset(0), 
                     .has_reset(1), 
                     .is_rand(1), 
                     .individually_accessible(0));    
    endfunction
endclass

// USER_DEF0_STAT0
class user_def0_stat0 extends uvm_reg;
  `uvm_object_utils(intr)
   
  rand uvm_reg_field status;
  rand uvm_reg_field mask;

  function new (string name = "intr");
    super.new(name,32,UVM_NO_COVERAGE);
  endfunction

  function void build; 
    
    // Create bitfield
    status = uvm_reg_field::type_id::create("status");   
    // Configure
    status.configure(.parent(this), 
                     .size(16), 
                     .lsb_pos(0), 
                     .access("RW"),  
                     .volatile(0), 
                     .reset(0), 
                     .has_reset(1), 
                     .is_rand(1), 
                     .individually_accessible(0)); 
    // Below line is equivalen to above one   
    // status.configure(this, 32,       0,   "RW",   0,        0,        1,        1,      0); 
    //                  reg, bitwidth, lsb, access, volatile, reselVal, hasReset, isRand, fieldAccess
    
    mask = uvm_reg_field::type_id::create("mask");   
    mask.configure(.parent(this), 
                     .size(16), 
                     .lsb_pos(16), 
                     .access("RW"),  
                     .volatile(0), 
                     .reset(0), 
                     .has_reset(1), 
                     .is_rand(1), 
                     .individually_accessible(0));    
    endfunction
endclass


// USER_DEF0_STAT1
class user_def0_stat1 extends uvm_reg;
  `uvm_object_utils(intr)
   
  rand uvm_reg_field status;
  rand uvm_reg_field mask;

  function new (string name = "intr");
    super.new(name,32,UVM_NO_COVERAGE);
  endfunction

  function void build; 
    
    // Create bitfield
    status = uvm_reg_field::type_id::create("status");   
    // Configure
    status.configure(.parent(this), 
                     .size(16), 
                     .lsb_pos(0), 
                     .access("RW"),  
                     .volatile(0), 
                     .reset(0), 
                     .has_reset(1), 
                     .is_rand(1), 
                     .individually_accessible(0)); 
    // Below line is equivalen to above one   
    // status.configure(this, 32,       0,   "RW",   0,        0,        1,        1,      0); 
    //                  reg, bitwidth, lsb, access, volatile, reselVal, hasReset, isRand, fieldAccess
    
    mask = uvm_reg_field::type_id::create("mask");   
    mask.configure(.parent(this), 
                     .size(16), 
                     .lsb_pos(16), 
                     .access("RW"),  
                     .volatile(0), 
                     .reset(0), 
                     .has_reset(1), 
                     .is_rand(1), 
                     .individually_accessible(0));    
    endfunction
endclass


// USER_DEF1_STAT0
class user_def1_stat0 extends uvm_reg;
  `uvm_object_utils(intr)
   
  rand uvm_reg_field status;
  rand uvm_reg_field mask;

  function new (string name = "intr");
    super.new(name,32,UVM_NO_COVERAGE);
  endfunction

  function void build; 
    
    // Create bitfield
    status = uvm_reg_field::type_id::create("status");   
    // Configure
    status.configure(.parent(this), 
                     .size(16), 
                     .lsb_pos(0), 
                     .access("RW"),  
                     .volatile(0), 
                     .reset(0), 
                     .has_reset(1), 
                     .is_rand(1), 
                     .individually_accessible(0)); 
    // Below line is equivalen to above one   
    // status.configure(this, 32,       0,   "RW",   0,        0,        1,        1,      0); 
    //                  reg, bitwidth, lsb, access, volatile, reselVal, hasReset, isRand, fieldAccess
    
    mask = uvm_reg_field::type_id::create("mask");   
    mask.configure(.parent(this), 
                     .size(16), 
                     .lsb_pos(16), 
                     .access("RW"),  
                     .volatile(0), 
                     .reset(0), 
                     .has_reset(1), 
                     .is_rand(1), 
                     .individually_accessible(0));    
    endfunction
endclass

// USER_DEF1_STAT1
class user_def1_stat1 extends uvm_reg;
  `uvm_object_utils(intr)
   
  rand uvm_reg_field status;
  rand uvm_reg_field mask;

  function new (string name = "intr");
    super.new(name,32,UVM_NO_COVERAGE);
  endfunction

  function void build; 
    
    // Create bitfield
    status = uvm_reg_field::type_id::create("status");   
    // Configure
    status.configure(.parent(this), 
                     .size(16), 
                     .lsb_pos(0), 
                     .access("RW"),  
                     .volatile(0), 
                     .reset(0), 
                     .has_reset(1), 
                     .is_rand(1), 
                     .individually_accessible(0)); 
    // Below line is equivalen to above one   
    // status.configure(this, 32,       0,   "RW",   0,        0,        1,        1,      0); 
    //                  reg, bitwidth, lsb, access, volatile, reselVal, hasReset, isRand, fieldAccess
    
    mask = uvm_reg_field::type_id::create("mask");   
    mask.configure(.parent(this), 
                     .size(16), 
                     .lsb_pos(16), 
                     .access("RW"),  
                     .volatile(0), 
                     .reset(0), 
                     .has_reset(1), 
                     .is_rand(1), 
                     .individually_accessible(0));    
    endfunction
endclass



//	Register Block Definition
class dma_reg_model extends uvm_reg_block;
  `uvm_object_utils(dma_reg_model)
  
  // register instances 
  rand proc0_status 	  reg_proc0_status; 
  rand proc1_status 	  reg_proc1_status;
  rand core0_joint 	    reg_core0_joint;
  rand core1_joint      reg_core1_joint;
  rand core0_prio       reg_core0_prio;
  rand core1_prio       reg_core1_prio;
  rand core0_clkdiv     reg_core0_clkdiv;
  rand core1_clkdiv     reg_core1_clkdiv;
  rand core0_start      reg_core0_start;
  rand core1_start      reg_core1_start;
  rand periph_rx_ctrl   reg_periph_rx_ctrl;
  rand periph_tx_ctrl   reg_periph_tx_ctrl;
  rand idle             reg_idle;
  rand user_def_stat    reg_user_def_stat;
  rand user_def0_stat0  reg_user_def0_stat0;
  rand user_def0_stat1  reg_user_def0_stat1;
  rand user_def1_stat0  reg_user_def1_stat0;
  rand user_def1_stat1  reg_user_def1_stat1;
  
  
  function new (string name = "");
    super.new(name, build_coverage(UVM_NO_COVERAGE));
  endfunction

  function void build;
    
    // reg creation
    reg_proc0_status = proc0_status::type_id::create("reg_intr");
    reg_proc0_status.build();
    reg_proc0_status.configure(this);
    //r0.add_hdl_path_slice("r0", 0, 8);      // name, offset, bitwidth
 
    reg_proc1_status = proc1_status::type_id::create("reg_ctrl");
    reg_proc1_status.build();
    reg_proc1_status.configure(this);
    
    reg_core0_joint = core0_joint::type_id::create("reg_io_addr");
    reg_core0_joint.build();
    reg_core0_joint.configure(this);
  
    reg_core1_joint = core1_joint::type_id::create("reg_mem_addr");
    reg_core1_joint.build();
    reg_core1_joint.configure(this);
    
    reg_core0_prio = core0_prio::type_id::create("reg_extra_info");
    reg_core0_prio.build();
    reg_core0_prio.configure(this);

    reg_core1_prio = core1_prio::type_id::create("reg_extra_info");
    reg_core1_prio.build();
    reg_core1_prio.configure(this);

    reg_core0_clkdiv = core0_clkdiv::type_id::create("reg_extra_info");
    reg_core0_clkdiv.build();
    reg_core0_clkdiv.configure(this);

    reg_core1_clkdiv = core1_clkdiv::type_id::create("reg_extra_info");
    reg_core1_clkdiv.build();
    reg_core1_clkdiv.configure(this);

    reg_core0_start = core0_start::type_id::create("reg_extra_info");
    reg_core0_start.build();
    reg_core0_start.configure(this);

    reg_core1_start = core1_start::type_id::create("reg_extra_info");
    reg_core1_start.build();
    reg_core1_start.configure(this);

    reg_periph_rx_ctrl = periph_rx_ctrlt::type_id::create("reg_extra_info");
    reg_periph_rx_ctrl.build();
    reg_periph_rx_ctrl.configure(this);

    reg_periph_tx_ctrl = periph_tx_ctrlt::type_id::create("reg_extra_info");
    reg_periph_tx_ctrl.build();
    reg_periph_tx_ctrl.configure(this);

    reg_idle = idle::type_id::create("reg_extra_info");
    reg_idle.build();
    reg_idle.configure(this);

    reg_user_def_stat = user_def_stat::type_id::create("reg_user_def_stat");
    reg_user_def_stat.build();
    reg_user_def_stat.configure(this);

    reg_def0_stat0 = def0_stat0::type_id::create("reg_def0_stat0");
    reg_def0_stat0.build();
    reg_def0_stat0.configure(this);

    reg_def0_stat1 = def0_stat1::type_id::create("reg_def0_stat1");
    reg_def0_stat1.build();
    reg_def0_stat1.configure(this);

    reg_def1_stat0 = def1_stat0::type_id::create("reg_def1_stat0");
    reg_def1_stat0.build();
    reg_def1_stat0.configure(this);

    reg_def1_stat1 = def1_stat1::type_id::create("reg_def1_stat1");
    reg_def1_stat1.build();
    reg_def1_stat1.configure(this);    
    
    // memory map creation and reg map to it
    default_map = create_map("my_map", 0, 4, UVM_LITTLE_ENDIAN); // name, base, nBytes
    default_map.add_reg(reg_proc0_status, 'h0, "RW");  // reg, offset, access
    default_map.add_reg(reg_proc1_status, 'h4, "RW");
    default_map.add_reg(reg_proc2_status, 'h8, "RW");
    default_map.add_reg(reg_proc3_status, 'hC, "RW");
    default_map.add_reg(reg_proc4_status, 'h10, "RW");
    default_map.add_reg(reg_proc5_status, 'h14, "RW");
    default_map.add_reg(reg_proc6_status, 'h18, "RW");
    default_map.add_reg(reg_proc7_status, 'h1C, "RW");
    default_map.add_reg(reg_core0_joint, 'h30, "RW");  // reg, offset, access
    default_map.add_reg(reg_core1_joint, 'h34, "RW");
    default_map.add_reg(reg_core0_prio, 'h38, "RW");
    default_map.add_reg(reg_core1_prio, 'h3C, "RW");
    default_map.add_reg(reg_core0_clkdiv, 'h40, "RW");
    default_map.add_reg(reg_core1_clkdiv, 'h44, "RW");  // reg, offset, access
    default_map.add_reg(reg_core0_start, 'h48, "RW");
    default_map.add_reg(reg_core1_start, 'h4c, "RW");
    default_map.add_reg(reg_periph_rx_ctrl, 'h3C, "RW");
    default_map.add_reg(reg_periph_tx_ctrl, 'h50, "RW");
    default_map.add_reg(reg_idle	, 'h54, "RW");  // reg, offset, access
    default_map.add_reg(reg_user_def_stat	, 'hD0, "RW");
    default_map.add_reg(reg_user_def_stat	, 'hE0, "RW");
    default_map.add_reg(reg_user_def0_stat0, 'hF0, "RW");
    default_map.add_reg(reg_user_def0_stat1, 'hF4, "RW");
    default_map.add_reg(reg_user_def1_stat0, 'hF8, "RW");
    default_map.add_reg(reg_user_def1_stat1, 'hFC, "RW");
    
    lock_model();
  endfunction
endclass
