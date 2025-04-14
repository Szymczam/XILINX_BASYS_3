
#include <stdlib.h>

#include "xparameters.h"
#include "xgpio.h"
#include "sleep.h"
#include "xil_printf.h"
//#include "xiltimer.h"
//#include "xtmrctr.h"

#define LED_DELAY       1000000

#define GPIO_CHANNEL    0x1
#define GPIO_INPUT      0xFFFFFFFF
#define GPIO_OUTPUT     0xFFFFFFFF 

XGpio 		Gpio0_out0;
volatile int Delay;

//XTmrCtr     timer;


union GPIO0
{
	u32 all;
	struct{
	uint16_t seg7_16b;
	uint16_t LEDs;
	}bits;
};

typedef struct{
	union   GPIO0	out;
    uint32_t        read;
} Gpio_t;
Gpio_t gpio;





int main(void) {
    int Status;
    
    Status = XGpio_Initialize(&Gpio0_out0, XPAR_XGPIO_0_BASEADDR);
    if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

    XGpio_SetDataDirection(&Gpio0_out0, GPIO_CHANNEL, GPIO_INPUT);


    //Status = XTmrCtr_Initialize(&timer, XPAR_AXI_TIMER_0_BASEADDR);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}



    //XTmrCtr_Start(&timer, 0);

    while (1){
        
        print("Hello World\n\r");   
        gpio.read = XGpio_DiscreteRead(&Gpio0_out0, GPIO_CHANNEL);
        gpio.out.bits.LEDs =  gpio.read;

        //XGpio_SetDataDirection(&Gpio0_out0, GPIO_CHANNEL, GPIO_OUTPUT);

        gpio.out.bits.seg7_16b++;

   		/* Set the LED to High */
		XGpio_DiscreteWrite(&Gpio0_out0, GPIO_CHANNEL, gpio.out.all);

		/* Wait a small amount of time so the LED is visible */
		usleep(LED_DELAY);


   }

   return 0;
}


