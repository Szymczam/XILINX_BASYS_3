
//#include <stdio.h>

#include "xil_printf.h"
#include "sleep.h"	//delay


#include "device.h"


cfpga::cfpga() {
}
cfpga::~cfpga() {}


XGpio 		Gpio0_in0;
XGpio 		Gpio0_out0;

cfpga	fpga;





int main(){

	fpga.Init_GPIO();
	print("Hello World\n\r");

	fpga.gpio.GPIO0_out1.bit.LED2 = 1;


    //cleanup_platform();
    while(1){


    	fpga.gpio.GPIO0_in1.all = fpga.GPIO_in0_read();
    	fpga.GPIO_out0_write(fpga.gpio.GPIO0_out1.all);
    	usleep(100000);
    	fpga.GPIO_out0_write(0);
    	usleep(100000);
    }

}
