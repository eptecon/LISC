/**
  ******************************************************************************
  * @file    main.c
  * @author  EP
  * @version V1.0.1
  * @date    04-November-2018
  * @brief   Main program body
  ******************************************************************************
  */

/* Includes ------------------------------------------------------------------*/
#include "stm32f4xx.h"
#include "system.h"
#include "stm32f4xx_dcmi.h"
#include "stm32f4xx_dma.h"

/* macro -------------------------------------------------------------*/
#define TxBufferSize1   (countof(TxBuffer1) - 1)
#define TxBufferSize2   (countof(TxBuffer2) - 1)

#define countof(a)   (sizeof(a) / sizeof(*(a)))

/* variables ---------------------------------------------------------*/
uint8_t TxBuffer1[] = "The quick brown fox jumps over the lazy dog\r\n";
uint8_t TxBuffer2[] = "2 USART DMA Polling: USARTz -> USARTy using DMA";
uint8_t RxBuffer1[2049];
uint8_t RxBuffer2[TxBufferSize1];

/* flags */
uint8_t Start = 1;
uint8_t DataReady = 0;
uint8_t CaptureData = 0;

/* function prototypes -----------------------------------------------*/
void MainFunction(void);


void main(void)
{
    /* System Initialisation */
	SysInit();
    
	while (1)
        {
            MainFunction();
		}

}/* main */


void MainFunction(void)
{

	/* MainFunction */
	if ((GPIO_ReadInputDataBit(GPIOA, GPIO_Pin_0) == 1))
	{
		GPIO_SetBits(GPIOA, GPIO_Pin_5);
		GPIO_SetBits(GPIOD,  GPIO_Pin_13);
		DMA_ClearITPendingBit(DMA1_Stream6, DMA_IT_TCIF6);
		DMA_ClearITPendingBit(DMA2_Stream1, DMA_IT_TCIF1);
		DCMI_ClearITPendingBit(DCMI_IT_FRAME);

		//DMA_Cmd(DMA2_Stream1, DISABLE);
		CaptureData = 1;
		Start = 0;

	}

	if(u16CaptureData == 1)
	{
		//Start = 0;
		GPIO_ResetBits(GPIOA, GPIO_Pin_5);
		//GPIO_SetBits(GPIOD,  GPIO_Pin_13);

		DMA_Cmd(DMA2_Stream1, ENABLE);

		DCMI_Cmd(ENABLE);
		Delay(200);

		DCMI_CaptureCmd(ENABLE);

		Delay(200);

		if (DCMI_GetITStatus(DCMI_IT_FRAME))
		  {
		      /* Clear ... interrupt pending bit */
			  DCMI_ClearITPendingBit(DCMI_IT_FRAME);
			  u16DataReady = 1;
			  u16CaptureData = 0;
			  GPIO_SetBits(GPIOD,  GPIO_Pin_15);
		  }

		DataReady = 1;
		//CaptureData = 0;
	}

	if (DataReady == 1)
	{
		Delay(200);

		//DCMI_CaptureCmd(DISABLE);
		//while (i  < sizeof(Data)-1)
		//{
			//while(USART_GetFlagStatus(USART2, USART_FLAG_TC) == RESET);
			//USART_SendData(USART2, Data[i]);
			//i++;
		//}

		//Delay(200);

		if(DMA_GetITStatus(DMA1_Stream6, DMA_IT_TCIF6) == SET)
		{
			//GPIO_SetBits(GPIOD,  GPIO_Pin_12);
			DataReady = 0;
		}

		DMA_Cmd(DMA1_Stream6, ENABLE);
		Delay(2000);

		DataReady = 0;
		//DMA_Cmd(DMA1_Stream6, DISABLE);
		DMA_Stream_IRQHandler();

	}

}/* Main Function */
