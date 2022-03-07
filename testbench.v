`include "defines.v"

module testbench;
	reg clock;
	reg reset;

	wire cpu_hlt;
	wire sht_hlt;
	wire sht_error;
	
	reg [8:0] uart_data_in;
	wire [8:0] uart_data_out;

	top tp(
		.clock(clock),
		.reset(reset),
		
		.cpu_hlt(cpu_hlt),
		.sht_hlt(sht_hlt),
		.sht_error(sht_error),
		
		.uart_data_in(uart_data_in),
		.uart_data_out(uart_data_out)
	);

	wire [31:0] x0 = tp.cpu.regs[0];
	wire [31:0] x1 = tp.cpu.regs[1];
	wire [31:0] x2 = tp.cpu.regs[2];
	wire [31:0] x3 = tp.cpu.regs[3];
	wire [31:0] x4 = tp.cpu.regs[4];
	wire [31:0] x5 = tp.cpu.regs[5];
	wire [31:0] x6 = tp.cpu.regs[6];
	wire [31:0] x7 = tp.cpu.regs[7];
	wire [31:0] x8 = tp.cpu.regs[8];
	wire [31:0] x9 = tp.cpu.regs[9];
	wire [31:0] x10 = tp.cpu.regs[10];
	wire [31:0] x11 = tp.cpu.regs[11];
	wire [31:0] x12 = tp.cpu.regs[12];
	wire [31:0] x13 = tp.cpu.regs[13];
	wire [31:0] x14 = tp.cpu.regs[14];
	wire [31:0] x15 = tp.cpu.regs[15];
	wire [31:0] x16 = tp.cpu.regs[16];
	wire [31:0] x17 = tp.cpu.regs[17];
	wire [31:0] x18 = tp.cpu.regs[18];
	wire [31:0] x19 = tp.cpu.regs[19];
	wire [31:0] x20 = tp.cpu.regs[20];
	wire [31:0] x21 = tp.cpu.regs[21];
	wire [31:0] x22 = tp.cpu.regs[22];
	wire [31:0] x23 = tp.cpu.regs[23];
	wire [31:0] x24 = tp.cpu.regs[24];
	wire [31:0] x25 = tp.cpu.regs[25];
	wire [31:0] x26 = tp.cpu.regs[26];
	wire [31:0] x27 = tp.cpu.regs[27];
	wire [31:0] x28 = tp.cpu.regs[28];
	wire [31:0] x29 = tp.cpu.regs[29];
	wire [31:0] x30 = tp.cpu.regs[30];
	wire [31:0] x31 = tp.cpu.regs[31];
	
	initial begin
		$dumpfile("test.vcd");
    	$dumpvars(0, testbench);

		clock = 1;
		reset = 1;
		#5;
		reset = 0;
		clock = 0;
    	$readmemh("rom.hex", tp.mem.data, 0, `MEMORY_SIZE-1);
    	forever begin
	    	#5 clock = ~clock;
    	end
    end
    
    always @(posedge clock) begin
    	if (uart_data_out[8]) begin
	    	$write("%c", uart_data_out[7:0]);
    	end
    	uart_data_in[8] <= 1;
    	uart_data_in[7:0] <= $random % 255;
    end
    
    always @(posedge cpu_hlt or posedge sht_hlt or posedge sht_error) begin
    	#1;
    	
		$display("x0  = %d :: %h", $signed(tp.cpu.regs[0]), tp.cpu.regs[0]);
		$display("x1  = %d :: %h", $signed(tp.cpu.regs[1]), tp.cpu.regs[1]);
		$display("x2  = %d :: %h", $signed(tp.cpu.regs[2]), tp.cpu.regs[2]);
		$display("x3  = %d :: %h", $signed(tp.cpu.regs[3]), tp.cpu.regs[3]);
		$display("x4  = %d :: %h", $signed(tp.cpu.regs[4]), tp.cpu.regs[4]);
		$display("x5  = %d :: %h", $signed(tp.cpu.regs[5]), tp.cpu.regs[5]);
		$display("x6  = %d :: %h", $signed(tp.cpu.regs[6]), tp.cpu.regs[6]);
		$display("x7  = %d :: %h", $signed(tp.cpu.regs[7]), tp.cpu.regs[7]);
		$display("x8  = %d :: %h", $signed(tp.cpu.regs[8]), tp.cpu.regs[8]);
		$display("x9  = %d :: %h", $signed(tp.cpu.regs[9]), tp.cpu.regs[9]);
		$display("x10 = %d :: %h", $signed(tp.cpu.regs[10]), tp.cpu.regs[10]);
		$display("x11 = %d :: %h", $signed(tp.cpu.regs[11]), tp.cpu.regs[11]);
		$display("x12 = %d :: %h", $signed(tp.cpu.regs[12]), tp.cpu.regs[12]);
		$display("x13 = %d :: %h", $signed(tp.cpu.regs[13]), tp.cpu.regs[13]);
		$display("x14 = %d :: %h", $signed(tp.cpu.regs[14]), tp.cpu.regs[14]);
		$display("x15 = %d :: %h", $signed(tp.cpu.regs[15]), tp.cpu.regs[15]);
		$display("x16 = %d :: %h", $signed(tp.cpu.regs[16]), tp.cpu.regs[16]);
		$display("x17 = %d :: %h", $signed(tp.cpu.regs[17]), tp.cpu.regs[17]);
		$display("x18 = %d :: %h", $signed(tp.cpu.regs[18]), tp.cpu.regs[18]);
		$display("x19 = %d :: %h", $signed(tp.cpu.regs[19]), tp.cpu.regs[19]);
		$display("x20 = %d :: %h", $signed(tp.cpu.regs[20]), tp.cpu.regs[20]);
		$display("x21 = %d :: %h", $signed(tp.cpu.regs[21]), tp.cpu.regs[21]);
		$display("x22 = %d :: %h", $signed(tp.cpu.regs[22]), tp.cpu.regs[22]);
		$display("x23 = %d :: %h", $signed(tp.cpu.regs[23]), tp.cpu.regs[23]);
		$display("x24 = %d :: %h", $signed(tp.cpu.regs[24]), tp.cpu.regs[24]);
		$display("x25 = %d :: %h", $signed(tp.cpu.regs[25]), tp.cpu.regs[25]);
		$display("x26 = %d :: %h", $signed(tp.cpu.regs[26]), tp.cpu.regs[26]);
		$display("x27 = %d :: %h", $signed(tp.cpu.regs[27]), tp.cpu.regs[27]);
		$display("x28 = %d :: %h", $signed(tp.cpu.regs[28]), tp.cpu.regs[28]);
		$display("x29 = %d :: %h", $signed(tp.cpu.regs[29]), tp.cpu.regs[29]);
		$display("x30 = %d :: %h", $signed(tp.cpu.regs[30]), tp.cpu.regs[30]);
		$display("x31 = %d :: %h", $signed(tp.cpu.regs[31]), tp.cpu.regs[31]);
    	$display("pc  = %h", tp.cpu.pc);
    	
    	if (sht_error) begin
    		$display("-> error shutdown");
    	end else begin
    		if (cpu_hlt)
	    		$display("-> CPU shutdown (internal error or unhandled trap condition, e.g. memory error)");
	    	else
	    		$display("-> normal shutdown");
    	end
    	
    	$finish;
	end
endmodule
