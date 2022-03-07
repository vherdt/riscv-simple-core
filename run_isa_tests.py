#!/usr/bin/env python3
import types, shlex, os
from subprocess import Popen, PIPE

FILE_DIR = os.path.join(os.environ['RISCV_TESTS_DIR'], "isa")

##./elf2bin.py riscv-tests/isa/rv32ui-p-add rom.hex


files = []
for filename in os.listdir(FILE_DIR):
	path = os.path.join(FILE_DIR, filename)
	if filename.endswith(".dump"):
		continue

	if filename.startswith("rv32ui-p"):
		files.append(path)
	elif filename.startswith("rv32um-p"):
		files.append(path)
		
		
class TestResults(types.SimpleNamespace):
	def __init__(self):
		self.passed = []
		self.failed = []
		self.crashed = []
		
	def show(self):
		total = len(self.passed) + len(self.failed) + len(self.crashed)
		all_passed = len(self.failed) == 0 and len(self.crashed) == 0
		
		print("=[ Test Execution Summary ]=".ljust(80, '='))
		
		for e in self.failed:
			print("FAIL: {}".format(e))
			
		for e in self.crashed:
			print("CRASH: {}".format(e))
		
		print("failed {} / {} tests".format(len(self.failed), total))
		print("crashed {} / {} tests".format(len(self.crashed), total))
		print("passed {} / {} tests".format(len(self.passed), total))
		
		if all_passed:
			print("ALL TESTS PASSED")
		else:
			print("SOME TESTS FAILED OR CRASHED")


res = TestResults()


def run_test(filename):
	print("run-test: {}".format(filename))
	cmd = "./core"
	cmd_list = shlex.split(cmd)
	process = Popen(cmd_list, stdout=PIPE)
	(output, err) = process.communicate()
	exit_code = process.wait()

	if exit_code != 0:
		print(" -- crashed with exit code {}".format(exit_code))
		res.crashed.append(filename)
	else:
		if b"-> normal shutdown" in output:
			print(" -- passed")
			res.passed.append(filename)
		else:
			print(" -- failed")
			res.failed.append(filename)


os.system("make")
for f in files:
	mk_rom = "./elf2bin.py {} rom.hex".format(f)
	os.system(mk_rom)
	run_test(f)
	
res.show()
