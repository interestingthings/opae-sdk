#ifndef FPGA_SIMULATOR_VERILATOR_H
#define FPGA_SIMULATOR_VERILATOR_H

#include <iostream>
#include <map>
#include <memory>
#include <cstdbool>

#include "ase_types_int.h"
#include "ifpga_simulator.h"

namespace intel {
namespace fpga {
namespace ase {

/* Concrete FPGA simulator class for Verilator */
template<class afu> class fpga_simulator_verilator : public fpga_simulator <afu> {
public:

	using fpga_simulator<afu>::m_fpga_simulator_id;

	fpga_simulator_verilator() {
		m_fpga_simulator_id = verilator;
	}

	void init();

	void run();

	void reset();

	void shutdown();

	void compile_afu();

	void compile_simulation_libraries();

	void register_observer();

	void update_observers();

};

} // end of namespace ase
} // end of namespace fpga
} // end of namespace intel

#endif
