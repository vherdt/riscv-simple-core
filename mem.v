`include "defines.v"

module memory
	(
		input reset,
		input clock,
		
		input [31:0] mem_addr,
		input [`MEMORY_ACCESS_SIZE:0] mem_size,
		input mem_enable,
		input mem_w_mode,
		input [31:0] mem_w_data,
		output reg [31:0] mem_r_data,
		output reg mem_done,
		output reg mem_error
	);
	
	reg[7:0] data[`MEMORY_SIZE-1:0];	// 8 KB
	integer i;
	wire[3:0] mask;
	
	assign mask[0] = 1;
	assign mask[1] = mem_size == 2 || mem_size == 4;
	assign mask[2] = mem_size == 4;
	assign mask[3] = mem_size == 4;
	
	always @(posedge clock) begin
		if (reset) begin
			mem_done <= 0;
			mem_error <= 0;
		end else begin
			if (mem_enable) begin
				if (mem_w_mode) begin
					if (mask[0])
						data[mem_addr    ] <= mem_w_data[7:0];
					if (mask[1])
						data[mem_addr + 1] <= mem_w_data[15:8];
					if (mask[2])
						data[mem_addr + 2] <= mem_w_data[23:16];
					if (mask[3])
						data[mem_addr + 3] <= mem_w_data[31:24];
				end else begin
					mem_r_data <= {
						mask[3] ? data[mem_addr+3] : 8'b0, 
						mask[2] ? data[mem_addr+2] : 8'b0, 
						mask[1] ? data[mem_addr+1] : 8'b0, 
						mask[0] ? data[mem_addr] : 8'b0
					};
				end
				mem_done <= 1;
			end else begin
				mem_done <= 0;
			end
		end
	end
endmodule


module shutdown
	(
		input reset,
		input clock,
		
		input [31:0] mem_addr,
		input [`MEMORY_ACCESS_SIZE:0] mem_size,
		input mem_enable,
		input mem_w_mode,
		input [31:0] mem_w_data,
		output reg [31:0] mem_r_data,
		output reg mem_done,
		output reg mem_error,
		
		output reg hlt,
		output reg hlt_error
	);
	
	always @(posedge clock) begin
		if (reset) begin
			mem_done <= 0;
			mem_error <= 0;
			hlt <= 0;
			hlt_error <= 0;
		end else begin
			if (mem_enable) begin
				if (mem_w_mode && (mem_addr == 0) && (mem_size == 4) && (mem_w_data == 93)) begin
					mem_error <= 0;
					hlt <= 1;
				end else if (mem_w_mode && (mem_addr == 4) && (mem_size == 4) && (mem_w_data == 93)) begin
					mem_error <= 0;
					hlt_error <= 1;
				end else begin
					mem_error <= 1;
				end
				mem_done <= 1;
			end
		end
	end
endmodule


module uart
	(
		input reset,
		input clock,
		
		input [31:0] mem_addr,
		input [`MEMORY_ACCESS_SIZE:0] mem_size,
		input mem_enable,
		input mem_w_mode,
		input [31:0] mem_w_data,
		output reg [31:0] mem_r_data,
		output reg mem_done,
		output reg mem_error,
		
		input [8:0] data_in,
		output reg [8:0] data_out
	);
	
	always @(posedge clock) begin
		if (reset) begin
			mem_done <= 0;
			mem_error <= 0;
			data_out <= 0;
		end else begin
			data_out[8] <= 0;
		
			if (mem_enable) begin
				mem_done <= 1;
				
				if (mem_w_mode) begin
					if (mem_addr == 0) begin
						data_out[8] <= 1;
						data_out[7:0] <= mem_w_data[7:0];
					end
				end else begin
					case (mem_addr)
						0: mem_r_data <= 0;
						4: begin
							if (data_in[8])
								mem_r_data <= data_in[7:0];
							else
								mem_r_data[31] <= 1;	// RX empty
						end
					endcase
				end
			end else begin
				mem_done <= 0;
			end
		end
	end
endmodule


module clint #(
		parameter SCALER = 32'd0000_0256
	)
	(
		input reset,
		input clock,
		
		input [31:0] mem_addr,
		input [`MEMORY_ACCESS_SIZE:0] mem_size,
		input mem_enable,
		input mem_w_mode,
		input [31:0] mem_w_data,
		output reg [31:0] mem_r_data,
		output reg mem_done,
		output reg mem_error,
		
		output reg [63:0] mtime,
		output tip,
		output reg sip
	);
	
	reg [63:0] mtimecmp;
	reg [31:0] cnt;
	
	assign tip = (mtimecmp != 0) && (mtime >= mtimecmp);
	
	always @(posedge clock) begin
		if (reset) begin
			mem_done <= 0;
			mem_error <= 0;
			mtime <= 0;
			mtimecmp <= 0;
			sip <= 0;
			cnt <= 0;
		end else begin
			if (cnt < SCALER) begin
				cnt <= cnt + 1;
			end else begin
				cnt <= 0;
				mtime <= mtime + 1;
			end
			
			if (mem_enable) begin
				if (mem_w_mode && (mem_addr == 0)) begin
					mem_error <= 0;
					sip <= mem_w_data[0];
				end else if (mem_w_mode && (mem_addr == 32'h4000) && (mem_size == 4)) begin
					mem_error <= 0;
					mtimecmp[31:0] <= mem_w_data;
//					$display("D: mtimecmp=%d", mtimecmp);
//					$display("D: new-data=%d", mem_w_data);
//					$display("D: mtime=%d", mtime);
//					$display("D: tip=%d", tip);
				end else if (mem_w_mode && (mem_addr == 32'h4004) && (mem_size == 4)) begin
					mem_error <= 0;
					mtimecmp[63:32] <= mem_w_data;
//					$display("T: mtimecmp=%d", mtimecmp);
//					$display("T: new-data=%d", mem_w_data);
//					$display("T: mtime=%d", mtime);
//					$display("T: tip=%d", tip);
				end else if (!mem_w_mode && (mem_addr == 0)) begin
					mem_error <= 0;
					mem_r_data <= {31'd0, sip};
				end else if (!mem_w_mode && (mem_addr == 32'h4000) && (mem_size == 4)) begin
					mem_error <= 0;
					mem_r_data <= mtimecmp[31:0];
				end else if (!mem_w_mode && (mem_addr == 32'h4004) && (mem_size == 4)) begin
					mem_error <= 0;
					mem_r_data <= mtimecmp[63:32];
				end else if (!mem_w_mode && (mem_addr == 32'hBFF8) && (mem_size == 4)) begin
					mem_error <= 0;
					mem_r_data <= mtime[31:0];
//					$display("> mtime[31:0]=%d", mtime[31:0]);
				end else if (!mem_w_mode && (mem_addr == 32'hBFFC) && (mem_size == 4)) begin
					mem_error <= 0;
					mem_r_data <= mtime[63:32];
//					$display("> mtime[63:32]=%d", mtime[63:32]);
				end else begin
					mem_error <= 1;
				end
				mem_done <= 1;
			end else begin
				mem_done <= 0;
			end
		end
	end
endmodule


module interconnect	#(
		parameter RX_1_START_ADDR = 32'h8000_0000,
		parameter RX_1_END_ADDR   = RX_1_START_ADDR + `MEMORY_SIZE,
		parameter RX_2_START_ADDR = 32'h0201_0000,
		parameter RX_2_END_ADDR   = 32'h0201_03ff,
		parameter RX_3_START_ADDR = 32'h1001_3000,
		parameter RX_3_END_ADDR   = 32'h1001_3fff,
		parameter RX_4_START_ADDR = 32'h0200_0000,
		parameter RX_4_END_ADDR   = 32'h0200_ffff
	)
	(
		input reset,
		input clock,
		
		// master (transmit -- tx)
		input [31:0] tx_mem_addr,			// access addr
		input [`MEMORY_ACCESS_SIZE:0] tx_mem_size,			// access size (1,2,4)
		input tx_mem_enable,				// enable access
		input tx_mem_w_mode,				// use write access (otherwise read access)
		input [31:0] tx_mem_w_data,			// write data
		output reg [31:0] tx_mem_r_data,	// read data
		output tx_mem_ready,				// memory is ready to use (i.e. last access completed)
		output reg tx_mem_error,			// something went wrong (e.g. missing access rights, unmapped address, etc.)
		
		// slave 1 (receive -- rx1)
		output reg [31:0] rx1_mem_addr,
		output reg [`MEMORY_ACCESS_SIZE:0] rx1_mem_size,
		output reg rx1_mem_enable,
		output reg rx1_mem_w_mode,
		output reg [31:0] rx1_mem_w_data,
		input [31:0] rx1_mem_r_data,
		input rx1_mem_done,					// memory access completed (since last enable)
		input rx1_mem_error,
		
		// slave 2 (receive -- rx2)
		output reg [31:0] rx2_mem_addr,
		output reg [`MEMORY_ACCESS_SIZE:0] rx2_mem_size,
		output reg rx2_mem_enable,
		output reg rx2_mem_w_mode,
		output reg [31:0] rx2_mem_w_data,
		input [31:0] rx2_mem_r_data,
		input rx2_mem_done,
		input rx2_mem_error,
		
		// slave 3 (receive -- rx3)
		output reg [31:0] rx3_mem_addr,
		output reg [`MEMORY_ACCESS_SIZE:0] rx3_mem_size,
		output reg rx3_mem_enable,
		output reg rx3_mem_w_mode,
		output reg [31:0] rx3_mem_w_data,
		input [31:0] rx3_mem_r_data,
		input rx3_mem_done,
		input rx3_mem_error,
		
		// slave 4 (receive -- rx4)
		output reg [31:0] rx4_mem_addr,
		output reg [`MEMORY_ACCESS_SIZE:0] rx4_mem_size,
		output reg rx4_mem_enable,
		output reg rx4_mem_w_mode,
		output reg [31:0] rx4_mem_w_data,
		input [31:0] rx4_mem_r_data,
		input rx4_mem_done,
		input rx4_mem_error
	);
	
	localparam READY = 0;
	localparam BUSY_1 = 1;
	localparam BUSY_2 = 2;
	localparam BUSY_3 = 3;
	localparam BUSY_4 = 4;
	
	reg [2:0] state;
	
	assign tx_mem_ready = state == READY && !tx_mem_enable;
	
	always @(posedge clock) begin
		if (reset) begin
			state <= READY;
			tx_mem_error <= 0;
			rx1_mem_enable <= 0;
			rx2_mem_enable <= 0;
			rx3_mem_enable <= 0;
			rx4_mem_enable <= 0;
		end else begin
			//NOTE: this code is dependent on the device timing. It expects that the device captures the respective *mem_enable* signal within one clock cycle.
			rx1_mem_enable <= 0;
			rx2_mem_enable <= 0;
			rx3_mem_enable <= 0;
			rx4_mem_enable <= 0;
					
			case (state)
				READY: begin
					if (tx_mem_enable) begin
						if (tx_mem_addr >= RX_1_START_ADDR && tx_mem_addr <= RX_1_END_ADDR) begin
							rx1_mem_addr <= tx_mem_addr - RX_1_START_ADDR;
							rx1_mem_size <= tx_mem_size;
							rx1_mem_enable <= 1;
							rx1_mem_w_mode <= tx_mem_w_mode;
							rx1_mem_w_data <= tx_mem_w_data;
							state <= BUSY_1;
						end else if (tx_mem_addr >= RX_2_START_ADDR && tx_mem_addr <= RX_2_END_ADDR) begin
							rx2_mem_addr <= tx_mem_addr - RX_2_START_ADDR;
							rx2_mem_size <= tx_mem_size;
							rx2_mem_enable <= 1;
							rx2_mem_w_mode <= tx_mem_w_mode;
							rx2_mem_w_data <= tx_mem_w_data;
							state <= BUSY_2;
						end else if (tx_mem_addr >= RX_3_START_ADDR && tx_mem_addr <= RX_3_END_ADDR) begin
							rx3_mem_addr <= tx_mem_addr - RX_3_START_ADDR;
							rx3_mem_size <= tx_mem_size;
							rx3_mem_enable <= 1;
							rx3_mem_w_mode <= tx_mem_w_mode;
							rx3_mem_w_data <= tx_mem_w_data;
							state <= BUSY_3;
						end else if (tx_mem_addr >= RX_4_START_ADDR && tx_mem_addr <= RX_4_END_ADDR) begin
							rx4_mem_addr <= tx_mem_addr - RX_4_START_ADDR;
							rx4_mem_size <= tx_mem_size;
							rx4_mem_enable <= 1;
							rx4_mem_w_mode <= tx_mem_w_mode;
							rx4_mem_w_data <= tx_mem_w_data;
							state <= BUSY_4;
						end else begin
							tx_mem_error <= 1;
						end
					end
				end
				BUSY_1: begin
					tx_mem_error <= rx1_mem_error;
					tx_mem_r_data <= rx1_mem_r_data;
					if (rx1_mem_done || rx1_mem_error)
						state <= READY;
				end
				BUSY_2: begin
					tx_mem_error <= rx2_mem_error;
					tx_mem_r_data <= rx2_mem_r_data;
					if (rx2_mem_done || rx2_mem_error)
						state <= READY;
				end
				BUSY_3: begin
					tx_mem_error <= rx3_mem_error;
					tx_mem_r_data <= rx3_mem_r_data;
					if (rx3_mem_done || rx3_mem_error)
						state <= READY;
				end
				BUSY_4: begin
					tx_mem_error <= rx4_mem_error;
					tx_mem_r_data <= rx4_mem_r_data;
					if (rx4_mem_done || rx4_mem_error)
						state <= READY;
				end
				default: begin
					tx_mem_error <= 1;
				end
			endcase
		end
	end
endmodule
