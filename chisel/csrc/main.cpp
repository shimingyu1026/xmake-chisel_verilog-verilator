#include "chisel_demo.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#include "config_chisel.h"
#include <cstdint>

#include <fmt/color.h>
#include <fmt/core.h>

// Required by Verilator for tracing
double sc_time_stamp() { return 0; }

int main(int argc, char **argv) {
  fmt::print(bg(fmt::color::blue), "Hello Chisel");
  char const *vcdfile = WAVE_FILE_NAME;
  VerilatedContext *contextp = new VerilatedContext;
  contextp->commandArgs(argc, argv);
  chisel_demo *top = new chisel_demo{contextp};
  VerilatedVcdC *tfp = new VerilatedVcdC;
  top->trace(tfp, 99);
  Verilated::traceEverOn(true);
  tfp->open(vcdfile);
  for (uint64_t i = 0; i / 2 < WAVE_MAX_CYCLES && !contextp->gotFinish(); ++i) {
    contextp->timeInc(1);
    top->clock = i % 2;
    top->reset = i < 2;
    top->eval();
    tfp->dump(contextp->time());
  }
  tfp->close();
  delete top;
  delete contextp;
  return 0;
}