/******************************************************************************/
/*                                                                            */
/* main.cc -- Demo program for the PmodSD IP                                  */
/*                                                                            */
/******************************************************************************/
/* Author: Thomas Kappenman                                                   */
/* Copyright 2016, Digilent Inc.                                              */
/******************************************************************************/
/*
*
* Copyright (c) 2013-2016, Digilent <www.digilentinc.com>
* Contact Digilent for the latest version.
*
* This program is free software; distributed under the terms of
* BSD 3-clause license ("Revised BSD License", "New BSD License", or "Modified BSD License")
*
* Redistribution and use in source and binary forms, with or without modification,
* are permitted provided that the following conditions are met:
*
* 1.    Redistributions of source code must retain the above copyright notice, this
*        list of conditions and the following disclaimer.
* 2.    Redistributions in binary form must reproduce the above copyright notice,
*        this list of conditions and the following disclaimer in the documentation
*        and/or other materials provided with the distribution.
* 3.    Neither the name(s) of the above-listed copyright holder(s) nor the names
*        of its contributors may be used to endorse or promote products derived
*        from this software without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
* INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
* BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
* DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
* LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
* OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
* OF THE POSSIBILITY OF SUCH DAMAGE.
*/
/******************************************************************************/
/* File Description:                                                          */
/*                                                                            */
/* This demo creates a file in your SD card and writes to it                  */
/*                                                                            */
/******************************************************************************/
/* Revision History:                                                          */
/*                                                                            */
/*    08/10/2016(TommyK):   Created                                           */
/*    01/20/2018(atangzwj): Validated for Vivado 2017.4                       */
/*                                                                            */
/******************************************************************************/

//#include "PmodSD.h"
#include "xil_cache.h"
#include "xil_printf.h"
#include "xil_printf.h"
#include "sleep.h"	//delay


#include "device.h"


cfpga::cfpga() {
}
cfpga::~cfpga() {}


XGpio 		Gpio0_in0;
XGpio 		Gpio0_out0;

cfpga	fpga;
int value[2];
void DemoInitialize();
void DemoRun();


int main(void) {
   Xil_ICacheEnable();
   Xil_DCacheEnable();

   DemoInitialize();
   DemoRun();
   return 0;
}

void DemoInitialize() {
	fpga.Init_GPIO();
	print("Hello World\n\r");

	fpga.gpio.GPIO0_out1.bit.CPU_Led = 1;

	value[0] = 100;
	value[1] = 200;
}





void DemoRun() {

   while (1){
   	fpga.gpio.GPIO0_in1.all = fpga.GPIO_in0_read();


   	fpga.gpio.GPIO0_out1.bit.CPU_PSM_SPS_14b = value[0];
   	fpga.gpio.GPIO0_out1.bit.CPU_PSM_DPS_14b = value[1];
   	fpga.gpio.GPIO0_out1.bit.CPU_Led = 1;
   	fpga.GPIO_out0_write(fpga.gpio.GPIO0_out1.all);
   	usleep(100000);
   	fpga.gpio.GPIO0_out1.bit.CPU_Led = 0;
	fpga.GPIO_out0_write(fpga.gpio.GPIO0_out1.all);
   	usleep(100000);

   	xil_printf("Disk mounted\r\n");
   }
}
