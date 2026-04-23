class vseq_multi_beat_burst extends vseq_base;
    `uvm_object_utils(vseq_multi_beat_burst)

    function new(string name = "vseq_multi_beat_burst");
        super.new(name);
    endfunction : new

    extern virtual task do_randomize();

endclass : vseq_multi_beat_burst

// Override the virtual function
// Take note that there is no virtual infront
task vseq_multi_beat_burst::do_randomize();
    assert(program_seq.randomize() with { 
        len >= 32; 
        src == 32'h0000_10000; 
        dest == 32'h1000_1000;
        });
endtask : do_randomize