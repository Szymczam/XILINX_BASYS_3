/*
 * device.h
 *
 *  Created on: 30 gru 2022
 *      Author: marek
 */


#define SRC_DEVICE_H_

#include "xparameters.h"
#include "xgpio.h"

#define GPIO_CHANNEL_0			0x01
#define GPIO_CHANNEL_1			0x02


#define GPIO_0_DEVICE_ID		XPAR_GPIO_0_DEVICE_ID

extern XGpio 		Gpio0_in0;
extern XGpio 		Gpio0_out0;



union CPU_GPIO0_IN {
	u32 all;
	struct{
		u32 btn : 5;
		u32 rsvd : 27;
	}bit;
};

union CPU_GPIO0_OUT {
	u32 all;
	struct{
		u32 LED2 : 1;
		u32 rsvd : 31;
	}bit;
};


struct GPIO_DATA {
	union   CPU_GPIO0_IN	GPIO0_in1;
	union   CPU_GPIO0_OUT	GPIO0_out1;

};


class cfpga {
public:
    //! Constructor
	cfpga();

    //! Destructor
    ~cfpga();

    volatile struct GPIO_DATA gpio;


     void GPIO_out0_write(u32 data){
    	XGpio_DiscreteWrite(&Gpio0_out0, GPIO_CHANNEL_1, data);

    }
    inline u32 GPIO_in0_read(){
    	return XGpio_DiscreteRead(&Gpio0_in0, GPIO_CHANNEL_0);

    }



    int Init_GPIO(){
    	int status;

    	status = XGpio_Initialize(&Gpio0_in0, GPIO_0_DEVICE_ID);
    	if (status != XST_SUCCESS)	return XST_FAILURE;
        XGpio_SetDataDirection(&Gpio0_in0, GPIO_CHANNEL_0, 0xFFFFFFFF);


    	status = XGpio_Initialize(&Gpio0_out0, GPIO_0_DEVICE_ID);
    	if (status != XST_SUCCESS)	return XST_FAILURE;
        XGpio_SetDataDirection(&Gpio0_out0, GPIO_CHANNEL_1, 0x00000000);

    	return status;
    }


};


int Init_GPIO();







