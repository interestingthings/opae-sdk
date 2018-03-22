// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table internal header
//
// Internal details; most calling programs do not need this header

#ifndef _Vccip_std_afu__Syms_H_
#define _Vccip_std_afu__Syms_H_

#include "verilated_heavy.h"

// INCLUDE MODULE CLASSES
#include "Vccip_std_afu.h"
#include "Vccip_std_afu___024unit.h"

// SYMS CLASS
class Vccip_std_afu__Syms : public VerilatedSyms {
  public:
    
    // LOCAL STATE
    const char* __Vm_namep;
    bool	__Vm_activity;		///< Used by trace routines to determine change occurred
    bool	__Vm_didInit;
    
    // SUBCELL STATE
    Vccip_std_afu*                 TOPp;
    
    // COVERAGE
    
    // SCOPE NAMES
    VerilatedScope __Vscope_ccip_std_afu__nlb_lpbk__inst_arbiter__test_lpbk1;
    VerilatedScope __Vscope_ccip_std_afu__nlb_lpbk__inst_arbiter__test_lpbk1__rdrsp_mem0__ram_2port_0__altera_syncram_component;
    VerilatedScope __Vscope_ccip_std_afu__nlb_lpbk__inst_arbiter__test_lpbk1__rdrsp_mem1__ram_2port_0__altera_syncram_component;
    VerilatedScope __Vscope_ccip_std_afu__nlb_lpbk__inst_requestor__nlb_writeTx_fifo__C1Tx_mem__ram_2port_0__altera_syncram_component;
    
    // CREATORS
    Vccip_std_afu__Syms(Vccip_std_afu* topp, const char* namep);
    ~Vccip_std_afu__Syms() {};
    
    // METHODS
    inline const char* name() { return __Vm_namep; }
    inline bool getClearActivity() { bool r=__Vm_activity; __Vm_activity=false; return r;}
    
} VL_ATTR_ALIGNED(64);

#endif  /*guard*/
