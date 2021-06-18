#include "stm32f4xx_rcc.h"
#include "stm32f4xx_gpio.h"
#include "stm32f4xx_dcmi.h"
#include "stm32f4xx_dma.h"
#include "stm32f4xx_usart.h"
#include "misc.h"

/* System Clocks Configurations ---------------------------------------------------------*/
void RCC_Config(void)
{
  /* GPIOA, GPIOB, GPIOC and GPIOD Periph clock enable */
  RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOA | RCC_AHB1Periph_GPIOB | RCC_AHB1Periph_GPIOC | RCC_AHB1Periph_GPIOD, ENABLE);

  /* USART2 Periph clock enable */
  RCC_APB1PeriphClockCmd(RCC_APB1Periph_USART2, ENABLE);

  /* DMA1 clock enable */
  RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_DMA1, ENABLE);

  /* Enable DMA2 clock */
  RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_DMA2, ENABLE);

  /* DCMI clock enable */
  RCC_AHB2PeriphClockCmd(RCC_AHB2Periph_DCMI, ENABLE);
}/* RCC_Config */


/* GPIO Configurations ---------------------------------------------------------*/
void GPIO_Config(void)
{
  GPIO_InitTypeDef  GPIO_InitStructure;


  /* USART GPIO Configurations ---------------------------------------------------------*/
  /* Configure PA2 for USART2 TX as AF */
  GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
  GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_UP;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF;
  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_100MHz;
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_2;
  GPIO_Init(GPIOA, &GPIO_InitStructure);

  /* Configure PA3 for USART2 RX as AF */
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF;
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_3;
  GPIO_Init(GPIOA, &GPIO_InitStructure);

  /* Connect PA2 and PA3 to AF */
  GPIO_PinAFConfig(GPIOA, GPIO_PinSource2, GPIO_AF_USART2);		/* TX */
  GPIO_PinAFConfig(GPIOA, GPIO_PinSource3, GPIO_AF_USART2);		/* RX */

  /* DCMI GPIO Configurations ---------------------------------------------------------*/
  /* Configure PC6, PC7, PC8, PC9, PC11 for DCMI Data (D0, D1, D2, D3, D4) as AF */
  GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
  GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_UP;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF;
  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_100MHz;
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_6 | GPIO_Pin_7 | GPIO_Pin_8 | GPIO_Pin_9 | GPIO_Pin_11;
  GPIO_Init(GPIOC, &GPIO_InitStructure);

  /* Configure PB6, PB8, PB9 for DCMI Data (D5, D6, D7) and PB7 for DCMI VSYNC as AF */
  GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
  GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_UP;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF;
  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_100MHz;
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_6 | GPIO_Pin_7 | GPIO_Pin_8 | GPIO_Pin_9;
  GPIO_Init(GPIOB, &GPIO_InitStructure);

  /* Configure PA4 and PA6  for DCMI HSYNC and PIXCLK */
  GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
  GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_UP;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AF;
  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_100MHz;
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_4 | GPIO_Pin_6;
  GPIO_Init(GPIOA, &GPIO_InitStructure);

  /* Connect DCMI pins to AF */
  GPIO_PinAFConfig(GPIOC, GPIO_PinSource6, GPIO_AF_DCMI);
  GPIO_PinAFConfig(GPIOC, GPIO_PinSource7, GPIO_AF_DCMI);
  GPIO_PinAFConfig(GPIOC, GPIO_PinSource8, GPIO_AF_DCMI);
  GPIO_PinAFConfig(GPIOC, GPIO_PinSource9, GPIO_AF_DCMI);
  GPIO_PinAFConfig(GPIOC, GPIO_PinSource11, GPIO_AF_DCMI);

  GPIO_PinAFConfig(GPIOB, GPIO_PinSource6, GPIO_AF_DCMI);
  GPIO_PinAFConfig(GPIOB, GPIO_PinSource7, GPIO_AF_DCMI);
  GPIO_PinAFConfig(GPIOB, GPIO_PinSource8, GPIO_AF_DCMI);
  GPIO_PinAFConfig(GPIOB, GPIO_PinSource9, GPIO_AF_DCMI);

  GPIO_PinAFConfig(GPIOA, GPIO_PinSource4, GPIO_AF_DCMI);
  GPIO_PinAFConfig(GPIOA, GPIO_PinSource6, GPIO_AF_DCMI);

  /* Common GPIO Configurations ---------------------------------------------------------*/
  /* Configure PA0 as Input for TRIGGER-Pushbutton */
  GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_NOPULL;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IN;
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_0;
  GPIO_Init(GPIOA, &GPIO_InitStructure);

  /* Configure PA5 as Output for TRIGGER-Signal */
  GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
  GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_NOPULL;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_OUT;
  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_100MHz;
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_5;
  GPIO_Init(GPIOA, &GPIO_InitStructure);

  /* Configure PA7 as Input for READY */
  GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_NOPULL;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IN;
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_7;
  GPIO_Init(GPIOA, &GPIO_InitStructure);

  /* Configure PD12, PD13, PD14 and PD15 as Output for LEDs (green, orange red blue) */
  GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
  GPIO_InitStructure.GPIO_PuPd = GPIO_PuPd_NOPULL;
  GPIO_InitStructure.GPIO_Mode = GPIO_Mode_OUT;
  GPIO_InitStructure.GPIO_Speed = GPIO_Speed_100MHz;
  GPIO_InitStructure.GPIO_Pin = GPIO_Pin_12 | GPIO_Pin_13 | GPIO_Pin_14 | GPIO_Pin_15;
  GPIO_Init(GPIOD, &GPIO_InitStructure);


}/* GPIO_Config */


/* USART Configurations ---------------------------------------------------------*/
void USART_Config(void)
{
  USART_InitTypeDef USART_InitStruct;
  /* USARTx configured as follow:
          - BaudRate = 115200 baud
          - Word Length = 8 Bits
          - One Stop Bit
          - No parity
          - Hardware flow control disabled (RTS and CTS signals)
          - Receive and transmit enabled
    */
  /* Configure USART2 */
  USART_InitStruct.USART_BaudRate = 115200;
  USART_InitStruct.USART_WordLength = USART_WordLength_8b;
  USART_InitStruct.USART_StopBits = USART_StopBits_1;
  USART_InitStruct.USART_Parity = USART_Parity_No;
  USART_InitStruct.USART_HardwareFlowControl = USART_HardwareFlowControl_None;
  USART_InitStruct.USART_Mode = USART_Mode_Rx | USART_Mode_Tx;
  USART_Init(USART2, &USART_InitStruct);

  /* Activate USART2 */
  USART_Cmd(USART2, ENABLE);
}/* USART_Config */


/* Delay function  ...TBD ---------------------------------------------------------*/
void Delay(__IO uint32_t nCount)
{
  while(nCount--)
  {
  }
}/* Delay */


/* DMA Configurations ---------------------------------------------------------*/
void DMA_Config(void)
{
  DMA_InitTypeDef  DMA_InitStructure;

  /* DMA1 Stream6 Configuration */
  DMA_DeInit(DMA1_Stream6);

  DMA_InitStructure.DMA_Channel = DMA_Channel_4;
  DMA_InitStructure.DMA_BufferSize =(uint16_t)sizeof(RxBuffer1) - 1;
  DMA_InitStructure.DMA_DIR = DMA_DIR_MemoryToPeripheral; // Transmit form memory via UART2
  DMA_InitStructure.DMA_Memory0BaseAddr = (uint32_t)RxBuffer1;
  DMA_InitStructure.DMA_MemoryDataSize = DMA_MemoryDataSize_Byte;
  DMA_InitStructure.DMA_MemoryInc = DMA_MemoryInc_Enable;
  DMA_InitStructure.DMA_PeripheralBaseAddr = (uint32_t)&USART2->DR;
  DMA_InitStructure.DMA_PeripheralDataSize = DMA_PeripheralDataSize_Byte;
  DMA_InitStructure.DMA_PeripheralInc = DMA_PeripheralInc_Disable;
  DMA_InitStructure.DMA_Mode = DMA_Mode_Normal;
  DMA_InitStructure.DMA_Priority = DMA_Priority_Medium;
  DMA_InitStructure.DMA_FIFOMode = DMA_FIFOMode_Enable;
  DMA_InitStructure.DMA_FIFOThreshold = DMA_FIFOThreshold_Full;
  DMA_InitStructure.DMA_MemoryBurst = DMA_MemoryBurst_Single;
  DMA_InitStructure.DMA_PeripheralBurst = DMA_PeripheralBurst_Single;

  DMA_Init(DMA1_Stream6, &DMA_InitStructure);

  /* Enable the USART Tx DMA request */
  USART_DMACmd(USART2, USART_DMAReq_Tx, ENABLE);

  /* Enable DMA Stream Transfer Complete interrupt */
  DMA_ITConfig(DMA1_Stream6, DMA_IT_TC, ENABLE);

  /* Enable DMA Stream Half Transfer Complete interrupt */
  DMA_ITConfig(DMA1_Stream6, DMA_IT_HT, ENABLE);

  //DMA_ClearITPendingBit(DMA1_Stream6, DMA_IT_TCIF6);
  /* Enable the DMA RX Stream */
  //DMA_Cmd(DMA1_Stream6, ENABLE);

  /* DMA2 Stream1 Configuration */
  DMA_DeInit(DMA2_Stream1);

  DMA_InitStructure.DMA_Channel = DMA_Channel_1;
  DMA_InitStructure.DMA_BufferSize = (sizeof(RxBuffer1)/sizeof(uint32_t)); //(uint16_t)sizeof(RxBuffer1) - 1; //1;
  DMA_InitStructure.DMA_DIR = DMA_DIR_PeripheralToMemory;			//DCMI to memory
  DMA_InitStructure.DMA_Memory0BaseAddr = (uint32_t)RxBuffer1;
  DMA_InitStructure.DMA_MemoryDataSize = DMA_MemoryDataSize_Byte;
  DMA_InitStructure.DMA_MemoryInc = DMA_MemoryInc_Enable;
  DMA_InitStructure.DMA_PeripheralBaseAddr = (uint32_t)(DCMI_BASE + 0x28);
  DMA_InitStructure.DMA_PeripheralDataSize = DMA_PeripheralDataSize_Byte;
  DMA_InitStructure.DMA_PeripheralInc = DMA_PeripheralInc_Disable;
  DMA_InitStructure.DMA_Mode = DMA_Mode_Normal;
  DMA_InitStructure.DMA_Priority = DMA_Priority_High;
  DMA_InitStructure.DMA_FIFOMode = DMA_FIFOMode_Disable;
  DMA_InitStructure.DMA_FIFOThreshold = DMA_FIFOThreshold_Full;
  DMA_InitStructure.DMA_MemoryBurst = DMA_MemoryBurst_Single;
  DMA_InitStructure.DMA_PeripheralBurst = DMA_PeripheralBurst_Single;

  DMA_Init(DMA2_Stream1, &DMA_InitStructure);

   /* Enable DMA Stream Transfer Complete interrupt */
  DMA_ITConfig(DMA2_Stream1, DMA_IT_TC, ENABLE);

  /* Enable DMA Stream Half Transfer Complete interrupt */
  DMA_ITConfig(DMA2_Stream1, DMA_IT_HT, ENABLE);

}/* DMA_Config */


/* DCMI Configurations ---------------------------------------------------------*/
void DCMI_Config(void)
{
  DCMI_InitTypeDef DCMI_InitStructure;

  /* DCMI configuration */
  DCMI_InitStructure.DCMI_CaptureMode = DCMI_CaptureMode_Continuous;
  DCMI_InitStructure.DCMI_SynchroMode = DCMI_SynchroMode_Hardware;
  DCMI_InitStructure.DCMI_PCKPolarity = DCMI_PCKPolarity_Rising;
  DCMI_InitStructure.DCMI_VSPolarity = DCMI_VSPolarity_High;
  DCMI_InitStructure.DCMI_HSPolarity = DCMI_HSPolarity_High;
  DCMI_InitStructure.DCMI_CaptureRate = DCMI_CaptureRate_All_Frame;
  DCMI_InitStructure.DCMI_ExtendedDataMode = DCMI_ExtendedDataMode_8b;

  DCMI_Init(&DCMI_InitStructure);

  /* mask interrupt for DCMI */
  DCMI_ITConfig(DCMI_IT_FRAME, ENABLE);
  DCMI_ITConfig(DCMI_IT_OVF, ENABLE);
  DCMI_ITConfig(DCMI_IT_ERR, ENABLE);
  DCMI_ITConfig(DCMI_IT_VSYNC, ENABLE);


  //DCMI_Cmd(ENABLE);
}/* DCMI_Config */


/**************************************************************************************/

void DMA_Stream_IRQHandler(void)
{
  /* Test on DMA Stream Transfer Complete interrupt */
  if (DMA_GetITStatus(DMA1_Stream6, DMA_IT_TCIF6))
  {
    /* Clear DMA Stream Transfer Complete interrupt pending bit */
    DMA_ClearITPendingBit(DMA1_Stream6, DMA_IT_TCIF6);

    GPIO_SetBits(GPIOD,  GPIO_Pin_14);
  }

  /* Test on DMA Stream Half Transfer interrupt */
  if (DMA_GetITStatus(DMA1_Stream6, DMA_IT_TCIF6))
  {
    /* Clear DMA Stream Half Transfer interrupt pending bit */
    DMA_ClearITPendingBit(DMA1_Stream2, DMA_IT_TCIF2);

    GPIO_SetBits(GPIOD,  GPIO_Pin_12);
  }
}

/**************************************************************************************/

void DCMI_Frame_IRQHandler(void)
{
  /* Test on ... interrupt */
  if (DCMI_GetITStatus(DCMI_IT_FRAME))
  {
    /* Clear ... interrupt pending bit */
	  DCMI_ClearITPendingBit(DCMI_IT_FRAME);

    //GPIO_SetBits(GPIOD,  GPIO_Pin_12);
  }

  /* Test on ... interrupt */
  if (DCMI_GetITStatus(DCMI_IT_OVF))
  {
    /* Clear ... pending bit */
	DCMI_ClearITPendingBit(DCMI_IT_OVF);

    GPIO_SetBits(GPIOD,  GPIO_Pin_13);
  }
  /* Test on ... interrupt */
  if (DCMI_GetITStatus(DCMI_IT_ERR))
  {
    /* Clear ... interrupt pending bit */
	DCMI_ClearITPendingBit(DCMI_IT_ERR);

    GPIO_SetBits(GPIOD,  GPIO_Pin_14);
  }

  /* Test on ... interrupt */
  if (DCMI_GetITStatus(DCMI_IT_VSYNC))
  {
    /* Clear ... pending bit */
    DCMI_ClearITPendingBit(DCMI_IT_VSYNC);

    GPIO_SetBits(GPIOD,  GPIO_Pin_15);
  }

}


/**************************************************************************************/

void NVIC_Config(void)
{
  NVIC_InitTypeDef NVIC_InitStructure;

  /* Configure the Priority Group to 2 bits */
  NVIC_PriorityGroupConfig(NVIC_PriorityGroup_2);

  /* Enable the UART2 TX DMA Interrupt */
  NVIC_InitStructure.NVIC_IRQChannel = DMA1_Stream6_IRQn;
  NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 0;
  NVIC_InitStructure.NVIC_IRQChannelSubPriority = 0;
  NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;
  NVIC_Init(&NVIC_InitStructure);

}


/**************************************************************************************/

void SysInit(void)
{
  RCC_Config();
  GPIO_Config();
  USART_Config();
  DMA_Config();
  DCMI_Config();
  NVIC_Config();

}
