#ifndef SYSCONF_H_
#define SYSCONF_H_

#include "stm32f4xx.h"

void RCC_Config(void);
void GPIO_Config(void);
void USART_Config(void);
void Delay(__IO uint32_t nCount);
void DMA_Config(void);
void DCMI_Config(void);

void DMA_Stream_IRQHandler(void);
void DCMI_Frame_IRQHandler(void);
void NVIC_Config(void);

void SysInit(void);

#endif