// Copyright(c) 2017, Intel Corporation
//
// Redistribution  and  use  in source  and  binary  forms,  with  or  without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of  source code  must retain the  above copyright notice,
//   this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
// * Neither the name  of Intel Corporation  nor the names of its contributors
//   may be used to  endorse or promote  products derived  from this  software
//   without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,  BUT NOT LIMITED TO,  THE
// IMPLIED WARRANTIES OF  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED.  IN NO EVENT  SHALL THE COPYRIGHT OWNER  OR CONTRIBUTORS BE
// LIABLE  FOR  ANY  DIRECT,  INDIRECT,  INCIDENTAL,  SPECIAL,  EXEMPLARY,  OR
// CONSEQUENTIAL  DAMAGES  (INCLUDING,  BUT  NOT LIMITED  TO,  PROCUREMENT  OF
// SUBSTITUTE GOODS OR SERVICES;  LOSS OF USE,  DATA, OR PROFITS;  OR BUSINESS
// INTERRUPTION)  HOWEVER CAUSED  AND ON ANY THEORY  OF LIABILITY,  WHETHER IN
// CONTRACT,  STRICT LIABILITY,  OR TORT  (INCLUDING NEGLIGENCE  OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,  EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif				// HAVE_CONFIG_H

#include <opae/access.h>
#include <opae/utils.h>
#include "common_int.h"
#include "ccip_common.h"

#include <errno.h>
#include <malloc.h>		/* malloc */
#include <stdlib.h>		/* exit */
#include <stdio.h>		/* printf */
#include <string.h>		/* memcpy */
#include <unistd.h>		/* getpid */
#include <sys/types.h>		/* pid_t */
#include <sys/ioctl.h>		/* ioctl */
#include <sys/mman.h>		/* mmap & munmap */
#include <sys/time.h>		/* struct timeval */

fpga_result __FPGA_API__ fpgaWriteMMIO32(fpga_handle handle,
					 uint32_t mmio_num,
					 uint64_t offset, uint32_t value)
{
	return FPGA_OK;
}

fpga_result __FPGA_API__ fpgaReadMMIO32(fpga_handle handle,
					uint32_t mmio_num, uint64_t offset,
					uint32_t *value)
{
}


fpga_result __FPGA_API__ fpgaWriteMMIO64(fpga_handle handle,
					 uint32_t mmio_num,
					 uint64_t offset, uint64_t value)
{
	return FPGA_OK;
}

fpga_result __FPGA_API__ fpgaReadMMIO64(fpga_handle handle,
					uint32_t mmio_num, uint64_t offset,
					uint64_t *value)
{
}

fpga_result __FPGA_API__ fpgaMapMMIO(fpga_handle handle, uint32_t mmio_num,
				     uint64_t **mmio_ptr)
{
	fpga_result result = FPGA_OK;
	return result;
}

fpga_result __FPGA_API__ fpgaUnmapMMIO(fpga_handle handle,
				       uint32_t mmio_num)
{
	// TODO: check handle?
	// TODO: check mmio_num?

	return FPGA_OK;
}

fpga_result __FPGA_API__ fpgaReset(fpga_handle handle)
{
	return FPGA_OK;
}
