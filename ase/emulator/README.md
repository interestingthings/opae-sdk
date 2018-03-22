# Project Status #

## Base classes ##

| Filename        | Purpose of the header file                              | Status | Testing |
|-----------------|---------------------------------------------------------|--------|---------|
| ase_types_int.h | Internal data-types to be shared between C and C++ code | TODO   | TODO    |

## Core classes ##

| Filename                           | Purpose of the header file                                         | Status | Testing |
|------------------------------------|--------------------------------------------------------------------|--------|---------|
| ibase.h                            | Generic abstract class                                             | DONE   | TODO    |
| ifpga_emulator.h                   | Abstract class definying the top object                            | DONE   | TODO    |
| iafu_model.h                       | Abstract class for the AFU model                                   | TODO   | TODO    |
| afu_model_verilator.h              | Concrete class for AFU model from Verilator                        | TODO   | TODO    |
| iafu_model_factory.h               | Abstract class for the AFU model factory                           | TODO   | TODO    |
| iafu_model_factory_verilator.h     | Concrete class for the AFU model factory when using Verilator      | TODO   | TODO    |
| ifpga_simulator.h                  | Abstract class for the FPGA simulator                              | TODO   | TODO    |
| fpga_simulator_verilator.h         | Concrete class for the FPGA simulator when using Verilator         | TODO   | TODO    |
| ifpga_simulator_factory.h          | Abstract class for the simulator factory                           | TODO   | TODO    |
| fpga_simulator_factory_verilator.h | Concrete class for the FPGA simulator factory when using Verilator | TODO   | TODO    |

## Additional classes ##

| Filename         | Purpose of the header file          | Status | Testing |
|------------------|-------------------------------------|--------|---------|
| dma_buffer_emu.h | Concrete class for the DMA buffers  |        |         |
| mmio_emu.h       | Concrete class for the MMIO regions |        |         |
| fpga_command.h   |                                     |        |         |

## Interface classes ##

| Filename        | Purpose of the header file                                                    | Status | Testing |
|-----------------|-------------------------------------------------------------------------------|--------|---------|
| ccip_common.h   | CCIP-specific constants and data types (structs)                              | TODO   | TODO    |
| ccip_emulator.h | Concrete class implementing main object that interfaces with OPAE application | TODO   | TODO    |
