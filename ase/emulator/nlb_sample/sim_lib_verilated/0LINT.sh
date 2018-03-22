#!/bin/bash
# Created by altera_lib_lpm.pl
echo "**********************************************************************"
echo Lint LPM_DEVICE_FAMILIES
vlint --brief $* LPM_DEVICE_FAMILIES.v
echo "**********************************************************************"
echo Lint LPM_HINT_EVALUATION
vlint --brief $* LPM_HINT_EVALUATION.v
echo "**********************************************************************"
echo Lint LPM_MEMORY_INITIALIZATION
vlint --brief $* LPM_MEMORY_INITIALIZATION.v
echo "**********************************************************************"
echo Lint lpm_abs
vlint --brief $* lpm_abs.v
echo "**********************************************************************"
echo Lint lpm_add_sub
vlint --brief $* lpm_add_sub.v
echo "**********************************************************************"
echo Lint lpm_and
vlint --brief $* lpm_and.v
echo "**********************************************************************"
echo Lint lpm_bipad
vlint --brief $* lpm_bipad.v
echo "**********************************************************************"
echo Lint lpm_bustri
vlint --brief $* lpm_bustri.v
echo "**********************************************************************"
echo Lint lpm_clshift
vlint --brief $* lpm_clshift.v
echo "**********************************************************************"
echo Lint lpm_compare
vlint --brief $* lpm_compare.v
echo "**********************************************************************"
echo Lint lpm_constant
vlint --brief $* lpm_constant.v
echo "**********************************************************************"
echo Lint lpm_counter
vlint --brief $* lpm_counter.v
echo "**********************************************************************"
echo Lint lpm_decode
vlint --brief $* lpm_decode.v
echo "**********************************************************************"
echo Lint lpm_divide
vlint --brief $* lpm_divide.v
echo "**********************************************************************"
echo Lint lpm_ff
vlint --brief $* lpm_ff.v
echo "**********************************************************************"
echo Lint lpm_fifo
vlint --brief $* lpm_fifo.v
echo "**********************************************************************"
echo Lint lpm_fifo_dc
vlint --brief $* lpm_fifo_dc.v
echo "**********************************************************************"
echo Lint lpm_fifo_dc_async
vlint --brief $* lpm_fifo_dc_async.v
echo "**********************************************************************"
echo Lint lpm_fifo_dc_dffpipe
vlint --brief $* lpm_fifo_dc_dffpipe.v
echo "**********************************************************************"
echo Lint lpm_fifo_dc_fefifo
vlint --brief $* lpm_fifo_dc_fefifo.v
echo "**********************************************************************"
echo Lint lpm_inpad
vlint --brief $* lpm_inpad.v
echo "**********************************************************************"
echo Lint lpm_inv
vlint --brief $* lpm_inv.v
echo "**********************************************************************"
echo Lint lpm_latch
vlint --brief $* lpm_latch.v
echo "**********************************************************************"
echo Lint lpm_mult
vlint --brief $* lpm_mult.v
echo "**********************************************************************"
echo Lint lpm_mux
vlint --brief $* lpm_mux.v
echo "**********************************************************************"
echo Lint lpm_or
vlint --brief $* lpm_or.v
echo "**********************************************************************"
echo Lint lpm_outpad
vlint --brief $* lpm_outpad.v
echo "**********************************************************************"
echo Lint lpm_ram_dp
vlint --brief $* lpm_ram_dp.v
echo "**********************************************************************"
echo Lint lpm_ram_dq
vlint --brief $* lpm_ram_dq.v
echo "**********************************************************************"
echo Lint lpm_ram_io
vlint --brief $* lpm_ram_io.v
echo "**********************************************************************"
echo Lint lpm_rom
vlint --brief $* lpm_rom.v
echo "**********************************************************************"
echo Lint lpm_shiftreg
vlint --brief $* lpm_shiftreg.v
echo "**********************************************************************"
echo Lint lpm_xor
vlint --brief $* lpm_xor.v
