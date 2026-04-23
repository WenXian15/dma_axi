class vseq_single_beat extends vseq_base;
    `uvm_object_utils(vseq_single_beat)

    function new(string name = "vseq_single_beat");
        super.new(name);
    endfunction : new

    extern virtual task do_randomize();

endclass : vseq_single_beat

// Override the virtual function
// No need virtual front of task
task vseq_single_beat::do_randomize();
    assert(program_seq.randomize() with { 
        len == 1; 
        src == 32'h0000_10000; 
        dest == 32'h1000_1000;
    });

endtask : do_randomize