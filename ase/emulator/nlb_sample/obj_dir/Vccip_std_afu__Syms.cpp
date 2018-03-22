// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table implementation internals

#include "Vccip_std_afu__Syms.h"
#include "Vccip_std_afu.h"
#include "Vccip_std_afu___024unit.h"

// FUNCTIONS
Vccip_std_afu__Syms::Vccip_std_afu__Syms(Vccip_std_afu* topp, const char* namep)
	// Setup locals
	: __Vm_namep(namep)
	, __Vm_activity(false)
	, __Vm_didInit(false)
	// Setup submodule names
{
    // Pointer to top level
    TOPp = topp;
    // Setup each module's pointers to their submodules
    // Setup each module's pointer back to symbol table (for public functions)
    TOPp->__Vconfigure(this, true);
    // Setup scope names
    __Vscope_ccip_std_afu__nlb_lpbk__inst_arbiter__test_lpbk1.configure(this,name(),"ccip_std_afu.nlb_lpbk.inst_arbiter.test_lpbk1");
    __Vscope_ccip_std_afu__nlb_lpbk__inst_arbiter__test_lpbk1__rdrsp_mem0__ram_2port_0__altera_syncram_component.configure(this,name(),"ccip_std_afu.nlb_lpbk.inst_arbiter.test_lpbk1.rdrsp_mem0.ram_2port_0.altera_syncram_component");
    __Vscope_ccip_std_afu__nlb_lpbk__inst_arbiter__test_lpbk1__rdrsp_mem1__ram_2port_0__altera_syncram_component.configure(this,name(),"ccip_std_afu.nlb_lpbk.inst_arbiter.test_lpbk1.rdrsp_mem1.ram_2port_0.altera_syncram_component");
    __Vscope_ccip_std_afu__nlb_lpbk__inst_requestor__nlb_writeTx_fifo__C1Tx_mem__ram_2port_0__altera_syncram_component.configure(this,name(),"ccip_std_afu.nlb_lpbk.inst_requestor.nlb_writeTx_fifo.C1Tx_mem.ram_2port_0.altera_syncram_component");
}
