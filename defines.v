`ifndef CORE_DEFINES_V
`define CORE_DEFINES_V

`define MEMORY_SIZE 32'h0002_0000	// default size for simulation

`define MEMORY_ACCESS_SIZE 2

`define CORE_USE_CSR
//`define CORE_USE_IRQ
//`define CORE_USE_MULTIPLY


`ifdef CORE_USE_IRQ
	`ifndef CORE_USE_CSR
		`error_IRQ_requires_CSR
	`endif
`endif 

`endif
