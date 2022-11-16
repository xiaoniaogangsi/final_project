// Main.c - makes LEDG0 on DE2-115 board blink if NIOS II is set up correctly
// for ECE 385 - University of Illinois - Electrical and Computer Engineering
// Author: Zuofu Cheng

int main()
{
//	int i = 0;
//	volatile unsigned int *LED_PIO = (unsigned int*)0x40; //make a pointer to access the PIO block
//
//	*LED_PIO = 0; //clear all LEDs
//	while ( (1+1) != 3) //infinite loop
//	{
//		for (i = 0; i < 100000; i++); //software delay
//		*LED_PIO |= 0x1; //set LSB
//		for (i = 0; i < 100000; i++); //software delay
//		*LED_PIO &= ~0x1; //clear LSB
//	}
//	return 1; //never gets here

	int i = 0;
	int sum;
	volatile unsigned int *LED_PIO = (unsigned int*)0x40;
	volatile unsigned int *SWITCH_PIO = (unsigned int*)0x20;
	volatile unsigned int *RESET_PIO = (unsigned int*)0x80;
	volatile unsigned int *ACCUMULATE_PIO = (unsigned int*)0x70;
	*LED_PIO = 0;
	while ((1+1) != 3){	//Infinite loop
		if (*RESET_PIO == 0){	//When key[0] is pressed, reset the LEDs
			*LED_PIO = 0;
		}
		if (*ACCUMULATE_PIO == 0){	//When key[1] is pressed
			while (*ACCUMULATE_PIO != 1){
				i |= 1;	//software delay until key[1] is released
			}
			if (*LED_PIO + *SWITCH_PIO <= 255){
				*LED_PIO += *SWITCH_PIO;
			}else{		//Overflow
				sum = *LED_PIO + *SWITCH_PIO;
				while (sum > 255){
					sum = sum - 256;
				}
				*LED_PIO = sum;
			}
		}
	}
	return 0;
}
