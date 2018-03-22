// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vccip_std_afu.h for the primary calling header

#ifndef _Vccip_std_afu___024unit_H_
#define _Vccip_std_afu___024unit_H_

#include "verilated_heavy.h"
#include "Vccip_std_afu__Inlines.h"
class Vccip_std_afu__Syms;

//----------

VL_MODULE(Vccip_std_afu___024unit) {
  public:
    // CELLS
    
    // PORTS
    
    // LOCAL SIGNALS
    
    // LOCAL VARIABLES
    
    // INTERNAL VARIABLES
  private:
    Vccip_std_afu__Syms*	__VlSymsp;		// Symbol table
  public:
    
    // PARAMETERS
    
    // CONSTRUCTORS
  private:
    Vccip_std_afu___024unit& operator= (const Vccip_std_afu___024unit&);	///< Copying not allowed
    Vccip_std_afu___024unit(const Vccip_std_afu___024unit&);	///< Copying not allowed
  public:
    Vccip_std_afu___024unit(const char* name="TOP");
    ~Vccip_std_afu___024unit();
    
    // USER METHODS
    
    // API METHODS
    
    // INTERNAL METHODS
    void __Vconfigure(Vccip_std_afu__Syms* symsp, bool first);
  private:
    void	_configure_coverage(Vccip_std_afu__Syms* __restrict vlSymsp, bool first);
    void	_ctor_var_reset();
} VL_ATTR_ALIGNED(128);

#endif  /*guard*/
