//============================================================
// Common typedef for register fields
//============================================================
typedef struct {
	string  name;
	int     size;
	int     lsb;
	string  access;   // "RW" / "RO" / "W"
} reg_field_t;


//============================================================
// Helper functions for building registers
//============================================================
function automatic uvm_reg build_reg
(
	uvm_reg_block parent,
	string        name,
	int unsigned  addr,
	reg_field_t   fields[] = '{},
	string        reg_access = "RW"     // overall access type
);
	uvm_reg r;

	r = uvm_reg::type_id::create(name);
	r.configure(parent, 4, UVM_NO_COVERAGE);
	r.build();  // REQUIRED

	foreach (fields[i]) begin
		r.add_field
		(
			.name(fields[i].name),
			.size(fields[i].size),
			.lsb_pos(fields[i].lsb),
			.access(fields[i].access)
		);
	end

	parent.default_map.add_reg(r, addr, reg_access);
	return r;
endfunction


//============================================================
// Shortcut wrappers
//============================================================
function automatic uvm_reg build_rw_reg
(
	uvm_reg_block parent, string n, int addr, reg_field_t fields[]
);
	return build_reg(parent, n, addr, fields, "RW");
endfunction

function automatic uvm_reg build_ro_reg
(
	uvm_reg_block parent, string n, int addr, reg_field_t fields[]
);
	return build_reg(parent, n, addr, fields, "R");
endfunction

function automatic uvm_reg build_wo_reg
(
	uvm_reg_block parent, string n, int addr, reg_field_t fields[]
);
	return build_reg(parent, n, addr, fields, "W");
endfunction

class dma_channel_reg_block extends uvm_reg_block;

	// Registers
	uvm_reg CMD_REG0;
	uvm_reg CMD_REG1;
	uvm_reg CMD_REG2;
	uvm_reg CMD_REG3;

	uvm_reg STATIC_REG0;
	uvm_reg STATIC_REG1;
	uvm_reg STATIC_REG2;
	uvm_reg STATIC_REG3;
	uvm_reg STATIC_REG4;

	uvm_reg RESTRICT_REG;
	uvm_reg READ_OFFSET_REG;
	uvm_reg WRITE_OFFSET_REG;
	uvm_reg FIFO_FULLNESS_REG;
	uvm_reg CMD_OUTS_REG;

	uvm_reg CH_ENABLE_REG;
	uvm_reg CH_START_REG;
	uvm_reg CH_ACTIVE_REG;
	uvm_reg COUNT_REG;

	uvm_reg INT_RAWSTAT_REG;
	uvm_reg INT_CLEAR_REG;
	uvm_reg INT_ENABLE_REG;
	uvm_reg INT_STATUS_REG;

	`uvm_object_utils(dma_channel_reg_block)

	function new(string name = "dma_channel_reg_block");
		super.new(name, UVM_NO_COVERAGE);
	endfunction


	//------------------------------------------------------------
	// BUILD FUNCTION
	//------------------------------------------------------------
	virtual function void build();

		default_map = create_map("chan_map", 'h0, 4, UVM_LITTLE_ENDIAN);

		//--------------------------------------------------------
		// CMD_REG0 0x00
		//--------------------------------------------------------
		CMD_REG0 = build_rw_reg(this, "CMD_REG0", 'h00,
			'{ '{ "RD_START_ADDR", 32, 0, "RW" } }
		);

		//--------------------------------------------------------
		// CMD_REG1 0x04
		//--------------------------------------------------------
		CMD_REG1 = build_rw_reg(this, "CMD_REG1", 'h04,
			'{ '{ "WR_START_ADDR", 32, 0, "RW" } }
		);

		//--------------------------------------------------------
		// CMD_REG2 0x08
		// Clean dual-mode representation:
		// - BUFFER_SIZE 16:0
		// - X_SIZE 8:16
		// - Y_SIZE 8:24
		//--------------------------------------------------------
		CMD_REG2 = build_rw_reg(this, "CMD_REG2", 'h08,
			'{
				'{ "BUFFER_SIZE", 16, 0,  "RW" },
				'{ "X_SIZE",       8, 16, "RW" },
				'{ "Y_SIZE",       8, 24, "RW" }
			}
		);

		//--------------------------------------------------------
		// CMD_REG3 0x0C
		//--------------------------------------------------------
		CMD_REG3 = build_rw_reg(this, "CMD_REG3", 'h0C,
			'{
				'{ "CMD_SET_INT",   1, 0, "RW" },
				'{ "CMD_LAST",      1, 1, "RW" },
				'{ "CMD_NEXT_ADDR",28, 4, "RW" }
			}
		);

		//--------------------------------------------------------
		// STATIC_REG0..4  0x10–0x20
		//--------------------------------------------------------
		STATIC_REG0 = build_rw_reg(this, "STATIC_REG0", 'h10,
			'{
				'{ "RD_BURST_MAX_SIZE", 10, 0,  "RW" },
				'{ "RD_TOKENS",          6, 16, "RW" },
				'{ "RD_OUTSTANDING",     1, 22, "RW" },
				'{ "RD_INCR",            1, 23, "RW" }
			}
		);

		STATIC_REG1 = build_rw_reg(this, "STATIC_REG1", 'h14,
			'{
				'{ "WR_BURST_MAX_SIZE", 10, 0,  "RW" },
				'{ "WR_TOKENS",          6, 16, "RW" },
				'{ "WR_OUTSTANDING",     1, 22, "RW" },
				'{ "WR_INCR",            1, 23, "RW" }
			}
		);

		STATIC_REG2 = build_rw_reg(this, "STATIC_REG2", 'h18,
			'{
				'{ "BLOCK",      1, 0,  "RW" },
				'{ "JOINT",      1, 1,  "RW" },
				'{ "AUTO_RETRY", 1, 2,  "RW" },
				'{ "RD_PORT_NUM",4, 8,  "RW" },
				'{ "WR_PORT_NUM",4, 12, "RW" },
				'{ "END_SWAP",   2, 28, "RW" }
			}
		);

		STATIC_REG3 = build_rw_reg(this, "STATIC_REG3", 'h1C,
			'{
				'{ "RD_WAIT_LIMIT",12, 0,  "RW" },
				'{ "WR_WAIT_LIMIT",12,16, "RW" }
			}
		);

		STATIC_REG4 = build_rw_reg(this, "STATIC_REG4", 'h20,
			'{
				'{ "RD_PERIPH_NUM",   5, 0,  "RW" },
				'{ "RD_PERIPH_BLOCK", 1, 5,  "RW" },
				'{ "WR_PERIPH_NUM",   5, 16, "RW" },
				'{ "WR_PERIPH_BLOCK", 1, 21, "RW" }
			}
		);

		//--------------------------------------------------------
		// READ-ONLY REGISTERS 0x2C–0x3C
		//--------------------------------------------------------
		RESTRICT_REG = build_ro_reg(this, "RESTRICT_REG", 'h2C,
			'{
				'{ "ALLOW_FULL_FIFO",    1, 0, "RO" },
				'{ "ALLOW_JOINT_BURST",  1, 1, "RO" },
				'{ "RD_OUTSTANDING_STAT",1, 2, "RO" },
				'{ "WR_OUTSTANDING_STAT",1, 3, "RO" }
			}
		);

		READ_OFFSET_REG = build_ro_reg(this, "READ_OFFSET_REG", 'h30,
			'{
				'{ "RD_OFFSET",  16, 0,  "RO" },
				'{ "RD_X_OFFSET", 8, 16, "RO" },
				'{ "RD_Y_OFFSET", 8, 24, "RO" }
			}
		);

		WRITE_OFFSET_REG = build_ro_reg(this, "WRITE_OFFSET_REG", 'h34,
			'{
				'{ "WR_OFFSET",16,0, "RO" }
			}
		);

		FIFO_FULLNESS_REG = build_ro_reg(this, "FIFO_FULLNESS_REG", 'h38,
			'{
				'{ "RD_GAP",      10, 0,  "RO" },
				'{ "WR_FULLNESS",10, 16, "RO" }
			}
		);

		CMD_OUTS_REG = build_ro_reg(this, "CMD_OUTS_REG", 'h3C,
			'{
				'{ "RD_CMD_OUTS", 6, 0, "RO" },
				'{ "WR_CMD_OUTS", 6, 8, "RO" }
			}
		);

		//--------------------------------------------------------
		// CH_ENABLE / START / ACTIVE
		//--------------------------------------------------------
		CH_ENABLE_REG = build_rw_reg(this, "CH_ENABLE_REG", 'h40,
			'{
				'{ "CH_ENABLE",1,0,"RW" }
			}
		);

		CH_START_REG = build_wo_reg(this, "CH_START_REG", 'h44,
			'{
				'{ "CH_START",1,0,"W" }
			}
		);

		CH_ACTIVE_REG = build_ro_reg(this, "CH_ACTIVE_REG", 'h48,
			'{
				'{ "CH_RD_ACTIVE",1,0,"RO" },
				'{ "CH_WR_ACTIVE",1,1,"RO" }
			}
		);

		COUNT_REG = build_ro_reg(this, "COUNT_REG", 'h50,
			'{
				'{ "BUFF_COUNT",16,0,"RO" },
				'{ "INT_COUNT", 6,16,"RO" }
			}
		);

		//--------------------------------------------------------
		// INTERRUPT REGISTERS 0xA0–0xAC
		//--------------------------------------------------------
		INT_RAWSTAT_REG = build_rw_reg(this, "INT_RAWSTAT_REG", 'hA0,
			'{
				'{ "INT_CH_END",        1, 0,  "RW" },
				'{ "INT_RD_DECERR",     1, 1,  "RW" },
				'{ "INT_RD_SLVERR",     1, 2,  "RW" },
				'{ "INT_RD_OK",         1, 3,  "RW" },
				'{ "INT_RD_LAST",       1, 4,  "RW" },
				'{ "INT_WR_DECERR",     1, 5,  "RW" },
				'{ "INT_WR_SLVERR",     1, 6,  "RW" },
				'{ "INT_WR_OK",         1, 7,  "RW" },
				'{ "INT_WR_LAST",       1, 8,  "RW" },
				'{ "INT_TIMEOUT",       1, 9,  "RW" },
				'{ "INT_RETRY_FAIL",    1,10, "RW" },
				'{ "INT_PERIPH_ERR",    1,11, "RW" }
			}
		);

		INT_CLEAR_REG = build_wo_reg(this, "INT_CLEAR_REG", 'hA4,
			'{
				'{ "INT_CLEAR_BITS",12,0,"W" }
			}
		);

		INT_ENABLE_REG = build_rw_reg(this, "INT_ENABLE_REG", 'hA8,
			'{
				'{ "INT_EN_BITS",12,0,"RW" }
			}
		);

		INT_STATUS_REG = build_ro_reg(this, "INT_STATUS_REG", 'hAC,
			'{
				'{ "INT_STATUS_BITS",12,0,"RO" }
			}
		);

	endfunction : build

endclass : dma_channel_reg_block


//============================================================
// CORE REGISTER BLOCK  (8 channels + shared registers)
//============================================================
class dma_core_reg_block extends uvm_reg_block;

	//--------------------------------------------------------
	// Parameters
	//--------------------------------------------------------
	localparam int NUM_CHANNELS       = 8;
	localparam int CHANNEL_OFFSET     = 'h100;   // 256 bytes
	localparam int SHARED_BASE_OFFSET = 'h1000;  // After channel spaces

	// core_id is provided by constructor
	int core_id;

	//--------------------------------------------------------
	// Per-channel register blocks
	//--------------------------------------------------------
	dma_channel_reg_block channel[NUM_CHANNELS];

	//--------------------------------------------------------
	// Shared registers
	//--------------------------------------------------------
	uvm_reg INT_STATUS[8];          // INT0_STATUS..INT7_STATUS

	uvm_reg CORE_JOINT_MODE;
	uvm_reg CORE_PRIORITY;
	uvm_reg CORE_CLKDIV;
	uvm_reg CORE_CH_START;

	uvm_reg PERIPH_RX_CTRL;
	uvm_reg PERIPH_TX_CTRL;

	uvm_reg IDLE;
	uvm_reg USER_DEF_STATUS;
	uvm_reg USER_CORE_DEF_STATUS1;

	`uvm_object_utils(dma_core_reg_block)


	//--------------------------------------------------------
	// Constructor
	//--------------------------------------------------------
	function new(string name="dma_core_reg_block", int id=0);
		super.new(name, UVM_NO_COVERAGE);
		core_id = id;
	endfunction


	//--------------------------------------------------------
	// BUILD
	//--------------------------------------------------------
	virtual function void build();

		// Core map base: 0x0000 for core0, 0x0800 for core1
		default_map = create_map($sformatf("core%0d_map", core_id),
		                         core_id == 0 ? 32'h0000 : 32'h0800,
		                         4, UVM_LITTLE_ENDIAN);

		//====================================================
		// CHANNEL SUBMAPS  (8 channels)
		//====================================================
		for (int ch = 0; ch < NUM_CHANNELS; ch++) begin

			string nm = $sformatf("channel%0d", ch);

			channel[ch] = dma_channel_reg_block::type_id::create(nm);
			channel[ch].configure(this);
			channel[ch].build();

			// Add submap @ base + ch * CHANNEL_OFFSET
			default_map.add_submap(
				channel[ch].default_map,
				default_map.get_base_addr() + ch * CHANNEL_OFFSET
			);
		end


		//====================================================
		// SHARED INTERRUPT REGISTERS 0x1000 + core offset
		//
		// Each INTx_STATUS register holds:
		//  bit[0]   CORE0_CH0_INTx_STAT
		//  ...
		//  bit[7]   CORE0_CH7_INTx_STAT
		//  bit[8]   CORE1_CH0_INTx_STAT
		//  ...
		//  bit[15]  CORE1_CH7_INTx_STAT
		//
		// This matches a 2-core system (16 channels).
		//====================================================
		for (int i = 0; i < 8; i++) begin

			reg_field_t fields[$];

			// 8 bits for this core channels
			for (int ch = 0; ch < 8; ch++) begin
				fields.push_back(
					'{
						$psprintf("CORE%0d_CH%0d_INT%0d", core_id, ch, i),
						1,
						ch,
						"RO"
					}
				);
			end

			// 8 bits for the OTHER core channels
			int other_core = (core_id == 0) ? 1 : 0;
			for (int ch = 0; ch < 8; ch++) begin
				fields.push_back(
					'{
						$psprintf("CORE%0d_CH%0d_INT%0d", other_core, ch, i),
						1,
						8 + ch,
						"RO"
					}
				);
			end

			INT_STATUS[i] = build_ro_reg(
				this,
				$psprintf("INT%0d_STATUS", i),
				SHARED_BASE_OFFSET + i * 4,
				fields
			);
		end


		//====================================================
		// CORE_JOINT_MODE   (RW)
		//====================================================
		CORE_JOINT_MODE = build_rw_reg(this, "CORE_JOINT_MODE",
			32'h1030 + core_id*4,
			'{
				'{ "JOINT_MODE", 1, 0, "RW" }
			}
		);


		//====================================================
		// CORE_PRIORITY  (RW, 32-bit raw)
		//====================================================
		CORE_PRIORITY = build_rw_reg(this, "CORE_PRIORITY",
			32'h1038 + core_id*4,
			'{}
		);


		//====================================================
		// CORE_CLKDIV
		//====================================================
		CORE_CLKDIV = build_rw_reg(this, "CORE_CLKDIV",
			32'h1040 + core_id*4,
			'{
				'{ "CLKDIV_RATIO", 4, 0, "RW" }
			}
		);


		//====================================================
		// CORE_CH_START  (Write-only, 8 bit field)
		//====================================================
		CORE_CH_START = build_wo_reg(this, "CORE_CH_START",
			32'h1048 + core_id*4,
			'{
				'{ "CHANNEL_START", 8, 0, "W" }
			}
		);


		//====================================================
		// PERIPH_RX_CTRL / PERIPH_TX_CTRL
		//====================================================
		PERIPH_RX_CTRL = build_rw_reg(this, "PERIPH_RX_CTRL",
			32'h1050,
			'{}
		);

		PERIPH_TX_CTRL = build_rw_reg(this, "PERIPH_TX_CTRL",
			32'h1054,
			'{}
		);


		//====================================================
		// IDLE register  (RO)
		//====================================================
		IDLE = build_ro_reg(this, "IDLE", 32'h10D0, '{});


		//====================================================
		// USER-DEFINED STATUS
		//====================================================
		USER_DEF_STATUS = build_ro_reg(this, "USER_DEF_STATUS",
			32'h10E0, '{}
		);

		USER_CORE_DEF_STATUS1 = build_ro_reg(this, "USER_CORE_DEF_STATUS1",
			32'h10F4, '{}
		);

	endfunction : build

endclass : dma_core_reg_block


//============================================================
// TOP REGISTER BLOCK  (2 cores)
//============================================================
class dma_top_reg_block extends uvm_reg_block;

	//--------------------------------------------------------
	// Parameters
	//--------------------------------------------------------
	localparam int NUM_CORES = 2;

	// Core base offsets
	localparam int CORE_OFFSET[NUM_CORES] = '{32'h0000, 32'h0800};

	//--------------------------------------------------------
	// Core register blocks
	//--------------------------------------------------------
	dma_core_reg_block core[NUM_CORES];

	`uvm_object_utils(dma_top_reg_block)


	//--------------------------------------------------------
	// Constructor
	//--------------------------------------------------------
	function new(string name = "dma_top_reg_block");
		super.new(name, UVM_NO_COVERAGE);
	endfunction


	//--------------------------------------------------------
	// BUILD
	//--------------------------------------------------------
	virtual function void build();

		//----------------------------------------------------
		// Create top-level map
		//----------------------------------------------------
		default_map = create_map("dma_top_map", 0, 4, UVM_LITTLE_ENDIAN);

		//----------------------------------------------------
		// Build 2 cores
		//----------------------------------------------------
		for (int c = 0; c < NUM_CORES; c++) begin

			// Create core block with core_id
			core[c] = dma_core_reg_block::type_id::create(
				$sformatf("core%0d", c),
				/* core_id */ c
			);

			core[c].configure(this);
			core[c].build();

			// Add core submap at proper offset
			default_map.add_submap(
				core[c].default_map,
				CORE_OFFSET[c]
			);
		end

	endfunction : build

endclass : dma_top_reg_block;
