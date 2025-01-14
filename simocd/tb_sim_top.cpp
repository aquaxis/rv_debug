#include <stdlib.h>
#include <verilated.h>
#include <verilated_fst_c.h>
#ifndef NON_JTAG
#include "jtag_vpi/jtagServer.h"
#endif
#include "Vdebug_top.h"

#define DIVTICK 10000000

vluint64_t tick = 0;
char dumpfile[256];
int filecount = 0;

int main(int argc, char **argv)
{
	Verilated::commandArgs(argc, argv);

	// Instantiate DUT
	Vdebug_top *dut = new Vdebug_top();

#ifdef OUTPUT_WAVE
	// Trace DUMP ON
	Verilated::traceEverOn(true);
	VerilatedFstC *m_trace = new VerilatedFstC;
	//  VerilatedFstC *m_trace = new VerilatedFstC;
	dut->trace(m_trace, 99);
	sprintf(dumpfile, "dump%03d.fst", filecount);
	m_trace->open(dumpfile);
	//  m_trace->open("sim.fst");
	printf("Trace On\n");
#endif

#ifndef NON_JTAG
	// JTAG Server
	VerilatorJtagServer *jtag = new VerilatorJtagServer(60);
	jtag->init_jtag_server(5555, false);
#endif

	printf("Simulation Start\n");

	// Format
	dut->TRST_N = 0;
	dut->RST_N = 0;
	dut->CLK = 0;

	// Reset Time(0-100)
	while (tick < 100)
	{
		// Evaluate DUT
		dut->CLK = !dut->CLK;
		dut->eval();
#ifdef OUTPUT_WAVE
		m_trace->dump(tick);
#endif
		tick++;
	}

	// Release reset
	dut->RST_N = 1;
	dut->TRST_N = 1;
	dut->CLK = !dut->CLK;
	dut->eval();
#ifdef OUTPUT_WAVE
	m_trace->dump(tick);
#endif
	tick++;

#ifndef NON_JTAG
	while (jtag->stop_simu == false)
#else
	while (tick < 100000)
#endif
	{
		dut->CLK = !dut->CLK;
		dut->eval();

		jtag->doJTAG(tick, &dut->TMS, &dut->TDI, &dut->TCK, dut->TDO);

#ifdef OUTPUT_WAVE
		m_trace->dump(tick);
		if (tick % DIVTICK == 0)
		{
			m_trace->close();
			filecount++;
			sprintf(dumpfile, "dump%03d.fst", filecount);
			m_trace->open(dumpfile);
		}
#endif

		tick++;
	}

#ifdef OUTPUT_WAVE
	m_trace->close();
#endif

	printf("Simulation Finished\n");
}