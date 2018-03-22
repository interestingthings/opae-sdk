// Copyright(c) 2014-2017, Intel Corporation
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
// **************************************************************************

#ifndef _EMU_COMMON_H_
#define _EMU_COMMON_H_

#ifdef __cplusplus
#include <cstdlib>
#include <cstdint>
#else
#include <stdlib.h>
#include <stdint.h>
#endif

/* *******************************************************************************
 * SYSTEM FACTS
 * *******************************************************************************/

#define FPGA_ADDR_WIDTH		48
#define PHYS_ADDR_PREFIX_MASK	0x0000FFFFFFE00000
#define CL_ALIGN		6
#define MEMBUF_2MB_ALIGN	21

// Width of a cache line in bytes
#define CL_BYTE_WIDTH		64
#define SIZEOF_1GB_BYTES	((uint64_t)pow(1024, 3))

// Size of page
#define EMU_PAGESIZE    0x1000	// 4096 bytes
#define CCI_CHUNK_SIZE  (2*1024*1024)	// CCI 2 MB physical chunks

// MMIO memory map size
#define MMIO_LENGTH     (512*1024)	// 512 KB MMIO size
#define MMIO_AFU_OFFSET (256*1024)

// MMIO Tid width
#define MMIO_TID_BITWIDTH          9
#define MMIO_TID_BITMASK        (uint32_t)(pow((uint32_t)2, MMIO_TID_BITWIDTH)-1)
#define MMIO_MAX_OUTSTANDING       64

// Number of UMsgs per AFU
#define NUM_UMSG_PER_AFU        8

// UMAS region
#define UMAS_LENGTH     (NUM_UMSG_PER_AFU * EMU_PAGESIZE)
#define UMAS_REGION_MEMSIZE        (2*1024*1024)

// User clock default
#define DEFAULT_USR_CLK_MHZ     312.500
#define DEFAULT_USR_CLK_TPS     (int)(1E+12/(DEFAULT_USR_CLK_MHZ*pow(1000, 2)));

// Max number of user interrupts
#define MAX_USR_INTRS              4

/*
 * ASE INTERNAL MACROS
 * -------------------
 * Controls file, path lengths
 */

// SHM memory name length
#define EMU_FILENAME_LEN        40

// ASE filepath length
#define EMU_FILEPATH_LEN        256

// ASE logger len
#define EMU_LOGGER_LEN          1024

// Timestamp session code length
#define EMU_SESSION_CODE_LEN    20

// work Directory location
extern char *emu_workdir_path;

// Timestamp IPC file
#define TSTAMP_FILENAME ".emu_timestamp"
extern char tstamp_filepath[EMU_FILEPATH_LEN];
extern char *glbl_session_id;

// CCIP Warnings and Error stat location
extern char ccip_sniffer_file_statpath[EMU_FILEPATH_LEN];

// READY file name
#define EMU_READY_FILENAME ".emu_ready.pid"
#define APP_LOCK_FILENAME  ".app_lock.pid"

// ASE Mode macros
#define EMU_MODE_DAEMON_NO_SIMKILL   1
#define EMU_MODE_DAEMON_SIMKILL      2
#define EMU_MODE_DAEMON_SW_SIMKILL   3
#define EMU_MODE_REGRESSION          4

// UMAS establishment status
#define NOT_ESTABLISHED 0xC0C0
#define ESTABLISHED     0xBEEF

// ASE PortCtrl Command values
typedef enum {
	AFU_RESET,
	EMU_SIMKILL,
	EMU_INIT,
	UMSG_MODE
} emu_portctrl_cmd;

// Buffer information structure --
//   Be careful of alignment within this structure!  The layout must be
//   identical on both 64 bit and 32 bit compilations.
struct buffer_t			//  Descriptiion                    Computed by
{				// --------------------------------------------
	int32_t index;		// Tracking id                     | INTERNAL
	int32_t valid;		// Valid buffer indicator          | INTERNAL
	uint64_t vbase;		// SW virtual address              |   APP
	uint64_t pbase;		// SIM virtual address             |   SIM
	uint64_t fake_paddr;	// unique low FPGA_ADDR_WIDTH addr |   SIM
	uint64_t fake_paddr_hi;	// unique hi FPGA_ADDR_WIDTH addr  |   SIM
	int32_t is_privmem;	// Flag memory as a private memory |
	int32_t is_mmiomap;	// Flag memory as CSR map          |
	int32_t is_umas;	// Flag memory as UMAS region      |
	uint32_t memsize;	// Memory size                     |   APP
	char memname[EMU_FILENAME_LEN];	// Shared memory name              | INTERNAL
	struct buffer_t *next;
};

/*
 * Workspace meta list
 */
struct wsmeta_t {
	int index;
	int valid;
	uint64_t *buf_structaddr;
	struct wsmeta_t *next;
};


/*
 * MMIO transaction packet --
 *   Be careful of alignment within this structure!  The layout must be
 *   identical on both 64 bit and 32 bit compilations.
 */
typedef struct mmio_t {
	int32_t tid;
	int32_t write_en;
	int32_t width;
	int32_t addr;
	uint64_t qword[8];
	int32_t resp_en;
	int32_t dummy;        // For 64 bit alignment
} mmio_t;


/*
 * Umsg transaction packet
 */
typedef struct umsgcmd_t {
	int32_t id;
	int32_t hint;
	uint64_t qword[8];
} umsgcmd_t;

// CCI transaction packet
typedef struct ccip_pkt_t {
	int       mode;
	int       qw_start;
	long      mdata;
	long long cl_addr;
	long long qword[8];
	int       resp_channel;
	int       intr_id;
	int       success;
} cci_pkt_t;

#define CCIPKT_WRITE_MODE    0x1010
#define CCIPKT_READ_MODE     0x2020
#define CCIPKT_WRFENCE_MODE  0xFFFF
#define CCIPKT_ATOMIC_MODE   0x8080
#define CCIPKT_INTR_MODE     0x4040

#endif // End _EMU_COMMON_H_
