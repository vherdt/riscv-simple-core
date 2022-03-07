`include "defines.v"

`define OPCODE_UNDEF 0
`define OPCODE_LUI 1
`define OPCODE_AUIPC 2
`define OPCODE_JAL 3
`define OPCODE_JALR 4
`define OPCODE_BEQ 5
`define OPCODE_BNE 6
`define OPCODE_BLT 7
`define OPCODE_BGE 8
`define OPCODE_BLTU 9
`define OPCODE_BGEU 10
`define OPCODE_LB 11
`define OPCODE_LH 12
`define OPCODE_LW 13
`define OPCODE_LBU 14
`define OPCODE_LHU 15
`define OPCODE_SB 16
`define OPCODE_SH 17
`define OPCODE_SW 18
`define OPCODE_ADDI 19
`define OPCODE_SLTI 20
`define OPCODE_SLTIU 21
`define OPCODE_XORI 22
`define OPCODE_ORI 23
`define OPCODE_ANDI 24
`define OPCODE_SLLI 25
`define OPCODE_SRLI 26
`define OPCODE_SRAI 27
`define OPCODE_ADD 28
`define OPCODE_SUB 29
`define OPCODE_SLL 30
`define OPCODE_SLT 31
`define OPCODE_SLTU 32
`define OPCODE_XOR 33
`define OPCODE_SRL 34
`define OPCODE_SRA 35
`define OPCODE_OR 36
`define OPCODE_AND 37
`define OPCODE_FENCE 38
`define OPCODE_FENCE_I 39
`define OPCODE_ECALL 40
`define OPCODE_EBREAK 41
`define OPCODE_CSRRW 42
`define OPCODE_CSRRS 43
`define OPCODE_CSRRC 44
`define OPCODE_CSRRWI 45
`define OPCODE_CSRRSI 46
`define OPCODE_CSRRCI 47
`define OPCODE_MRET 48
`define OPCODE_WFI 49

`define OPCODE_MUL 50
`define OPCODE_MULH 51
`define OPCODE_MULHSU 52
`define OPCODE_MULHU 53
`define OPCODE_DIV 54
`define OPCODE_DIVU 55
`define OPCODE_REM 56
`define OPCODE_REMU 57


// 64 bit timer csrs
`define CYCLE_ADDR 12'hC00
`define CYCLEH_ADDR 12'hC80
`define TIME_ADDR 12'hC01
`define TIMEH_ADDR 12'hC81
`define INSTRET_ADDR 12'hC02
`define INSTRETH_ADDR 12'hC82

// shadows for the above CSRs
`define MCYCLE_ADDR 12'hB00
`define MCYCLEH_ADDR 12'hB80
`define MTIME_ADDR 12'hB01
`define MTIMEH_ADDR 12'hB81
`define MINSTRET_ADDR 12'hB02
`define MINSTRETH_ADDR 12'hB82

// 32 bit machine CSRs
`define MVENDORID_ADDR 12'hF11
`define MARCHID_ADDR 12'hF12
`define MIMPID_ADDR 12'hF13
`define MHARTID_ADDR 12'hF14

`define MSTATUS_ADDR 12'h300
`define MISA_ADDR 12'h301
`define MEDELEG_ADDR 12'h302
`define MIDELEG_ADDR 12'h303
`define MIE_ADDR 12'h304
`define MTVEC_ADDR 12'h305
`define MCOUNTEREN_ADDR 12'h306
`define MCOUNTINHIBIT_ADDR 12'h320

`define MSCRATCH_ADDR 12'h340
`define MEPC_ADDR 12'h341
`define MCAUSE_ADDR 12'h342
`define MTVAL_ADDR 12'h343
`define MIP_ADDR 12'h344


`define CORE_STATE_FETCH 0
`define CORE_STATE_DECODE 1
`define CORE_STATE_WAIT_LOAD_OPERANDS 2
`define CORE_STATE_EXECUTE 3
`define CORE_STATE_CSR 4
`define CORE_STATE_TRAP 5
`define CORE_STATE_CHECK_IRQ 6
`define CORE_STATE_IRQ 7


`define EXC_U_SOFTWARE_INTERRUPT 0
`define EXC_S_SOFTWARE_INTERRUPT 1
`define EXC_M_SOFTWARE_INTERRUPT 3
`define EXC_U_TIMER_INTERRUPT 4
`define EXC_S_TIMER_INTERRUPT 5
`define EXC_M_TIMER_INTERRUPT 7
`define EXC_U_EXTERNAL_INTERRUPT 8
`define EXC_S_EXTERNAL_INTERRUPT 9
`define EXC_M_EXTERNAL_INTERRUPT 11

`define EXC_INSTR_ADDR_MISALIGNED 31'd0
`define EXC_INSTR_ACCESS_FAULT 31'd1
`define EXC_ILLEGAL_INSTR 31'd2
`define EXC_BREAKPOINT 31'd3
`define EXC_LOAD_ADDR_MISALIGNED 31'd4
`define EXC_LOAD_ACCESS_FAULT 31'd5
`define EXC_STORE_AMO_ADDR_MISALIGNED 31'd6
`define EXC_STORE_AMO_ACCESS_FAULT 31'd7
`define EXC_ECALL_U_MODE 31'd8
`define EXC_ECALL_S_MODE 31'd9
`define EXC_ECALL_M_MODE 31'd11
`define EXC_INSTR_PAGE_FAULT 31'd12
`define EXC_LOAD_PAGE_FAULT 31'd13
`define EXC_STORE_AMO_PAGE_FAULT 31'd15


`define MSTATUS_MIE 3
`define MSTATUS_MPIE 7

`define MSTATUS_WRITE_MASK 32'b00000000000000000000000010001000
`define MSTATUS_READ_MASK  32'b00000000000000000001100010001000

`define MIE_WRITE_MASK 32'b00000000000000000000100010001000
`define MIE_READ_MASK  `MIE_WRITE_MASK

`define MIP_WRITE_MASK `MIE_WRITE_MASK
`define MIP_READ_MASK  `MIP_WRITE_MASK


module core
	(
		input reset,
		input clock,
		/* memory interface */
		output reg [31:0] mem_addr,
		output reg [`MEMORY_ACCESS_SIZE:0] mem_size,
		output reg mem_enable,
		output reg mem_w_mode,
		output reg [31:0] mem_w_data,
		input [31:0] mem_r_data,
		input mem_ready,
		input mem_error,
		/* clint & interrupt interface */
		input [63:0] mtime,
		input sip,	// SW interrupt pending
		input tip,	// timer interrupt pending
		input eip,	// external interrupt pending
		/* debug/misc */
		output hlt
	);
	
	reg[31:0] regs[31:0];
	reg[31:0] last_pc;
	reg[31:0] pc;
	// state reencoding forbidden
	(* fsm_encoding="none" *) reg[2:0] state;
	reg[31:0] instr;
	reg[5:0] opcode;
	reg[1:0] prv;
	reg error;
	integer i;
	
	reg[30:0] trap_code;
	reg[31:0] trap_value;

`ifdef CORE_USE_CSR
	/* begin CSRs */
	reg[31:0] mvendorid;
	reg[31:0] marchid;
	reg[31:0] mimpid;
	reg[31:0] mhartid;
	
	reg[31:0] misa;
	
	reg[31:0] mcause;
	reg[31:0] mtval;
	reg[31:0] mtvec;
	reg[31:0] mepc;
	
	reg[31:0] mstatus;
	reg[31:0] mip;
	reg[31:0] mie;
	
	reg[63:0] minstret;
	reg[63:0] mcycle;
	/* end CSRs */
`endif
	
	localparam x0 = 0;
	localparam REG_MIN = 32'h8000_0000;
	localparam REG_MAX = 32'h7fff_ffff;
	
	function signed [31:0] J_imm;
		input reg[31:0] instr;
		begin
			J_imm = $signed({instr[31], instr[19:12], instr[20], instr[30:21], 1'b0});
		end
	endfunction
	
	function signed [31:0] B_imm;
		input reg[31:0] instr;
		begin
			B_imm = $signed({instr[31], instr[7], instr[30:25], instr[11:8], 1'b0});
		end
	endfunction
	
	function signed [31:0] I_imm;
		input reg[31:0] instr;
		begin
			I_imm = $signed(instr[31:20]);
		end
	endfunction
	
	function signed [31:0] S_imm;
		input reg[31:0] instr;
		begin
			S_imm = $signed({instr[31:25], instr[11:7]});
		end
	endfunction
	
	function [31:0] U_imm;
		input reg[31:0] instr;
		begin
			U_imm = {instr[31:12], 12'b0000_0000_0000};
		end
	endfunction
	
	function [4:0] shamt;
		input reg[31:0] instr;
		begin
			shamt = instr[24:20];
		end
	endfunction
	
`ifdef CORE_USE_CSR
	function [11:0] csr;
		input reg[31:0] instr;
		begin
			csr = instr[31:20];
		end
	endfunction
	
	function [4:0] csr_uimm;
		input reg[31:0] instr;
		begin
			csr_uimm = instr[19:15];
		end
	endfunction
`endif
	
	function [4:0] RD;
		input reg[31:0] instr;
		begin
			RD = instr[11:7];
		end
	endfunction
	
	function [4:0] RS1;
		input reg[31:0] instr;
		begin
			RS1 = instr[19:15];
		end
	endfunction
	
	function [4:0] RS2;
		input reg[31:0] instr;
		begin
			RS2 = instr[24:20];
		end
	endfunction
	
	function [31:0] sign_extend_16_to_32;
		input reg[15:0] data;
		begin
			sign_extend_16_to_32 = $signed(data);
		end
	endfunction
	
	function [31:0] sign_extend_8_to_32;
		input reg[7:0] data;
		begin
			sign_extend_8_to_32 = $signed(data);
		end
	endfunction
	
	function signed [63:0] s64;
		input [31:0] arg;
		begin
			s64 = $signed(arg);
		end
	endfunction
	
	function [63:0] u64;
		input [31:0] arg;
		begin
			u64 = arg;
		end
	endfunction
	
	
`ifdef CORE_USE_CSR
	task do_csr_reset;
		begin
			mvendorid <= 0;
			marchid <= 0;
			mimpid <= 0;
			mhartid <= 0;
			
			mcause <= 0;
			mtval <= 0;
			mtvec <= 0;
			mepc <= 0;
			
			misa[31:30] <= 1;
`ifdef CORE_USE_MULTIPLY
			misa[29:0]  <= (1 << 8) | (1 << 12);
`else
			misa[29:0]  <= (1 << 8);
`endif

			mstatus <= 3 << 11;
			mip <= 0;
			mie <= 0;

`ifdef CORE_USE_CSR
			minstret <= 0;
			mcycle <= 0;
`endif
		end
	endtask
	
	function csr_is_invalid_access;
		input reg[11:0] addr;
		input reg is_write;
		reg [1:0] csr_prv;
		reg csr_readonly;
		begin
			csr_prv = (12'h300 & addr) >> 8;
			csr_readonly = ((12'hC00 & addr) >> 10) == 2'b11;
			csr_is_invalid_access = (is_write && csr_readonly) || (prv < csr_prv);
		end
	endfunction
	
	function [31:0] get_write_value;
		input reg[31:0] old_value;
		input reg[31:0] write_mask;
		input reg[31:0] new_value;
		begin
			get_write_value = (old_value & ~write_mask) | (new_value & write_mask);
		end
	endfunction
	
	task csr_write;
		input reg[11:0] addr;
		input reg[31:0] value;
		begin
			case (addr)
				`MCAUSE_ADDR: begin
					mcause <= value;
				end
				`MEPC_ADDR: begin
					mepc <= value;
				end
				`MTVEC_ADDR: begin
					mtvec <= value;
					mtvec[1:0] <= 0;
				end
				`MTVAL_ADDR: begin
					mtval <= value;
				end
				`MISA_ADDR: begin
					// NOTE: just keep old value
				end
				`MSTATUS_ADDR: begin
					mstatus <= get_write_value(mstatus, `MSTATUS_WRITE_MASK, value);
				end
				`MIE_ADDR: begin
					mie <= get_write_value(mie, `MIE_WRITE_MASK, value);
				end
				`MIP_ADDR: begin
					mip <= get_write_value(mip, `MIP_WRITE_MASK, value);
				end
				default: begin
					illegal_instruction();
				end
			endcase
		end
	endtask
	
	task csr_read;
		input [11:0] addr;
		output [31:0] ans;
		begin
			case (addr)
				`MCAUSE_ADDR: begin
					ans = mcause;
				end
				`MEPC_ADDR: begin
					ans = mepc;
				end
				`MTVEC_ADDR: begin
					ans = mtvec;
				end
				`MTVAL_ADDR: begin
					ans = mtval;
				end
				`MISA_ADDR: begin
					ans = misa;
				end
				`MHARTID_ADDR: begin
					ans = mhartid;
				end
				`MVENDORID_ADDR: begin
					ans = mvendorid;
				end
				`MIMPID_ADDR: begin
					ans = mimpid;
				end
				`MARCHID_ADDR: begin
					ans = marchid;
				end
				
				`MSTATUS_ADDR: begin
					ans = mstatus & `MSTATUS_READ_MASK;
				end
				`MIE_ADDR: begin
					ans = mie & `MIE_WRITE_MASK;
				end
				`MIP_ADDR: begin
					ans = mip & `MIP_WRITE_MASK;
				end
				
				`MCYCLE_ADDR: begin
					ans = mcycle[31:0];
				end
				`MCYCLEH_ADDR: begin
					ans = mcycle[63:32];
				end
				`MTIME_ADDR: begin
					ans = mtime[31:0];
				end
				`MTIMEH_ADDR: begin
					ans = mtime[63:32];
				end
				`MINSTRET_ADDR: begin
					ans = minstret[31:0];
				end
				`MINSTRETH_ADDR: begin
					ans = minstret[63:32];
				end
				
				default: begin
					illegal_instruction();
					ans = 32'h0000_0000;
				end
			endcase
		end
	endtask
`endif
	
	task do_reset;
		begin
			error <= 0;
			state <= `CORE_STATE_FETCH;
			pc <= 32'h8000_0000;
			prv <= 2'b11;
			mem_enable <= 0;
			for (i=0; i<32; i=i+1) begin
				regs[i] <= 0;
			end
`ifdef CORE_USE_CSR
			do_csr_reset();
`endif
		end
	endtask
	
	task illegal_instruction;
		begin
			state <= `CORE_STATE_TRAP;
			trap_code <= `EXC_ILLEGAL_INSTR;
			trap_value <= instr;
		end
	endtask
	
	task exec_ecall;
		begin
			state <= `CORE_STATE_TRAP;
			trap_code <= `EXC_ECALL_M_MODE;
			trap_value <= last_pc;
		end
	endtask


`ifdef CORE_USE_CSR
	reg[31:0] rs1_val;
	reg[31:0] csr_val;
	
	task exec_csrrw_1;
		input imode;
		begin
			if (csr_is_invalid_access(csr(instr), 1)) begin
				illegal_instruction();
			end else begin
				if (imode) begin
					rs1_val <= csr_uimm(instr);
				end else begin
					rs1_val <= regs[RS1(instr)];
				end
				if (RD(instr) != x0) begin
					csr_read(csr(instr), csr_val);
				end
				state <= `CORE_STATE_CSR;
			end
		end
	endtask
	
	task exec_csrrw_2;
		begin
			if (RD(instr) != x0) begin
				regs[RD(instr)] <= csr_val;
				csr_write(csr(instr), rs1_val);
			end else begin
				csr_write(csr(instr), rs1_val);
			end
		end
	endtask
	
	task exec_csrr_1;
		input imode;
		reg write;
		begin
			write = RS1(instr) != x0;
			if (csr_is_invalid_access(csr(instr), write)) begin
				illegal_instruction();
			end else begin
				if (imode) begin
					rs1_val <= csr_uimm(instr);
				end else begin
					rs1_val <= regs[RS1(instr)];
				end
				csr_read(csr(instr), csr_val);
				state <= `CORE_STATE_CSR;
			end
		end
	endtask
	
	task exec_csrr_2;
		input smode;
		begin
			if (RD(instr) != x0) begin
				regs[RD(instr)] <= csr_val;
			end
			if (RS1(instr) != x0) begin
				if (smode)
					csr_write(csr(instr), csr_val | rs1_val);
				else
					csr_write(csr(instr), csr_val & ~rs1_val);
			end
		end
	endtask
`endif
	
	
	task do_execute;
		begin
			`ifdef CORE_USE_CSR
				minstret <= minstret + 1;
			`endif
			
			pc <= pc + 4;
			
			//$display("pc: %h", pc);
		
			case (opcode)
				`OPCODE_LUI: begin
					regs[RD(instr)] <= U_imm(instr);
				end
				`OPCODE_AUIPC: begin
					regs[RD(instr)] <= pc + U_imm(instr);
				end
				
				`OPCODE_JAL: begin
					regs[RD(instr)] <= pc + 4;	// link
					pc <= pc + J_imm(instr);
				end
				`OPCODE_JALR: begin
					regs[RD(instr)] <= pc + 4;	// link
					pc <= (regs[RS1(instr)] + I_imm(instr)) & ~32'b1;
				end
				
				`OPCODE_BEQ: begin
					if (regs[RS1(instr)] == regs[RS2(instr)]) begin
						pc <= pc + B_imm(instr);
					end
				end
				`OPCODE_BNE: begin
					if (regs[RS1(instr)] != regs[RS2(instr)]) begin
						pc <= pc + B_imm(instr);
					end
				end
				`OPCODE_BLT: begin
					if ($signed(regs[RS1(instr)]) < $signed(regs[RS2(instr)])) begin
						pc <= pc + B_imm(instr);
					end
				end
				`OPCODE_BGE: begin
					if ($signed(regs[RS1(instr)]) >= $signed(regs[RS2(instr)])) begin
						pc <= pc + B_imm(instr);
					end
				end
				`OPCODE_BLTU: begin
					if (regs[RS1(instr)] < regs[RS2(instr)]) begin
						pc <= pc + B_imm(instr);
					end
				end
				`OPCODE_BGEU: begin
					if (regs[RS1(instr)] >= regs[RS2(instr)]) begin
						pc <= pc + B_imm(instr);
					end
				end				
				
				`OPCODE_LW: begin
					regs[RD(instr)] <= mem_r_data;
				end
				`OPCODE_LHU: begin
					regs[RD(instr)] <= mem_r_data;
				end
				`OPCODE_LBU: begin
					regs[RD(instr)] <= mem_r_data;
				end
				`OPCODE_LH: begin
					regs[RD(instr)] <= sign_extend_16_to_32(mem_r_data[15:0]);
				end
				`OPCODE_LB: begin
					regs[RD(instr)] <= sign_extend_8_to_32(mem_r_data[7:0]);
				end
				
				`OPCODE_SW: begin
					mem_addr <= regs[RS1(instr)] + S_imm(instr);
					mem_w_mode <= 1;
					mem_size <= 4;
					mem_enable <= 1;
					mem_w_data <= regs[RS2(instr)];
				end
				`OPCODE_SH: begin
					mem_addr <= regs[RS1(instr)] + S_imm(instr);
					mem_w_mode <= 1;
					mem_size <= 2;
					mem_enable <= 1;
					mem_w_data <= regs[RS2(instr)][15:0];
				end
				`OPCODE_SB: begin
					mem_addr <= regs[RS1(instr)] + S_imm(instr);
					mem_w_mode <= 1;
					mem_size <= 1;
					mem_enable <= 1;
					mem_w_data <= regs[RS2(instr)][7:0];
				end
				
				`OPCODE_ADDI: begin
					regs[RD(instr)] <= regs[RS1(instr)] + I_imm(instr);
				end
				`OPCODE_SLTI: begin
					regs[RD(instr)] <= $signed(regs[RS1(instr)]) < I_imm(instr);
				end
				`OPCODE_SLTIU: begin
					regs[RD(instr)] <= regs[RS1(instr)] < I_imm(instr);
				end
				`OPCODE_XORI: begin
					regs[RD(instr)] <= regs[RS1(instr)] ^ I_imm(instr);
				end
				`OPCODE_ORI: begin
					regs[RD(instr)] <= regs[RS1(instr)] | I_imm(instr);
				end
				`OPCODE_ANDI: begin
					regs[RD(instr)] <= regs[RS1(instr)] & I_imm(instr);
				end
				`OPCODE_SLLI: begin
					regs[RD(instr)] <= regs[RS1(instr)] << shamt(instr);
				end
				`OPCODE_SRLI: begin
					regs[RD(instr)] <= regs[RS1(instr)] >> shamt(instr);
				end
				`OPCODE_SRAI: begin
					regs[RD(instr)] <= $signed(regs[RS1(instr)]) >>> shamt(instr);
				end
				
				`OPCODE_ADD: begin
					regs[RD(instr)] <= regs[RS1(instr)] + regs[RS2(instr)];
				end
				`OPCODE_SUB: begin
					regs[RD(instr)] <= regs[RS1(instr)] - regs[RS2(instr)];
				end
				`OPCODE_SLL: begin
					regs[RD(instr)] <= regs[RS1(instr)] << regs[RS2(instr)][4:0];
				end
				`OPCODE_SRL: begin
					regs[RD(instr)] <= regs[RS1(instr)] >> regs[RS2(instr)][4:0];
				end
				`OPCODE_SRA: begin
					regs[RD(instr)] <= $signed(regs[RS1(instr)]) >>> regs[RS2(instr)][4:0];
				end
				`OPCODE_SLT: begin
					regs[RD(instr)] <= $signed(regs[RS1(instr)]) < $signed(regs[RS2(instr)]);
				end
				`OPCODE_SLTU: begin
					regs[RD(instr)] <= regs[RS1(instr)] < regs[RS2(instr)];
				end
				`OPCODE_XOR: begin
					regs[RD(instr)] <= regs[RS1(instr)] ^ regs[RS2(instr)];
				end
				`OPCODE_OR: begin
					regs[RD(instr)] <= regs[RS1(instr)] | regs[RS2(instr)];
				end
				`OPCODE_AND: begin
					regs[RD(instr)] <= regs[RS1(instr)] & regs[RS2(instr)];
				end
				
				`OPCODE_FENCE: begin
					// NOP for now
				end
				`OPCODE_FENCE_I: begin
					// NOP for now
				end
				`OPCODE_WFI: begin
					// NOP for now
				end
		
`ifdef CORE_USE_CSR	
				`OPCODE_CSRRW: begin
					exec_csrrw_1(0);
				end
				`OPCODE_CSRRS: begin
					exec_csrr_1(0);
				end
				`OPCODE_CSRRC: begin
					exec_csrr_1(0);
				end
				`OPCODE_CSRRWI: begin
					exec_csrrw_1(1);
				end
				`OPCODE_CSRRSI: begin
					exec_csrr_1(1);
				end
				`OPCODE_CSRRCI: begin
					exec_csrr_1(1);
				end
				
				`OPCODE_ECALL: begin
					exec_ecall();
				end
				
				`OPCODE_MRET: begin
					do_mret();
				end
`endif
				
`ifdef CORE_USE_MULTIPLY
				`OPCODE_MUL: begin
					regs[RD(instr)] <= s64(regs[RS1(instr)]) * s64(regs[RS2(instr)]);
				end
				`OPCODE_MULH: begin
					regs[RD(instr)] <= (s64(regs[RS1(instr)]) * s64(regs[RS2(instr)])) >> 32;
				end
				`OPCODE_MULHU: begin
					regs[RD(instr)] <= (u64(regs[RS1(instr)]) * u64(regs[RS2(instr)])) >> 32;
				end
				`OPCODE_MULHSU: begin
					regs[RD(instr)] <= (s64(regs[RS1(instr)]) * u64(regs[RS2(instr)])) >> 32;
				end

				`OPCODE_DIV: begin
					if (regs[RS2(instr)] == 0) begin
						regs[RD(instr)] <= -1;
					end 
					else if ((regs[RS1(instr)] == REG_MIN) && (regs[RS2(instr)] == -1)) begin
						regs[RD(instr)] <= regs[RS1(instr)];
					end
					else begin
						regs[RD(instr)] <= $signed(regs[RS1(instr)]) / $signed(regs[RS2(instr)]);
					end
				end
				`OPCODE_DIVU: begin
					if (regs[RS2(instr)] == 0) begin
						regs[RD(instr)] <= -1;
					end 
					else begin
						regs[RD(instr)] <= regs[RS1(instr)] / regs[RS2(instr)];
					end
				end
				`OPCODE_REM: begin
					if (regs[RS2(instr)] == 0) begin
						regs[RD(instr)] <= regs[RS1(instr)];
					end 
					else if ((regs[RS1(instr)] == REG_MIN) && (regs[RS2(instr)] == -1)) begin
						regs[RD(instr)] <= 0;
					end
					else begin
						regs[RD(instr)] <= $signed(regs[RS1(instr)]) % $signed(regs[RS2(instr)]);
					end
				end
				`OPCODE_REMU: begin
					if (regs[RS2(instr)] == 0) begin
						regs[RD(instr)] <= regs[RS1(instr)];
					end 
					else begin
						regs[RD(instr)] <= regs[RS1(instr)] % regs[RS2(instr)];
					end
				end
`endif

				default: begin
					do_internal_error();
				end
			endcase
			
			regs[0] <= 0;
		end
	endtask
	
`ifdef CORE_USE_CSR
	task do_csr;
		begin
			case (opcode)
				`OPCODE_CSRRW: begin
					exec_csrrw_2();
				end
				`OPCODE_CSRRS: begin
					exec_csrr_2(1);
				end
				`OPCODE_CSRRC: begin
					exec_csrr_2(0);
				end
				`OPCODE_CSRRWI: begin
					exec_csrrw_2;
				end
				`OPCODE_CSRRSI: begin
					exec_csrr_2(1);
				end
				`OPCODE_CSRRCI: begin
					exec_csrr_2(0);
				end
				default: begin
					do_internal_error();
				end
			endcase
		end
	endtask
	
	task do_trap;
		begin
			mstatus[`MSTATUS_MPIE] <= mstatus[`MSTATUS_MIE];
			mstatus[`MSTATUS_MIE] <= 0;
			
			mcause <= {1'b0, trap_code};
			mtval  <= trap_value;
			mepc   <= last_pc;
			pc     <= mtvec[31:2] << 2;
		end
	endtask
	
	task do_mret;
		begin
			mstatus[`MSTATUS_MIE] <= mstatus[`MSTATUS_MPIE];
			mstatus[`MSTATUS_MPIE] <= 1;
			pc <= mepc;
		end
	endtask
`else // CORE_USE_CSR
	task do_trap;
		begin
			do_internal_error();
		end
	endtask
`endif


`ifdef CORE_USE_IRQ
	task check_irq;
		begin
			mip[`EXC_M_TIMER_INTERRUPT] <= tip;
		
			if (mstatus[`MSTATUS_MIE]) begin
				if ((eip || mip[`EXC_M_EXTERNAL_INTERRUPT]) && mie[`EXC_M_EXTERNAL_INTERRUPT]) begin
					state <= `CORE_STATE_IRQ;
					trap_code <= `EXC_M_EXTERNAL_INTERRUPT;
					if (eip)
						mip[`EXC_M_EXTERNAL_INTERRUPT] <= 1;
				end
				if ((sip || mip[`EXC_M_SOFTWARE_INTERRUPT]) && mie[`EXC_M_SOFTWARE_INTERRUPT]) begin
					state <= `CORE_STATE_IRQ;
					trap_code <= `EXC_M_SOFTWARE_INTERRUPT;
					if (sip)
						mip[`EXC_M_SOFTWARE_INTERRUPT] <= 1;
				end
				else if ((tip || mip[`EXC_M_TIMER_INTERRUPT]) && mie[`EXC_M_TIMER_INTERRUPT]) begin
					state <= `CORE_STATE_IRQ;
					trap_code <= `EXC_M_TIMER_INTERRUPT;
				end
			end
		end
	endtask
	
	task do_irq;
		begin
			mstatus[`MSTATUS_MPIE] <= mstatus[`MSTATUS_MIE];
			mstatus[`MSTATUS_MIE] <= 0;
			
			mcause <= {1'b1, trap_code};
			mepc   <= pc;
			pc     <= mtvec[31:2] << 2;
		end
	endtask
`endif

	
	task do_internal_error;
		begin
			error <= 1;
			pc <= pc;
		end
	endtask
	
	task do_fetch;
		begin
			mem_addr <= pc;
			mem_w_mode <= 0;
			mem_size <= 4;
			mem_enable <= 1;
			last_pc <= pc;
		end
	endtask
	
	task do_decode;
		begin
			instr <= mem_r_data;
			
			case (mem_r_data[6:0])
				7'b0110111: opcode <= `OPCODE_LUI;
				7'b0010111: opcode <= `OPCODE_AUIPC;
				7'b1101111: opcode <= `OPCODE_JAL;
				7'b1100111: opcode <= `OPCODE_JALR;
				
				7'b1100011: begin
					case (mem_r_data[14:12])
						3'b000: opcode <= `OPCODE_BEQ;
						3'b001: opcode <= `OPCODE_BNE;
						3'b100: opcode <= `OPCODE_BLT;
						3'b101: opcode <= `OPCODE_BGE;
						3'b110: opcode <= `OPCODE_BLTU;
						3'b111: opcode <= `OPCODE_BGEU;
						default: opcode <= `OPCODE_UNDEF;
					endcase
				end
				
				7'b0000011: begin
					mem_enable <= 1;
					mem_addr <= regs[RS1(mem_r_data)] + I_imm(mem_r_data);
					mem_w_mode <= 0;
					state <= `CORE_STATE_WAIT_LOAD_OPERANDS;
					case (mem_r_data[14:12])
						3'b000: begin
							opcode <= `OPCODE_LB;
							mem_size <= 1;
						end
						3'b001: begin
							opcode <= `OPCODE_LH;
							mem_size <= 2;
						end
						3'b010: begin
							opcode <= `OPCODE_LW;
							mem_size <= 4;
						end
						3'b100: begin
							opcode <= `OPCODE_LBU;
							mem_size <= 1;
						end
						3'b101: begin
							opcode <= `OPCODE_LHU;
							mem_size <= 2;
						end
						default: opcode <= `OPCODE_UNDEF;
					endcase
				end
				
				7'b0100011: begin
					case (mem_r_data[14:12])
						3'b000: opcode <= `OPCODE_SB;
						3'b001: opcode <= `OPCODE_SH;
						3'b010: opcode <= `OPCODE_SW;
						default: opcode <= `OPCODE_UNDEF;
					endcase
				end
				
				7'b0010011: begin
					case (mem_r_data[14:12])
						3'b000: opcode <= `OPCODE_ADDI;
						3'b010: opcode <= `OPCODE_SLTI;
						3'b011: opcode <= `OPCODE_SLTIU;
						3'b100: opcode <= `OPCODE_XORI;
						3'b110: opcode <= `OPCODE_ORI;
						3'b111: opcode <= `OPCODE_ANDI;
						3'b001: opcode <= `OPCODE_SLLI;
						3'b101: begin
							case (mem_r_data[31:25])
								7'b0000000: opcode <= `OPCODE_SRLI;
								7'b0100000: opcode <= `OPCODE_SRAI;
								default: opcode <= `OPCODE_UNDEF;
							endcase
						end
						default: opcode <= `OPCODE_UNDEF;
					endcase
				end
				
				7'b0110011: begin
					case (mem_r_data[31:25])
						7'b0000000: begin
							case (mem_r_data[14:12])
								3'b000: opcode <= `OPCODE_ADD;
								3'b001: opcode <= `OPCODE_SLL;
								3'b010: opcode <= `OPCODE_SLT;
								3'b011: opcode <= `OPCODE_SLTU;
								3'b100: opcode <= `OPCODE_XOR;
								3'b101: opcode <= `OPCODE_SRL;
								3'b110: opcode <= `OPCODE_OR;
								3'b111: opcode <= `OPCODE_AND;
								default: opcode <= `OPCODE_UNDEF;
							endcase
						end
						7'b0100000: begin
							case (mem_r_data[14:12])
								3'b000: opcode <= `OPCODE_SUB;
								3'b101: opcode <= `OPCODE_SRA;
								default: opcode <= `OPCODE_UNDEF;
							endcase
						end
					`ifdef CORE_USE_MULTIPLY
						7'b0000001: begin
							case (mem_r_data[14:12])
								3'b000: opcode <= `OPCODE_MUL;
								3'b001: opcode <= `OPCODE_MULH;
								3'b010: opcode <= `OPCODE_MULHSU;
								3'b011: opcode <= `OPCODE_MULHU;
								3'b100: opcode <= `OPCODE_DIV;
								3'b101: opcode <= `OPCODE_DIVU;
								3'b110: opcode <= `OPCODE_REM;
								3'b111: opcode <= `OPCODE_REMU;
								default: opcode <= `OPCODE_UNDEF;
							endcase
						end
					`endif
						default: opcode <= `OPCODE_UNDEF;
					endcase
				end
				
				7'b0001111: begin
					case (mem_r_data[14:12])
						3'b000: opcode <= `OPCODE_FENCE;
						3'b001: opcode <= `OPCODE_FENCE_I;
						default: opcode <= `OPCODE_UNDEF;
					endcase
				end
				
				7'b1110011: begin
					case (mem_r_data[14:12])
						3'b000: begin
							case (mem_r_data[31:20])
								12'b000000000000: opcode <= `OPCODE_ECALL;
								12'b000000000001: opcode <= `OPCODE_EBREAK;
								12'b001100000010: opcode <= `OPCODE_MRET;
								12'b000100000101: opcode <= `OPCODE_WFI;
								default: opcode <= `OPCODE_UNDEF;
							endcase
						end
					`ifdef CORE_USE_CSR
						3'b001: opcode <= `OPCODE_CSRRW;
						3'b010: opcode <= `OPCODE_CSRRS;
						3'b011: opcode <= `OPCODE_CSRRC;
						3'b101: opcode <= `OPCODE_CSRRWI;
						3'b110: opcode <= `OPCODE_CSRRSI;
						3'b111: opcode <= `OPCODE_CSRRCI;
					`endif
						default: opcode <= `OPCODE_UNDEF;
					endcase
				end
				
				default:
					opcode <= `OPCODE_UNDEF;
			endcase
		end
	endtask
	
	task do_step;
		begin
			`ifdef CORE_USE_CSR
				mcycle <= mcycle + 1;
			`endif
		
			mem_enable <= 0;
			
			if (mem_error) begin
				do_internal_error();
			end else begin		
				case (state)
					`CORE_STATE_FETCH: begin
						if (mem_ready) begin
							state <= `CORE_STATE_DECODE;
							do_fetch();
						end
					end
					`CORE_STATE_DECODE: begin
						if (mem_ready) begin
							state <= `CORE_STATE_EXECUTE;
							do_decode();
						end
					end
					`CORE_STATE_WAIT_LOAD_OPERANDS: begin
						if (mem_ready) begin
							`ifdef CORE_USE_IRQ
								state <= `CORE_STATE_CHECK_IRQ;
							`else
								state <= `CORE_STATE_FETCH;
							`endif
							do_execute();
						end
					end
					`CORE_STATE_EXECUTE: begin
						`ifdef CORE_USE_IRQ
							state <= `CORE_STATE_CHECK_IRQ;
						`else
							state <= `CORE_STATE_FETCH;
						`endif
						do_execute();
					end
				`ifdef CORE_USE_CSR
					`CORE_STATE_CSR: begin
						`ifdef CORE_USE_IRQ
							state <= `CORE_STATE_CHECK_IRQ;
						`else
							state <= `CORE_STATE_FETCH;
						`endif
						do_csr();
					end
				`endif
				`ifdef CORE_USE_IRQ
					`CORE_STATE_CHECK_IRQ: begin
						state <= `CORE_STATE_FETCH;
						check_irq();
					end
					`CORE_STATE_IRQ: begin
						state <= `CORE_STATE_FETCH;
						do_irq();
					end
				`endif
					`CORE_STATE_TRAP: begin
						state <= `CORE_STATE_FETCH;
						do_trap();
					end
					default: begin
						do_internal_error();
					end
				endcase
			end
		end
	endtask
	
 
	always @(posedge clock) begin
		if (reset)
			do_reset();
		else
			if (!error)
				do_step();
	end
	
	assign hlt = error;
endmodule
