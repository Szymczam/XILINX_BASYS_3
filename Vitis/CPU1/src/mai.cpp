
//#include "PmodSD.h"
#include "xil_cache.h"
#include "xil_printf.h"
#include "sleep.h"	//delay

#include "device.h"
#include "PmodSD.h"


cfpga::cfpga() {
}
cfpga::~cfpga() {}


XGpio 		Gpio0_in0;
XGpio 		Gpio0_out0;

cfpga	fpga;
int value[2];
void Initialize();
void Run();
void Run_SD_card();


int main(void) {
   Xil_ICacheEnable();
   Xil_DCacheEnable();

   Initialize();
   Run_SD_card();
   Run();
   return 0;
}

void Initialize() {
	fpga.Init_GPIO();
	print("Hello World\n\r");

	fpga.gpio.GPIO0_out1.bit.CPU_Led = 1;

	value[0] = 100;
	value[1] = 200;
}


u16 cnt;




void Run() {



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

   	xil_printf("hello Mark %d\r\n", cnt++);
   }
}


void Run_SD_card() {
	   DXSPISDVOL disk(XPAR_PMODSD_0_AXI_LITE_SPI_BASEADDR,
	         XPAR_PMODSD_0_AXI_LITE_SDCS_BASEADDR);
	   DFILE file;

	   // The drive to mount the SD volume to.
	   // Options are: "0:", "1:", "2:", "3:", "4:"
	   static const char szDriveNbr[] = "0:";

	   FRESULT fr;
	   u32 bytesWritten = 0;
	   u32 bytesRead, totalBytesRead;
	   u8 buff[12], *buffptr;

	   xil_printf("PmodSD Demo Launched\r\n");
	   // Mount the disk
	   DFATFS::fsmount(disk, szDriveNbr, 1);

	   xil_printf("Disk mounted\r\n");

	   fr = file.fsopen("newfile.txt", FA_WRITE | FA_CREATE_ALWAYS);
	   if (fr == FR_OK) {
	      xil_printf("Opened newfile.txt\r\n");
	      fr = file.fswrite("It works!!!", 12, &bytesWritten);
	      if (fr == FR_OK)
	         xil_printf("Write successful\r\n");
	      else
	         xil_printf("Write failed\r\n");
	      fr = file.fsclose();
	      if (fr == FR_OK)
	         xil_printf("File close successful\r\n");
	      else
	         xil_printf("File close failed\r\n");
	   } else {
	      xil_printf("Failed to open file to write to\r\n");
	   }

	   fr = file.fsopen("newfile.txt", FA_READ);
	   if (fr == FR_OK) {
	      buffptr = buff;
	      totalBytesRead = 0;
	      do {
	         fr = file.fsread(buffptr, 1, &bytesRead);
	         buffptr++;
	         totalBytesRead += bytesRead;
	      } while (totalBytesRead < 12 && fr == FR_OK);

	      if (fr == FR_OK) {
	         xil_printf("Read successful:");
	         buff[totalBytesRead] = 0;
	         xil_printf("'%s'\r\n", buff);
	      } else {
	         xil_printf("Read failed\r\n");
	      }
	   } else {
	      xil_printf("Failed to open file to read from\r\n");
	   }

}

