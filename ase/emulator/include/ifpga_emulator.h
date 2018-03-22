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

#ifndef FPGA_EMULATOR_H
#define FPGA_EMULATOR_H

#include "ase_types_int.h"
#include "fpga.h"

#ifdef __cplusplus

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <sstream>
#include <memory>
#include <cassert>
#include <cerrno>
#include <stdexcept>
#include <deque>
#include <list>
#include <atomic>
#include <chrono>
#include <mutex>

#include "dma_buffer_emu.h"
#include "mmio_emu.h"

/* AFU model classes */
#include "iafu_model.h"
#include "iafu_model_factory.h"

/* FPGA simulator classes */
#include "ifpga_simulator.h"
#include "ifpga_simulator_factory.h"

/* FPGA interface class */
#include "fpga_interface.h"

/* FPGA commands (from OPAE to FPGA) */
#include "fpga_command.h"

namespace intel {
namespace fpga {
namespace ase {

template<class afu> class fpga_emulator
{
protected:
	typedef std::shared_ptr<fpga_emulator> ptr_t;
	using Lock = std::unique_lock<std::mutex>;

        /// Pointer to the AFU model
	mutable	Lock	    	            m_afu_model_lock;
	mutable	std::mutex	            m_afu_model_mutex;
	std::shared_ptr<afu_wrapper<afu>>   m_afu_model;

	/// Pointer to the ASE simulator
	mutable Lock			     m_ase_simulator_lock;
	mutable std::mutex		     m_ase_simulator_mutex;
	std::shared_ptr<fpga_simulator<afu>> m_ase_simulator;

	/// List of FPGA transactions (originated from OPAE application)
	std::list<fpga_command>	     m_fpga_commands;

	/// List of FPGA events (originated from AFU)
	std::list<fpga_event>	             m_fpga_events;

	/// List of dispatcher/receiver pairs for OPAE to/from AFU communication
	std::list<fpga_interface>	     m_fpga_interfaces;

 	/// Shared buffer data structures, among all concurrent software threads
	std::list<dma_buffer_emu>	     m_fpga_buffers;

	/// Shared MMIO data structures, among all concurrent software threads
	std::list<mmio_emu>	             m_fpga_mmios;

	/// Transaction (a.k.a. commands dispatcher)
	/// Sends transactions from transactions list (queue) to the fpga_interfaces
	std::atomic<bool>                    m_transact_tx_enable;
	std::thread                          m_transact_tx_thread;
	void                                 m_transact_tx_method();

	std::atomic<bool>                    m_event_rx_enable;
	std::thread                          m_event_rx_thread;
	void                                 m_event_rx_method();

	/// Singleton constructor is private
	fpga_emulator(void) {
		m_afu_model_lock = std::move(Lock(m_afu_model_mutex));
		m_ase_simulator_lock = std::move(Lock(m_ase_simulator_mutex));

		m_transact_tx_thread = std::thread(&fpga_emulator::m_transact_tx_method, this);
		m_event_rx_thread = std::thread(&fpga_emulator::m_event_rx_method, this);
	};
	static std::shared_ptr<fpga_emulator> instance_ = nullptr;

	/// Receive a command from the OPAE application
	virtual fpga_command_result command_receive(fpga_command& app_transaction) = 0;

	/// Transmit transaction to the fpga_interface threads
	virtual fpga_command_result fpga_command_dispatch(const fpga_command& app_transaction) = 0;

public:
	static std::shared_ptr<fpga_emulator<afu>> instance() {
		if (!instance_)
		{
			instance_.reset(new fpga_emulator<afu>());
		}
		return instance_;
	}

	/// Get & release functions for the afu_model; weak_ptr is not owning (weak)
	std::weak_ptr<afu_wrapper<afu>> get_afu_model() const {
		m_afu_model_lock.lock();
		return m_afu_model;
	}

	bool release_afu_model() const {
		m_afu_model_lock.unlock();
	}

	/// Get & release functions for the ase_simulator
	std::weak_ptr<fpga_simulator<afu>> get_ase_simulator() const {
		m_ase_simulator_lock.lock();
		return m_ase_simulator;
	}

	bool release_ase_simulator() const {
		m_ase_simulator_lock.unlock();
	}

};

} // end of namespace ase
} // end of namespace fpga
} // end of namespace intel

#endif //__cplusplus

#endif // FPGA_EMULATOR_H
