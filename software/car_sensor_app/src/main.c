#include "xparameters.h"
#include "xgpio.h"
#include "string.h"
//#include "stdlib.h"
//#include "stdio.h"
int main()
{
    XGpio dip;
    u32   dip_check;
    xil_printf("-- Start of the program --\r\n");
    // Use XGpio_Initialize to initialize the DIP GPIO device

    XGpio_Initialize(&dip, XPAR_AXI_GPIO_0_DEVICE_ID);
    // Use XGpio_SetDataDirection to set the input/output direction
    XGpio_SetDataDirection(&dip, 1, 0xFFFFFFFF);
    // Use XGpio_Initialize to initialize the SW GPIO device

    //int row , collum;
	//row =1456; // amount of row that the image we analyed has
	//collum = 2059; // the aomunt of colum the image we analyzed has
   // int mask [row][collum];// will contain the bit map of mask
    //int Results [row] [collum]; // will contain bit map of results
    // centroid that contain the 	cordinates of each parking lot data gotten from MATLAB
  /*  FILE *fstream = fopen("bwmask.csv","r");
    if(fstream == NULL)
      {
         xil_printf("\n file opening failed ");

      }*/
    int centroid [14][2] = {{479,427},{717,426},{953,432},{1189,435},{1427,435},{1660,442},{1900,443},
    						{481,967},{715,969},{950,966},{1189,969},{1422,969},{1657,971},{1899,972}
    						};
    int mask [14] ={1,1,1,1,1,1,1,1,1,1,1,1,1,1};
    int result [14]={1,1,1,1,0,0,1,0,0,1,1,1,0,0};

    while (1)
    {
        // Use XGpio_DiscreteRead to read the status of btns
    	dip_check= XGpio_DiscreteRead(&dip, 1);

        // Use xil_printf to write the status on the screen
    	 xil_printf("DIP Status %x\r\n", dip_check);

    	 if (dip_check ==0)
    	 {
    		 xil_printf("Select Which parking lot to check for a car \r\n");
    	 }
    	 if (dip_check >0 && dip_check <15)
    	    	 {
    	    		 xil_printf("checking paring lot %x\r\n",dip_check);
    	    		 int x =  centroid [dip_check -1] [0]; // define x cordinate of the image
    	    		 int y =  centroid [dip_check - 1] [1]; // define y cordinate of the image
    	    		 xil_printf("cordinates at x  %d\r",x );
    	    		 xil_printf(" and  y %d\r\n" ,y);
    	    		 if((mask[dip_check-1]) == (result[dip_check-1]))
    	    		 {
    	    			 xil_printf("a car is parked at parking lot %d\r\n ", dip_check);

    	    		 }
    	    		 else{
    	    			 xil_printf("this parking lot is free at parking lot  %d\r\n", dip_check);
    	    		 }

    	    	 }
    	 if (dip_check ==15)
    	 {
    		 xil_printf(" program is now ending  car detector analysis scan complete \n"  );
    		 return 0;
    	 }

    	 // The Zynq clock runs at 100 MHz.
    	 for (int i =0 ; i<9999999; i++);

    }
}
