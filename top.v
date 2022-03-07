`include "defines.v"

module top
	(
	input reset,
	input clock,
	
	output cpu_hlt,
	output sht_hlt,
	output sht_error,
	
	input [8:0] uart_data_in,
	output [8:0] uart_data_out
	);

	// core -- interconnect
	wire [31:0] tx_mem_addr;
	wire [`MEMORY_ACCESS_SIZE:0] tx_mem_size;
	wire tx_mem_enable;
	wire tx_mem_w_mode;
	wire [31:0] tx_mem_w_data;
	wire [31:0] tx_mem_r_data;
	wire tx_mem_ready;
	wire tx_mem_error;
	
	// interconnect -- memory
	wire [31:0] rx1_mem_addr;
	wire [`MEMORY_ACCESS_SIZE:0] rx1_mem_size;
	wire rx1_mem_enable;
	wire rx1_mem_w_mode;
	wire [31:0] rx1_mem_w_data;
	wire [31:0] rx1_mem_r_data;
	wire rx1_mem_done;
	wire rx1_mem_error;
	
	// interconnect -- shutdown
	wire [31:0] rx2_mem_addr;
	wire [`MEMORY_ACCESS_SIZE:0] rx2_mem_size;
	wire rx2_mem_enable;
	wire rx2_mem_w_mode;
	wire [31:0] rx2_mem_w_data;
	wire [31:0] rx2_mem_r_data;
	wire rx2_mem_done;
	wire rx2_mem_error;
	
	// interconnect -- uart
	wire [31:0] rx3_mem_addr;
	wire [`MEMORY_ACCESS_SIZE:0] rx3_mem_size;
	wire rx3_mem_enable;
	wire rx3_mem_w_mode;
	wire [31:0] rx3_mem_w_data;
	wire [31:0] rx3_mem_r_data;
	wire rx3_mem_done;
	wire rx3_mem_error;
	
	// interconnect -- clint
	wire [31:0] rx4_mem_addr;
	wire [`MEMORY_ACCESS_SIZE:0] rx4_mem_size;
	wire rx4_mem_enable;
	wire rx4_mem_w_mode;
	wire [31:0] rx4_mem_w_data;
	wire [31:0] rx4_mem_r_data;
	wire rx4_mem_done;
	wire rx4_mem_error;
	
	// interrupt stub
	wire [63:0] mtime;
	wire eip = 0;
	wire sip;
	wire tip;
	
	memory mem(
		.clock(clock),
		.reset(reset),
		
		.mem_addr(rx1_mem_addr),
		.mem_size(rx1_mem_size),
		.mem_enable(rx1_mem_enable),
		.mem_w_mode(rx1_mem_w_mode),
		.mem_w_data(rx1_mem_w_data),
		.mem_r_data(rx1_mem_r_data),
		.mem_error(rx1_mem_error),
		.mem_done(rx1_mem_done)
	);
	
	shutdown sht(
		.clock(clock),
		.reset(reset),
		
		.mem_addr(rx2_mem_addr),
		.mem_size(rx2_mem_size),
		.mem_enable(rx2_mem_enable),
		.mem_w_mode(rx2_mem_w_mode),
		.mem_w_data(rx2_mem_w_data),
		.mem_r_data(rx2_mem_r_data),
		.mem_error(rx2_mem_error),
		.mem_done(rx2_mem_done),
		
		.hlt(sht_hlt),
		.hlt_error(sht_error)
	);
	
	uart urt(
		.clock(clock),
		.reset(reset),
		
		.mem_addr(rx3_mem_addr),
		.mem_size(rx3_mem_size),
		.mem_enable(rx3_mem_enable),
		.mem_w_mode(rx3_mem_w_mode),
		.mem_w_data(rx3_mem_w_data),
		.mem_r_data(rx3_mem_r_data),
		.mem_error(rx3_mem_error),
		.mem_done(rx3_mem_done),
		
		.data_in(uart_data_in),
		.data_out(uart_data_out)
	);
	
	clint clnt(
		.clock(clock),
		.reset(reset),
		
		.mem_addr(rx4_mem_addr),
		.mem_size(rx4_mem_size),
		.mem_enable(rx4_mem_enable),
		.mem_w_mode(rx4_mem_w_mode),
		.mem_w_data(rx4_mem_w_data),
		.mem_r_data(rx4_mem_r_data),
		.mem_error(rx4_mem_error),
		.mem_done(rx4_mem_done),
		
		.mtime(mtime),
		.tip(tip),
		.sip(sip)
	);
	
	core cpu(
		.clock(clock),
		.reset(reset),
		
		.mem_addr(tx_mem_addr),
		.mem_size(tx_mem_size),
		.mem_enable(tx_mem_enable),
		.mem_w_mode(tx_mem_w_mode),
		.mem_w_data(tx_mem_w_data),
		.mem_r_data(tx_mem_r_data),
		.mem_error(tx_mem_error),
		.mem_ready(tx_mem_ready),
		
		.mtime(mtime),
		.eip(eip),
		.sip(sip),
		.tip(tip),
		
		.hlt(cpu_hlt)
	);
	
	interconnect router(
		.clock(clock),
		.reset(reset),
		
		.tx_mem_addr(tx_mem_addr),
		.tx_mem_size(tx_mem_size),
		.tx_mem_enable(tx_mem_enable),
		.tx_mem_w_mode(tx_mem_w_mode),
		.tx_mem_w_data(tx_mem_w_data),
		.tx_mem_r_data(tx_mem_r_data),
		.tx_mem_error(tx_mem_error),
		.tx_mem_ready(tx_mem_ready),
		
		.rx1_mem_addr(rx1_mem_addr),
		.rx1_mem_size(rx1_mem_size),
		.rx1_mem_enable(rx1_mem_enable),
		.rx1_mem_w_mode(rx1_mem_w_mode),
		.rx1_mem_w_data(rx1_mem_w_data),
		.rx1_mem_r_data(rx1_mem_r_data),
		.rx1_mem_error(rx1_mem_error),
		.rx1_mem_done(rx1_mem_done),
		
		.rx2_mem_addr(rx2_mem_addr),
		.rx2_mem_size(rx2_mem_size),
		.rx2_mem_enable(rx2_mem_enable),
		.rx2_mem_w_mode(rx2_mem_w_mode),
		.rx2_mem_w_data(rx2_mem_w_data),
		.rx2_mem_r_data(rx2_mem_r_data),
		.rx2_mem_error(rx2_mem_error),
		.rx2_mem_done(rx2_mem_done),
		
		.rx3_mem_addr(rx3_mem_addr),
		.rx3_mem_size(rx3_mem_size),
		.rx3_mem_enable(rx3_mem_enable),
		.rx3_mem_w_mode(rx3_mem_w_mode),
		.rx3_mem_w_data(rx3_mem_w_data),
		.rx3_mem_r_data(rx3_mem_r_data),
		.rx3_mem_error(rx3_mem_error),
		.rx3_mem_done(rx3_mem_done),
		
		.rx4_mem_addr(rx4_mem_addr),
		.rx4_mem_size(rx4_mem_size),
		.rx4_mem_enable(rx4_mem_enable),
		.rx4_mem_w_mode(rx4_mem_w_mode),
		.rx4_mem_w_data(rx4_mem_w_data),
		.rx4_mem_r_data(rx4_mem_r_data),
		.rx4_mem_error(rx4_mem_error),
		.rx4_mem_done(rx4_mem_done)
	);
endmodule
