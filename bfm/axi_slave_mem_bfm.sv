module axi_slave_mem_bfm #(
  parameter int ADDR_W    = 32,
  parameter int DATA_W    = 64,
  parameter int ID_W      = 4,
  parameter int MEM_BYTES = 1<<20,   // 1MB
  parameter bit EN_WAIT   = 0        // set 1 if you want random wait states
)(
  axi_if.tb_slave axi
);

  localparam int STRB_W = DATA_W/8;

  // Byte-addressable memory
  byte mem [0:MEM_BYTES-1];

  // ----------------------------
  // Optional wait-state generator
  // ----------------------------
  function automatic logic maybe_wait();
    if (!EN_WAIT) return 1'b0;
    // simple pseudo-random wait (10% chance)
    return ($urandom_range(0,9) == 0);
  endfunction

  // ----------------------------
  // Write channel state
  // ----------------------------
  typedef enum logic [1:0] {W_IDLE, W_DATA, W_RESP} wstate_t;
  wstate_t wstate;

  logic [ID_W-1:0]   w_id;
  logic [ADDR_W-1:0] w_addr;
  logic [7:0]        w_len;
  logic [2:0]        w_size;
  logic [1:0]        w_burst;
  int unsigned       w_beat;

  // ----------------------------
  // Read channel state
  // ----------------------------
  typedef enum logic [1:0] {R_IDLE, R_DATA} rstate_t;
  rstate_t rstate;

  logic [ID_W-1:0]   r_id;
  logic [ADDR_W-1:0] r_addr;
  logic [7:0]        r_len;
  logic [2:0]        r_size;
  logic [1:0]        r_burst;
  int unsigned       r_beat;

  // ----------------------------
  // Helper: read a beat from memory
  // ----------------------------
  function automatic logic [DATA_W-1:0] mem_read_beat(input logic [ADDR_W-1:0] addr);
    logic [DATA_W-1:0] d;
    d = '0;
    for (int i = 0; i < STRB_W; i++) begin
      int unsigned a = addr + i;
      if (a < MEM_BYTES) d[i*8 +: 8] = mem[a];
      else               d[i*8 +: 8] = 8'h00;
    end
    return d;
  endfunction

  // Helper: write a beat into memory with strobe
  task automatic mem_write_beat(
    input logic [ADDR_W-1:0] addr,
    input logic [DATA_W-1:0] data,
    input logic [STRB_W-1:0] strb
  );
    for (int i = 0; i < STRB_W; i++) begin
      if (strb[i]) begin
        int unsigned a = addr + i;
        if (a < MEM_BYTES) mem[a] = data[i*8 +: 8];
      end
    end
  endtask

  // Address increment for INCR bursts
  function automatic logic [ADDR_W-1:0] next_addr(
    input logic [ADDR_W-1:0] base,
    input int unsigned beat,
    input logic [2:0] size
  );
    int unsigned bytes_per_beat = (1 << size);
    return base + beat * bytes_per_beat;
  endfunction

  // ----------------------------
  // Drive defaults
  // ----------------------------
  always_comb begin
    // READY defaults
    axi.awready = (wstate == W_IDLE) && !maybe_wait();
    axi.wready  = (wstate == W_DATA) && !maybe_wait();
    axi.arready = (rstate == R_IDLE) && !maybe_wait();

    // Response defaults
    axi.bid    = w_id;
    axi.bresp  = 2'b00;
    axi.bvalid = (wstate == W_RESP);

    // Read data defaults
    axi.rid    = r_id;
    axi.rresp  = 2'b00;
    axi.rvalid = (rstate == R_DATA);
    axi.rlast  = (rstate == R_DATA) && (r_beat == r_len);
    axi.rdata  = mem_read_beat(next_addr(r_addr, r_beat, r_size));
  end

  // ----------------------------
  // Sequential logic
  // ----------------------------
  always_ff @(posedge axi.aclk or negedge axi.aresetn) begin
    if (!axi.aresetn) begin
      wstate <= W_IDLE;
      rstate <= R_IDLE;

      w_id   <= '0; w_addr <= '0; w_len <= '0; w_size <= '0; w_burst <= '0; w_beat <= 0;
      r_id   <= '0; r_addr <= '0; r_len <= '0; r_size <= '0; r_burst <= '0; r_beat <= 0;
    end else begin
      // ----------------
      // WRITE FSM
      // ----------------
      unique case (wstate)
        W_IDLE: begin
          if (axi.awvalid && axi.awready) begin
            w_id    <= axi.awid;
            w_addr  <= axi.awaddr;
            w_len   <= axi.awlen;
            w_size  <= axi.awsize;
            w_burst <= axi.awburst;
            w_beat  <= 0;
            wstate  <= W_DATA;
          end
        end

        W_DATA: begin
          if (axi.wvalid && axi.wready) begin
            // write current beat
            mem_write_beat(next_addr(w_addr, w_beat, w_size), axi.wdata, axi.wstrb);

            // advance
            if (w_beat == w_len) begin
              // last beat expected
              wstate <= W_RESP;
            end else begin
              w_beat <= w_beat + 1;
            end
          end
        end

        W_RESP: begin
          if (axi.bready && axi.bvalid) begin
            wstate <= W_IDLE;
          end
        end
      endcase

      // ----------------
      // READ FSM
      // ----------------
      unique case (rstate)
        R_IDLE: begin
          if (axi.arvalid && axi.arready) begin
            r_id    <= axi.arid;
            r_addr  <= axi.araddr;
            r_len   <= axi.arlen;
            r_size  <= axi.arsize;
            r_burst <= axi.arburst;
            r_beat  <= 0;
            rstate  <= R_DATA;
          end
        end

        R_DATA: begin
          if (axi.rvalid && axi.rready) begin
            if (r_beat == r_len) begin
              rstate <= R_IDLE;
            end else begin
              r_beat <= r_beat + 1;
            end
          end
        end
      endcase
    end
  end

  // ----------------------------
  // Backdoor utilities (for TB)
  // ----------------------------
  task automatic bd_write_byte(input int unsigned addr, input byte val);
    if (addr < MEM_BYTES) mem[addr] = val;
  endtask

  task automatic bd_read_byte(input int unsigned addr, output byte val);
    if (addr < MEM_BYTES) val = mem[addr];
    else                  val = 8'h00;
  endtask

  task automatic bd_memset(input int unsigned addr, input int unsigned nbytes, input byte val);
    for (int unsigned i = 0; i < nbytes; i++) begin
      if ((addr+i) < MEM_BYTES) mem[addr+i] = val;
    end
  endtask

  task automatic bd_fill_inc(input int unsigned addr, input int unsigned nbytes, input byte seed);
    byte v = seed;
    for (int unsigned i = 0; i < nbytes; i++) begin
      if ((addr+i) < MEM_BYTES) mem[addr+i] = v;
      v++;
    end
  endtask

endmodule
